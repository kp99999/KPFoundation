//
//  TimingTask.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/27.
//  Copyright © 2017年 ZYY. All rights reserved.
//  

#import "TimingTask.h"

#define MaxNotifyNumb           1000     // 最大通知数

#define F_Timing    0.1        // 最小计时单位 0.1秒


#pragma mark - TimingItem 对象
@interface TimingItem : NSObject

@property(nonatomic, strong) NSString *timeId;

@property NSInteger timeCount;        // 以 F_Timing 秒为1个单位

@property(nonatomic, copy) TimingDo timeIn;

@property (nonatomic, strong) dispatch_queue_t dp;

@property BOOL isRunning;       // 是否运行中

@property BOOL isOneTime;

@end


@implementation TimingItem

@end


#pragma mark - TimingTask 实现

static const void * const kDispatchQueueTimingTaskKey = &kDispatchQueueTimingTaskKey;

@interface TimingTask(){
    
    NSMutableArray *notifyToDo;     // 存储通知的动作
    
    NSUInteger counter;
    
    NSUInteger timesId;     // 唯一标示
    
    dispatch_queue_t    tQueue;         // 串行队列，保证线程安全（线程队列，只会在GCD线程上执行，不会暂用主线程）
}

@end

@implementation TimingTask

+ (TimingTask *)Start{
    static dispatch_once_t once;
    static TimingTask * singleton;
    dispatch_once(&once, ^{ singleton = [[TimingTask alloc] init]; });
    return singleton;
}

-(id)init{
    self = [super init];
    if (self) {
        notifyToDo = [[NSMutableArray alloc]initWithCapacity:100];
        
        counter = 0;
        timesId = 1;
        
        [NSThread detachNewThreadSelector:@selector(onThread:) toTarget:self withObject:nil];
        
        tQueue = dispatch_queue_create([[NSString stringWithFormat:@"TimingTask.%@", self] UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(tQueue, kDispatchQueueTimingTaskKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)onThread:(id)sneder
{
//    self.workerThread_NS = [NSThread currentThread];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:F_Timing target:self selector:@selector(activeNotify) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

// 通知处理
- (void)activeNotify{

    counter++;
    
    for (NSInteger i = 0; i < [notifyToDo count]; i++) {
        TimingItem *timingMess = notifyToDo[i];
        
        if (timingMess.timeIn) {
            if (timingMess.isOneTime){
                timingMess.timeCount--;
                if (timingMess.timeCount <= 0 && !timingMess.isRunning) {
                    
                    timingMess.isRunning = YES;
                    
                    dispatch_async(timingMess.dp, ^{
                        
                        timingMess.timeIn();
                        if (timingMess.isOneTime) {
                            timingMess.timeIn = nil;
                            timingMess.dp = nil;
                        }
                        
                        timingMess.isRunning = NO;
                    });
                }
            }else{
                if ((counter % timingMess.timeCount) == 0  && !timingMess.isRunning) {
                    
                    timingMess.isRunning = YES;
                    dispatch_async(timingMess.dp, ^{
                        timingMess.timeIn();
                        
                        timingMess.isRunning = NO;
                    });
                }
            }
        }
    }
    
    // 每10秒钟，遍历一遍，是否有可释放资源
    if (counter % 100 == 0) {
        __weak __typeof(self) _weakSelf = (__bridge id)dispatch_get_specific(kDispatchQueueTimingTaskKey);
        
        assert(_weakSelf != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
        
        dispatch_sync(tQueue, ^() {
            
            for (NSInteger i = 0; i < [notifyToDo count]; i++) {
                if (!((TimingItem *)notifyToDo[i]).timeIn && !((TimingItem *)notifyToDo[i]).isRunning) {
                    [notifyToDo removeObjectAtIndex:i];
                    i--;
                }
            }
            
        });
    }
}

- (NSString *)addNotifyTime:(float)times OneTime:(BOOL)isOneTime RunQueue:(dispatch_queue_t)dq TimeDo:(TimingDo)timeDo{
    __weak __typeof(self) _weakSelf = (__bridge id)dispatch_get_specific(kDispatchQueueTimingTaskKey);
    
    assert(_weakSelf != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
    
    if (times < 0 || !timeDo || MaxNotifyNumb <= [notifyToDo count]){
        return nil;
    }
    
    if (!dq) {
        dq = dispatch_get_main_queue();
    }
    
    NSInteger timeCount = times * 10;
    
    TimingItem *timingMess = [[TimingItem alloc]init];
    timingMess.isOneTime = isOneTime;
    timingMess.isRunning = NO;
    timingMess.timeCount = timeCount < 1 ? 1 : timeCount;
    timingMess.timeIn = timeDo;
    timingMess.dp = dq;
    timingMess.timeId = [NSString stringWithFormat:@"%ld",timesId++];
    
    dispatch_sync(tQueue, ^() {
        
        // 线程安全加载
        [notifyToDo addObject:timingMess];
        
    });
    
    return timingMess.timeId;
}
- (void)delNotifyTime:(NSString *)timeId{
    __weak __typeof(self) _weakSelf = (__bridge id)dispatch_get_specific(kDispatchQueueTimingTaskKey);
    
    assert(_weakSelf != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
    
    if (!timeId) {
        return;
    }
    
    dispatch_sync(tQueue, ^() {
        
        for (NSInteger i = 0; i < [notifyToDo count]; i++) {
            if ([((TimingItem *)notifyToDo[i]).timeId isEqualToString:timeId]) {
                ((TimingItem *)notifyToDo[i]).timeIn = nil;
                ((TimingItem *)notifyToDo[i]).dp = nil;

                break;
            }
        }
        
    });
}

@end

//
//  AnimTimeManege.m
//  CostumeChain
//
//  Created by ecpmac on 13-12-5.
//
//

#import "AnimTimeManege.h"

#import "TimingTask.h"

@interface AnimTimeManege(){
    CGFloat runTime;        // 纪录动画时间
    
    CGFloat nowAnimTime;      // 动画总时间
    
    NSDate *beginDate;        // 计时起点
}

@end

@implementation AnimTimeManege

+ (AnimTimeManege *)AnimTime{
    static dispatch_once_t once;
    static AnimTimeManege * singleton;
    dispatch_once(&once, ^{ singleton = [[AnimTimeManege alloc] init]; });
    return singleton;
}

-(id)init{
    self = [super init];
    if (self) {
        nowAnimTime = 0.0;
        
        runTime = 0.0;
        
        beginDate = nil;
        
        NSString *sddf = [[TimingTask Start] addNotifyTime:0.1 OneTime:NO RunQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) TimeDo:^BOOL{
            
            [self handleTiming];
            
            return YES;
        }];
    }
    return self;
}

#pragma mark -- 内部处理
- (void)startTiming{
    if (!beginDate) {
        beginDate = [NSDate date];
    }
}
- (void)stopTiming:(NSDate *)endTime{
    if (nowAnimTime < 0.0001) {
        beginDate = nil;
        
    }else{
        if (endTime) {
            beginDate = endTime;
        }else{
            beginDate = [NSDate date];
        }
        
    }
}

// 处理背景刷新事件
- (void)handleTiming{
    if (nowAnimTime < 0.0001 || !beginDate){
        [self stopTiming:nil];
        return;
    }
    NSDate *nowDate = [NSDate date];
    CGFloat jetLag = nowDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970;

    nowAnimTime -= jetLag;
    if (nowAnimTime < 0) {
        nowAnimTime = 0.0;
    }
    
    [self stopTiming:nowDate];
}

#pragma mark -- 外部调用
// 纪录动画时间
- (CGFloat)recordTime:(CGFloat)times{
    if (!(times > 0)) {
        return 0;
    }
    
    nowAnimTime += times;
    
    [self startTiming];
    
    return nowAnimTime;
}

// 在fromTime时间点插入times动画
- (CGFloat)insertRecordTime:(CGFloat)times FromTime:(CGFloat)fromTime{
    if (!(times > 0)) {
        return 0;
    }
    
    if (nowAnimTime < (times + fromTime)) {
        nowAnimTime = times + fromTime;
    }
    
    [self startTiming];
    
    return nowAnimTime;
}

// 读取需要延迟的时间
- (CGFloat)getDelayTime{
    
    return nowAnimTime;
}

@end

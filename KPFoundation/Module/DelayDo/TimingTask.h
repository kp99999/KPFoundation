//
//  TimingTask.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/27.
//  Copyright © 2017年 ZYY. All rights reserved.
//  定时任务 （已支持线程安全）

#import <Foundation/Foundation.h>

typedef BOOL (^TimingDo)(void);     // 任务回调

@interface TimingTask : NSObject

+ (TimingTask *)Start;

/**
 添加一个计时任务 (若时间到，任务还在执行，则将跳过此次执行)

 @param times 时间：以秒为单位，最小值为0.1，小于0.1 均等于 0.1
 @param isOneTime 是否只执行一次
 @param dq 要执行的线程队列 (默认在主线程队列执行)
 @param timeDo 执行代码
 @return 返回此次任务的id，用于删除（停止）
 */
- (NSString *)addNotifyTime:(float)times OneTime:(BOOL)isOneTime RunQueue:(dispatch_queue_t)dq TimeDo:(TimingDo)timeDo;

/**
 删除一个任务

 @param timeId 生成任务的id
 */
- (void)delNotifyTime:(NSString *)timeId;

@end

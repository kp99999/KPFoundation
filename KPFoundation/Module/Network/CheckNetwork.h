//
//  CheckNetwork.h
//  ZYYObjcLib
//
//  Created by zyyuann on 15/12/29.
//  Copyright © 2015年 ZYY. All rights reserved.
//

/**
 *  网络状态
 */
typedef NS_ENUM(NSInteger, NetworkStatusType) {

    NetworkStatusTypeFree = 0,      // 未知

    NetworkStatusTypeNot ,          // 没网络

    NetworkStatusTypeWWAN ,         // 移动网络
 
    NetworkStatusTypeWiFi ,         // WiFi
};

@protocol CheckNetworkObserverDelegate <NSObject>

@required       //必须实现

/**
 状态变化回调

 @param type 当前状态
 */
- (void)changeNetworkStatus:(NetworkStatusType)type;

@end


@interface CheckNetwork : NSObject

+ (CheckNetwork *)Share;

/**
 获取当前网络状态（有一定的延迟，不建议调用）

 @return 返回状态
 */
- (NetworkStatusType)getNetworkType;

/**
 绑定网络状态变更回调

 @param delegate 要绑定的对象（对象计数器会被 +1，不用时要记得释放）
 */
- (void)addObserverWithDelegate:(id<CheckNetworkObserverDelegate>)delegate;

/**
 释放回调
 
 @param delegate 要释放的对象
 */
- (void)releaseObserverWithDelegate:(id<CheckNetworkObserverDelegate>)delegate;

@end

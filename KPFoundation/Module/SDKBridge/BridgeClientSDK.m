//
//  BridgeClientSDK.m
//  ZYYObjcLib
//
//  Created by zyyuann on 16/4/18.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import "BridgeClientSDK.h"

#import "TimingTask.h"

#pragma mark - BridgeServiceMode 声明、实现

static NSUInteger uniqueNumb = 1;

@implementation BridgeServiceMode

- (instancetype)initWithTransferId:(NSString *)tId;
{
    self = [super init];
    if (self) {
        if (tId) {
            _transferId = tId;
        }else{
            _transferId = [NSString stringWithFormat:@"%ld",uniqueNumb++];
        }
    }
    return self;
}

@end


#pragma mark - BridgeClientSDK 声明

@interface BridgeClientSDK(){
    NSMutableArray *handleRspArr;       // sdk响应队列
    NSLock *handleLock;
    
    BridgeSDKType bridgeType;       // 所属模块
    
    BridgeDataMode *nowRunMode;      // 当前执行的任务，每次只能有一个任务
    
}

- (void)serviceReceive:(BridgeDataMode *)sData;

@end


#pragma mark - BridgeServer 声明

@interface BridgeServer : NSObject{
    NSMutableDictionary *sdkObjDic;
}

+ (BridgeServer *)Share;

// 注册sdk
- (BOOL)registerSDK:(BridgeClientSDK *)oneSDKObj BridgeType:(BridgeSDKType)bType;

// 发送数据请求
- (BOOL)channelSDKData:(BridgeDataMode *)sData;

@end


#pragma mark -
#pragma mark -

#pragma mark - BridgeDataMode 实现
@implementation BridgeDataMode

- (instancetype)initWithServiceMode:(id)serMode
{
    self = [super init];
    if (self) {
        if (serMode) {
            _serviceMode = serMode;
        }else{
            _serviceMode = [[BridgeServiceMode alloc] initWithTransferId:nil];
        }
        
        _errPost = nil;
    }
    return self;
}

@end


#pragma mark - BridgeServer 实现

@implementation BridgeServer

+ (BridgeServer *)Share{
    static dispatch_once_t once;
    static BridgeServer * singleton;
    dispatch_once(&once, ^{ singleton = [[BridgeServer alloc] init]; });
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        sdkObjDic = [[NSMutableDictionary alloc]initWithCapacity:20];
        
    }
    return self;
}

#pragma mark  外部调用
- (BOOL)registerSDK:(BridgeClientSDK *)oneSDKObj BridgeType:(BridgeSDKType)bType{
    if (oneSDKObj) {
        id hObj = [sdkObjDic objectForKey:[NSString stringWithFormat:@"%ld", bType]];
        if (hObj) {
            return NO;
        }else{
            [sdkObjDic setObject:oneSDKObj forKey:[NSString stringWithFormat:@"%ld", bType]];
            return YES;
        }
    }
    
    return NO;
}

// 发送数据请求
- (BOOL)channelSDKData:(BridgeDataMode *)sData{
    if (!sData) {
        return NO;
    }
    
    id hObj = [sdkObjDic objectForKey:[NSString stringWithFormat:@"%ld", sData.serviceMode.sendToSDK]];
    if (hObj && [hObj isKindOfClass:[BridgeClientSDK class]]) {
        [(BridgeClientSDK *)hObj serviceReceive:sData];
        
        return YES;
    }else{
        // 未注册
        return NO;
    }
}

@end


#pragma mark - BridgeClientSDK 实现

@implementation BridgeClientSDK

#pragma mark 外部调用
- (instancetype)initBridgeType:(BridgeSDKType)bType OpenService:(BOOL)isOpen
{
    self = [super init];
    if (self) {
        
        if ([self isMemberOfClass:[BridgeClientSDK class]]) {
            NSAssert(NO , @"BridgeClientSDK 不可直接初始化");
            return nil;
        }
        
        bridgeType = bType;
        
        [[BridgeServer Share] registerSDK:self BridgeType:bridgeType];
        
        if (isOpen) {
            handleRspArr = [[NSMutableArray alloc] initWithCapacity:10];
            handleLock = [[NSLock alloc] init];
        }else{
            handleRspArr = nil;
            handleLock = nil;
        }
    }
    
    return self;
}

- (void)sendToClientData:(BridgeDataMode *)sData{
    if (!sData) {
        return;
    }
    
    sData.serviceMode.selfSDK = bridgeType;
    
    [[BridgeServer Share] channelSDKData:sData];
}

- (void)provideService:(BridgeServiceMode *)sData{}

- (void)responseToClientData:(id)upData{
    
    // 回调
    if (nowRunMode && nowRunMode.finishDo) {
        if (upData && [upData isKindOfClass:[NSError class]]) {
            nowRunMode.errPost = upData;
            nowRunMode.finishDo(nil);
        }else{
            nowRunMode.finishDo(upData);
        }
        nowRunMode.finishDo = nil;
    }
    
    
    if (!handleRspArr) {
        nowRunMode = nil;
        return;
    }
    
    // 删除
    [handleLock lock];
    
    if (nowRunMode) {
        [handleRspArr removeObject:nowRunMode];
    }
    nowRunMode = nil;
    
    [handleLock unlock];
    
    // 发起新流程
    if ([handleRspArr count] > 0) {
        nowRunMode = handleRspArr[0];
        
        [self provideService:nowRunMode.serviceMode];
    }
}

#pragma mark 私有方法
// 提供服务
- (void)serviceReceive:(BridgeDataMode *)sData{
    NSAssert(handleRspArr , @"模块 不提供服务");
    
    // 来自其他sdk的请求
    [handleLock lock];
    
    [handleRspArr addObject:sData];
    
    [handleLock unlock];
    
    if (!nowRunMode && [handleRspArr count] > 0) {
        nowRunMode = handleRspArr[0];
        
        [self provideService:nowRunMode.serviceMode];
    }
}

@end

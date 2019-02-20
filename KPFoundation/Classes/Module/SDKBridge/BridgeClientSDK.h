//
//  BridgeClientSDK.h
//  ZYYObjcLib
//
//  Created by zyyuann on 16/4/18.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeServiceMode;

typedef void (^ClientFinish)(id data);

// 数据类型
typedef NS_ENUM(NSUInteger, BridgeSDKType){
    SDKFree = 0,

};


@interface BridgeServiceMode : NSObject

@property (strong, nonatomic, readonly)NSString *transferId;      // 唯一标示

@property BridgeSDKType selfSDK;        // 发起sdk
@property BridgeSDKType sendToSDK;      // 发往sdk

@property (nonatomic, strong) id sendPost;

@property NSInteger operationLink;      // 命令操作

@end


// 请求报文
@interface BridgeDataMode : NSObject

@property(nonatomic, strong, readonly) BridgeServiceMode *serviceMode;

@property (nonatomic, strong) NSError *errPost;

@property NSUInteger timeOut;           // 超时处理 0 表示不做超时处理

@property(nonatomic, copy) ClientFinish finishDo;

- (instancetype)initWithServiceMode:(id)serMode;        // serMode 可空

@end


// 每个sdk都必须继承该类，不可直接初始化使用
@interface BridgeClientSDK : NSObject

/**
 初始化，注册一个桥模块

 @param bType 模块类型
 @param isOpen 是否开启提供服务
 @return 返回对象
 */
- (instancetype)initBridgeType:(BridgeSDKType)bType OpenService:(BOOL)isOpen;

/**
 客户端发起请求

 @param sData 发起请求对象
 */
- (void)sendToClientData:(BridgeDataMode *)sData;

/**
 需要提供的服务，对接收到的数据进行处理 (由子类重写该方法)

 @param sData 需要处理的数据
 */
- (void)provideService:(BridgeServiceMode *)sData;

/**
 完成某次服务

 @param upData 回调数据
 */
- (void)responseToClientData:(id)upData;

@end

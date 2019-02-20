//
//  TCPLink.h
//  IMSDK
//
//  Created by zyyuann on 16/3/31.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TCPLinkTimeOut          0.5
#define TCPSendTimeOut          300

#define SendFinishOne           [@"ok" dataUsingEncoding:NSUTF8StringEncoding]

typedef NS_ENUM (NSInteger,TCPLinkType)  {
    TCPLinkFree = 0,     // 未知
    
    TCPLinkFinish,     // 已连接
    
    TCPLinking,      // 连接中
    
    TCPUnLink,      // 未连接
    
    TCPLinkErr      // 连接出错
};

typedef void (^LinkToHandle)(NSData *);

@protocol ProtectLinkDelegate <NSObject>

//必须实现
@required

- (NSString *)getLinkIp;            // 格式 ip:port

- (TCPLinkType)getLinkState;     // 获取连接状态

- (void)sendToSocket:(NSData *)data;       // 发送数据

- (void)connectWithReceiveLink:(LinkToHandle)l_handle;       // 发起连接 并 接收数据回调

//可选实现
@optional

- (void)disconnect;

@end


#pragma mark TCPLinkManage
@interface TCPLinkManage : NSObject<ProtectLinkDelegate>

/*
 ipArr 每一项为 NSDictionary
            NSDictionary 包含：
                            key：@"ip"（nsstring类型）
                            key：@"port"（nsstring 或 nsnumber）
 */

- (instancetype)initWithLinkIP:(NSArray *)ipArr;

@end

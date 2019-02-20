//
//  TCPLink.m
//  IMSDK
//
//  Created by zyyuann on 16/3/31.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import "TCPLinkManage.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface TCPLinkManage()<GCDAsyncSocketDelegate, ProtectLinkDelegate>{
    
    GCDAsyncSocket *asyncSocket;
    
    long tcpTag;
    long tcpTagCount;       // 成功条数
    
    TCPLinkType linkType;
    
    NSArray *imIpAddress;           // im 地址集合
    
    NSString *nowIp;
}

@property (nonatomic, copy) LinkToHandle linkHandle;

@end


@implementation TCPLinkManage

- (instancetype)initWithLinkIP:(NSArray *)ipArr
{
    if (!ipArr) {
        return nil;
    }
    imIpAddress = [[NSArray alloc] initWithArray:ipArr copyItems:YES];
    
    self = [super init];
    if (self) {
        
        linkType = TCPLinkFree;
        
        _linkHandle = nil;
        
        tcpTag = 0;
        tcpTagCount = 0;
       
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
    if (asyncSocket) {
        asyncSocket.delegate = nil;
        asyncSocket = nil;
    }
    
}


#pragma mark - ProtectLinkDelegate

- (NSString *)getLinkIp {
    return nowIp;
}

// 获取连接状态
- (TCPLinkType)getLinkState{
    return linkType;
}

// 发送数据
- (void)sendToSocket:(NSData *)data{
    if (!data) {
        return;
    }
    
    if (!(asyncSocket && [asyncSocket isConnected])) {
        linkType = TCPUnLink;
        return;
    }
    
    @try {
        tcpTag++;
        
        NSLog(@"[发送数据] writeToSocket: %ld", tcpTag);
        
        [asyncSocket writeData:data withTimeout:TCPSendTimeOut tag:tcpTag];
        
    }
    @catch (NSException *exception) {
        NSLog(@" ***** NSException:%@ in writeToSocket *****",exception);
        
        // 考虑重连
        linkType = TCPLinkErr;
    }
}

// 发起连接 并 接收数据回调
- (void)connectWithReceiveLink:(LinkToHandle)l_handle{
    
    _linkHandle = l_handle;
    
    if (!imIpAddress) {
        linkType = TCPLinkErr;
        return;
    }
    
    if (asyncSocket && [asyncSocket isConnected]) {
        linkType = TCPLinkFinish;
        
        if (_linkHandle) {
            _linkHandle(nil);
        }
        
        return;
    }
    
    NSString *ipAdr = nil;
    NSInteger port = 0;
    // ip选择
    id ipDic = nil;
    if ([imIpAddress count] == 1) {
        ipDic = imIpAddress[0];
    } else {
        ipDic = imIpAddress[(arc4random() % [imIpAddress count])];
    }
    if (ipDic && [ipDic isKindOfClass:[NSDictionary class]]) {
        ipAdr = ipDic[@"ip"];
        if (ipDic[@"port"]) {
            if ([ipDic[@"port"] isKindOfClass:[NSString class]]) {
                port = ((NSString *)ipDic[@"port"]).integerValue;
            } else if ([ipDic[@"port"] isKindOfClass:[NSNumber class]]){
                port = ((NSNumber *)ipDic[@"port"]).integerValue;
            }
        }
    }
    
    NSLog(@"TCPLink :connect ipAdr:%@ port:%ld",ipAdr,(long)port);
    
    if (!(ipAdr && [ipAdr length])) {
        linkType = TCPLinkErr;
        return;
    }
    nowIp = [ipAdr stringByAppendingFormat:@":%ld" ,port];
    
    linkType = TCPLinking;
    
    NSError *error = nil;
    [asyncSocket connectToHost:ipAdr onPort:port withTimeout:TCPLinkTimeOut error:&error];
    if (error) {
        NSLog(@"[RHSocketConnection] connectWithHost error: %@", error.description);
        
        linkType = TCPLinkErr;
        
        if (_linkHandle) {
            _linkHandle(nil);
        }
    }
}

- (void)disconnect
{
    NSLog(@"Socket Client:disconnect");
    
    if (asyncSocket && [asyncSocket isConnected]) {
        _linkHandle = nil;
        [asyncSocket disconnect];
    }
}


#pragma mark - GCDAsyncSocketDelegate
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"[断开连接] didDisconnect...%@", err.description);

    linkType = TCPUnLink;
    if (_linkHandle) {
        // 成功相应
        _linkHandle(nil);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"[连接成功] didConnectToHost: %@, port: %d", host, port);
    
    linkType = TCPLinkFinish;
    if (_linkHandle) {
        // 成功相应
        _linkHandle(nil);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"[接收到数据] didReadData length: %lu, tag: %ld", (unsigned long)data.length, tag);
    
    if (_linkHandle && [data length] > 0) {
        _linkHandle(data);
    }
    
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"[发送完数据 闭环] didWriteDataWithTag: %ld", tag);
    [sock readDataWithTimeout:-1 tag:tag];
    
    tcpTagCount++;
    if (tcpTagCount == tcpTag) {
        if (_linkHandle) {
            // 成功相应
            _linkHandle(SendFinishOne);
        }
    }
}

@end

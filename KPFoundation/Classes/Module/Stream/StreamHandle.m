//
//  StreamHandle.m
//  zyy
//
//  Created by zyyuann on 16/3/31.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import "StreamHandle.h"

#import "NSStream+NSStreamAddition.h"

#import "FileToUse.h"

@interface StreamHandle()<NSStreamDelegate>{
    
    NSMutableDictionary *outStreamDic;
}

@end


@implementation StreamHandle

+ (StreamHandle *)Share{
    static dispatch_once_t once;
    static StreamHandle * singleton;
    dispatch_once(&once, ^{ singleton = [[StreamHandle alloc] init]; });
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        outStreamDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)initOutStreamToFolderName:(NSString *)folderName FileName:(NSString *)fileName
{
    if (!(folderName && fileName)) {
        return ;
    }
    if (outStreamDic[fileName]) {
        return;
    }
    
    NSOutputStream *_outStream = [[NSOutputStream alloc] initToFileAtPath:[[FileToUse Share] getRouteFolderName:folderName FileName:fileName] append:NO];
    
    if (!_outStream) {
        return ;
    }
    [_outStream setDelegate:self];
    [_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outStream open];
    
    [outStreamDic setValue:_outStream forKey:fileName];
}

#pragma mark - PublicAPI
- (BOOL)writeToStream:(NSData *)data FileName:(NSString *)fileName{
    if (!(data && fileName)) {
        return NO;
    }
    
    NSOutputStream *_outStream = outStreamDic[fileName];
    
    while (_outStream && [_outStream hasSpaceAvailable] && data) {
        
        NSInteger bytesWritten = [_outStream write:[data bytes] maxLength:[data length]];
        if (_outStream.streamError || bytesWritten < 0) {
            // 出错
            return NO;
        }
        
        if (bytesWritten >= [data length]) {
            data = nil;
        }else{
            data = [data subdataWithRange:NSMakeRange(bytesWritten, [data length] - bytesWritten)];
        }
    }
    
    return YES;
}

- (void)writeToEndWithFileName:(NSString *)fileName{
    if (!fileName) {
        return;
    }
    NSOutputStream *_outStream = outStreamDic[fileName];
    if (_outStream) {
        [_outStream close];
        [_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [outStreamDic removeObjectForKey:fileName];
    }
}

#pragma mark - NSStream Delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventNone:
            NSLog(@"Event type: EventNone");
            break;
        case NSStreamEventOpenCompleted:        // 输入输出流打开完成
            [self p_handleConntectOpenCompletedStream:aStream];
            break;
        case NSStreamEventHasSpaceAvailable:          //发送数据（链路空闲）// 可以发放字节
            [self p_handleEventHasSpaceAvailableStream:aStream];
            break;
        case NSStreamEventErrorOccurred:        // 连接出现错误
            [self p_handleEventErrorOccurredStream:aStream];
            break;
        case NSStreamEventEndEncountered:
            [self p_handleEventEndEncounteredStream:aStream];   // 连接结束
            break;
        case NSStreamEventHasBytesAvailable:            //数据接收 // 有字节可读
            [self p_handleEventHasBytesAvailableStream:aStream];
            break;
    }
}

#pragma mark - PrivateAPI
- (void)p_handleConntectOpenCompletedStream:(NSStream *)aStream
{
//    NSLog(@"handleConntectOpenCompleted");
//    if (aStream == _outStream) {
//        
//        if (self.linkState) {
//            self.linkState(IMTCP_LinkFinish);
//        }
//    }
}

- (void)p_handleEventHasSpaceAvailableStream:(NSStream *)aStream
{
//    canDataSent = YES;
//    NSLog(@"handleEventHasSpaceAvailableStream：可发送数据");
//    
//    if (nowSendData && !nowSendData.isSendAll) {
//        
//        [self writeToSocket:nowSendData];
//        
//        return;
//    }
//    
//    do {
//        if (![sendBuffers count]) {
//            NSLog(@"WRITE - No data to send");
//            
//            return;
//        }
//        
//        nowSendData = [sendBuffers objectAtIndex:0];
//        [sendBuffers removeObjectAtIndex:0];
//        
//        if (![nowSendData.sendData length]) {
//            nowSendData = nil;
//            NSLog(@"WRITE - No data to send");
//            
//        }
//        
//    } while (!nowSendData);
//    
//    [self writeToSocket:nowSendData];
}

- (void)p_handleEventErrorOccurredStream:(NSStream *)aStream
{
//    NSLog(@"handle eventErrorOccurred");
//    
//    [self disconnect];
    
}

- (void)p_handleEventEndEncounteredStream:(NSStream *)aStream
{
//    NSLog(@"handle eventEndEncountered");
//    
//    [self disconnect];
    
}

- (void)p_handleEventHasBytesAvailableStream:(NSStream *)aStream
{
//    if (aStream == _inStream) {
//        
//        uint8_t buf[1024];
//        NSInteger len = 0;
//        NSMutableData *nowReceiveBuf = [[NSMutableData alloc]init];
//        do {
//            len = [(NSInputStream *)aStream read:buf maxLength:1024];
//            
//            if (len > 0) {
//                [nowReceiveBuf appendBytes:(const void *)buf length:len];
//            }
//        
//        } while (len == 1024);
//        
//        NSLog(@"%@", testIp);
//        
//        if (self.linkHandle && [nowReceiveBuf length] > 0) {
//            self.linkHandle(nowReceiveBuf);
//        }
//    }
}

@end

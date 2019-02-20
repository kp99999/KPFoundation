//
//  NSStream+NSStreamAddition.m
//  mtalk
//
//  Created by maye on 13-10-23.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//


#import "NSStream+NSStreamAddition.h"
//TODO we need to check this code later..by zouye
@implementation NSStream (NSStreamAddition)
+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
    CFHostRef           host;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
	
    readStream = NULL;
    writeStream = NULL;
    
    host = CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName);
    if (host != NULL) {
        (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, (SInt32)port, &readStream, &writeStream);
        CFRelease(host);
    }
    
    if (inputStream == NULL) {
        if (readStream != NULL) {
            CFRelease(readStream);
        }
    } else {
        *inputStream = (__bridge NSInputStream *) readStream;
    }
    if (outputStream == NULL) {
        if (writeStream != NULL) {
            CFRelease(writeStream);
        }
    } else {
        *outputStream =(__bridge NSOutputStream *) writeStream;
    }
}

@end

@implementation NSMutableData(NSMutableDataExtension)

-(void)writeBool:(BOOL)value{
}
-(void)writeByte:(uint8_t)value{

    [self appendBytes:&value length:1];
}
-(void)writeShort:(short)v{
    unsigned char b16 = (v >> 8) & 0x00FF;
    unsigned char b8 = v & 0x00FF;
    [self appendBytes:&b16 length:1];
    [self appendBytes:&b8 length:1];
}
-(void)writeInt:(int)aint{
    unsigned char b32 = aint >> 24;
    unsigned char b24 = (aint >> 16) & 0x000000FF;
    unsigned char b16 = (aint >> 8) & 0x000000FF;
    unsigned char b8 = aint & 0x000000FF;
    [self appendBytes:&b32 length:1];
    [self appendBytes:&b24 length:1];
    [self appendBytes:&b16 length:1];
    [self appendBytes:&b8 length:1];
}
-(void)writeLong:(long long)value{
}

-(void)writeFloat:(float)value{
    
}
-(void)writeDouble:(double)value{
}
-(void)writeUTF:(NSString *)value{
}



@end

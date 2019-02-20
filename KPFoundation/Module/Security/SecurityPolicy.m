//
//  SecurityPolicy.m
//  GoodMelt
//
//  Created by linyu on 13-10-16.
//  Copyright (c) 2013年 CCB. All rights reserved.
//

#import "SecurityPolicy.h"

#import <KPFoundation/KPPublicDefine.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

#import <KPFoundation/DeviceBaseData.h>
//#import <KPFoundation/KeychainItemWrapper.h>

#import "zlib.h"

#define AESKEYWORD      @"Q06HU5bm4owAeDcH"     //  aes密钥

@interface NSData (AES)
- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;
@end

@implementation NSData (AES)
- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          0,       // ccb(kCCOptionPKCS7Padding|kCCOptionECBMode)
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}
@end

@implementation SecurityPolicy

#pragma mark - 私用方法

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSInteger)CharToInt:(char)c
{
    if (c >= 'A' && c <= 'Z') {
        return c - 65;
    } else if (c >= 'a' && c <= 'z') {
        return c - 97 + 26;
    } else if (c >= '0' && c <= '9') {
        return c - 48 + 26 + 26;
    } else {
        switch(c) {
            case '+':
                return 62;
            case '/':
                return 63;
            case '=':
                return 0;
            default:
                return -1;
        }
    }
}

#pragma mark - 外部调用
// AES-128-ECB 对16进制解密,,type=1返回nsdata、type=2返回nsstring
+ (id)DecryptAES:(id)data BackType:(NSInteger)type{
    if (!data) {
        return nil;
    }
    
    NSData *do_data = nil;
    if ([data isKindOfClass:[NSString class]]) {
        // 16进制字符串
        NSString *data_str = data;
        Byte *myBuffer = (Byte *)malloc(([data_str length] / 2));
        bzero(myBuffer, [data_str length] / 2 );
        for (int i = 0; i < [data_str length] - 1; i += 2) {
            unsigned int anInt;
            NSString * hexCharStr = [data_str substringWithRange:NSMakeRange(i, 2)];
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            myBuffer[i / 2] = anInt;
        }
        do_data = [NSData dataWithBytes:myBuffer length:[data_str length]/2];
    }else if ([data isKindOfClass:[NSData class]]){
        do_data = data;
    }
    
    NSData *en_data = [do_data AES128DecryptWithKey:AESKEYWORD iv:NULL];
    
    if(type == 1){
        return en_data;
    }else if (type == 2){
        
        NSUInteger lengths = 0;
        if (en_data) {
            Byte *testByte = (Byte *)[en_data bytes];
            while (*testByte++) {
                lengths++;
            }
            
            if (lengths > [en_data length]) {
                return nil;
            }
        }
        
        if (lengths) {
            en_data = [en_data subdataWithRange:NSMakeRange(0, lengths)];
        }
        
        return [[NSString alloc] initWithData:en_data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

// AES-128-ECB 加密
+ (id)EncryptAES:(id)data BackType:(NSInteger)type{
    if (!data) {
        return nil;
    }
    
    NSMutableData *do_data = nil;
    if ([data isKindOfClass:[NSString class]]) {
        do_data = [NSMutableData dataWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }else if ([data isKindOfClass:[NSData class]]){
        do_data = [NSMutableData dataWithData:data];
    }
    
    if (do_data) {
        uint8_t sdf = 0;
        while ([do_data length] % 16) {
            [do_data appendBytes:&sdf length:1];
        }
    }
    
    NSData *enData = [do_data AES128EncryptWithKey:AESKEYWORD iv:NULL];
    
    if(type == 1){
        return enData;
    }else if (type == 2){
        Byte *bytes = (Byte *)[enData bytes];
        
        NSString *hexStr = @"";
        for(int i=0; i < [enData length];i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];  //16进制数
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        NSLog(@"bytes 的16进制数为:%@",hexStr);
        
        if ([hexStr length] > 1)
            return hexStr;
    }
    
    
    return nil;
}

// DES 加密
+ (NSData *)EncryptDES:(id)en_data Key:(NSString *)key
{
    if (!(en_data && key)) {
        return nil;
    }
    NSData *enData = nil;
    if ([en_data isKindOfClass:[NSString class]]) {
        enData = [en_data dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([en_data isKindOfClass:[NSData class]]){
        enData = enData;
    }
    if (!enData) {
        return nil;
    }
    
    NSUInteger dataLength = [enData length];
    Byte iv[] = {1,2,3,4,5,6,7,8};
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [enData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
    }
    return nil;
}

// DES 解密
+ (NSData *)DecryptDES:(id)dec_data Key:(NSString *)key
{
    if (!(dec_data && key)) {
        return nil;
    }
    NSData *decData = nil;
    if ([dec_data isKindOfClass:[NSString class]]) {
        decData = [dec_data dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([dec_data isKindOfClass:[NSData class]]){
        decData = dec_data;
    }
    if (!decData) {
        return nil;
    }
    
    Byte iv[] = {1,2,3,4,5,6,7,8};
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [decData bytes], [decData length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        return [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
    }
    return nil;
}

// MD5 加密
+ (NSString *)EncryptMD5_16:(id)md5_data{
    if (md5_data == nil)
        return nil;
    
    NSData *md5Data = nil;
    if ([md5_data isKindOfClass:[NSString class]]) {
        md5Data = [md5_data dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([md5_data isKindOfClass:[NSData class]]){
        md5Data = md5_data;
    }
    if (md5Data) {
        
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5([md5Data bytes], (CC_LONG)[md5Data length], result);
        
        NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i = 0; i < 16; i++)
            [hash appendFormat:@"%02X", result[i]];
        
        return [hash lowercaseString];
    }
    
    return nil;
}

// Base64 编码
+ (NSString *)EncodeBase64:(NSData *)data{
    if (!(data && data.length > 0))
        return nil;
    
    char *characters = malloc(data.length * 3 / 2);
    
    if (characters == NULL)
        return nil;
    
    NSInteger end = data.length - 3;
    NSInteger index = 0;
    NSInteger charCount = 0;
    NSInteger n = 0;
    
    while (index <= end) {
        int d = (((int)(((char *)[data bytes])[index]) & 0x0ff) << 16)
        | (((int)(((char *)[data bytes])[index + 1]) & 0x0ff) << 8)
        | ((int)(((char *)[data bytes])[index + 2]) & 0x0ff);
        
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = encodingTable[(d >> 6) & 63];
        characters[charCount++] = encodingTable[d & 63];
        
        index += 3;
        
        if(n++ >= 14)
        {
            n = 0;
            characters[charCount++] = ' ';
        }
    }
    
    if(index == data.length - 2)
    {
        int d = (((int)(((char *)[data bytes])[index]) & 0x0ff) << 16)
        | (((int)(((char *)[data bytes])[index + 1]) & 255) << 8);
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = encodingTable[(d >> 6) & 63];
        characters[charCount++] = '=';
    }
    else if(index == data.length - 1)
    {
        int d = ((int)(((char *)[data bytes])[index]) & 0x0ff) << 16;
        characters[charCount++] = encodingTable[(d >> 18) & 63];
        characters[charCount++] = encodingTable[(d >> 12) & 63];
        characters[charCount++] = '=';
        characters[charCount++] = '=';
    }
    NSString * rtnStr = [[NSString alloc] initWithBytesNoCopy:characters length:charCount encoding:NSUTF8StringEncoding freeWhenDone:YES];
    return rtnStr;
}
+ (NSData *)DecodeBase64:(NSString *)data{
    if(!(data && data.length > 0)) {
        return nil;
    }
    NSMutableData *rtnData = [[NSMutableData alloc]init];
    NSInteger slen = data.length;
    int index = 0;
    while (true) {
        while (index < slen && [data characterAtIndex:index] <= ' ') {
            index++;
        }
        if (index >= slen || index  + 3 >= slen) {
            break;
        }
        
        NSInteger byte = ([SecurityPolicy CharToInt:[data characterAtIndex:index]] << 18) + ([SecurityPolicy CharToInt:[data characterAtIndex:index + 1]] << 12) + ([SecurityPolicy CharToInt:[data characterAtIndex:index + 2]] << 6) + [SecurityPolicy CharToInt:[data characterAtIndex:index + 3]];
        Byte temp1 = (byte >> 16) & 255;
        [rtnData appendBytes:&temp1 length:1];
        if([data characterAtIndex:index + 2] == '=') {
            break;
        }
        Byte temp2 = (byte >> 8) & 255;
        [rtnData appendBytes:&temp2 length:1];
        if([data characterAtIndex:index + 3] == '=') {
            break;
        }
        Byte temp3 = byte & 255;
        [rtnData appendBytes:&temp3 length:1];
        index += 4;
        
    }
    return rtnData;
}

// gzip 解压
+ (NSData *)UnGzipData:(NSData *)compressedData
{
    if (!compressedData || [compressedData length] == 0)
        return nil;
    
    NSUInteger full_length = [compressedData length];
    NSUInteger half_length = [compressedData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (uInt)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK)
        return nil;
    
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    
    if (inflateEnd (&strm) != Z_OK)
        return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    return nil;
}
// gzip 加压
+ (NSData*)GzipData:(NSData*)pUncompressedData
{
    if (!pUncompressedData || [pUncompressedData length] == 0)
    {
        NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
        return nil;
    }
    
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
    zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
    zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
    zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
    zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
    zlibStreamStruct.avail_in  = [pUncompressedData length]; // Number of input bytes left to process
    
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK)
    {
        NSString *errorMsg = nil;
        switch (initError)
        {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        return nil;
    }
    
    // Create output memory buffer for compressed data. The zlib documentation states that
    // destination buffer size must be at least 0.1% larger than avail_in plus 12 bytes.
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.1 + 12];
    
    int deflateStatus = 0;
    do
    {
        // Store location where next byte should be put in next_out
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        
        // Calculate the amount of remaining free space in the output buffer
        // by subtracting the number of bytes that have been written so far
        // from the buffer's total capacity
        zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    } while ( deflateStatus == Z_OK );
    
    // Check for zlib error and convert code to usable error message if appropriate
    if (deflateStatus != Z_STREAM_END)
    {
        NSString *errorMsg = nil;
        switch (deflateStatus)
        {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        
        // Free data structures that were dynamically created for the stream.
        deflateEnd(&zlibStreamStruct);
        
        return nil;
    }
    // Free data structures that were dynamically created for the stream.
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength: zlibStreamStruct.total_out];
    NSLog(@"%s: Compressed file from %d KB to %d KB", __func__, [pUncompressedData length]/1024, [compressedData length]/1024);
    
    return compressedData;
}


#pragma mark - 保存和读取UUID
+ (NSString *)saveUUIDToKeyChain {
    /*
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithAccount:@"Identfier" service:@"AppName" accessGroup:nil];
    NSString *string = [keychainItem objectForKey: (__bridge id)kSecAttrGeneric];
    if([string isEqualToString:@""] || !string){
        string = [[[DeviceBaseData deviceUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        [keychainItem setObject:string forKey:(__bridge id)kSecAttrGeneric];
    }
    */
    return @"222";
}

+ (NSString *)ReadUUIDFromKeyChain {
    /*
    KeychainItemWrapper *keychainItemm = [[KeychainItemWrapper alloc] initWithAccount:@"Identfier" service:@"AppName" accessGroup:nil];
    NSString *UUID = [keychainItemm objectForKey: (__bridge id)kSecAttrGeneric];
    
    if (UUID && [UUID length]) {
        return UUID;
    }
    */
    return @"333";
}

//+ (NSString *)getUUIDString {
//    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
//    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
//    NSString *uuidString = [(__bridge NSString*)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    CFRelease(strRef);
//    CFRelease(uuidRef);
//    return uuidString;
//}

@end

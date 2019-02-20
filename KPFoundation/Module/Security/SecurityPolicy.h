//
//  SecurityPolicy.h
//  GoodMelt
//
//  Created by linyu on 13-10-16.
//  Copyright (c) 2013年 CCB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityPolicy : NSObject

// md5 16位
+ (NSString *)EncryptMD5_16:(id)md5_data;

// Base64 编码
+ (NSString *)EncodeBase64:(NSData *)data;
+ (NSData *)DecodeBase64:(NSString *)data;

// AES 加密
+ (id)EncryptAES:(id)data BackType:(NSInteger)type; //type=1返回nsdata、type=2返回nsstring
+ (id)DecryptAES:(id)data BackType:(NSInteger)type; //type=1返回nsdata、type=2返回nsstring

// DES 加密、解密
+ (NSData *)EncryptDES:(id)en_data Key:(NSString *)key;
+ (NSData *)DecryptDES:(id)dec_data Key:(NSString *)key;

// gzip 加解压
+ (NSData *)UnGzipData:(NSData *)compressedData;
+ (NSData*)GzipData:(NSData*)pUncompressedData;

// KeyChain uuid
+ (NSString *)ReadUUIDFromKeyChain;

@end

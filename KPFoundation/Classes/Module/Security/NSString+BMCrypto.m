//
//  NSString+BMCrypto.m
//  Pods
//
//  Created by 马光明 on 16/7/18.
//
//

#import "NSString+BMCrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

const Byte ivv[] = {1,2,3,4,5,6,7,8};
@implementation NSString (BMCrypto)
- (NSString *)BM_MD5
{
    const char *orgin_cstr = [self UTF8String];
    unsigned char result_cstr[CC_MD5_DIGEST_LENGTH];
    CC_MD5(orgin_cstr, (CC_LONG)strlen(orgin_cstr), result_cstr);
    NSMutableString *result_str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result_str appendFormat:@"%02X", result_cstr[i]];
    }
    return [result_str lowercaseString];
}

- (NSString *)BM_SHA1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)BM_SHA256
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self BM_stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)BM_Base64EncodedString
{
    NSData *originData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSData *)BM_Base64EncodedData
{
    NSData *originData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [originData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString *)BM_Base64DecodedString
{
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *output = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    return output;
}

- (NSData *)BM_Base64DecodedData
{
    return [[NSData alloc] initWithBase64EncodedString:self options:0];
}

- (NSString *)BM_EncodeBase64WithKey:(NSString *)key
{
    if (!self || self.length == 0) {
        return nil;
    }
    return [self BM_EncryptDESWithKey:key];
}

- (NSString *)BM_DncodeBase64WithKey:(NSString *)key
{
    if (!self || self.length == 0) {
        return nil;
    }
    return [self BM_DecryptDESWithKey:key];
}

- (NSString *)BM_EncryptDESWithKey:(NSString *)key
{
    
    NSString *ciphertext = nil;
    NSData *textData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivv,
                                          [textData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        ciphertext = [Base64 encode:data];
        ciphertext = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return ciphertext;
}

- (NSString *)BM_DecryptDESWithKey:(NSString *)key
{
    NSString *plaintext = nil;
//    NSData *cipherdata = [Base64 decode:self];
    NSData *cipherdata = [[NSData alloc] initWithBase64EncodedString:self options:0];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext;
}

- (NSString *)BM_URLEncodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,NULL,CFSTR("!*'();:@&=+$,/?%#[]<>"),kCFStringEncodingUTF8));
    return result;
}

- (NSString*)BM_URLDecodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)self,CFSTR(""),kCFStringEncodingUTF8));
    return result;
}

#pragma mark - private
- (NSString *)BM_stringFromBytes:(unsigned char *)bytes length:(int)length
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
    [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}
@end

//
//  NSString+BMCrypto.h
//  Pods
//
//  Created by 马光明 on 16/7/18.
//
//

#import <Foundation/Foundation.h>

@interface NSString (BMCrypto)
/**
 * 返回MD5加密后得字符串。
 */
- (NSString *)BM_MD5;

/**
 * 返回SHA1加密后得字符串。
 */
- (NSString *)BM_SHA1;

/**
 * 返回SHA256加密后得字符串。
 */
- (NSString *)BM_SHA256;

/**
 *  Base64编码
 */
- (NSString *)BM_Base64EncodedString;

/**
 *  Base64编码
 */
- (NSData *)BM_Base64EncodedData;

/**
 *  Base64解码
 */
- (NSString *)BM_Base64DecodedString;

/**
 *  Base64解码
 */
- (NSData *)BM_Base64DecodedData;

/**
 * Des+Base64加密。
 */
- (NSString *)BM_EncodeBase64WithKey:(NSString *)key;

/**
 * Des+Base64解密。
 */
- (NSString *)BM_DncodeBase64WithKey:(NSString *)key;

/**
 * Des加密。
 */
- (NSString *)BM_EncryptDESWithKey:(NSString *)key;

/**
 * Des解密。
 */
- (NSString *)BM_DecryptDESWithKey:(NSString *)key;

/**
 * URL编码。
 */
- (NSString *)BM_URLEncodedString;

/**
 * URL解码。
 */
- (NSString *)BM_URLDecodedString;
@end

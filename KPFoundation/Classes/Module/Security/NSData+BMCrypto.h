//
//  NSData+BMCrypto.h
//  Pods
//
//  Created by 马光明 on 16/7/18.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
extern NSString * const kCommonCryptoErrorDomain;

@interface NSError (BMCryptoErrorDomain)
+ (NSError *) errorWithCCCryptorStatus: (CCCryptorStatus) status;
@end

@interface NSData (BMCryptoCommonDigest)

- (NSData *) BM_MD2Sum;
- (NSData *) BM_MD4Sum;
- (NSData *) BM_MD5Sum;

- (NSData *) BM_SHA1Hash;
- (NSData *) BM_SHA224Hash;
- (NSData *) BM_SHA256Hash;
- (NSData *) BM_SHA384Hash;
- (NSData *) BM_SHA512Hash;

@end

@interface NSData (BMCryptoCommonCryptor)
- (NSData *) BM_base64EncodedData;
- (NSString *) BM_base64EncodedString;
- (NSData *) BM_base64DecodedData;
- (NSString *) BM_base64DecodedString;

- (NSData *) BM_AES256EncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) BM_decryptedAES256DataUsingKey: (id) key error: (NSError **) error;

- (NSData *) BM_DESEncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) BM_decryptedDESDataUsingKey: (id) key error: (NSError **) error;

- (NSData *) BM_CASTEncryptedDataUsingKey: (id) key error: (NSError **) error;
- (NSData *) BM_decryptedCASTDataUsingKey: (id) key error: (NSError **) error;

@end

@interface NSData (BMCryptoLowLevelCommonCryptor)

- (NSData *) BM_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) BM_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) BM_dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

- (NSData *) BM_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) BM_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) BM_decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

@end

@interface NSData (BMCryptoCommonHMAC)

- (NSData *) BM_HMACWithAlgorithm: (CCHmacAlgorithm) algorithm;
- (NSData *) BM_HMACWithAlgorithm: (CCHmacAlgorithm) algorithm key: (id) key;

@end

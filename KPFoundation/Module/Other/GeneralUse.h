//
//  GeneralUse.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralUse : NSObject

/**
 将NSDictionary或NSArray 转换为 JSON

 @param transData NSDictionary、NSArray 对象
 @param type type=1，表示返回NSString；type=2，表示返回NSData
 @return 返回结果
 */
+ (id)TransformToJson:(id)transData BackType:(NSInteger)type;

/**
 把NSString、nsdata 转化为 NSDictionary或NSArray

 @param jsonData NSString、nsdata 对象
 @return 返回结果
 */
+ (id)TransformToObj:(id)jsonData;

/**
 对 字典化Json 规范化为纯NSString型，用于兼容（不建议使用）

 @param oldJson 就的Json对象
 @return 返回新的Json对象
 */
+ (id)StandardToJson:(id)oldJson;

/**
 检测版本

 @param versionA 版本A
 @param versionB 版本B
 @return 版本A比版本B新，返回YES; 版本A比版本B旧，或相同，返回NO
 */
+ (BOOL)VersionA:(NSString*)versionA GreaterThanVersionB:(NSString*)versionB;

/**
 判断是否包含子字符串

 @param orgStr 原始字符串
 @param subStr 子字符串
 @param isFuzzy NO表示区分大小写，YES表示不区分大小写
 @return 返回结果
 */
+ (BOOL)IsContainString:(NSString *)orgStr SubString:(NSString *)subStr Fuzzy:(BOOL)isFuzzy;



/**
 把int转nsstring，并按照fillZero 10进制位数填充0

 @param numb 要转换的数字
 @param fillZero 值如是10、100、1000、10000等等
 @return 返回转换结果
 */
+ (NSString *)StringFromNSUInteger:(NSInteger)numb FillZero:(NSUInteger)fillZero;

/**
 价格转换

 @param numbStr 价格
 @param fillZero 保留浮点数
 @return 返回带 逗号 的价格值
 */
+ (NSString *)StrmethodComma:(NSString *)numbStr FloatingNumber:(int64_t)fillZero;
+ (NSString *)StrmethodComma:(NSString *)numbStr FloatingNumber:(int64_t)fillZero KeepPoint:(BOOL)isKeep Need45:(BOOL)isNeed45;

+ (NSString *)StrmethodAbbreviation:(NSString *)numbStr FloatingNumber:(int64_t)fillZero;

// 将阿拉伯数字转换位中文大写，允许有两位小数
+ (NSString *)DigitUppercase:(NSString *)money;

@end

#import <KPFoundation/GeneralUse+Compress.h>

#import <KPFoundation/GeneralUse+Time.h>

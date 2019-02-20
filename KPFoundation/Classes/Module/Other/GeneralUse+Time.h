//
//  GeneralUse+Time.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//  时间处理

#import <KPFoundation/GeneralUse.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GeneralUse (Time)


/**
把时间戳 格式化 为 北京时间

@param formatterStr 格式化的格式，默认为：yyyyMMddHHmmss，支持（@"HH"、@"dd"）
@param intTime 时间戳
@return 返回格式化后的数据
*/
+ (NSString *)TimeToNowFormatter:(NSString *)formatterStr Time:(NSTimeInterval)intTime;

/**
 把北京时间 格式化
 
 @param formatterStr 格式化的格式，默认为：yyyyMMddHHmmss，支持（@"HH"、@"dd"）
 @param tStr 要转化的时间
 @return 返回格式化后的数据
 */
+ (NSDate *)TimeWithFormatter:(NSString *)formatterStr TimeString:(NSString *)tStr;

/**
 返回秒级时间戳

 @return 返回nsstring型时间戳
 */
+ (NSString *)TimestampToSecond;

/**
 当前时间与另一个差（秒级）

 @param beTime 要比较的时间
 @return 返回时间（单位秒），返回-1表示无效时间
 */
+ (NSInteger)SecondNowTimeWithTime:(NSInteger)beTime;

/**
 返回天或月的时间戳
 
 @param isDay Yes表示天，否则为月
 @param timeInt 时间戳
 @return 时间
 */
+ (NSDate *)TimeWithMonthDay:(BOOL)isDay TimeDate:(int64_t)timeInt;

/**
 时间戳 转 周几
 
 @param data 时间戳
 @return 返回周几
 */
+ (NSString *)WeekDayFordate:(NSTimeInterval)data;

@end

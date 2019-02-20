//
//  GeneralUse+Time.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "GeneralUse+Time.h"

@implementation GeneralUse (Time)

+ (NSString *)TimeToNowFormatter:(NSString *)formatterStr Time:(NSTimeInterval)intTime {
    if (!formatterStr) {
        formatterStr = @"yyyyMMddHHmmss";
    }
    
    NSDate *dates = [NSDate date];
    if (intTime > 0) {
        dates = [NSDate dateWithTimeIntervalSince1970:intTime];
    }
    
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterStr];     // yyyy-MM-dd HH:mm:ss
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    return [formatter stringFromDate:dates];
}
    
+ (NSDate *)TimeWithFormatter:(NSString *)formatterStr TimeString:(NSString *)tStr {
    if (!formatterStr) {
        formatterStr = @"yyyyMMddHHmmss";
    }
    
    //将字符串转为日期
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/beijing"]];
    //先设置给定的字符串是什么格式的例如yyyyMMddHHmmss
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:formatterStr];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:tStr];
    
    return date;
}

+ (NSString *)TimestampToSecond {
    NSDate *now = [NSDate date];
    
    NSTimeInterval timeNow = [now timeIntervalSince1970];
    NSString *nowStr = [NSString stringWithFormat:@"%lf",timeNow];
    NSRange pointRange = [nowStr rangeOfString:@"."];
    nowStr = [nowStr substringToIndex:pointRange.location];
    
    return nowStr;
}

+ (NSInteger)SecondNowTimeWithTime:(NSInteger)beTime{
    if (beTime < 1) {
        return -1;
    }
    
    NSDate *now;
    now=[NSDate date];
    NSTimeInterval timeNow = [now timeIntervalSince1970];
    
    return fabsl(timeNow - beTime);
}

+ (NSDate *)TimeWithMonthDay:(BOOL)isDay TimeDate:(int64_t)timeInt {
    NSString *formatterStr = nil;
    if (isDay) {
        formatterStr = @"yyyyMMdd";
    }else{
        formatterStr = @"yyyyMM";
    }
    
    NSString *beginTime = [GeneralUse TimeToNowFormatter:formatterStr Time:timeInt];
    NSDate *date = [GeneralUse TimeWithFormatter:formatterStr TimeString:beginTime];
    
    return date;
}

+ (NSString *)WeekDayFordate:(NSTimeInterval)data {
    NSArray *weekday = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:data];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekdayOrdinal fromDate:newDate];
    
    if ((components.weekday - 1) < 7 && (components.weekday - 1) >= 0) {
        return [weekday objectAtIndex:(components.weekday - 1)];
    }
    return @"";
}

@end

//
//  GeneralUse+StrengthPassword.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/5/9.
//  Copyright © 2017年 ZYY. All rights reserved.
//  密码安全提示

#import <KPFoundation/GeneralUse.h>

/**
 密码强度级别枚举，从0(最低)到6(最高)
 */
typedef NS_ENUM(NSInteger, PasswordStrengthLevel) {
    /**
     *  密码为空
     */
    PasswordStrengthLevelVeryFree = 0,
    /**
     *  密码强度 很弱
     */
    PasswordStrengthLevelVeryWeak = 1,
    /**
     *  密码强度 弱
     */
    PasswordStrengthLevelWeak,
    /**
     *  密码强度 一般
     */
    PasswordStrengthLevelAverage,
    /**
     *  密码强度 强
     */
    PasswordStrengthLevelStrong,
    /**
     *  密码强度 很强
     */
    PasswordStrengthLevelVeryStrong,
    /**
     *  密码强度 安全
     */
    PasswordStrengthLevelSecure,
    /**
     *  密码强度 非常安全
     */
    PasswordStrengthLevelVerySecure
};

@interface GeneralUse (StrengthPassword)

/**
 检测密码强度级别
 根据字母大小写、数字、字符串等判断密码复杂度
 @return 强度界别
 */
+ (PasswordStrengthLevel)CheckPasswordStrength:(NSString *)psw;

@end

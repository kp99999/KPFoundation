//
//  GeneralUse+StrengthPassword.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/5/9.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "GeneralUse+StrengthPassword.h"

@implementation GeneralUse (StrengthPassword)

#pragma mark - Public
+ (PasswordStrengthLevel)CheckPasswordStrength:(NSString *)psw{
 
    if (!(psw && [psw length])) {
        return PasswordStrengthLevelVeryFree;
    }
    NSInteger length = [psw length];
    int lowercase = [self countLowercaseLetters:psw];
    int uppercase = [self countUppercaseLetters:psw];
    int numbers = [self countNumbers:psw];
    int symbols = [self countSymbols:psw];
    
    int score = 0;
    
    if (length < 5){
        score += 5;
    }
    else{
        if (length > 4 && length < 8){
            score += 10;
        }
        else{
            if (length > 7)
                score += 20;
        }
    }
    if (numbers == 1){
        score += 10;
    }
    else{
        if (numbers == 2){
            score += 15;
        }
        else{
            if (numbers > 2){
                score += 20;
            }
        }
    }
    if (symbols == 1){
        score += 10;
    }
    else{
        if (symbols == 2){
            score += 15;
        }
        else{
            if (symbols > 2){
                score += 20;
            }
        }
    }
    if (lowercase == 1){
        score += 10;
    }
    else{
        if (lowercase == 2){
            score += 15;
        }
        else{
            if (lowercase > 2){
                score += 20;
            }
        }
    }
    if (uppercase == 1){
        score += 10;
    }
    else{
        if (uppercase == 2){
            score += 15;
        }
        else{
            if (uppercase > 2){
                score += 20;
            }
        }
    }
    if (score == 100){
        return PasswordStrengthLevelVerySecure;
    }
    else{
        if (score >= 90){
            return PasswordStrengthLevelSecure;
        }
        else{
            if (score >= 80){
                return PasswordStrengthLevelVeryStrong;
            }
            else{
                if (score >= 70){
                    return PasswordStrengthLevelStrong;
                }
                else{
                    if (score >= 60){
                        return PasswordStrengthLevelAverage;
                    }
                    else{
                        if (score >= 50){
                            return PasswordStrengthLevelWeak;
                        }
                        else{
                            return PasswordStrengthLevelVeryWeak;
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - Private

//小写字符数
+ (int)countLowercaseLetters:(NSString *)password
{
    int count = 0;
    for (int i = 0; i < [password length]; i++) {
        BOOL isLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[password characterAtIndex:i]];
        if (isLowercase == YES) {
            count++;
        }
    }
    return count;
}

//大写字母数
+ (int)countUppercaseLetters:(NSString *)password
{
    int count = 0;
    for (int i = 0; i < [password length]; i++) {
        BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[password characterAtIndex:i]];
        if (isUppercase == YES) {
            count++;
        }
    }
    return count;
}

//数字个数
+ (int)countNumbers:(NSString *)password
{
    int count = 0;
    for (int i = 0; i < [password length]; i++) {
        BOOL isNumber = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] characterIsMember:[password characterAtIndex:i]];
        if (isNumber == YES) {
            count++;
        }
    }
    return count;
}

//符号个数
+ (int)countSymbols:(NSString *)password
{
    int count = 0;
    for (int i = 0; i < [password length]; i++) {
        BOOL isSymbol = [[NSCharacterSet characterSetWithCharactersInString:@"`~!?@#$€£¥§%^&*()_+-={}[]:\";.,<>'•\\|/"] characterIsMember:[password characterAtIndex:i]];
        if (isSymbol == YES) {
            count++;
        }
    }
    return count;
}

@end

//
//  IMInternationalHelper.m
//  IMComponents
//
//  Created by YuSong.Yan on 16/5/3.
//  Copyright © 2016年 Midea Co., Ltd. All rights reserved.
//

#import "MultiLanguage.h"

#import <objc/runtime.h>

//本地语言类型改变接受的通知
NSString* const MultiLanguageLanguageChangedNotify = @"MultiLanguageLanguageChangedNotify";
//自定义语言缓存Key
NSString* const MultiLanguageLanguageKey = @"MultiLanguageLanguageKey";

/**
 根据语言名称获取语言类型
 @param name 语言名称
 @return 语言类型
 */
static LanguageType languageType(NSString* name)
{
    int i = 0;
    LanguageType type = LanguageTypeUnknown;
    const char* cname = [name UTF8String];
    
    if (!cname) return LanguageTypeUnknown;
    
    while (languageTable[i].type != LanguageTypeUnknown) {
        if (!strcmp(languageTable[i].name, cname)) {
            type = languageTable[i].type;
            break;
        }
        i++;
    }
    return type;
}

/**
 通过语言类型获取语言名称
 @param type 语言类型
 @return 语言名称
 */
static NSString* languageName(LanguageType type)
{
    int i = 0;
    NSString *name = NULL;
    while (languageTable[i].type != LanguageTypeUnknown) {
        if (type == languageTable[i].type) {
            name = [NSString stringWithFormat:@"%s", languageTable[i].name];
        }
        i++;
    }
    return name;
}

@interface BundleEx : NSBundle
@end
@implementation BundleEx
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    return [[MultiLanguage Share] localizedStringForKey:key value:value table:tableName];
}
@end

@interface MultiLanguage(){
    NSString* currentName;
    
    
}

@property(nonatomic,strong) NSBundle* bundle;
@end

@implementation MultiLanguage

+ (NSString *)GetDefAppleLanguages{
    NSString *lg_ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    if (lg_) {
        NSArray *lg_arr = [lg_ componentsSeparatedByString:@"-"];
        if ([lg_arr count] >= 2) {
            lg_ = [NSString stringWithFormat:@"%@-%@" ,lg_arr[0] ,lg_arr[1]];
        }
    }
    return lg_;
}

#pragma mark - life cycle
+ (instancetype)Share
{
    static id once = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        once = [[self alloc] init];
    });
    return once;
}

- (id)init
{
    self  = [super init];
    if (self) {
        object_setClass([NSBundle mainBundle],[BundleEx class]);
        
        currentName = [[NSUserDefaults standardUserDefaults] objectForKey:MultiLanguageLanguageKey];
        if (!currentName) {//第一次使用系统语言
            currentName = [MultiLanguage GetDefAppleLanguages];
            if (languageType(currentName) == LanguageTypeUnknown) {
                currentName = languageName(LanguageTypeSimpleChinese);
                _languageType = LanguageTypeSimpleChinese;
            }else{
                _languageType = languageType(currentName);
            }
            [[NSUserDefaults standardUserDefaults] setObject:currentName forKey:MultiLanguageLanguageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            _languageType = languageType(currentName);
        }
        //设置语言包所在位置
        NSString* path = [[NSBundle mainBundle] pathForResource:currentName ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    }
    return self;
}

#pragma mark - public methods
- (NSString* )localizedStringForKey:(NSString* )key value:(NSString *)value table:(NSString *)tableName
{
    if (_bundle) {
        NSString *str = [_bundle localizedStringForKey:key value:value table:tableName];
        if (str) {
            return str;
        }
    }
    return value;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundle:(NSBundle*)bundle
{
    NSString* path = [bundle pathForResource:currentName ofType:@"lproj"];
    NSBundle *customBundle = [NSBundle bundleWithPath:path];
    return [customBundle localizedStringForKey:key value:value table:tableName];
}

#pragma mark - getters and setters
- (void)setLanguageType:(LanguageType)lType{
    
    if (_languageType != lType) {
        _languageType = lType;
        currentName = languageName(_languageType);
        //设置语言包所在位置
        NSString* path = [[NSBundle mainBundle] pathForResource:currentName ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
        
        //缓存用户设置
        [[NSUserDefaults standardUserDefaults] setObject:currentName forKey:MultiLanguageLanguageKey];
        
        //语言变更广播
        [[NSNotificationCenter defaultCenter] postNotificationName:MultiLanguageLanguageChangedNotify object:nil userInfo:nil];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setTypeName:(NSString *)tName{
    if (!tName) {
        return;
    }
    if ([tName isEqualToString:languageName(LanguageTypeEnglish)]) {
        self.languageType = LanguageTypeEnglish;
    }else if ([tName isEqualToString:languageName(LanguageTypeSimpleChinese)]) {
        self.languageType = LanguageTypeSimpleChinese;
    }else if ([tName isEqualToString:languageName(LanguageTypeTraditionalChinese)]) {
        self.languageType = LanguageTypeTraditionalChinese;
    }else if ([tName isEqualToString:languageName(LanguageTypeIndonesion)]) {
        self.languageType = LanguageTypeIndonesion;
    }
}
    
-(NSString *)typeName
{
    return languageName(_languageType);
}

#pragma mark - private methods

@end

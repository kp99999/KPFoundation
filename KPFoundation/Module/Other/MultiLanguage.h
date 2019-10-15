//
//  MultiLanguageType.h
//  IMComponents
//
//  Created by zyy on 16/5/3.
//  Copyright © 2016年 Midea Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ML(key) \
[[MultiLanguage Share] localizedStringForKey:key value:key table:nil]

/*
 本地语言类型改变接受的通知
 */
extern NSString* const MultiLanguageLanguageChangedNotify;

/**
 语言类型
 */
typedef NS_ENUM(NSInteger,LanguageType)
{
    LanguageTypeUnknown = 0,          //未知
    LanguageTypeEnglish,              //英文
    LanguageTypeSimpleChinese,        //简体中文
    LanguageTypeTraditionalChinese,    //繁体中文
    LanguageTypeIndonesion    // 印尼语
    /* 在这里添加其它语言类型 */
};

/**
 语言表
 *列表所有支持的语言对应的名称，该名称必须与InfoPlist.strings对应；
 简体中文(中国) zh-cn    ***
 繁体中文(台湾地区) zh-tw   ***
 繁体中文(香港) zh-hk
 英语(香港) en-hk
 英语(美国) en-us
 英语(英国) en-gb
 英语(全球) en-ww
 英语(加拿大) en-ca
 英语(澳大利亚) en-au
 英语(爱尔兰) en-ie
 英语(芬兰) en-fi
 芬兰语(芬兰)fi-fi
 英语(丹麦) en-dk
 丹麦语(丹麦) da-dk
 英语(以色列) en-il
 希伯来语(以色列) he-il
 英语(南非) en-za
 英语(印度) en-in
 英语(挪威) en-no
 英语(新加坡) en-sg
 英语(新西兰) en-nz
 英语(印度尼西亚) en-id
 英语(菲律宾) en-ph
 英语(泰国) en-th
 英语(马来西亚) en-my
 英语(阿拉伯) en-xa
 韩文(韩国) ko-kr
 日语(日本) ja-jp ***
 荷兰语(荷兰) nl-nl
 荷兰语(比利时) nl-be
 葡萄牙语(葡萄牙) pt-pt
 葡萄牙语(巴西) pt-br
 法语(法国) fr-fr
 法语(卢森堡) fr-lu
 法语(瑞士) fr-ch
 法语(比利时) fr-be
 法语(加拿大) fr-ca
 西班牙语(拉丁美洲) es-la
 西班牙语(西班牙) es-es
 西班牙语(阿根廷) es-ar
 西班牙语(美国) es-us
 西班牙语(墨西哥) es-mx
 西班牙语(哥伦比亚) es-co
 西班牙语(波多黎各) es-pr
 德语(德国) de-de
 德语(奥地利) de-at
 德语(瑞士) de-ch
 俄语(俄罗斯) ru-ru
 意大利语(意大利) it-it
 希腊语(希腊) el-gr
 挪威语(挪威) no-no
 匈牙利语(匈牙利) hu-hu
 土耳其语(土耳其) tr-tr
 捷克语(捷克共和国) cs-cz
 斯洛文尼亚语 sl-sl
 波兰语(波兰) pl-pl
 瑞典语(瑞典)  sv-se
 西班牙语(智利)  es-cl
 */
static struct LanguageItem {
    LanguageType  type;
    char*           name;   /* 需要与Apple一致 */
} const languageTable[] = {
    {LanguageTypeEnglish, "en"},
    {LanguageTypeSimpleChinese, "zh-Hans"},
    {LanguageTypeTraditionalChinese, "zh-Hant"},
    {LanguageTypeIndonesion, "id"},
    /* 在这里添加其它语言类型 */
    {LanguageTypeUnknown, NULL},
    
};

@interface MultiLanguage : NSObject

+ (instancetype)Share;

+ (NSString *)GetDefAppleLanguages;


/*设置语言类型*/
@property (nonatomic, assign)LanguageType languageType;


/**
 通过 name 来修改类型

 @param tName 对应 LanguageItem.name 的值
 */
- (void)setTypeName:(NSString *)tName;

/**
 语获取语言字段值
 
 @param key         语言字典标识
 @param value       找不到相关key时返回的值
 @param tableName   语言字典文件名，不包含扩展名
 @return 译后值
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

/**
 获取语言字段值
 
 @param key         语言字典标识
 @param value       找不到相关key时返回的值
 @param tableName   语言字典文件名，不包含扩展名
 @param bundle      语言字典所在目录bundle 特别注意：不包含语言类型部分
 @return 译后值
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundle:(NSBundle*)bundle;

/// 获取语言类型
-(NSString *)typeName;
@end

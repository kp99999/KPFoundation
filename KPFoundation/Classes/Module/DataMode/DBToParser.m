//
//  DBToParser.m
//  ZYYObjcLib
//
//  Created by zyyuann on 15/8/11.
//  Copyright © 2015年 ZYY. All rights reserved.
//

#import "DBToParser.h"

#import <objc/runtime.h>

#import <KPFoundation/FileToUse.h>

#import <KPFoundation/GeneralUse.h>

#define FileLibDB       @"LibDatabase.db"         // 默认存储数据库

#pragma mark - DBParserShare
@interface DBParserShare : NSObject{
    
}

+ (DBParserShare *)Share;

@end

@implementation DBParserShare

+ (DBParserShare *)Share{
    static dispatch_once_t once;
    static DBParserShare * singleton;
    dispatch_once(&once, ^{
        singleton = [[DBParserShare alloc] init];
    });
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

// 生成数据库表, 字段
- (NSString *)bulidDBTable:(DBToParser *)dbParser{
    if (!dbParser) {
        return nil;
    }
    
    
    return nil;
}

@end


#pragma mark - DBToParser
@interface DBToParser(){
    
    NSMutableDictionary *parserKeyType;
}

@end

@implementation DBToParser

- (instancetype)init{
    
    return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)i_dic
{
    
    self = [super init];
    if (self) {
        parserKeyType = [[NSMutableDictionary alloc]initWithCapacity:10];
        
        unsigned int outCount, i;
        
        objc_property_t *properties = class_copyPropertyList([self parserClass], &outCount);
        
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            
            NSString *nameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            if (nameString && propertyType) {
                [parserKeyType setValue:propertyType forKey:nameString];
            }
        }
        
        properties = class_copyPropertyList([DBToParser class], &outCount);
        
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            
            NSString *nameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            if (nameString && propertyType) {
                [parserKeyType setValue:propertyType forKey:nameString];
            }
        }
        
        [self refreshWithDictionary:i_dic];
    }
    return self;
}

- (id)getValueWithKey:(NSString *)pKey{
    if (!pKey) {
        return nil;
    }
    
    SEL selector = NSSelectorFromString(pKey);
    IMP imp = [self methodForSelector:selector];
    
    id value = nil;
    NSString *propertyType = parserKeyType[pKey];
    if ([propertyType rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
        id (*func)(id, SEL) = (void *)imp;
        value = func(self, selector);
    }else if ([propertyType hasPrefix:@"Tq"] || [propertyType hasPrefix:@"Ti"] || [propertyType hasPrefix:@"Tl"] || [propertyType hasPrefix:@"Ts"])
    {
        NSInteger (*func)(id, SEL) = (void *)imp;
        value = @(func(self, selector));
    }
    else if ([propertyType hasPrefix:@"TF"] || [propertyType hasPrefix:@"Td"])
    {
        CGFloat (*func)(id, SEL) = (void *)imp;
        value = @(func(self, selector));
    }
    
    return value;
}

//////////////////////////////////////////////////////////////
- (void)refreshWithDictionary:(NSDictionary *)i_dic{
    NSArray *keys = [parserKeyType allKeys];
    for (NSInteger i = 0; keys && i < [keys count]; i++) {
        id setValue = nil;
        
        if (i_dic) {
            setValue = [i_dic objectForKey:keys[i]];
        }
        
        // 获取类变量 value
        
        NSString *oneKey = [[[keys[i] substringToIndex:1] uppercaseString] stringByAppendingString:[keys[i] substringFromIndex:1]];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:",oneKey]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        
        
        NSString *propertyType = parserKeyType[keys[i]];
        if ([propertyType rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
            if (setValue && [setValue isKindOfClass:[NSString class]]) {
                ;
            }else if (setValue && [setValue isKindOfClass:[NSNumber class]]){
                setValue = [NSString stringWithFormat:@"%@",setValue];
            }else if (setValue && ([setValue isKindOfClass:[NSArray class]] || [setValue isKindOfClass:[NSDictionary class]])){
                setValue = [GeneralUse TransformToJson:setValue BackType:1];
                if (!setValue) {
                    setValue = @"";
                }
            }else{
                setValue = @"";
            }
            
            func(self, selector, setValue);
        }else if ([propertyType hasPrefix:@"Tq"] || [propertyType hasPrefix:@"Ti"] || [propertyType hasPrefix:@"Tl"] || [propertyType hasPrefix:@"Ts"])
        {
            NSInteger ii = 0;
            if (setValue && [setValue isKindOfClass:[NSString class]]) {
                ii = ((NSString *)setValue).integerValue;
            }else if (setValue && [setValue isKindOfClass:[NSNumber class]]){
                ii = ((NSNumber *)setValue).integerValue;
            }
            void (*fun_o)(id, SEL, NSInteger) = (void *)imp;
            fun_o(self, selector, ii);
        }
        else if ([propertyType hasPrefix:@"TF"])
        {
            float ff = 0;
            if (setValue && [setValue isKindOfClass:[NSString class]]) {
                ff = ((NSString *)setValue).floatValue;
            }else if (setValue && [setValue isKindOfClass:[NSNumber class]]){
                ff = ((NSNumber *)setValue).floatValue;
            }
            void (*fun_o)(id, SEL, NSInteger) = (void *)imp;
            fun_o(self, selector, ff);
        }
        else if([propertyType hasPrefix:@"Td"]) {
            double dd = 0;
            if (setValue && [setValue isKindOfClass:[NSString class]]) {
                dd = ((NSString *)setValue).doubleValue;
            }else if (setValue && [setValue isKindOfClass:[NSNumber class]]){
                dd = ((NSNumber *)setValue).doubleValue;
            }
            void (*fun_o)(id, SEL, NSInteger) = (void *)imp;
            fun_o(self, selector, dd);
        }
//        else if ([propertyType hasPrefix:@"Tc"]) {
//            [protypes addObject:@"char"];
//        }
//        else if()
//        {
//            [protypes addObject:@"short"];
//        }
        else{
            NSAssert(NO , @"数据库只支持NSString类型");
        }
    }
}

- (NSArray *)parserKeys{
    return [parserKeyType allKeys];
}

- (NSDictionary *)parserToDictionary{
    NSMutableDictionary *parserDic = [[NSMutableDictionary alloc]initWithCapacity:10];
    NSArray *keys = [parserKeyType allKeys];
    for (NSInteger i = 0; keys && i < [keys count]; i++) {
        
        id value = [self getValueWithKey:keys[i]];
        if (value) {
            [parserDic setValue:value forKey:keys[i]];
        }
    }
    return [parserDic copy];
}

- (NSString *)getAttributesTypeWithKey:(NSString *)key{
    if (!key) {
        nil;
    }
    NSString *propertyType = parserKeyType[key];
    if ([propertyType rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
        if ([self isSetPrimaryKey] && [key isEqualToString:@"main_key"]) {
            return @"TEXT PRIMARY KEY";
        }
        return @"TEXT";
    }else if ([propertyType hasPrefix:@"Tq"] || [propertyType hasPrefix:@"Ti"] || [propertyType hasPrefix:@"Tl"] || [propertyType hasPrefix:@"Ts"])
    {
        return @"INTEGER";
    }
    else if ([propertyType hasPrefix:@"TF"] || [propertyType hasPrefix:@"Td"])
    {
        return @"REAL";
    }
    else{
        return nil;
    }
}

- (NSString *)parserNameWithInstance:(id)instance
{
    NSArray *keys = [parserKeyType allKeys];
    for (NSInteger i = 0; keys && i < [keys count]; i++) {
        id value = [self getValueWithKey:keys[i]];
        if (value && [value isEqual:instance]) {
            return keys[i];
        }
    }
    return @"";
}

- (BOOL)isAutoMainKey{
    if (self.main_key && [self.main_key length] > 0) {
        return NO;
    }
    
    return YES;
}

- (NSString *)parserClassString{
    return NSStringFromClass([self parserClass]);
}
#pragma mark - 外部实现类
- (NSString *)getDBName{
    return FileLibDB;
}
- (Class)parserClass{
    return [DBToParser class];
}
- (NSString *)getSqlList{
    return nil;
}
- (BOOL)isSetPrimaryKey{
    return NO;
}

@end

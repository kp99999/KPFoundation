//
//  JsonToParser.m
//  ZYYObjcLib
//
//  Created by zyyuann on 16/1/16.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import "JsonToParser.h"

#import <objc/runtime.h>

#import "GeneralUse.h"
#import "CheckNetwork.h"

@interface JsonToParser() {
    
}

@end

@implementation JsonToParser

- (instancetype)init {
    
    _isNetWork = YES;
    _isOpenNetWork = YES;
    _isTimeOut = NO;
    
    return [self initWithJsonData:nil Error:nil];
}

- (instancetype)initWithJsonData:(id)data Error:(NSError *)err {
    self = [super init];
    if (self) {
        id jsonData;
        _error = err;
        if (!data) {
            _otherMess = @"解析数据为空";
            if (!_error) {
                _error = [NSError errorWithDomain:@"未知错误" code:NSURLErrorUnknown userInfo:nil];
            }
            if (_error.code == NSURLErrorNotConnectedToInternet) {
                // 判断是否有网络
                _isNetWork = NO;
            } else if (_error.code == NSURLErrorTimedOut) {
                _isTimeOut = YES;
            } else if (_error.code == NSURLErrorNotConnectedToInternet) {
                // 可能限制了网络
                _isOpenNetWork = NO;
            }
            
        } else {
            jsonData = [GeneralUse TransformToObj:data];
            if (!jsonData) {
                jsonData = data;
            }
            
            if ([self isMemberOfClass:[JsonToParser class]]) {
                _otherMess = data;
                _error = [NSError errorWithDomain:@"对纯JsonToParser 不解析" code:-2 userInfo:nil];
            } else {
                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                    _otherMess = jsonData;
                    
                    [self parserFromDictionary:jsonData];
                    
                } else if ([jsonData isKindOfClass:[NSArray class]] || [jsonData isKindOfClass:[NSString class]]) {
                    // 不解析
                    _otherMess = jsonData;
                } else {
                    _otherMess = @"无法进行json解析";
                    _error = [NSError errorWithDomain:@"无法进行json解析" code:-3 userInfo:nil];
                }
            }
        }
    }
    
    return self;
}

// mode 解析
- (void)parserFromDictionary:(NSDictionary *)dic {
    if (!dic) {
        return;
    }
    
    NSMutableDictionary *parserKeyType = [[NSMutableDictionary alloc]initWithCapacity:20];
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *nameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if (nameString && propertyType) {
            [parserKeyType setValue:propertyType forKey:nameString];
        }
    }
    
    if ([parserKeyType count] > 0) {
        [self setWithDictionary:dic ParserKeyType:[parserKeyType copy]];
        [parserKeyType removeAllObjects];
        parserKeyType = nil;
    }
}
// mode 赋值
- (void)setWithDictionary:(NSDictionary *)i_dic ParserKeyType:(NSDictionary *)parserKeyType {
    if (!(i_dic && parserKeyType)) {
        return;
    }
    NSArray *keys = [parserKeyType allKeys];
    for (NSInteger i = 0; keys && i < [keys count]; i++) {
        
        NSString *oneKey = [[[keys[i] substringToIndex:1] uppercaseString] stringByAppendingString:[keys[i] substringFromIndex:1]];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:",oneKey]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        
        id setValue = [self getValueFromDic:i_dic Key:keys[i]];
        
        if (setValue) {
            NSString *propertyType = parserKeyType[keys[i]];
            
            if (setValue && [setValue isKindOfClass:[NSString class]]) {
                if ([propertyType rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
                    func(self, selector, setValue);
                }
            } else if (setValue && [setValue isKindOfClass:[NSNumber class]]) {
                if ([propertyType rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
                    setValue = [NSString stringWithFormat:@"%@",setValue];
                    func(self, selector, setValue);
                }
            } else if([setValue isKindOfClass:[NSDictionary class]]) {
                Class OneClass = [self parserClass:keys[i]];
                if (OneClass && [OneClass isSubclassOfClass:[JsonToParser class]]) {
                    JsonToParser *onePaeser = [[OneClass alloc] initWithJsonData:setValue Error:nil];
                    if (onePaeser) {
                        func(self, selector, onePaeser);
                    } else {
                        func(self, selector, nil);
                    }
                } else if (OneClass && OneClass == [NSDictionary class]) {
                    func(self, selector, setValue);
                } else {
                    func(self, selector, nil);
                }
                
                
            } else if (setValue && [setValue isKindOfClass:[NSArray class]]) {
                if ([propertyType rangeOfString:@"T@\"NSArray\""].location != NSNotFound) {
                    NSMutableArray *arrData = [[NSMutableArray alloc] initWithCapacity:[setValue count]];
                    Class OneClass = [self parserClass:keys[i]];
                    if (OneClass) {
                        for (NSInteger x = 0; x < [setValue count]; x++) {
                            JsonToParser *oneParser = [[OneClass alloc] initWithJsonData:setValue[x] Error:nil];
                            if (oneParser) {
                                [arrData addObject:oneParser];
                            }
                        }
                    }
                    
                    if ([arrData count] > 0) {
                        func(self, selector, [arrData copy]);
                        [arrData removeAllObjects];
                        arrData = nil;
                    } else {
                        func(self, selector, setValue);
                    }
                }
            } else {
                func(self, selector, nil);
            }
        } else {
            func(self, selector, nil);
        }
    }
}
// 字符转换，并返回值
- (id)getValueFromDic:(NSDictionary *)dic Key:(NSString *)oneKey {
    if (!oneKey) {
        return nil;
    }
    id value = [dic objectForKey:oneKey];
    
    // 特殊处理：'-'变量
    if (!value) {
        oneKey = [oneKey stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
        value = [dic objectForKey:oneKey];
    }
    // 特殊处理：最后字符为'_'的变量
    if (!value) {
        if ([oneKey length] > 1 && [[oneKey substringFromIndex:[oneKey length] - 2] isEqualToString:@"_"]) {
            value = [dic objectForKey:[oneKey substringToIndex:[oneKey length] - 2]];
        }
    }
    
    return value;
}

#pragma mark - 外部实现类
- (Class)parserClass:(NSString *)key {
    return [JsonToParser class];
}

@end

//
//  ShareTable.m
//  ZYYObjcLib
//
//  Created by zyyuann on 15/4/18.
//  Copyright © 2015年 ZYY. All rights reserved.
//

#import "ShareTable.h"

#import <KPFoundation/FileUse.h>

#define MainKey_Extend   @"to_out_"

@implementation ShareTable

- (Class)parserClass{
    return [ShareTable class];
}
- (BOOL)isSetPrimaryKey{
    return YES;
}
- (NSString *)getSqlList{
    
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", [self parserClassString], [self parserNameWithInstance:self.main_key],self.main_key];
}

//
- (void)updateModeData:(void(^)(BOOL isSec))finish{
    [self refreshWithDictionary:[ShareTable AddMainKeyExtend:[self parserToDictionary] Key:[self parserNameWithInstance:self.main_key]]];
    
    [[FileUse Share] updateModeData:self];
}

- (void)resultComMainKey:(void(^)(NSArray *arr))finish{
    if (!finish) {
        return;
    }
    [self refreshWithDictionary:[ShareTable AddMainKeyExtend:[self parserToDictionary] Key:[self parserNameWithInstance:self.main_key]]];
    
    id data = [[FileUse Share] resultModeData:self];
    if (data && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *n_arr = [[NSMutableArray alloc]initWithCapacity:[data count]];
        for (id objDic in data) {
            if ([objDic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = [ShareTable DelMainKeyExtend:objDic Key:[self parserNameWithInstance:self.main_key]];
                if (dic) {
                    [n_arr addObject:dic];
                }
            }
        }
        if ([n_arr count] > 0) {
            finish([n_arr copy]);
            [n_arr removeAllObjects];
            n_arr = nil;
        }else{
            finish(nil);
        }
    }else{
        finish(nil);
    }

}

+ (NSDictionary *)AddMainKeyExtend:(NSDictionary *)dic Key:(NSString *)keyName{
    if (!(dic && keyName)) {
        return nil;
    }
    
    NSString *name = [dic objectForKey:keyName];
    if (name) {
        if ([name rangeOfString:MainKey_Extend].location == NSNotFound) {
            return dic;
        }
    }
    
    NSMutableDictionary *m_dic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [m_dic setObject:[MainKey_Extend stringByAppendingString:m_dic[keyName]] forKey:keyName];
    return [m_dic copy];
}
+ (NSDictionary *)DelMainKeyExtend:(NSDictionary *)dic Key:(NSString *)keyName{
    if (!(dic && keyName)) {
        return nil;
    }
    
    NSString *name = [dic objectForKey:keyName];
    if (name) {
        if ([name rangeOfString:MainKey_Extend].location == NSNotFound) {
            return dic;
        }
    }
    
    NSMutableDictionary *m_dic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    NSString *main_key_str = [m_dic objectForKey:keyName];
    if (main_key_str && [main_key_str length] > [MainKey_Extend length]) {
        main_key_str = [main_key_str substringFromIndex:[MainKey_Extend length]];
        [m_dic setValue:main_key_str forKey:keyName];
    }
    return [m_dic copy];
}

@end

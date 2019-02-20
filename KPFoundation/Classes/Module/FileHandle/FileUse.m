//
//  FileUse.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/20.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "FileUse.h"

static bool isInit = NO;     // 单例初始化判断（该类不允许被继承，初始化多个）

@implementation FileUse

+ (FileUse *)Share{
    
    static dispatch_once_t onceFileToUse;
    static FileUse * singletonFileToUse;
    dispatch_once(&onceFileToUse, ^{
        isInit = YES;
        singletonFileToUse = [[FileUse alloc] init];
    });
    return singletonFileToUse;
}

- (id)init
{
    if (!isInit) {
        NSAssert(isInit , @"该类不允许被继承，初始化多个");
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        [self initFileUseFMDBAuthority];
        
        [self initFileUseManager];
        
    }
    
    return self;
}

@end

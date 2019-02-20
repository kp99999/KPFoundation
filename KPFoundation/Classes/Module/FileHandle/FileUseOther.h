//
//  FileUse+Other.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/22.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FCJsonLocal(key) \
[FileUseOther GetAsynchronousJsonLocal:key BundleResource:@"ZYYLibBundle"]

#define FCFileLocal(key) \
[FileUseOther GetFileLocal:key BundleResource:@"ZYYLibBundle"]

@interface FileUseOther : NSObject

+ (BOOL)OperatingIsInFile:(NSString *)fileStr;

+ (NSString *)OperatingRouteFile:(NSString *)fileStr;       // 获取文件路径
+ (BOOL)WriteData:(NSData *)theData FileName:(NSString *)fileName;          // 会遍历创建文件夹

+ (NSData *)GetFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName;
+ (id)GetAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName;

@end

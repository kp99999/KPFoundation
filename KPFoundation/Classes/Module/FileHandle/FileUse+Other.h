//
//  FileUse+Other.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/22.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/FileUse.h>

//#define FCJsonLocal(key) \
//[[FileUse Share] getAsynchronousJsonLocal:key BundleResource:@"ZYYLibBundle"]
//
//#define FCFileLocal(key) \
//[[FileUse Share] getFileLocal:key BundleResource:@"ZYYLibBundle"]

@interface FileUse (Other)

// zip 解压
+ (NSData *)ZipUnpackFile:(NSString *)fileStr EndDel:(BOOL)isDel Authority:(id)authStr;

/**
 获取本地 资源文件
 
 @param fileName 文件名
 @param bunleName 从属Bundle
 @return 返回数据
 */
- (NSData *)getFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName;
- (id)getAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName;      // 在 GetFileLocal 附近对象化

@end

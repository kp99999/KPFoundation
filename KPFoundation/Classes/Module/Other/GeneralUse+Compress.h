//
//  GeneralUse+Compress.h
//  Pods
//
//  Created by zhang yyuan on 2017/9/8.
//
//  压缩、解压

#import <KPFoundation/GeneralUse.h>

@interface GeneralUse (Compress)

+ (NSData *)GzipInflate:(NSData*)data;
+ (NSData *)GzipDeflate:(NSData*)data;

+ (NSData *)ZlibInflate:(NSData *)data;
+ (NSData *)ZlibDeflate:(NSData *)data;

@end

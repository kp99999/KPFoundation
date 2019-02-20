//
//  FileUse+Other.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/22.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "FileUseOther.h"

#import "GeneralUse.h"

@implementation FileUseOther

#pragma mark - 本地资源文件处理

/**
 文件是否存在
 
 @param fileStr 带路径文件名
 @return 是否存在
 */
+ (BOOL)OperatingIsInFile:(NSString *)fileStr{
    if (fileStr) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
        if ([fileManager fileExistsAtPath:fileStr]){
            
            return YES;
        }
        
    }
    
    return NO;
}

+ (BOOL)WriteData:(NSData *)theData FileName:(NSString *)fileName {
    if (!fileName) {
        return NO;
    }
    NSArray *fileArr = [fileName componentsSeparatedByString:@"/"];
    NSString *folderStr = nil;
    for (NSInteger i = 0; fileArr && i < ([fileArr count] - 1) ; i++) {
        if (folderStr) {
            folderStr = [folderStr stringByAppendingFormat:@"/%@" ,fileArr[i]];
        } else {
            folderStr = [self OperatingRouteFile:fileArr[i]];
        }
        
        NSError *err = nil;
        BOOL isDir = NO;
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:folderStr isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
            [[NSFileManager defaultManager] createDirectoryAtPath:folderStr withIntermediateDirectories:YES attributes:nil error:&err];
        
        if (err)
            return NO;
    }
    
    NSString *fileStr = [self OperatingRouteFile:fileName];
    
    return [[NSFileManager defaultManager] createFileAtPath:fileStr contents:theData attributes:nil];
}

+ (NSString *)OperatingRouteFile:(NSString *)fileStr{
    
    if (fileStr) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return [documentsDirectory stringByAppendingPathComponent:fileStr];
    }
    
    return nil;
}

// 获取本地 资源文件
+ (NSData *)GetFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName {
    if (!fileName) {
        return nil;
    }
    
    NSBundle *bkBundle = [NSBundle mainBundle];
    NSString *localPath = nil;
    if (bunleName) {
        bkBundle = [NSBundle bundleWithPath:[bkBundle pathForResource:bunleName ofType:@"bundle"]];
    }
    
    NSArray *interArr = [fileName componentsSeparatedByString:@"."];
    if ([interArr count] == 2) {
        localPath=[bkBundle pathForResource:[interArr objectAtIndex:0] ofType:[interArr objectAtIndex:1]];
    }else if ([interArr count] == 1){
        localPath=[bkBundle pathForResource:[interArr objectAtIndex:0] ofType:nil];
    }
    
    NSData *content = [NSData dataWithContentsOfFile:localPath];
    
    return content;
}
// 获取本地 json 资源文件
+ (id)GetAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName {
    NSData *content = [self GetFileLocal:interfaceName BundleResource:bunleName];
    return [GeneralUse TransformToObj:content];
    
}

@end

//
//  FileUse+Other.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/22.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "FileUse+Other.h"

#import "GeneralUse.h"

@implementation FileUse (Other)

#pragma mark - 本地资源文件处理
// 获取本地 资源文件
- (NSData *)getFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName{
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
- (id)getAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName{
    NSData *content = [self getFileLocal:interfaceName BundleResource:bunleName];
    return [GeneralUse TransformToObj:content];
    
}

@end

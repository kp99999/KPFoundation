//
//  FileUse+Manager.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/21.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "FileUse+Manager.h"

#import "ShareTable.h"
#import "GeneralUse.h"


#define FolderLibDB     @"LibDataBase"      // sdk数据库文件夹

NSString *const FolderName_UnClean_UserFile = @"user_file";
NSString *const FolderName_UnClean_ImportantFile = @"image_important";
NSString *const FolderName_Clean7_TemporaryFile = @"temporary_file";
NSString *const FolderName_Clean30_ResourceFile = @"image_resource";

@implementation FileUse (Manager)

/**
 文件是否存在

 @param fileStr 带路径文件名
 @return 是否存在
 */
- (BOOL)operatingIsInFile:(NSString *)fileStr{
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

/**
 获取文件所在路径
 
 @param fileStr 文件名（可以带文件夹，格式：文件夹/文件名）
 @param authority 认证
 @return 返回路径
 */
- (NSString *)operatingRouteFile:(NSString *)fileStr{
    
    if (fileStr) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return [documentsDirectory stringByAppendingPathComponent:fileStr];
    }
    
    return nil;
}

/**
 创建文件夹
 
 @param folderName 文件夹名称
 @param authority 认证
 @return 是否创建成功（已存在文件夹，直接返回成功）
 */
- (BOOL)createFolder:(NSString *)folderName{
    
    NSString *folderStr = [self operatingRouteFile:folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *err = nil;
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:folderStr isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
        [fileManager createDirectoryAtPath:folderStr withIntermediateDirectories:YES attributes:nil error:&err];
    
    if (err)
        return NO;
    
    NSLog(@"folderStr = %@",folderStr);
    
    return YES;
}

/**
 文件夹删除
 
 @param folderName 文件 或 文件夹 名
 */
- (void)deleteFile:(NSString *)name{
    if (name) {
        NSString *folderStr = [self operatingRouteFile:name];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:folderStr error:nil];
    }
}

/**
 读文件
 
 @param fileStr 文件名（可以带文件夹，格式：文件夹/文件名）
 @param type 1：表示返回 NSData， 2:表示返回 NSString
 @return 返回对象
 */
- (id)operatingReadFile:(NSString *)fileStr Type:(NSInteger)type{
    if ([self operatingIsInFile:fileStr]) {
        NSError *err = nil;
        id data = nil;
        
        if (type == 1) {
            data = [NSData dataWithContentsOfFile:[self operatingRouteFile:fileStr] options:NSDataReadingMappedIfSafe error:&err];
        }else if (type == 2){
            data =  [NSString stringWithContentsOfFile:[self operatingRouteFile:fileStr] encoding:NSUTF8StringEncoding error:&err];
        }
        
        if (err)
            return nil;
        else
            return data;
    }
    
    return nil;
}

/**
 写文件(若存在，则删旧文件)
 
 @param fileStr 文件名（可以带文件夹，格式：文件夹/文件名）
 @param theData 存储数据
 @return 返回是否成功
 */
- (BOOL)operatingWriteFile:(NSString *)fileStr NeedData:(NSData *)theData{
    if ([self operatingIsInFile:fileStr]) {
        [self deleteFile:fileStr];
    }
    
    fileStr = [self operatingRouteFile:fileStr];
    
    return [[NSFileManager defaultManager] createFileAtPath:fileStr contents:theData attributes:nil];
}

/**
 移动文件 或 重命名
 
 @param newPath 新名称 (可以带文件夹，格式：文件夹/文件名）
 @param oldPath 旧名称 (可以带文件夹，格式：文件夹/文件名）
 @return 返回是否成功
 */
- (BOOL)operatingRenameFilePath:(NSString *)newPath OldFilePath:(NSString *)oldPath{
    if (!(newPath && oldPath)) {
        return NO;
    }
    
    NSString *fullNewPath = [self operatingRouteFile:newPath];
    NSString *fullOldPath = [self operatingRouteFile:oldPath];
    
    return [[NSFileManager defaultManager] moveItemAtPath:fullOldPath toPath:fullNewPath error:nil];
}

/**
 获取文件头信息
 
 @param fileStr 文件名（可以带文件夹，格式：文件夹/文件名）
 @return 返回结果
 */
- (id)operatingFileAttributes:(NSString *)fileStr{
    if (fileStr) {
        fileStr = [self operatingRouteFile:fileStr];
        
        return [[NSFileManager defaultManager] attributesOfItemAtPath:fileStr error:NULL];
    }
    
    return nil;
}

// 判断是否要清空缓存
- (void)judgeToDelFolder:(NSString *)folder Day:(NSString *)days{
    if (!(folder && days)) {
        return;
    }
    
    ShareTable *commontTable = [[ShareTable alloc]init];
    commontTable.main_key = folder;
    NSArray *nowData = [self resultModeData:commontTable];
    
    BOOL isUpdata = NO;
    if (nowData && [nowData count] == 1) {
        [commontTable refreshWithDictionary:nowData[0]];
        NSInteger time = [GeneralUse SecondNowTimeWithTime:commontTable.time];
        if (time > days.integerValue * 24 * 3600) {
            [self deleteFile:folder];
            if ([self createFolder:folder]) {
                isUpdata = YES;
            }
        }
    }else{
        isUpdata = YES;
    }
    
    if (isUpdata) {
        commontTable.time = [GeneralUse TimestampToSecond].integerValue;
        [self updateModeData:commontTable];
    }
}

#pragma mark - 外部调用

- (void)initFileUseManager{
    
    if (fileConfig) {
        return;
    }
    
    BOOL isSecc = [self createFolder:FolderLibDB];
    NSAssert(isSecc , @"FolderLibDB 文件夹创建失败");
    
    id infoData = [self getAsynchronousJsonLocal:@"FolderSetting.json" BundleResource:@"ZYYLibBundle"];
    if (infoData && [infoData isKindOfClass:[NSDictionary class]]) {
        fileConfig = [infoData copy];
    }else{
        NSAssert(NO , @"FolderSetting 配置文件有错误");
        return;
    }
    
    // 创建必要的文件夹，并对文件夹进行管理
    NSArray *keyArr = [fileConfig allKeys];
    for (NSString *str in keyArr) {
        BOOL isSecc = [self createFolder:str];
        NSAssert(isSecc , @"FolderSetting 文件夹创建失败");
        if (isSecc) {
            NSDictionary *oneConfig = [fileConfig objectForKey:str];
            if ([[oneConfig objectForKey:@"unClean"] isEqualToString:@"0"]) {
                [self judgeToDelFolder:str Day:[oneConfig objectForKey:@"cleanDay"]];
            }
        }
    }
}

- (NSString *)getRouteFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!folderName) {
        return nil;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig && ![folderName isEqualToString:FolderLibDB]) {
        return nil;
    }
    
    NSString *fullName = folderName;
    if (fileName) {
        fullName = [NSString stringWithFormat:@"%@/%@",folderName,fileName];
    }
    
    return [self operatingRouteFile:fullName];
}

- (id)readFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return nil;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return nil;
    }
    
    return [self operatingReadFile:[NSString stringWithFormat:@"%@/%@",folderName,fileName] Type:1];
}

- (BOOL)writeData:(NSData *)theData FolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return NO;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return NO;
    }
    
    if (theData) {
        return [self operatingWriteFile:[NSString stringWithFormat:@"%@/%@",folderName,fileName] NeedData:theData];
    }
    
    return NO;
}

- (void)deleteFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    
    if (folderName && fileName) {
        [self deleteFile:[NSString stringWithFormat:@"%@/%@",folderName, fileName]];
    }else if (folderName){
        [self judgeToDelFolder:folderName Day:@"0"];;
    }
}

- (BOOL)renameFolderName:(NSString *)folderName OldFileName:(NSString *)oldName NewFileName:(NSString *)newName{
    if (!folderName) {
        return NO;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return NO;
    }
    
    if (!(oldName && newName)) {
        return NO;
    }
    
    NSString *pOldName = [NSString stringWithFormat:@"%@/%@",folderName,oldName];
    NSString *pNewName = [NSString stringWithFormat:@"%@/%@",folderName,newName];
    
    return [self operatingRenameFilePath:pNewName OldFilePath:pOldName];
}

- (NSInteger)getFileSizeWithFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!folderName) {
        return -1;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return -1;
    }
    
    NSString *fullName = folderName;
    if (fileName) {
        fullName = [NSString stringWithFormat:@"%@/%@",folderName,fileName];
    }
    
    id dic = [self operatingFileAttributes:fullName];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSNumber *contentLength = dic[NSFileSize];
        if (contentLength) {
            return contentLength.integerValue;
        }
    }
    
    return -1;
}

@end

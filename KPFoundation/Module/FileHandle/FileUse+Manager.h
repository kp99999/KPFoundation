//
//  FileUse+Manager.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/21.
//  Copyright © 2017年 ZYY. All rights reserved.
//  不需要考虑多线程安全，苹果已经考虑

#import <KPFoundation/FileUse.h>

extern NSString *const FolderName_UnClean_UserFile;             // 永久不清除
extern NSString *const FolderName_UnClean_ImportantFile;        // 永久不清除
extern NSString *const FolderName_Clean7_TemporaryFile;         // 7天自动清除
extern NSString *const FolderName_Clean30_ResourceFile;         // 30天自动清除

@interface FileUse(){
    /*  文件配置
     key: 文件夹名称
     value: 文件夹配置参数
     */
    NSDictionary *fileConfig;
}

@end

@interface FileUse (Manager)

- (void)initFileUseManager;

/**
 读文件

 @param folderName 文件夹名
 @param fileName 文件名
 @return 返回NSData
 */
- (id)readFolderName:(NSString *)folderName FileName:(NSString *)fileName;

/**
 写文件

 @param theData 文件数据
 @param folderName 文件夹名
 @param fileName 文件名
 @return 是否成功
 */
- (BOOL)writeData:(NSData *)theData FolderName:(NSString *)folderName FileName:(NSString *)fileName;

/**
 文件删除

 @param folderName 文件夹名
 @param fileName 文件名(fileName = nil,删除文件夹)
 */
- (void)deleteFolderName:(NSString *)folderName FileName:(NSString *)fileName;

/**
 获取文件路径

 @param folderName 文件夹名
 @param fileName 文件名 （fileName = nil,获取文件夹路径）
 @return 路径
 */
- (NSString *)getRouteFolderName:(NSString *)folderName FileName:(NSString *)fileName;

/**
 重命名

 @param folderName 文件夹名
 @param oldName 就文件名
 @param newName 新文件名
 @return 是否成功
 */
- (BOOL)renameFolderName:(NSString *)folderName OldFileName:(NSString *)oldName NewFileName:(NSString *)newName;

/**
 获取文件大小

 @param folderName 文件夹名
 @param fileName 文件名
 @return 大小
 */
- (NSInteger)getFileSizeWithFolderName:(NSString *)folderName FileName:(NSString *)fileName;

@end

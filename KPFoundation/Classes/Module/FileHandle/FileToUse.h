//
//  FileToUse.h
//  ZYYObjcLib
//
//  Created by zyyuann on 16/1/12.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FileFinish)(BOOL isSec ,id data);     // 网络返回

@interface FileToUse : NSObject

+ (FileToUse *)Share;

// 判断文件是否存在
- (BOOL)isInFolderName:(NSString *)folderName FileName:(NSString *)fileName;
// 文件 读写 操作
- (id)readFolderName:(NSString *)folderName FileName:(NSString *)fileName;      // 文件名自动md5，返回NSData
- (BOOL)writeData:(NSData *)theData FolderName:(NSString *)folderName FileName:(NSString *)fileName;    // 文件名自动md5
- (BOOL)writeData:(NSData *)theData FolderName:(NSString *)folderName SourceName:(NSString *)fileName;
- (void)deleteFolderName:(NSString *)folderName FileName:(NSString *)fileName;        // 删除文件(fileName = nil,删除文件夹)
- (NSString *)getRouteFolderName:(NSString *)folderName FileName:(NSString *)fileName;      // 获取文件(fileName = nil,获取文件夹路径)
- (BOOL)renameFolderName:(NSString *)folderName OldFileName:(NSString *)oldName NewFileName:(NSString *)newName;      // 重命名
- (NSInteger)getFileSizeWithFolderName:(NSString *)folderName FileName:(NSString *)fileName;    // 获取文件大小

// zip 解压
- (NSData *)zipUnpackFolderName:(NSString *)folderName FileName:(NSString *)fileName;

// Bundle Resource 读写 操作
// 获取本地 资源文件
- (NSData *)getFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName;
// 获取本地 json 资源文件
- (id)getAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName;
// 获取本地 图片
- (id)getImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName;

// 获取plist文件
- (NSDictionary *)getPlistName:(NSString *)name;


// mode sql数据库 操作
- (void)updateModeData:(id)dataMode Finish:(FileFinish)fileFinish;
- (void)resultModeData:(id)dataMode Finish:(FileFinish)fileFinish;
- (void)resultModeNumb:(id)dataMode Finish:(FileFinish)fileFinish;      // 获取查询条数
- (void)deleteTableMode:(id)dataMode Finish:(FileFinish)fileFinish;
- (BOOL)upToTableName:(NSString *)name ListNumb:(NSUInteger)nowNumb AddItem:(NSArray *)item;    // 更新表结构

// 事务处理 type=1 插入,   type=2 修改
- (void)transactionData:(NSArray *)dArr Type:(NSInteger)type Finish:(FileFinish)fileFinish;
- (void)transactionData:(NSArray *)dArr Key:(NSString *)key TableName:(NSString *)tName Type:(NSInteger)type Finish:(FileFinish)fileFinish;

@end

//
//  FileToControll.h
//  testCCBMonitor
//
//  Created by zyy_pro on 14-10-22.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileToControll : NSObject

// 本地文件存储
+ (BOOL)CreateFolder:(NSString *)folderName Authority:(id)authStr;
+ (void)DeleteFolder:(NSString *)folderName Authority:(id)authStr;

+ (BOOL)OperatingIsInFile:(NSString *)fileStr Authority:(id)authStr;
+ (id)OperatingReadFile:(NSString *)fileStr Type:(NSInteger)type Authority:(id)authStr;
+ (BOOL)OperatingWriteFile:(NSString *)fileStr NeedData:(NSData *)theData Authority:(id)authStr;
+ (NSString *)OperatingRouteFile:(NSString *)fileStr Authority:(id)authStr;     // 获取文件路径
+ (BOOL)OperatingRenameFilePath:(NSString *)newPath OldFilePath:(NSString *)oldPath Authority:(id)authStr;     // 重命名
+ (id)OperatingFileAttributes:(NSString *)fileStr Authority:(id)authStr;      // 获取文件头信息

// zip 解压
+ (NSData *)ZipUnpackFile:(NSString *)fileStr EndDel:(BOOL)isDel Authority:(id)authStr;

// 获取本地app 资源文件
+ (NSData *)GetFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName Authority:(id)authStr;
// 获取本地 图片
+ (id)GetImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName Authority:(id)authStr;

// 数据库管理
+ (BOOL) CreateDataBase:(NSString *)dbPath Authority:(id)authStr;
+ (BOOL) CreateTable:(NSString *)tableName AllKey:(NSArray *)keys DatabasePath:(NSString *)dbPath Authority:(id)authStr;
+ (BOOL) UpdateWithTable:(NSString *)tableName DatabasePath:(id)dbPath Data:(NSDictionary *)dic MainKey:(NSString *)m_key Authority:(id)authStr;
+ (NSArray *) ResultWithDatabasePath:(NSString *)dbPath SelectList:(NSString *)sqlList Authority:(id)authStr;
+ (BOOL)UpdateDatabasePath:(NSString *)dbPath UpdateList:(NSString *)sqlList Authority:(id)authStr;
// 删除表
+ (BOOL)DeleteTable:(NSString *)tableName DatabasePath:(NSString *)dbPath Authority:(id)authStr;

// 获取表条数
+ (NSInteger)GetTableRowNumb:(NSString *)dbPath SelectList:(NSString *)sqlList Authority:(id)authStr;

// sql 事务
// 插入事务
+ (BOOL)InsertTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath DataArr:(NSArray *)dArr Authority:(id)authStr;
+ (BOOL)InsertTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath Key:(NSString *)f_key DataArr:(NSArray *)dArr Authority:(id)authStr;
// 修改事务
+ (BOOL)UpdateTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath MainKey:(NSString *)m_key DataArr:(NSArray *)dArr Authority:(id)authStr;

@end

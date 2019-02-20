//
//  FileToControll.m
//  testCCBMonitor
//
//  Created by zyy_pro on 14-10-22.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//

#import "FileToControll.h"

#import <FMDB/FMDB.h>

#import <ZipArchive/ZipArchive.h>

#import <KPFoundation/FileToUse.h>

@implementation FileToControll

/*
 文件命名格式：[NSString stringWithFormat:@"%@/%@",SaveToImageFolder,names];
 */

//+ (BOOL)HaveAuthority:(id)theAuth{
//    if ([theAuth isEqualToString:SelfAuthority])
//        return YES;
//
//    return NO;
//}

+ (BOOL)HaveAuthority:(id)theAuth{
    if (theAuth && [theAuth isMemberOfClass:[FileToUse class]])
        return YES;
    
    if (theAuth && [theAuth isMemberOfClass:[self class]]) {
        return YES;
    }
    
    return NO;
}

//创建文件夹
+ (BOOL)CreateFolder:(NSString *)folderName Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    return [FileToControll createFolder:folderName];
}
+ (BOOL)createFolder:(NSString *)folderName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderStr = [NSString stringWithFormat:@"%@/%@",documentsDirectory,folderName];
    
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

// 删除文件夹
+ (void)DeleteFolder:(NSString *)folderName Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return ;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], folderName];
    [fileManager removeItemAtPath:imageDir error:nil];
}

// 文件是否存在
+ (BOOL)OperatingIsInFile:(NSString *)fileStr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
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

// 读文件
+ (id)OperatingReadFile:(NSString *)fileStr Type:(NSInteger)type Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    if (fileStr) {
        NSError *err = nil;
        id data = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
        if ([fileManager fileExistsAtPath:fileStr]){
            if (type == 1) {
                data = [NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/%@",fileStr] options:NSDataReadingMappedIfSafe error:&err];
            }else if (type == 2){
                data =  [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingFormat:@"/%@",fileStr] encoding:NSUTF8StringEncoding error:&err];
            }
            
        }
        
        if (err)
            return nil;
        else
            return data;
    }
    
    return nil;
}

// 写文件(若存在，则删旧文件)
+ (BOOL)OperatingWriteFile:(NSString *)fileStr NeedData:(NSData *)theData Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (fileStr && theData && theData.length>0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
        //NSLog(@"documentsDirectory::%@",documentsDirectory);
        NSError *err = nil;
        if ([fileManager fileExistsAtPath:fileStr]) {
            [fileManager removeItemAtPath:fileStr error:&err];
        }
        
        if (err)
            return NO;
        
        return [fileManager createFileAtPath:fileStr contents:theData attributes:nil];
    }
    
    return NO;
}

+ (NSString *)OperatingRouteFile:(NSString *)fileStr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    if (fileStr) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return [documentsDirectory stringByAppendingFormat:@"/%@",fileStr];
        
    }
    
    return nil;
}

+ (BOOL)OperatingRenameFilePath:(NSString *)newPath OldFilePath:(NSString *)oldPath Authority:(id)authStr{
    if (!(newPath && oldPath)) {
        return NO;
    }
    
    NSString *fullNewPath = [self OperatingRouteFile:newPath Authority:authStr];
    NSString *fullOldPath = [self OperatingRouteFile:oldPath Authority:authStr];
    
    return [[NSFileManager defaultManager] moveItemAtPath:fullOldPath toPath:fullNewPath error:nil];
}

+ (id)OperatingFileAttributes:(NSString *)fileStr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    if (fileStr) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        return [[NSFileManager defaultManager] attributesOfItemAtPath:[documentsDirectory stringByAppendingFormat:@"/%@",fileStr] error:NULL];
    }
    
    return nil;
}

// zip 解压
+ (NSData *)ZipUnpackFile:(NSString *)fileStr EndDel:(BOOL)isDel Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    NSData *okData = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
    if ([fileManager fileExistsAtPath:fileStr]){
        ZipArchive *zip = [[ZipArchive alloc] init];
        
        if ([zip UnzipOpenFile:[documentsDirectory stringByAppendingFormat:@"/%@",fileStr]]) {
            BOOL ret = [zip UnzipFileTo:[documentsDirectory stringByAppendingFormat:@"/%@_zip",fileStr] overWrite: YES];
            
            [zip UnzipCloseFile];
            
            if (ret){
                NSArray *fileArr = [fileStr componentsSeparatedByString:@"/"];
                if (fileArr && [fileArr count] > 0) {
                    okData = [FileToControll OperatingReadFile:[NSString stringWithFormat:@"%@_zip/%@" ,fileStr ,[fileArr lastObject]] Type:1 Authority:authStr];
                }
            }
        }
        
        // 删除数据
        if (isDel) {
            [FileToControll DeleteFolder:fileStr Authority:authStr];
            [FileToControll DeleteFolder:[fileStr stringByAppendingString:@"_zip"] Authority:authStr];
        }
    }
    
    
    return okData;
    
}

#pragma mark - 获取本地 资源文件
// 获取本地 资源文件
+ (NSData *)GetFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
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
// 获取本地 图片
+ (id)GetImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    if (!imageName) {
        return nil;
    }
    NSBundle *bkBundle = [NSBundle mainBundle];
    if (bunleName) {
        bkBundle = [NSBundle bundleWithPath:[bkBundle pathForResource:bunleName ofType:@"bundle"]];
    }
    
    return [UIImage imageNamed:imageName inBundle:bkBundle compatibleWithTraitCollection:nil];
}

#pragma mark - 数据库操作

+ (FMDatabase *) createDataBase:(NSString *)dbPath{
    if (!dbPath) {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *db_Path = [documentsDirectory stringByAppendingPathComponent:dbPath];
    FMDatabase *db = [FMDatabase databaseWithPath:db_Path];
    
    if (!(db && [db open])) {
        NSLog(@"Could not open db.");
        return nil;
    }
    
    [db close];
    
    return db;
}

+ (BOOL) createTable:(NSString *)tableName AllKey:(NSArray *)keys FMDatabase:(FMDatabase *)db{
    if (!(tableName && keys)) {
        return NO;
    }
    if (!(db && [db isKindOfClass:[FMDatabase class]] && [db open])) {
        return NO;
    }
    
    if (![db tableExists:tableName]) {
        NSString *keyStr = @"";
        for (id str in keys) {
            if ([str isKindOfClass:[NSString class]]) {
                keyStr = [keyStr stringByAppendingFormat:@"%@ TEXT ,",str];
            }
        }
        if (keyStr && [keyStr length] > 1) {
            keyStr = [keyStr substringToIndex:([keyStr length] - 1)];
        }
        
        if (![db open]) {
            return NO;
        }
        // CREATE TABLE
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@(%@)", tableName, keyStr]];
        
        [db close];
        return YES;
    }
    
    [db close];
    return YES;
}

+ (BOOL) CreateDataBase:(NSString *)dbPath Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if ([FileToControll createDataBase:dbPath]) {
        return YES;
    }
    return NO;
}

+ (BOOL) CreateTable:(NSString *)tableName AllKey:(NSArray *)keys DatabasePath:(NSString *)dbPath Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    return [FileToControll createTable:tableName AllKey:keys FMDatabase:db];
}

+ (BOOL) UpdateWithTable:(NSString *)tableName DatabasePath:(id)dbPath Data:(NSDictionary *)dic MainKey:(NSString *)m_key Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(dbPath && dic)) {
        return NO;
    }
    
    BOOL returnBool = NO;
    
    FMDatabase *db = nil;
    if ([dbPath isKindOfClass:[NSString class]]) {
        db = [FileToControll createDataBase:dbPath];
    }else if([dbPath isKindOfClass:[FMDatabase class]]){
        db = dbPath;
    }
    
    if (db && [db open] && [db tableExists:tableName]) {
        // 更新不成功就插入一条数据
        NSString *upStrData = @"";
        
        NSArray *keyArr = [dic allKeys];
        for (NSInteger i = 0; i < [keyArr count]; i++) {
            if (![keyArr[i] isEqualToString:m_key]) {
                upStrData = [upStrData stringByAppendingFormat:@"%@ = '%@',",keyArr[i],dic[keyArr[i]]];
            }
        }
        if (upStrData && [upStrData length] > 1) {
            upStrData = [upStrData substringToIndex:([upStrData length] - 1)];
            
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, m_key, [dic objectForKey:m_key]]];
            
            if ([rs next]) {
                // 已经存在，则update
                returnBool = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'", tableName, upStrData, m_key, [dic objectForKey:m_key]]];
                
            }else{
                
                NSString *f_key = @"";
                NSString *f_value = @"";
                for (NSInteger i = 0; i < [keyArr count]; i++) {
                    f_key = [f_key stringByAppendingFormat:@"%@ ,",keyArr[i]];
                    f_value = [f_value stringByAppendingFormat:@"'%@' ,",dic[keyArr[i]]];
                }
                if (f_key && f_value && [f_key length] > 1 && [f_value length] > 1) {
                    f_key = [f_key substringToIndex:([f_key length] - 1)];
                    f_value = [f_value substringToIndex:([f_value length] - 1)];
                    
                    returnBool = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, f_key, f_value]];
                }
            }
        }
    }
    
    [db close];
    return returnBool;
}

// 删除表
+ (BOOL)DeleteTable:(NSString *)tableName DatabasePath:(NSString *)dbPath Authority:(id)authStr
{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(dbPath && tableName)) {
        return NO;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    if (db && [db open]){
        if ([db tableExists:tableName]) {
            if (![db executeUpdate:[NSString stringWithFormat:@"DROP TABLE %@", tableName]])
            {
                NSLog(@"Delete table error!");
                return NO;
            }
        }
        
    }else{
        return NO;
    }
    
    if (db) {
        [db close];
    }
    
    return YES;
}

+ (NSArray *) ResultWithDatabasePath:(NSString *)dbPath SelectList:(NSString *)sqlList Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return nil;
    
    if (!(dbPath && sqlList)) {
        return nil;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    if (!(db && [db open])){
        return nil;
    }
    
    FMResultSet *rs = [db executeQuery:sqlList];
    
    NSMutableArray *resultFull = [[NSMutableArray alloc]initWithCapacity:1];
    while ([rs next]){
        [resultFull addObject:[rs resultDictionary]];
    }
    
    [db close];
    
    if ([resultFull count] > 0) {
        return [resultFull copy];
    }
    return nil;
}

// 表操作
+ (BOOL)UpdateDatabasePath:(NSString *)dbPath UpdateList:(NSString *)sqlList Authority:(id)authStr
{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(dbPath && sqlList)) {
        return NO;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    if (db && [db open]){
        if (![db executeUpdate:sqlList])
        {
            NSLog(@"UpdateDatabasePath sqlList error!");
            return NO;
        }
        
    }else{
        return NO;
    }
    
    if (db) {
        [db close];
    }
    
    return YES;
}

+ (NSInteger)GetTableRowNumb:(NSString *)dbPath SelectList:(NSString *)sqlList Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return -1;
    
    NSInteger numb = -1;
    if (dbPath && sqlList) {
        FMDatabase *db = [FileToControll createDataBase:dbPath];
        if (db && [db open]){
            numb = [db intForQuery:sqlList];
        }
        [db close];
    }
    
    return numb;
}

+ (BOOL)InsertTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath DataArr:(NSArray *)dArr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(tableName && dbPath && dArr)) {
        return NO;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    if (!(db && [db open])){
        
        return NO;
    }
    
    
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    @try {
        for (id oneDic in dArr) {
            if ([oneDic isKindOfClass:[NSDictionary class]]) {
                NSArray *keyArr = [oneDic allKeys];
                
                NSString *f_key = @"";
                NSString *f_value = @"";
                for (NSInteger i = 0; i < [keyArr count]; i++) {
                    f_key = [f_key stringByAppendingFormat:@"%@ ,",keyArr[i]];
                    f_value = [f_value stringByAppendingFormat:@"\"%@\" ,",[oneDic[keyArr[i]] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
                }
                if (f_key && f_value && [f_key length] > 1 && [f_value length] > 1) {
                    f_key = [f_key substringToIndex:([f_key length] - 1)];
                    f_value = [f_value substringToIndex:([f_value length] - 1)];
                    
                    BOOL returnBool = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, f_key, f_value]];
                    if (!returnBool) {
                        isRollBack = YES;
                        break ;
                    }
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (isRollBack) {
            [db rollback];
        }else{
            [db commit];
        }
        
        [(FMDatabase *)db close];
        
        return !isRollBack;
    }
}
+ (BOOL)InsertTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath Key:(NSString *)f_key DataArr:(NSArray *)dArr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(tableName && dbPath && dArr && f_key)) {
        return NO;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    if (!(db && [db open])){
        
        return NO;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    @try {
        for (id oneStr in dArr) {
            if ([oneStr isKindOfClass:[NSString class]]) {
                BOOL returnBool = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, f_key, oneStr]];
                if (!returnBool) {
                    isRollBack = YES;
                    break ;
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (isRollBack) {
            [db rollback];
        }else{
            [db commit];
        }
        
        [(FMDatabase *)db close];
        
        return !isRollBack;
    }
}


+ (BOOL)UpdateTransactionTable:(NSString *)tableName DatabasePath:(NSString *)dbPath MainKey:(NSString *)m_key DataArr:(NSArray *)dArr Authority:(id)authStr{
    if (![FileToControll HaveAuthority:authStr])
        return NO;
    
    if (!(tableName && dbPath && dArr && m_key)) {
        return NO;
    }
    
    FMDatabase *db = [FileToControll createDataBase:dbPath];
    
    if (!(db && [db open])){
        
        return NO;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    @try {
        for (id oneDic in dArr) {
            if ([oneDic isKindOfClass:[NSDictionary class]]) {
                NSArray *keyArr = [oneDic allKeys];
                NSString *upStrData = @"";
                
                for (NSInteger i = 0; i < [keyArr count]; i++) {
                    if (![keyArr[i] isEqualToString:m_key]) {
                        upStrData = [upStrData stringByAppendingFormat:@"%@ = '%@',",keyArr[i],oneDic[keyArr[i]]];
                    }
                }
                
                BOOL returnBool = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'", tableName, upStrData, m_key, [oneDic objectForKey:m_key]]];
                if (!returnBool) {
                    isRollBack = YES;
                    break ;
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (isRollBack) {
            [db rollback];
        }else{
            [db commit];
        }
        
        [(FMDatabase *)db close];
        
        return !isRollBack;
    }
}

@end

//
//  FileUse+FMDB.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/21.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import "FileUse+FMDB.h"

#import "FileUse+Manager.h"

#import "DBToParser.h"

#import <FMDB/FMDB.h>

#define FolderLibDB     @"LibDataBase"      // sdk数据库文件夹

@implementation FileUse (FMDB)

- (void)initFileUseFMDBAuthority{
    
    if (!dbQueueDic) {
        dbQueueDic = [[NSMutableDictionary alloc]initWithCapacity:3];
    }else{
        [dbQueueDic removeAllObjects];
    }
}

/**
 生成数据库
 
 @param dbPath 数据库路径
 @param authority 认证
 @return 返回数据库
 */
- (FMDatabaseQueue *) createDataBaseQueueFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    
    NSString *db_Path = [self getRouteFolderName:folderName FileName:fileName];
    if (db_Path) {
        FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:db_Path];
        
        if (!dbQueue) {
            NSLog(@"---------------- Could not build db Queue.");
            return nil;
        }
        
        return dbQueue;
    }
    return nil;
}

/**
 建表

 @param tableName 表名
 @param keys 字段
 @param db 表所属数据库
 @return 是否成功
 */
- (BOOL) createTable:(NSString *)tableName AllKey:(NSArray *)keys FMDatabase:(FMDatabase *)db{
    if (!(tableName && keys)) {
        return NO;
    }
    if (!(db && [db open])) {
        return NO;
    }
    
    if (![db tableExists:tableName]) {
        NSString *keyStr = @"";
        for (id dic in keys) {
            if ([dic isKindOfClass:[NSDictionary class]] && [[dic allKeys] count]) {
                keyStr = [keyStr stringByAppendingFormat:@"%@ %@ ,",[dic allKeys][0] ,dic[[dic allKeys][0]]];
            }
        }
        if (keyStr && [keyStr length] > 1) {
            keyStr = [keyStr substringToIndex:([keyStr length] - 1)];
        }
    
        // CREATE TABLE
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@(%@)", tableName, keyStr]];
        
        [db close];
        return YES;
    }
    
    [db close];
    return YES;
}


/**
 查找数据库

 @param db 数据库
 @param sqlList sql语句
 @return 查询结果
 */
- (NSArray *) resultDB:(FMDatabase *)db SelectList:(NSString *)sqlList{
    if (!(db && sqlList)) {
        return nil;
    }
    if (!(db && [db open])){
        return nil;
    }
    
    FMResultSet *rs = [db executeQuery:sqlList];
    
    NSMutableArray *resultFull = [[NSMutableArray alloc] init];
    while ([rs next]){
        [resultFull addObject:[rs resultDictionary]];
    }
    
    [db close];
    
    if ([resultFull count] > 0) {
        return [resultFull copy];
    }
    return nil;
}

/**
 删除表

 @param db 数据库
 @param sqlList sql语句
 @return 是否成功
 */
- (BOOL)updateDB:(FMDatabase *)db SelectList:(NSString *)sqlList{
    
    if (!(db && sqlList)) {
        return NO;
    }
    if (!(db && [db open])) {
        return NO;
    }
    BOOL returnBool = [db executeUpdate:sqlList];
    
    [db close];
    return returnBool;
}

/**
 插入一条数据

 @param db 数据库
 @param tableName 表
 @param dic 数据
 @return 是否成功
 */
- (BOOL)insertDB:(FMDatabase *)db Table:(NSString *)tableName Data:(NSDictionary *)dic{
    if (!(db && tableName && dic)) {
        return NO;
    }
    
    if (!(db && [db open])) {
        return NO;
    }
    
    // 更新不成功就插入一条数据
    BOOL isOk = NO;
    NSArray *keyArr = [dic allKeys];
    NSString *f_key = @"";
    NSString *f_value = @"";
    
    for (NSInteger i = 0; i < [keyArr count]; i++) {
        f_key = [f_key stringByAppendingFormat:@"%@ ,",keyArr[i]];
        f_value = [f_value stringByAppendingFormat:@"'%@' ,",dic[keyArr[i]]];
    }
    if (f_key && f_value && [f_key length] > 1 && [f_value length] > 1) {
        f_key = [f_key substringToIndex:([f_key length] - 1)];
        f_value = [f_value substringToIndex:([f_value length] - 1)];
        
        isOk = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, f_key, f_value]];
    }
    
    [db close];
    return isOk;
}

/**
 修改、更新数据

 @param db 数据库
 @param tableName 表名
 @param dic 要修改数据
 @param mkey 主键名称
 @return 是否成功
 */
- (BOOL)updateDB:(FMDatabase *)db Table:(NSString *)tableName Data:(NSDictionary *)dic MainKey:(NSString *)mkey{
    if (!(db && tableName && dic && mkey)) {
        return NO;
    }
    
    if (!(db && [db open])) {
        return NO;
    }
    
    NSString *upStrData = @"";
    NSArray *keyArr = [dic allKeys];
    for (NSInteger i = 0; i < [keyArr count]; i++) {
        if (![keyArr[i] isEqualToString:mkey]) {
            upStrData = [upStrData stringByAppendingFormat:@"%@ = '%@',",keyArr[i],dic[keyArr[i]]];
        }
    }
    
    BOOL returnBool = NO;
    if (upStrData && [upStrData length] > 1) {
        upStrData = [upStrData substringToIndex:([upStrData length] - 1)];
        
        returnBool = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'", tableName, upStrData, mkey, [dic objectForKey:mkey]]];
    }
    
    [db close];
    return returnBool;
}

// 检测模型，跟本地库、表，的完整性
- (BOOL)cheakDataMode:(id)dMode{
    if (dMode && [dMode isKindOfClass:[DBToParser class]]) {
        __weak DBToParser *_dMode = dMode;
        
        NSString *dbName = [_dMode getDBName];
        
        if (dbName) {
            __block BOOL isRebuild = YES;       // 是否需要建库
            __block BOOL isEffective = NO;     // 是否存在并有效
            if (dbQueueDic[dbName]) {
                
                FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
                [dbQueue inDatabase:^(FMDatabase *db) {
                    // 数据库有效性
                    if ([db goodConnection]) {
                        BOOL isExists = [db tableExists:[_dMode parserClassString]];
                        if (!isExists) {
                            // 建表
                            NSArray *allKey = [_dMode parserKeys];
                            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[allKey count]];
                            for (NSInteger i = 0; i < [allKey count]; i++) {
                                NSString *att = [_dMode getAttributesTypeWithKey:allKey[i]];
                                if (att) {
                                    [arr addObject:@{allKey[i]:att}];
                                }
                            }
                            isEffective = [self createTable:[_dMode parserClassString] AllKey:[arr copy] FMDatabase:db];
                        }
                        
                        isRebuild = NO;
                    }
                }];
            }
            
            if (isRebuild) {
                FMDatabaseQueue *dbQueue = [self createDataBaseQueueFolderName:FolderLibDB FileName:dbName];
                if (dbQueue) {
                    [dbQueueDic setObject:dbQueue forKey:dbName];
                }
                
                // 建表
                [dbQueue inDatabase:^(FMDatabase *db) {
                    NSArray *allKey = [_dMode parserKeys];
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[allKey count]];
                    for (NSInteger i = 0; i < [allKey count]; i++) {
                        NSString *att = [_dMode getAttributesTypeWithKey:allKey[i]];
                        if (att) {
                            [arr addObject:@{allKey[i]:att}];
                        }
                    }
                    
                    isEffective = [self createTable:[_dMode parserClassString] AllKey:[arr copy] FMDatabase:db];
                }];
            }
            
            return isEffective;
        }
    }
    
    return NO;
}

#pragma mark - 外部调用
- (BOOL)updateModeData:(id)dataMode{
    __block BOOL isOk = NO;
    if ([self cheakDataMode:dataMode]) {
        
        NSString *dbName = [(DBToParser *)dataMode getDBName];
        NSString *tableClass = [(DBToParser *)dataMode parserClassString];
        NSDictionary *dic = [(DBToParser *)dataMode parserToDictionary];
        
        if ([(DBToParser *)dataMode isAutoMainKey]) {
            // 无主键 新增
            FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
            [dbQueue inDatabase:^(FMDatabase *db) {
                
                isOk = [self insertDB:db Table:tableClass Data:dic];
            }];
        }else{
            // 有主键
            __weak DBToParser *_dMode = dataMode;
            
            FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
            [dbQueue inDatabase:^(FMDatabase *db) {
                
                NSArray *haveOne = [self resultDB:db SelectList:[NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableClass, [_dMode parserNameWithInstance:_dMode.main_key], _dMode.main_key]];
                if (haveOne && [haveOne count]) {
                    // 修改
                    isOk = [self updateDB:db Table:tableClass Data:dic MainKey:[_dMode parserNameWithInstance:_dMode.main_key]];
                }else{
                    // 新增
                    isOk = [self insertDB:db Table:tableClass Data:dic];
                }
            }];
        }
    }
    
    return isOk;
}

- (id)resultModeData:(id)dataMode{
    __block NSArray *arr = nil;
    if ([self cheakDataMode:dataMode]) {
        
        __weak DBToParser *_dMode = dataMode;
        NSString *dbName = [(DBToParser *)dataMode getDBName];
        FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            arr = [self resultDB:db SelectList:[_dMode getSqlList]];
        }];
    }
    
    return arr;
}

- (BOOL)deleteTableMode:(id)dataMode{
    __block BOOL isOk = NO;
    if ([self cheakDataMode:dataMode]) {
        
        NSString *dbName = [(DBToParser *)dataMode getDBName];
        NSString *tableClass = [(DBToParser *)dataMode parserClassString];
        FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
        
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            isOk = [self updateDB:db SelectList:[NSString stringWithFormat:@"DROP TABLE %@", tableClass]];
        }];
    }
    
    return isOk;
}

- (BOOL)upToTableMode:(id)dataMode ListNumb:(NSUInteger)nowNumb AddItem:(NSArray *)item{
    if (!(dataMode && nowNumb > 0 && item && [item count] > 0)) {
        return YES;
    }
    
    if ([self cheakDataMode:dataMode]) {
        
        NSString *dbName = [(DBToParser *)dataMode getDBName];
        NSString *tableClass = [(DBToParser *)dataMode parserClassString];
        FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
        
        NSString *tableSqlStr = [NSString stringWithFormat:@"select * from sqlite_master where type = 'table' and tbl_name = '%@'", tableClass];
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            NSArray *tableInfo = [self resultDB:db SelectList:tableSqlStr];
            
            if (tableInfo && [tableInfo count] == 1) {
                NSDictionary *mDic = tableInfo[0];
                NSString *sqlStr = mDic[@"sql"];
                NSArray *sqlCount = [sqlStr componentsSeparatedByString:@","];
                
                if (sqlCount && [sqlCount count] == nowNumb) {
                    for (NSInteger i = 0; i < [item count]; i++) {
                        NSString *tableAlterSqlStr = [NSString stringWithFormat:@"ALTER table %@ ADD '%@' TEXT DEFAULT ''",tableClass ,item[i]];
                        
                        if (![self updateDB:db SelectList:tableAlterSqlStr]) {
                            break;
                        }
                    }
                }
            }
        }];
    }

    return YES;
}

- (NSInteger)resultModeNumb:(id)dataMode{
    __block NSInteger resultNumb = 0;
    if ([self cheakDataMode:dataMode]) {
        
        NSString *dbName = [(DBToParser *)dataMode getDBName];
        FMDatabaseQueue *dbQueue = dbQueueDic[dbName];
        
        __weak DBToParser *_dMode = dataMode;
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            if (db && [db open]){
                resultNumb = [db intForQuery:[_dMode getSqlList]];
            }
            [db close];
        }];
    }
    
    return resultNumb;
}

@end

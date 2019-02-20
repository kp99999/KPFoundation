    //
//  FileToUse.m
//  ZYYObjcLib
//
//  Created by zyyuann on 16/1/12.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import "FileToUse.h"

#import "GeneralUse.h"

#import "FileToControll.h"

#import "SecurityPolicy.h"

#import "ShareTable.h"

#import "TimingTask.h"

#import "FileUse.h"

#import "FileUseOther.h"

#define DelFolderTime               @"delfolder_time"       // key 删除时间

// 工程资源存储
#define FolderLibDB     @"LibDataBase"      // sdk数据库文件夹
#define FileLibDB       @"LibDatabase.db"         // sdk数据库
#define LibDBTable     @"config_table"      // 数据表

typedef NS_ENUM (NSInteger,FileType)  {
    SQLUpdateType = 1,      // 更新sql数据
    SQLResultType ,           // 获取sql数据
    SQLResultNumbType ,           // 获取sql数据
    SQLDeleteType ,           // 删除表
    
    InsertTransactionType ,           // 插入事务
    UpdateTransactionType ,            // 修改事务
    
    InsertTransactionType_2 ,           // 插入事务
    UpdateTransactionType_2            // 修改事务
};

@interface FileObject : NSObject

@property FileType fileType;       // 操作类型

@property(nonatomic, copy) FileFinish finishDo;     // 如果已经成功，置空

@property(nonatomic, strong) id objParser;      // sql 基于 DBToParser、nsstring 类

@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSString *filePath;      // Folder 或 Bundle

@property(nonatomic, strong) id dtOther;      // 待定

@property BOOL isFrish;

@end

@implementation FileObject

@end


#pragma mark - FileToUse 类

static bool isInit = NO;     // 单例初始化判断（该类不允许被继承，初始化多个）

@interface FileToUse(){
    /*  文件配置
     key: 文件夹名称
     value: 文件夹配置参数
     */
    NSDictionary *fileConfig;
    
    NSMutableArray *fileObjArr;     // 缓存文件操作
    BOOL isFileDoing;       // 文件操作中
    
    NSLock *fileLock;
}

@end

@implementation FileToUse

+ (FileToUse *)Share{
    static dispatch_once_t onceFileToUse;
    static FileToUse * singletonFileToUse;
    dispatch_once(&onceFileToUse, ^{
        isInit = YES;
        singletonFileToUse = [[FileToUse alloc] init];
    });
    return singletonFileToUse;
}

- (id)init
{
    if (!isInit) {
        NSAssert(isInit , @"该类不允许被继承，初始化多个");
        return nil;
    }
    
    self = [super init];
    if (self) {
        fileObjArr = [[NSMutableArray alloc]initWithCapacity:10];
        
        fileLock = [[NSLock alloc] init];
        
        fileConfig = nil;
        
        id infoData = FCJsonLocal(@"FolderSetting.json");
        if (infoData && [infoData isKindOfClass:[NSDictionary class]]) {
            fileConfig = [infoData copy];
        }else{
            NSAssert(NO , @"FolderSetting 配置文件有错误");
            return nil;
        }
        
        [FileToControll CreateFolder:FolderLibDB Authority:self];
        if (![self initLibDB]) {
            NSAssert(NO , @"lib 创建数据库、表失败");
            return nil;
        }
        
        NSArray *keyArr = [fileConfig allKeys];
        for (NSString *str in keyArr) {
            BOOL isSecc = [FileToControll CreateFolder:str Authority:self];
            NSAssert(isSecc , @"FolderSetting 文件夹创建失败");
            if (isSecc) {
                NSDictionary *oneConfig = [fileConfig objectForKey:str];
                if ([[oneConfig objectForKey:@"unClean"] isEqualToString:@"0"]) {
                    [self judgeToDelFolder:str Day:[oneConfig objectForKey:@"cleanDay"]];
                }
                
            }
        }
        
        [self startFileHandle];     // 开启定时处理
    }
    return self;
}

- (BOOL)initLibDB{
    
    if ([FileToControll CreateDataBase:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]) {
        
        ShareTable *commontTable = [[ShareTable alloc]initWithDictionary:@{@"valve":@"CreateTable"}];
        
        return [FileToControll CreateTable:[commontTable parserClassString] AllKey:[commontTable parserKeys] DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self];
    }
    return NO;
}

// 判断是否要清空缓存
- (void)judgeToDelFolder:(NSString *)folder Day:(NSString *)days{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    NSString *theStr = [defaults objectForKey:DelFolderTime];
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
            [FileToControll DeleteFolder:folder Authority:self];
            if ([FileToControll CreateFolder:folder Authority:self]) {
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

- (void)autoAddMainKey:(id)dataMode{
    if (!(dataMode && [dataMode isKindOfClass:[DBToParser class]])) {
        return;
    }
    if ([(DBToParser *)dataMode isAutoMainKey]) {
        NSInteger count = [FileToControll GetTableRowNumb:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] SelectList:[NSString stringWithFormat:@"select count(*) from %@",[(DBToParser *)dataMode parserClassString]] Authority:self];
        if (count >= 0) {
            ((DBToParser *)dataMode).main_key = [NSString stringWithFormat:@"%ld",(long)count + 1];
        }else{
            // 数据表未创建，初始化
            ((DBToParser *)dataMode).main_key = @"0";
        }
    }
}

#pragma mark - 开启定时处理(NSString *sdfsf)
- (void)startFileHandle{
    isFileDoing = NO;
    
    // 这个地方一定要加返回
    NSString *sdfsf = [[TimingTask Start] addNotifyTime:0.1 OneTime:NO RunQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) TimeDo:^BOOL{

        if (isFileDoing || [fileObjArr count] <= 0) {
            return YES;
        }
        
        isFileDoing = YES;
        
        [fileLock lock];
        
        for (NSInteger i = 0; i < [fileObjArr count]; i++){
            if (((FileObject *)fileObjArr[i]).isFrish) {
                ((FileObject *)fileObjArr[i]).objParser = nil;
                [fileObjArr removeObjectAtIndex:i];
                i--;
            }
        }
        
        [fileLock unlock];
        
        for (NSInteger i = 0; i < [fileObjArr count]; i++) {
            FileObject *fileObj = fileObjArr[i];
            if (fileObj.finishDo) {
                if (fileObj.fileType == SQLUpdateType) {
                    BOOL up_end = [self updateModeData:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileObj.finishDo(up_end,nil);
                    });
                    
                }else if (fileObj.fileType == SQLResultType){
                    NSArray *resultEnd = [self resultModeData:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        fileObj.finishDo(YES,resultEnd);
                    });
                    
                }else if (fileObj.fileType == SQLResultNumbType){
                    NSInteger resultNmub = [self resultModeToNumb:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultNmub >= 0) {
                            fileObj.finishDo(YES,[NSNumber numberWithInteger:resultNmub]);
                        }else{
                            fileObj.finishDo(NO,nil);
                        }
                        
                    });
                    
                }else if (fileObj.fileType == SQLDeleteType){
                    BOOL delete_end = [self deleteModeData:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileObj.finishDo(delete_end,nil);
                    });
                }else if (fileObj.fileType == InsertTransactionType){
                    BOOL insert_end = [self insertTransactionData:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileObj.finishDo(insert_end,nil);
                    });
                }else if (fileObj.fileType == UpdateTransactionType){
                    BOOL update_end = [self updateTransactionData:fileObj.objParser];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileObj.finishDo(update_end,nil);
                    });
                }else if (fileObj.fileType == InsertTransactionType_2){
                    BOOL insert_end = NO;
                    NSArray *keyArr = [(NSString *)fileObj.dtOther componentsSeparatedByString:@","];
                    if (fileObj.fileName && [FileToControll CreateTable:fileObj.fileName AllKey:keyArr DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]) {
                        
                        insert_end = [FileToControll InsertTransactionTable:fileObj.fileName DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Key:fileObj.dtOther DataArr:fileObj.objParser Authority:self];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fileObj.finishDo(insert_end,nil);
                    });
                }
            }
            
            fileObj.isFrish = YES;
        }
        
        isFileDoing = NO;
        
        return YES;
    }];
}

#pragma mark - sql 内部调用
// mode 数据库
- (BOOL)updateModeData:(id)dataMode{
    if (!dataMode) {
        return NO;
    }
    
    if ([dataMode isKindOfClass:[DBToParser class]]) {
        [self autoAddMainKey:dataMode];
        
        NSString *tableClass = [(DBToParser *)dataMode parserClassString];
        if (tableClass && [FileToControll CreateTable:tableClass AllKey:[(DBToParser *)dataMode parserKeys] DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]) {
            
            NSDictionary *dic = [(DBToParser *)dataMode parserToDictionary];
            
            return [FileToControll UpdateWithTable:tableClass DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Data:dic MainKey:@"main_key" Authority:self];
        }
    }else if ([dataMode isKindOfClass:[NSArray class]] && [dataMode count] > 0){
        
        NSString *tableClass = [(DBToParser *)dataMode[0] parserClassString];
        if (tableClass && [FileToControll CreateTable:tableClass AllKey:[(DBToParser *)dataMode[0] parserKeys] DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]) {
            
            @try {
                for (id oneMode in dataMode) {
                    [self autoAddMainKey:oneMode];
                    
                    NSDictionary *dic = [(DBToParser *)oneMode parserToDictionary];
                    
                    [FileToControll UpdateWithTable:tableClass DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Data:dic MainKey:@"main_key" Authority:self];
                    
                }
            }
            @catch (NSException *exception) {
            }
            @finally {
                
                return YES;
            }
        }
        
        
    }
    
    return NO;
}
- (NSArray *)resultModeData:(id)dataMode{
    if (!(dataMode && [dataMode isKindOfClass:[DBToParser class]])) {
        return nil;
    }
    NSString *tableClass = [(DBToParser *)dataMode parserClassString];
    if (tableClass && [FileToControll CreateTable:tableClass AllKey:[(DBToParser *)dataMode parserKeys] DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]){
        return [FileToControll ResultWithDatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] SelectList:[(DBToParser *)dataMode getSqlList] Authority:self];
    }else{
        return nil;
    }
}
- (NSInteger)resultModeToNumb:(id)dataMode{
    if (!(dataMode && [dataMode isKindOfClass:[DBToParser class]])) {
        return -1;
    }
    NSString *tableClass = [(DBToParser *)dataMode parserClassString];
    if (tableClass && [FileToControll CreateTable:tableClass AllKey:[(DBToParser *)dataMode parserKeys] DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]){
        return [FileToControll GetTableRowNumb:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] SelectList:[(DBToParser *)dataMode getSqlList] Authority:self];
    }else{
        return -1;
    }
}
- (BOOL)deleteModeData:(id)dataMode{
    if (!(dataMode && [dataMode isKindOfClass:[DBToParser class]])) {
        return nil;
    }
    NSString *tableClass = [(DBToParser *)dataMode parserClassString];
    return [FileToControll DeleteTable:tableClass DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self];
}

// 插入事务
- (BOOL)insertTransactionData:(NSArray *)dArr{
    if (!dArr) {
        return NO;
    }
    
    NSString *tableClass = nil;
    NSArray *tbKeys = nil;
    
    NSMutableArray *insertArr = [NSMutableArray arrayWithCapacity:[dArr count]];
    for (id oneMode in dArr) {
        if ([oneMode isKindOfClass:[DBToParser class]]) {
            NSDictionary *dic = [(DBToParser *)oneMode parserToDictionary];
            if (dic) {
                [insertArr addObject:dic];
                
                if (!tableClass) {
                    tableClass = [(DBToParser *)oneMode parserClassString];
                }
                if (!tbKeys) {
                    tbKeys = [(DBToParser *)oneMode parserKeys];
                }
            }
        }
    }
    if (tableClass && [FileToControll CreateTable:tableClass AllKey:tbKeys DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]){
        return [FileToControll InsertTransactionTable:tableClass DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] DataArr:[insertArr copy] Authority:self];
    }else{
        return NO;
    }
}
// 修改事务
- (BOOL)updateTransactionData:(NSArray *)dArr{
    if (!dArr) {
        return NO;
    }
    
    NSString *tableClass = nil;
    NSString *mainKey = nil;
    NSArray *tbKeys = nil;
    
    NSMutableArray *insertArr = [NSMutableArray arrayWithCapacity:[dArr count]];
    for (id oneMode in dArr) {
        if ([oneMode isKindOfClass:[DBToParser class]]) {
            NSDictionary *dic = [(DBToParser *)oneMode parserToDictionary];
            if (dic) {
                [insertArr addObject:dic];
                
                if (!tableClass) {
                    tableClass = [(DBToParser *)oneMode parserClassString];
                }
                if (!mainKey) {
                    mainKey = [(DBToParser *)oneMode parserNameWithInstance:((DBToParser *)oneMode).main_key];
                }
                if (!tbKeys) {
                    tbKeys = [(DBToParser *)oneMode parserKeys];
                }
            }
        }
    }
    
    if (tableClass && [FileToControll CreateTable:tableClass AllKey:tbKeys DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] Authority:self]){
        return [FileToControll UpdateTransactionTable:tableClass DatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] MainKey:mainKey DataArr:[insertArr copy] Authority:self];
    }else{
        return NO;
    }
}

#pragma mark - 文件操作 外部调用
// 判断文件是否存在
- (BOOL)isInFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return NO;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return NO;
    }
    
    NSString *fullName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:fileName]];
    return [FileToControll OperatingIsInFile:fullName Authority:self];
}
- (id)readFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return nil;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return nil;
    }
    
    NSString *fullName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:fileName]];
    return [FileToControll OperatingReadFile:fullName Type:1 Authority:self];
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
        NSString *fullName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:fileName]];
        return [FileToControll OperatingWriteFile:fullName NeedData:theData Authority:self];
    }
    
    return NO;
}
- (BOOL)writeData:(NSData *)theData FolderName:(NSString *)folderName SourceName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return NO;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return NO;
    }
    
    if (theData) {
        NSString *fullName = [NSString stringWithFormat:@"%@/%@",folderName,fileName];
        return [FileToControll OperatingWriteFile:fullName NeedData:theData Authority:self];
    }
    
    return NO;
}

- (NSString *)getRouteFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!folderName) {
        return nil;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return nil;
    }
    
    NSString *fullName = folderName;
    if (fileName) {
        fullName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:fileName]];
    }
    
    return [FileToControll OperatingRouteFile:fullName Authority:self];
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
    
    NSString *pOldName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:oldName]];
    NSString *pNewName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:newName]];
    
    return [FileToControll OperatingRenameFilePath:pNewName OldFilePath:pOldName Authority:self];
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
        fullName = [NSString stringWithFormat:@"%@/%@",folderName,[SecurityPolicy EncryptMD5_16:fileName]];
    }
    
    id dic = [FileToControll OperatingFileAttributes:fullName Authority:self];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSNumber *contentLength = dic[NSFileSize];
        if (contentLength) {
            return contentLength.integerValue;
        }
    }
    
    return -1;
}

- (void)deleteFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    
    if (folderName && fileName) {
        [FileToControll DeleteFolder:[NSString stringWithFormat:@"%@/%@",folderName, fileName] Authority:self];
    }else if (folderName){
        [self judgeToDelFolder:folderName Day:@"0"];
    }
    
}

// zip 解压
- (NSData *)zipUnpackFolderName:(NSString *)folderName FileName:(NSString *)fileName{
    if (!(fileName && folderName)) {
        return nil;
    }
    NSDictionary *folderConfig = [fileConfig objectForKey:folderName];
    if (!folderConfig) {
        return nil;
    }
    
    return [FileToControll ZipUnpackFile:[NSString stringWithFormat:@"%@/%@",folderName,fileName] EndDel:YES Authority:self];
}

#pragma mark - Bundle Resource 读写 操作
// 获取本地 资源文件
- (NSData *)getFileLocal:(NSString *)fileName BundleResource:(NSString *)bunleName{
    return [FileToControll GetFileLocal:fileName BundleResource:bunleName Authority:self];
}
// 获取本地 json 资源文件
- (id)getAsynchronousJsonLocal:(NSString *)interfaceName BundleResource:(NSString *)bunleName{
    NSData *content = [FileToControll GetFileLocal:interfaceName BundleResource:bunleName Authority:self];
    
    if (!content) {
        return nil;
    }
    
    return [GeneralUse TransformToObj:content];
}
// 获取本地 图片
- (id)getImageLocal:(NSString *)imageName BundleResource:(NSString *)bunleName{
    return [FileToControll GetImageLocal:imageName BundleResource:bunleName Authority:self];
}

- (NSDictionary *)getPlistName:(NSString *)name
{
    if (name) {
        NSString *appCfgPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        BOOL isHav = [[NSFileManager defaultManager] fileExistsAtPath:appCfgPath];
        NSAssert(isHav, @"AppCfg.plist 找不到App配置文件，请增加配置文件");
        if (isHav) {
            return [[NSDictionary alloc] initWithContentsOfFile:appCfgPath];
        }
    }
    return nil;
}

#pragma mark - sql数据库 外部调用
- (void)updateModeData:(id)dataMode Finish:(FileFinish)fileFinish{
    
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.fileType = SQLUpdateType;
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dataMode;
    fileObj.isFrish = NO;
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}
- (void)resultModeData:(id)dataMode Finish:(FileFinish)fileFinish{
    
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.fileType = SQLResultType;
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dataMode;
    fileObj.isFrish = NO;
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}
- (void)resultModeNumb:(id)dataMode Finish:(FileFinish)fileFinish{
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.fileType = SQLResultNumbType;
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dataMode;
    fileObj.isFrish = NO;
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}
- (void)deleteTableMode:(id)dataMode Finish:(FileFinish)fileFinish{
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.fileType = SQLDeleteType;
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dataMode;
    fileObj.isFrish = NO;
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}
// 更新表
- (BOOL)upToTableName:(NSString *)name ListNumb:(NSUInteger)nowNumb AddItem:(NSArray *)item{
    
    if (!(name && nowNumb > 0 && item && [item count] > 0)) {
        return YES;
    }
    
    NSString *tableSqlStr = [NSString stringWithFormat:@"select * from sqlite_master where type = 'table' and tbl_name = '%@'", name];
    
    NSArray *tableInfo = [FileToControll ResultWithDatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] SelectList:tableSqlStr Authority:self];
    if (tableInfo && [tableInfo count] == 1) {
        NSDictionary *mDic = tableInfo[0];
        NSString *sqlStr = mDic[@"sql"];
        NSArray *sqlCount = [sqlStr componentsSeparatedByString:@","];
        
        if (sqlCount && [sqlCount count] == nowNumb) {
            for (NSInteger i = 0; i < [item count]; i++) {
                NSString *tableAlterSqlStr = [NSString stringWithFormat:@"ALTER table %@ ADD '%@' TEXT DEFAULT ''",name ,item[i]];
                
                if (![FileToControll UpdateDatabasePath:[NSString stringWithFormat:@"%@/%@", FolderLibDB, FileLibDB] UpdateList:tableAlterSqlStr Authority:self]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

// 事务
- (void)transactionData:(NSArray *)dArr Type:(NSInteger)type Finish:(FileFinish)fileFinish{
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dArr;
    fileObj.isFrish = NO;
    
    if (type == 1) {
        fileObj.fileType = InsertTransactionType;
    }else if (type == 2){
        fileObj.fileType = UpdateTransactionType;
    }
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}
- (void)transactionData:(NSArray *)dArr Key:(NSString *)key TableName:(NSString *)tName Type:(NSInteger)type Finish:(FileFinish)fileFinish{
    [fileLock lock];
    
    FileObject *fileObj = [[FileObject alloc]init];
    fileObj.finishDo = fileFinish;
    fileObj.objParser = dArr;
    fileObj.isFrish = NO;
    fileObj.dtOther = key;
    fileObj.fileName = tName;
    
    if (type == 1) {
        fileObj.fileType = InsertTransactionType_2;
    }else if (type == 2){
        fileObj.fileType = UpdateTransactionType_2;
    }
    
    [fileObjArr addObject:fileObj];
    
    [fileLock unlock];
}

@end

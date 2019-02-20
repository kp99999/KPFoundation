//
//  FileUse+FMDB.h
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/21.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/FileUse.h>

@interface FileUse(){
    
    NSMutableDictionary *dbQueueDic;        // FMDatabaseQueue 集群
}

@end

@interface FileUse (FMDB)

- (void)initFileUseFMDBAuthority;        // 初始化

/**
 数据库 新增、修改 操作
 
 @param dataMode 继承 DBToParser 的 mode对象
 @return 是否成功
 */
- (BOOL)updateModeData:(id)dataMode;

/**
 数据库 查询操作
 
 @param dataMode dataMode 继承 DBToParser 的 mode对象
 @return 返回查询结果
 */
- (id)resultModeData:(id)dataMode;

/**
 删除表
 
 @param dataMode  继承 DBToParser 的 mode对象
 @return 是否成功
 */
- (BOOL)deleteTableMode:(id)dataMode;

/**
 更新表结构
 
 @param dataMode 继承 DBToParser 的 mode对象
 @param nowNumb 变更前表列个数
 @param item 要添加的列
 @return 是否成功
 */
- (BOOL)upToTableMode:(id)dataMode ListNumb:(NSUInteger)nowNumb AddItem:(NSArray *)item;

/**
 获取查询条数
 
 @param dataMode 继承 DBToParser 的 mode对象
 @return 返回查询数量
 */
- (NSInteger)resultModeNumb:(id)dataMode;

@end

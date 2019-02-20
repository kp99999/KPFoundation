//
//  DBToParser.h
//  ZYYObjcLib
//
//  Created by zyyuann on 15/8/11.
//  Copyright © 2015年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBToParser : NSObject

@property(nonatomic, strong)NSString *main_key;         // 主键（唯一标示）

/**
 初始化对象

 @param dic 初始化数据
 @return 对象
 */
- (id)initWithDictionary:(NSDictionary *)dic;

/**
 刷新对象

 @param i_dic 刷新数据
 */
- (void)refreshWithDictionary:(NSDictionary *)i_dic;

/**
 获取变量名列表

 @return 返回 列表
 */
- (NSArray *)parserKeys;

/**
 获取初始化时的数据

 @return 返回 Dictionary 数据类型
 */
- (NSDictionary *)parserToDictionary;

/**
 获取对象在数据库对应类型

 @param key 数据表的某一项
 @return 返回类型
 */
- (NSString *)getAttributesTypeWithKey:(NSString *)key;

/**
 获取对象对应变量名

 @param instance 对象
 @return 返回变量名
 */
- (NSString *)parserNameWithInstance:(id)instance;

/**
 是否有主键

 @return 是否有主键
 */
- (BOOL)isAutoMainKey;

/**
 获取子类名（用于表名）

 @return 返回 String 类名称
 */
- (NSString *)parserClassString;

#pragma mark 外部实现类
/**
 获取数据库名称 (可以由子类重写，否则返回默认数据库名)
 
 @return 返回 String 数据库名称
 */
- (NSString *)getDBName;

/**
 获取类名 子类继承实现

 @return 返回类名
 */
- (Class)parserClass;

/**
 获取查询语句 子类继承实现

 @return 语句
 */
- (NSString *)getSqlList;

/**
 是否需要主键 子类继承实现（默认 NO）

 @return 返回结果
 */
- (BOOL)isSetPrimaryKey;

@end

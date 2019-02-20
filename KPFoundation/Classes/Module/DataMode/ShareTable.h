//
//  ShareTable.h
//  ZYYObjcLib
//
//  Created by zyyuann on 15/4/18.
//  Copyright © 2015年 ZYY. All rights reserved.
////    通用数据库表

#import <KPFoundation/DBToParser.h>

typedef void (^ShareFinish)(BOOL isSec);     // 网络返回

@interface ShareTable : DBToParser

- (void)updateModeData:(void(^)(BOOL isSec))finish;
- (void)resultComMainKey:(void(^)(NSArray *arr))finish;

// mode 数据库
@property(nonatomic, strong)NSString *valve;            // 值
@property NSInteger time;             // 时间
@property(nonatomic, strong)NSString *describe;         // 描述
@property(nonatomic, strong)NSString *alternate;        // 扩展字段

@end

//
//  JsonToParser.h
//  ZYYObjcLib
//
//  Created by zyyuann on 16/1/16.
//  Copyright © 2016年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonToParser : NSObject

@property (nonatomic, readonly)NSError *error;
@property (nonatomic, readonly)id otherMess;       // 可以是提示信息（NSString）、可以是数组（NSArray）
@property (readonly)BOOL isNetWork;       // 是否有网络
@property (readonly)BOOL isOpenNetWork;       // 是否有开启网络访问权限
@property (readonly)BOOL isTimeOut;       // 是否请求超时

- (id)initWithJsonData:(id)data Error:(NSError *)err;

#pragma mark - 外部实现类
- (Class)parserClass:(NSString *)key;

@end

//
//  NetWorkManage.h
//  LIb_Shop
//
//  Created by zyy_pro on 14-7-7.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KPFoundation/NetWorkPublic.h>


/// 写个数组的子类，实现线程安全
@interface NSKSafeMutableArray : NSMutableArray

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end



typedef void (^BSLocal)(BOOL isLocal);     // 本地返回

@interface NetWorkManage : NSObject

+ (NetWorkManage *)Share;

/**
 为每个请求生成一个本地id

 @return request id
 */
- (int64_t)getRequestId;

/**
 post请求，优先级中
 
 @param interfaceURL 请求URL
 @param modelClass 报文体model
 @param localDo 本地存在，先返回本地报文
 @param completionDo 请求回调
 */
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass FromLocal:(BSLocal)localDo Completion:(BSNetWork)completionDo;
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo;

// 上传文件
- (void)upFileURL:(NSString *)url PostData:(id)upData Header:(NSDictionary *)headerDic FileData:(NSData *)fData Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Model:(Class)mClass Completion:(BSNetWork)completionDo;


@end

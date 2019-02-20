//
//  NetWorkManage.h
//  LIb_Shop
//
//  Created by zyy_pro on 14-7-7.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//  

#import <Foundation/Foundation.h>

#import <KPFoundation/NetWorkPublic.h>

typedef void (^BSLocal)(BOOL isLocal);     // 本地返回

@interface NetWorkManage : NSObject

+ (NetWorkManage *)Share;

/**
 为每个请求生成一个本地id

 @return request id
 */
- (int64_t)getRequestId;

/**
 post请求，优先级最高 (会把其它未request的请求都卡住)

 @param interfaceURL 请求URL
 @param modelClass 报文体model
 @param completionDo 请求回调
 */
- (void)requestInstantURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass Completion:(BSNetWork)completionDo;
- (void)requestInstantURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo;

/**
 get请求，优先级最高 (会把其它未request的请求都卡住)

 @param interfaceURL 请求URL
 @param modelClass 报文体model
 @param completionDo 请求回调
 */
- (void)requestInstantGetURL:(NSString *)interfaceURL Header:(NSDictionary *)headerDic Model:(Class)modelClass Completion:(BSNetWork)completionDo;

/**
 post请求，优先级中

 @param interfaceURL 请求URL
 @param modelClass 报文体model
 @param localDo 本地存在，先返回本地报文
 @param completionDo 请求回调
 */
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass FromLocal:(BSLocal)localDo Completion:(BSNetWork)completionDo;
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo;

/**
 下载图片

 @param url 图片URL
 @param isLocal 是否本地优先
 @param completionDo 请求回调
 */
- (void)downLocalURL:(NSString *)url LocalFrist:(BOOL)isLocal Completion:(BSNetWork)completionDo;

/**
 本地优先下载图片

 @param url 图片URL
 @param completionDo 请求回调
 */
- (void)downLocalURL:(NSString *)url Completion:(BSNetWork)completionDo;

/**
 文件下载

 @param url 文件URL
 @param fPath 存储文件夹名
 @param fileName 存储文件名
 @param completionDo 请求回调
 */
- (void)downFileURL:(NSString *)url SaveFolderPath:(NSString *)fPath FileName:(NSString *)fileName Completion:(BSNetWork)completionDo;

// 上传文件
- (void)upFileURL:(NSString *)url PostData:(id)upData Header:(NSDictionary *)headerDic FileData:(NSData *)fData Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Model:(Class)mClass Completion:(BSNetWork)completionDo;


/**
 清空下载链接

 @param onlyImage 是否只清空图片
 */
- (void)clearNetworkLink:(BOOL)onlyImage;


@end

//
//  NetworkRequest.h
//  CCBShop
//
//  Created by zyy_pro on 14-7-14.
//  Copyright (c) 2014年 CCB. All rights reserved.
//  重写 AFHTTPSessionManager

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

#import <KPFoundation/NetWorkPublic.h>

typedef NS_ENUM (NSInteger,RequestStatus)  {
    RequestNone = 0,
    RequestInNetWork ,           // 请求已经在网络上了
    RequestFinish ,           // 请求已完成
    RequestCancel ,           // 请求已取消
    RequestErr          // 请求出错
};

typedef NS_ENUM (NSInteger,RequestType)  {
    RequestFree = 0,
    RequestInterface ,           // 接口请求
    RequestImage ,              // 图片请求
    RequestFile                 // 文件请求
};

@interface NetworkRequest : AFURLSessionManager

- (instancetype)initWithURLString:(NSString *)urlStr RequestType:(RequestType)rType;

- (void)setClassParse:(Class)t_class;

- (void)GETJsonHeader:(NSDictionary *)headerDic
              success:(BSNetWork)success
              failure:(void (^)(NSError *error))failure;

- (void)POSTJsonParameters:(id)parameters
                    header:(NSDictionary *)headerDic
                   success:(BSNetWork)success
                   failure:(void (^)(NSError *error))failure;

- (void)POSTJsonParameters:(id)parameters
                    header:(NSDictionary *)headerDic
                  progress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                   success:(BSNetWork)success
                   failure:(void (^)(NSError *error))failure;

// 上传文件
- (void)POSTUpFileParameters:(id)parameters
                      header:(NSDictionary *)headerDic
   constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                    progress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                     success:(BSNetWork)success
                     failure:(void (^)(NSError *error))failure;

- (void)GETImageProgress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                 success:(BSNetWork)success
                 failure:(void (^)(NSError *error))failure;

- (void)GETDownFileProgress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                 folderPath:(NSString *)fPath
                   fileName:(NSString *)fName
                    success:(BSNetWork)success
                    failure:(void (^)(NSError *error))failure;


- (void)startRequest;
- (void)cancelConnection;
- (RequestStatus)getNowRequestStatus;

- (BOOL)detectionInUrl:(NSString *)url;       // 检测url是否存在

@end

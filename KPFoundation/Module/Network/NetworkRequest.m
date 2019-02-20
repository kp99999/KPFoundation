//
//  NetworkRequest.m
//  CCBShop
//
//  Created by zyy_pro on 14-7-14.
//  Copyright (c) 2014年 CCB. All rights reserved.
//

#import "NetworkRequest.h"
#import "SecurityPolicy.h"

#import "KPPublicDefine.h"

#import "FileToUse.h"

#define TimeoutIntervalRequest          15

@interface NetworkRequest(){
    
    RequestStatus requestStatus;
    
    NSString *requestURL;         // 请求接口 ｜｜ 请求图片地址
    
    NSURLSessionDataTask *requestTask;
    
    NSURLSessionDownloadTask *downTask;
    
    AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
    
    Class jsonMode;
}

@end
/////////////////////////////////////////

@implementation NetworkRequest

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //TODO set the default HTTP headers
    
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                           diskCapacity:150 * 1024 * 1024
                                                               diskPath:@"com.alamofire.imagedownloader"];;
    
    return configuration;
}

- (instancetype)initWithURLString:(NSString *)urlStr RequestType:(RequestType)rType{
    if (!urlStr) {
        return nil;
    }
    
    jsonMode = nil;
    
    requestTask = nil;
    downTask = nil;
    requestSerializer = nil;
    
    requestStatus = RequestNone;
    
    requestURL = urlStr;
    
    NSURLSessionConfiguration *defaultConfiguration = nil;
    if (rType == RequestImage) {
        defaultConfiguration = [self.class defaultURLSessionConfiguration];
    }
    
    self = [super initWithSessionConfiguration:defaultConfiguration];
    if (!self) {
        return nil;
    }
    
    if (rType == RequestInterface) {
        requestSerializer = [AFJSONRequestSerializer serializer];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }else if (rType == RequestImage){
        self.responseSerializer = [AFImageResponseSerializer serializer];
    }
    
    self.securityPolicy.validatesDomainName = NO;
    self.securityPolicy.allowInvalidCertificates = YES;
    
    return self;
}

- (void)setClassParse:(Class)t_class{
    jsonMode = t_class;
}

- (void)GETJsonHeader:(NSDictionary *)headerDic
              success:(BSNetWork)success
              failure:(void (^)(NSError *error))failure{
    [self dataTaskWithHTTPMethod:@"GET" URLString:requestURL Parameters:nil Header:headerDic UploadProgress:nil DownloadProgress:nil Success:success Failure:failure];
}

- (void)POSTJsonParameters:(id)parameters
                    header:(NSDictionary *)headerDic
                   success:(BSNetWork)success
                   failure:(void (^)(NSError *error))failure{
    [self POSTJsonParameters:parameters header:headerDic progress:nil success:success failure:failure];
}

- (void)POSTJsonParameters:(id)parameters
                    header:(NSDictionary *)headerDic
                  progress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                   success:(BSNetWork)success
                   failure:(void (^)(NSError *error))failure{
    
    [self dataTaskWithHTTPMethod:@"POST" URLString:requestURL Parameters:parameters Header:headerDic UploadProgress:nil DownloadProgress:downloadProgress Success:success Failure:failure];
    
}

// 上传文件
- (void)POSTUpFileParameters:(id)parameters
                      header:(NSDictionary *)headerDic
   constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                    progress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                     success:(BSNetWork)success
                     failure:(void (^)(NSError *error))failure{
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    if (parameters && [parameters isKindOfClass:[NSString class]]) {
        request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:requestURL parameters:nil constructingBodyWithBlock:block error:&serializationError];
        
        [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    }else if(parameters && [parameters isKindOfClass:[NSDictionary class]]){
        request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:requestURL parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    }else{
        request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:requestURL parameters:nil constructingBodyWithBlock:block error:&serializationError];
    }
    
    
    if (headerDic && request) {
        NSArray *allKeys = [headerDic allKeys];
        for (NSInteger i = 0; allKeys && i < [allKeys count]; i++) {
            [request setValue:headerDic[allKeys[i]] forHTTPHeaderField:allKeys[i]];
        }
    }
    
    if (serializationError) {
        requestStatus = RequestErr;
        
        if (failure) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
        
    }else{
        
        if (headerDic) {
            NSArray *allKeys = [headerDic allKeys];
            for (NSInteger i = 0; allKeys && i < [allKeys count]; i++) {
                [request setValue:headerDic[allKeys[i]] forHTTPHeaderField:allKeys[i]];
            }
        }
        
        [request setTimeoutInterval:TimeoutIntervalRequest];
        
        requestTask = [self uploadTaskWithStreamedRequest:request progress:downloadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
            NSLog(@"file_response = %@",responseObject);
            if (error) {
                requestStatus = RequestErr;
                if (failure) {
                    failure(error);
                }
            } else {
                requestStatus = RequestFinish;
                if (success) {
                    success(responseObject);
                }
            }
        }];
        
    }
}

- (void)dataTaskWithHTTPMethod:(NSString *)method
                     URLString:(NSString *)URLString
                    Parameters:(id)parameters
                        Header:(NSDictionary *)headerDic
                UploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
              DownloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                       Success:(BSNetWork)success
                       Failure:(void (^)(NSError *))failure{
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    if (parameters && [parameters isKindOfClass:[NSString class]]) {
        request = [requestSerializer requestWithMethod:method URLString:requestURL parameters:nil error:&serializationError];
        
        [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        request = [requestSerializer requestWithMethod:method URLString:requestURL parameters:parameters error:&serializationError];
    }
    
    if (serializationError) {
        requestStatus = RequestErr;
        
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
    }else{
        
        if (headerDic) {
            NSArray *allKeys = [headerDic allKeys];
            for (NSInteger i = 0; allKeys && i < [allKeys count]; i++) {
                [request setValue:headerDic[allKeys[i]] forHTTPHeaderField:allKeys[i]];
            }
        }
        
        [request setTimeoutInterval:TimeoutIntervalRequest];
        
        requestTask = [self dataTaskWithRequest:request
                                 uploadProgress:uploadProgress
                               downloadProgress:downloadProgress
                              completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                  NSLog(@"response = %@",responseObject);
                                  if (error) {
                                      requestStatus = RequestErr;
                                      if (failure) {
                                          failure(error);
                                      }
                                  } else {
                                      requestStatus = RequestFinish;
                                      if (success) {
                                          success(responseObject);
                                      }
                                  }
                              }];
    }
}

- (void)GETImageProgress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                 success:(BSNetWork)success
                 failure:(void (^)(NSError *error))failure{
    
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    requestTask = [self dataTaskWithRequest:request
                             uploadProgress:nil
                           downloadProgress:downloadProgress
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                              
                              if (error) {
                                  requestStatus = RequestErr;
                                  if (failure) {
                                      failure(error);
                                  }
                              }else{
                                  requestStatus = RequestFinish;
                                  if (success) {
                                      success(responseObject);
                                  }
                              }
                          }
                   ];
}

- (void)GETDownFileProgress:(void (^)(NSProgress *downloadProgress)) downloadProgress
                 folderPath:(NSString *)fPath
                   fileName:(NSString *)fName
                    success:(BSNetWork)success
                    failure:(void (^)(NSError *error))failure{
    
    if (!(fPath && fName)) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"文件路径或文件名为空" code:-1111 userInfo:nil];
            failure(error);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    __block NSURL *loadFileURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    loadFileURL = [loadFileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@" ,fPath ,fName]];
    // NSData *loadFileData = [NSData dataWithContentsOfURL:loadFileURL];
    
    downTask = [self downloadTaskWithRequest:request progress:downloadProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return loadFileURL;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            requestStatus = RequestErr;
            if (failure) {
                failure(error);
            }
        }else{
            requestStatus = RequestFinish;
            if (success) {
                success(nil);
            }
        }
    }];
    
//    if (loadFileData) {
//        @try {
//            downTask = [self downloadTaskWithResumeData:loadFileData progress:downloadProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                return loadFileURL;
//            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//                if (error) {
//                    requestStatus = RequestErr;
//                    if (failure) {
//                        failure(error);
//                    }
//                    
//                    [[FileToUse Share] deleteFolderName:fPath FileName:fName];
//                    
//                }else{
//                    requestStatus = RequestFinish;
//                    if (success) {
//                        success(nil);
//                    }
//                }
//            }];
//            
//        }
//        @catch (NSException *exception) {
//            NSLog(@" ***** 文件下载故障:%@ __ 本地数据断点有误 *****",exception);
//            
//            [[FileToUse Share] deleteFolderName:fPath FileName:fName];
//            
//            downTask = [self downloadTaskWithRequest:request progress:downloadProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                
//                return loadFileURL;
//                
//            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//                if (error) {
//                    requestStatus = RequestErr;
//                    if (failure) {
//                        failure(error);
//                    }
//                }else{
//                    requestStatus = RequestFinish;
//                    if (success) {
//                        success(nil);
//                    }
//                }
//            }];
//        }
//        @finally {
//            必然执行
//        }
//        
//        
//    }else{
//        
//    }

}


/////////////////////////////////////////////

// toBugBox是否需要弹出框报错提醒，theData返回数据
//- (void)handleBackData:(BOOL)toBugBox InterfaceData:(NSData *)theData Times:(NSInteger)nowTimes{
//    if (nowTimes > 2) {
//        return;
//    }
//
//    id bizData = nil;
//
//    if (theData) {
//        NSString *responseStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
//        NSLog(@"HttpResponseBody %@",responseStr);
//        if (responseStr) {
//            NSRange ranges = [responseStr rangeOfString:@"Code"];
//            if (ranges.length > 0){
//                NSError *jsError = nil;
//                id jsonDic = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableLeaves error:&jsError];
//                if (jsError || jsonDic == nil){
//                    if (toBugBox)
//                        [WaitBox AddAlertView:@"服务器返回json数据格式有误"];
//                }else{
//                    jsonDic = [DefaultManage StandardToJson:jsonDic];
//                    // 头部处理
//                    [self headDataHandle:jsonDic];
//                    // 内容处理
//                    id bizJson = [jsonDic objectForKey:@"bizData"];
//                    if (backToSecurity) {
//                        if ([bizJson isKindOfClass:[NSString class]]) {
//                            NSData *AESData = [SecurityPolicy DecryptAES:bizJson BackType:1];
//                            if (AESData) {
//                                id jsonAESDic = [NSJSONSerialization JSONObjectWithData:AESData options:NSJSONReadingMutableLeaves error:&jsError];
//                                if (jsError || jsonAESDic == nil){
//                                    if (toBugBox)
//                                        [WaitBox AddAlertView:@"服务器返回json数据格式有误"];
//                                }else{
//                                    bizData = jsonAESDic;
//                                }
//                            }
//                        }
//                    }else{
//                        bizData = bizJson;
//                    }
//                }
//            }else{
//                if (toBugBox)
//                    [self errorMatch:2 ErrorInfo:responseStr ErrorInterface:nil];   //服务器出错匹配
//            }
//        }
//    }
//
//    if (bizData) {
//        if (nowTimes == 1 && toSaveLocal){
//            if ([bizData isKindOfClass:[NSString class]] && [bizData length] < 2){
//                [self handleBackData:NO InterfaceData:[[FileToManager fileDo] operatingReadFile:requestStr ReadType:2 Authority:self] Times:++nowTimes];
//                return;
//            }
//            else
//                [[FileToManager fileDo] operatingWriteFile:requestStr WriteType:2 NeedData:theData Authority:self];
//        }
//    }else{
//        if (nowTimes == 1 && toSaveLocal) {
//            [self handleBackData:NO InterfaceData:[[FileToManager fileDo] operatingReadFile:requestStr ReadType:2 Authority:self] Times:++nowTimes];
//            return;
//        }
//    }
//
//    if (completionDo){
//        completionDo(bizData);
//        completionDo = nil;
//    }
//}


#pragma mark - 外部请求
// 开始发请求
- (void)startRequest{
    if (requestStatus == RequestNone) {
        if (requestTask) {
            [requestTask resume];
        }else if (downTask){
            [downTask resume];
        }
        
        
        requestStatus = RequestInNetWork;
    }
}

// 取消链接
- (void)cancelConnection{
    if (requestTask) {
        [requestTask cancel];
        requestTask = nil;
    }
    if (downTask) {
        [downTask cancel];
        downTask = nil;
    }
    requestStatus = RequestCancel;
    
}

- (RequestStatus)getNowRequestStatus{
    return requestStatus;
}

// 检测url是否存在
- (BOOL)detectionInUrl:(NSString *)url{
    if (url && [url isEqualToString:requestURL]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 出错处理
// 错误匹配 （1：系统错误。2:服务器错误）
//- (void)errorMatch:(NSInteger)errorType ErrorInfo:(NSString *)errorStr ErrorInterface:(NSString *)errInter{
//    NSString *outMessage = nil;
//    if (errorStr == nil)
//        outMessage = @"没有错误信息，可能接口返回空";
//    else{
//        NSLog(@"wbFailed__:%@",errorStr);
//        if (errorType == 1) {
//            NSDictionary *errDir = [errorMessage objectForKey:@"SystemError"];
//            outMessage = [errDir objectForKey:errorStr];
//        }else if(errorType == 2){
//
//            NSDictionary *errDir = [errorMessage objectForKey:@"ServerError"];
//            NSEnumerator *keys = [errDir keyEnumerator];
//            for (NSString *key in keys) {
//                NSRange ranges = [errorStr rangeOfString:key];
//                if (ranges.length > 0) {
//                    outMessage = [errDir objectForKey:key];
//                    break;
//                }
//            }
//        }
//    }
//
//    if (outMessage == nil)
//        outMessage = @"亲，您的环境不给力，请稍后再试";
//
//}

@end

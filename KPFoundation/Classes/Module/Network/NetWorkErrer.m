////
////  NetWorkErrer.m
////  ZYYObjcLib
////
////  Created by zyyuann on 15/12/31.
////  Copyright © 2015年 ZYY. All rights reserved.
////
//
//#import "NetWorkErrer.h"
//
//@implementation NetWorkErrer
//
//@end
//
////
////  NetworkRequest.m
////  CCBShop
////
////  Created by zyy_pro on 14-7-14.
////  Copyright (c) 2014年 CCB. All rights reserved.
////
//
//#import "NetworkRequest.h"
//#import "SecurityPolicy.h"
//
//#define TimeoutIntervalRequest          60
//
//@interface NetworkRequest(){
//    NSInteger nowPriority;        // 表示链接优先级。1：linkInitiative，，2：linkPassive，，3：linkImage
//    UIView *toWaitView;              // 等待视图
//    BOOL isInNetWork;               // 请求是否已经在网络上了
//    BOOL isFinish;        // 是否完成
//    BOOL needSecurity;          // 是否需要加密上传数据报文
//    BOOL toSaveLocal;           // 是否本地刘副本
//    void(^completionDo)(id);
//    NSString *requestStr;         // 请求接口 ｜｜ 请求图片地址
//    NSURLConnection *requestConnection;
//    
//    id baseData;                    // 请求信息
//    NSMutableData *receivedData;       // 返回数据
//    NSDictionary *errorMessage;
//    
//    BOOL backToSecurity;          // 是否需要解密下载数据报文
//}
//
//@end
///////////////////////////////////////////
//
//@implementation NetworkRequest
//
//- (id)initInterface:(NSString *)interface Priority:(NSInteger)thePri BaseData:(NSDictionary *)dicData ToWait:(UIView *)waitView ToSecurity:(BOOL)isSecurity ToSave:(BOOL)isSave ErrerInfo:(NSDictionary *)eDic Completion:(void(^)(id))com
//{
//    if (dicData == nil || interface == nil)
//        return nil;
//    
//    needSecurity = isSecurity;
//    toSaveLocal = isSave;
//    nowPriority = thePri;
//    toWaitView = waitView;
//    baseData = [dicData copy];
//    requestStr = interface;
//    errorMessage = eDic;
//    completionDo = nil;
//    if (com) {
//        completionDo = [com copy];
//    }
//    
//    // 对低优先级的，先从本地读，并返回
//    if (nowPriority == 2 && toSaveLocal)
//        [self handleBackData:NO InterfaceData:[[FileToManager fileDo] operatingReadFile:requestStr ReadType:2 Authority:self] Times:2];
//    
//    self = [super init];
//    if (self) {
//        [self initAll];
//    }
//    return self;
//}
//
//- (id)initImage:(NSString *)url Completion:(void(^)(id))com{
//    if (url == nil || [url length] < 5)
//        return nil;
//    
//    NSData *imageData = [[FileToManager fileDo] operatingReadFile:url ReadType:1 Authority:self];
//    if (imageData) {
//        id images = [UIImage imageWithData:imageData];
//        if (com)
//            com(images);
//        
//        return nil;
//    }
//    
//    nowPriority = 3;
//    toWaitView = nil;
//    baseData = nil;
//    requestStr = url;
//    errorMessage = nil;
//    completionDo = nil;
//    if (com) {
//        completionDo = [com copy];
//    }
//    
//    self = [super init];
//    if (self) {
//        [self initAll];
//    }
//    return self;
//}
//
//- (void)initAll{
//    requestConnection = nil;
//    isInNetWork = NO;
//    isFinish = NO;
//    
//    if (errorMessage) {
//        NSArray *secArr = [errorMessage objectForKey:@"NeedSecurity"];
//        for (NSInteger i = 0; secArr && i < [secArr count]; i++) {
//            if ([[secArr objectAtIndex:i] isEqualToString:requestStr]) {
//                backToSecurity = YES;
//                break;
//            }
//        }
//    }
//}
//
///////////////////////////////////////////////
//
//// toBugBox是否需要弹出框报错提醒，theData返回数据
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
//
//// 头部处理
//- (void)headDataHandle:(id)headData{
//    if (headData && [headData isKindOfClass:[NSDictionary class]]){
//        if ([[headData objectForKey:@"isEncryption"]isEqualToString:@"1"])
//            backToSecurity = YES;
//        else
//            backToSecurity = NO;
//        
//        if ([requestStr isEqualToString:@"M0000001"])
//            [[B2CUse B2cShare:self] initInterfaceRequest:headData];
//    }
//    
//}
//
//#pragma mark - 外部请求
//// 开始发请求
//- (void)startPostRequest{
//    
//    if (nowPriority == 1 || nowPriority == 2) {
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:MainURL]
//                                                                    cachePolicy: NSURLRequestReloadIgnoringCacheData      // 不缓存
//                                                                timeoutInterval: TimeoutIntervalRequest];
//        
//        NSMutableDictionary *info = [[NSMutableDictionary alloc]initWithCapacity:4];
//        
//        
//        if (requestStr && [requestStr length] > 0)
//            [info setValue:requestStr forKey:@"tranCode"];
//        
//        if (baseData)
//            [info setValue:baseData forKey:@"bizData"];
//        else
//            [info setValue:@"" forKey:@"bizData"];
//        
//        [info setValue:[[B2CUse B2cShare:self] backRequestTimestamp] forKey:@"requestTimestamp"];
//        [info setValue:[[B2CUse B2cShare:self] backSerialNo] forKey:@"serialNo"];
//        [info setValue:[[B2CUse B2cShare:self] backAppId] forKey:@"appId"];
//        [info setValue:[[B2CUse B2cShare:self] backMac] forKey:@"Mac"];
//        [info setValue:@"0" forKey:@"isEncryption"];
//        [info setValue:[[B2CUse B2cShare:self] backVersion] forKey:@"Version"];
//        [info setValue:[[B2CUse B2cShare:self] backUserID] forKey:@"userId"];
//        
//        NSString *postStr = [DefaultManage DicTransformJSON:info AppendString:nil];
//        //postStr = @"{\"tranCode\":\"M0020001\"}";// stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        //        postStr = [@"json_data=" stringByAppendingString:postStr];
//        NSData *postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//        [request setHTTPMethod:@"POST"];
//        [request setHTTPBody:postData];
//        
//        //[request setValue: [NSString stringWithFormat:@"%ld",[postData length]] forHTTPHeaderField:@"Content-Length"];
//        //[request setValue: @"charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//        
//        
//        requestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//        
//    }else if (nowPriority == 3){
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
//                                                                    cachePolicy: NSURLRequestReloadIgnoringCacheData      // 不缓存
//                                                                timeoutInterval: TimeoutIntervalRequest];
//        requestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    }
//    
//    if(requestConnection){
//        receivedData = [[NSMutableData alloc]init];
//        [receivedData setLength:0];
//        [requestConnection start];
//        isInNetWork = YES;
//    }
//    
//}
//
//- (void)startGetRequest{
//    if (nowPriority == 1 || nowPriority == 2) {
//        NSString *requestUrl = [[NSString stringWithFormat:@"%@{\"tranCode\":\"%@\"}",MainURL,requestStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"requestUrl=%@",requestUrl);
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:requestUrl]
//                                                                    cachePolicy: NSURLRequestReloadIgnoringCacheData      // 不缓存
//                                                                timeoutInterval: TimeoutIntervalRequest];
//        
//        NSMutableDictionary *info = [[NSMutableDictionary alloc]initWithCapacity:4];
//        if (baseData)
//            [info setValue:baseData forKey:@"bizData"];
//        
//        //  ???????????????????   继续追加头部
//        
//        //NSString *postStr = [DefaultManage DicTransformJSON:info AppendString:nil];
//        //NSData *postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//        
//        //[request setHTTPMethod: @"POST"];
//        [request setHTTPMethod:@"GET"];
//        //        [request setHTTPBody:postData];
//        //    [urlRequest setValue: IPADDRESS forHTTPHeaderField:@"Host"];
//        //    [urlRequest setValue: postLength forHTTPHeaderField:@"Content-Length"];
//        //    [urlRequest setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        requestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//        
//        //        NSDictionary *takeData = [[networkLinkH objectAtIndex:nowLinkH] objectForKey:@"takeData"];
//        //        if (takeData && [takeData count] > 0) {
//        //            NSEnumerator *keys = [takeData keyEnumerator];
//        //            for (NSObject *key in keys) {
//        //                NSString* value = [takeData objectForKey:key];
//        //                if (value && key) {
//        //                    //value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        //                    [setUrl appendFormat:@"&%@=%@",key,value];
//        //                }
//        //            }
//        //
//        //        }
//        //
//        
//        //        if (postDic && [postDic count] > 0) {
//        //            NSEnumerator *keys = [postDic keyEnumerator];
//        //            for (NSObject *key in keys) {
//        //                NSString* tmpValue = (NSString*)[postDic objectForKey:key];
//        //                if (tmpValue && key) {
//        //                    //[requestToForm setPostValue:tmpValue forKey:(NSString*)key];
//        //                    //[requestToForm addRequestHeader:(NSString*)key value:(NSString*)tmpValue];
//        //                }
//        //            }
//        //        }
//    }else if (nowPriority == 3){
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
//                                                                    cachePolicy: NSURLRequestReloadIgnoringCacheData      // 不缓存
//                                                                timeoutInterval: TimeoutIntervalRequest];
//        requestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    }
//    
//    if(requestConnection){
//        receivedData = [[NSMutableData alloc]init];
//        [receivedData setLength:0];
//        [requestConnection start];
//        isInNetWork = YES;
//    }
//}
//
//// 取消链接
//- (void)cancelConnection{
//    isInNetWork = NO;
//    if (isFinish) {
//        return;
//    }
//    isFinish = YES;
//    if (requestConnection) {
//        [requestConnection cancel];
//        requestConnection = nil;
//    }
//    
//    if (receivedData) {
//        receivedData = nil;
//    }
//}
//
//// 链接是否在网络上
//- (BOOL)isInConnection{
//    return isInNetWork;
//}
//// 请求是否结束
//- (BOOL)isFinishConnection{
//    return isFinish;
//}
//
//// 返回等待视图
//- (UIView *)superWaitView{
//    return toWaitView;
//}
//
//#pragma mark - 出错处理
//// 错误匹配 （1：系统错误。2:服务器错误）
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
//    [WaitBox AddAlertView:outMessage];
//}
//
//#pragma mark - NSURLConnectionDelegate,NSURLConnectionDataDelegate 协议方法
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    
//    if (receivedData){
//        if (nowPriority == 1) {
//            [self handleBackData:YES InterfaceData:receivedData Times:1];
//        }else if (nowPriority == 2){
//            [self handleBackData:NO InterfaceData:receivedData Times:1];
//        }else if (nowPriority == 3){
//            
//            UIImage *images = [UIImage imageWithData:receivedData];
//            if (images) {
//                [[FileToManager fileDo] operatingWriteFile:requestStr WriteType:1 NeedData:receivedData Authority:self];
//                if (completionDo) {
//                    completionDo(images);
//                    completionDo = nil;
//                }
//            }
//        }
//    }
//    
//    [self cancelConnection];
//    
//    if (completionDo){
//        completionDo(nil);
//        completionDo = nil;
//    }
//    
//    if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(networkEnd)]) {
//        [self.requestDelegate networkEnd];
//    }
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    NSLog(@"Http_error:%@_%ld", error.localizedDescription,(long)error.code);
//    
//    if (nowPriority == 1) {
//        if (toSaveLocal) {
//            NSData *localData = [[FileToManager fileDo] operatingReadFile:requestStr ReadType:2 Authority:self];
//            if (localData)
//                [self handleBackData:NO InterfaceData:localData Times:2];
//            
//        }
//        //[self errorMatch:1 ErrorInfo:[NSString stringWithFormat:@"%ld",(long)error.code] ErrorInterface:nil];   //网络、系统出错匹配
//    }
//    
//    [self cancelConnection];
//    
//    if (completionDo){
//        completionDo(nil);
//        completionDo = nil;
//    }
//    
//    if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(networkEnd)]) {
//        [self.requestDelegate networkEnd];
//    }
//}
//
//// 中间数据
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    [receivedData appendData:data];
//}
//
//// 重置进度指示
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse{
//    [receivedData setLength:0];
//}
//
//@end

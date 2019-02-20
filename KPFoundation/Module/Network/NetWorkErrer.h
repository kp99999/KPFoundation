//
//  NetWorkErrer.h
//  ZYYObjcLib
//
//  Created by zyyuann on 15/12/31.
//  Copyright © 2015年 ZYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkErrer : NSObject

////  生产：@"http://buy.ccb.com/mobile/method?queryParam"
////  测试：@"http://128.128.99.162:10001/mobile/method?queryParam"
////  挡板（get）：@"http://128.128.99.162:10001/webapi/WebTransServlet?json_data="
////  挡板（post）：@"http://128.128.99.162:10001/webapi/WebTransServlet"
//#define MainURL     @"http://128.128.99.162:10001/webapi/WebApiServlet"
////#define MainURL     @"http://128.128.99.162:10001/webapi/WebApiServlet"
//
//@protocol NetworkRequestDelegate <NSObject>
//
//@optional
//
//- (void)networkEnd;
//
//@end
//
//@interface NetworkRequest : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
//
//@property(strong, nonatomic)id<NetworkRequestDelegate> requestDelegate;
//
//- (id)initInterface:(NSString *)interface Priority:(NSInteger)thePri BaseData:(NSDictionary *)dicData ToWait:(UIView *)waitView ToSecurity:(BOOL)isSecurity ToSave:(BOOL)isSave ErrerInfo:(NSDictionary *)eDic Completion:(void(^)(id))com;
//
//- (id)initImage:(NSString *)url Completion:(void(^)(id))com;
//
//- (void)startPostRequest;
//- (void)startGetRequest;
//- (void)cancelConnection;
//- (BOOL)isInConnection;         // 链接是否在网络上
//- (BOOL)isFinishConnection;     // 请求是否结束
//
//- (UIView *)superWaitView;

@end

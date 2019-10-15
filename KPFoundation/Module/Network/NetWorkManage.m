//
//  NetWorkManage.m
//  LIb_Shop
//
//  Created by zyy_pro on 14-7-7.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//
//  该网络模块包含了：优先级判断，对1级的链接，都会把图片链接（3级）全部取消，然后进行请求
//  同时在网络上的请求数：对优先级1、2的，则各有1条在网络上；图片资源则同时在线是5条
//

#import "NetWorkManage.h"
#import "FileToControll.h"

#import "NetworkRequest.h"
#import "CheckNetwork.h"

#import "KPPublicDefine.h"
#import "GeneralUse.h"
#import "JsonToParser.h"

#import "FileUse.h"
#import "FileUseOther.h"

#import "DeviceBaseData.h"

// 优先级 对应在网络请求数
#define MaxLink        15
#define MaxPriorityMiddleLink        5
#define MaxPriorityLowLink        10

typedef NS_ENUM (NSInteger,PriorityType)  {
    PriorityNone = 0,
    PriorityHeight ,           // 优先级 高
    PriorityMiddle ,           // 优先级 中
    PriorityLow          // 优先级 底
};

@interface NetWorkManage() {
    
    // 网络连接信息（网络只有一条链接）
    NSMutableArray *linkInitiative;   // 优先级：1（最高）
    NSMutableArray *linkPassive;   // 优先级：2
    NSMutableArray *linkImage;   // 优先级：3
    
    PriorityType whichPriority;        // 表示当前优先级。1：linkInitiative，，2：linkPassive，，3：linkImage
    
    BOOL needSecurity;          // 是否需要加密上传数据报文
    BOOL toSaveLocal;           // 是否本地刘副本
    
    id baseData;                    // 请求信息
    
    BOOL backToSecurity;          // 是否需要解密下载数据报文
    
    // f每个请求都有一个 request id
    int64_t requestBase;
    int64_t requestSequence;
}
@end


@implementation NetWorkManage

+ (NetWorkManage *)Share{
    static dispatch_once_t once;
    static NetWorkManage * singleton;
    dispatch_once(&once, ^{ singleton = [[NetWorkManage alloc] init]; });
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

// 初始化
- (void)initData{
    
    linkInitiative = [[NSMutableArray alloc]init];
    linkPassive = [[NSMutableArray alloc]init];
    linkImage = [[NSMutableArray alloc]init];
    
    requestBase = 0;
    requestSequence = 0;
    if ([[DeviceBaseData deviceUUID] length] > 8) {
        requestBase = strtoull([[[DeviceBaseData deviceUUID] substringFromIndex:[[DeviceBaseData deviceUUID] length] - 8] UTF8String],0,16) & 0xFFFFFFFF;
    }
}

#pragma mark - 内部调用
// 清除请求链接：theGrade清理级别，0表示全部
- (void)clearLinkGrade:(NSInteger)theGrade{
    if (theGrade == 0) {
        for (NSInteger i = 0; linkInitiative && i < [linkInitiative count]; i++) {
            [(NetworkRequest *)[linkInitiative objectAtIndex:i] cancelConnection];
        }
        [linkInitiative removeAllObjects];
        
        for (NSInteger i = 0; linkPassive && i < [linkPassive count]; i++) {
            [(NetworkRequest *)[linkInitiative objectAtIndex:i] cancelConnection];
        }
        [linkPassive removeAllObjects];
        for (NSInteger i = 0; linkImage && i < [linkImage count]; i++) {
            [(NetworkRequest *)[linkImage objectAtIndex:i] cancelConnection];
        }
        [linkImage removeAllObjects];
        
        return;
    }
    
    NSMutableArray *linkArr = nil;
    switch (theGrade) {
        case 1:
            linkArr = linkInitiative;
            break;
        case 2:
            linkArr = linkPassive;
            break;
        case 3:
            linkArr = linkImage;
            break;
        default:
            break;
    }
    
    for (NSInteger x = 0; linkArr && x < [linkArr count]; x++) {
        [(NetworkRequest *)[linkArr objectAtIndex:x] cancelConnection];
    }
    if (linkArr) {
        [linkArr removeAllObjects];
    }
}

- (void)clearUnuseLink{
    
    @synchronized ([NetWorkManage Share]) {
        for (NSInteger grade = 1; grade < 4; grade++) {
            NSMutableArray *linkArr = nil;
            switch (grade) {
                case 1:
                    linkArr = linkInitiative;
                    break;
                case 2:
                    linkArr = linkPassive;
                    break;
                case 3:
                    linkArr = linkImage;
                    break;
                default:
                    break;
            }
            
            for (NSInteger i = 0; linkArr && i < [linkArr count]; i++) {
                if (linkArr.count > i) {
                    RequestStatus requestStatus = [(NetworkRequest *)[linkArr objectAtIndex:i] getNowRequestStatus];
                    if (requestStatus == RequestFinish || requestStatus == RequestCancel || requestStatus == RequestErr) {
                        if (linkArr.count > i) {
                            [linkArr removeObjectAtIndex:i];
                            i--;
                        }
                    }
                }
                
            }
        }
    }
}

- (void)requestToNetwork{
    NSInteger nowLinkNumb = 0;
    
    // 发优先级最高   接口请求   只能有一条
    for (NSInteger i = 0; linkInitiative && i < [linkInitiative count]; i++) {
        if ([(NetworkRequest *)[linkInitiative objectAtIndex:i] getNowRequestStatus] == RequestInNetWork) {
            nowLinkNumb++;
            return;
            
        }else if([(NetworkRequest *)[linkInitiative objectAtIndex:i] getNowRequestStatus] == RequestNone) {
            [(NetworkRequest *)[linkInitiative objectAtIndex:i] startRequest];
            nowLinkNumb++;
            return;
            
        }
    }
    
    NSInteger middleLinkNumb = 0;
    for (NSInteger i = 0; linkPassive && i < [linkPassive count]; i++) {
        if ([(NetworkRequest *)[linkPassive objectAtIndex:i] getNowRequestStatus] == RequestInNetWork) {
            middleLinkNumb++;
            nowLinkNumb++;
        }
    }
    for (NSInteger i = 0; linkPassive && i < [linkPassive count]; i++) {
        if (nowLinkNumb >= MaxLink) {
            return;
        }
        
        if ([(NetworkRequest *)[linkPassive objectAtIndex:i] getNowRequestStatus] == RequestNone) {
            [(NetworkRequest *)[linkPassive objectAtIndex:i] startRequest];
            middleLinkNumb++;
            nowLinkNumb++;
        }
        if (middleLinkNumb >= MaxPriorityLowLink) {
            break;
        }
    }
    
    NSInteger lowLinkNumb = 0;
    for (NSInteger i = 0; linkImage && i < [linkImage count]; i++) {
        if ([(NetworkRequest *)[linkImage objectAtIndex:i] getNowRequestStatus] == RequestInNetWork) {
            lowLinkNumb++;
            nowLinkNumb++;
        }
    }
    for (NSInteger i = 0; linkImage && i < [linkImage count]; i++) {
        if (nowLinkNumb >= MaxLink) {
            return;
        }
        
        if ([(NetworkRequest *)[linkImage objectAtIndex:i] getNowRequestStatus] == RequestNone) {
            [(NetworkRequest *)[linkImage objectAtIndex:i] startRequest];
            lowLinkNumb++;
            nowLinkNumb++;
        }
        if (lowLinkNumb >= MaxPriorityLowLink) {
            break;
        }
    }
}

// 初始化请求
- (void)requestInterface:(NSString *)interface PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)mClass Priority:(NSInteger)thePri Post:(BOOL)isPost Completion:(void(^)(id))completionJson{
    [self clearUnuseLink];
    if (!completionJson) {
        return;
    }
    
    if ([self asynchronousLocalModel:mClass Completion:completionJson]) {
        return;
    }
    
    if (!interface) {
        completionJson(nil);
        return;
    } else if (mClass && ![mClass isSubclassOfClass:[JsonToParser class]]) {
        completionJson(nil);
        return;
    }
    
    __block BOOL isToNetwork = YES;
    
    NetworkRequest *link = [[NetworkRequest alloc]initWithURLString:interface RequestType:RequestInterface];
    if (link) {
        
        [link setClassParse:mClass];
        if (isPost) {
            [link POSTJsonParameters:upData header:headerDic success:^(id secData) {
                
                if (mClass) {
                    // 预处理数据
                    completionJson([[mClass alloc] initWithJsonData:secData Error:nil]);
                } else {
                    completionJson(secData);
                }
                
                [self requestToNetwork];
                
            } failure:^(NSError *error) {
                
                if (mClass) {
                    // 预处理错误
                    completionJson([[mClass alloc] initWithJsonData:nil Error:error]);
                } else {
                    completionJson(error);
                }
                
                isToNetwork = NO;
                [self requestToNetwork];
                
            }];
        }else{
            [link GETJsonHeader:headerDic success:^(id secData) {
                
                if (mClass) {
                    // 预处理数据
                    completionJson([[mClass alloc] initWithJsonData:secData Error:nil]);
                } else {
                    completionJson(secData);
                }
                
                [self requestToNetwork];
                
            } failure:^(NSError *error) {
                
                if (mClass) {
                    // 预处理错误
                    completionJson([[mClass alloc] initWithJsonData:nil Error:error]);
                } else {
                    completionJson(error);
                }
                
                isToNetwork = NO;
                [self requestToNetwork];
                
            }];
        }
        
        if (thePri == 1) {
            [linkInitiative addObject:link];
        }else if (thePri == 2) {
            [linkPassive addObject:link];
        }
    }
    
    if (isToNetwork) {
        [self requestToNetwork];
    }
}

#pragma mark - 外部接口
- (int64_t)getRequestId {
    @synchronized (self) {
        requestSequence++;
        int64_t requestTime = [NSDate date].timeIntervalSince1970 * 10;
        return (requestBase  << 32) | (requestTime & 0xFFFFFFF0) | (requestSequence & 0xF);
    }
}


- (void)requestInstantURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass Completion:(BSNetWork)completionDo {
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:modelClass Priority:PriorityHeight Post:YES Completion:completionDo];
}
- (void)requestInstantURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo {
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:nil Priority:PriorityHeight Post:YES Completion:completionDo];
}

- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass FromLocal:(BSLocal)localDo Completion:(BSNetWork)completionDo {
    // 先获取本地数据
//    // 对低优先级的，先从本地读，并返回
//    if (nowPriority == 2 && toSaveLocal)
//        [self handleBackData:NO InterfaceData:[[FileToManager fileDo] operatingReadFile:requestStr ReadType:2 Authority:self] Times:2];
    
    // 再请求
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:modelClass Priority:PriorityMiddle Post:YES Completion:completionDo];
}
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo {
    if ([interfaceURL hasPrefix:@"local://"]) {
        completionDo([FileUseOther GetAsynchronousJsonLocal:[[interfaceURL stringByReplacingOccurrencesOfString:@"local://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] BundleResource:nil]);
        return;
    }
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:nil Priority:PriorityMiddle Post:YES Completion:completionDo];
}

- (void)requestInstantGetURL:(NSString *)interfaceURL Header:(NSDictionary *)headerDic Model:(Class)modelClass Completion:(BSNetWork)completionDo {
    
    [self requestInterface:interfaceURL PostData:nil Header:headerDic Model:modelClass Priority:PriorityHeight Post:NO Completion:completionDo];
}

- (void)downLocalURL:(NSString *)url Completion:(BSNetWork)completionDo {
    [self downLocalURL:url LocalFrist:YES Completion:completionDo];
}
- (void)downLocalURL:(NSString *)url LocalFrist:(BOOL)isLocal Completion:(BSNetWork)completionDo {
    [self clearUnuseLink];
    
    if (!completionDo) {
        return;
    }
    
    if (url == nil || [url length] < 1) {
        completionDo(nil);
        return;
    }
    
    if (isLocal) {
        NSData *iData = [[FileUse Share] readFolderName:@"image_important" FileName:url];
        
        if (iData) {
            completionDo([UIImage imageWithData:iData]);
            
            return ;
        }
    }
    
    // 去重复
    for (NetworkRequest *oneLink in linkImage) {
        if ([oneLink detectionInUrl:url]) {
            completionDo(nil);
            return;
        }
    }
    
    __block BOOL isToNetwork = YES;
    
    NetworkRequest *link_3 = [[NetworkRequest alloc]initWithURLString:url RequestType:RequestImage];
    if (link_3) {
        
        [link_3 setClassParse:nil];
        
        [link_3 GETImageProgress:nil success:^(id secData) {
            // 预处理数据
            
            if (secData && [secData isKindOfClass:[UIImage class]]) {
                NSData *imageData = UIImagePNGRepresentation(secData);
                
                [[FileUse Share] writeData:imageData FolderName:FolderName_Clean30_ResourceFile FileName:url];
            }
            
            completionDo(secData);
            
            [self requestToNetwork];
        } failure:^(NSError *error) {
            completionDo(nil);
            
            isToNetwork = NO;
            [self requestToNetwork];
        }];
        
        [linkImage addObject:link_3];
    }
    
    if (isToNetwork) {
        [self requestToNetwork];
    }

}

// URL下载文件 优先中
- (void)downFileURL:(NSString *)url SaveFolderPath:(NSString *)fPath FileName:(NSString *)fileName Completion:(BSNetWork)completionDo {
    [self clearUnuseLink];
    
    if (url == nil || [url length] < 5 || completionDo == nil) {
        if (completionDo) {
            completionDo(@"url有误");
        }
        return;
    }
    
    if (!(fPath && fileName)) {
        completionDo(@"文件名不能为空");
        return;
    }
    
    __block BOOL isToNetwork = YES;
    
    NetworkRequest *link_2 = [[NetworkRequest alloc]initWithURLString:url RequestType:RequestFile];
    if (link_2) {
        
        [link_2 setClassParse:nil];
        
        [link_2 GETDownFileProgress:nil folderPath:fPath fileName:fileName success:^(id data) {
            completionDo(data);
            
            [self requestToNetwork];
        } failure:^(NSError *error) {
            completionDo(error);
            
            isToNetwork = NO;
            [self requestToNetwork];
        }];
        
        [linkPassive addObject:link_2];
    }
    
    if (isToNetwork) {
        [self requestToNetwork];
    }
}

// 上传文件
- (void)upFileURL:(NSString *)url PostData:(id)upData Header:(NSDictionary *)headerDic FileData:(NSData *)fData Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Model:(Class)mClass Completion:(BSNetWork)completionDo {
    
    [self clearUnuseLink];
    if (!completionDo) {
        return;
    }
    
    if (!(url && fData)) {
        completionDo(nil);
        return;
    }
    
    if ([self asynchronousLocalModel:mClass Completion:completionDo]) {
        return;
    }
    
    __block BOOL isToNetwork = YES;
    __block NSData *flieData = fData;
    
    NetworkRequest *link = [[NetworkRequest alloc]initWithURLString:url RequestType:RequestInterface];
    if (link) {
        
        [link setClassParse:mClass];
        
        [link POSTUpFileParameters:upData header:headerDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:flieData name:name fileName:fileName mimeType:mimeType];
            
        } progress:nil success:^(id secData) {
            
            if (mClass) {
                // 预处理数据
                completionDo([[mClass alloc] initWithJsonData:secData Error:nil]);
            } else {
                completionDo(secData);
            }
            
            [self requestToNetwork];
            
        } failure:^(NSError *error) {
            
            if (mClass) {
                // 预处理错误
                completionDo([[mClass alloc] initWithJsonData:nil Error:error]);
            } else {
                completionDo(error);
            }
            
            isToNetwork = NO;
            [self requestToNetwork];
        }];
        
        [linkPassive addObject:link];
    }
    
    if (isToNetwork) {
        [self requestToNetwork];
    }

}

// 重新初始化 networkLink 数据
- (void)clearNetworkLink:(BOOL)onlyImage{
    
    if (onlyImage) {
        [self clearLinkGrade:3];
    }else{
        [self clearLinkGrade:0];
    }
}

////////////////////////////////////////////////////////////
// 测试用：读本地数据
- (BOOL)asynchronousLocalModel:(Class)mClass Completion:(void(^)(id))completionJSONObject{
    if (!mClass) {
        return NO;
    }
#ifdef NetWorkOpenLocal

    if (NetWorkOpenLocal) {
        
        NSData *content = [[FileUse Share] getFileLocal:NSStringFromClass(mClass) BundleResource:NetWorkBundleName];
        completionJSONObject([[mClass alloc] initWithJsonData:content Error:nil]);
        
        return YES;
    }else{
        return NO;
    }
    
#else
    
    return NO;
    
#endif

}

@end

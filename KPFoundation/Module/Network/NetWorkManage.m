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


@interface NSKSafeMutableArray() {
    CFMutableArrayRef _array;
}

@end

@implementation NSKSafeMutableArray

- (id)init {
    self = [super init];
    if (self) {
        _array = CFArrayCreateMutable(kCFAllocatorDefault, 10, &kCFTypeArrayCallBacks);
    }
    return self;
}

// 获取可变数组数量
- (NSUInteger)count {
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        result = CFArrayGetCount(_array);
    });
    return result;
}

// 获取第N个位置的对象
- (id)objectAtIndex:(NSUInteger)index {
    __block id result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        result = index < count ? CFArrayGetValueAtIndex(_array, index) : nil;
    });
    return result;
}

// 插入对象至指定位置
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    __block NSUInteger blockIndex = index;
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(_array);
        blockIndex = blockIndex > count ? count : blockIndex;
        
        CFArrayInsertValueAtIndex(_array, index, (__bridge const void *)anObject);
    });
}

// 删除指定位置上的对象
- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        //NSLog(@"_array_count = %d    -------    i = %d",count,index);
        if (index < count) {
            CFArrayRemoveValueAtIndex(_array, index);
        }
    });
}

// 添加对象
- (void)addObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        CFArrayAppendValue(_array, (__bridge const void *)anObject);
    });
}

// 删除最后一个对象
- (void)removeLastObject {
    dispatch_barrier_async(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        if (count > 0) {
            CFArrayRemoveValueAtIndex(_array, count-1);
        }
    });
}

// 替换指定位置的对象
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_barrier_async(self.syncQueue, ^{
        if (!anObject) {
            return;
        }
        
        NSUInteger count = CFArrayGetCount(_array);
        if (index >= count) {
            return;
        }
        
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    });
}

// 懒加载
- (dispatch_queue_t)syncQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.kong.NSKSafeMutableArray", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}
@end

typedef NS_ENUM (NSInteger,PriorityType)  {
    PriorityNone = 0,
    PriorityHeight ,           // 优先级 高
    PriorityMiddle ,           // 优先级 中
    PriorityLow          // 优先级 底
};

@interface NetWorkManage() {
    
    // 网络连接信息（网络只有一条链接）
    NSKSafeMutableArray *linkPassive;   // 优先级：2
    
    BOOL needSecurity;          // 是否需要加密上传数据报文
    BOOL toSaveLocal;           // 是否本地刘副本
    
    id baseData;                    // 请求信息
    
    BOOL backToSecurity;          // 是否需要解密下载数据报文
    
    // f每个请求都有一个 request id
    int64_t requestBase;
    int64_t requestSequence;
    
    dispatch_queue_t queue;
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
    linkPassive = [[NSKSafeMutableArray alloc] init];
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    requestBase = 0;
    requestSequence = 0;
    if ([[DeviceBaseData deviceUUID] length] > 8) {
        requestBase = strtoull([[[DeviceBaseData deviceUUID] substringFromIndex:[[DeviceBaseData deviceUUID] length] - 8] UTF8String],0,16) & 0xFFFFFFFF;
    }
}

#pragma mark - 内部调用
- (void)clearUnuseLink{
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; linkPassive && i < linkPassive.count; i++) {
            if (linkPassive.count > i) {
                RequestStatus requestStatus = [(NetworkRequest *)[linkPassive objectAtIndex:i] getNowRequestStatus];
                if (requestStatus == RequestFinish || requestStatus == RequestCancel || requestStatus == RequestErr) {
                    if (linkPassive.count > i) {
                        //NSLog(@"linkPassive_count = %d    -------    i = %d",linkPassive.count,i);
                        [linkPassive removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
        }
    });
}

- (void)requestToNetwork{
    
    dispatch_async(queue, ^{
        NSInteger nowLinkNumb = 0;
        NSInteger middleLinkNumb = 0;
        for (NSInteger i = 0; linkPassive && i < linkPassive.count; i++) {
            if ([(NetworkRequest *)[linkPassive objectAtIndex:i] getNowRequestStatus] == RequestInNetWork) {
                middleLinkNumb++;
                nowLinkNumb++;
            }
        }
        for (NSInteger i = 0; linkPassive && i < linkPassive.count; i++) {
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
    });
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
        [linkPassive addObject:link];
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


- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Model:(Class)modelClass FromLocal:(BSLocal)localDo Completion:(BSNetWork)completionDo {
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:modelClass Priority:PriorityMiddle Post:YES Completion:completionDo];
}
- (void)requestLocalURL:(NSString *)interfaceURL PostData:(id)upData Header:(NSDictionary *)headerDic Completion:(BSNetWork)completionDo {
    [self requestInterface:interfaceURL PostData:upData Header:headerDic Model:nil Priority:PriorityMiddle Post:YES Completion:completionDo];
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

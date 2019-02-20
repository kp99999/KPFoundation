//
//  CheckNetwork.m
//  ZYYObjcLib
//
//  Created by zyyuann on 15/12/29.
//  Copyright © 2015年 ZYY. All rights reserved.
//  检查网络，并对网络的变化而做出变更

#import <AFNetworking/AFNetworking.h>

#import "CheckNetwork.h"

@interface CheckNetwork(){
    NetworkStatusType networkStatus;
    
    NSMutableArray *delegateArr;
}

@end

@implementation CheckNetwork

static bool isInit = NO;     // 单例初始化判断（该类不允许被继承，初始化多个）

+ (CheckNetwork *)Share
{
    static dispatch_once_t predicate;
    static CheckNetwork *checkNetworkInstance = nil;
    
    dispatch_once(&predicate, ^{
        isInit = YES;
        checkNetworkInstance = [[CheckNetwork alloc] init];
        isInit = NO;
    });
    return checkNetworkInstance;
}

-(instancetype)init{
    
    if (isInit) {
        self = [super init];
        if (self){
            delegateArr = [[NSMutableArray alloc]init];
            networkStatus = NetworkStatusTypeFree;
            
            [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                if (status == AFNetworkReachabilityStatusNotReachable){
                    networkStatus = NetworkStatusTypeNot;
                }else if (status == AFNetworkReachabilityStatusUnknown){
                    networkStatus = NetworkStatusTypeFree;
                }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
                    networkStatus = NetworkStatusTypeWWAN;
                }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
                    networkStatus = NetworkStatusTypeWiFi;
                }
                
                [self notiToDelegate];
            }];
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        }
        return self;
    }
    
    NSAssert(isInit , @"该类不允许被继承，初始化多个");
    
    return nil;
}

// 回调给观察者
- (void)notiToDelegate{
    for (NSInteger i = 0; i < [delegateArr count]; i++) {
        if ([delegateArr[i] respondsToSelector:@selector(changeNetworkStatus:)]) {
            [delegateArr[i] changeNetworkStatus:networkStatus];
        }
    }
}

- (NetworkStatusType)getNetworkType{
    
    return networkStatus;
}

- (void)addObserverWithDelegate:(id<CheckNetworkObserverDelegate>)delegate{
    if (delegate && [delegate respondsToSelector:@selector(changeNetworkStatus:)]) {
        
        if (![delegateArr containsObject:delegate]) {
            [delegateArr addObject:delegate];
        }
    }
}

- (void)releaseObserverWithDelegate:(id<CheckNetworkObserverDelegate>)delegate{
    if (delegate) {
        [delegateArr removeObject:delegate];
    }
}

@end

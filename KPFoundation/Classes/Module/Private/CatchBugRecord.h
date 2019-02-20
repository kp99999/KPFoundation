//
//  CatchBugRecord.h
//  testCCBMonitor
//
//  Created by zyy_pro on 14-10-20.
//  Copyright (c) 2014年 zyy_pro. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CatchBugRecordDelegate <NSObject>

@optional

- (void)backBugErrorNo:(NSString *)errorNo ErrorDesc:(NSString *)errorDesc OtherError:(NSString *)otherError;

@end

@interface CatchBugRecord : NSObject

+ (CatchBugRecord *)Bug;

- (void)openToBugDelegate:(id<CatchBugRecordDelegate>)delegate Authority:(NSString *)authStr;

@end

//
//  AnimTimeManege.h
//  CostumeChain
//
//  Created by ecpmac on 13-12-5.
//
//  一般用于动画场景渐进效果

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define DelectTime      0.1

@interface AnimTimeManege : NSObject

+ (AnimTimeManege *)AnimTime;

- (CGFloat)recordTime:(CGFloat)times;       // 记录此次动画时间
- (CGFloat)insertRecordTime:(CGFloat)times FromTime:(CGFloat)fromTime;       // 在fromTime时间点插入times动画
- (CGFloat)getDelayTime;

@end

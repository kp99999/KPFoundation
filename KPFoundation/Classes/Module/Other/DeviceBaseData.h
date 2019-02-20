//
//  DeviceBaseData.h
//  Pods
//
//  Created by gzkp on 2017/7/17.
//
//

#import <Foundation/Foundation.h>

@interface DeviceBaseData : NSObject

#pragma mark - 设备唯一标识 uuid
+ (NSString *)deviceUUID;

#pragma mark - 获取设备的型号
+ (NSString *)deviceModel;

#pragma mark - 取设备名称
+ (NSString *)deviceName;

// 手机别名
+ (NSString *)userPhoneName;

#pragma mark - 获取系统版本号
+ (NSString *)sysVersion;

#pragma mark - 获取App的build版本
+ (NSString *)appBuildVersion;

#pragma mark - 获取App的名称
+ (NSString *)appName;

#pragma mark - 获取设备的型号
+ (NSString *)deviceModelName;

#pragma mark - 获取工程名称
+ (NSString *)appProdectsName;

#pragma mark - 屏幕分辨率
+ (NSString *)devicePix;

#pragma mark - 屏幕尺寸
+ (NSString *)screenSize;

#pragma mark - 手机序列号
+ (NSString *)indentifierNumber;



@end

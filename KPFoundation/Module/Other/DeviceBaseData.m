//
//  DeviceBaseData.m
//  Pods
//
//  Created by gzkp on 2017/7/17.
//
//

#import <KPFoundation/DeviceBaseData.h>
#import <sys/utsname.h>


@implementation DeviceBaseData

#pragma mark - 设备唯一标识 uuid
+ (NSString *)deviceUUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
}

#pragma mark - 获取设备的型号
+ (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
    
}

#pragma mark - 取设备名称
+ (NSString *)deviceName
{
    return [[UIDevice currentDevice] name];
}
+ (NSString *)userPhoneName {
    return [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] name]];
}

#pragma mark - 获取系统版本号
+ (NSString *)sysVersion
{
    return [[UIDevice currentDevice] systemVersion];
    
}

#pragma mark - 获取App的build版本
+ (NSString *)appBuildVersion
{
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString* currentVersion = [infoDic valueForKey:@"CFBundleShortVersionString"];
    currentVersion = [currentVersion stringByAppendingFormat:@".%@",  [infoDic objectForKey:@"CFBundleVersion"]];
    
    return currentVersion;
    
}

#pragma mark - 获取App的名称
+ (NSString *)appName
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return  [infoDic objectForKey:@"CFBundleDisplayName"];
    
}

#pragma mark - 获取App的名称
+ (NSString *)appProdectsName
{
    NSString *String;
    
    String=[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    
    return String;
}

+ (NSString *)devicePix {
    NSString *String;
    
    CGFloat scale_screen = [[UIScreen mainScreen]scale];
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGSize size=rect.size;
    CGFloat width=size.width;
    CGFloat height=size.height;
    
    String=[NSString stringWithFormat:@"%0.0f*%0.0f",height*scale_screen,width*scale_screen];
    return String;
}
+ (NSString *)screenSize {
    NSString *String;
    
    CGRect rect=[[UIScreen mainScreen]bounds];
    CGSize size=rect.size;
    CGFloat width=size.width;
    CGFloat height=size.height;
    
    String=[NSString stringWithFormat:@"%0.0f*%0.0f",height,width];
    
    return String;
}

+ (NSString *)indentifierNumber {
    return [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice]identifierForVendor] UUIDString]];
}

#pragma mark - 获取设备的型号
+ (NSString *)deviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([deviceModel isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"]) return @"Verizon iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"] ||
        [deviceModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,2"] ||
        [deviceModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"] ||
        [deviceModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,4"] ||
        [deviceModel isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    if ([deviceModel isEqualToString:@"iPod7,1"]) return @"iPod Touch 6G";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"]) return @"iPad 2 (32nm)";
    if ([deviceModel isEqualToString:@"iPad2,5"]) return @"iPad mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"]) return @"iPad mini (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"]) return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"]) return @"iPad 3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"]) return @"iPad 3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"]) return @"iPad 3(4G)";
    if ([deviceModel isEqualToString:@"iPad3,4"]) return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"]) return @"iPad 4 (4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"]) return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"]) return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"]) return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,4"] ||
        [deviceModel isEqualToString:@"iPad4,5"] ||
        [deviceModel isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"] ||
        [deviceModel isEqualToString:@"iPad4,8"] ||
        [deviceModel isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    
    if ([deviceModel isEqualToString:@"iPad5,1"]) return @"iPadmini4";
    if ([deviceModel isEqualToString:@"iPad5,2"]) return @"iPadmini4";
    if ([deviceModel isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    
    if ([deviceModel isEqualToString:@"iPad6,1"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,2"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,4"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,5"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,6"]) return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,7"] ||
        [deviceModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([deviceModel isEqualToString:@"iPad6,11"] ||
        [deviceModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([deviceModel isEqualToString:@"iPad7,1"] ||
        [deviceModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([deviceModel isEqualToString:@"iPad7,3"] ||
        [deviceModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    


    if ([deviceModel containsString:@","]) {
        
        if ([deviceModel containsString:@"iPad"]) {
            deviceModel = @"iPad";
            
        }else if ([deviceModel containsString:@"iPhone"]){
            deviceModel = @"iPhone";
            
        }else if ([deviceModel containsString:@"iPod"]){
            deviceModel = @"iPod";
            
        }
    }
    
    //------------------------------Samulitor-------------------------------------
    if ([deviceModel isEqualToString:@"i386"]) return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"]) return @"Simulator";
    
    
    return deviceModel;
}

@end

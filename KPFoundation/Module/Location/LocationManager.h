//
//  LocationManager.h
//  Pods
//
//  Created by 马光明 on 16/6/25.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef NS_ENUM(NSUInteger, LocationManagerLocationServiceStatus) {
    LocationManagerLocationServiceStatusDefault,               //默认状态
    LocationManagerLocationServiceStatusOK,                    //定位功能正常
    LocationManagerLocationServiceStatusUnknownError,          //未知错误
    LocationManagerLocationServiceStatusUnAvailable,           //定位功能关掉了
    LocationManagerLocationServiceStatusNoAuthorization,       //定位功能打开，但是用户不允许使用定位
    LocationManagerLocationServiceStatusNotDetermined          //用户还没做出是否要允许应用使用定位功能的决定，第一次安装应用的时候会提示用户做出是否允许使用定位功能的决定
};

typedef NS_ENUM(NSUInteger, LocationManagerLocationResult) {
    LocationManagerLocationResultDefault,              //默认状态
    LocationManagerLocationResultLocating,             //定位中
    LocationManagerLocationResultSuccess,              //定位成功
    LocationManagerLocationResultFail,                 //定位失败
};

@protocol LocationManagerDelegate <NSObject>

- (void)didUpdateLocations:(NSArray *)locations;
- (void)didFailWithError:(NSError *)error;
@end


@interface LocationManager : NSObject
@property (nonatomic, assign, readonly) LocationManagerLocationResult locationResult;
@property (nonatomic, assign,readonly) LocationManagerLocationServiceStatus locationStatus;
@property (nonatomic, copy, readonly) CLLocation *currentLocation;
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

+ (instancetype)sharedInstance;
-(void)appSetAlwaysBackgroudLocation:(BOOL)ON;
- (void)startLocation;
-(void)startMonitoringSignificantLocationChanges;
- (void)stopLocation;
- (void)restartLocation;


@end

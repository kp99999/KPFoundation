//
//  LocationManager.m
//  Pods
//
//  Created by 马光明 on 16/6/25.
//
//

#import "LocationManager.h"

#import <AFNetworking/AFNetworking.h>

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) LocationManagerLocationResult locationResult;
@property (nonatomic, assign, readwrite) LocationManagerLocationServiceStatus locationStatus;
@property (nonatomic, copy, readwrite) CLLocation *currentLocation;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property(nonatomic,assign) BOOL isAlwaysBackGroupLocation;

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskIdentifier;

@end
@implementation LocationManager

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static LocationManager *locationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[LocationManager alloc] init];
    });
    return locationManager;
}

#pragma mark - public methods
-(void)appSetAlwaysBackgroudLocation:(BOOL)ON{
    self.isAlwaysBackGroupLocation = ON;
}

- (void)startLocation
{
    if ([self checkLocationStatus]) {
        self.locationResult = LocationManagerLocationResultLocating;
        [self.locationManager startUpdatingLocation];
    } else {
        [self failedLocationWithResultType:LocationManagerLocationResultFail statusType:self.locationStatus];
    }
}

-(void)startMonitoringSignificantLocationChanges{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopLocation
{
    if ([self checkLocationStatus]) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)restartLocation
{
    [self stopLocation];
    [self startLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [manager.location copy];
    NSLog(@"Current location is %@", self.currentLocation);
    if (self.isAlwaysBackGroupLocation) {
        
        if ( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
        {
            [self endBackgroundUpdateTask];
        }
        else//后台定位
        {
            //假如上一次的上传操作尚未结束 则直接return
            if ( self.taskIdentifier != UIBackgroundTaskInvalid )
            {
                return;
            }
            
            [self beingBackgroundUpdateTask];
            
            //上传完成记得调用 [self endBackgroundUpdateTask];
        }
        
        
    }
    else{
        [self stopLocation];
    }
    if (_delegate  && [_delegate respondsToSelector:@selector(didUpdateLocations:)]) {
        [_delegate performSelector:@selector(didUpdateLocations:) withObject:locations];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //如果用户还没选择是否允许定位，则不认为是定位失败
    if (self.locationStatus == LocationManagerLocationServiceStatusNotDetermined) {
        return;
    }
    
    //如果正在定位中，那么也不会通知到外面
    if (self.locationResult == LocationManagerLocationResultLocating) {
        return;
    }
    self.locationStatus = LocationManagerLocationServiceStatusUnknownError;
    if (_delegate  && [_delegate respondsToSelector:@selector(didFailWithError:)]) {
        [_delegate performSelector:@selector(didFailWithError:) withObject:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationStatus = LocationManagerLocationServiceStatusOK;
        [self restartLocation];
    } else {
        if (self.locationStatus != LocationManagerLocationServiceStatusNotDetermined) {
            [self failedLocationWithResultType:LocationManagerLocationResultDefault statusType:LocationManagerLocationServiceStatusNoAuthorization];
        } else {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
                [self.locationManager requestWhenInUseAuthorization];  //弹出允许框
            }
            [self checkLocationStatus];
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark - private methods
- (void)failedLocationWithResultType:(LocationManagerLocationResult)result statusType:(LocationManagerLocationServiceStatus)status
{
    self.locationResult = result;
    self.locationStatus = status;
}

- (BOOL)checkLocationStatus;
{
    BOOL result = NO;
    BOOL serviceEnable = [self locationServiceEnabled];
    LocationManagerLocationServiceStatus authorizationStatus = [self locationServiceStatus];
    if (authorizationStatus == LocationManagerLocationServiceStatusOK && serviceEnable) {
        result = YES;
    }else if (authorizationStatus == LocationManagerLocationServiceStatusNotDetermined) {
        result = YES;
    }else{
        result = NO;
    }
    
    if (serviceEnable && result) {
        result = YES;
    }else{
        result = NO;
    }
    
    if (result == NO) {
        [self failedLocationWithResultType:LocationManagerLocationResultFail statusType:self.locationStatus];
    }
    
    return result;
}

- (BOOL)locationServiceEnabled
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationStatus = LocationManagerLocationServiceStatusOK;
        return YES;
    } else {
        self.locationStatus = LocationManagerLocationServiceStatusUnknownError;
        return NO;
    }
}

- (LocationManagerLocationServiceStatus)locationServiceStatus
{
    self.locationStatus = LocationManagerLocationServiceStatusUnknownError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                self.locationStatus = LocationManagerLocationServiceStatusNotDetermined;
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways :
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationStatus = LocationManagerLocationServiceStatusOK;
                break;
                
            case kCLAuthorizationStatusDenied:
                self.locationStatus = LocationManagerLocationServiceStatusNoAuthorization;
                break;
                
            default:
                break;
        }
    } else {
        self.locationStatus = LocationManagerLocationServiceStatusUnAvailable;
    }
    return self.locationStatus;
}




- (NSString *)titleWithPlacemark:(CLPlacemark *)mark
{
    NSString *title = @"";
    if([mark.addressDictionary objectForKey:@"State"]) {
        title=[NSString stringWithFormat:@"%@",[mark.addressDictionary objectForKey:@"State"]];
    }
    if(mark.subLocality) {
        title=[NSString stringWithFormat:@"%@%@",title,mark.subLocality];
    }
    if(mark.thoroughfare) {
        title=[NSString stringWithFormat:@"%@%@",title,mark.thoroughfare];
    }
    if ([mark.addressDictionary objectForKey:@"FormattedAddressLines"]) {
        NSArray *lines = [mark.addressDictionary objectForKey:@"FormattedAddressLines"];
        if ([lines isKindOfClass:[NSArray class]] && lines.count > 0) {
            NSString *line = lines[0];
            if (line.length > 0) {
                if ([line hasPrefix:@"中国"]) {
                    title = [line substringFromIndex:2];
                }
            }
        }
    }
    return title;
}

- (void)beingBackgroundUpdateTask
{
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    if ( self.taskIdentifier != UIBackgroundTaskInvalid )
    {
        [[UIApplication sharedApplication] endBackgroundTask: self.taskIdentifier];
        self.taskIdentifier = UIBackgroundTaskInvalid;
    }
}

#pragma mark - getters and setters
- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        [_locationManager requestAlwaysAuthorization];
#endif
        
        NSArray* backgroundModes = [[NSBundle mainBundle].infoDictionary objectForKey:@"UIBackgroundModes"];
        if( backgroundModes && [backgroundModes containsObject:@"location"]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
            [_locationManager setAllowsBackgroundLocationUpdates:YES];
#endif
            [_locationManager allowDeferredLocationUpdatesUntilTraveled:500 timeout:500];
        }
    }
    return _locationManager;
}

@end

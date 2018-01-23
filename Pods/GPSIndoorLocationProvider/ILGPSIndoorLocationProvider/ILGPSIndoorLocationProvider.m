#import "ILGPSIndoorLocationProvider.h"

@implementation ILGPSIndoorLocationProvider {
    CLLocationManager* locationManager;
    BOOL isStarted;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        isStarted = false;
    }
    return self;
}

- (BOOL) supportsFloor {
    return false;
}

- (void) start {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager startUpdatingLocation];
        isStarted = true;
    }
    else {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void) stop {
    [locationManager stopUpdatingLocation];
    isStarted = false;
}

- (BOOL) isStarted {
    return isStarted;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    ILIndoorLocation* indoorLocation = [[ILIndoorLocation alloc] init];
    indoorLocation.latitude = location.coordinate.latitude;
    indoorLocation.longitude = location.coordinate.longitude;
    indoorLocation.accuracy = location.horizontalAccuracy;
    indoorLocation.timestamp = location.timestamp;
    indoorLocation.providerName = [self getName];
    [self dispatchDidUpdateLocation:indoorLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self dispatchDidFailWithError:error];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            NSError* error = [NSError errorWithDomain:@"ILGPSIndoorLocationProvider" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Permission required"}];
            [self dispatchDidFailWithError:error];
        }
            break;
        default:{
            if (!isStarted) {
                [locationManager startUpdatingLocation];
                isStarted = true;
            }
        }
    }
}

@end

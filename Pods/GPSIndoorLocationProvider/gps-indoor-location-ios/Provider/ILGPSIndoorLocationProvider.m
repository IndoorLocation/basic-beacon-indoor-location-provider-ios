#import "ILGPSIndoorLocationProvider.h"

@interface ILGPSIndoorLocationProvider ()

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL shouldStart;

@end

@implementation ILGPSIndoorLocationProvider {
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        _isStarted = false;
        _shouldStart = false;
    }
    return self;
}

- (instancetype) initWith:(CLLocationManager*) locationManager {
    self = [super init];
    if (self) {
        _locationManager = locationManager;
        _locationManager.delegate = self;
        _isStarted = false;
        _shouldStart = false;
    }
    return self;
}

- (BOOL) supportsFloor {
    return false;
}

- (void) start {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startUpdating];
    }
    else {
        [self.locationManager requestWhenInUseAuthorization];
        self.shouldStart = true;
    }
}

- (void)startUpdating {
    [self.locationManager startUpdatingLocation];
    self.isStarted = true;
    self.shouldStart = false;
}

- (void) stop {
    [self.locationManager stopUpdatingLocation];
    self.isStarted = false;
}

- (BOOL) isStarted {
    return _isStarted;
}

- (BOOL) shouldStart {
    return _shouldStart;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    ILIndoorLocation* indoorLocation = [[ILIndoorLocation alloc] initWithProvider:self latitude:location.coordinate.latitude longitude:location.coordinate.longitude floor:nil];
    indoorLocation.accuracy = location.horizontalAccuracy;
    indoorLocation.timestamp = location.timestamp;
    [self dispatchDidUpdateLocation:indoorLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self dispatchDidFailWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
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
            if (self.shouldStart) {
                [self startUpdating];
            }
        }
    }
}

@end

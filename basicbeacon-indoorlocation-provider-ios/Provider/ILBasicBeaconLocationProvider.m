#import "ILBasicBeaconLocationProvider.h"
#import "ILLatLngFloor.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@implementation ILBasicBeaconLocationProvider {
    NSString* mapwizeApiKey;
    CLLocationManager* locationManager;
    ILGPSIndoorLocationProvider* gpsLocationProvider;
    ILIndoorLocation* lastGpsLocation;
    BOOL started;
    NSMutableDictionary<NSString*,ILLatLngFloor*>* locationByUniqId;
    NSMutableDictionary<NSString*, NSNumber*>* rssiMeanByUniqId;
    NSTimer* computeNearestBeaconTimer;
}
    
- (instancetype)initWithMapwizeApiKey:(NSString*) apiKey gpsIndoorLocationProvider:(ILGPSIndoorLocationProvider*) gpsIndoorLocationProvider {
    self = [super init];
    if (self) {
        mapwizeApiKey = apiKey;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        gpsLocationProvider = gpsIndoorLocationProvider;
        [gpsLocationProvider addDelegate:self];
        started = NO;
        locationByUniqId = [[NSMutableDictionary alloc] init];
        rssiMeanByUniqId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) start {
    
    if (!started) {
        [locationManager requestWhenInUseAuthorization];
        [gpsLocationProvider start];
        started = YES;
        computeNearestBeaconTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(computeNearestBeacon)
                                       userInfo:nil
                                        repeats:YES];
        [self dispatchDidStart];
    }
    
}
    
- (void) stop {
    
    if (started) {
        [gpsLocationProvider stop];
        started = NO;
        [computeNearestBeaconTimer invalidate];
        [self dispatchDidStop];
    }
    
}
    
- (BOOL) isStarted {
    return started;
}
    
- (BOOL) supportsFloor {
    return YES;
}

- (void) updateMonitoredRegionFromLocation:(ILIndoorLocation*) location {
    
    double latitudeMin = location.latitude - 0.005;
    double latitudeMax = location.latitude + 0.005;
    double longitudeMin = location.longitude - 0.005;
    double longitudeMax = location.longitude + 0.005;
    
    NSString* urlFormat = @"https://api.mapwize.io/v1/beacons/?api_key=%@&type=ibeacon&latitudeMin=%f&latitudeMax=%f&longitudeMin=%f&longitudeMax=%f";
    NSString* urlString = [NSString stringWithFormat:urlFormat, mapwizeApiKey, latitudeMin, latitudeMax, longitudeMin, longitudeMax];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSError *error = nil;
            NSArray* responseArray = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:0
                         error:&error];
            [self handleBeaconsData:responseArray];
        }
    }];
    [task resume];
    
}

- (void) handleBeaconsData:(NSArray*) responseArray {
    
    NSMutableSet* uuidsSet = [[NSMutableSet alloc] init];
    NSString* uniqIdFormat = @"%@-%@-%@";
    
    for (NSDictionary* beaconDictionary in responseArray) {
        NSDictionary* properties = beaconDictionary[@"properties"];
        NSString* uuid = properties[@"uuid"];
        NSNumber* major = properties[@"major"];
        NSNumber* minor = properties[@"minor"];
        
        NSDictionary* location = beaconDictionary[@"location"];
        NSNumber* latitude = location[@"lat"];
        NSNumber* longitude = location[@"lon"];
        NSNumber* floor = beaconDictionary[@"floor"];
        
        ILLatLngFloor* latLngFloor = [[ILLatLngFloor alloc] initWithLatitude:latitude longitude:longitude floor:floor];
        
        [uuidsSet addObject:uuid];
        
        NSString* uniqId = [NSString stringWithFormat:uniqIdFormat, uuid, major, minor];
        [locationByUniqId setObject:latLngFloor forKey:uniqId];
    }
    
    [self updateMonitoredUuids:uuidsSet];
    
}
    
- (void) updateMonitoredUuids:(NSSet<NSString*>*) uuids {
    NSSet* rangedRegions = locationManager.rangedRegions;
    for (CLRegion* region in rangedRegions) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    for (NSString* uuidString in uuids) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        CLBeaconRegion* region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuidString];
        [locationManager startRangingBeaconsInRegion:region];
    }
    
}
    
- (void) computeNearestBeacon {
    NSUInteger maxRssi = -2000;
    NSString* maxRssiUniqId;
    for (NSString* key in rssiMeanByUniqId) {
        NSUInteger rssi = rssiMeanByUniqId[key].integerValue;
        if (rssi > maxRssi) {
            maxRssi = rssi;
            maxRssiUniqId = key;
        }
    }
    
    ILLatLngFloor* latLngFloor = locationByUniqId[maxRssiUniqId];
    if (latLngFloor) {
        ILIndoorLocation* indoorLocation = [[ILIndoorLocation alloc] initWithProvider:self latitude:latLngFloor.latitude.doubleValue longitude:latLngFloor.longitude.doubleValue floor:latLngFloor.floor];
        [self dispatchDidUpdateLocation:indoorLocation];
    }
    
    [rssiMeanByUniqId removeAllObjects];
    
}
    
#pragma mark CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSString* uniqIdFormat = @"%@-%@-%@";
    if (beacons.count > 0) {
        CLBeacon* nearestBeacon = beacons[0];
        NSString* uuid = nearestBeacon.proximityUUID.UUIDString;
        NSNumber* major = nearestBeacon.major;
        NSNumber* minor = nearestBeacon.minor;
        NSString* uniqId = [NSString stringWithFormat:uniqIdFormat, uuid, major, minor];
        
        ILLatLngFloor* latLngFloor = locationByUniqId[uniqId];
        if (latLngFloor) {
            
            NSNumber* rssiNumber = rssiMeanByUniqId[uniqId];
            NSInteger rssi;
            if (!rssiNumber) {
                rssi = nearestBeacon.rssi;
            }
            else {
                rssi = rssiNumber.integerValue;
                rssi = (rssi + nearestBeacon.rssi) / 2;
            }
            
            rssiMeanByUniqId[uniqId] = [NSNumber numberWithInteger:rssi];

        }
        
    }
    
}
    
- (BOOL) distanceExceededBetween:(ILIndoorLocation*) lastLocation and:(ILIndoorLocation*) newLocation {
    int R = 6371;
    
    double latDistance = DEGREES_TO_RADIANS(newLocation.latitude - lastLocation.latitude);
    double lonDistance = DEGREES_TO_RADIANS(newLocation.longitude - lastLocation.longitude);
    double a = sin(latDistance/2) * sin(latDistance/2)
    + cos(DEGREES_TO_RADIANS(lastLocation.latitude)) * cos(DEGREES_TO_RADIANS(newLocation.latitude))
    * sin(lonDistance/2) * sin(lonDistance/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = R * c * 1000;
    
    if (distance > 500) {
        return YES;
    }
    
    return NO;
}
    
#pragma mark ILLocationProviderDelegate
    
- (void)provider:(ILIndoorLocationProvider *)provider didFailWithError:(NSError *)error {
    
}
    
- (void)provider:(ILIndoorLocationProvider *)provider didUpdateLocation:(ILIndoorLocation *)location {
    if (!lastGpsLocation || [self distanceExceededBetween:lastGpsLocation and:location]) {
        [self updateMonitoredRegionFromLocation:location];
    }
    lastGpsLocation = location;
}
    
- (void)providerDidStart:(ILIndoorLocationProvider *)provider {
    
}
    
- (void)providerDidStop:(ILIndoorLocationProvider *)provider {
    
}
    
@end

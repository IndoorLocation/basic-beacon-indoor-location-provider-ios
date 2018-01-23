#import <IndoorLocation/IndoorLocation.h>
#import <CoreLocation/CoreLocation.h>
#import "ILGPSIndoorLocationProvider.h"

@interface ILBasicBeaconLocationProvider : ILIndoorLocationProvider <CLLocationManagerDelegate, ILIndoorLocationProviderDelegate>
    
- (instancetype)initWithMapwizeApiKey:(NSString*) apiKey gpsIndoorLocationProvider:(ILGPSIndoorLocationProvider*) gpsIndoorLocationProvider;
    
@end

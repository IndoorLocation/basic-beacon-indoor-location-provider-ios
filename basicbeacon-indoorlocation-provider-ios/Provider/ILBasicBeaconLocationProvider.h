#import <CoreLocation/CoreLocation.h>
#import <GPSIndoorLocationProvider/ILGPSIndoorLocationProvider.h>

@interface ILBasicBeaconLocationProvider : ILIndoorLocationProvider <CLLocationManagerDelegate, ILIndoorLocationProviderDelegate>
    
- (instancetype)initWithMapwizeApiKey:(NSString*) apiKey gpsIndoorLocationProvider:(ILGPSIndoorLocationProvider*) gpsIndoorLocationProvider;
    
@end

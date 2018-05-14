#import <CoreLocation/CoreLocation.h>
#import <IndoorLocation/ILIndoorLocationProvider.h>
#import <IndoorLocation/ILIndoorLocationProviderDelegate.h>
#import <IndoorLocation/ILIndoorLocation.h>

@interface ILBasicBeaconLocationProvider : ILIndoorLocationProvider <CLLocationManagerDelegate, ILIndoorLocationProviderDelegate>
    
- (instancetype)initWithMapwizeApiKey:(NSString*) apiKey indoorLocationProvider:(ILIndoorLocationProvider*) locationProvider;
    
@end

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <IndoorLocation/IndoorLocation.h>

@interface ILGPSIndoorLocationProvider : ILIndoorLocationProvider <CLLocationManagerDelegate>

- (instancetype) initWith:(CLLocationManager*) locationManager;

@end

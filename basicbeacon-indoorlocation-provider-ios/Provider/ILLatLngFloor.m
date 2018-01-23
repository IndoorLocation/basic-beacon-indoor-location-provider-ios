#import "ILLatLngFloor.h"

@implementation ILLatLngFloor

- (instancetype) initWithLatitude:(NSNumber*) latitude longitude:(NSNumber*) longitude floor:(NSNumber*) floor{
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _floor = floor;
    }
    return self;
}
    
@end

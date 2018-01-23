#import <IndoorLocation/IndoorLocation.h>

@interface ILLatLngFloor : ILIndoorLocationProvider

@property (nonatomic, strong) NSNumber* latitude;
@property (nonatomic, strong) NSNumber* longitude;
@property (nonatomic, strong) NSNumber* floor;
    
- (instancetype) initWithLatitude:(NSNumber*) latitude longitude:(NSNumber*) longitude floor:(NSNumber*) floor;
    
@end

#import "ViewController.h"
#import "ILBasicBeaconLocationProvider.h"
#import "ILGPSIndoorLocationProvider.h"

@interface ViewController ()

@end

@implementation ViewController {
    
    MapwizePlugin* mapwizePlugin;
    ILBasicBeaconLocationProvider* basicBeaconProvider;
    ILGPSIndoorLocationProvider* gpsProvider;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapwizePlugin = [[MapwizePlugin alloc] initWith:_mglMapView options:[[MWZOptions alloc] init]];
    mapwizePlugin.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) mapwizePluginDidLoad:(MapwizePlugin *)mapwizePlugin {
    
    gpsProvider = [[ILGPSIndoorLocationProvider alloc] init];
    basicBeaconProvider = [[ILBasicBeaconLocationProvider alloc] initWithMapwizeApiKey:@"<NAVISENS KEY>" indoorLocationProvider:gpsProvider];
    [mapwizePlugin setIndoorLocationProvider:basicBeaconProvider];
    
}
    
@end

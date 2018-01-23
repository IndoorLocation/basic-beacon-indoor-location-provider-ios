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
    basicBeaconProvider = [[ILBasicBeaconLocationProvider alloc] initWithMapwizeApiKey:@"1f04d780dc30b774c0c10f53e3c7d4ea" gpsIndoorLocationProvider:gpsProvider];
    [mapwizePlugin setIndoorLocationProvider:basicBeaconProvider];
    
}
    
@end

//
//  ViewController.m
//  MTLocationDemo
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mapView, locateMeItem;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MTLocationManager sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [MTLocationManager sharedInstance].locationManager.distanceFilter = kCLDistanceFilterNone;
    [MTLocationManager sharedInstance].locationManager.headingFilter = 5;
    
    self.locateMeItem = [MTLocateMeBarButtonItem userTrackingBarButtonItemForMapView:self.mapView];
    [self.locateMeItem addTarget:self action:@selector(locateMe:) forControlEvents:UIControlEventTouchUpInside];
    self.locateMeItem.headingEnabled = YES;
    
    // Setup toolbar
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [self.view addSubview:toolbar];
    
    // Create array with Toolbar Items
    NSArray *toolbarItems = [NSArray arrayWithObject:self.locateMeItem];
    // Set toolbar items
    [toolbar setItems:toolbarItems animated:NO];
    
    [MTLocationManager sharedInstance].mapView = self.mapView;
}

- (void) locateMe:(id) sender {
    self.mapView.showsUserLocation = (self.mapView.showsUserLocation) ? NO : YES;
    [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[MTLocationManager sharedInstance] stopAllServices];
    [self.locateMeItem stopListeningToLocationUpdates];
    self.mapView.showsUserLocation = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTLocationManagerDidStopUpdatingHeading object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Resize the toolbar when device is rotated
    [toolbar setFrame:CGRectMake(0, 0, self.view.frame.size.height, 44)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set an initial map location
    MKCoordinateRegion zoomLocation;
    zoomLocation.center.latitude = 38.9101118;
    zoomLocation.center.longitude = -77.0363658;
    zoomLocation.span.latitudeDelta = 0.162872;
    zoomLocation.span.longitudeDelta = 0.109863;
    
    [self.mapView setRegion:zoomLocation animated:YES];
    [self.mapView setShowsUserLocation:YES];
    
    [self.locateMeItem startListeningToLocationUpdates];
    [self.locateMeItem setFrameForInterfaceOrientation:self.interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerDidStopUpdatingHeading:) name:kMTLocationManagerDidStopUpdatingHeading object:nil];
}

- (void)locationManagerDidStopUpdatingHeading:(NSNotification *)notification {
    //rotate map back to Identity-Transformation
    [self.mapView resetHeadingRotationAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

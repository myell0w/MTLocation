//
//  ViewController.h
//  MTLocationDemo
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MTLocation.h"

@interface ViewController : UIViewController {
    MKMapView *mapView;
    MTLocateMeBarButtonItem *locateMeItem;
    UIToolbar *toolbar;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MTLocateMeBarButtonItem *locateMeItem;
@end

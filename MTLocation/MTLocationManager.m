//
//  MTLocationManager.m
//
//  Created by Matthias Tretter on 06.02.11.
//  Copyright (c) 2009-2011  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "MTLocationManager.h"
#import "MTLocationDefines.h"
#import "MTLocationFunctions.h"
#import "MKMapView+MTLocation.h"
#import "MTTouchesMovedGestureRecognizer.h"


@interface MTLocationManager ()

// re-define as read/write
@property (nonatomic, strong, readwrite) CLLocation *lastKnownLocation;
@property (nonatomic, copy) mt_location_changed_block locationChangedBlock;

- (void)setActiveServicesForTrackingMode:(MTUserTrackingMode)trackingMode;

@end

@implementation MTLocationManager

@synthesize locationManager = locationManager_;
@synthesize lastKnownLocation = lastKnownLocation_;
@synthesize mapView = mapView_;
@synthesize displayHeadingCalibration = displayHeadingCalibration_;
@synthesize locationChangedBlock = locationChangedBlock_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)init {
    if ((self = [super init])) {
        locationManager_ = [[CLLocationManager alloc] init];
		locationManager_.delegate = self;
        displayHeadingCalibration_ = YES;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Location Service Methods
////////////////////////////////////////////////////////////////////////

- (void)setTrackingMode:(MTUserTrackingMode)trackingMode {
    [self setActiveServicesForTrackingMode:trackingMode];
}

- (void)stopAllServices {
	// Reset transform on map
    [self.mapView resetHeadingRotationAnimated:YES];
    [self.mapView hideHeadingAngleView];
    
    if (MTLocationUsesNewAPIs()) {
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
    }
    
	// stop location-services
	[self.locationManager stopUpdatingLocation];
	[self.locationManager stopUpdatingHeading];
    
	// post notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingHeading object:self userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingServices object:self userInfo:nil];
}

- (void)invalidateLastKnownLocation {
    self.lastKnownLocation = nil;
}

- (void)whenLocationChanged:(mt_location_changed_block)block {
    self.locationChangedBlock = block;
}

- (void)removeLocationChangedBlock {
    self.locationChangedBlock = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setMapView:(MKMapView *)mapView {
	if(mapView != mapView_) {
		mapView_ = mapView;
        
        // detect taps on the map-view
        MTTouchesMovedGestureRecognizer * tapInterceptor = [[MTTouchesMovedGestureRecognizer alloc] init];
        // safe self for block
        __unsafe_unretained MTLocationManager *blockSelf = self;
        
        tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
            // Reset transform on map
            [blockSelf.mapView resetHeadingRotationAnimated:YES];
            // hide heading angle overlay
            [blockSelf.mapView hideHeadingAngleView];
            
            // stop location-services
            [[MTLocationManager sharedInstance].locationManager stopUpdatingLocation];
            [[MTLocationManager sharedInstance].locationManager stopUpdatingHeading];
            
            // Tell LocateMeBarButtonItem to update it's state
            [[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingHeading object:blockSelf userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingServices object:blockSelf userInfo:nil];
        };
        
        [self.mapView addGestureRecognizer:tapInterceptor];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark locationManager Delegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  newLocation, @"newLocation",
							  oldLocation, @"oldLocation", nil];
    
    // move heading angle overlay to new coordinate
    if (!MTLocationUsesNewAPIs()) {
        [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
        [self.mapView moveHeadingAngleViewToCoordinate:newLocation.coordinate];
    }
    
    // save last known global location
    self.lastKnownLocation = newLocation;
    
    // call delegate-block if there is one
    if (self.locationChangedBlock != nil) {
        self.locationChangedBlock(newLocation);
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidUpdateToLocationFromLocation object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  error, @"error", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidFailWithError object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  newHeading, @"newHeading", nil];
    
    if (newHeading.headingAccuracy > 0) {
        // show heading angle overlay
        [self.mapView showHeadingAngleView];
        // move heading angle overlay to new coordinate
        [self.mapView moveHeadingAngleViewToCoordinate:self.mapView.userLocation.coordinate];
        // rotate map according to heading
        [self.mapView rotateToHeading:newHeading animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidUpdateHeading object:self userInfo:userInfo];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return self.displayHeadingCalibration;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  region, @"region", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidEnterRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  region, @"region", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidExitRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  region, @"region",
							  error, @"error", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerMonitoringDidFailForRegion object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  [NSNumber numberWithInt:status], @"status", nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidChangeAuthorizationStatus object:self userInfo:userInfo];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MTLocateMeButtonDelegate Methods
////////////////////////////////////////////////////////////////////////

- (void)locateMeButton:(MTLocateMeButton *)locateMeButton didChangeTrackingMode:(MTUserTrackingMode)trackingMode {
    [self setActiveServicesForTrackingMode:trackingMode];    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)setActiveServicesForTrackingMode:(MTUserTrackingMode)trackingMode {
    if (MTLocationUsesNewAPIs()) {
        self.mapView.userTrackingMode = (MKUserTrackingMode)trackingMode;
    } 
    
    // check new status after status-toggle and update locationManager accordingly
    switch(trackingMode) {
            // if we are currently idle, stop updates
        case MTUserTrackingModeNone:
            [self stopAllServices];
            break;
            
            // if we are currently searching, start updating location
        case MTUserTrackingModeSearching:
            //NSLog(@"Start updating location");
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;
            
            // if we are already receiving updates
        case MTUserTrackingModeFollow:
            //NSLog(@"Start updating location");
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;
            
            // if we are currently receiving heading updates, start updating heading
        case MTUserTrackingModeFollowWithHeading:
            //NSLog(@"start updating heading");
            [self.locationManager startUpdatingLocation];
            [self.locationManager startUpdatingHeading];
            break;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Singleton definitons
////////////////////////////////////////////////////////////////////////

static MTLocationManager *sharedMTLocationManager = nil;

+ (MTLocationManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMTLocationManager = [[self alloc] init];
    });
    
	return sharedMTLocationManager;
}

@end

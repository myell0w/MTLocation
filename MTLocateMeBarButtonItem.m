//
//  MTLocateMeBarButtonItem.m
//
//  Created by Matthias Tretter on 21.01.11.
//  Copyright (c) 2009-2011  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MTLocateMeBarButtonItem.h"
#import "MTLocateMeButton.h"
#import "MTLocationManager.h"
#import "MKMapView+MTLocation.h"
#import <MapKit/MapKit.h>


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Class Extension
////////////////////////////////////////////////////////////////////////

@interface MTLocateMeBarButtonItem ()

@property (nonatomic, strong) MTLocateMeButton *locateMeButton;

- (void)locationManagerDidUpdateToLocationFromLocation:(NSNotification *)notification;
- (void)locationManagerDidUpdateHeading:(NSNotification *)notification;
- (void)locationManagerDidFail:(NSNotification *)notification;
- (void)locationManagerDidStopUpdatingServices:(NSNotification *)notification;

@end


@implementation MTLocateMeBarButtonItem

@synthesize locateMeButton = locateMeButton_;
@synthesize headingEnabled = headingEnabled_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle, Memory Management
////////////////////////////////////////////////////////////////////////

- (id)initWithMapView:(MKMapView *)mapView {
    if ((self = [self initWithTrackingMode:MTUserTrackingModeNone startListening:YES])) {
        // use MTLocationmanager as delegate, and set it's mapView
        self.delegate = [MTLocationManager sharedInstance];
        [MTLocationManager sharedInstance].mapView = mapView;
        
        // prepare mapView for use with MTLocation
        [mapView sizeToFitTrackingModeFollowWithHeading];
        [mapView addGoogleBadge];
        [mapView addHeadingAngleView];
    }
    
    return self;
}

- (id)initWithTrackingMode:(MTUserTrackingMode)trackingMode startListening:(BOOL)startListening {
    locateMeButton_ = [[MTLocateMeButton alloc] initWithFrame:CGRectZero];
    
	if ((self = [super initWithCustomView:locateMeButton_])) {
		locateMeButton_.trackingMode = trackingMode;
        
        if (startListening) {
            [self startListeningToLocationUpdates];
        }
	}
    
	return self;
}

// the designated initializer
- (id)initWithTrackingMode:(MTUserTrackingMode)trackingMode {
	return [self initWithTrackingMode:trackingMode startListening:YES];
}

// The designated initializer of the base-class
- (id)initWithCustomView:(UIView *)customView {
	return [self initWithTrackingMode:MTUserTrackingModeNone];
}

- (void)dealloc {
    // end listening to location update notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMTLocationManagerDidUpdateToLocationFromLocation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTLocationManagerDidUpdateHeading object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTLocationManagerDidFailWithError object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTLocationManagerDidStopUpdatingServices object:nil];
    
	locateMeButton_ = nil;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setTrackingMode:(MTUserTrackingMode)trackingMode {
	[self setTrackingMode:trackingMode animated:NO];
}

- (void)setTrackingMode:(MTUserTrackingMode)trackingMode animated:(BOOL)animated {
	[self.locateMeButton setTrackingMode:trackingMode animated:YES];
}

- (MTUserTrackingMode)trackingMode {
	return self.locateMeButton.trackingMode;
}

- (void)setHeadingEnabled:(BOOL)headingEnabled {
	self.locateMeButton.headingEnabled = headingEnabled;
}

- (BOOL)headingEnabled {
	return self.locateMeButton.headingEnabled;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
	[self.locateMeButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setDelegate:(id<MTLocateMeButtonDelegate>)delegate {
    self.locateMeButton.delegate = delegate;
}

- (id<MTLocateMeButtonDelegate>)delegate {
    return self.locateMeButton.delegate;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Portrait/Landscape
////////////////////////////////////////////////////////////////////////

- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [self.locateMeButton setFrameForInterfaceOrientation:orientation];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Listener
////////////////////////////////////////////////////////////////////////

- (void)startListeningToLocationUpdates {
    // begin listening to location update notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidUpdateToLocationFromLocation:)
                                                 name:kMTLocationManagerDidUpdateToLocationFromLocation
                                               object:nil];
    // begin listening to heading update notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidUpdateHeading:)
                                                 name:kMTLocationManagerDidUpdateHeading
                                               object:nil];
    // begin listening to location errors
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidFail:)
                                                 name:kMTLocationManagerDidFailWithError
                                               object:nil];
    // begin listening to end of updating of all services
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationManagerDidStopUpdatingServices:)
                                                 name:kMTLocationManagerDidStopUpdatingServices
                                               object:nil];
}

- (void)stopListeningToLocationUpdates {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Location Manager Notifications
////////////////////////////////////////////////////////////////////////

- (void)locationManagerDidUpdateToLocationFromLocation:(NSNotification *)notification {
    // only set new location status if we are currently not receiving heading updates
	if (self.trackingMode != MTUserTrackingModeFollowWithHeading) {
        [self setTrackingMode:MTUserTrackingModeFollow animated:YES];
	}
}

- (void)locationManagerDidUpdateHeading:(NSNotification *)notification {
	CLHeading *newHeading = [notification.userInfo valueForKey:@"newHeading"];
    
    if (newHeading.headingAccuracy > 0) {
        [self setTrackingMode:MTUserTrackingModeFollowWithHeading animated:YES];
    } else {
        [self setTrackingMode:MTUserTrackingModeFollow animated:YES];
    }
}

- (void)locationManagerDidFail:(NSNotification *)notification {
    [self setTrackingMode:MTUserTrackingModeNone animated:YES];
}

- (void)locationManagerDidStopUpdatingServices:(NSNotification *)notification {
	// update locationStatus
	[self setTrackingMode:MTUserTrackingModeNone animated:YES];
}


@end

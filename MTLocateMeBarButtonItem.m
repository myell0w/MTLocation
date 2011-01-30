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


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Class Extension
////////////////////////////////////////////////////////////////////////

@interface MTLocateMeBarButtonItem ()

@property (nonatomic, retain) MTLocateMeButton *locateMeButton;

@end


@implementation MTLocateMeBarButtonItem

@synthesize locateMeButton = locateMeButton_;
@synthesize headingEnabled = headingEnabled_;
@synthesize locationManager = locationManager_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle, Memory Management
////////////////////////////////////////////////////////////////////////

// the designated initializer
- (id)initWithLocationStatus:(MTLocationStatus)locationStatus locationManager:(CLLocationManager *)locationManager {
	locateMeButton_ = [[MTLocateMeButton alloc] initWithFrame:CGRectZero];

	if ((self = [super initWithCustomView:locateMeButton_])) {
		locateMeButton_.locationStatus = locationStatus;
		locateMeButton_.locationManager = locationManager;
		// pass is nil for locationManager if you don't want to use it
		locationManager_ = [locationManager retain];
		locationManager_.delegate = self;
	}

	return self;
}

- (id)initWithLocationStatus:(MTLocationStatus)locationStatus {
	return [self initWithLocationStatus:locationStatus locationManager:nil];
}

// The designated initializer of the base-class
- (id)initWithCustomView:(UIView *)customView {
	return [self initWithLocationStatus:MTLocationStatusIdle];
}

- (void)dealloc {
	[locateMeButton_ release], locateMeButton_ = nil;
	[locationManager_ release], locationManager_ = nil;

	[super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setLocationStatus:(MTLocationStatus)locationStatus {
	[self setLocationStatus:locationStatus animated:NO];
}

- (void)setLocationStatus:(MTLocationStatus)locationStatus animated:(BOOL)animated {
	if (self.locationStatus != locationStatus) {
		[self.locateMeButton setLocationStatus:locationStatus animated:YES];
	}
}

- (MTLocationStatus)locationStatus {
	return self.locateMeButton.locationStatus;
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

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark locationManager Delegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  newLocation, @"newLocation",
							  oldLocation, @"oldLocation", nil];

	// only set new location status if we are currently not receiving heading updates
	if (self.locationStatus != MTLocationStatusReceivingHeadingUpdates) {
		// if horizontal accuracy is below our threshold update status
		if (newLocation.horizontalAccuracy < kMTLocationMinimumHorizontalAccuracy) {
			[self setLocationStatus:MTLocationStatusReceivingLocationUpdates animated:YES];
		} else {
			[self setLocationStatus:MTLocationStatusSearching animated:YES];
		}
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidUpdateToLocationFromLocation object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  error, @"error", nil];

	[self setLocationStatus:MTLocationStatusIdle animated:YES];

	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidFailWithError object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  newHeading, @"newHeading", nil];

	[self setLocationStatus:MTLocationStatusReceivingHeadingUpdates animated:YES];

	[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidUpdateHeading object:self userInfo:userInfo];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
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


@end

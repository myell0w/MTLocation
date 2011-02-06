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


@implementation MTLocationManager

@synthesize locationManager = locationManager_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////


- (id)init {
    if ((self = [super init])) {
        locationManager_ = [[CLLocationManager alloc] init];
		locationManager_.delegate = self;
    }

    return self;
}

- (void)dealloc {
    [locationManager_ release], locationManager_ = nil;

    [super dealloc];
}



////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark locationManager Delegate
////////////////////////////////////////////////////////////////////////


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: manager, @"locationManager",
							  newLocation, @"newLocation",
							  oldLocation, @"oldLocation", nil];

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


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MTLocateMeButtonDelegate Methods
////////////////////////////////////////////////////////////////////////

- (void)locateMeButton:(MTLocateMeButton *)locateMeButton didChangeLocationStatus:(MTLocationStatus)locationStatus {
    // check new status after status-toggle and update locationManager accordingly
    switch(locationStatus) {
            // if we are currently idle, stop updates
        case MTLocationStatusIdle:
            //NSLog(@"Stopped updating");
            [self.locationManager stopUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;

            // if we are currently searching, start updating location
        case MTLocationStatusSearching:
            //NSLog(@"Start updating location");
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;

            // if we are already receiving updates
        case MTLocationStatusReceivingLocationUpdates:
            //NSLog(@"Start updating location");
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            break;

            // if we are currently receiving heading updates, start updating heading
        case MTLocationStatusReceivingHeadingUpdates:
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
	@synchronized(self) {
		if (sharedMTLocationManager == nil) {
			sharedMTLocationManager = [[self alloc] init];
		}
	}

	return sharedMTLocationManager;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedMTLocationManager == nil) {
			sharedMTLocationManager = [super allocWithZone:zone];

			return sharedMTLocationManager;
		}
	}

	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)release {
}

- (id)autorelease {
	return self;
}

@end

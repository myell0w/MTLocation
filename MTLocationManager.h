//
//  MTLocationManager.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MTLocateMeButton.h"
#import "MTLocateMeBarButtonItem.h"

// block-type of block that gets executed when location changes
typedef void (^mt_location_changed_block)(CLLocation *location);

/**
 Singleton class that acts as the Location Manager and it's delegate
 Sends Notifications when CLLocationManagerDelegate-Methods are called
 */
@interface MTLocationManager : NSObject <CLLocationManagerDelegate, MTLocateMeButtonDelegate> 

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) CLLocation *lastKnownLocation;
// Optional: a MapView that gets rotated according to heading updates
@property (nonatomic, strong) MKMapView *mapView;
// configure if heading calibration should be displayed
@property (nonatomic, getter=isHeadingCalibrationDisplayed) BOOL displayHeadingCalibration;

// Singleton Instance
+ (MTLocationManager *)sharedInstance;

/** Sets the specified tracking mode programatically (doesn't update button) */
- (void)setTrackingMode:(MTUserTrackingMode)trackingMode;
- (void)stopAllServices;
- (void)invalidateLastKnownLocation;

- (void)whenLocationChanged:(mt_location_changed_block)block;
- (void)removeLocationChangedBlock;

@end

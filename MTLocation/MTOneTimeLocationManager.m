//
//  MTOneTimeLocationManager.m
//  MTLocation
//
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MTOneTimeLocationManager.h"
#import "MTLocationManager.h"


@interface MTOneTimeLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationAccuracy accuracy;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation MTOneTimeLocationManager

@synthesize locationManager = locationManager_;
@synthesize completion = completion_;
@synthesize error = error_;
@synthesize accuracy = accuracy_;

////////////////////////////////////////////////////////////////////////
#pragma mark - WTOneTimeLocationManager
////////////////////////////////////////////////////////////////////////

- (void)startUpdatingLocationWithAcccuracy:(CLLocationAccuracy)accuracy
                            distanceFilter:(CLLocationDistance)distanceFilter
                                completion:(mt_location_changed_block)completion 
                                     error:(mt_location_error_block)error {
    if (self.locationManager == nil) {
        self.accuracy = accuracy;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = distanceFilter;
        self.locationManager.desiredAccuracy = accuracy;
        self.locationManager.delegate = self;
    }
    
    self.completion = completion;
    self.error = error;
    
    [self.locationManager startUpdatingLocation];
}

- (void)cancel {
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation.horizontalAccuracy < self.accuracy) {
        [self cancel];
    }
    
    [MTLocationManager sharedInstance].lastKnownLocation = newLocation;
    
    if (self.completion != nil) {
        self.completion(newLocation);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self cancel];
    
    if (self.error != nil) {    
        self.error(error);
    }
}


@end

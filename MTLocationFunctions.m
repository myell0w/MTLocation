//
//  MTLocationFunctions.m
//
//  Created by Matthias Tretter on 8.3.2011.
//  Copyright (c) 2009-2011 Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "MTLocationFunctions.h"
#import <MapKit/MapKit.h>


void MTOpenDirectionInGoogleMaps(CLLocationCoordinate2D startingPoint, CLLocationCoordinate2D endPoint, NSString *directionMode) {
	NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
							   startingPoint.latitude,startingPoint.longitude, endPoint.latitude, endPoint.longitude];
    
	if (![directionMode isEqualToString:kMTDirectionModeCar]) {
		googleMapsURL = [googleMapsURL stringByAppendingFormat:@"&dirflg=%@", directionMode];
	}
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
}




void MTRotateViewToHeading(UIView *view, CLHeading *heading, BOOL animated) {
    double animationDuration = animated ? 0.2 : 0.0;
    
	if (heading.headingAccuracy > 0) {
        if (animated) {
            // if the map is currently not rotated
            // we are just starting the rotation
            // therefore it is possible that there is a big
            // angle between current transformation and the one
            // applied, so we increase the animation duration
            if (CGAffineTransformIsIdentity(view.transform)) {
                if (fabs(heading.magneticHeading) > 135.0) {
                    animationDuration = 0.5;
                } else if (fabs(heading.magneticHeading) > 90.0) {
                    animationDuration = 0.4;
                } else if (fabs(heading.magneticHeading) > 45.0) {
                    animationDuration = 0.3;
                }
            }
        }
        
		// Apply the transformation animated
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 [view setTransform:CGAffineTransformMakeRotation(heading.magneticHeading * M_PI / -180.0)];
                             
                             // special case: MapView
                             if ([view isKindOfClass:[MKMapView class]]) {
                                 MKMapView *mapView = (MKMapView *)view;
                                 
                                 // rotate annotation-views back so that Pins & Annotations appear non-rotated
                                 for (id<MKAnnotation> annotation in mapView.annotations) {
                                     [[mapView viewForAnnotation:annotation] setTransform:CGAffineTransformMakeRotation(heading.magneticHeading * M_PI / 180.0)];
                                 }
                             }
						 }];
	}
}

void MTResetViewRotation(UIView *view, BOOL animated) {
    // reset rotation of map-view
	[UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         [view setTransform:CGAffineTransformIdentity];
                         
                         // special case: MapView
                         if ([view isKindOfClass:[MKMapView class]]) {
                             MKMapView *mapView = (MKMapView *)view;
                             
                             // rotate annotation-views back so that Pins & Annotations appear non-rotated
                             for (id<MKAnnotation> annotation in mapView.annotations) {
                                 [[mapView viewForAnnotation:annotation] setTransform:CGAffineTransformIdentity];
                             }
                         }
                     }];
}
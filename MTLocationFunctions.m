//
//  MTLocationFunctions.m
//
//  Created by Matthias Tretter on 2.02.11.
//  Copyright (c) 2009-2011  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "MTLocationFunctions.h"


void MTRotateMapToHeading(MKMapView *mapView, CLHeading *heading) {
	double animationDuration = 0.2;

	if (heading.headingAccuracy > 0) {
		// if the map is currently not rotated
		// we are just starting the rotation
		// therefore it is possible that there is a big
		// angle between current transformation and the one
		// applied, so we increase the animation duration
		if (CGAffineTransformIsIdentity(mapView.transform)) {
			if (fabs(heading.magneticHeading) > 135.0) {
				animationDuration = 0.5;
			} else if (fabs(heading.magneticHeading) > 90.0) {
				animationDuration = 0.4;
			} else if (fabs(heading.magneticHeading) > 45.0) {
				animationDuration = 0.3;
			}
		}

		// Apply the transformation animated
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 [mapView setTransform:CGAffineTransformMakeRotation(heading.magneticHeading * M_PI / -180.0)];
						 }];
	}
}


void MTClearMapRotation(MKMapView *mapView) {
    // reset rotation of map-view
	[UIView animateWithDuration:0.5 animations:^{
		[mapView setTransform:CGAffineTransformIdentity];
	}];
}

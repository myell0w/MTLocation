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



void MTOpenDirectionInGoogleMaps(CLLocationCoordinate2D startingPoint, CLLocationCoordinate2D endPoint, NSString *directionMode) {
	NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
							   startingPoint.latitude,startingPoint.longitude, endPoint.latitude, endPoint.longitude];

	if (![directionMode isEqualToString:kMTDirectionModeCar]) {
		googleMapsURL = [googleMapsURL stringByAppendingFormat:@"&dirflg=%@", directionMode];
	}

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
}

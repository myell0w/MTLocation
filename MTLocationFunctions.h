//
//  MTLocationFunctions.h
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kMTDirectionModeCar					@"kMTDirectionModeCar"
#define kMTDirectionModeWalking				@"w"
#define kMTDirectionModePublicTransport		@"r"


// use iOS 5 APIs?
BOOL MTLocationUsesNewAPIs(void);

// opens directions from startPoint to endPoint in the built-in Google Maps App
void MTOpenDirectionInGoogleMaps(CLLocationCoordinate2D startingPoint, CLLocationCoordinate2D endPoint, NSString *directionMode);

// rotates any UIView according to some heading information
void MTRotateViewToHeading(UIView *view, CLHeading *heading, BOOL animated);
// rotates any UIView to point from one coordinate to another
void MTRotateViewForDirectionFromCoordinateToCoordinate(UIView *view, CLHeading *heading, CLLocationCoordinate2D fromLocation, CLLocationCoordinate2D toLocation, BOOL animated);
// clears the rotation-transform on the view
void MTResetViewRotation(UIView *view, BOOL animated);
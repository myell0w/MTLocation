//
//  MTLocationDefines.h
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


// The location status determines in which Status regarding to Core Location the application
// currently is, whether it is idle, searching for a location, receiving locations or receiving heading information
typedef enum MTLocationStatus {
	MTLocationStatusIdle = 0,						// Currently Idle
	MTLocationStatusSearching = 1,					// Currently determining Location
	MTLocationStatusReceivingLocationUpdates = 2,	// Currently receiving location updates
	MTLocationStatusReceivingHeadingUpdates = 3		// Currently receiving heading updates
} MTLocationStatus;


// number of defines stati
#define kMTLocationStatusCount 4

// defined threshold for a location that counts as a location update
#define kMTLocationMinimumHorizontalAccuracy 100


#define kMTLocationManagerDidUpdateToLocationFromLocation	@"kMTLocationManagerDidUpdateToLocationFromLocation"
#define kMTLocationManagerDidFailWithError					@"kMTLocationManagerDidFailWithError"
#define kMTLocationManagerDidUpdateHeading					@"kMTLocationManagerDidUpdateHeading"
#define kMTLocationManagerDidEnterRegion					@"kMTLocationManagerDidEnterRegion"
#define kMTLocationManagerDidExitRegion						@"kMTLocationManagerDidExitRegion"
#define kMTLocationManagerMonitoringDidFailForRegion		@"kMTLocationManagerMonitoringDidFailForRegion"
#define kMTLocationManagerDidChangeAuthorizationStatus		@"kMTLocationManagerDidChangeAuthorizationStatus"

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

- (id)initWithLocationStatus:(MTLocationStatus)locationStatus startListening:(BOOL)startListening {
    locateMeButton_ = [[MTLocateMeButton alloc] initWithFrame:CGRectZero];
    
	if ((self = [super initWithCustomView:locateMeButton_])) {
		locateMeButton_.locationStatus = locationStatus;
        
        if (startListening) {
            [self startListeningToLocationUpdates];
        }
	}
    
	return self;
}

// the designated initializer
- (id)initWithLocationStatus:(MTLocationStatus)locationStatus {
	return [self initWithLocationStatus:locationStatus startListening:YES];
}

// The designated initializer of the base-class
- (id)initWithCustomView:(UIView *)customView {
	return [self initWithLocationStatus:MTLocationStatusIdle];
}

- (void)dealloc {
    // end listening to location update notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[locateMeButton_ release], locateMeButton_ = nil;

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
	[self.locateMeButton setLocationStatus:locationStatus animated:YES];
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

- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.locateMeButton setFrameForInterfaceOrientation:orientation duration:duration];
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
	CLLocation *newLocation = [notification.userInfo valueForKey:@"newLocation"];

    // only set new location status if we are currently not receiving heading updates
	if (self.locationStatus != MTLocationStatusReceivingHeadingUpdates) {
		// if horizontal accuracy is below our threshold update status
		if (newLocation.horizontalAccuracy < kMTLocationMinimumHorizontalAccuracy) {
			[self setLocationStatus:MTLocationStatusReceivingLocationUpdates animated:YES];
		} else {
			[self setLocationStatus:MTLocationStatusSearching animated:YES];
		}
	}
}

- (void)locationManagerDidUpdateHeading:(NSNotification *)notification {
	CLHeading *newHeading = [notification.userInfo valueForKey:@"newHeading"];

    if (newHeading.headingAccuracy > 0) {
        [self setLocationStatus:MTLocationStatusReceivingHeadingUpdates animated:YES];
    } else {
        [self setLocationStatus:MTLocationStatusReceivingLocationUpdates animated:YES];
    }
}

- (void)locationManagerDidFail:(NSNotification *)notification {
    [self setLocationStatus:MTLocationStatusIdle animated:YES];
}

- (void)locationManagerDidStopUpdatingServices:(NSNotification *)notification {
	// update locationStatus
	[self setLocationStatus:MTLocationStatusIdle animated:YES];
}


@end

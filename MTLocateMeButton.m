//
//  MTLocateMeButton.m
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

#import "MTLocateMeButton.h"


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Customize Section
////////////////////////////////////////////////////////////////////////

// Background images
#define kLocationStatusIdleBackgroundImage						@"LocateMeButton.png"
#define kLocationStatusSearchingBackgroundImage					@"LocateMeButtonTrackingPressed.png"
#define kLocationStatusRecevingLocationUpdatesBackgroundImage	@"LocateMeButtonTrackingPressed.png"
#define kLocationStatusRecevingHeadingUpdatesBackgroundImage	@"LocateMeButtonTrackingPressed.png"

// foreground images
#define kLocationStatusIdleImage					@"Location.png"
#define kLocationStatusRecevingLocationUpdatesImage	@"Location.png"
#define kLocationStatusRecevingHeadingUpdatesImage	@"LocationHeading.png"

// animation durations
#define kShrinkAnimationDuration 0.25
#define kExpandAnimationDuration 0.25
#define kExpandAnimationDelay    0.1

// size & insets
#define kWidthLandscape         32.f
#define kHeightLandscape        32.f

#define kActivityIndicatorInsetPortrait 12.f
#define kImageViewInsetPortrait		    10.f

#define kActivityIndicatorInsetLandscape  8.f
#define kImageViewInsetLandscape  	      6.f


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Class Extension
////////////////////////////////////////////////////////////////////////


@interface MTLocateMeButton ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) CGRect activityIndicatorFrame;
@property (nonatomic, assign) CGRect imageViewFrame;
@property (nonatomic, assign) UIView *activeSubview;
@property (nonatomic, readonly) UIView *inactiveSubview;

- (void)updateUI;
- (void)locationStatusToggled:(id)sender;

- (void)setSmallFrame:(UIView *)view;
- (void)setBigFrame:(UIView *)view;

@end


@implementation MTLocateMeButton

@synthesize locationStatus = locationStatus_;
@synthesize headingEnabled = headingEnabled_;
@synthesize activityIndicator = activityIndicator_;
@synthesize imageView = imageView_;
@synthesize activityIndicatorFrame = activityIndicatorFrame_;
@synthesize imageViewFrame = imageViewFrame_;
@synthesize activeSubview = activeSubview_;
@synthesize locationManager = locationManager_;
@synthesize delegate = delegate_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle, Memory Management
////////////////////////////////////////////////////////////////////////


- (id)initWithFrame:(CGRect)frame  {
	CGRect buttonFrame = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        buttonFrame = CGRectMake(0.,0.,kWidthLandscape,kHeightLandscape);
    } else {
        buttonFrame = (CGRect){CGPointZero, [UIImage imageNamed:kLocationStatusIdleBackgroundImage].size};
    }
    
    if ((self = [super initWithFrame:buttonFrame])) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            activityIndicatorFrame_ = CGRectInset(buttonFrame, kActivityIndicatorInsetLandscape, kActivityIndicatorInsetLandscape);
            imageViewFrame_ = CGRectInset(buttonFrame, kImageViewInsetLandscape , kImageViewInsetLandscape);
        } else {
            activityIndicatorFrame_ = CGRectInset(buttonFrame, kActivityIndicatorInsetPortrait, kActivityIndicatorInsetPortrait);
            imageViewFrame_ = CGRectInset(buttonFrame, kImageViewInsetPortrait, kImageViewInsetPortrait);
        }
        
		locationStatus_ = MTLocationStatusIdle;
		headingEnabled_ = YES;
        
		activityIndicator_ = [[UIActivityIndicatorView alloc] initWithFrame:activityIndicatorFrame_];
        activityIndicator_.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		activityIndicator_.contentMode = UIViewContentModeScaleAspectFit;
		activityIndicator_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		activityIndicator_.userInteractionEnabled = NO;
        
		imageView_ = [[UIImageView alloc] initWithFrame:imageViewFrame_];
		imageView_.contentMode = UIViewContentModeScaleAspectFit;
		imageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		[self addSubview:imageView_];
        [self addSubview:activityIndicator_];
		[self addTarget:self action:@selector(locationStatusToggled:) forControlEvents:UIControlEventTouchUpInside];
        
		[self updateUI];
	}
    
    return self;
}

- (void)dealloc {
    delegate_ = nil;
    [activityIndicator_ release], activityIndicator_ = nil;
	[imageView_ release], imageView_ = nil;
	[locationManager_ release], locationManager_ = nil;
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (UIView *)inactiveSubview {
	if (self.activeSubview == self.activityIndicator) {
		return self.imageView;
	} else {
		return self.activityIndicator;
	}
}

- (BOOL)headingEnabled {
	return [CLLocationManager headingAvailable] && headingEnabled_;
}

- (void)setLocationStatus:(MTLocationStatus)locationStatus {
	if (locationStatus_ != locationStatus) {
		locationStatus_ = locationStatus;
		[self updateUI];
	}
}

- (void)setLocationStatus:(MTLocationStatus)locationStatus animated:(BOOL)animated {
	if (locationStatus_ != locationStatus) {
		if (animated) {
			// Important: do not use setter here, because otherwise updateUI is triggered too soon!
			locationStatus_ = locationStatus;
			[self setSmallFrame:self.inactiveSubview];
            
			// animate currently visible subview to a smaller frame
			// when finished, animate currently invisible subview to big frame
			[UIView beginAnimations:@"AnimateLocationStatusShrink" context:(void *)[NSNumber numberWithInt:locationStatus]];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:kShrinkAnimationDuration];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(locationStatusAnimationShrinkDidFinish:finished:context:)];
            
			[self setSmallFrame:self.activeSubview];
            
			[UIView commitAnimations];
		} else {
			self.locationStatus = locationStatus;
		}
	}
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Portrait/Landscape
////////////////////////////////////////////////////////////////////////

- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [UIView beginAnimations:@"MTLocationRotationAnimation" context:NULL];
    [UIView setAnimationDuration:duration];
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.frame = (CGRect){CGPointZero, [UIImage imageNamed:kLocationStatusIdleBackgroundImage].size};
        
        self.activityIndicatorFrame = CGRectInset(self.frame, kActivityIndicatorInsetPortrait, kActivityIndicatorInsetPortrait);
        self.imageViewFrame = CGRectInset(self.frame, kImageViewInsetPortrait , kImageViewInsetPortrait);
    } else {
        self.frame = CGRectMake(0.,0.,kWidthLandscape,kHeightLandscape);
        
        self.activityIndicatorFrame = CGRectInset(self.frame, kActivityIndicatorInsetLandscape, kActivityIndicatorInsetLandscape);
        self.imageViewFrame = CGRectInset(self.frame, kImageViewInsetLandscape, kImageViewInsetLandscape);
    }
    
    [self setBigFrame:self.activeSubview];
    
    [UIView commitAnimations];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations
////////////////////////////////////////////////////////////////////////

- (void)locationStatusAnimationShrinkDidFinish:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// location status changed, now another subview is visible
	[self updateUI];
	// set the inactive subview back to the original frame
	[self setBigFrame:self.inactiveSubview];
    
	// animate the currently visible subview back to a big frame
	[UIView beginAnimations:@"AnimateLocationStatusExpand" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelay:kExpandAnimationDelay];
	[UIView setAnimationDuration:kExpandAnimationDuration];
    
	[self setBigFrame:self.activeSubview];
    
	[UIView commitAnimations];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
	switch (self.locationStatus) {
		case MTLocationStatusIdle:
			[self setImage:[UIImage imageNamed:kLocationStatusIdleBackgroundImage] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kLocationStatusIdleImage];
			self.activeSubview = self.imageView;
			break;
            
		case MTLocationStatusSearching:
			[self setImage:[UIImage imageNamed:kLocationStatusSearchingBackgroundImage] forState:UIControlStateNormal];
			[self.activityIndicator startAnimating];
			self.imageView.image = nil;
			self.activeSubview = self.activityIndicator;
			break;
            
		case MTLocationStatusReceivingLocationUpdates:
			[self setImage:[UIImage imageNamed:kLocationStatusRecevingLocationUpdatesBackgroundImage] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kLocationStatusRecevingLocationUpdatesImage];
			self.activeSubview = self.imageView;
			break;
            
		case MTLocationStatusReceivingHeadingUpdates:
			[self setImage:[UIImage imageNamed:kLocationStatusRecevingHeadingUpdatesBackgroundImage] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kLocationStatusRecevingHeadingUpdatesImage];
			self.activeSubview = self.imageView;
			break;
	}
}

// is called when the user taps the button
- (void)locationStatusToggled:(id)sender {
	MTLocationStatus newLocationStatus = MTLocationStatusIdle;
    
	// set new location status
	switch (self.locationStatus) {
			// if we are currently idle, search for location
		case MTLocationStatusIdle:
			newLocationStatus = MTLocationStatusSearching;
			break;
            
			// if we are currently searching, abort and switch back to idle
		case MTLocationStatusSearching:
			newLocationStatus = MTLocationStatusIdle;
			break;
            
			// if we are currently receiving updates next status depends whether heading is supported or not
		case MTLocationStatusReceivingLocationUpdates:
			newLocationStatus = self.headingEnabled ? MTLocationStatusReceivingHeadingUpdates : MTLocationStatusIdle;
			break;
            
			// if we are currently receiving heading updates, switch back to idle
		case MTLocationStatusReceivingHeadingUpdates:
			newLocationStatus = MTLocationStatusIdle;
			// post notification that heading updates stopped
			[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingHeading object:self userInfo:nil];
			break;
	}
    
	// update to new location status
	[self setLocationStatus:newLocationStatus animated:YES];
    
	// call delegate
    [self.delegate locateMeButton:self didChangeLocationStatus:newLocationStatus];
}

// sets a view to a smaller frame, used for animation
- (void)setSmallFrame:(UIView *)view {
	double inset = view.frame.size.width / 2.;
    
	view.frame = CGRectMake(view.frame.origin.x + inset, view.frame.origin.y + inset,
							view.frame.size.width - 2*inset, view.frame.size.height - 2*inset);
}

// sets a view to the original bigger frame, used for animation
- (void)setBigFrame:(UIView *)view {
	if (view == self.activityIndicator) {
		view.frame = self.activityIndicatorFrame;
	} else {
		view.frame = self.imageViewFrame;
	}
}

@end

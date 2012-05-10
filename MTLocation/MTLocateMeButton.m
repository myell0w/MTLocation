//
//  MTLocateMeButton.m
//
//  Created by Matthias Tretter on 21.01.11.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
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
#define kMTLocationStatusIdleBackgroundImage						@"MTLocation.bundle/LocateMeButton"
#define kMTLocationStatusSearchingBackgroundImage					@"MTLocation.bundle/LocateMeButtonTrackingPressed"
#define kMTLocationStatusRecevingLocationUpdatesBackgroundImage     @"MTLocation.bundle/LocateMeButtonTrackingPressed"
#define kMTLocationStatusRecevingHeadingUpdatesBackgroundImage      @"MTLocation.bundle/LocateMeButtonTrackingPressed"

// foreground images
#define kMTLocationStatusIdleImage                      @"MTLocation.bundle/Location"
#define kMTLocationStatusRecevingLocationUpdatesImage	@"MTLocation.bundle/Location"
#define kMTLocationStatusRecevingHeadingUpdatesImage	@"MTLocation.bundle/LocationHeading"

// animation durations
#define kShrinkAnimationDuration            0.25
#define kExpandAnimationDuration            0.25
#define kExpandAnimationDelay               0.1

// size & insets
#define kWidthLandscape                     32.f
#define kHeightLandscape                    32.f

#define kActivityIndicatorInsetPortrait     6.f
#define kImageViewInsetPortrait             5.f

#define kActivityIndicatorInsetLandscape    8.f
#define kImageViewInsetLandscape            6.f


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Class Extension
////////////////////////////////////////////////////////////////////////


@interface MTLocateMeButton ()

// Subview: activity indicator is shown during MTLocationStatusSearching
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
// Subview: Holds image that is shown in all other LocationStati
@property (nonatomic, strong) UIImageView *imageView;
// the initial frame of the activity indicator
@property (nonatomic, assign) CGRect activityIndicatorFrame;
// the initial frame of the image view
@property (nonatomic, assign) CGRect imageViewFrame;
// the currently displayed sub-view
@property (nonatomic, unsafe_unretained) UIView *activeSubview;
@property (unsafe_unretained, nonatomic, readonly) UIView *inactiveSubview;

- (void)updateUI;
- (void)trackingModeToggled:(id)sender;

- (void)setSmallFrame:(UIView *)view;
- (void)setBigFrame:(UIView *)view;

@end


@implementation MTLocateMeButton

@synthesize trackingMode = _trackingMode;
@synthesize headingEnabled = _headingEnabled;
@synthesize activityIndicator = _activityIndicator;
@synthesize imageView = _buttonImageView;
@synthesize activityIndicatorFrame = _activityIndicatorFrame;
@synthesize imageViewFrame = _buttonImageViewFrame;
@synthesize activeSubview = _activeSubview;
@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
@synthesize idleBackgroundImage = _idleBackgroundImage;
@synthesize searchingBackgroundImage = _searchingBackgroundImage;
@synthesize recevingHeadingUpdatesBackgroundImage = _recevingHeadingUpdatesBackgroundImage;
@synthesize recevingLocationUpdatesBackgroundImage = _recevingLocationUpdatesBackgroundImage;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle, Memory Management
////////////////////////////////////////////////////////////////////////


- (id)initWithFrame:(CGRect)frame {
	CGSize buttonSize = CGSizeMake(kWidthLandscape, kHeightLandscape);
    
    _idleBackgroundImage = [UIImage imageNamed:kMTLocationStatusIdleBackgroundImage];
    _searchingBackgroundImage = [UIImage imageNamed:kMTLocationStatusSearchingBackgroundImage];
    _recevingHeadingUpdatesBackgroundImage = [UIImage imageNamed:kMTLocationStatusRecevingHeadingUpdatesBackgroundImage];
    _recevingLocationUpdatesBackgroundImage = [UIImage imageNamed:kMTLocationStatusRecevingLocationUpdatesBackgroundImage];
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        buttonSize = _idleBackgroundImage.size;
    }
    
    if ((self = [super initWithFrame:(CGRect){frame.origin, buttonSize}])) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            _activityIndicatorFrame = CGRectInset(self.bounds, kActivityIndicatorInsetLandscape, kActivityIndicatorInsetLandscape);
            _buttonImageViewFrame = CGRectInset(self.bounds, kImageViewInsetLandscape , kImageViewInsetLandscape);
        } else {
            _activityIndicatorFrame = CGRectInset(self.bounds, kActivityIndicatorInsetPortrait, kActivityIndicatorInsetPortrait);
            _buttonImageViewFrame = CGRectInset(self.bounds, kImageViewInsetPortrait, kImageViewInsetPortrait);
        }
        
		_trackingMode = MTLocationStatusIdle;
		_headingEnabled = YES;
        
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:_activityIndicatorFrame];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		_activityIndicator.contentMode = UIViewContentModeScaleAspectFit;
		_activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_activityIndicator.userInteractionEnabled = NO;
        
		_buttonImageView = [[UIImageView alloc] initWithFrame:_buttonImageViewFrame];
		_buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
		_buttonImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		[self addSubview:_buttonImageView];
        [self addSubview:_activityIndicator];
		[self addTarget:self action:@selector(trackingModeToggled:) forControlEvents:UIControlEventTouchUpInside];
        
		[self updateUI];
	}
    
    return self;
}

- (void)dealloc {
    _delegate = nil;
    _activityIndicator = nil;
	_buttonImageView = nil;
	_locationManager = nil;
    
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
	return [CLLocationManager headingAvailable] && _headingEnabled;
}

- (void)setTrackingMode:(MTUserTrackingMode)trackingMode {
	if (_trackingMode != trackingMode) {
		_trackingMode = trackingMode;
		[self updateUI];
	}
}

- (void)setTrackingMode:(MTUserTrackingMode)trackingMode animated:(BOOL)animated {
	if (_trackingMode != trackingMode) {
		if (animated) {
			// Important: do not use setter here, because otherwise updateUI is triggered too soon!
			_trackingMode = trackingMode;
			[self setSmallFrame:self.inactiveSubview];
            
			// animate currently visible subview to a smaller frame
			// when finished, animate currently invisible subview to big frame
			[UIView beginAnimations:@"AnimateLocationStatusShrink" context:(__bridge void *)[NSNumber numberWithInt:trackingMode]];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:kShrinkAnimationDuration];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(locationStatusAnimationShrinkDidFinish:finished:context:)];
            
			[self setSmallFrame:self.activeSubview];
            
			[UIView commitAnimations];
		} else {
			self.trackingMode = trackingMode;
		}
	}
}

- (void)setIdleBackgroundImage:(UIImage *)idleBackgroundImage {
    if (_idleBackgroundImage != idleBackgroundImage) {
        _idleBackgroundImage = idleBackgroundImage;
        self.frame = (CGRect){ .origin = self.frame.origin, .size = _idleBackgroundImage.size };
        [self updateUI];
    }
}

- (void)setSearchingBackgroundImage:(UIImage *)searchingBackgroundImage {
    if (_searchingBackgroundImage != searchingBackgroundImage) {
        _searchingBackgroundImage = searchingBackgroundImage;
        [self updateUI];
    }
}

- (void)setRecevingHeadingUpdatesBackgroundImage:(UIImage *)recevingHeadingUpdatesBackgroundImage {
    if (_recevingHeadingUpdatesBackgroundImage != recevingHeadingUpdatesBackgroundImage) {
        _recevingHeadingUpdatesBackgroundImage = recevingHeadingUpdatesBackgroundImage;
        [self updateUI];
    }
}

- (void)setRecevingLocationUpdatesBackgroundImage:(UIImage *)recevingLocationUpdatesBackgroundImage {
    if (_recevingLocationUpdatesBackgroundImage != recevingLocationUpdatesBackgroundImage) {
        _recevingLocationUpdatesBackgroundImage = recevingLocationUpdatesBackgroundImage;
        [self updateUI];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Portrait/Landscape
////////////////////////////////////////////////////////////////////////

- (void)setFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.frame = (CGRect){{self.frame.origin.x, self.frame.origin.y}, self.idleBackgroundImage.size};
        
        self.activityIndicatorFrame = CGRectInset(self.bounds, kActivityIndicatorInsetPortrait, kActivityIndicatorInsetPortrait);
        self.imageViewFrame = CGRectInset(self.bounds, kImageViewInsetPortrait , kImageViewInsetPortrait);
    } else {
        self.frame = (CGRect){self.frame.origin.x, self.frame.origin.y, kWidthLandscape, kHeightLandscape};
        
        self.activityIndicatorFrame = CGRectInset(self.bounds, kActivityIndicatorInsetLandscape, kActivityIndicatorInsetLandscape);
        self.imageViewFrame = CGRectInset(self.bounds, kImageViewInsetLandscape, kImageViewInsetLandscape);
    }
    
    [self setBigFrame:self.activeSubview];
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
	switch (self.trackingMode) {
		case MTUserTrackingModeNone:
			[self setImage:self.idleBackgroundImage forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kMTLocationStatusIdleImage];
			self.activeSubview = self.imageView;
			break;
            
		case MTUserTrackingModeSearching:
			[self setImage:self.searchingBackgroundImage forState:UIControlStateNormal];
			[self.activityIndicator startAnimating];
			self.imageView.image = nil;
			self.activeSubview = self.activityIndicator;
			break;
            
		case MTUserTrackingModeFollow:
			[self setImage:self.recevingLocationUpdatesBackgroundImage forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kMTLocationStatusRecevingLocationUpdatesImage];
			self.activeSubview = self.imageView;
			break;
            
		case MTUserTrackingModeFollowWithHeading:
			[self setImage:self.recevingHeadingUpdatesBackgroundImage forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:kMTLocationStatusRecevingHeadingUpdatesImage];
			self.activeSubview = self.imageView;
			break;
	}
}

// is called when the user taps the button
- (void)trackingModeToggled:(id)sender {
	MTUserTrackingMode newTrackingMode = MTUserTrackingModeNone;
    
	// set new location status
	switch (self.trackingMode) {
			// if we are currently idle, search for location
		case MTUserTrackingModeNone:
			newTrackingMode = MTUserTrackingModeSearching;
			break;
            
			// if we are currently searching, abort and switch back to idle
		case MTUserTrackingModeSearching:
			newTrackingMode = MTUserTrackingModeNone;
			break;
            
			// if we are currently receiving updates next status depends whether heading is supported or not
		case MTUserTrackingModeFollow:
			newTrackingMode = self.headingEnabled ? MTUserTrackingModeFollowWithHeading : MTUserTrackingModeNone;
			break;
            
			// if we are currently receiving heading updates, switch back to idle
		case MTUserTrackingModeFollowWithHeading:
			newTrackingMode = MTUserTrackingModeNone;
			// post notification that heading updates stopped
			[[NSNotificationCenter defaultCenter] postNotificationName:kMTLocationManagerDidStopUpdatingHeading object:self userInfo:nil];
			break;
	}
    
	// update to new location status
	[self setTrackingMode:newTrackingMode animated:YES];
    
	// call delegate
    [self.delegate locateMeButton:self didChangeTrackingMode:newTrackingMode];
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

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

#define kShrinkAnimationDuration 0.25
#define kExpandAnimationDuration 0.25
#define kExpandAnimationDelay    0.1

#define kActivityIndicatorInset 12.f
#define kImageViewInset		    10.f


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


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle, Memory Management
////////////////////////////////////////////////////////////////////////


- (id)initWithFrame:(CGRect)frame  {
    if ((self = [super initWithFrame:frame])) {
		activityIndicatorFrame_ = CGRectInset(frame, kActivityIndicatorInset, kActivityIndicatorInset);
		imageViewFrame_ = CGRectInset(frame, kImageViewInset , kImageViewInset);

		locationStatus_ = MTLocationStatusIdle;

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
    [activityIndicator_ release], activityIndicator_ = nil;
	[imageView_ release], imageView_ = nil;

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

- (void)setLocationStatus:(MTLocationStatus)locationStatus {
	locationStatus_ = locationStatus;
	[self updateUI];
}

- (void)setLocationStatus:(MTLocationStatus)locationStatus animated:(BOOL)animated {
	if (animated) {
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


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations
////////////////////////////////////////////////////////////////////////

- (void)locationStatusAnimationShrinkDidFinish:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	NSNumber *locationStatusWrapper = (NSNumber *)context;

	// location status changed, now another subview is visible
	self.locationStatus = [locationStatusWrapper intValue];
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
			[self setImage:[UIImage imageNamed:@"LocateMeButton.png"] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:@"Location.png"];
			self.activeSubview = self.imageView;
			break;

		case MTLocationStatusSearching:
			[self setImage:[UIImage imageNamed:@"LocateMeButtonTrackingPressed.png"] forState:UIControlStateNormal];
			[self.activityIndicator startAnimating];
			self.imageView.image = nil;
			self.activeSubview = self.activityIndicator;
			break;

		case MTLocationStatusReceivingLocationUpdates:
			[self setImage:[UIImage imageNamed:@"LocateMeButtonTrackingPressed.png"] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:@"Location.png"];
			self.activeSubview = self.imageView;
			break;

		case MTLocationStatusReceivingHeadingUpdates:
			[self setImage:[UIImage imageNamed:@"LocateMeButtonTrackingPressed.png"] forState:UIControlStateNormal];
			[self.activityIndicator stopAnimating];
			self.imageView.image = [UIImage imageNamed:@"LocationHeading.png"];
			self.activeSubview = self.imageView;
			break;
	}
}

// is called when the user taps the button
- (void)locationStatusToggled:(id)sender {
	switch (self.locationStatus) {
			// if we are currently idle, search for location
		case MTLocationStatusIdle:
			[self setLocationStatus:MTLocationStatusSearching animated:YES];
			break;

			// if we are currently searching, abort and switch back to idle
		case MTLocationStatusSearching:
			[self setLocationStatus:MTLocationStatusIdle animated:YES];
			break;

			// if we are currently receiving updates next status depends whether heading is supported or not
		case MTLocationStatusReceivingLocationUpdates:
			[self setLocationStatus:self.headingEnabled ? MTLocationStatusReceivingHeadingUpdates : MTLocationStatusIdle animated:YES];
			break;

			// if we are currently receiving heading updates, switch back to idle
		case MTLocationStatusReceivingHeadingUpdates:
			[self setLocationStatus:MTLocationStatusIdle animated:YES];
			break;
	}
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

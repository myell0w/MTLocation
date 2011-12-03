//
// WildcardGestureRecognizer.m
// Created by Raymond Daly on 10/31/10.
// Copyright 2010 Floatopian LLC. All rights reserved.
//

#import "MTTouchesMovedGestureRecognizer.h"

#define kMTTouchesMinimumDuration  0.5


@interface MTTouchesMovedGestureRecognizer ()

@property (nonatomic, strong) NSDate *touchesBeganTimestamp;

@end


@implementation MTTouchesMovedGestureRecognizer

@synthesize touchesMovedCallback = touchesMovedCallback_;
@synthesize touchesBeganTimestamp = touchesBeganTimestamp_;

- (id)init {
	if ((self = [super init])) {
		self.cancelsTouchesInView = NO;
	}

	return self;
}

- (void)dealloc {
    touchesMovedCallback_ = nil;
	touchesBeganTimestamp_ = nil;

}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count >= 2) {
        self.touchesBeganTimestamp = [NSDate date];
    }
}*/

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (/*self.touchesBeganTimestamp != nil && [self.touchesBeganTimestamp timeIntervalSinceNow] < kMTTouchesMinimumDuration &&*/
		touches.count == 1 && self.touchesMovedCallback) {
		self.touchesMovedCallback(touches, event);
	}
}

/*- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.touchesBeganTimestamp = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.touchesBeganTimestamp = nil;
}*/

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	return NO;
}

@end

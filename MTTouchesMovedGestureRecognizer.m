//
// WildcardGestureRecognizer.m
// Created by Raymond Daly on 10/31/10.
// Copyright 2010 Floatopian LLC. All rights reserved.
//

#import "MTTouchesMovedGestureRecognizer.h"


@implementation MTTouchesMovedGestureRecognizer

@synthesize touchesMovedCallback = touchesMovedCallback_;

- (id)init {
	if ((self = [super init])) {
		self.cancelsTouchesInView = NO;
	}

	return self;
}

- (void)dealloc {
    [touchesMovedCallback_ release], touchesMovedCallback_ = nil;

    [super dealloc];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count == 1 && self.touchesMovedCallback) {
		self.touchesMovedCallback(touches, event);
	}
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	return NO;
}

@end

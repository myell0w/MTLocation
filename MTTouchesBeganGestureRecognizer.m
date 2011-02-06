//
// WildcardGestureRecognizer.m
// Created by Raymond Daly on 10/31/10.
// Copyright 2010 Floatopian LLC. All rights reserved.
//

#import "MTTouchesBeganGestureRecognizer.h"


@implementation MTTouchesBeganGestureRecognizer

@synthesize touchesBeganCallback;

- (id)init {
	if ((self = [super init])) {
		self.cancelsTouchesInView = NO;
	}

	return self;
}

- (void)dealloc {
    [touchesBeganCallback release];

    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touchesBeganCallback) {
		touchesBeganCallback(touches, event);
	}
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	return NO;
}

@end

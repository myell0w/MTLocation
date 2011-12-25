//
//  MTTouchesMovedGestureRecognizer.m
// 
//  Created by Floatopian LLC. All rights reserved.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

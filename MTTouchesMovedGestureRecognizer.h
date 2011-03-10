//
//  MTTouchesMovedGestureRecognizer.h
//  Copyright 2010 Floatopian LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface MTTouchesMovedGestureRecognizer : UIGestureRecognizer {
	TouchesEventBlock touchesMovedCallback_;
	NSDate *touchesBeganTimestamp_;
}

@property(copy) TouchesEventBlock touchesMovedCallback;


@end

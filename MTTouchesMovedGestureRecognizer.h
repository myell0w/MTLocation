//
//  MTTouchesMovedGestureRecognizer.h
//  Copyright 2010 Floatopian LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface MTTouchesMovedGestureRecognizer : UIGestureRecognizer 

@property(copy) TouchesEventBlock touchesMovedCallback;

@end

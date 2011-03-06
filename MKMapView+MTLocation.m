//
//  MKMapVIew+MTLocation.m
//
//  Created by Matthias Tretter on 02.03.11.
//  Copyright (c) 2009-2011  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MKMapView+MTLocation.h"

#define kDefaultGoogleBadgeOriginX 12
#define kDefaultGoogleBadgeOriginY 340


@implementation MKMapView (MTLocation)

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Google Badge
////////////////////////////////////////////////////////////////////////

- (void)addGoogleBadge {
    [self addGoogleBadgeAtPoint:CGPointMake(kDefaultGoogleBadgeOriginX, kDefaultGoogleBadgeOriginY)];
}

- (void)addGoogleBadgeAtPoint:(CGPoint)topLeftOfGoogleBadge {
    UIImageView *googleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoogleBadge.png"]] autorelease];
	googleView.frame = CGRectMake(topLeftOfGoogleBadge.x, topLeftOfGoogleBadge.y,
                                  googleView.frame.size.width, googleView.frame.size.height);
	
    [self.superview addSubview:googleView];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation (Heading information)
////////////////////////////////////////////////////////////////////////

- (void)rotateToHeading:(CLHeading *)heading animated:(BOOL)animated {
    double animationDuration = animated ? 0.2 : 0.0;
    
	if (heading.headingAccuracy > 0) {
        if (animated) {
            // if the map is currently not rotated
            // we are just starting the rotation
            // therefore it is possible that there is a big
            // angle between current transformation and the one
            // applied, so we increase the animation duration
            if (CGAffineTransformIsIdentity(self.transform)) {
                if (fabs(heading.magneticHeading) > 135.0) {
                    animationDuration = 0.5;
                } else if (fabs(heading.magneticHeading) > 90.0) {
                    animationDuration = 0.4;
                } else if (fabs(heading.magneticHeading) > 45.0) {
                    animationDuration = 0.3;
                }
            }
        }
        
		// Apply the transformation animated
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 [self setTransform:CGAffineTransformMakeRotation(heading.magneticHeading * M_PI / -180.0)];
                             
                             // rotate annotation-views back so that Pins & Annotations appear non-rotated
                             for (id<MKAnnotation> annotation in self.annotations) {
                                 [[self viewForAnnotation:annotation] setTransform:CGAffineTransformMakeRotation(heading.magneticHeading * M_PI / 180.0)];
                             }
						 }];
	}
    
}

- (void)resetHeadingRotationAnimated:(BOOL)animated {
    // reset rotation of map-view
	[UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         [self setTransform:CGAffineTransformIdentity];
                         
                         // rotate annotation-views back so that Pins & Annotations appear non-rotated
                         for (id<MKAnnotation> annotation in self.annotations) {
                             [[self viewForAnnotation:annotation] setTransform:CGAffineTransformIdentity];
                         }
                     }];
}

@end

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
#import "MTLocation.h"
#import "MTLocationFunctions.h"
#import <objc/runtime.h>

#define kDefaultGoogleBadgeOriginX 12
#define kDefaultGoogleBadgeYOffset 27

static char headingAngleViewKey;

@implementation MKMapView (MTLocation)

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)mapViewInSuperview:(UIView *)superview {
    MKMapView *mapView = [[[self class] alloc] initWithFrame:CGRectZero];

    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [superview addSubview:mapView];
    [mapView sizeToFitTrackingModeFollowWithHeading];
    [mapView addGoogleBadge];
    [mapView addHeadingAngleView];
    
    return mapView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding Overlay Views
////////////////////////////////////////////////////////////////////////

- (void)sizeToFitTrackingModeFollowWithHeading {
    if (MTLocationUsesNewAPIs()) {
        self.frame = self.superview.bounds;
    } else {
        CGRect newFrame = self.frame;
        CGRect bounds = self.superview.bounds;
        // pythagoras ftw.
        CGFloat superviewDiagonal = ceilf(sqrtf(bounds.size.width * bounds.size.width + bounds.size.height * bounds.size.height));
        
        // set new size of frame
        newFrame.size.width = superviewDiagonal + 5.f;
        newFrame.size.height = superviewDiagonal + 5.f;
        self.frame = newFrame;
        
        // center in superview
        self.center = self.superview.center;
        self.frame = CGRectIntegral(self.frame);
    } 
}

- (void)addGoogleBadge {
    CGPoint p;
    
    p.x = kDefaultGoogleBadgeOriginX;
    p.y = self.superview.frame.origin.y + self.superview.frame.size.height - kDefaultGoogleBadgeYOffset;
    
    [self addGoogleBadgeAtPoint:p];
}

- (void)addGoogleBadgeAtPoint:(CGPoint)topLeftOfGoogleBadge {
    if (!MTLocationUsesNewAPIs()) {
        UIImageView *googleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoogleBadge.png"]];
        googleView.tag = kMTLocationGoogleBadgeTag;
        googleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        googleView.frame = CGRectMake(topLeftOfGoogleBadge.x, topLeftOfGoogleBadge.y,
                                      googleView.frame.size.width, googleView.frame.size.height);
        
        [self.superview addSubview:googleView];
    }
}

- (void)addHeadingAngleView {
    if (!MTLocationUsesNewAPIs()) {
        UIImageView *headingAngleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeadingAngleSmall.png"]];
        headingAngleView.hidden = YES;
        headingAngleView.tag = kMTLocationHeadingViewTag;
        
        // add to superview
        [self.superview addSubview:headingAngleView];
        // add as associated object to MapView
        objc_setAssociatedObject(self, &headingAngleViewKey, headingAngleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)showHeadingAngleView {
    if (!MTLocationUsesNewAPIs()) {
        id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
        
        [headingAngleView setHidden:NO];
    }
}

- (void)hideHeadingAngleView {
    if (!MTLocationUsesNewAPIs()) {
        id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
        
        [headingAngleView setHidden:YES];
    }
}

- (void)moveHeadingAngleViewToCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!MTLocationUsesNewAPIs()) {
        CGPoint center = [self convertCoordinate:coordinate toPointToView:self.superview];
        id headingAngleView = objc_getAssociatedObject(self, &headingAngleViewKey);
        
        center.y -= [headingAngleView frame].size.height/2 + 8;
        [headingAngleView setCenter:center];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation (Heading information)
////////////////////////////////////////////////////////////////////////

- (void)rotateToHeading:(CLHeading *)heading {
    [self rotateToHeading:heading animated:YES];
}

- (void)rotateToHeading:(CLHeading *)heading animated:(BOOL)animated {
    if (!MTLocationUsesNewAPIs()) {
        MTRotateViewToHeading(self, heading, animated);
    }
}

- (void)resetHeadingRotation {
    [self resetHeadingRotationAnimated:YES];
}

- (void)resetHeadingRotationAnimated:(BOOL)animated {
    if (!MTLocationUsesNewAPIs()) {
        MTResetViewRotation(self, animated);
    }
}

@end

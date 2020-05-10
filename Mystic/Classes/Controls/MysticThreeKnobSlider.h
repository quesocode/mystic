//
//  MysticThreeKnobSlider.h
//  Mystic
//
//  Created by Travis A. Weerts on 8/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticSlider.h"

@interface MysticThreeKnobSlider : MysticSlider
{
    UIImage *_midHandleImageNormal, *_midHandleImageHighlighted;
}

// default 0.0
@property(assign, nonatomic) float midValue;

// default 0.0. This is the minimum distance between between the upper and lower values
@property(assign, nonatomic) float minimumMidRange;
@property(readonly, nonatomic) float midDistanceBetween;
@property(assign, nonatomic) float lastMidDistanceBetween;




// center location for the lower handle control
@property(readonly, nonatomic) CGPoint midCenter;



@property (assign, nonatomic) UIEdgeInsets midTouchEdgeInsets;

@property (assign, nonatomic) BOOL midHandleHidden;

@property (assign, nonatomic) float midHandleHiddenWidth;

// Images, these should be set before the control is displayed.
// If they are not set, then the default images are used.
// eg viewDidLoad


//Probably should add support for all control states... Anyone?

@property(retain, nonatomic) UIImage* midHandleImageNormal;
@property(retain, nonatomic) UIImage* midHandleImageHighlighted;


@property (nonatomic, assign) BOOL midHandleDisabled;


//Setting the lower/upper values with an animation :-)
- (void)setMidValue:(float)lowerValue animated:(BOOL) animated;

- (float) midValueFromRange:(MFRange)range;
- (float) midValueFromUpperAndLower;
- (float) midValueFromMinAndMax;



// customizations
//@property(assign, nonatomic) float lastMidValue;
- (void) setLowerValue:(float) lowerValue upperValue:(float)upperValue midValue:(float)midValue animated:(BOOL)animated complete:(MysticBlockBOOL)completeBlock;
- (void)setMidValue:(float)upperValue animated:(BOOL)animated complete:(MysticBlockBOOL)completed;

@property (retain, nonatomic) UIImageView* midHandle;
@end

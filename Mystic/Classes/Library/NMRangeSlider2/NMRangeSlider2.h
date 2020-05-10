//
//  RangeSlider.h
//  RangeSlider
//
//  Created by Murray Hughes on 04/08/2012
//  Copyright 2011 Null Monkey Pty Ltd. All rights reserved.
//
// Inspried by: https://github.com/buildmobile/iosrangeslider

#import <UIKit/UIKit.h>
#import "MysticTypedefs.h"
#import "MysticConstants.h"





@interface NMRangeSlider2 : UIControl
{
    UIImage *_trackBackgroundImage, *_trackImage, *_trackCrossedOverImage, *_lowerHandleImageNormal, *_lowerHandleImageHighlighted, *_upperHandleImageNormal, *_upperHandleImageHighlighted;
    float _lastMidValue, _lastUpperValue, _lastLowerValue, _upperValue, _lowerValue, _upperRealValue, _lowerRealValue, _minimumValue, _maximumValue, _minimumRealValue, _maximumRealValue, _minimumRange;
}
@property (retain, nonatomic) UIImageView* track;
@property (retain, nonatomic) UIImageView* trackBackground;

// default 0.0
@property(assign, nonatomic) float minimumValue;
@property(assign, nonatomic) BOOL isVertical, verticalAlignmentBottom, ignoreImageForTrackBackground, ignoreImageForTrack, ignoreImageForLowerHandle, ignoreImageForUpperHandle, ignoreImageForTrackCrossover, ignoreTrackBackgroundLayout, ignoreTrackLayout, ignoreUpperHandleLayout, ignoreLowerHandleLayout;
// default 1.0
@property(assign, nonatomic) float maximumValue;

@property (nonatomic, assign) BOOL useProportionalValues, debug, ignoreMinimumChange;
@property (nonatomic, assign) float proportionLowerValue, proportionPercent;
@property (nonatomic, assign) float change;
@property(assign, nonatomic) float minimumRealValue;
@property(assign, nonatomic) float maximumRealValue;
@property(assign, nonatomic) float upperRealValue;
@property(assign, nonatomic) float lowerRealValue;

// default 0.0. This is the minimum distance between between the upper and lower values
@property(assign, nonatomic) float minimumRange;
@property(assign, nonatomic) CGSize thumbSize, lowerThumbSize;
// default 0.0 (disabled)
@property(assign, nonatomic) float stepValue;
@property(assign, nonatomic) float minimumValueChange;

@property(nonatomic, readonly) float minMaxRange;
// If NO the slider will move freely with the tounch. When the touch ends, the value will snap to the nearest step value
// If YES the slider will stay in its current position until it reaches a new step value.
// default NO
@property(assign, nonatomic) BOOL stepValueContinuously;

// defafult YES, indicating whether changes in the sliders value generate continuous update events.
@property(assign, nonatomic) BOOL continuous;

// default 0.0. this value will be pinned to min/max
@property(assign, nonatomic) float lowerValue;

// default 1.0. this value will be pinned to min/max
@property(assign, nonatomic) float upperValue;

// center location for the lower handle control
@property(readonly, nonatomic) CGPoint lowerCenter;

// center location for the upper handle control
@property(readonly, nonatomic) CGPoint upperCenter;

// maximum value for left thumb
@property(assign, nonatomic) float lowerMaximumValue;

// minimum value for right thumb
@property(assign, nonatomic) float upperMinimumValue;

@property (assign, nonatomic) UIEdgeInsets lowerTouchEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets upperTouchEdgeInsets;

@property (assign, nonatomic) BOOL lowerHandleHidden;
@property (assign, nonatomic) BOOL upperHandleHidden;

@property (assign, nonatomic) float lowerHandleHiddenWidth;
@property (assign, nonatomic) float upperHandleHiddenWidth;

// Images, these should be set before the control is displayed.
// If they are not set, then the default images are used.
// eg viewDidLoad


//Probably should add support for all control states... Anyone?
@property(retain, nonatomic) UIImage* lowerHandleImageNormal;
@property(retain, nonatomic) UIImage* lowerHandleImageHighlighted;

@property(retain, nonatomic) UIImage* upperHandleImageNormal;
@property(retain, nonatomic) UIImage* upperHandleImageHighlighted;

@property(retain, nonatomic) UIImage* trackImage;

// track image when lower value is higher than the upper value (eg. when minimum range is negative
@property(retain, nonatomic) UIImage* trackCrossedOverImage;

@property(retain, nonatomic) UIImage* trackBackgroundImage;


@property (nonatomic, assign) BOOL lowerHandleDisabled;


//Setting the lower/upper values with an animation :-)
- (void)setLowerValue:(float)lowerValue animated:(BOOL) animated;

- (void)setUpperValue:(float)upperValue animated:(BOOL) animated;
- (CGRect)thumbRectForValue:(float)value image:(UIImage*) thumbImage;
- (void) addSubviews;

//- (void) setLowerValue:(float) lowerValue upperValue:(float) upperValue animated:(BOOL)animated;

// customizations
@property(assign, nonatomic) float lastUpperValue, lastLowerValue, lastMidValue, snapThreshold;
@property(retain, nonatomic) NSArray *snapPoints, *snapPointsLower, *snapPointsMid;
@property(assign, nonatomic) BOOL snapping, blockEvents, backgroundTrackEnabled, blockEventsBegin, blockEventsEnd;
@property(assign, nonatomic) float defaultLowerValue, defaultUpperValue;
@property(readonly, nonatomic) CGRect trackRect, trackBackgroundRect, thumbRect, lowerThumbRect, midThumbRect;

- (void) setLowerValue:(float) lowerValue upperValue:(float) upperValue animated:(BOOL)animated complete:(MysticBlockBOOL)completeBlock;
- (void)setUpperValue:(float)upperValue animated:(BOOL)animated complete:(MysticBlockBOOL)completed;
- (void)setLowerValue:(float)lowerValue animated:(BOOL) animated complete:(MysticBlockBOOL)completed;
- (void) reset;
- (void) commitValues;
- (void) resetValues;
- (void) configureView;
@property (retain, nonatomic) UIImageView* lowerHandle;
@property (retain, nonatomic) UIImageView* upperHandle;
-(CGRect) trackBackgroundRect;
- (CGRect)trackRect;
- (UIImage*) trackImageForCurrentValues;

@end

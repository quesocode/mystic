

//
//  MysticThreeKnobSlider.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticThreeKnobSlider.h"
#import "PackPotionOption.h"
#import "UIView+Mystic.h"

#define IS_PRE_IOS7() (DeviceSystemMajorVersion() < 7)



@interface MysticThreeKnobSlider ()
{
    float _midTouchOffset;
    float _stepValueInternal;
    BOOL _haveAddedSubviews;
}


@end



@implementation MysticThreeKnobSlider

- (void) reset;
{
    UIImage *image;
    
    if(!_upperHandleImageNormal)
    {
        image = [UIImage imageNamed:@"slider-mystic-handle-light"];
        self.upperHandleImageNormal = image;
        self.upperHandleImageHighlighted = self.upperHandleImageNormal;
    }
    
    if(!_lowerHandleImageNormal)
    {
        image = [UIImage imageNamed:@"slider-mystic-handle-dark"];
        self.lowerHandleImageNormal = image;
        self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
    }
    
    if(!_midHandleImageNormal)
    {
        image = [UIImage imageNamed:@"slider-mystic-handle-mid"];
        self.midHandleImageNormal = image;
        self.midHandleImageHighlighted = self.midHandleImageNormal;
    }

    
    if(!_trackImage)
    {
        self.trackImage = [UIImage imageNamed:@"slider-mystic-track-normal"];
    }
    [super reset];
    self.lowerHandleDisabled = NO;


    
}

- (void) resetValues;
{
    [super resetValues];
    _midValue = 0.5;
    _lastMidValue = 0.5;
    _midDistanceBetween = 0.5;
    _minimumMidRange = 0.0;
}
- (void) resetValue:(BOOL)animated;
{
    [self resetLastValue:animated ? @(0.25) : nil finished:nil];
}
- (void) resetToDefaultValues;
{
    [self resetToDefaultValues:nil finished:nil];
}
- (void) resetToDefaultValues:(id)animated finished:(MysticBlockAnimationFinished)finished;
{
    float l = !isnan(self.defaultLowerValue) ? self.defaultLowerValue : self.minimumValue;
    float u = !isnan(self.defaultUpperValue) ? self.defaultUpperValue : self.maximumValue;
    float m = !isnan(self.defaultValue) ? self.defaultValue : [self midValueFromRange:MFRangeMake(l, u)];
    [self setLowerValue:l upperValue:u midValue:m animDuration:animated complete:finished];
}
- (void) resetLastValue:(BOOL)animated finished:(MysticBlockAnimationFinished)finished;
{
    
    
    float l = !isnan(self.lastLowerValue) ? self.lastLowerValue : self.minimumValue;
    float u = !isnan(self.lastUpperValue) ? self.lastUpperValue : self.maximumValue;
    float m = !isnan(self.lastMidValue) ? self.lastMidValue : self.midValue;
    m = isnan(m) ? [self midValueFromRange:MFRangeMake(l, u)] : m;
    [self setLowerValue:l upperValue:u midValue:m animated:animated complete:finished];
}

- (void) configureView
{
    [super configureView];
    //Setup the default values
    _midValue = 0.5;
    _lastMidValue = _midValue;
    _midDistanceBetween = 0.5;
    _minimumMidRange = 0.0;
    _midHandleDisabled = NO;
    _midHandleHidden = NO;
    _midHandleHiddenWidth = 2.0f;
    _midTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _lowerValue = 0;
    _upperValue = 1;
    _lowerRealValue = 0;
    _upperRealValue = 1;
    _minimumValue = 0;
    _maximumValue = 1;
    _maximumRealValue = 1;
    _minimumRealValue = 0;
    
}

- (void) setMidValue:(float)midValue
{
    float value = midValue;
    if(_stepValueInternal>0) value = roundf(value / _stepValueInternal) * _stepValueInternal;
    value = MIN(value, self.upperValue - self.minimumMidRange);
    value = MAX(value, self.lowerValue + self.minimumMidRange);
    _midValue = value;
    _midDistanceBetween = (_midValue - self.lowerValue)/(self.upperValue - self.lowerValue);
    if(isnan(_lastMidValue)) _lastMidValue = value;
    [self setNeedsLayout];
}
- (float) midValueFromUpperAndLower;
{
    return [self midValueFromRange:MFRangeMakeWithCenterLength(self.lowerValue, self.upperValue, _midDistanceBetween)];
}
- (float) midValueFromMinAndMax;
{
    return [self midValueFromRange:MFRangeMakeWithCenterLength(self.minimumValue, self.maximumValue, _midDistanceBetween)];
}
- (float) midValueFromRange:(MFRange)range;
{
    return range.location + ((range.length - range.location)*range.centerLength);
}

- (void) updateMidValue;
{
    self.midValue = [self midValueFromUpperAndLower];
}
- (void) setLowerValue:(float)lowerValue;
{
    [self setLowerValue:lowerValue updateMid:YES];
}
- (void) setLowerValue:(float)lowerValue updateMid:(BOOL)updateMid;
{
    [super setLowerValue:lowerValue];
    if(updateMid) [self updateMidValue];
}
- (void) setUpperValue:(float)value;
{
    [self setUpperValue:value updateMid:YES];
}
- (void) setUpperValue:(float)value updateMid:(BOOL)updateMid;
{
    [super setUpperValue:value];
    if(updateMid) [self updateMidValue];
}



- (CGPoint) midCenter
{
    return _midHandle.center;
}
- (void) setMidHandleHidden:(BOOL)midHandleHidden;
{
    _midHandleHidden = midHandleHidden;
    [self setNeedsLayout];
}


- (UIImage *)midHandleImageNormal
{
    if(_midHandleImageNormal==nil)
    {
        UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
        _midHandleImageNormal = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
        
    }
    
    return _midHandleImageNormal;
}

- (UIImage *)midHandleImageHighlighted
{
    if(_midHandleImageHighlighted==nil)
    {
        UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
        _midHandleImageHighlighted = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
    }
    
    return _midHandleImageHighlighted;
}


-(float) midValueForCenterX:(float)x
{
    float _padding = _midHandle.frame.size.width/2.0f;
    float value = self.minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (self.maximumValue - self.minimumValue);
    
    value = MAX(value, self.minimumValue + _minimumMidRange);
    value = MIN(value, self.upperValue - _minimumMidRange);
    float range = _maximumRealValue - _minimumRealValue;
    for (NSNumber *snapPoint in self.snapPointsMid) {
        float snapValue = snapPoint.floatValue;
        if((value > snapValue - range*self.snapThreshold && value < snapValue) || (value < snapValue + range*self.snapThreshold && value > snapValue))
        {
            value = snapValue;
            break;
        }
    }
    return value;
}

- (CGRect)thumbRectForValue:(float)value image:(UIImage*) thumbImage
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    
    thumbRect.size = CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    
    if(insets.top || insets.bottom) thumbRect.size.height=self.bounds.size.height;
    float xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - self.minimumValue) / (self.maximumValue - self.minimumValue)));
    thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
    return CGRectIntegral(thumbRect);
    
}

- (void) setMidHandleImageNormal:(UIImage *)midHandleImageNormal;
{
    if(_midHandleImageNormal)
    {
        [_midHandleImageNormal release];
        _midHandleImageNormal=nil;
    }
    _midHandleImageNormal = midHandleImageNormal ? [midHandleImageNormal retain] : nil;
    [self.midHandle setNeedsDisplay];

}
- (void) setMidHandleImageHighlighted:(UIImage *)midHandleImageHighlighted;
{
    if(_midHandleImageHighlighted)
    {
        [_midHandleImageHighlighted release];
        _midHandleImageHighlighted=nil;
    }
    _midHandleImageHighlighted = midHandleImageHighlighted ? [midHandleImageHighlighted retain] : nil;
    [self.midHandle setNeedsDisplay];
}
- (void) addSubviews
{
    if(_haveAddedSubviews==YES) return;
    if(_haveAddedSubviews==NO) _haveAddedSubviews=YES;
    [super addSubviews];
    self.midHandle = [[UIImageView alloc] initWithImage:self.midHandleImageNormal highlightedImage:self.midHandleImageHighlighted];
    self.midHandle.frame = [self thumbRectForValue:_midValue image:self.midHandleImageNormal];
    
    [self addSubview:self.midHandle];
}


-(void)layoutSubviews
{
    if(_haveAddedSubviews==NO) [self addSubviews];
    // Layout the lower handle
    self.midHandle.frame = [self thumbRectForValue:_midValue image:self.midHandleImageNormal];
    self.midHandle.image = self.midHandleImageNormal;
    self.midHandle.highlightedImage = self.midHandleImageHighlighted;
    self.midHandle.hidden = self.midHandleHidden;
    self.trackBackground.frame = [self trackBackgroundRect];
    self.track.frame = [self trackRect];
    self.track.image = [self trackImageForCurrentValues];
    
    // Layout the lower handle
    self.lowerHandle.frame = [self thumbRectForValue:self.lowerValue image:self.lowerHandleImageNormal];
    self.lowerHandle.image = self.lowerHandleImageNormal;
    self.lowerHandle.highlightedImage = self.lowerHandleImageHighlighted;
    self.lowerHandle.hidden = self.lowerHandleHidden;
    
    // Layoput the upper handle
    
    self.upperHandle.frame = [self thumbRectForValue:self.upperValue image:self.upperHandleImageNormal];
    
    
    self.upperHandle.image = self.upperHandleImageNormal;
    self.upperHandle.highlightedImage = self.upperHandleImageHighlighted;
    self.upperHandle.hidden= self.upperHandleHidden;

    
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    
    if(!self.midHandleDisabled &&  CGRectContainsPoint(UIEdgeInsetsInsetRect(_midHandle.frame, self.midTouchEdgeInsets), touchPoint))
    {

        _midHandle.highlighted = YES;
        _midTouchOffset = touchPoint.x - _midHandle.center.x;
    }

    _stepValueInternal= self.stepValueContinuously ? self.stepValue : 0.0f;

    
    return _midHandle.highlighted ? YES : [super beginTrackingWithTouch:touch withEvent:event];
}


-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_midHandle.highlighted && !self.upperHandle.highlighted && !self.lowerHandle.highlighted){
        return YES;
    }
    CGPoint touchPoint = [touch locationInView:self];
    if(_midHandle.highlighted )
    {
        float newValue = [self midValueForCenterX:(touchPoint.x - _midTouchOffset)];
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if(!self.lowerHandle.highlighted && !self.upperHandle.highlighted)
        {
            self.lowerHandle.highlighted=NO;
            self.upperHandle.highlighted=NO;
            [self bringSubviewToFront:_midHandle];
            [self bringSubviewToFront:self.upperHandle];
            [self bringSubviewToFront:self.lowerHandle];
            [self setMidValue:newValue animated:self.stepValueContinuously ? YES : NO];
        }
        else
        {
            _midHandle.highlighted=NO;
        }
    }
    BOOL shouldContinue = _midHandle.highlighted;

    
    //send the control event
    if(self.continuous) [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    //redraw
    [self setNeedsLayout];
    
    return shouldContinue ? shouldContinue : [super continueTrackingWithTouch:touch withEvent:event];
}



-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _midHandle.highlighted = NO;
    
    if(self.stepValue>0)
    {
        _stepValueInternal=self.stepValue;
        
        if(!self.midHandleDisabled) [self setMidValue:_midValue animated:YES];
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}




- (void)setMidValue:(float)midValue animated:(BOOL) animated;
{
    [self setLowerValue:NAN upperValue:NAN midValue:midValue animated:animated complete:nil];
}
- (void)setMidValue:(float)midValue animated:(BOOL)animated complete:(MysticBlockBOOL)completed;
{
    [self setLowerValue:NAN upperValue:NAN midValue:midValue animated:animated complete:completed];
}

- (void) setLowerValue:(float) lowerValue upperValue:(float)upperValue midValue:(float)midValue animated:(BOOL)animated complete:(MysticBlockBOOL)completeBlock;
{
    [self setLowerValue:lowerValue upperValue:upperValue midValue:midValue animDuration:animated ? @(0.25) : nil complete:completeBlock];
}
- (void) setLowerValue:(float) lowerValue upperValue:(float)upperValue midValue:(float)midValue animDuration:(id)animatedDuration complete:(MysticBlockBOOL)completeBlock;
{
    BOOL animated = animatedDuration && [animatedDuration floatValue] > 0;
    if((!animated) && (isnan(midValue) || midValue==self.midValue) && (isnan(upperValue) || upperValue==self.upperValue) && (isnan(lowerValue) || lowerValue==self.lowerValue))
    {
        //nothing to set
        if(completeBlock) completeBlock(YES);
        return;
    }
    __unsafe_unretained __block id weakSelf = self;
    float l = isnan(lowerValue) ? self.lowerValue : lowerValue;
    float u = isnan(upperValue) ? self.upperValue : upperValue;
    float m = isnan(midValue) ? self.midValue : midValue;

    _midValue = m;
    _midDistanceBetween = (m - l)/(u - l);

    
    
    __block void (^setValuesBlock)(void) = ^ {
        if(!isnan(midValue))
        {
            [weakSelf setMidValue:midValue];
        }

        if(!isnan(lowerValue))
        {
            [weakSelf setLowerValue:lowerValue updateMid:NO];
        }
        if(!isnan(upperValue))
        {
            [weakSelf setUpperValue:upperValue updateMid:NO];
        }

        
    };
    __block __strong MysticBlockBOOL _c = completeBlock ? completeBlock : nil;

    if(animated)
    {
        [MysticUIView animateWithDuration:[animatedDuration floatValue]  delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut
                         animations:^{
                             
                             setValuesBlock();
                             [weakSelf layoutSubviews];
                             setValuesBlock = nil;
                             
                         } completion:^(BOOL finished) {
                             [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
                             if(_c) { _c(finished); _c = nil; }
                         }];
        
    }
    else
    {
        setValuesBlock();
        setValuesBlock = nil;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if(completeBlock) completeBlock(YES);
        _c = nil;
    }
}





@end

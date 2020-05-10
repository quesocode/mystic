//
//  RangeSlider.m
//  RangeSlider
//
//  Created by Murray Hughes on 04/08/2012
//  Copyright 2011 Null Monkey Pty Ltd. All rights reserved.
//

#import "NMRangeSlider2.h"


#define IS_PRE_IOS7() (DeviceSystemMajorVersion() < 7)

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}



@interface NMRangeSlider2 ()
{
    float _lowerTouchOffset;
    float _upperTouchOffset;
    float _stepValueInternal;
    BOOL _haveAddedSubviews;
    
}






@end


@implementation NMRangeSlider2

@synthesize upperValue=_upperValue, lowerValue=_lowerValue, maximumValue=_maximumValue, minimumValue=_minimumValue;
#pragma mark -
#pragma mark - Constructors

- (id)init
{
    self = [super init];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureView];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) [self configureView];
    return self;
}


- (void) configureView
{
    _snapThreshold = 0.01;
    _thumbSize = CGSizeUnknown;
    _lowerThumbSize = CGSizeUnknown;
    _proportionPercent = 0.5;
    _useProportionalValues = NO;
    _ignoreMinimumChange = NO;
    //Setup the default values
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _minimumRange = 0.0;
    _stepValue = 0.0;
    _stepValueInternal = 0.0;
    _continuous = YES;
    _lowerValue = NAN;
    _upperValue = NAN;
    _upperRealValue = _upperValue;
    _lowerRealValue = _lowerValue;
    _defaultLowerValue = NAN;
    _defaultUpperValue = NAN;
    _lowerMaximumValue = NAN;
    _upperMinimumValue = NAN;
    _upperHandleHidden = NO;
    _lowerHandleHidden = NO;
    _blockEvents = NO;
    _lastLowerValue = _lowerValue;
    _lastUpperValue = _upperValue;
    _lastMidValue = NAN;
    _lowerHandleHiddenWidth = 2.0f;
    _upperHandleHiddenWidth = 2.0f;
    _lowerTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _upperTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _backgroundTrackEnabled = YES;
    _change = 0;
}



// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Properties
- (CGPoint) lowerCenter
{
    return _lowerHandle.center;
}

- (CGPoint) upperCenter
{
    return _upperHandle.center;
}

- (void) setMinimumValue:(float)minimumValue;
{
    _minimumValue = minimumValue;
    _minimumRealValue = minimumValue;
    if(self.useProportionalValues)
    {
        _minimumValue = 0;
    }
}
- (void) setMaximumValue:(float)value;
{
    _maximumValue = value;
    _maximumRealValue = value;
    if(self.useProportionalValues)
    {
        _maximumValue = 1;
    }
}
- (void) setLowerValue:(float)lowerValue
{
    float value = lowerValue;
    
    if(_stepValueInternal>0)
    {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
    }
    
    value = MIN(value, _maximumRealValue);
    value = MAX(value, _minimumRealValue);
    
    if (!isnan(_lowerMaximumValue)) {
        value = MIN(value, _lowerMaximumValue);
    }
    
    value = isnan(_upperRealValue) ? value : MIN(value, _upperRealValue - _minimumRange);
    
    _lowerRealValue = value;
    
    float v = [self proportionalValueFor:value debug:@"setLowerValue"];
    
    _lowerValue = v;
    
    if(isnan(_lastLowerValue))
    {
        _lastLowerValue = _lowerRealValue;
    }
    [self setNeedsLayout];
}

- (void) setUpperValue:(float)upperValue
{
    float value = upperValue;
    if(_stepValueInternal>0)
    {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
        
    }
    
    value = MAX(value, _minimumRealValue);
    value = MIN(value, _maximumRealValue);
    
    if (!isnan(_upperMinimumValue))  value = MAX(value, _upperMinimumValue);
    
    value = isnan(_lowerRealValue) ? value : MAX(value, _lowerRealValue+_minimumRange);
    _upperRealValue = value;
    
    float v = [self proportionalValueFor:value debug:@"setUpperValue"];
    
    _upperValue = v;
    if(isnan(_lastUpperValue))
    {
        _lastUpperValue = _upperRealValue;
    }
    [self setNeedsLayout];
}



- (float) proportionalValueFor:(float)value debug:(NSString *)debug;
{
    //    NSAssert(isnan(value), [@"Setting NAN to: " stringByAppendingString:debug ? debug : @""]);
    float v = value;
    float b = -1, r=-1;
    if(self.useProportionalValues)
    {
        if(v <= self.proportionLowerValue)
        {
            r = self.proportionLowerValue - _minimumRealValue;
            b = fabsf(v/(r*-1));
            v = _minimumRealValue < 0 ? self.proportionPercent - (self.proportionPercent *b) : (self.proportionPercent *b);
        }
        else
        {
            r = _maximumRealValue - self.proportionLowerValue;
            b = (v - self.proportionLowerValue)/r;
            v = self.proportionPercent + ((1-self.proportionPercent) *b);
        }
        
    }
    if(self.debug && debug) NSLog(@"\t%d    %@    |   r: %2.2f  |    b: %2.2f    |    %@ %2.2f = %2.2f",  (int)self.tag, debug, r, b, value <= self.proportionLowerValue ? @"less" : @"more", value, v);
    return v;
}

- (void) setLowerValue:(float) lowerValue upperValue:(float) upperValue animated:(BOOL)animated complete:(MysticBlockBOOL)completeBlock;
{
    [self setLowerValue:lowerValue upperValue:upperValue animDuration:animated ? @(0.25) : nil complete:completeBlock];
}
- (void) setLowerValue:(float) lowerValue upperValue:(float) upperValue animDuration:(id)animatedDuration complete:(MysticBlockBOOL)completeBlock;
{
    BOOL animated = animatedDuration && [animatedDuration floatValue] > 0;
    if(!animated && (isnan(lowerValue) || lowerValue==_lowerRealValue) && (isnan(upperValue) || upperValue==_upperRealValue))
    {
        if(completeBlock) completeBlock(YES);
        return;
    }
    __unsafe_unretained __block NMRangeSlider2 *weakSelf = self;
    __block __strong MysticBlockBOOL _c = completeBlock ? completeBlock : nil;
    __block void (^setValuesBlock)(void) = ^ {
        if(!isnan(lowerValue)) [weakSelf setLowerValue:lowerValue];
        if(!isnan(upperValue)) [weakSelf setUpperValue:upperValue];
    };
    if(animated)
    {
        BOOL _shouldBlock = weakSelf.blockEvents;
        [UIView animateWithDuration:[animatedDuration floatValue] delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut
                         animations:^{
                             setValuesBlock(); setValuesBlock = nil;
                             [weakSelf layoutSubviews];
                         } completion:^(BOOL f) {
                             if(!_shouldBlock) [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
                             if(_c) { _c(f); _c=nil; }
                         }];
    }
    else
    {
        setValuesBlock(); setValuesBlock = nil;
        if(!weakSelf.blockEvents) [self sendActionsForControlEvents:UIControlEventValueChanged];
        if(completeBlock) completeBlock(YES);
        _c = nil;
    }
}
- (BOOL) blockEvents; { return (_blockEvents || (!_ignoreMinimumChange && !isnan(_minimumValueChange) && _change <= _minimumValueChange)); }
- (BOOL) blockEventsEnd; { return _blockEvents; }
- (BOOL) blockEventsBegin; { return _blockEvents; }

- (void)setLowerValue:(float)lowerValue animated:(BOOL)animated { [self setLowerValue:lowerValue upperValue:NAN animated:animated complete:nil]; }
- (void)setUpperValue:(float)upperValue animated:(BOOL)animated { [self setLowerValue:NAN upperValue:upperValue animated:animated complete:nil]; }

- (void) setLowerHandleHidden:(BOOL)lowerHandleHidden
{
    _lowerHandleHidden = lowerHandleHidden;
    [self setNeedsLayout];
}

- (void) setUpperHandleHidden:(BOOL)upperHandleHidden
{
    _upperHandleHidden = upperHandleHidden;
    [self setNeedsLayout];
}

//ON-Demand images. If the images are not set, then the default values are loaded.

- (UIImage *)trackBackgroundImage
{
    if(self.ignoreImageForTrackBackground) return nil;

    if(_trackBackgroundImage==nil)
    {
        if(IS_PRE_IOS7())
        {
            UIImage* image = [UIImage imageNamed:@"slider-default-trackBackground"];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
            _trackBackgroundImage = image;
        }
        else
        {
            UIImage* image = [UIImage imageNamed:@"slider-default7-trackBackground"];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
            _trackBackgroundImage = image;
        }
    }
    
    return _trackBackgroundImage;
}

- (UIImage *)trackImage
{
    if(self.ignoreImageForTrack) return nil;
    if(_trackImage==nil)
    {
        if(IS_PRE_IOS7())
        {
            _trackImage = [[UIImage imageNamed:@"slider-default-track"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
        }
        else
        {
            _trackImage = [[[UIImage imageNamed:@"slider-default7-track"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    return _trackImage;
}


- (UIImage *)trackCrossedOverImage
{
    if(self.ignoreImageForTrackCrossover) return nil;

    if(_trackCrossedOverImage==nil)
    {
        if(IS_PRE_IOS7())
        {
            _trackCrossedOverImage = [[UIImage imageNamed:@"slider-default-trackCrossedOver"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
        }
        else
        {
            _trackCrossedOverImage = [[UIImage imageNamed:@"slider-default7-trackCrossedOver"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
        }
    }
    
    return _trackCrossedOverImage;
}

- (UIImage *)lowerHandleImageNormal
{
    if(self.ignoreImageForLowerHandle) return nil;

    if(_lowerHandleImageNormal==nil)
    {
        if(IS_PRE_IOS7())
        {
            UIImage* image = [UIImage imageNamed:@"slider-default-handle"];
            _lowerHandleImageNormal = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        }
        else
        {
            UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
            _lowerHandleImageNormal = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
        }
        
    }
    
    return _lowerHandleImageNormal;
}

- (UIImage *)lowerHandleImageHighlighted
{
    if(self.ignoreImageForLowerHandle) return nil;

    if(_lowerHandleImageHighlighted==nil)
    {
        if(IS_PRE_IOS7())
        {
            UIImage* image = [UIImage imageNamed:@"slider-default-handle-highlighted"];
            _lowerHandleImageHighlighted = image;
            _lowerHandleImageHighlighted = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
            
        }
        else
        {
            UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
            _lowerHandleImageHighlighted = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
        }
    }
    
    return _lowerHandleImageHighlighted;
}

- (UIImage *)upperHandleImageNormal
{
    if(self.ignoreImageForUpperHandle) return nil;

    if(_upperHandleImageNormal==nil)
    {
        if(IS_PRE_IOS7())
        {
            UIImage* image = [UIImage imageNamed:@"slider-default-handle"];
            _upperHandleImageNormal = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
            
        }
        else
        {
            UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
            _upperHandleImageNormal = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
        }
    }
    
    return _upperHandleImageNormal;
}

- (UIImage *)upperHandleImageHighlighted
{
    if(self.ignoreImageForUpperHandle) return nil;

    if(_upperHandleImageHighlighted==nil)
    {
        if(IS_PRE_IOS7())
        {
            UIImage* image = [UIImage imageNamed:@"slider-default-handle-highlighted"];
            _upperHandleImageHighlighted = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        }
        else
        {
            UIImage* image = [UIImage imageNamed:@"slider-default7-handle"];
            _upperHandleImageHighlighted = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
        }
    }
    
    return _upperHandleImageHighlighted;
}

// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Math Math Math

//Returns the lower value based on the X potion
//The return value is automatically adjust to fit inside the valid range
-(float) lowerValueForCenterX:(float)x
{
    float _padding = self.isVertical ?  _lowerHandle.frame.size.height/2.0f :  _lowerHandle.frame.size.width/2.0f;
    float value;
    if(self.useProportionalValues)
    {
        float w = (self.isVertical ? self.frame.size.height : self.frame.size.width);
        float c = (self.isVertical ? self.frame.size.height : self.frame.size.width) * self.proportionPercent;
        if(x <= c)
        {
            float r = self.proportionLowerValue - _minimumRealValue;
            value = self.proportionLowerValue - (r * (1-(x/c)));
        }
        else
        {
            float wc = (self.isVertical ? self.frame.size.height : self.frame.size.width) - c;
            float r = _maximumRealValue - self.proportionLowerValue;
            value = self.proportionLowerValue + (r *((x-c)/wc));
        }
    }
    else
    {
        value = _minimumRealValue + (x-_padding) / ((self.isVertical ? self.frame.size.height : self.frame.size.width)-(_padding*2)) * (_maximumRealValue - _minimumRealValue);
    }
    value = MAX(value, _minimumRealValue);
    value = MIN(value, _upperRealValue - _minimumRange);
    float range = _maximumRealValue - _minimumRealValue;
    for (NSNumber *snapPoint in self.snapPointsLower) {
        float snapValue = snapPoint.floatValue;
        if((value > snapValue - range*_snapThreshold && value < snapValue) || (value < snapValue + range*_snapThreshold && value > snapValue))
        {
            value = snapValue;
            break;
        }
    }
    return value;
}
- (BOOL) snapping; { return self.snapPoints.count > 0; }
//Returns the upper value based on the X potion
//The return value is automatically adjust to fit inside the valid range
-(float) upperValueForCenterX:(float)x
{
    float _padding = self.isVertical ? _upperHandle.frame.size.height/2 : _upperHandle.frame.size.width/2.0;
    float value;
    if(self.useProportionalValues)
    {
        float w = self.isVertical ? self.bounds.size.height : self.bounds.size.width;
        float c = w * self.proportionPercent;
        float r;
        if(x <= c)
        {
            r = self.proportionLowerValue - _minimumRealValue; // 1
            value = self.proportionLowerValue - (r * (1-(x/c)));
        }
        else
        {
            w = (self.isVertical ? self.bounds.size.height : self.bounds.size.width) - c;
            r = _maximumRealValue - self.proportionLowerValue;
            value = self.proportionLowerValue + (r *((x-c)/w));
        }
        
        if(self.debug) NSLog(@"\t\t upperValueForX:  r: %2.2f  |  c: %2.2f  |  x: %2.2f / w: %2.2f  =  %2.2f", r, c, x, w, value);
        
    }
    else
    {
        value = _minimumRealValue + (x-_padding) / ((self.isVertical ? self.frame.size.height : self.frame.size.width)-(_padding*2)) * (_maximumRealValue - _minimumRealValue);
    }
    value = MIN(value, _maximumRealValue);
    value = MAX(value, _lowerRealValue+_minimumRange);
    
    float range = _maximumRealValue - _minimumRealValue;
    for (NSNumber *snapPoint in self.snapPoints) {
        float snapValue = snapPoint.floatValue;
        if((value > snapValue - range*_snapThreshold && value < snapValue) || (value < snapValue + range*_snapThreshold && value > snapValue))
        {
            value = snapValue;
            break;
        }
    }
    return value;
}

- (UIEdgeInsets) trackAlignmentInsets
{
    UIEdgeInsets lowerAlignmentInsets = self.lowerHandleImageNormal.alignmentRectInsets;
    UIEdgeInsets upperAlignmentInsets = self.upperHandleImageNormal.alignmentRectInsets;
    
    CGFloat lowerOffset = MAX(lowerAlignmentInsets.right, upperAlignmentInsets.left);
    CGFloat upperOffset = MAX(upperAlignmentInsets.right, lowerAlignmentInsets.left);
    
    CGFloat leftOffset = MAX(lowerOffset, upperOffset);
    CGFloat rightOffset = leftOffset;
    CGFloat topOffset = lowerAlignmentInsets.top;
    CGFloat bottomOffset = lowerAlignmentInsets.bottom;
    
    return UIEdgeInsetsMake(topOffset, leftOffset, bottomOffset, rightOffset);
}


//returns the rect for the track image between the lower and upper values based on the trackimage object
- (CGRect)trackRect
{
    CGRect retValue;
    
    UIImage* currentTrackImage = [self trackImageForCurrentValues];
    
    retValue.size = CGSizeMake(currentTrackImage.size.width, currentTrackImage.size.height);
    
    if(currentTrackImage.capInsets.top || currentTrackImage.capInsets.bottom)
    {
        if(!self.isVertical) retValue.size.height=self.bounds.size.height;
        else retValue.size.width=self.bounds.size.width;
    }
    
    if(!self.isVertical)
    {
        float lowerHandleWidth = _lowerHandleHidden ? _lowerHandleHiddenWidth : _lowerHandle.frame.size.width;
        float upperHandleWidth = _upperHandleHidden ? _upperHandleHiddenWidth : _upperHandle.frame.size.width;
        
        float xLowerValue = ((self.bounds.size.width - lowerHandleWidth) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(lowerHandleWidth/2.0f);
        float xUpperValue = ((self.bounds.size.width - upperHandleWidth) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(upperHandleWidth/2.0f);
        
        retValue.origin = CGPointMake(xLowerValue, (self.bounds.size.height/2.0f) - (retValue.size.height/2.0f));
        retValue.size.width = xUpperValue-xLowerValue;
    }
    else
    {
        float lowerHandleWidth = _lowerHandleHidden ? _lowerHandleHiddenWidth : _lowerHandle.frame.size.height;
        float upperHandleWidth = _upperHandleHidden ? _upperHandleHiddenWidth : _upperHandle.frame.size.height;
        
        float yLowerValue = ((self.bounds.size.height - lowerHandleWidth) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(lowerHandleWidth/2.0f);
        
        float yUpperValue = ((self.bounds.size.height - upperHandleWidth) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(upperHandleWidth/2.0f);
//        if(!self.verticalMinimumOnTop)
//        {
//            yLowerValue = (self.bounds.size.height-lowerHandleWidth) - yLowerValue;
//            yUpperValue = (self.bounds.size.height-upperHandleWidth) - yUpperValue;
//
//        }
        retValue.origin = CGPointMake((self.bounds.size.width/2.0f) - (retValue.size.width/2.0f), yLowerValue);
        retValue.size.height = yUpperValue-yLowerValue;
    }
    
    CGRect bins = retValue;
    UIEdgeInsets alignmentInsets = [self trackAlignmentInsets];
    retValue = UIEdgeInsetsInsetRect(retValue,alignmentInsets);
    
    //    if(self.debug)
    //    {
    //        NSLog(@"\t trackRect: %@   | min: %2.2f  |  max: %2.2f  |   l: %2.2f  |  u: %2.2f  |  ins: %@  |  %@", FLogStr(retValue), _minimumValue, _maximumValue, _lowerValue, _upperValue, NSStringFromUIEdgeInsets(alignmentInsets), FLogStr(bins));
    //    }
    return retValue;
}
- (void) setVerticalAlignmentBottom:(BOOL)verticalAlignmentBottom;
{
    BOOL changed = _verticalAlignmentBottom!=verticalAlignmentBottom;
    if(!changed) return;
    _verticalAlignmentBottom=verticalAlignmentBottom;
    if(self.isVertical)
    {
        self.transform = CGAffineTransformScale(self.transform, 1,-1);
    }
}
- (UIImage*) trackImageForCurrentValues
{
    if(self.lowerValue <= self.upperValue)
    {
        return self.trackImage;
    }
    else
    {
        return self.trackCrossedOverImage;
    }
}

//returns the rect for the background image
-(CGRect) trackBackgroundRect
{
    CGRect trackBackgroundRect;
    
    trackBackgroundRect.size = CGSizeMake(_trackBackgroundImage.size.width, _trackBackgroundImage.size.height);
    
    if(_trackBackgroundImage.capInsets.top || _trackBackgroundImage.capInsets.bottom)
    {
        if(!self.isVertical) trackBackgroundRect.size.height=self.bounds.size.height;
        else trackBackgroundRect.size.width=self.bounds.size.width;
    }
    
    if(_trackBackgroundImage.capInsets.left || _trackBackgroundImage.capInsets.right)
    {
        if(self.isVertical) trackBackgroundRect.size.height=self.bounds.size.height;
        else trackBackgroundRect.size.width=self.bounds.size.width;
    }
    
    if(!self.isVertical)  trackBackgroundRect.origin = CGPointMake(0, (self.bounds.size.height/2.0f) - (trackBackgroundRect.size.height/2.0f));
    else trackBackgroundRect.origin = CGPointMake((self.bounds.size.width/2.0f) - (trackBackgroundRect.size.width/2.0f), 0);
    
    // Adjust the track rect based on the image alignment rects
    
    UIEdgeInsets alignmentInsets = [self trackAlignmentInsets];
    trackBackgroundRect = UIEdgeInsetsInsetRect(trackBackgroundRect,alignmentInsets);
    
    return trackBackgroundRect;
}

//returms the rect of the tumb image for a given track rect and value
- (CGRect)thumbRectForValue:(float)valueReal image:(UIImage*) thumbImage;
{
    return [self thumbRectForValue:valueReal image:thumbImage debug:nil];
}
- (CGRect)thumbRectForValue:(float)valueReal image:(UIImage*) thumbImage debug:(NSString *)debug;
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    
    thumbRect.size = !CGSizeIsUnknown(_thumbSize) ? _thumbSize : CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    
    if(insets.top || insets.bottom)
    {
        if(self.isVertical) thumbRect.size.width=self.bounds.size.width;
        else thumbRect.size.height=self.bounds.size.height;
    }
    debug = nil;
    float value = self.useProportionalValues ? [self proportionalValueFor:valueReal debug:debug] : valueReal;
    
    if(self.isVertical)
    {
        float yValue = ((self.bounds.size.height-thumbRect.size.height)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
//        if(!self.verticalMinimumOnTop)
//        {
//            yValue = (self.bounds.size.height-thumbRect.size.height) - yValue;
//        }
        thumbRect.origin = CGPointMake((self.bounds.size.width/2.0f) - (thumbRect.size.width/2.0f), yValue);
    }
    else
    {
        float xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
        thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
    }
    
    
    return CGRectIntegral(thumbRect);
    
}

- (CGRect)lowerThumbRectForValue:(float)valueReal image:(UIImage*) thumbImage;
{
    return [self lowerThumbRectForValue:valueReal image:thumbImage debug:nil];
}
- (CGRect)lowerThumbRectForValue:(float)valueReal image:(UIImage*) thumbImage debug:(NSString *)debug;
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    
    thumbRect.size = !CGSizeIsUnknown(_lowerThumbSize) ? _lowerThumbSize : !CGSizeIsUnknown(_thumbSize) ? _thumbSize : CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    
    if(insets.top || insets.bottom)
    {
        if(self.isVertical) thumbRect.size.width=self.bounds.size.width;
        else thumbRect.size.height=self.bounds.size.height;
    }
    debug = nil;
    float value = self.useProportionalValues ? [self proportionalValueFor:valueReal debug:debug] : valueReal;
    
    if(self.isVertical)
    {
        float yValue = ((self.bounds.size.height-thumbRect.size.height)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
//        if(!self.verticalMinimumOnTop)
//        {
//            yValue = (self.bounds.size.height-thumbRect.size.height) - yValue;
//        }
        thumbRect.origin = CGPointMake((self.bounds.size.width/2.0f) - (thumbRect.size.width/2.0f), yValue);
    }
    else
    {
        float xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
        thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
    }
    
    
    
    return CGRectIntegral(thumbRect);
    
}

// ------------------------------------------------------------------------------------------------------


- (CGRect) thumbRect;
{
    return self.upperHandleHidden ? CGRectUnknown : self.upperHandle.frame;
}
- (CGRect) lowerThumbRect;
{
    return self.lowerHandleHidden ? CGRectUnknown : self.lowerHandle.frame;
}
#pragma mark -

- (void) setThumbSize:(CGSize)thumbSize;
{
    _thumbSize = thumbSize;
    [self setNeedsLayout];
}
- (void) setLowerThumbSize:(CGSize)thumbSize;
{
    _lowerThumbSize = thumbSize;
    [self setNeedsLayout];
}


#pragma mark - Layout



- (void) addSubviews
{
    //------------------------------
    // Track
    self.track = [[UIImageView alloc] initWithImage:[self trackImageForCurrentValues]];
    self.track.frame = CGRectNoNaN([self trackRect]);
    
    //------------------------------
    // Lower Handle Handle
    self.lowerHandle = [[UIImageView alloc] initWithImage:self.lowerHandleImageNormal highlightedImage:self.lowerHandleImageHighlighted];

    self.lowerHandle.frame = CGRectNoNaN([self lowerThumbRectForValue:self.lowerRealValue image:self.lowerHandleImageNormal debug:@"lowerHandleRect"]);
    self.lowerHandle.contentMode = UIViewContentModeScaleAspectFill;
    //------------------------------
    // Upper Handle Handle
    self.upperHandle = [[UIImageView alloc] initWithImage:self.upperHandleImageNormal highlightedImage:self.upperHandleImageHighlighted];

    self.upperHandle.frame = CGRectNoNaN([self thumbRectForValue:self.upperRealValue image:self.upperHandleImageNormal debug:@"upperHandleRect"]);
    self.upperHandle.contentMode = UIViewContentModeScaleAspectFill;

    //------------------------------
    // Track Brackground
    self.trackBackground = [[UIImageView alloc] initWithImage:self.trackBackgroundImage];

    self.trackBackground.frame = CGRectNoNaN([self trackBackgroundRect]);

    
    [self addSubview:self.trackBackground];
    [self addSubview:self.track];
    [self addSubview:self.lowerHandle];
    [self addSubview:self.upperHandle];
}


-(void)layoutSubviews
{
    if(_haveAddedSubviews==NO)
    {
        _haveAddedSubviews=YES;
        [self addSubviews];
    }
    
    if(_lowerHandleHidden)
    {
        _lowerValue = _minimumValue;
        _lastLowerValue = _minimumRealValue;
    }
    
    if(_upperHandleHidden)
    {
        _upperValue = _maximumValue;
        _lastUpperValue = _maximumRealValue;
    }
    
    if(!self.ignoreTrackBackgroundLayout) self.trackBackground.frame = [self trackBackgroundRect];
    if(!self.ignoreTrackLayout) self.track.frame = CGRectNoNaN([self trackRect]);
    if(!self.ignoreImageForTrack) self.track.image = [self trackImageForCurrentValues];
    
    // Layout the lower handle
    if(!self.ignoreLowerHandleLayout) self.lowerHandle.frame = CGRectNoNaN([self lowerThumbRectForValue:_lowerRealValue image:self.lowerHandleImageNormal debug:@"lowerHandleRectLayout"]);
    if(!self.ignoreImageForLowerHandle) self.lowerHandle.image = self.lowerHandleImageNormal;
    if(!self.ignoreImageForLowerHandle) self.lowerHandle.highlightedImage = self.lowerHandleImageHighlighted;
    self.lowerHandle.hidden = self.lowerHandleHidden;
    
    // Layoput the upper handle
    
    if(!self.ignoreUpperHandleLayout) self.upperHandle.frame = CGRectNoNaN([self thumbRectForValue:_upperRealValue image:self.upperHandleImageNormal debug:@"upperHandleRectLayout"]);
    
    
    if(!self.ignoreImageForUpperHandle) self.upperHandle.image = self.upperHandleImageNormal;
    if(!self.ignoreImageForUpperHandle) self.upperHandle.highlightedImage = self.upperHandleImageHighlighted;
    self.upperHandle.hidden= self.upperHandleHidden;
    
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(self.lowerHandleImageNormal.size.height, self.upperHandleImageNormal.size.height));
}

// ------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Touch handling

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    _change = 0;
    //Check both buttons upper and lower thumb handles because
    //they could be on top of each other.
    BOOL should = NO;
    if(!self.lowerHandleDisabled &&  CGRectContainsPoint(UIEdgeInsetsInsetRect(_lowerHandle.frame, self.lowerTouchEdgeInsets), touchPoint))
    {
        _lowerHandle.highlighted = YES;
        _lowerTouchOffset = (self.isVertical ? touchPoint.y : touchPoint.x) - (self.isVertical ? _lowerHandle.center.y :  _lowerHandle.center.x);
        should = YES;
    }
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_upperHandle.frame, self.upperTouchEdgeInsets), touchPoint))
    {
        _upperHandle.highlighted = YES;
        _upperTouchOffset = (self.isVertical ? touchPoint.y : touchPoint.x) - (self.isVertical ? _upperHandle.center.y :  _upperHandle.center.x);
        should = !should ? YES : should;
    }
    
    _stepValueInternal= _stepValueContinuously ? _stepValue : 0.0f;
    if(should && !self.blockEventsBegin) [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    
    return should;
}

- (void) cancelTrackingWithEvent:(UIEvent *)event;
{
    if(!self.blockEventsEnd)
    {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_lowerHandle.highlighted && !_upperHandle.highlighted ){
        return YES;
    }
    float __change = 0;
    CGPoint touchPoint = [touch locationInView:self];
    float newValue = NAN;
    float currentValue;
//    DLog(@"touch point:  %@  %@", p(touchPoint), b(_upperHandle.highlighted));
    if(!self.lowerHandleDisabled && _lowerHandle.highlighted)
    {
        
        //get new lower value based on the touch location.
        //This is automatically contained within a valid range.
        newValue = [self lowerValueForCenterX:((self.isVertical ? touchPoint.y : touchPoint.x) - _lowerTouchOffset)];
        currentValue = self.lowerRealValue;
        //if both upper and lower is selected, then the new value must be LOWER
        //otherwise the touch event is ignored.
        if(!_upperHandle.highlighted || newValue<_lowerRealValue)
        {
            _upperHandle.highlighted=NO;
            [self bringSubviewToFront:_upperHandle];
            if(!self.lowerHandleDisabled) [self bringSubviewToFront:_lowerHandle];
            
            if(!self.lowerHandleDisabled) [self setLowerValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _lowerHandle.highlighted=NO;
        }
        __change = MAX(_change, fabsf(newValue - currentValue));
        
    }
    
    if(_upperHandle.highlighted )
    {
        newValue = [self upperValueForCenterX:((self.isVertical ? touchPoint.y : touchPoint.x) - _upperTouchOffset)];
        currentValue = self.upperRealValue;
//        DLog(@"value:  %2.2f -> %2.2f", self.upperValue, newValue);
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if(!_lowerHandle.highlighted || newValue>_upperRealValue)
        {
            _lowerHandle.highlighted=NO;
            if(!self.lowerHandleDisabled) [self bringSubviewToFront:_lowerHandle];
            [self bringSubviewToFront:_upperHandle];
            [self setUpperValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _upperHandle.highlighted=NO;
        }
        __change = MAX(_change, fabsf(newValue - currentValue));
        
    }
    
    
    //send the control event
    if(!isnan(_minimumValueChange))
    {
        
        _change += __change;
        
    }
    if(_continuous)
    {
        if(!self.blockEvents)
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            _change = 0;
        }
        
        
    }
    
    //redraw
    [self setNeedsLayout];
    
    return YES;
}



-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
    _change = 0;
    
    if(_stepValue>0)
    {
        _stepValueInternal=_stepValue;
        
        if(!self.lowerHandleDisabled) [self setLowerValue:_lowerRealValue animated:YES];
        [self setUpperValue:_upperRealValue animated:YES];
    }
    if(!self.blockEventsEnd)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
    
}




- (void)setLowerValue:(float)lowerValue animated:(BOOL) animated complete:(MysticBlockBOOL)completed;
{
    [self setLowerValue:lowerValue upperValue:NAN animated:animated complete:completed];
}

- (void)setUpperValue:(float)upperValue animated:(BOOL)animated complete:(MysticBlockBOOL)completed;
{
    [self setLowerValue:NAN upperValue:upperValue animated:animated complete:completed];
}
- (void) reset;
{
    
    [self resetValues];
    
}
- (void) resetValues;
{
    
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _minimumRange = 0.0;
    _stepValue = 0.0;
    _stepValueInternal = 0.0;
    _continuous = YES;
    
    _lowerValue = 0;
    _upperValue = 1.0;
    
    _lastLowerValue = _lowerValue;
    _lastUpperValue = _upperValue;
    _defaultLowerValue = NAN;
    _defaultUpperValue = NAN;
    
    _lowerMaximumValue = NAN;
    _upperMinimumValue = NAN;
}

- (float) defaultLowerValue;
{
    return isnan(_defaultLowerValue) ? _minimumRealValue : _defaultLowerValue;
}
- (float) defaultUpperValue;
{
    return isnan(_defaultUpperValue) ? _maximumRealValue : _defaultUpperValue;
}

- (void) commitValues;
{
    if(!self.blockEvents) [self sendActionsForControlEvents:UIControlEventValueChanged];
}



//- (float) minimumRange;
//{
//    return self.useProportionalValues ?
//}
- (float) maximumValue;
{
    return _maximumRealValue;
}
- (float) minimumValue;
{
    return _minimumRealValue;
}
- (float) upperValue;
{
    return _upperRealValue;
}

- (float) lowerValue;
{
    return _lowerRealValue;
}

- (float) minMaxRange;
{
    return fabsf(_maximumValue - _minimumValue);
}

@end

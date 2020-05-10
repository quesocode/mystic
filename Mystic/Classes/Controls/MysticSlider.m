//
//  MysticSlider.m
//  Mystic
//
//  Created by travis weerts on 1/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSlider.h"
#import "UIColor+Mystic.h"
#import "MysticUI.h"


@implementation MysticSlider

@synthesize sliderType=_sliderType, targetOption=_targetOption, value=_value;

+ (id) sliderWithFrame:(CGRect)frame;
{
    MysticSlider *slider = [[[self class] alloc] initWithFrame:frame];
    if([slider respondsToSelector:@selector(setTintColor:)])
    {
        slider.minimumTrackTintColor = [UIColor color:MysticColorTypeSliderMin];
        slider.maximumTrackTintColor = [UIColor color:MysticColorTypeSliderMax];
    }
    
    
    
    return [slider autorelease];
}

+ (id) panelSliderWithFrame:(CGRect)frame;
{
    MysticSlider *slider = [[[self class] alloc] initWithFrame:frame type:MysticSliderTypePanel];
    return [slider autorelease];
}

+ (id) sliderWithFrame:(CGRect)frame type:(MysticSliderType)type;
{
    return [[[[self class] alloc] initWithFrame:frame type:type] autorelease];
}

- (void) dealloc;
{
    _imageViewDelegate = nil;
    _finishAction = nil;
    _refreshAction = nil;
    _reloadAction = nil;
    _stillAction = nil;
    [_minimumTrackTintColor release];
    [_maximumTrackTintColor release];
    [_minimumValueImage release];
    [_maximumValueImage release];
    if(_valueBlock) Block_release(_valueBlock);
    if (self.timer) [self.timer invalidate];
    if (self.timer2) [self.timer2 invalidate];
    [_timer release], _timer = nil;
    [_timer2 release], _timer2 = nil;
    Block_release(_changeBlock); _changeBlock=nil;
    Block_release(_stillBlock); _stillBlock=nil;
    Block_release(_finishBlock); _finishBlock=nil;
    [super dealloc];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        _sliderCalls = 0;
        _insetSize = (CGSize){-10,-10};
        _colorState = MysticSliderStateNone;

        [self commonInit];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _sliderCalls = 0;
        _insetSize = (CGSize){-10,-10};
        _colorState = MysticSliderStateNone;

        [self commonInit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame type:(MysticSliderType)sliderType
{
    self = [super initWithFrame:frame];
    if (self) {
        _sliderType = sliderType;
        _sliderCalls = 0;
        _insetSize = (CGSize){-10,-10};
        _colorState = MysticSliderStateNone;

        [self commonInit];
    }
    return self;
}
- (UIEdgeInsets) thumbInsets;
{
    return UIEdgeInsetsMake(self.insetSize.height, self.insetSize.width, self.insetSize.height, self.insetSize.width);
}
- (UIEdgeInsets) trackInsets;
{
    return UIEdgeInsetsMake(-5, 0, -5, 0);
}
- (void) commonInit;
{
    _sliderCalls = 0;
    _insetSize = (CGSize){-10,-10};
    _defaultValue = NAN;
    _onlyTouchControls = NO;
    [self reset];

}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!self.onlyTouchControls) return [super hitTest:point withEvent:event];
    CGRect thumbFrame;
    if(!self.upperHandleHidden)
    {
        thumbFrame = UIEdgeInsetsInsetRect([self thumbRect], [self thumbInsets]);
        if (CGRectContainsPoint(thumbFrame, point)) return [super hitTest:point withEvent:event];
    }
    if(!self.lowerHandleHidden && !self.lowerHandleDisabled)
    {
        thumbFrame = UIEdgeInsetsInsetRect([self lowerThumbRect], [self thumbInsets]);
        if (CGRectContainsPoint(thumbFrame, point)) return [super hitTest:point withEvent:event];
    }
    if(self.backgroundTrackEnabled)
    {
        thumbFrame = UIEdgeInsetsInsetRect([self trackBackgroundRect], [self trackInsets]);
        if (CGRectContainsPoint(thumbFrame, point)) return [super hitTest:point withEvent:event];
    }
    return nil;
}
- (void) reset;
{
    [super reset];
    UIImage* image;
    
    if(!_trackBackgroundImage && !self.ignoreImageForTrackBackground)
    {
        image = [[UIImage imageNamed:@"slider-mystic-trackBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)];
        self.trackBackgroundImage = image;
    }
    
    if(!_trackImage && !self.ignoreImageForTrack)
    {
        switch (self.sliderType) {
            case MysticSliderTypeTrackless: image = nil; break;
            default: image = [UIImage imageNamed:@"slider-mystic-track"]; break;
        }
        self.trackImage = image;
    }
    
    if(!_upperHandleImageNormal && !self.ignoreImageForUpperHandle)
    {
        image = [UIImage imageNamed:@"slider-mystic-handle-light"];
        self.upperHandleImageNormal = image;
        self.upperHandleImageHighlighted = image;
    }
    
    if(!_lowerHandleImageNormal && !self.ignoreImageForLowerHandle)
    {
        self.lowerHandleImageNormal = [UIImage imageNamed:@"slider-handle-mid-pink-dark"];
        self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
    }
    
    
    if(!_trackCrossedOverImage && !self.ignoreImageForTrackCrossover) self.trackCrossedOverImage = [UIImage imageNamed:@"slider-mystic-trackCrossedOver"];
    self.tag = MysticViewTypeSlider;
    self.snapping = YES;
    self.lowerHandleDisabled = YES;
}
- (void) resetValue:(BOOL)animated;
{
    [self setUpperValue:self.defaultValue animated:animated];

}
- (void) resetLastValue:(BOOL)animated finished:(MysticBlockAnimationFinished)finished;
{
    [self setLowerValue:self.lastLowerValue upperValue:self.lastUpperValue animated:animated complete:finished];

}
- (float) value;
{
    if(self.valueBlock) return self.valueBlock(self.upperValue,NO, self);
    return self.upperValue;
}
- (void) setValue:(float)value;
{
    if(self.valueBlock) value = self.valueBlock(value, YES, self);
    _value = value;
    self.upperValue = value;
}
#ifdef DEBUG
- (void) setTestFilter:(id)filter forKey:(id)key;
{
    if(!self.testFilters) self.testFilters = [NSMutableDictionary dictionary];
    
    [self.testFilters setObject:filter forKey:key];
}
#endif

- (void) setSetting:(MysticObjectType)setting;
{
    [self setSetting:setting animated:NO];
}
- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated;
{
    [self setSetting:setting animated:animated setValue:YES];
}
- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated setValue:(BOOL)shouldSetValue;
{
    _setting = setting;
    CGFloat __value, __snapValue, lowerValue, __snapLower, __snapMid, __snapValueMin, __snapValueMax;
    __snapValue = MYSTIC_FLOAT_UNKNOWN;
    __snapLower = MYSTIC_FLOAT_UNKNOWN;
    __snapMid = MYSTIC_FLOAT_UNKNOWN;
    __snapValueMin = MYSTIC_FLOAT_UNKNOWN;
    __snapValueMax = MYSTIC_FLOAT_UNKNOWN;

    self.lowerHandleHidden = NO;
    self.stepValue = 0;
    self.stepValueContinuously = NO;
    lowerValue = 0;

    switch (_setting) {
        case MysticSettingGrain:
            self.minimumValue = 0;
            self.maximumValue = 0.3f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.grainAlpha : self.defaultValue;
            __snapValue = __value;
            break;
        case MysticSettingVignetteColorAlpha:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption && self.targetOption.vignetteColor ? self.targetOption.vignetteColor.alpha : self.defaultValue;
            
            __snapValue = __value;
            break;
        case MysticSettingToon:
            self.minimumValue = 0.025;
            self.maximumValue = 1.f;
            self.defaultValue = ktoonThreshold;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.toonThreshold : self.defaultValue;
            
//            __snapValue = __value;
            break;
        case MysticSettingPixellate:
            self.minimumValue = 0.005;
            self.maximumValue = 0.2f;
            self.defaultValue = kpixellatePixelWidth;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.pixellatePixelWidth : self.defaultValue;
//            __snapValue = __value;
            break;
        case MysticSettingBlurCircle:
            self.minimumValue = 1;
            self.maximumValue = 14;
            self.defaultValue = kblurCircleRadius;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.blurCircleRadius : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingBlurZoom:
            self.minimumValue = 0;
            self.maximumValue = 10;
            self.defaultValue = kblurZoomSize;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.blurZoomSize : self.defaultValue;
            //            __snapValue = __value;
            break;
        
        case MysticSettingBlurMotion:
            self.minimumValue = 0;
            self.maximumValue = 30;
            self.defaultValue = kblurMotionSize;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.blurMotionSize : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingBlurGaussian:
        case MysticSettingBlur:
            self.minimumValue = 0;
            self.maximumValue = 10;
            self.defaultValue = kblurRadius;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.blurRadius : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingDistortGlassSphere:
            self.minimumValue = 0;
            self.maximumValue = 1;
            self.defaultValue = ksphereRadius;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.sphereRadius : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingDistortSwirl:
            self.minimumValue = 0;
            self.maximumValue = 1;
            self.defaultValue = kswirlRadius;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.swirlRadius : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingDistortBuldge:
            self.minimumValue = 0;
            self.maximumValue = 1;
            self.defaultValue = kbuldgeRadius;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.buldgeRadius : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingDistortPinch:
            self.minimumValue = -2;
            self.maximumValue = 2;
            self.defaultValue = kpinchScale;
            self.minimumRange = -2.f;

            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.pinchScale : self.defaultValue;
            //            __snapValue = __value;
            break;
        case MysticSettingSketchFilter:
            self.minimumValue = 0.2;
            self.maximumValue = 15.f;
            self.defaultValue = ksketchStrength;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.sketchStrength : self.defaultValue;
//            __snapValue = __value;
            break;
        case MysticSettingHalfTone:
            self.minimumValue = 0.01;
            self.maximumValue = 0.1;
            self.defaultValue = khalftonePixelWidth;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.halftonePixelWidth : self.defaultValue;
            
            __snapValue = __value;
            break;
        case MysticSettingPosterize:
            self.minimumValue = 1;
            self.maximumValue = 25;
            self.defaultValue = kposterizeLevels;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.halftonePixelWidth : self.defaultValue;
            
//            __snapValue = __value;
            break;
        case MysticSettingHighlightIntensity:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.highlightIntensity : self.defaultValue;
            __snapValue = __value;
            break;
        case MysticSettingShadowIntensity:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.shadowIntensity : self.defaultValue;
            __snapValue = __value;
            break;
        case MysticSettingFilterAlpha:
        case MysticSettingIntensity:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 1.f;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? self.targetOption.intensity : self.defaultValue;
            __snapValue = __value;
            
            break;
        
            
        case MysticSettingVibrance:
            
            self.minimumValue = 0;
            self.maximumValue = 2.4;
            self.defaultValue = 1.2;
            self.minimumRange = -1.2;
            __value = self.targetOption ? self.targetOption.vibrance+1.2 : self.defaultValue;
            lowerValue = self.defaultValue;
            break;
            
        case MysticSettingSkin:
        {
            self.minimumValue = 0;
            self.maximumValue = 0.6;
            self.defaultValue = 0.3;
            self.minimumRange = -0.3;            
            [self fixValue:^ float (float value, BOOL set,  MysticSlider *slider)
            {
                return set ? value + 0.3f : value - 0.3f;
            }];
            __value = self.targetOption ? self.targetOption.skinToneAdjust+0.3 : self.defaultValue;
            lowerValue = self.defaultValue;
            break;
        }
        case MysticSettingColorAdjustAlpha:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? [(PackPotionOptionColor *)self.targetOption color].alpha : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorAdjustSaturation:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? [(PackPotionOptionColor *)self.targetOption color].saturation : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorAdjustHue:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? [(PackPotionOptionColor *)self.targetOption color].hue : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorAdjustBrightness:
            self.minimumValue = 0;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            __value = self.targetOption ? [(PackPotionOptionColor *)self.targetOption color].brightness : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorOffsetHue:
            self.minimumValue = -1.0f;
            self.maximumValue = 1.f;
            self.defaultValue = 0;
            self.minimumRange = -1.f;
            lowerValue = 0;
            __value = self.defaultValue;
            break;
        
        case MysticSettingHSB:
        case MysticSettingHSBHue:
            self.minimumValue = -360.0f;
            self.maximumValue = 360.0f;
            self.defaultValue = 0.0f;
            self.minimumRange = -360.f;
            lowerValue = 0;
            __value = self.targetOption ? self.targetOption.hsb.hue : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingHSBSaturation:
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.hsb.saturation : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingHSBBrightness:
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.hsb.brightness : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            self.colorState = MysticSliderStateRed;
            __value = self.targetOption ? self.targetOption.rgb.one : self.defaultValue;
            lowerValue = self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorBalanceGreen:
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            self.colorState = MysticSliderStateGreen;
            __value = self.targetOption ? self.targetOption.rgb.two : self.defaultValue;
            lowerValue = self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingColorBalanceBlue:
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            self.colorState = MysticSliderStateBlue;
            __value = self.targetOption ? self.targetOption.rgb.three : self.defaultValue;
            lowerValue = self.defaultValue;
            __snapValue = __value;
            break;
            
        
            
        case MysticSettingHaze:
            self.minimumValue = kHazeMin;
            self.maximumValue = kHazeMax;
            self.defaultValue = kHaze;
            self.minimumRange = kHazeMin;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.haze : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingLevels:
            self.minimumValue = kLevelsMin;
            self.maximumValue = kLevelsMax;
            self.defaultValue = kLevels;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            __value = 0;
            __snapValue = __value;
            break;
            
        case MysticSettingTemperature:
            self.minimumValue = kTemperatureMin;
            self.maximumValue = kTemperatureMax;
            self.defaultValue = kTemperature;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.temperature : self.defaultValue;
            __snapValue = __value;
            break;
        case MysticSettingUnsharpMask:
            self.minimumValue = kUnsharpMaskMin;
            self.maximumValue = kUnsharpMaskMax;
            self.defaultValue = kUnsharpMask;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            __value = self.targetOption ? self.targetOption.unsharpMask : self.defaultValue;
            __snapValue = __value;
            break;
        case MysticSettingSharpness:
            self.minimumValue = kSharpnessMin;
            self.maximumValue = kSharpnessMax;
            self.defaultValue = kSharpness;
            self.minimumRange = kSharpnessMin;
            self.lowerHandleHidden = YES;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.sharpness : self.defaultValue;
            break;
        case MysticSettingTiltShift:
            self.minimumValue = 0;
            self.maximumValue = 14;
            self.defaultValue = 7;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            __value = self.targetOption ? self.targetOption.tiltShiftBlurSizeInPixels : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingSaturation:
            self.minimumValue = kSaturationMin;
            self.maximumValue = kSaturationMax;
            self.defaultValue = kSaturation;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.saturation : self.defaultValue;
            __snapValue = __value;
            break;
            
        case MysticSettingVignette:
            self.minimumValue = kVignetteMin;
            self.maximumValue = kVignetteMax;
            self.defaultValue = 0;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            CGFloat start = self.targetOption ? self.targetOption.vignetteStart : 1;
            CGFloat end = self.targetOption ? self.targetOption.vignetteEnd : 1;
            __value = start == 1 && end == 1 ? self.defaultValue : (1 - end)/.3;
            
            break;
            
        case MysticSettingGamma:
            self.minimumValue = kGammaMin;
            self.maximumValue = kGammaMax;
            self.defaultValue = kGamma;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.gamma : self.defaultValue;
            break;
            
        case MysticSettingExposure:
            self.minimumValue = kExposureMin;
            self.maximumValue = kExposureMax;
            self.minimumRange = -1.f;
            __value = self.targetOption ? self.targetOption.exposure : self.defaultValue;
            self.defaultValue = kExposure;
            lowerValue = self.defaultValue;
            break;
            
#ifdef DEBUG
        case MysticSettingTest:
            self.minimumValue = kSharpnessMin;
            self.maximumValue = 15.0;
            self.defaultValue = kSharpness;
            self.minimumRange = kSharpnessMin;
            self.lowerHandleHidden = YES;
            lowerValue = self.defaultValue;
            __value = kSharpness;
            break;
#endif
        
            
        case MysticSettingHighlights:
            self.minimumValue = kHighlightsMin;
            self.maximumValue = kHighlightsMax;
            self.defaultValue = kHighlights;
            self.lowerHandleHidden = YES;
            [self fixValue:^ float (float v, BOOL set,  MysticSlider *s)
             {
                 return set ? 1-v : 1 - v;
             }];
            lowerValue = self.minimumValue;
            __value = self.targetOption ? 1-self.targetOption.highlights : self.defaultValue;
            break;
            
        case MysticSettingShadows:
            self.minimumValue = kShadowsMin;
            self.maximumValue = kShadowsMax;
            self.defaultValue = kShadows;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            __value = self.targetOption ? self.targetOption.shadows : self.defaultValue;
            break;
            
        case MysticSettingContrast:
            self.useProportionalValues = YES;
            self.proportionLowerValue = kContrast;
            self.minimumValue = kContrastMin;
            self.maximumValue = kContrastMax;
            self.defaultValue = kContrast;
            self.minimumRange = -1.f;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.contrast : self.defaultValue;
            break;
            
        case MysticSettingBrightness:
            self.maximumValue = kBrightnessMax;
            self.minimumValue = kBrightnessMin;
            self.defaultValue = kBrightness;
            self.minimumRange = kBrightnessMin;
            lowerValue = self.defaultValue;
            __value = self.targetOption ? self.targetOption.brightness : self.defaultValue;
            break;
        
        case MysticSettingWearAndTear:
            self.maximumValue = MYSTIC_WEAR_MAX;
            self.minimumValue = MYSTIC_WEAR_MIN;
            self.defaultValue = MYSTIC_WEAR_DEFAULT;
            self.lowerHandleHidden = YES;
            lowerValue = self.minimumValue;
            __value = self.targetOption ? self.targetOption.wearAndTear : self.defaultValue;
            break;
            
        default: __value = 0; break;
    }
    
    __snapValue = __snapValue == MYSTIC_FLOAT_UNKNOWN ? self.defaultValue : __snapValue;
    BOOL s = self.snapping;
    self.snapping = NO;
    _value = __value;
    self.snapPoints = @[@(__snapValue)];
    self.snapPointsMid  = (__snapMid != MYSTIC_FLOAT_UNKNOWN) ? @[@(__snapMid)] : nil;
    self.snapPointsLower  = (__snapLower != MYSTIC_FLOAT_UNKNOWN) ? @[@(__snapLower)] : nil;
    if(self.lowerHandleHidden)
    {
        self.snapPoints = @[@(__snapValue), @(self.minimumRealValue), @(self.maximumRealValue)];
    }
    else
    {
        __snapLower = __snapLower == MYSTIC_FLOAT_UNKNOWN ? self.lowerRealValue : __snapLower;
        self.snapPointsLower  = (__snapLower != MYSTIC_FLOAT_UNKNOWN) ? @[@(__snapLower)] : nil;
    }
    self.lastUpperValue = __value;
    self.lastLowerValue = lowerValue;
    self.lowerValue = lowerValue;
    if(shouldSetValue)
    {
        if(self.debug) DLog(@"set setting and value: %2.2f", __value);
        if(self.lowerHandleHidden)[self setUpperValue:__value animated:animated];
        else [self setLowerValue:lowerValue upperValue:__value animated:animated complete:nil];
    }
    [self setNeedsLayout];
}

// This extends the touchable area by 10 pixels on the left and right and 15 pixels on the top and bottom.
- (void) fixValue:(MysticBlockSliderValue)block;
{
    self.valueBlock = block;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    if(self.onlyTouchControls) return [super pointInside:point withEvent:event];
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, _insetSize.width, _insetSize.height);
    return CGRectContainsPoint(bounds, point);
}

- (void) setChangeBlock:(MysticSliderBlock)changeBlock;
{
    if(!_changeBlock && changeBlock)
    {
        [self removeTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
        if(!_finishBlock)
        {
            [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventEditingDidEnd];
            [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
            [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
            [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchCancel];
        }
    }
    if(_changeBlock) Block_release(_changeBlock);
    _changeBlock = Block_copy(changeBlock);
}

- (void) setFinishBlock:(MysticSliderBlock)finishBlock;
{
    if(!_finishBlock && finishBlock)
    {
        [self removeTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self removeTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self removeTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchCancel];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self removeTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchCancel];
    }
    if(_finishBlock) Block_release(_finishBlock);
    _finishBlock = Block_copy(finishBlock);
}

- (void) setupActionsForSetting:(MysticObjectType)setting option:(PackPotionOption *)option animated:(BOOL)animated;
{
    self.targetOption = option;
    [self setSetting:setting animated:animated];
    option.refreshState = setting;
    [self setChangeBlockForSetting:setting option:option];
    [self setStillBlockForSetting:setting option:option];
    [self setFinishBlockForSetting:setting option:option];
}

- (void) setChangeBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
{
    self.changeBlock = [MysticSliderBlocks blockForSliderChange:self option:option ? option : self.targetOption setting:setting];
    if(self.changeBlock)
    {
        option.refreshState = setting;
        [self addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    }
}


- (void) setFinishBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
{
    self.finishBlock = [MysticSliderBlocks blockForSliderFinish:self option:option ? option : self.targetOption setting:setting];
    if(self.finishBlock)
    {
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(sliderDidEnd:) forControlEvents:UIControlEventTouchCancel];
    }
    else if (self.changeBlock)
    {
        [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(sliderDidChangeEnd:) forControlEvents:UIControlEventTouchCancel];
    }
}
- (void) setStillBlockForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
{

}
- (void) sliderDidChange:(MysticSlider *)slider;
{
    self.changeBlock(slider);
}
- (void) sliderDidChangeEnd:(MysticSlider *)slider;
{
    self.changeBlock(slider);
}
- (void) sliderDidEnd:(MysticSlider *)slider;
{
    self.finishBlock(slider);
}


- (void) resetToDefaultValues;
{
    [self resetToDefaultValues:nil finished:nil];
}
- (void) resetToDefaultValues:(id)animated finished:(MysticBlockAnimationFinished)finished;
{
    self.ignoreMinimumChange = YES;
    float l = !isnan(self.defaultLowerValue) ? self.defaultLowerValue : isnan(self.lastLowerValue) ? self.minimumRealValue : self.lastLowerValue;
    float u = !isnan(self.defaultValue) ? self.defaultValue : isnan(self.lastUpperValue) ? self.maximumRealValue : self.lastUpperValue;
    [self setLowerValue:self.lowerHandleDisabled ? NAN : l upperValue:u animated:animated && [animated floatValue] > 0 ? YES : NO complete:finished];
    self.ignoreMinimumChange = NO;
}

- (void) resetToValue:(float)u animated:(id)animated finished:(MysticBlockAnimationFinished)finished;
{
    self.ignoreMinimumChange = YES;
    float l = !isnan(self.defaultLowerValue) ? self.defaultLowerValue : isnan(self.lastLowerValue) ? self.minimumRealValue : self.lastLowerValue;
    [self setLowerValue:self.lowerHandleDisabled ? NAN : l upperValue:u animated:animated && [animated floatValue] > 0 ? YES : NO complete:finished];
    self.ignoreMinimumChange = NO;
}
- (void) setSliderType:(MysticSliderType)sliderType;
{
    BOOL changed = _sliderType!=sliderType;
    if(!changed) return;
    _sliderType = sliderType;
    
    switch (sliderType) {
        case MysticSliderTypeVerticalMinimal:
            
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
    [self setNeedsLayout];
}





@end


@implementation MysticScrollViewSlider

- (void) commonInit;
{
    [super commonInit];
    self.insetSize = (CGSize){-3, -3};
    self.onlyTouchControls = YES;
}

@end

@implementation MysticSliderBrush

- (void) commonInit;
{
    [super commonInit];
    self.ignoreImageForTrackBackground = YES;
    self.ignoreImageForTrack = YES;
    self.ignoreImageForTrackCrossover = YES;
    self.ignoreImageForUpperHandle = YES;
    self.ignoreImageForLowerHandle = YES;
    self.ignoreTrackLayout = YES;
    self.ignoreTrackBackgroundLayout = YES;
    self.ignoreLowerHandleLayout = YES;
    self.isVertical = YES;
    self.lowerHandleHidden = YES;
    self.verticalAlignmentBottom=YES;
    self.sliderType = MysticSliderTypeVerticalMinimal;
    self.thumbSize = (CGSize){6,30};
    self.originalThumbSize = (CGSize){6,30};
    self.horizontalAlignment = MysticPositionLeft;
    self.upperTouchEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
    self.highlightedThumbSize = (CGSize){18,30};
}

- (void) addSubviews;
{
    [super addSubviews];
//    self.upperHandle.backgroundColor = [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1];
    self.upperHandle.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.98];
    self.upperHandle.layer.cornerRadius = 3;
    self.trackBackground.layer.cornerRadius = 3;
    self.trackBackground.frame = CGRectXW(self.trackBackground.frame, self.horizontalAlignment == MysticPositionLeft ? self.highlightedThumbSize.width/2- 4/2 : self.bounds.size.width - self.highlightedThumbSize.width/2 - 4/2, 4);
    self.trackBackground.backgroundColor = [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:0.2];
    self.trackBackground.alpha = 0;
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    self.upperHandle.center = CGPointX(self.upperHandle.center,self.horizontalAlignment == MysticPositionLeft ? 5 : self.bounds.size.width - 5);
    self.upperTouchEdgeInsets = UIEdgeInsetsMake(-15, self.horizontalAlignment == MysticPositionLeft ? -15 : -30, -15, self.horizontalAlignment == MysticPositionLeft ? -30 : -15);
        if(self.upperHandle.highlighted)
        {
            self.upperHandle.frame = CGRectXW(self.upperHandle.frame, self.horizontalAlignment == MysticPositionLeft ? 0 : self.bounds.size.width - self.highlightedThumbSize.width, self.highlightedThumbSize.width);
            self.upperHandle.backgroundColor = UIColor.whiteColor;
            self.trackBackground.alpha = 1;
        }
        else
        {
            self.upperHandle.frame = CGRectXW(self.upperHandle.frame, self.horizontalAlignment == MysticPositionLeft ? 0 : self.bounds.size.width - self.thumbSize.width, self.thumbSize.width);
            self.upperHandle.backgroundColor = [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:0.98];
            self.trackBackground.alpha = 0;
        }
}
-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL should = [super beginTrackingWithTouch:touch withEvent:event];
    if(self.upperHandle.highlighted)
    {
        self.thumbSize = self.highlightedThumbSize;
    }
    [MysticUIView animate:0.2 animations:^{
        [self layoutSubviews];
    }];
    return should;
}
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(self.upperHandle.highlighted)
    {
        self.thumbSize = self.originalThumbSize;
    }
    [super endTrackingWithTouch:touch withEvent:event];
}
@end

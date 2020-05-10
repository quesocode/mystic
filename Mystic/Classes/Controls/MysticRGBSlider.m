//
//  MysticRGBSlider.m
//  Mystic
//
//  Created by Travis A. Weerts on 9/3/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticRGBSlider.h"
#import "PackPotionOption.h"

@implementation MysticRGBSlider

- (void) commonInit;
{
    
    _setting = MysticSettingColorBalance;
    [self setColorState:MysticSliderStateRed animated:NO];
    [super commonInit];
}
- (void) reset;
{
    UIImage *image = [UIImage imageNamed:@"slider-mystic-handle-light"];
    self.upperHandleImageNormal = image;
    self.upperHandleImageHighlighted = self.upperHandleImageNormal;
    image = [[UIImage imageNamed:@"slider-mystic-trackBackground-dark"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)];
    self.trackBackgroundImage = image;
    [super setColorState:self.colorState];
    [super reset];
    self.lowerHandleDisabled = YES;
    [self setNeedsDisplay];

    
}

- (void) configureView
{
    [super configureView];
    _lowerValue = 1;
    _upperValue = 1;
    _lowerRealValue = 1;
    _upperRealValue = 1;
    _minimumValue = 0;
    _maximumValue = 2.f;
    _maximumRealValue = 2.f;
    _minimumRealValue = 0;
    _minimumRange = -1.f;
}

- (void) setColorState:(MysticSliderState)colorState;
{
    [self setColorState:colorState animated:NO];
}
- (void) setColorState:(MysticSliderState)colorState animated:(BOOL)animated;
{
//    if(colorState == [super colorState]) return;
    [super setColorState:colorState];
    self.trackBackgroundImage = [[UIImage imageNamed:@"slider-mystic-trackBackground-dark"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)];
    switch (colorState) {
        case MysticSliderStateGreen:
        {
            self.lowerHandleImageNormal = [UIImage imageNamed:@"slider-mystic-handle-green"];
            self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-green"];
            if(self.targetOption) [self setLowerValue:self.lowerValue upperValue:self.targetOption.rgb.two animated:YES complete:nil];
            break;
        }
        case MysticSliderStateBlue:
        {
            self.lowerHandleImageNormal = [UIImage imageNamed:@"slider-mystic-handle-blue"];
            self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-blue"];
            if(self.targetOption) [self setLowerValue:self.lowerValue upperValue:self.targetOption.rgb.three animated:YES complete:nil];
            break;
        }
        case MysticSliderStateRed:
        default:
        {
            self.lowerHandleImageNormal = [UIImage imageNamed:@"slider-mystic-handle-red"];
            self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-red"];
            [self setLowerValue:self.lowerValue upperValue:self.targetOption ? self.targetOption.rgb.one : self.upperValue animated:YES complete:nil];
            break;
        }
    }
    self.trackCrossedOverImage = self.trackImage;

    [self setSetting:MysticSettingColorBalance animated:YES setValue:YES];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}


- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated setValue:(BOOL)shouldSetValue;
{
    switch (setting) {
        case MysticSettingRGB:
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalanceGreen:
        {
            _setting = MysticSettingColorBalance;
            self.minimumValue = 0.0f;
            self.maximumValue = 2.0f;
            self.defaultValue = 1.0f;
            self.minimumRange = -1.f;
            float __value;
            switch (self.colorState) {
                case MysticSliderStateGreen: __value = self.targetOption ? self.targetOption.rgb.two : self.defaultValue; break;
                case MysticSliderStateBlue: __value = self.targetOption ? self.targetOption.rgb.three : self.defaultValue; break;
                default: __value = self.targetOption ? self.targetOption.rgb.one : self.defaultValue; break;
            }
            [self setLowerValue:self.defaultValue upperValue:__value animated:animated complete:nil];
            break;
        }
        default: [super setSetting:setting animated:animated setValue:shouldSetValue]; break;
    }
    [self setNeedsLayout];
    return;
}

@end

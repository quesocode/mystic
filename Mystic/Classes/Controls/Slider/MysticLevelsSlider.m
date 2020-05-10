//
//  MysticLevelsSlider.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/26/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticLevelsSlider.h"
#import "PackPotionOption.h"

@implementation MysticLevelsSlider

- (void) commonInit;
{
    _setting = MysticSettingLevels;
    self.colorState = MysticSliderStateRGB;
    [super commonInit];
}
- (void) reset;
{
    UIImage *image = [UIImage imageNamed:@"slider-mystic-handle-light"];
    self.upperHandleImageNormal = image;
    self.upperHandleImageHighlighted = self.upperHandleImageNormal;
    image = [UIImage imageNamed:@"slider-mystic-handle-dark"];
    self.lowerHandleImageNormal = image;
    self.lowerHandleImageHighlighted = self.lowerHandleImageNormal;
    image = [[UIImage imageNamed:@"slider-mystic-trackBackground-dark"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)];
    self.trackBackgroundImage = image;
    [super setColorState:self.colorState];
    [super reset];
    self.lowerHandleDisabled = NO;

    
}
- (void) setColorState:(MysticSliderState)colorState;
{
    [self setColorState:colorState animated:NO];
}
- (void) setColorState:(MysticSliderState)colorState animated:(BOOL)animated;
{
    if(colorState == [super colorState]) return;
    [super setColorState:colorState];
    UIImage *image;
    switch (colorState) {
        case MysticSliderStateRed:
        {
            image = [UIImage imageNamed:@"slider-mystic-handle-red"];
            self.midHandleImageNormal = image;
            self.midHandleImageHighlighted = image;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-red"];
            if(self.targetOption) [self setLowerValue:self.targetOption.blackLevelsRed upperValue:self.targetOption.whiteLevelsRed midValue:self.targetOption.midLevelsRed animated:YES complete:nil];
            break;
        }
        case MysticSliderStateGreen:
        {
            image = [UIImage imageNamed:@"slider-mystic-handle-green"];
            self.midHandleImageNormal = image;
            self.midHandleImageHighlighted = image;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-green"];
            if(self.targetOption) [self setLowerValue:self.targetOption.blackLevelsGreen upperValue:self.targetOption.whiteLevelsGreen midValue:self.targetOption.midLevelsGreen animated:YES complete:nil];
            break;
        }
        case MysticSliderStateBlue:
        {
            image = [UIImage imageNamed:@"slider-mystic-handle-blue"];
            self.midHandleImageNormal = image;
            self.midHandleImageHighlighted = image;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-blue"];
            if(self.targetOption) [self setLowerValue:self.targetOption.blackLevelsBlue upperValue:self.targetOption.whiteLevelsBlue midValue:self.targetOption.midLevelsBlue animated:YES complete:nil];
            break;
        }
        default:
        {
            image = [UIImage imageNamed:@"slider-mystic-handle-mid"];
            self.midHandleImageNormal = image;
            self.midHandleImageHighlighted = image;
            self.trackImage = [UIImage imageNamed:@"slider-mystic-track-normal"];
            if(self.targetOption) [self setLowerValue:self.targetOption.blackLevels upperValue:self.targetOption.whiteLevels midValue:self.targetOption.midLevels animated:YES complete:nil];
            break;
        }
    }
    self.midHandle.highlighted = NO;
    [self setSetting:self.setting animated:YES setValue:YES];
    [self setNeedsDisplay];
}


- (void) setSetting:(MysticObjectType)setting animated:(BOOL)animated setValue:(BOOL)shouldSetValue;
{
    self.snapPointsLower = nil;
    self.snapPoints = nil;
    self.snapPointsMid = nil;
    BOOL setup = NO;
    float lowVal = 0;
    float midVal = 0.5;
    float topVal = 1;
    float lowValr = 0;
    float midValr = 0.5;
    float topValr = 1;
    float lowValb = 0;
    float midValb = 0.5;
    float topValb = 1;
    float lowValg = 0;
    float midValg = 0.5;
    float topValg = 1;
    
    switch (setting) {
        case MysticSettingLevels:
        {
            _setting = MysticSettingLevels;
            self.minimumValue = kLevelsMin;
            self.maximumValue = kLevelsMax;
            self.minimumRange = 0;
            self.lowerHandleHidden = NO;
            self.defaultLowerValue = self.minimumValue;
            self.defaultUpperValue = self.maximumValue;
            self.defaultValue = [self midValueFromMinAndMax];
            
            lowValr = self.targetOption ? self.targetOption.blackLevelsRed : kLevelsMin;
            midValr = self.targetOption && self.targetOption.midLevelsRed >= 0 ? self.targetOption.midLevelsRed : kLevelsMin + ((kLevelsMax-kLevelsMin)/2);
            topValr = self.targetOption ? self.targetOption.whiteLevelsRed : kLevelsMax;
            
            lowValg = self.targetOption ? self.targetOption.blackLevelsGreen : kLevelsMin;
            midValg = self.targetOption && self.targetOption.midLevelsGreen >= 0 ? self.targetOption.midLevelsGreen : kLevelsMin + ((kLevelsMax-kLevelsMin)/2);
            topValg = self.targetOption ? self.targetOption.whiteLevelsGreen : kLevelsMax;
            
            lowValb = self.targetOption ? self.targetOption.blackLevelsBlue : kLevelsMin;
            midValb = self.targetOption && self.targetOption.midLevelsBlue >= 0 ? self.targetOption.midLevelsBlue : kLevelsMin + ((kLevelsMax-kLevelsMin)/2);
            topValb = self.targetOption ? self.targetOption.whiteLevelsBlue : kLevelsMax;
            
            lowVal = self.targetOption ? self.targetOption.blackLevels : kLevelsMin;
            midVal = self.targetOption && self.targetOption.midLevels >= 0 ? self.targetOption.midLevels : kLevelsMin + ((kLevelsMax-kLevelsMin)/2);
            topVal = self.targetOption ? self.targetOption.whiteLevels : kLevelsMax;
            
            switch (self.colorState) {
                case MysticSliderStateRed:
                {
                    lowVal = lowValr;
                    midVal = midValr;
                    topVal = topValr;
                    break;
                }
                case MysticSliderStateGreen:
                {
                    lowVal = lowValg;
                    midVal = midValg;
                    topVal = topValg;
                    break;
                }
                case MysticSliderStateBlue:
                {
                    lowVal = lowValb;
                    midVal = midValb;
                    topVal = topValb;
                    break;
                }
                default:
                {
                    
                    break;
                }
            }
            self.lastUpperValue = topVal;
            self.lastLowerValue = lowVal;
            self.lastMidValue = midVal;
            [self setLowerValue:lowVal upperValue:topVal midValue:midVal animated:animated complete:nil];
            self.snapPoints = @[@(topVal)];
            self.snapPointsMid = @[@(midVal)];
            self.snapPointsLower = @[@(lowVal)];
            setup = YES;
            break;
        }
        default:
        {
            [super setSetting:setting animated:animated setValue:shouldSetValue];
            return;
        }
    }
    return;
}
@end

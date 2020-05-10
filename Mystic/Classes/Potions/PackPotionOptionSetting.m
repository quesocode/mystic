//
//  PackPotionOptionSetting.m
//  Mystic
//
//  Created by travis weerts on 1/26/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionSetting.h"
#import "EffectControl.h"
#import "MysticController.h"
#import "MysticIcon.h"
#import "UserPotion.h"
#import "MysticImageFilter.h"
#import "MysticEffectsManager.h"

@implementation PackPotionOptionSetting

+ (PackPotionOptionSetting *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionSetting *option = (PackPotionOptionSetting *)[super optionWithName:[name capitalizedString] info:info];
    option.type = MysticObjectTypeSetting;
    return option;
}
- (id) init;
{
    self = [super init];
    if(self) self.levelRules = MysticLayerLevelRuleAuto|MysticLayerLevelRuleAlwaysHighestUnlessMoved;
    return self;
}
- (BOOL) requiresFrameRefresh; { return NO; }
- (BOOL) canBeConfirmed; { return self.hasAdjustments; }
- (BOOL) canTransform; { return NO; }

- (BOOL) hasInput; { return NO; }
- (NSString *) layerSubtitle; { return @"Settings"; }
- (NSString *) layerTitle; { return @"Adjustments"; }
- (BOOL) showLayerPreview; { return YES; }
- (BOOL) isPreviewOption; { return NO; }
- (BOOL) showInLayers; { return YES; }
- (BOOL) canReorder; { return YES; }
- (BOOL) hasImage; { return NO; }
- (BOOL) hasShader; { return YES; }
- (BOOL) showAllActiveControls; { return YES; }
- (BOOL) showLabel { return YES; }
- (UIImage *) controlImage; { return [UIImage imageNamed:@"none_controlImage.png"]; }

- (BOOL) controlShouldShowCancel:(EffectControl *)control; { return YES; }
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = nil;
    if(isSelected)
    {
        label.textColor = [UIColor mysticWhiteColor];
        control.imageView.image = [MysticIcon image:control.imageView.image color:[UIColor mysticWhiteColor]];
        label.font = [MysticUI gothamBold:label.font.pointSize];
    }
    else
    {
        label.textColor = [UIColor mysticWhiteColor];
        control.imageView.image = [MysticIcon image:control.imageView.image color:[UIColor mysticDarkGrayBackgroundColor]];
        label.font = [MysticUI gotham:label.font.pointSize];
    }
}
- (void) updateControl:(EffectControl *)control selected:(BOOL)makeSelected;
{
    UIView *_cancelBtn = (UIView *)[control.selectedOverlayView viewWithTag:MysticButtonTypeCancel];
    control.selectedOverlayView.layer.borderWidth = 0;
    if(makeSelected)
    {
        control.imageView.backgroundColor = [UIColor hex:@"a65e64"];
        [_cancelBtn setHidden:![UserPotion hasUserAppliedSettingOfType:self.type]];
         control.selectedOverlayView.alpha = 1;
    }
    else
    {
        control.selectedOverlayView = nil;
        control.imageView.backgroundColor = [UIColor hex:@"5c534f"];
    }
    [control setSuperSelected:makeSelected];
    [self updateLabel:control.titleLabel control:control selected:makeSelected];
    
}

- (void) cancelEffect:(EffectControl *)control;
{
    PackPotionOption *option = (PackPotionOption *)[UserPotion optionForType:MysticObjectTypeSetting];
    switch (self.type) {
        case MysticSettingColorFilter:
        case MysticSettingChooseColorFilter: [UserPotion cancelOptionForType:MysticObjectTypeFilter]; break;
        case MysticSettingBrightness: option.brightness = kBrightness; break;
        case MysticSettingVibrance: option.vibrance = 0; break;
        case MysticSettingGamma: option.gamma = kGamma; break;
        case MysticSettingExposure: option.exposure = kExposure; break;
        case MysticSettingVignette: option.vignetteEnd = kVignetteStart; option.vignetteStart = kVignetteStart; break;
        case MysticSettingUnsharpMask: option.unsharpMask = kUnsharpMask; break;
        case MysticSettingHSB: option.hsb = MysticHSBDefault; break;
        case MysticSettingTemperature: option.temperature = kTemperature; option.tint = kTint; break;
        case MysticSettingLevels: option.blackLevels = kLevelsMin; option.whiteLevels = kLevelsMax; break;
        case MysticSettingHaze: option.haze = kHaze; break;
        case MysticSettingSaturation: option.saturation = kSaturation; break;
        case MysticSettingTiltShift: option.tiltShift = kTiltShift; break;
        case MysticSettingContrast: option.contrast = kContrast; break;
        case MysticSettingSharpness: option.sharpness = kSharpness; break;
        case MysticSettingShadows: option.shadows = kShadows; break;
        case MysticSettingHighlights: option.highlights = kHighlights; break;
        case MysticSettingBlending:
        default: break;
    }
    [self updateControl:control selected:NO];
    control.selected = NO;
    [[MysticController controller] reloadImage:NO];
    
}
- (MysticObjectType) groupType; { return MysticObjectTypeSetting; }


- (BOOL)updateFilters:(MysticObjectType)settingType;
{
    self.sourceNeedsRefresh = NO;
    NSArray *beforeFilterTypes = [self filterTypesMatchingOptions:MysticFilterOptionBeforeLayers];
    for (NSNumber *filterType in beforeFilterTypes) if(settingType == [filterType integerValue]) { self.sourceNeedsRefresh = YES; break; }
    return [super updateFilters:settingType];
}

- (id) setUserChoice;
{
    if(self.type != MysticObjectTypeSetting) return self;
    return [super setUserChoice];
}

- (BOOL) isActive;
{
    PackPotionOptionSetting *opt = nil;
    if(self.type != MysticObjectTypeSetting)
    {
        switch (self.type)
        {
            case MysticSettingChooseColorFilter:
            {
                opt = (PackPotionOptionSetting *)(self.targetOption ? self.targetOption : [[MysticOptions current] option:MysticObjectTypeFilter]);
                return opt ? YES : NO;
            }
            default:
            {
                opt = (PackPotionOptionSetting *)(self.targetOption ? self.targetOption : [[MysticOptions current] option:MysticObjectTypeSetting]);
                if(opt) return [opt hasAdjusted:self.type];
                break;
            }
        }
    }
    else
    {
        opt = (PackPotionOptionSetting *)(self.targetOption ? self.targetOption : [[MysticOptions current] option:MysticObjectTypeSetting]);
        if(opt) return YES;
    }
    return [super isActive];
}

- (void) setRefreshState:(MysticObjectType)refreshState;
{
    switch (refreshState) {
        case MysticSettingVignette:
        {
            if(![self hasAdjusted:MysticSettingVignette])
            {
                self.vignetteStart = kVignetteStart;
                self.vignetteEnd = kVignetteEnd;
                self.vignetteCenter = CGPointVignetteCenterDefault;
                
                [[MysticOptions current].filters.filter setVignette:self.vignetteCenter color:self.vignetteColor start:self.vignetteStart end:self.vignetteEnd option:self];
                [MysticEffectsManager refresh:self];
            }
            break;
        }
            
        default:  break;
    }
    [super setRefreshState:refreshState];
}

- (void) setupFilter:(MysticImageFilter *)imageFilter;
{
    if(self.ignoreActualRender) return;
    imageFilter = imageFilter ? imageFilter : [MysticOptions current].filters.filter;
    [super setupFilter:imageFilter];
    [imageFilter setTemp:kTemperatureValueMin + ((kTemperatureValueMax - kTemperatureValueMin)*(self.temperature/kTemperatureMax)) tint:self.tint index:self.shaderIndex option:self];
    [imageFilter setHaze:self.haze slope:self.hazeSlope index:self.shaderIndex option:self];
    [imageFilter setShadow:self.shadows highlight:self.highlights index:self.shaderIndex option:self];
    [imageFilter setShadowIntensity:self.shadowIntensity tint:self.shadowTintColor index:self.shaderIndex option:self];
    [imageFilter setHighlightIntensity:self.highlightIntensity tint:self.highlightTintColor index:self.shaderIndex option:self];
    [imageFilter setSkin:self.skinToneAdjust hue:self.skinHue hueThreshold:self.skinHueThreshold maxHueShift:self.skinHueMaxShift maxSaturation:self.skinMaxSaturation upperTone:self.skinUpperTone index:self.shaderIndex option:self ];
    if(self.hasGrain) [imageFilter setGrainTime:self.grainTime alpha:self.grainAlpha threshold:self.grainThreshold color:self.grainColor ? self.grainColor : [UIColor blackColor] option:self];
    if([self hasAdjusted:MysticSettingAdjustColor]) [imageFilter setAdjustColors:self index:self.shaderIndex];
//    if([self hasAdjusted:MysticSettingVignette])
//    {
        UIColor *vc = self.vignetteColor;
        if(!vc) vc = [[UIColor blackColor] alpha:0];
        [imageFilter setVignette:self.vignetteCenter color:vc start:self.vignetteStart end:self.vignetteEnd option:self];
//    }
}

@end

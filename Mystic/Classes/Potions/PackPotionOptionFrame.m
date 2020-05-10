//
//  PackPotionOptionFrame.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "PackPotionOptionFrame.h"
#import "UserPotion.h"
#import "MysticImage.h"
#import "EffectControl.h"
#import "UIImageView+WebCache.h"
#import "MysticEffectsManager.h"
#import "UIView+Mystic.h"

@implementation PackPotionOptionFrame


- (id) init;
{
    self = [super init];
    if(self)
    {
        self.levelRules = MysticLayerLevelRuleAuto;

    }
    return self;
}

- (void) setInfo:(NSDictionary *)info;
{
    [super setInfo:info];
    self.showBg = !self.allowColorReplacement;
    
}

- (BOOL) canInvertTexture;
{
    if(self.showBg) return YES;
    return !self.canReplaceColor;
}
- (BOOL) fillTransparency;
{
    switch (self.normalBlendingType) {
        case MysticFilterTypeBlendMaskScreenNoFill:
        case MysticFilterTypeBlendMaskMultiplyNoFill:
            
            return NO;
            
        default: break;
    }
    return !self.showBg;
}
- (BOOL) allowNormalBlending; { return YES; }
- (BOOL) allowNoBlending; { return NO; }

- (BOOL) allowColorReplacement;
{
    if(self.blendingType == MysticFilterTypeMask)
    {
        return YES;
    }
    return [super allowColorReplacement];
}

- (BOOL) hasForegroundColor;
{
    if([super hasForegroundColor]) return YES;
    return [self colorType:MysticOptionColorTypeForeground]!=MysticColorTypeAuto;
}


- (MysticColorType) colorType:(MysticOptionColorType)ctype;
{
    MysticColorType c = [super colorType:ctype];
    if(!(c == MysticColorTypeAuto && ctype == MysticOptionColorTypeForeground)) return c;
    switch (self.normalBlendingType) {
        case MysticFilterTypeBlendMaskMultiply:
        case MysticFilterTypeBlendMaskMultiplyNoFill:
        case MysticFilterTypeBlendMultiply: return MysticColorTypeChoice2;
        case MysticFilterTypeBlendMaskScreen:
        case MysticFilterTypeBlendMaskScreenNoFill:
        case MysticFilterTypeBlendScreen: return MysticColorTypeChoice1;
        case MysticFilterTypeBlendNormal: break;
        default: return MysticColorTypeChoice1;
    }
    return c;
}

- (BOOL) canReplaceColor;
{
    if([self hasUserSelectedColorOfOptionType:MysticOptionColorTypeForeground]) return YES;
    MysticFilterType ctype = self.filterType;
    MysticFilterType ntype = self.normalBlendingType;
    return ntype == MysticFilterTypeMask
        || (ctype == MysticFilterTypeUnknown && (ntype == MysticFilterTypeBlendMaskScreen || ntype == MysticFilterTypeBlendMaskMultiply || ntype == MysticFilterTypeBlendMaskMultiplyNoFill || ntype == MysticFilterTypeBlendMaskScreenNoFill))
        || (ctype == ntype && ctype != MysticFilterTypeBlendNormal && ctype != MysticFilterTypeBlendAlpha && ctype != MysticFilterTypeBlendAlphaMix);
}

- (BOOL) hasCustomLayerEffects; { return self.allowColorReplacement; }
- (BOOL) canFillBackgroundColor; { return YES; }
- (MysticLayerEffect) layerEffect;
{
    MysticLayerEffect value = super.layerEffect;
    
    if(!self.allowColorReplacement) return value;
    
    MysticColorType cType = [self colorType:MysticOptionColorTypeForeground];
    
    switch (cType) {
        case MysticColorTypeLayerEffectNone:
        {
            value = MysticLayerEffectNone;
            break;
        }
        case MysticColorTypeLayerEffectInvertedWhite:
        case MysticColorTypeLayerEffectInverted:
        {
            
            value = value != MysticLayerEffectNone ? MysticLayerEffectInverted : MysticLayerEffectNone;
            break;
        }
        case MysticColorTypeLayerEffectDesaturate:
        {
            value = MysticLayerEffectDesaturate;
            break;
        }
        case MysticColorTypeLayerEffectOne:
        {
            value = MysticLayerEffectOne;
            break;
        }
        case MysticColorTypeLayerEffectTwo:
        {
            value = MysticLayerEffectTwo;
            break;
        }
        case MysticColorTypeLayerEffectThree:
        {
            value = MysticLayerEffectThree;
            break;
        }
        case MysticColorTypeLayerEffectFour:
        {
            value = MysticLayerEffectFour;
            break;
        }
        default:
        {
            value = MysticLayerEffectNone;
            break;
        }
    }
    
    return value;
}
- (void) setLayerEffect:(MysticLayerEffect)value;
{
    
    [super setLayerEffect:value];
    
    
    if(!self.allowColorReplacement) return;

    
    MysticColorType newColorType = MysticColorTypeAuto;
    
    switch (value) {
        case MysticLayerEffectNone:
        {
            newColorType = MysticColorTypeLayerEffectNone;
            break;
        }
        case MysticLayerEffectInverted:
        {
            newColorType = MysticColorTypeLayerEffectInverted;
            switch (self.normalBlendingType) {
                case MysticFilterTypeBlendMaskMultiply:
                case MysticFilterTypeBlendMaskMultiplyNoFill:
                case MysticFilterTypeBlendMultiply:
                {
                    newColorType = MysticColorTypeChoice1;
                    break;
                }
                case MysticFilterTypeBlendMaskScreen:
                case MysticFilterTypeBlendMaskScreenNoFill:
                case MysticFilterTypeBlendScreen:
                {
                    newColorType = MysticColorTypeChoice2;
                    break;
                }
                default:
                {
                    break;
                }
            }
            break;
        }
        case MysticLayerEffectDesaturate:
        {
            newColorType = MysticColorTypeLayerEffectDesaturate;
            
            break;
        }
        case MysticLayerEffectOne:
        {
            newColorType = MysticColorTypeLayerEffectOne;
            
            break;
        }
        case MysticLayerEffectTwo:
        {
            newColorType = MysticColorTypeLayerEffectTwo;
            break;
        }
        case MysticLayerEffectThree:
        {
            newColorType = MysticColorTypeLayerEffectThree;
            break;
        }
        case MysticLayerEffectFour:
        {
            newColorType = MysticColorTypeLayerEffectFour;
            break;
        }
        case MysticLayerEffectRandom:
        {
            newColorType = MysticColorTypeLayerEffectRandom;
            break;
        }
        case MysticLayerEffectLast:
        {
            newColorType = MysticColorTypeLayerEffectLast;
            
            break;
        }
            
        default: break;
    }
    self.hasChanged = YES;
    
    
    [self setColorType:MysticOptionColorTypeForeground color:@(newColorType)];
    
    [(PackPotionOptionColor *)self setupFilter:[MysticOptions current].filters.filter];
    
    
    
    
    
}



- (UIColor *) maskBackgroundColor;
{
    return self.fillTransparency ? [self.backgroundColor invertedColor] : self.backgroundColor;
}
- (UIColor *) backgroundColor;
{
    return [super backgroundColor];
    
}
- (BOOL) ignoreAspectRatio; { return NO; }
- (id) setUserChoice
{
//    self.blended = [UserPotion optionForType:self.type].blended;
//    self.inverted = [UserPotion optionForType:self.type].inverted;
    [super setUserChoice];
    
    [UserPotion optionForType:self.type].intensity = self.presetIntensity > 0 ? self.presetIntensity : kFrameAlpha;
    if(self.presetBlending)
    {
        [UserPotion optionForType:self.type].blended = self.presetBlending;
        self.blended = [UserPotion optionForType:self.type].blended;
    }
    
    if(self.presetInvert)
    {
        [UserPotion optionForType:self.type].inverted = self.presetInvert;
        self.inverted = [UserPotion optionForType:self.type].inverted;
    }
    return self;
}
- (void) prepareControlForReuse:(EffectControl *)control;
{
    [super prepareControlForReuse:control];
    control.imageView = nil;
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    [self prepareControlForReuse:control];

    if(effect.cancelsEffect) return;
    
    
    
    __unsafe_unretained __block EffectControl *_control = [control retain];
    __unsafe_unretained __block PackPotionOption *weakSelf = [self retain];
    
    
    
    
    if(self.thumbnail)
    {
        _control.imageView.alpha = 1;
        
        _control.imageView.image = self.thumbnail;
        _control.imageView.highlightedImage = self.thumbnailHighlighted;
        weakSelf.hasBeenDisplayed = YES;
        [weakSelf release];
        [_control release];
    }
    else
    {
        [control.imageView cancelCurrentImageLoad];
        [control.imageView setImageWithURL:[NSURL URLWithString:self.thumbURLString] placeholderImage:nil options:0 manager:MysticCache.uiManager progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

            weakSelf.thumbnail = image;
            
            [MysticUIView animateWithDuration:MYSTIC_UI_CONTROL_FADE_DURATION animations:^{
                _control.imageView.alpha = _control.selected ? kMYSTICControlSelectedImageViewAlphaLayer : 1;
            } completion:^(BOOL finished) {
                weakSelf.hasBeenDisplayed = YES;
                _control.imageView.alpha = _control.selected ? kMYSTICControlSelectedImageViewAlphaLayer : 1;

                [weakSelf release];
                [_control release];
            }];
            
        }];
        _control.imageView.alpha = 0;
        
        
    }
}


@end

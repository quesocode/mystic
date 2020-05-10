//
//  PackPotionOptionText.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "PackPotionOptionText.h"
#import "UserPotion.h"
#import "MysticEffectsManager.h"
#import "EffectControl.h"
#import "SDWebImageManager.h"
#import "MysticController.h"
#import "UIViewController+MMDrawerController.h"

@interface PackPotionOptionText ()
{
    CGRect lastTransformNormalRect;
}
@end

@implementation PackPotionOptionText

- (id) init;
{
    self = [super init];
    if(self)
    {
        self.levelRules = MysticLayerLevelRuleAuto|MysticLayerLevelRuleAlwaysHighestBelowTop;
        self.showBg = NO;
        lastTransformNormalRect = CGRectZero;
    }
    return self;
}

- (BOOL) fillTransparency; { return NO; }

- (BOOL) fillBackgroundColor;
{
    return [self hasUserSelectedColorOfOptionType:MysticOptionColorTypeBackground];
}

- (BOOL) hasCustomLayerEffects;
{
    return self.allowColorReplacement;
}



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
    
    
    
    
    
    
    
}
- (void) setColorType:(MysticOptionColorType)optType color:(id)color;
{
    
    [super setColorType:optType color:color];
}
- (MysticColorType) colorType:(MysticOptionColorType)ctype;
{
    MysticColorType c = [super colorType:ctype];
    
//    MysticColorType bc = c;
    
    if(c == MysticColorTypeAuto && ctype == MysticOptionColorTypeForeground)
    {
        MysticFilterType __filterType = self.normalBlendingType;
        
        switch (__filterType) {
            case MysticFilterTypeBlendMaskMultiply:
            case MysticFilterTypeBlendMaskMultiplyNoFill:
                
            case MysticFilterTypeBlendMultiply:
                c = MysticColorTypeChoice2;
                break;
            case MysticFilterTypeBlendMaskScreen:
            case MysticFilterTypeBlendMaskScreenNoFill:
                
            case MysticFilterTypeBlendScreen:
                c = MysticColorTypeChoice1;
                break;
            case MysticFilterTypeBlendNormal:
            {
                break;
            }
            default:
                c = MysticColorTypeChoice1;
                break;
        }
        
        
        
    }
    
    
    
    return c;
}
- (BOOL) canReplaceColor;
{
    BOOL hascolor = [self hasUserSelectedColorOfOptionType:MysticOptionColorTypeForeground];
    if(hascolor) return YES;
    
    MysticFilterType ctype = self.filterType;
    MysticFilterType ntype = self.normalBlendingType;
    
    if((ctype == MysticFilterTypeUnknown && (ntype == MysticFilterTypeBlendMaskScreen || ntype == MysticFilterTypeBlendMaskMultiply || ntype == MysticFilterTypeBlendMaskScreenNoFill || ntype == MysticFilterTypeBlendMaskMultiplyNoFill)) || (ctype == ntype && ctype != MysticFilterTypeBlendNormal && ctype != MysticFilterTypeBlendAlpha && ctype != MysticFilterTypeBlendAlphaMix))
    {
        
        
        
        return YES;
    }
    return NO;
}

- (BOOL) canChooseCancelColor;
{
//    return YES;
    MysticFilterType ntype = self.normalBlendingType;
    
    return ( ntype == MysticFilterTypeBlendNormal || ntype == MysticFilterTypeBlendAlpha || ntype == MysticFilterTypeBlendAlphaMix);
    
}

- (BOOL) allowNormalBlending; { return YES; }
- (BOOL) allowNoBlending; { return YES; }

- (BOOL) anchorTopLeft; { return YES; }
- (BOOL) ignoreAspectRatio; { return YES; }
- (BOOL) stretchLayerImage { return NO; }
- (BOOL) canInvertTexture;
{
    return !self.canReplaceColor;
}

- (BOOL) canFillBackgroundColor; { return YES; }
- (BOOL) canFillTransformBackgroundColor; { return NO; }

- (BOOL) hasForegroundColor;
{
    if([super hasForegroundColor]) return YES;
    return [self colorType:MysticOptionColorTypeForeground]!=MysticColorTypeAuto;
}


- (id) setUserChoice
{
    PackPotionOption *currentTarget = self.targetOption ? self.targetOption : [[MysticOptions current] option:self.type];
    [super setUserChoice:YES finished:nil];
    
    if(currentTarget) currentTarget.intensity = self.presetIntensity > 0 ? self.presetIntensity : kTextAlpha;
    if(self.presetBlending)
    {
        if(currentTarget) currentTarget.blended = self.presetBlending;
        self.blended = currentTarget.blended;
    }
    
    if(self.presetInvert)
    {
        if(currentTarget) currentTarget.inverted = self.presetInvert;
        self.inverted = currentTarget.inverted;
    }
    return self;
}


- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.imageView = nil;
    control.backgroundView = nil;
    control.selectedOverlayView = nil;
    [self controlBecameInactive:control];

}
- (UIColor *) controlCurrentBackgroundColor:(EffectControl *)control;
{
    return control.selected ? [MysticColor colorWithType:MysticColorTypeObjectText] : [MysticColor colorWithType:MysticColorTypeControlInactive];
}
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    label.hidden = YES;
//    control.imageView.highlighted = isSelected;
    control.imageView.alpha = 1;
//    [control updateControl];
    [super updateLabel:label control:control selected:isSelected];
    if(control.hasBackgroundView) control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
    if(control.hasSelectedOverlayView) control.selectedOverlayView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
    if(control.hasImageView) control.imageView.alpha = isSelected ? 0 : 1;
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    if(effect.cancelsEffect) return;
    [self prepareControlForReuse:control];
    __unsafe_unretained EffectControl *_control = control;
    __unsafe_unretained PackPotionOptionText *weakSelf = self;

    MysticBlockImageObj readyBlock = nil;
    NSInteger visiblePosition = _control.visiblePosition;
    CGFloat imageViewAlpha = 1;
    readyBlock = self.hasProcessedThumbnail ? nil :  ^(UIImage *img, EffectControl *theControl){
        CGRect rect = CGRectMake(0, 0, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[MysticColor colorWithType:MysticColorTypeControlInactiveOverlay] setFill];
        CGContextFillRect(context, rect);
        [img drawInRect:CGRectIntegral(CGRectInset(rect, rect.size.width*.1, rect.size.height*.1)) blendMode:[weakSelf CGBlendMode] alpha:1];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        newImage = [UIImage imageWithCGImage:newImage.CGImage scale:img.scale orientation:UIImageOrientationUp];
        UIGraphicsEndImageContext();
        theControl.imageView.image = newImage;
        [weakSelf setThumbnail:newImage];
        theControl.imageView.alpha = 1;
        theControl.imageView.hidden = NO;
    };
    
    if(self.thumbnail)
    {
        if(readyBlock)
        {
            readyBlock(self.thumbnail, control);
        }
        else
        {
            _control.imageView.image = self.thumbnail;
            _control.imageView.highlightedImage = self.thumbnailHighlighted;
            _control.imageView.alpha = 1;
            _control.imageView.hidden = NO;
        }
    }
    else
    {
        
        
        _control.imageView.alpha = imageViewAlpha;
        UIImage *image = effect.layerThumbImage;
        
        if(image) { if(readyBlock) readyBlock(image, _control); }
        else
        {
            [MysticCache.uiManager downloadWithURL:[NSURL URLWithString:self.thumbURLString] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
             {
                 if(!finished || !image) return;
                 if(readyBlock) readyBlock(image, _control);
             }];
        }
    }
}
- (UIImage *) icon; { return _iconImg; }

- (MysticBlockSetImageView) imageViewBlock;
{
    if(_iconImg) return nil;

    __unsafe_unretained __block PackPotionOptionText *weakSelf = [self retain];

    MysticBlockSetImageView b2 = ^(UITableViewCell *cell, MysticBlockObjBOOL c)
    {
        __unsafe_unretained UITableViewCell *_cell = [cell retain];
        __unsafe_unretained UIImageView *_imageView = [cell.imageView retain];
        __unsafe_unretained __block MysticBlockObjBOOL _c = c ? Block_copy(c) : nil;
        
        
        __block CGSize _rsize = _imageView.frame.size;
        _rsize.width = MAX(_rsize.width, MYSTIC_DRAWER_LAYER_ICON_WIDTH);
        _rsize.height = MAX(_rsize.height, MYSTIC_DRAWER_LAYER_ICON_HEIGHT);

        MysticBlockReturnsImageFromObj readyBlock = (^UIImage *(UIImage *img){
            
            CGRect rect = CGRectMake(0, 0, _rsize.width, _rsize.height);
            UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [[MysticColor colorWithType:MysticColorTypeLayerIconBackground] setFill];
            CGContextFillRect(context, rect);
            CGRect newrect = rect;
            
            newrect = CGRectInset(rect, rect.size.width*.1, rect.size.height*.1);
            [img drawInRect:CGRectIntegral(newrect) blendMode:[self CGBlendMode] alpha:1];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            newImage = [UIImage imageWithCGImage:newImage.CGImage scale:newImage.scale orientation:UIImageOrientationUp];
            UIGraphicsEndImageContext();
            return newImage;
            
            
        });

        __block UIImage *newImg = nil;
        [MysticCache.uiManager downloadWithURL:[NSURL URLWithString:weakSelf.thumbURLString] options:0 progress:nil completed:^(UIImage *dimage, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             
             
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

             if(finished && readyBlock && dimage) {
                 newImg = readyBlock(dimage);
                 [newImg retain];
                 _imageView.image = newImg;
                 [weakSelf setIcon:newImg];

                 dispatch_async(dispatch_get_main_queue(), ^{
                   
                     
                     
                     if(_c)
                     {
                         _c(newImg, YES);
                         Block_release(_c);
                     }
                     [_imageView release];
                     [_cell release];
                     [weakSelf release];
                     [newImg autorelease];
                 
                 });
                 

             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(_c)
                     {
                         _c(nil, NO);
                         Block_release(_c);
                     }
                 });


             }

                 
         });
         
     }];
//        }
    };
    return Block_copy(b2);
    
}

- (void) setForegroundColor:(UIColor *)foregroundColor;
{
    
    [super setForegroundColor:foregroundColor];
}

- (UIColor *) foregroundColor
{
    UIColor *f = [super foregroundColor];
    if(!f) f = [UIColor whiteColor];
    return f;
}


- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption setting:(MysticObjectType)setting;
{
    if(!otherOption) return;
    
    if([otherOption isKindOfClass:[PackPotionOptionColor class]])
    {
        PackPotionOptionColor *colorOpt = (id)otherOption;
        if(![self hasUserSelectedColorOfOptionType:MysticOptionColorTypeBackground] && colorOpt.optionType == MysticOptionColorTypeBackground)
        {
            if([colorOpt color].alpha == 1)
            {
                colorOpt.color = [colorOpt.color colorWithAlphaComponent:0.5];
                
            }
        }
        else if([colorOpt color].alpha == 1  && colorOpt.optionType == MysticOptionColorTypeBackground)
        {
            colorOpt.color = [colorOpt.color colorWithAlphaComponent:self.backgroundColor.alpha];
            
        }
    }
    
    [super applyAdjustmentsFrom:otherOption setting:setting];
    switch (otherOption.type) {
        case MysticObjectTypeText:
        {
            [self.colorTypes addEntriesFromDictionary:otherOption.colorTypes];
            self.intensity = otherOption.intensity;
            self.layerEffect = otherOption.layerEffect;
            self.colorMatrix = otherOption.colorMatrix;
            break;
        }
        default: break;
    }
    
}


@end

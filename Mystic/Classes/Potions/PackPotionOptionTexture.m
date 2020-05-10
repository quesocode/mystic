//
//  PackPotionOptionTexture.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "PackPotionOptionTexture.h"
#import "UserPotion.h"
#import "EffectControl.h"
#import "UIImageView+WebCache.h"
#import "UIView+Mystic.h"

@implementation PackPotionOptionTexture




- (void) prepareControlForReuse:(EffectControl *)control;
{
    [super prepareControlForReuse:control];
    control.imageView = nil;
//    control.imageView.image = nil;
//    control.imageView.highlightedImage = nil;
//    control.imageView.highlighted = NO;
//    control.imageView.alpha = 1;
    
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    [self prepareControlForReuse:control];

    if(effect.cancelsEffect) return;
    
    
    __unsafe_unretained __block EffectControl *_control = [control retain];
    __unsafe_unretained __block PackPotionOption *weakSelf = [self retain];
    __block CGFloat _imageViewAlpha = _control.selected ? kMYSTICControlSelectedImageViewAlphaLayer : 1.0f;
    
    
    
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
            
            [MysticUIView animateWithDuration:MYSTIC_UI_CONTROL_FADE_DURATION animations:
            ^{
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


- (id) setUserChoice
{
    [super setUserChoice:YES finished:nil];
    
    [UserPotion optionForType:self.type].intensity = self.presetIntensity > 0 ? self.presetIntensity : kTextureAlpha;
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


@end

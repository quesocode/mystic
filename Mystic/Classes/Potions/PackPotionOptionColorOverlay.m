//
//  PackPotionOptionColorOverlay.m
//  Mystic
//
//  Created by Me on 6/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionColorOverlay.h"
#import "UserPotion.h"
#import "EffectControl.h"
#import "MysticCacheImage.h"
#import "MysticCacheImageKey.h"
#import "MysticLayerTableViewCell.h"

@interface PackPotionOptionColorOverlay ()
{
}
@end

@implementation PackPotionOptionColorOverlay

+ (id) optionWithItem:(MysticCollectionItem *)theItem;
{
    PackPotionOptionColorOverlay *option = [super optionWithItem:theItem];

    
    return option;
}

+ (id) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    
    if(![info objectForKey:@"blend"])
    {
        NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        
        [newInfo setObject:@"color" forKey:@"blend"];
        info = newInfo;
    }
    PackPotionOptionColorOverlay *option = [super optionWithName:name info:info];
    
    return option;

}
//- (NSString *) tag;
//{
//    return self.item.tag;
//    
//}

- (id) init;
{
    self = [super init];
    if(self)
    {
//        self.levelRules = self.levelRules|MysticLayerLevelRuleAlwaysBelowTop;
        self.levelRules = MysticLayerLevelRuleAuto|MysticLayerLevelRuleAlwaysBelowTop;
        _iconImgError = NO;

    }
    return self;
}

- (BOOL) allowNoBlending; { return YES; }
- (MysticFilterType) normalBlendingType;
{
    return MysticFilterTypeBlendNormal;
}

- (BOOL) showControlEffectToggler; { return NO; }

- (NSString *) name;
{
    return self.item.title;
}

- (MysticObjectType) type;
{
    return MysticObjectTypeColorOverlay;
}
- (NSString *) layerTitle;
{
    if(self.item.title) return self.item.title;
    return @"Color";
}
- (NSString *) layerSubtitle;
{
    if(!self.item.title)
    {
        switch (self.item.type)
        {
            case MysticCollectionItemTypeColor:
            {
                return MyLocalStr(@"OVERLAY");
                
            }
            case MysticCollectionItemTypeGradient:
            {
                return MyLocalStr(@"GRADIENT");
                
                
                
            }
            default:
            {
                return MyLocalStr(@"OVERLAY");
            }
        }
    }
    return MysticObjectTypeTitleParent(MysticObjectTypeColorOverlay, nil);
}
- (id) setUserChoice
{
    //    self.blended = [UserPotion optionForType:self.type].blended;
    //    self.inverted = [UserPotion optionForType:self.type].inverted;
    [super setUserChoice];
    
    [UserPotion optionForType:self.type].intensity = self.presetIntensity > 0 ? self.presetIntensity : kLightAlpha;
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
    [control.backgroundView removeBackgroundGradient];
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    [self prepareControlForReuse:control];
    
    if(effect.cancelsEffect) return;
    
    
   


}

- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    [super updateLabel:label control:control selected:isSelected];
    CGRect cf = control.frame;
    control.backgroundView.frame = CGRectXYWH(cf, 0, 7,  cf.size.width-5, cf.size.height - 7);
    if(isSelected && control.hasSelectedOverlayView)
    {
        control.selectedOverlayView.frame = CGRectY(control.selectedOverlayView.frame, 0);
    }

    if(isSelected)
    {
        control.backgroundView.backgroundColor = [UIColor clearColor];
        [control.backgroundView removeBackgroundGradient];
        [self controlBecameActive:control];
        return;
    }
    else [self controlBecameInactive:control];
    switch (self.item.type)
    {
        case MysticCollectionItemTypeColor:
        {
            control.backgroundView.backgroundColor = self.item.displayColor;
            break;
        }
            
        default:
        {
            
       
            [control.backgroundView setBackgroundGradient:self.item.gradient];
            
        
            
            break;
        }
    }
}



- (MysticImageLayer *) layerImageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize;
{
    
    switch (self.item.type)
    {
        
        case MysticCollectionItemTypeColor:
        case MysticCollectionItemTypeGradient:
        {
            NSString *cacheTag = [NSString stringWithFormat:@"%@-%2.0fx%2.0f", [self.item.colorStrings componentsJoinedByString:@"-"], renderSize.width, renderSize.height];
            MysticCacheImageKey *imageOptions = [MysticCacheImageKey options:@{
                                                                             @"option": self,
                                                                             @"tag": cacheTag,
                                                                             @"type": @(self.layerImageType),
                                                                             @"level": @(MYSTIC_LAYER_CACHED_LEVEL),
                                                                             @"cache": @(MysticCacheTypeLayer),
                                                                             @"name": @"layerSourceColor",
                                                                             @"saveToDisk": @YES,
                                                                             }];
            
            
            MysticImageLayer *returnImage = (id)[[MysticCacheImage layerCache] imageForOptions:imageOptions];

            
            if(returnImage) {
                
//                DLog(@"FOUND CACHE color overlay: %@", imageOptions.cacheKey);

                if(!self.readyForRender) self.readyForRender = YES;
                return returnImage;
            }
            
            switch (self.item.type) {
                case MysticCollectionItemTypeColor:
                {
                    returnImage = [MysticImage backgroundImageWithColor:self.item.color size:renderSize scale:1];
                    
                    break;
                }
                case MysticCollectionItemTypeGradient:
                {
                    returnImage = [MysticImage backgroundImageWithColor:self.item.colorStrings size:renderSize scale:1];
                    
                    break;
                }
                    
                default: break;
            }
            
            
            if(returnImage)
            {
                MysticImage *cachedReturnImage = [MysticCacheImage addImage:returnImage options:imageOptions];
                
            }
            if(!self.readyForRender) {  self.readyForRender = YES; }

            return returnImage;
            
            
        
        }
        default: break;
    }
    return [super layerImageForSettings:settings size:renderSize];
}

- (MysticImageType) layerImageType;
{
    MysticImageType itype = MysticImageTypeJPG;
    return itype;
}




- (MysticBlockSetImageView) imageViewBlock;
{
    if(_iconImg || _iconImgError)
    {
        return nil;
    }
    
    __unsafe_unretained __block PackPotionOptionColorOverlay *weakSelf = [self retain];
    
    MysticBlockSetImageView b2 = ^(UITableViewCell *cell, MysticBlockObjBOOL c)
    {
        __unsafe_unretained UITableViewCell *_cell = [cell retain];
        __unsafe_unretained UIImageView *_imageView = [cell.imageView retain];
        __block CGSize _rsize = CGSizeMakeAtLeast(_imageView.frame.size, (CGSize){MYSTIC_DRAWER_LAYER_ICON_WIDTH, MYSTIC_DRAWER_LAYER_ICON_HEIGHT});
        
        __unsafe_unretained __block MysticBlockObjBOOL _c = c ? Block_copy(c) : nil;
        __unsafe_unretained __block PackPotionOptionColorOverlay *_weakSelf = [weakSelf retain];

        NSBlockOperation *renderBlock = [NSBlockOperation blockOperationWithBlock:^{
            
            
            __block MysticImageLayer *lImg = [[_weakSelf layerImageForSettings:MysticRenderOptionsThumb size:[MysticUI scaleSize:_rsize scale:0]] retain];
            
            [_weakSelf setIcon:lImg];
//            ALLog(@"finished color overlay img", @[
//                                                   @"size", SLogStr(_rsize),
//                                                   @"lImg", ILogStr(lImg),
//                                                   @"option", MObj(_weakSelf.tag),
//                                                   @"option.name", MObj(_weakSelf.name),
//
//                                                   ]);
            
            if(!lImg)
            {
                _iconImgError = YES;
            }
            else
            {
                _imageView.image = lImg;
            }
            

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(_c)
                {
                    _c(lImg, !_iconImgError);
                    Block_release(_c);
                }
                [lImg release];
                
            });
            [_weakSelf release];
            
            
        }];
        [renderBlock setCompletionBlock:^{
            [weakSelf release], weakSelf=nil;
            [_imageView release];
            [_cell release];
        }];
        
        
        [[MysticLayerRenderQueue sharedQueue] addOperation:renderBlock];
        
        
    };
    return Block_copy(b2);
}

@end

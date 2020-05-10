//
//  PackPotionOptionSpecial.m
//  Mystic
//
//  Created by Me on 10/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionSpecial.h"
#import "Mystic.h"
#import "MysticLayerTableViewCell.h"
#import "EffectControl.h"

@implementation PackPotionOptionSpecial

- (void) commonInit;
{
    [super commonInit];
}



//- (void) updateControl:(EffectControl *)control selected:(BOOL)makeSelected;
//{
//
//}
- (BOOL) hasInput;
{
    return self.hasImage;
}


- (MysticBlockSetImageView) imageViewBlock;
{
    if(_iconImg) return nil;
    
    __unsafe_unretained __block PackPotionOptionSpecial *weakSelf = [self retain];
    
    MysticBlockSetImageView b2 = ^(UITableViewCell *cell, MysticBlockObjBOOL c)
    {
        __unsafe_unretained UITableViewCell *_cell = [cell retain];
        __unsafe_unretained UIImageView *_imageView = [cell.imageView retain];
        __block CGSize _rsize = CGSizeMakeAtLeast(_imageView.frame.size, (CGSize){MYSTIC_DRAWER_LAYER_ICON_WIDTH, MYSTIC_DRAWER_LAYER_ICON_HEIGHT});
 
        __unsafe_unretained __block MysticBlockObjBOOL _c = c ? Block_copy(c) : nil;
        MysticBlockReturnsImageFromObj readyBlock = (^UIImage *(UIImage *img){
            
            CGRect rect = CGRectMake(0, 0, _rsize.width, _rsize.height);
            UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            UIColor *clr = weakSelf.specialColor;
            clr = clr ? clr : [MysticColor colorWithType:MysticColorTypeLayerIconBackground];
            [clr setFill];
            CGContextFillRect(context, rect);
            
            [[[MysticColor colorWithType:MysticColorTypeLayerIconBackground] colorWithAlphaComponent:0.35] setFill];
            CGContextFillRect(context, rect);
            
            CGRect drect = CGRectInset(rect, rect.size.width*.25, rect.size.height*.25);
            drect = CGRectIntegral(CGRectWithContentMode(rect, drect, UIViewContentModeScaleAspectFit));
            CGRect arect = CGRectAlign(drect, rect, MysticAlignPositionCenter);
            
            [img drawInRect:drect blendMode:kCGBlendModePlusLighter alpha:1];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            newImage = [UIImage imageWithCGImage:newImage.CGImage scale:newImage.scale orientation:UIImageOrientationUp];
            UIGraphicsEndImageContext();
            return newImage;
            
            
        });
        
        __block UIImage *newImg = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            UIImage *dimage = [MysticImage image:@([MysticIcon iconTypeForObjectType:self.type]) size:[[(MysticLayerTableViewCell *)cell class] imageViewSize] color:@(MysticColorTypeDrawerIconImageOverlay)];
            
            newImg = readyBlock(dimage);
            
            [newImg retain];
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
            
            
            
            
            
        });
        
    };
    return Block_copy(b2);
}
- (BOOL) requiresFrameRefresh; { return NO; }
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    UIColor *newBgColor = isSelected ? [UIColor clearColor] : nil;
    if(!isSelected && !newBgColor)
    {
        
        MysticColorType controlColorType = MysticColorTypeControlBackgroundSpecial + control.position;
        controlColorType = controlColorType >= MysticColorTypeLastChoice ? (controlColorType - MysticColorTypeLastChoice) + MysticColorTypeControlBackgroundSpecial : controlColorType;
        newBgColor = [UIColor color:controlColorType];
    }
    if(!isSelected)
    {
        [self controlBecameInactive:control];
    }
    else
    {
        [self controlBecameActive:control];
    }
    control.backgroundView.backgroundColor = newBgColor;
    control.backgroundColor = [control.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];
    
    [control updateControl];
}

- (void) controlBecameActive:(EffectControl *)control;
{
    __unsafe_unretained __block id weakSelf = self;
    __unsafe_unretained __block EffectControl *__control = control;
    
    if(__control.selected)
    {
        [weakSelf showControlToggler:__control];
    }
}

- (void) controlBecameInactive:(EffectControl *)control;
{
    UIView *toggler = (UIView *)control.accessoryView;
    
    if(toggler)
    {
        control.accessoryView=nil;
        toggler = nil;
    }
    control.titleLabel.alpha = 1;
    
    
}

- (void) showControlToggler:(EffectControl *)control;
{
    
    
    
    __unsafe_unretained __block EffectControl *__control = control;
    
    UIView *customControlsView = control.accessoryView;
    if(!customControlsView)
    {
        
        customControlsView = [[UIView alloc] initWithFrame:control.selectedOverlayView.frame];
        CGPoint toggleCenter = customControlsView.center;
        
        CGFloat b = MYSTIC_UI_CONTROL_SUBBTN_SIZE;
        CGSize subBtnSize = CGSizeMake(32, 14);
        
        MysticButton *settingsBtn = [MysticButton button:[MysticImage image:@(MysticIconTypeMiniSlider) size:subBtnSize color:@(MysticColorTypeControlSubBtn)] action:^(id sender) {
            [__control accessoryTouched:sender];
            
        }];
        
        settingsBtn.hitInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        settingsBtn.adjustsImageWhenHighlighted = YES;
        settingsBtn.frame = CGRectMake(customControlsView.bounds.size.width/2 - subBtnSize.width/2,
                                       (customControlsView.bounds.size.height - subBtnSize.height)/2,
                                       subBtnSize.width, subBtnSize.height);
        settingsBtn.tag = MysticViewTypeButtonSettings;
        settingsBtn.alpha = 0;
        settingsBtn.transform = CGAffineTransformIdentity;
        settingsBtn.transform = CGAffineTransformScale(settingsBtn.transform, 0.25, 1);
        settingsBtn.contentMode = UIViewContentModeCenter;
        
        [customControlsView addSubview:settingsBtn];
        control.accessoryView = customControlsView;
        [customControlsView release];
        
        
        [MysticUIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
         {
             settingsBtn.transform = CGAffineTransformIdentity;
             settingsBtn.alpha = 1;
             
         } completion:^(BOOL finished2) {
             settingsBtn.alpha = 1;
             settingsBtn.transform = CGAffineTransformIdentity;
             
         }];
    }
    
    
    
    //    }
}

@end

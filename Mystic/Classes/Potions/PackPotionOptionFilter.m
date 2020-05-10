//
//  PackPotionOptionFilter.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "PackPotionOptionFilter.h"
#import "UserPotion.h"
#import "MysticEffectsManager.h"
#import "GPUImage.h"
#import "MysticUI.h"
#import "EffectControl.h"
#import "UIImageView+WebCache.h"
#import "MysticLayerTableViewCell.h"
#import "MysticFilterLookup.h"

#import "UserPotion.h"



@interface PackPotionOptionFilter ()
{
    BOOL setBgColor;
}
@end



@implementation PackPotionOptionFilter


+ (MysticControlObject *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionFilter *option = (PackPotionOptionFilter *)[super optionWithName:name info:info];
    option.intensity = option.presetIntensity > 0 ? option.presetIntensity : kColorAlpha;
    return option;
    
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        self.levelRules = self.levelRules|MysticLayerLevelRuleAlwaysHighest;
        setBgColor = NO;
    }
    return self;
}
//- (BOOL) createNewCopy;
//{
//    return NO;
//}
- (BOOL) allowsMultipleSelections; { return NO; }
- (BOOL) hasAdjustableSettings; { return NO; }
- (BOOL) resizeLayerImage; { return NO; }
- (id) setUserChoice
{
    [super setUserChoice];
    
    
//    if(self.presetSunshine) self.applySunshine = self.presetSunshine;
    return self;
}
- (BOOL) requiresFrameRefresh; { return NO; }
- (void) prepareControlForReuse:(EffectControl *)control;
{
    setBgColor = NO;
    [self controlBecameInactive:control];
}
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    
    [control setCornerRadius:0];

    label.alpha = isSelected ? 0 : 1;

    CGRect nlframe = label.frame;
    nlframe.size.height = MYSTIC_UI_CONTROL_LABEL_HEIGHT_MED;
    nlframe.origin.y = control.frame.size.height - nlframe.size.height - 5;
    label.frame = CGRectIntegral(nlframe);
    label.textColor = [UIColor colorWithType:MysticColorTypeControlBorderActive];
    label.font = [MysticUI gothamBold:8];
    label.text = [label.text uppercaseString];
    label.backgroundColor = [UIColor clearColor];
    [control bringSubviewToFront:label];

//    
    UIColor *newBgColor = isSelected ? [UIColor clearColor] : control.option.backgroundColor;

    if(!isSelected && (!newBgColor || [newBgColor isEqualToColor:[UIColor blackColor]]))
    {
        MysticColorType controlColorType = MysticColorTypeControlBackground1 + control.position;
        controlColorType = controlColorType >= MysticColorTypeLastChoice ? (controlColorType - MysticColorTypeLastChoice) + MysticColorTypeControlBackground1 : controlColorType;
        newBgColor = [UIColor color:controlColorType];
    }
    
    if(!isSelected)
    {
        [self controlBecameInactive:control];
        control.imageView.hidden = NO;
    }
    else
    {
        [self controlBecameActive:control];
        control.imageView.hidden = YES;

    }
    control.backgroundView.backgroundColor = newBgColor;
    control.backgroundColor = [control.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];
    [control updateControl];
}


- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    /*
    if(effect.cancelsEffect) return;
    [self prepareControlForReuse:control];
    __unsafe_unretained EffectControl *_control = control;
    __unsafe_unretained PackPotionOptionFilter *weakSelf = self;
    MysticBlockImageObj readyBlock = nil;
    NSInteger visiblePosition = _control.visiblePosition;
    //    CGFloat imageViewAlpha = visiblePosition == NSNotFound ? 1 : 0;
    CGFloat imageViewAlpha = 1;
    _control.imageView.contentMode = UIViewContentModeScaleAspectFill;

    readyBlock = self.hasProcessedThumbnail ? nil :  ^(UIImage *img, EffectControl *theControl){
        
        UIImage *newImage = nil;
        
        UIImage *sourceThumbImg = [UserPotion potion].thumbnailImage;
        
        CGFloat sourceWidth = CGImageGetWidth(sourceThumbImg.CGImage);
        CGFloat sourceHeight = CGImageGetHeight(sourceThumbImg.CGImage);

        NSString *cachePath = [[UserPotionManager cachePathForKey:[weakSelf.tag prefix:@"control-filter-"] cacheType:MysticCacheTypeProject] suffix:[NSString stringWithFormat: @"__%2.0fx%2.0f.jpg", sourceWidth, sourceHeight]];
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
        {
            newImage = [UIImage imageWithContentsOfFile:cachePath];
            theControl.imageView.image = newImage;
            theControl.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [weakSelf setThumbnail:newImage];
            theControl.imageView.alpha = 1;
            theControl.imageView.hidden = NO;
            return;
        }
        
//        ILog(@"user thumb image", [UserPotion potion].thumbnailImage);
//        DLog(@"filter layer source path: %@ %@  - %@", MBOOL([[NSFileManager defaultManager] fileExistsAtPath:((PackPotionOption *)theControl.effect).layerImagePath]), ((PackPotionOption *)theControl.effect).layerImagePath, ((PackPotionOption *)theControl.effect).imageName);
//        ILog(@"layer image", ((PackPotionOption *)theControl.effect).sourceImage);
        UIImage *sourceFilterImg = ((PackPotionOption *)theControl.effect).sourceImage;
        if(!sourceThumbImg)
        {
            DLog(@"there is no source thumb img");
            return;
        }
        if(!sourceFilterImg)
        {
            DLog(@"there is no source filter img");
            return;
        }
        GPUImagePicture *sourceThumb = [[GPUImagePicture alloc] initWithImage:sourceThumbImg];
        MysticFilterLookup *lookupFilter = [[MysticFilterLookup alloc] initWithImage:sourceFilterImg];
        
        [sourceThumb addTarget:lookupFilter];
        [sourceThumb processImage];
        [lookupFilter useNextFrameForImageCapture];
        newImage = [lookupFilter imageFromCurrentFramebuffer];
        theControl.imageView.image = newImage;
        theControl.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [weakSelf setThumbnail:newImage];
        theControl.imageView.alpha = 1;
        theControl.imageView.hidden = NO;
        
        NSString *upPath = [UserPotionManager setImage:newImage tag:[weakSelf.tag prefix:@"control-filter-"] cacheType:MysticCacheTypeProject];
        
        
        
        [sourceThumb autorelease];
        [lookupFilter autorelease];
    };
    
    
    DLog(@"filter has processed thumb: %@   %@", MBOOL(self.hasProcessedThumbnail), self.tag);
    
    
    if(readyBlock) readyBlock(self.thumbnail, control);
    else
    {
        _control.imageView.image = self.thumbnail;
        _control.imageView.highlightedImage = self.thumbnailHighlighted;
        _control.imageView.alpha = 1;
        _control.imageView.hidden = NO;
    }
    */
}


//- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
//{
//    [self prepareControlForReuse:control];
//
//    if(effect.cancelsEffect) return;
//    
//
//}

- (UIColor *) specialColor;
{
    
    UIColor *newBgColor = self.backgroundColor;
    if([newBgColor isEqualToColor:[UIColor blackColor]])
    {
        
        MysticColorType controlColorType = MysticColorTypeControlBackground1 + self.position;
        controlColorType = controlColorType >= MysticColorTypeLastChoice ? (controlColorType - MysticColorTypeLastChoice) + MysticColorTypeControlBackground1 : controlColorType;
        
        newBgColor = [UIColor color:controlColorType];
        
        
    }
    return newBgColor;
}


- (NSString *) thumbURLString;
{
    return [self.info objectForKey:@"thumb_url"] ? [self.info objectForKey:@"thumb_url"] : [NSString stringWithFormat:@"http://d3b9motiviyay1.cloudfront.net/newthumb/filters/%@.jpg", self.tag];
}
- (NSString *) previewURLString;
{
    return self.imageURLString;
}


- (BOOL) showLabel { return YES; }

- (BOOL) usesAccessory; { return YES; }

- (void) controlBecameActive:(EffectControl *)control;
{
    __unsafe_unretained __block PackPotionOptionFilter *weakSelf = self;
    __unsafe_unretained __block EffectControl *__control = control;

    if(__control.selected)
    {
        [weakSelf showControlToggler:__control];
    }
    control.titleLabel.alpha = 1;

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
    
    return;
//    
//    __unsafe_unretained __block EffectControl *__control = control;
//    
////    if([control.option usesAccessory])
////    {
//        UIView *customControlsView = control.accessoryView;
//        if(!customControlsView)
//        {
//            
//            customControlsView = [[UIView alloc] initWithFrame:control.backgroundView.bounds];
//            CGPoint toggleCenter = customControlsView.center;
//            
//            CGFloat b = MYSTIC_UI_CONTROL_SUBBTN_SIZE;
//            CGSize subBtnSize = CGSizeMake(32, 14);
//            
//            MysticButton *settingsBtn = [MysticButton button:[MysticImage image:@(MysticIconTypeMiniSlider) size:subBtnSize color:@(MysticColorTypeControlSubBtn)] action:^(id sender) {
//                [__control accessoryTouched:sender];
//                
//            }];
//            
//            CGSize bf = control.backgroundView.frame.size;
//            settingsBtn.hitInsets = UIEdgeInsetsMake((bf.height - subBtnSize.height)/2, (bf.width - subBtnSize.width)/2, (bf.height - subBtnSize.height)/2, (bf.width - subBtnSize.width)/2);
//            settingsBtn.adjustsImageWhenHighlighted = YES;
//            settingsBtn.frame = CGRectMake((customControlsView.bounds.size.width - subBtnSize.width)/2,
//                                           (customControlsView.bounds.size.height - subBtnSize.height)/2,
//                                           subBtnSize.width, subBtnSize.height);
//            settingsBtn.tag = MysticViewTypeButtonSettings;
//            settingsBtn.alpha = 0;
//            settingsBtn.transform = CGAffineTransformScale(settingsBtn.transform, 0.25, 1);
//            settingsBtn.contentMode = UIViewContentModeCenter;
//            [customControlsView addSubview:settingsBtn];
//            [control setAccessoryView:customControlsView center:control.backgroundView.center];
//            [customControlsView release];
//            
//            
//            [MysticUIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
//             {
//                 settingsBtn.transform = CGAffineTransformIdentity;
//                 settingsBtn.alpha = 1;
//                 
//             } completion:^(BOOL finished2) {
//                 settingsBtn.alpha = 1;
//                 settingsBtn.transform = CGAffineTransformIdentity;
//
//             }];
//        }
//        
//        
        
//    }
}



- (MysticBlockSetImageView) imageViewBlock;
{
    if(_iconImg)
    {
        return nil;
    }
    
    __unsafe_unretained __block PackPotionOptionFilter *weakSelf = [self retain];
    
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
            
            UIImage *dimage = [MysticImage image:@(MysticIconTypeSettingFilter) size:[[(MysticLayerTableViewCell *)cell class] imageViewSize] color:@(MysticColorTypeDrawerIconImageOverlay)];

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
@end

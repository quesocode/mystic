//
//  PackPotionOptionRecipe.m
//  Mystic
//
//  Created by travis weerts on 8/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionRecipe.h"
#import "MysticController.h"
#import "MysticProject.h"
#import "UserPotion.h"
#import "UIImageView+WebCache.h"

@implementation PackPotionOptionRecipe

@synthesize project=_project;

+ (PackPotionOptionRecipe *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionRecipe *option = (PackPotionOptionRecipe *)[super optionWithName:name info:info];
    option.project = [MysticProject project:info];
    if(name) option.project.name = name;
    return option;
}

+ (PackPotionOptionRecipe *) create;
{
    return [PackPotionOptionRecipe create:[UserPotion potion].uniqueTag];
}
+ (PackPotionOptionRecipe *) create:(NSString *)name;
{
    PackPotionOptionRecipe *recipe = (PackPotionOptionRecipe *)[PackPotionOptionRecipe optionWithName:name info:[UserPotion userInfo]];
    
    return recipe;
}

- (void) dealloc;
{
    [_project release];
    [super dealloc];
}
- (BOOL) shouldRegisterForChanges; { return NO; }
- (void) cancelEffect:(EffectControl *)control;
{
    control.selected = NO;
    self.cancelsEffect = YES;
    [control didTouchUpInside:control];
    self.cancelsEffect = NO;
    
}
- (BOOL) showLabel; { return NO; }
- (void) share:(MysticBlockObjBOOL)finished;
{
    [self.project share:finished];
}


- (BOOL) hasAdjustableSettings;
{
    return self.recipeType == MysticRecipesTypeSaved;
}
- (NSString *) thumbURLString;
{
    return self.project.thumbnailURL;
}
- (NSString *) previewURLString;
{
    return self.project.previewURL;
}
- (NSString *) imageURLString;
{
    return self.project.sourceImageURL;
}
-(NSString *) controlImageNamePath;
{
    return self.project.thumbnailFilePath;
}
- (void) setProject:(MysticProject *)value;
{
    [_project release], _project=nil;
    _project = [value retain];
    _project.useCurrentSourceImage = YES;
    _project.isRecipe = YES;
}
//- (void) updateControl:(EffectControl *)control selected:(BOOL)makeSelected;
//{
//    if(makeSelected)
//    {
//        control.selectedOverlayView.transform = CGAffineTransformTranslate(control.selectedOverlayView.transform, 0, -6);
//        control.settingsButton.transform = CGAffineTransformTranslate(control.settingsButton.transform, 0, 6);
//        control.cancelButton.transform = CGAffineTransformTranslate(control.cancelButton.transform, 0, 6);
//
//    }
//    else
//    {
//        control.selectedOverlayView.transform = CGAffineTransformIdentity;
//        control.settingsButton.transform = CGAffineTransformIdentity;
//        control.cancelButton.transform = CGAffineTransformIdentity;
//    }
//    control.selectedOverlayView.contentMode = UIViewContentModeCenter;
//    control.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self updateLabel:control.titleLabel control:control selected:makeSelected];
//}


- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    

    control.imageView.alpha = isSelected ? kMYSTICControlSelectedImageViewAlphaLayer : 1;

    control.backgroundView.backgroundColor = [control.backgroundView.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];
    control.backgroundColor = [control.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];

    
    if(!isSelected)
    {
        [self controlBecameInactive:control];
    }
    else
    {
        [self controlBecameActive:control];
    }
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    [super prepareControlForReuse:control];
    control.selectedOverlayView = nil;
    control.imageView = nil;
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


- (BOOL) isRenderableOption; { return NO; }
- (id) setUserChoice;
{
    return self;
    
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

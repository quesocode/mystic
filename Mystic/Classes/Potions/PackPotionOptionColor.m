//
//  PackPotionOptionColor.m
//  Mystic
//
//  Created by travis weerts on 1/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionColor.h"
#import "UIColor+Mystic.h"
#import "MysticColor.h"
#import "EffectControl.h"
#import "UserPotion.h"
#import "MysticScrollView.h"

@implementation PackPotionOptionColor

@synthesize color=_color, colorType, optionType, objectType, isPicker;

+ (PackPotionOptionColor *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionColor *option = (PackPotionOptionColor *)[super optionWithName:name info:info];
    option.color = [info objectForKey:@"color"] ? [UIColor string:[info objectForKey:@"color"]] : nil;
    return option;
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.selectedSize = (CGSize){30,30};
        self.unselectedSize = (CGSize){22,22};
        self.borderWidth = 5;
    }
    return self;
}
- (BOOL) shouldRegisterForChanges; { return NO; }
- (MysticObjectType) accessorySetting;
{
    switch (self.setting) {
        case MysticSettingColorAndIntensity: return MysticSettingColorAdjust;
        default: break;
    }
    return MysticSettingColorAdjustAll;
}
- (BOOL) isActive;
{
    if(!self.targetOption) return [super isActive];
    PackPotionOption *opt = self.targetOption;
    BOOL active = NO;
    if(self.targetOption)
    {
        switch (self.optionType) {
            case MysticOptionColorTypeBackground:
                return [opt.backgroundColor isEqualToColor:self.color];
            case MysticOptionColorTypeForeground:
                return [opt.foregroundColor isEqualToColor:self.color];
            default: break;
        }
    }
    return NO;
}
- (BOOL) showLabel; { return NO; }
- (BOOL) hasAdjustableSettings; { return NO; }
- (BOOL) isRenderableOption; { return NO; }

- (BOOL) hasInput; { return NO; }

- (BOOL) usesAccessory; { return YES; }



- (UIColor *) color;
{
    if(_color) return _color;
    _color = [[MysticColor colorWithType:self.colorType] retain];
    return _color;
}

- (BOOL) cancelsEffect;
{
    return self.colorType == MysticColorTypeAuto;
}

- (BOOL) userChoiceRequiresImageReload;
{
    if(self.targetOption)
    {
        switch (self.targetOption.type) {
            case MysticObjectTypeFont:
            case MysticObjectTypeShape: return NO;
            default: break;
        }
    }
    return [super userChoiceRequiresImageReload];
}
- (id) setUserChoice;
{
    PackPotionOption *currentTarget = self.targetOption ? self.targetOption : [UserPotion optionForType:self.objectType];
    MysticColorType currentTargetColorType = [currentTarget colorType:self.optionType];
    if((self.cancelsEffect && currentTargetColorType != MysticColorTypeAuto) || (!self.cancelsEffect && currentTargetColorType == MysticColorTypeAuto)) self.userChoiceRequiresImageReload = YES;
    else self.userChoiceRequiresImageReload = NO;
    [currentTarget applyAdjustmentsFrom:self setting:self.setting];
    return self;
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.alpha = 1.0f;
//    control.imageView.image = nil;
//    control.imageView.highlightedImage = nil;
//    control.imageView.highlighted = NO;
//    control.imageView.alpha = 1;
}


- (void) enableControl:(EffectControl *)control;
{
    control.alpha = control.isEnabled ? 1.0f : 0.5f;
}

- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    UIColor *newColor = [self.color displayColor];
    UIColor *newBgColor = isSelected ? [UIColor colorWithType:MysticColorTypeClear] : newColor;
    UIColor *newBorderColor = !isSelected ? [UIColor colorWithType:MysticColorTypeClear] : newColor;
    control.backgroundView.backgroundColor = newBgColor;
    CGRect bvf = control.backgroundView.frame;
    CGFloat bvh = MIN(self.selectedSize.height, control.frame.size.height-2);
    bvh = isSelected ? bvh : self.unselectedSize.height;
    CGPoint c = control.backgroundView.center;
    control.backgroundView.layer.borderWidth = self.borderWidth;
    control.backgroundView.layer.borderColor = newBorderColor.CGColor;
    if(bvf.size.height != bvh)
    {
        bvf.size.width = bvh;
        bvf.size.height = bvh;
        control.backgroundView.frame = bvf;
        control.backgroundView.center = c;
        control.backgroundView.layer.cornerRadius = bvf.size.width/2;
    }
    control.backgroundColor = [control.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];
    if(!isSelected) [self controlBecameInactive:control];
    else [self controlBecameActive:control];
    [control setSuperSelected:isSelected];
    
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
//
//    control.imageView.layer.borderWidth = MYSTIC_UI_CONTROL_SELECTED_BORDER;
//    control.imageView.layer.borderColor = [UIColor clearColor].CGColor;
//    if(!self.cancelsEffect) control.backgroundView.backgroundColor = [self.color displayColor];
//
    [self updateLabel:nil control:control selected:control.selected];

}
- (void) cancelEffect:(EffectControl *)control;
{
    [self controlTouched:control];
}




- (void) controlBecameActive:(EffectControl *)control;
{
    if(!(control.selected && [(MysticScrollView *)control.superview showsControlAccessory])) return;
    [self showControlToggler:control];
}

- (void) controlBecameInactive:(EffectControl *)control;
{
    UIView *toggler = (UIView *)control.accessoryView;
    if(toggler && [(MysticScrollView *)control.superview showsControlAccessory])
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
        
        CGFloat b = MYSTIC_UI_CONTROL_SUBBTN_SIZE;
        CGSize subBtnSize = CGSizeMake(24, 11);
        
        MysticButton *settingsBtn = [MysticButton button:nil action:^(id sender) {
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
}

@end

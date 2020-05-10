//
//  PackPotionOptionLayer.m
//  Mystic
//
//  Created by Me on 11/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionLayer.h"
#import "EffectControl.h"

@implementation PackPotionOptionLayer

@synthesize view=_view;

- (void) dealloc;
{
    [_view release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.showControlEffectToggler = NO;
        self.showControlEffectSettings = YES;
        self.levelRules = self.levelRules |MysticLayerLevelRuleAlwaysHighestBelowTop;
    }
    return self;
}
- (BOOL) hasImage; { return YES; }
- (BOOL) usesAccessory; { return YES; }
- (BOOL) allowsMultipleSelections;
{
    return [self hasInput];
}
- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.selectedOverlayView = nil;
    control.imageView = nil;
    control.backgroundView = nil;
    [self controlBecameInactive:control];

}

- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption;
{
    [super applyAdjustmentsFrom:otherOption];
    switch (otherOption.type) {
        case MysticObjectTypeColor:
        {
            self.hasChanged = YES;
            
            PackPotionOptionColor *colorOpt = (PackPotionOptionColor *)otherOption;
            [self setColorOption:colorOpt];
            [self setColorType:colorOpt.optionType color:colorOpt.color];
            
            break;
        }
        
            
        default: break;
    }
}


- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    if(control.hasSelectedOverlayView) control.selectedOverlayView.contentMode = UIViewContentModeCenter;
    if(self.hasBeenDisplayed) control.imageView.alpha = 1;

    if(isSelected)
    {
        if(control.hasBackgroundView) control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
        if(control.hasSelectedOverlayView) control.selectedOverlayView.image = [MysticImage image:@(MysticIconTypeControlSelected) size:(CGSize){control.selectedOverlayView.frame.size.width, control.selectedOverlayView.frame.size.height+7} color:@(MysticColorTypeControlOverlaySelected)];
        if(control.hasSelectedOverlayView) control.selectedOverlayView.frame = CGRectMake(0, control.imageView.frame.origin.y-7, control.imageView.frame.size.width, control.imageView.frame.size.height + 7);
        
        if(control.hasSelectedOverlayView) control.selectedOverlayView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
        if(control.hasImageView) control.imageView.alpha = kMYSTICControlSelectedImageViewAlphaLayer;
        [self controlBecameActive:control];
    }
    else
    {
        if(control.hasSelectedOverlayView) control.selectedOverlayView.image = nil;
        if(control.hasImageView) control.imageView.alpha = 1;
        [self controlBecameInactive:control];
        
    }
    
    
    [control updateControl];

    if(control.pageControl && !control.pageControl.hidden)
    {
        CGRect newFrame = control.selectedOverlayView.frame;
        newFrame.origin.y = control.imageView.frame.origin.y - MYSTIC_UI_CONTROL_PAGE_CONTROL_CONTENT_OFFSET;
        if(control.hasSelectedOverlayView) control.selectedOverlayView.frame = newFrame;
    }
    else
    {
        if(control.hasSelectedOverlayView) control.selectedOverlayView.frame = CGRectMake(0, control.imageView.frame.origin.y-7, control.imageView.frame.size.width, control.imageView.frame.size.height + 7);

//        control.selectedOverlayView.frame = control.imageView.frame;
    }
}

- (void) controlBecameActive:(EffectControl *)control;
{
    
    __unsafe_unretained __block PackPotionOptionLayer *weakSelf = self;
    __unsafe_unretained __block EffectControl *__control = control;
    if(control.hasBackgroundView)  __control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
    if(control.hasSelectedOverlayView) __control.selectedOverlayView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
    if(control.hasImageView) __control.imageView.alpha = kMYSTICControlSelectedImageViewAlphaLayer;
    if(__control.selected) [weakSelf showControlToggler:__control];
}

- (void) controlBecameInactive:(EffectControl *)control;
{
    if(control.hasBackgroundView) control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
    if(control.hasSelectedOverlayView) control.selectedOverlayView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
    if(control.hasImageView) control.imageView.alpha = 1;

    
    MysticToggleButton *toggler = (MysticToggleButton *)control.accessoryView;

    if(toggler)
    {
        control.accessoryView=nil;
        toggler = nil;
    }
    
    
}

- (void) showControlToggler:(EffectControl *)control;
{
    
    
    
    __unsafe_unretained __block EffectControl *__control = control;
    __unsafe_unretained __block PackPotionOptionLayer *weakSelf = self;
    if([control.option usesAccessory])
    {
        UIView *customControlsView = control.accessoryView;
        
        MysticToggleButton *toggler = nil;
        MysticButton *settingsBtn = nil;
        MysticBlock controlAnimations = nil;
        MysticBlockBOOL controlAnimationsComplete = nil;
        if(!customControlsView)
        {
            if(self.showControlEffectSettings || self.showControlEffectToggler)
            {
                customControlsView = [[UIView alloc] initWithFrame:control.selectedOverlayView.frame];
                CGPoint toggleCenter = customControlsView.center;

                CGFloat b = MYSTIC_UI_CONTROL_SUBBTN_SIZE;
                CGSize subBtnSize = CGSizeMake(40, 17);
                if(self.showControlEffectSettings)
                {
                    settingsBtn = [MysticButton button:[MysticImage image:@(MysticIconTypeMiniSlider) size:subBtnSize color:@(MysticColorTypeUnknown)] action:^(id sender) {
                        [__control accessoryTouched:sender];

                    }];
                    
                    CGFloat settingsBtnY = customControlsView.bounds.size.height - subBtnSize.height - MYSTIC_UI_CONTROL_SUBBTN_OFFSETY;
                    
                    if(!self.showControlEffectToggler)
                    {
                        settingsBtnY = (customControlsView.bounds.size.height - subBtnSize.height)/2;
                    }
                    settingsBtn.hitInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                    settingsBtn.adjustsImageWhenHighlighted = YES;
                    settingsBtn.frame = CGRectMake(customControlsView.bounds.size.width/2 - subBtnSize.width/2, settingsBtnY, subBtnSize.width, subBtnSize.height);
                    settingsBtn.tag = MysticViewTypeButtonSettings;
                    settingsBtn.alpha = 0;
                    settingsBtn.transform = CGAffineTransformMakeTranslation(0, 0);
                    settingsBtn.transform = CGAffineTransformScale(settingsBtn.transform, 0.25, 1);
                    
                    [customControlsView addSubview:settingsBtn];
                    CGPoint c = settingsBtn.center;
                    c.x = toggleCenter.x;
                    settingsBtn.center = c;
                    
                    controlAnimationsComplete = ^(BOOL finished) {
                        
                        [MysticUIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
                         {
                             settingsBtn.transform = CGAffineTransformIdentity;
                             settingsBtn.alpha = 1;
                             
                         } completion:nil];
                        
                        
                    };
                }
                if(self.showControlEffectToggler)
                {
                    CGSize togglerSize = CGSizeMake(38.f, 38.f);
                    toggler = [[MysticToggleButton alloc] initWithFrame:CGRectMake(0, 0, togglerSize.width, togglerSize.height)];
                    toggler.hitInsets = UIEdgeInsetsMakeFrom(20);
                    toggler.iconStyle = MysticIconTypeImage;
                    toggler.iconColorType = MysticColorTypeUnknown;
                    toggler.minToggleState = MysticLayerEffectNone;
                    toggler.tag = MysticViewTypeToggler;
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect0) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectNone];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect1) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectInverted];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect2) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectDesaturate];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect3) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectOne];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect4) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectTwo];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect5) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectThree];
                    [toggler setImage:[MysticImage image:@(MysticIconTypeEffect6) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectFour];
                    toggler.maxToggleState = MysticLayerEffectFour;

                    
                    toggler.onToggle = ^(MysticToggleButton *toggleSender)
                    {
                        int ts = MIN(toggleSender.toggleState, toggleSender.maxToggleState - 2);
                        CGFloat d = (float)((float)ts/(float)toggleSender.maxToggleState);
                        CGAffineTransform t = CGAffineTransformRotate(toggleSender.transform, ((M_PI / 2.0)*-1)*(1+d));
                        t = CGAffineTransformScale(t, .6, .6);

                        CGAffineTransform t2 = CGAffineTransformIdentity;
                        toggleSender.transform = t;
                        CGFloat p = (float)((float)toggleSender.toggleState/(float)toggleSender.maxToggleState);
                        NSTimeInterval dur = 0.2;
                        
                        [MysticUIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            toggleSender.transform = t2;
                        } completion:^(BOOL finished) {
                            
                            __control.option.activeOption.layerEffect = toggleSender.toggleState;
                            [__control accessoryTouched:toggleSender];
                        }];
                        
                    };
                    toggler.alpha = 0.0;
                    toggleCenter.y -= MYSTIC_UI_CONTROL_TOGGLER_OFFSETY;
                    toggler.center = toggleCenter;
                    [customControlsView addSubview:toggler];
                    
                    CGFloat d = 0;
                    CGAffineTransform t = CGAffineTransformRotate(toggler.transform, ((M_PI / 2.0)*-1)*(1+d));
                    t = CGAffineTransformScale(t, .65, .65);
                    
                    toggler.transform = t;
                    CGFloat p = (float)((float)toggler.toggleState/(float)toggler.maxToggleState);
                    NSTimeInterval dur = 0.2 + (0.15 * p);
                    
                    controlAnimations  = ^{
                        toggler.transform = CGAffineTransformIdentity;
                        toggler.alpha = 1;
                    };
                }
                
   
                
                
                
                
                
                
                
                control.accessoryView = customControlsView;
                [customControlsView release];
                
                
                [MysticUIView animateWithDuration:0.17 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:controlAnimations completion:controlAnimationsComplete];
            }
        }
        
        
        
        
        if(toggler)
        {
            MysticLayerEffect toggleState = control.option.activeOption ? control.option.activeOption.layerEffect : control.option.layerEffect;
            toggler.toggleState = (NSInteger)toggleState != NSNotFound ? toggleState : toggler.minToggleState;
        }
        [toggler autorelease];
    }
}


@end

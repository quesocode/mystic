//
//  PackPotionOptionMulti.m
//  Mystic
//
//  Created by Travis A. Weerts on 2/13/17.
//  Copyright © 2017 Blackpulp. All rights reserved.
//

#import "PackPotionOptionMulti.h"
#import "MysticConfigManager.h"
#import "MysticUser.h"
#import "EffectControl.h"
#import "NSDictionary+Merge.h"

@implementation PackPotionOptionMulti

+ (NSArray *) potions;
{
    NSMutableArray *potions = [NSMutableArray array];
    if([[NSFileManager defaultManager] fileExistsAtPath:[[MysticConfigManager configDirPath] stringByAppendingPathComponent:@"potions.plist"]])
    {
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[[MysticConfigManager configDirPath] stringByAppendingPathComponent:@"potions.plist"]];
        NSDictionary *pots = data[@"potions"];
        NSArray *order = data[@"order"];
        for (NSString *potionKey in order) {
            NSDictionary *pot = [pots objectForKey:potionKey];
            PackPotionOptionMulti *obj = [PackPotionOptionMulti optionWithName:potionKey info:pot];
            if(obj) [potions addObject:obj];
        }
    }
    return potions;
}
- (void) confirmCancel;
{
    [super confirmCancel];
    [self removeOption];
}
- (void) removeOption;
{
    [super removeOption];
    for (PackPotionOption *option in [MysticOptions current]) {
        if(option.multiOption && [option.multiOption isEqual:self] && [option.multiOption.optionSlotKey isEqualToString:self.optionSlotKey])
        {
            [[MysticOptions current] removeOption:option];
        }
    }
}
- (BOOL) hasMapImage; { return NO; }
- (BOOL) hasMaskImage; { return NO; }
- (BOOL) hasInput; { return NO; }
- (BOOL) hasImage; { return NO; }
- (BOOL) ignoreActualRender; { return YES; }
- (BOOL) isRenderableOption; { return YES; }
- (BOOL) allowsMultipleSelections; { return NO; }
- (BOOL) hasAdjustableSettings; { return NO; }
- (BOOL) resizeLayerImage; { return NO; }
- (BOOL) showLabel { return YES; }
- (BOOL) usesAccessory; { return YES; }
- (BOOL) requiresFrameRefresh; { return NO; }

- (MysticObjectType) type;
{
    return MysticObjectTypeMulti;
}
- (MysticObjectType) groupType;
{
    return MysticObjectTypeMulti;
}
- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    if(effect.cancelsEffect) return;
    [self prepareControlForReuse:control];
    control.imageView.image = self.thumbnail;
    control.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
}
- (UIImage *) thumbnail;
{
    UIImage *thumb = [UIImage imageNamed:self.info[@"thumbnail"]];
    if(!thumb)
    {
        NSString *newThumbPath = [[MysticUser cacheDirectoryPath] stringByAppendingFormat:@"/%@", self.info[@"thumbnail"]];
        thumb = [UIImage imageWithContentsOfFile:newThumbPath];
    }
    return thumb;
}
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    label.hidden = YES;
    //    control.imageView.highlighted = isSelected;
    control.imageView.alpha = 1;
    //    [control updateControl];
    [super updateLabel:label control:control selected:isSelected];
    if(control.hasBackgroundView) control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
//    if(control.hasSelectedOverlayView) control.selectedOverlayView.backgroundColor = [MysticColor colorWithType:MysticColorTypeClear];
    if(control.hasImageView) control.imageView.alpha = isSelected ? 0 : 1;
    
    [control setCornerRadius:0];
    
    label.alpha = isSelected ? 0 : 1;
    
    CGRect nlframe = control.imageView.frame;
//    nlframe.size.height = MYSTIC_UI_CONTROL_LABEL_HEIGHT_MED;
//    nlframe.origin.y = control.frame.size.height - nlframe.size.height - 5;
//    nlframe.size.height = control.imageView.frame.size.height;
//    nlframe.origin.y = control.imageView.frame.origin.y;
    
    label.frame = CGRectIntegral(nlframe);
    label.textColor = [UIColor colorWithType:MysticColorTypeControlBorderActive];
    label.font = [MysticUI gothamBold:8];
    label.text = [label.text uppercaseString];
    label.backgroundColor = [UIColor clearColor];
    [control bringSubviewToFront:label];

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
    control.titleLabel.text = [self.name uppercaseString];
    [control updateControl];
    control.titleLabel.hidden = NO;

}
- (void) showControlToggler:(EffectControl *)control;
{
    
    return;
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    [self controlBecameInactive:control];
}



- (void) controlBecameActive:(EffectControl *)control;
{
    __unsafe_unretained __block PackPotionOptionMulti *weakSelf = self;
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
- (id) setUserChoice:(BOOL)force finished:(MysticBlock)finished;
{
    NSDictionary *info = [[NSDictionary dictionaryWithDictionary:self.info] makeKeysNumeric];

    __unsafe_unretained PackPotionOptionMulti *weakSelf = self;
    __unsafe_unretained MysticBlock _f = finished ? Block_copy(finished) : nil;
    [MysticOptions loadMultiOption:info finished:^(id obj, BOOL success) {
        
        MysticOptions *options = obj;
        
        for (PackPotionOption *option in options) option.multiOption = weakSelf;
        [[MysticOptions current] addOptions:options.options];
        if(_f)
        {
            _f();
            Block_release(_f);
        }
    }];
    id obj = [super setUserChoice:force finished:finished];

    return obj;

}
- (void) setIsConfirmed:(BOOL)isConfirmed;
{
//    DLogDebug(@"setting multi confirmed: %@  ->  %@", MBOOL(isConfirmed), self);
    [super setIsConfirmed:isConfirmed];
}
@end

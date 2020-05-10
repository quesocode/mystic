//
//  PackPotionOptionBlend.m
//  Mystic
//
//  Created by travis weerts on 9/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionBlend.h"
#import "EffectControl.h"
#import "MysticEffectsManager.h"
#import "UserPotion.h"

@implementation PackPotionOptionBlend

+ (PackPotionOptionBlend *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionBlend *option = (PackPotionOptionBlend *)[super optionWithName:name info:info];
    option.blend = [[info objectForKey:@"blend"] integerValue];
    option.type = MysticObjectTypeBlend;
    return option;
}
- (BOOL) allowsMultipleSelections; { return NO; }
- (BOOL) shouldRegisterForChanges; { return NO; }
- (BOOL) showLabel; { return YES; }
- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.selectedOverlayView = nil;
    control.imageView = nil;
//    control.imageView.image = nil;
//    control.imageView.highlightedImage = nil;
//    control.imageView.highlighted = NO;
//    control.imageView.alpha = 1;
    
}
- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
{
    
    
    MysticColorType controlColorType = MysticColorTypeBlend1 + control.position;



    
    
    UIColor *newBgColor = isSelected ? [UIColor colorWithType:MysticColorTypeClear] : [UIColor color:controlColorType];
    control.backgroundView.backgroundColor = newBgColor;
    control.backgroundColor = [control.backgroundColor colorWithAlphaComponent:isSelected ? 0 : 1];
    
    
    
    
    label.backgroundColor = [UIColor clearColor];

    CGRect nlframe = label.frame;
    nlframe.size.height = MYSTIC_UI_CONTROL_LABEL_HEIGHT_MED;
    nlframe.origin.y = control.frame.size.height - nlframe.size.height - 5;
    label.frame = CGRectIntegral(nlframe);
    label.textColor = [UIColor colorWithType:MysticColorTypeControlBorderActive];
    label.font = [MysticUI gothamMedium:7];
    label.text = [label.text uppercaseString];
    [control bringSubviewToFront:label];
 
    
    CGRect sFrame = control.selectedOverlayView.frame;
    sFrame.size.height = control.frame.size.height - label.frame.size.height*0.7;
    control.selectedOverlayView.frame = sFrame;
    control.selectedOverlayView.transform = CGAffineTransformMakeTranslation(0, -4);

    
    control.selectedOverlayView.contentMode = UIViewContentModeCenter;
    [control setSuperSelected:isSelected];
}

- (void) thumbnail:(EffectControl *)control effect:(PackPotionOption *)effect;
{
    [self prepareControlForReuse:control];
}

- (id) setUserChoice;
{
    if(!self.targetOption) return self;
    if(self.isDefaultChoice)
    {
        [self.targetOption resetBlending];
    }
    else
    {
        [self.targetOption setBlendingType:MysticFilterTypeFromString(self.blendingMode)];
    }
    self.targetOption.hasChanged = YES;
    return self;
}

- (BOOL) isActive;
{
    BOOL value = NO;
    BOOL wasAdjusted = NO;
    BOOL equalValue = self.targetOption && self.targetOption.blendingType == self.blend;
    if(equalValue)
    {
        
        wasAdjusted = [self.targetOption hasAdjusted:MysticSettingBlending];
        
        
        if(self.isDefaultChoice)
        {
            value = wasAdjusted ? value : YES;
        }
        else
        {
            value = wasAdjusted;
        }
        
    }
    
    return value;
}
- (MysticFilterType) newBlendingType;
{
    return self.blend;
}
- (UIImage *) layerThumbImage;
{
    return self.targetOption ? self.targetOption.layerThumbImage : nil;
    
}

- (NSString *) blendingMode;
{
    if(self.blend == MysticFilterTypeBlendAuto) return nil;
    return MysticFilterTypeToString(self.blend);
}

- (MysticFilterType) blendingType;
{
    switch (self.blend) {
        case MysticFilterTypeBlendAuto:
            return self.targetOption.blendingType;
            
        default:
            
            break;
    }
    return self.blend;
}

- (NSString *) thumbURLString;
{
    return nil;
}
//- (void) updateLabel:(UILabel *)label control:(EffectControl *)control selected:(BOOL)isSelected;
//{
//    
//}

- (BOOL) isRenderableOption; { return NO; }

@end

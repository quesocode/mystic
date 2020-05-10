//
//  PackPotionOptionFontStyle.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionFontStyle.h"
#import "MysticFontStyleView.h"
#import "MysticOverlaysView.h"

@implementation PackPotionOptionFontStyle

@dynamic view;

+ (id) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOptionFontStyle *option = [super optionWithName:name info:info];
    option.fontFamily = option.fonts.count ? [option.fonts objectAtIndex:0] : option.fontFamily;
    return option;
}



- (void) commonInit;
{
    self.text = MYSTIC_DEFAULT_FONTSTYLE_TEXT;
}

- (NSArray *) fonts;
{
    NSArray *fonts = self.fontStyleOption ? self.fontStyleOption.fonts : [self.info objectForKey:@"fonts"];
    return fonts ? fonts : @[];
}


- (BOOL) isActive;
{
    if(self.isActiveAction)
    {
        return self.isActiveAction(self);
    }
    MysticFontStyleView *label = [self.overlaysView selectedLayer];
    if(label)
    {
        return [self isSame:label.option];
        
    }
    return NO;
}
- (BOOL) requiresFrameRefresh; { return NO; }
- (void) setColorOption:(PackPotionOptionColor *)colorOption;
{
    [super setColorOption:colorOption];
    MysticFontStyleView *label = [self.overlaysView selectedLayer];
    if(label)
    {
        label.color = [colorOption color];
    }
}

- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption;
{
    [super applyAdjustmentsFrom:otherOption];
    switch (otherOption.type) {
        case MysticObjectTypeFontStyle:
        {
            self.fontStyleOption = (PackPotionOptionFontStyle *)otherOption;
            self.fontFamily = [(PackPotionOptionFont *)otherOption fontFamily];
            self.fontName = [(PackPotionOptionFont *)otherOption fontName];

            break;
        }
        case MysticObjectTypeFont:
        {
            self.fontFamily = [(PackPotionOptionFont *)otherOption fontFamily];
            self.fontName = [(PackPotionOptionFont *)otherOption fontName];

            break;
        }
            
        default: break;
    }
}


- (id) setupWithOption:(PackPotionOption *)option makeLayer:(BOOL)createNewObject;
{
    [self applyAdjustmentsFrom:option];
    return [super setupWithOption:self makeLayer:createNewObject];
}

#pragma mark - PackPotionOptionFont methods
- (BOOL) hasValues; { return YES; }
- (UILabel *) viewLabel; { return nil; }


#pragma mark - Inherited

- (NSString *) name;
{
    if(self.isManager && self.fontStyleOption)
    {
        return [NSString stringWithFormat:@"Manager: %@", self.fontStyleOption.name];
    }
    return super.name;
}



@end

//
//  PackPotion.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "PackPotion.h"
#import "UserPotion.h"

@interface PackPotion ()
{
    
}
@end

@implementation PackPotion

@synthesize pack=_pack,
            textOptions=_textOptions,
            frameOptions=_frameOptions,
            textureOptions=_textureOptions,
            filterOptions=_filterOptions,
            lightOptions=_lightOptions,
            maskOptions=_maskOptions,
            badgeOptions=_badgeOptions,
            textColorOptions=_textColorOptions,
            badgeColorOptions=_badgeColorOptions,
            frameBackgroundColorOptions=_frameBackgroundColorOptions,
            defaultFilterOption=_defaultFilterOption,
            defaultFrameOption=_defaultFrameOption,
            defaultLightOption=_defaultLightOption,
            defaultTextOption=_defaultTextOption,
            defaultTextureOption=_defaultTextureOption,
            defaultMaskOption=_defaultMaskOption,
            info=_info,
            defaultBrightness=_defaultBrightness,
            defaultColorAlpha=_defaultColorAlpha,
            defaultExposure=_defaultExposure,
            defaultGamma=_defaultGamma,
            defaultBadgeColorOption=_defaultBadgeColorOption,
            defaultTextColorOption=_defaultTextColorOption,
            defaultFrameBackgroundColorOption=_defaultFrameBackgroundColorOption;

+ (PackPotion *) potionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotion *pack = (PackPotion *)[super optionWithName:name info:info];
    pack.info = info;
    pack.name = name;
    pack.tag = name;
    pack.cancelsEffect = [[info objectForKey:@"cancel"] boolValue];
    return pack;
}

- (void) dealloc
{
    if(self.coreData) self.coreData=nil;
    if(self.info) self.info=nil;
    [super dealloc];
}

- (NSArray *) optionsForType:(MysticObjectType)optionType
{
    if(!self.coreData) self.coreData = [Mystic core].data;
    NSArray *options =[NSArray array];
    Class optionClass = [PackPotionOption class];
    NSDictionary *optionsDict = nil;
    NSMutableArray *newOptions = [NSMutableArray array];
    switch (optionType) {
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            optionsDict = [self.coreData objectForKey:@"lights"];
            options = [self.info objectForKey:@"light"];
            break;
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            optionsDict = [self.coreData objectForKey:@"text"];
            options = [self.info objectForKey:@"text"];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            optionsDict = [self.coreData objectForKey:@"textures"];
            options = [self.info objectForKey:@"texture"];
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            optionsDict = [self.coreData objectForKey:@"frames"];
            options = [self.info objectForKey:@"frame"];
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            optionsDict = [self.coreData objectForKey:@"masks"];
            options = [self.info objectForKey:@"mask"];
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            optionsDict = [self.coreData objectForKey:@"badges"];
            options = [self.info objectForKey:@"badge"];
            break;
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            optionsDict = [self.coreData objectForKey:@"filters"];
            options = [self.info objectForKey:@"filter"];
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            options = [self.info objectForKey:@"textColor"];
            DLog(@"optionsDict: %@", optionsDict);
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            options = [self.info objectForKey:@"badgeColor"];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            options = [self.info objectForKey:@"frameBackgroundColor"];
            break;
            
        default: break;
    }
    
    for (NSString *optionKey in options) {
        if(![optionsDict objectForKey:optionKey]) continue;
        [newOptions addObject:[optionClass optionWithName:optionKey info:[optionsDict objectForKey:optionKey]]];
    }
    self.coreData = nil;
    return newOptions;
}

- (PackPotionOption *) optionForType:(MysticObjectType)optionType tag:(NSString *)withTag;
{
    if(!self.coreData) self.coreData = [Mystic core].data;
    Class optionClass = [PackPotionOption class];
    NSDictionary *optionsDict = nil;
    switch (optionType) {
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            optionsDict = [self.coreData objectForKey:@"lights"];
            break;
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            optionsDict = [self.coreData objectForKey:@"text"];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            optionsDict = [self.coreData objectForKey:@"textures"];
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            optionsDict = [self.coreData objectForKey:@"frames"];
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            optionsDict = [self.coreData objectForKey:@"masks"];
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            optionsDict = [self.coreData objectForKey:@"badges"];
            break;
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            optionsDict = [self.coreData objectForKey:@"filters"];
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            optionsDict = [self.coreData objectForKey:@"colors"];
            break;
            
        default: break;
    }
    self.coreData = nil;
    return [optionsDict objectForKey:withTag] ? (PackPotionOption *)[optionClass optionWithName:withTag info:[optionsDict objectForKey:withTag]] : nil;
}

- (NSArray *) textOptions
{
    return [self optionsForType:MysticObjectTypeText];
}
- (NSArray *) filterOptions
{
    return [self optionsForType:MysticObjectTypeFilter];
}
- (NSArray *) frameOptions
{
    return [self optionsForType:MysticObjectTypeFrame];
}
- (NSArray *) textureOptions
{
    return [self optionsForType:MysticObjectTypeTexture];
}
- (NSArray *) lightOptions
{
    return [self optionsForType:MysticObjectTypeLight];
}
- (NSArray *) maskOptions
{
    return [self optionsForType:MysticObjectTypeMask];
}
- (NSArray *) badgeOptions
{
    return [self optionsForType:MysticObjectTypeBadge];
}
- (NSArray *) badgeColorOptions
{
    return [self optionsForType:MysticObjectTypeBadgeColor];
}
- (NSArray *) textColorOptions
{
    return [self optionsForType:MysticObjectTypeTextColor];
}
- (NSArray *) frameBackgroundOptions
{
    return [self optionsForType:MysticObjectTypeFrameBackgroundColor];
}

- (MysticControlObject *) parentControl
{
    return self.pack;
}
- (float) defaultColorAlpha
{
    return [self.info objectForKey:@"defaults"] ? [[[self.info objectForKey:@"defaults"] objectForKey:@"colorAlpha"] floatValue] : 1.0;
}
- (float) defaultBrightness
{
    return [self.info objectForKey:@"defaults"] ? [[[self.info objectForKey:@"defaults"] objectForKey:@"brightness"] floatValue] : 0;
}
- (float) defaultExposure
{
    return [self.info objectForKey:@"defaults"] ? [[[self.info objectForKey:@"defaults"] objectForKey:@"exposure"] floatValue] : 0;
}
- (float) defaultGamma
{
    return [self.info objectForKey:@"defaults"] ? [[[self.info objectForKey:@"defaults"] objectForKey:@"gamma"] floatValue] : 0;
}
- (PackPotionOptionColor *) defaultTextColorOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"textColor"] : nil;
    if(defaultTag)
    {
        PackPotionOptionColor *option = (PackPotionOptionColor *)[self optionForType:MysticObjectTypeTextColor tag:defaultTag];
        if(option) return option;
    }
    NSArray *textOptions = self.textColorOptions;
    return (textOptions && [textOptions count]) ? [textOptions objectAtIndex:0] : nil;
}
- (PackPotionOptionColor *) defaultBadgeColorOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"badgeColor"] : nil;
    if(defaultTag)
    {
        PackPotionOptionColor *option = (PackPotionOptionColor *)[self optionForType:MysticObjectTypeBadgeColor tag:defaultTag];
        if(option) return option;
    }
    NSArray *textOptions = self.badgeColorOptions;
    return (textOptions && [textOptions count]) ? [textOptions objectAtIndex:0] : nil;
}
- (PackPotionOptionColor *) defaultFrameBackgroundColorOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"frameBackgroundColor"] : nil;
    if(defaultTag)
    {
        PackPotionOptionColor *option = (PackPotionOptionColor *)[self optionForType:MysticObjectTypeFrameBackgroundColor tag:defaultTag];
        if(option) return option;
    }
    NSArray *textOptions = self.frameBackgroundColorOptions;
    return (textOptions && [textOptions count]) ? [textOptions objectAtIndex:0] : nil;
}
- (PackPotionOptionText *) defaultTextOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"text"] : nil;
    if(defaultTag)
    {
        PackPotionOptionText *option = (PackPotionOptionText *)[self optionForType:MysticObjectTypeText tag:defaultTag];
        if(option) return option;
    }
    NSArray *textOptions = self.textOptions;
    return (textOptions && [textOptions count]) ? [textOptions objectAtIndex:0] : nil;
}

- (PackPotionOptionTexture *) defaultTextureOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"texture"] : nil;
    if(defaultTag)
    {
        PackPotionOptionTexture *option = (PackPotionOptionTexture *)[self optionForType:MysticObjectTypeTexture tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.textureOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (PackPotionOptionBadge *) defaultBadgeOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"badge"] : nil;
    if(defaultTag)
    {
        PackPotionOptionBadge *option = (PackPotionOptionBadge *)[self optionForType:MysticObjectTypeBadge tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.badgeOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (PackPotionOptionFilter *) defaultFilterOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"filter"] : nil;
    if(defaultTag)
    {
        PackPotionOptionFilter *option = (PackPotionOptionFilter *)[self optionForType:MysticObjectTypeFilter tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.filterOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (PackPotionOptionFrame *) defaultFrameOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"frame"] : nil;
    if(defaultTag)
    {
        PackPotionOptionFrame *option = (PackPotionOptionFrame *)[self optionForType:MysticObjectTypeFrame tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.frameOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (PackPotionOptionMask *) defaultMaskOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"mask"] : nil;
    if(defaultTag)
    {
        PackPotionOptionMask *option = (PackPotionOptionMask *)[self optionForType:MysticObjectTypeMask tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.maskOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (PackPotionOptionLight *) defaultLightOption
{
    NSString *defaultTag = [self.info objectForKey:@"defaults"] ? [[self.info objectForKey:@"defaults"] objectForKey:@"light"] : nil;
    if(defaultTag)
    {
        PackPotionOptionLight *option = (PackPotionOptionLight *)[self optionForType:MysticObjectTypeLight tag:defaultTag];
        if(option) return option;
    }
    NSArray *options = self.lightOptions;
    return (options && [options count]) ? [options objectAtIndex:0] : nil;
}

- (id) setUserChoice;
{
    [super setUserChoice];
    //if(!self.coreData) self.coreData = [Mystic core].data;
    if(self.cancelsEffect)
    {
        [UserPotion resetPotion];
    }
//    else
//    {
//        [self.defaultTextOption setUserChoice];
//        [self.defaultFrameOption setUserChoice];
//        [self.defaultMaskOption setUserChoice];
//        [self.defaultTextureOption setUserChoice];
//        [self.defaultFilterOption setUserChoice];
//        [self.defaultLightOption setUserChoice];
//        [self.defaultBadgeOption setUserChoice];
//        [UserPotion potion].colorAlpha = self.defaultColorAlpha;
//        [UserPotion potion].brightness = self.defaultBrightness;
//        [UserPotion potion].gamma = self.defaultGamma;
//        [UserPotion potion].exposure = self.defaultExposure;
//        [UserPotion potion].transformTextRect = CGRectZero;
//        [UserPotion potion].transformRect = CGRectZero;
//        [UserPotion potion].transformBadgeRect = CGRectZero;
//    }
    //self.coreData = nil;
    return self;
}

@end

//
//  MysticShaderData.m
//  Mystic
//
//  Created by Me on 10/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticShaderData.h"
#import "MysticDictionary.h"
#import "MysticShaderConstants.h"
#import "PackPotionOption.h"
#import "MysticTypedefs.h"


@implementation MysticShaderData

+ (NSString *) blendKey:(id)aKey;
{
    if([aKey isKindOfClass:[NSString class]]) return aKey;
    if([aKey respondsToSelector:@selector(integerValue)])
    {
        MysticFilterType switchToType = MysticFilterTypeUnknown;
        switch ([aKey integerValue]) {
            case MysticFilterTypeBlendMaskScreenNoFill: switchToType = MysticFilterTypeBlendMaskScreen; break;
            case MysticFilterTypeBlendMaskMultiplyNoFill: switchToType = MysticFilterTypeBlendMaskMultiply; break;
            case MysticFilterTypeBlendLuminosity: return @"luminosity";
        }
        if(switchToType != MysticFilterTypeUnknown) return MysticFilterTypeToString(switchToType);
    }
    return MysticFilterTypeToString([aKey integerValue]);
}
+ (NSString *) settingToKey:(id)aKey;
{
    if([aKey isKindOfClass:[NSString class]]) return aKey;
    if([aKey respondsToSelector:@selector(integerValue)])
    {
        switch ([aKey integerValue]) {
            case MysticSettingAdjustColor: return @"adjustcolor";

            case MysticSettingHighlightTint: return @"highlightstint";
            case MysticSettingShadowTint: return @"shadowstint";
            case MysticSettingShadowsHighlights:
            case MysticSettingShadows:
            case MysticSettingHighlights: return @"shadowshighlights";
            case MysticSettingHighlightIntensity:
            case MysticSettingHighlightTintColor:
            case MysticSettingShadowIntensity:
            case MysticSettingShadowTintColor: return @"shadowshighlightstint";
            case MysticSettingSaturation: return @"saturation";
            case MysticSettingBrightness: return @"brightness";
            case MysticSettingVibrance: return @"vibrance";
            
            case MysticSettingHSB:
            case MysticSettingHSBHue: return @"hsb";
            case MysticSettingColorBalance:
            case MysticSettingColorBalanceRed:
            case MysticSettingColorBalanceBlue:
            case MysticSettingColorBalanceGreen: return @"colorbalance";
            default: return [[MysticObjectTypeTitleParent([aKey integerValue], nil) stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        }
    }
    return aKey;
}
+ (MysticDictionary *) data;
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"plist"];
    return [(id)[[MysticDictionary alloc] initWithContentsOfFile:filePath] autorelease];
    
}

+ (NSString *)constant:(id)key;
{
    return [self objectAtKeyPath:[@"constants." stringByAppendingString:key]];
}
+ (NSString *)uniform:(id)key;
{
    return [self objectAtKeyPath:[@"uniforms." stringByAppendingString:key]];
}
+ (NSString *)function:(id)key;
{
    id v = [self objectAtKeyPath:[@"functions." stringByAppendingString:key]];
    if([v isKindOfClass:[NSDictionary class]])
    {
        v = [(NSDictionary *)v objectForKey:@"function"];
    }
    else if(!v && [(NSString *)key hasPrefix:@"blend"])
    {
        v = [self blend:[[key stringByReplacingOccurrencesOfString:@"blend" withString:@""] lowercaseString]];
    }
    if([v isKindOfClass:[NSString class]] && [v hasPrefix:@"var:"])
    {
        if ([v isEqualToString:@"var:control"]) {
            v = MysticShaderControlOutput;
        }
        else if ([v isEqualToString:@"var:levels"]) {
            v = MysticShaderLevels;
        }
    }
    return [v isKindOfClass:[NSString class]] ? v : nil;
    
}
+ (NSString *)blend:(id)key;
{
    id v = [self objectAtKeyPath:[@"blends." stringByAppendingString:key]];
    if([v isKindOfClass:[NSDictionary class]])
    {
        v = [(NSDictionary *)v objectForKey:@"blend"];
    }
    return [v isKindOfClass:[NSString class]] ? v : nil;
}
+ (MysticObjectType) itemsType;
{
    return MysticObjectTypeSpecial;
}

+ (id) lookupUniform:(id)keyPath;
{
    return [self lookupShaderString:[NSString stringWithFormat:@"uniforms.%@", keyPath]];
}
+ (id) lookupFunction:(id)keyPath;
{
    return [self lookupShaderString:[NSString stringWithFormat:@"functions.%@", keyPath]];
}
+ (id) lookupBlend:(id)keyPath;
{
    return [self lookupShaderString:[NSString stringWithFormat:@"blends.%@", keyPath]];
}
+ (id) lookupConstant:(id)keyPath;
{
    return [self lookupShaderString:[NSString stringWithFormat:@"constants.%@", keyPath]];
}
+ (id) lookupShaderString:(id)keyPath;
{
    return [self objectAtKeyPath:keyPath];
}

+ (id) lookup:(id)keyPath;
{
    return [self lookup:keyPath option:nil];
}

+ (id) lookup:(id)keyPath option:(PackPotionOption *)option;
{
    id info = [self objectAtKeyPath:keyPath];
    return !info ? nil : [MysticShaderInfo info:info forKey:keyPath option:option];
}

@end


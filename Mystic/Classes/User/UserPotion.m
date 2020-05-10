//
//  UserPotion.m
//  Mystic
//
//  Created by Travis on 10/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "UserPotion.h"
#import "MysticEffectsManager.h"

@implementation UserPotion


+ (UserPotion *) potion
{
    return (UserPotion *)[super potion];
}
+(void) resetPotion;
{
    [super resetPotion];
    [[MysticOptions current] reset];
    [[MysticEffectsManager manager] setOptions:nil];
    
}
+ (void) resetSettings;
{
    if ([MysticOptions current]) {
        PackPotionOptionSetting *option = (PackPotionOptionSetting *)[[MysticOptions current] option:MysticObjectTypeSetting];
        if(option)
        {
            [option setDefaultSettings];
            [[MysticOptions current] removeOption:option];
        }
    }
    [super resetSettings];
}

+ (BOOL) hasOption:(PackPotionOption *)option;
{
    BOOL hasOption = NO;
    if ([MysticOptions current])
    {
        hasOption = [[MysticOptions current] contains:option equal:NO];
    }
    return hasOption ? YES : [super hasOption:option];
}
+ (void) removeOption:(MysticOption *)option;
{
    [[MysticOptions current] removeOption:option];
    if([[MysticOptions current] parentOptions])
    {
        [[MysticOptions current].parentOptions removeOption:option];
    }
//    [super removeOption:option];
}
+ (void) cancelOption:(MysticOption *)option;
{
//    [super cancelOption:option];
    [self removeOption:option];
    //[[MysticOptions current] removeOption:option];
}
+ (void) removeOptionForType:(MysticObjectType)type cancel:(BOOL)cancel;
{
    
    
    
    NSArray *options = [[MysticOptions current] options:@(type)];
    if(options && options.count)
    {
        [[MysticOptions current] removeOptions:options cancel:cancel];
        if([[MysticOptions current] parentOptions])
        {
            [[MysticOptions current].parentOptions removeOptions:options cancel:cancel];
        }
    }
    //    if(type != MysticObjectTypeFont)
    //    {
    [super removeOptionForType:type];
    //    }
}
+ (void) removeOptionForType:(MysticObjectType)type;
{
    [self removeOptionForType:type cancel:YES];
    
}
+ (PackPotionOption *) optionForType:(MysticObjectType)type;
{
    PackPotionOption *option = [[MysticOptions current] option:type];
    if(!option)
    {
        option = [super optionForType:type];
    }
    return option;
}
+ (PackPotionOption *) setOption:(PackPotionOption *)option type:(MysticObjectType)type;
{
    if(!option.canBeChosen) { DLog(@"option cant be chosen: %@", option); return nil; }
    PackPotionOption *newOption = [super setOption:option type:type];
    if(![[MysticOptions current] contains:option equal:option.createNewCopy])
    {
        DLog(@"UserPotion setOption addOption: %@", option);
        [[MysticOptions current] addOption:option];
    }
    return newOption;
}
+ (MysticOptions *)effects:(BOOL)enabled;
{
    if(![MysticOptions current])
    {
        return [super effects:enabled];
    }
    return [MysticOptions current];
}

+ (BOOL) confirmed;
{
    return [MysticOptions current] ? [[MysticOptions current] confirm:@(MysticObjectTypeAll)] : [super confirmed];
}

+ (PackPotionOption *) makeOption:(MysticObjectType)newType;
{
    return [[self class] makeOption:newType userInfo:nil];
}
+ (PackPotionOption *) makeOption:(MysticObjectType)newType userInfo:(NSDictionary *)info;
{
    
    
    PackPotionOption *option = nil;
    switch (newType) {
        
        case MysticObjectTypeSourceSetting:
        {
            option = (PackPotionOption *)[PackPotionOptionSourceSetting optionWithName:@"settings-source" info:nil];
            option.ignoreRender = NO;
            option.type = MysticObjectTypeSetting;
            [option setUserChoice];
            [UserPotion setOption:option type:MysticObjectTypeSetting];
            [[UserPotion potion] confirmOption:option];
            break;
        }
        default:
        {
            MysticObjectType _newType = MysticTypeForSetting(newType, nil);
            switch (_newType) {
             
                case MysticObjectTypeSetting:
                {
                    option = (PackPotionOption *)[PackPotionOptionSetting optionWithName:@"settings" info:nil];
                    option.ignoreRender = NO;
                    option.type = MysticObjectTypeSetting;
                    [option setUserChoice];
                    [UserPotion setOption:option type:MysticObjectTypeSetting];
                    [[UserPotion potion] confirmOption:option];
                    break;
                }
                
                default:
                {
                    break;
                }
            }
        
        
            break;
        }
    }
    
    return option;
}

+ (PackPotionOption *) confirmedOptionForType:(MysticObjectType)type;
{
    return [[MysticOptions current] option:type];
}

@end

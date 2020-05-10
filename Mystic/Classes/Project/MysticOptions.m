//
//  MysticOptions.m
//  Mystic
//
//  Created by travis weerts on 8/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticOptions.h"
#import "UserPotion.h"
#import "MysticPreloaderImage.h"
#import "MysticEffectsManager.h"
#import "MysticController.h"
#import "NSArray+Mystic.h"
#import <CommonCrypto/CommonDigest.h>
#import "MysticOptionsCacheManager.h"

@interface MysticOptions ()
{

}
@end
@implementation MysticOptions

+ (MysticOptions *) current;
{
    return [MysticEffectsManager currentOptions];
}
+ (MysticOptions *) currentOptions;
{
    return [MysticEffectsManager currentOptions];
}
+ (MysticOptions *) reversedOptions;
{
    MysticOptions *c = [MysticOptions current];
    c.sortOrder = MysticSortOrderReverse;
    return c;
}

- (void) dealloc;
{
    [_projectName release];
    [super dealloc];
}



#pragma mark - Image Caching

- (void) storeImage:(UIImage *)theImage pass:(MysticOptions *)thePass;
{
    
    [[MysticOptionsCacheManager sharedManager] cacheImage:theImage forOptions:thePass];

    
}


#pragma mark - Project Stuff


- (NSString *) projectName;
{
    if(!_projectName) _projectName = [UserPotion potion].uniqueTag ? [[UserPotion potion].uniqueTag retain] : [[@"proj-" stringByAppendingString:[Mystic randomHash]] retain];
    return _projectName;
}
- (void) saveProject;
{
    [[MysticUser user] saveProject:[self projectDictionary] forName:self.projectName];
}

- (void) savePotion:(NSString *)potionName;
{
    [[MysticUser user] savePotion:[self projectDictionary] projectKeyName:[self.projectName suffix:[self.tag prefix:@"-"]] projectName:potionName];
}

- (NSDictionary *) projectDictionary;
{
    NSMutableDictionary *projDict = [NSMutableDictionary dictionary];
    NSMutableArray *sortedRenderableEffects = [NSMutableArray array];
    NSMutableArray *options = [NSMutableArray array];
    [sortedRenderableEffects addObjectsFromArray:[self sortedRenderOptions]];
    for (PackPotionOption *option in sortedRenderableEffects) {
        NSMutableDictionary *oad = [NSMutableDictionary dictionary];
        [oad addEntriesFromDictionary:option.allAdjustments];
        NSString *oTag = [option.tag copy];
        NSDictionary *adjusts = oad && oad.count ? [NSDictionary dictionaryWithDictionary:oad] : nil;
  
        [options addObject:@{@(MysticProjectKeyTag): isM(oTag) ? oTag : [NSNull null],
                             @(MysticProjectKeyAdjustments): adjusts && adjusts.count ? adjusts : [NSNull null],
                             @(MysticProjectKeyLevel): option ? @(option.level) : [NSNull null],
                             @(MysticProjectKeyOptionGroup): option ? @(option.type) : [NSNull null],
                             @(MysticProjectKeyOptionLayerEffect) : @(option.layerEffect),
                             }];
        [oTag release];
    }
    
    if(options && options.count) [projDict setObject:[NSArray arrayWithArray:options] forKey:@(MysticProjectKeyOptions)];

    NSDictionary *historyItem = [UserPotion historyItemAtIndex:0];
    
    
    NSString *originPath1 = [[UserPotion potion].originalImagePath copy];
    NSString *sourceImagePath1 = [historyItem[@"source"] copy];
    NSString *sourceImageResizedPath1 = [historyItem[@"resized"] copy];
    NSString *thumbPath1 = [[UserPotion potion].thumbnailImagePath copy];

    NSString *originPath = !originPath1 ? nil : [originPath1 stringByReplacingOccurrencesOfString:[MysticCache projectCache].diskCachePath withString:@""];
    NSString *sourceImagePath = !sourceImagePath1 ? nil : [sourceImagePath1 stringByReplacingOccurrencesOfString:[MysticCache projectCache].diskCachePath withString:@""];
    NSString *sourceImageResizedPath = !sourceImageResizedPath1 ? nil : [sourceImageResizedPath1 stringByReplacingOccurrencesOfString:[MysticCache projectCache].diskCachePath withString:@""];
    NSString *thumbPath = !thumbPath1 ? nil : [thumbPath1 stringByReplacingOccurrencesOfString:[MysticCache projectCache].diskCachePath withString:@""];
    
    
    NSArray *history = (id)[[NSArray arrayWithArray:[UserPotion potion].history] copy];
    [projDict setObject:history forKey:@(MysticProjectKeyHistory)];
    [history autorelease];
    
    [projDict setObject:@([UserPotion potion].historyChangeIndex) forKey:@(MysticProjectKeyHistoryChangeIndex)];
    
    [projDict setObject:@([UserPotion potion].historyIndex) forKey:@(MysticProjectKeyHistoryIndex)];

    originPath = originPath ? originPath : (id)@"";
    sourceImagePath = sourceImagePath ? sourceImagePath : @"";
    sourceImageResizedPath = sourceImageResizedPath ? sourceImageResizedPath : @"";
    thumbPath = thumbPath ? thumbPath : @"";

    
    if(isM(originPath)) [projDict setObject:originPath forKey:@(MysticProjectKeyImageOriginalPath)];
    if(isM(sourceImagePath)) [projDict setObject:sourceImagePath forKey:@(MysticProjectKeyImageSrcPath)];
    if(isM(sourceImageResizedPath)) [projDict setObject:sourceImageResizedPath forKey:@(MysticProjectKeyImageResizedPath)];
    if(isM(thumbPath)) [projDict setObject:thumbPath forKey:@(MysticProjectKeyImageThumbPath)];
    
    [originPath1 release];
    [sourceImagePath1 release];
    [sourceImageResizedPath1 release];
    [thumbPath1 release];
    
    id sizeObj = [NSValue valueWithCGSize:self.size];
    if(sizeObj) [projDict setObject:[NSValue valueWithCGSize:self.size] forKey:@(MysticProjectKeyRenderSize)];

    return [NSDictionary dictionaryWithObjects:projDict.allValues forKeys:projDict.allKeys];
}
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict;
{
    return [[self class] optionsFromProject:projectDict finished:nil];
}
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;
{
    return [self optionsFromProject:projectDict addOptions:YES finished:finishedBlock];
}
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict addOptions:(BOOL)shouldAdd finished:(MysticBlockObjBOOL)finishedBlock;
{
    MysticOptions *theOptions = (id)[MysticOptions options];
    
    NSMutableArray *theOptionsOptions = [NSMutableArray array];
    
    
    CGSize projSize = CGSizeZero;
    [projectDict retain];
    id projSizeObj = [projectDict objectForKey:@(MysticProjectKeyRenderSize)] ? [projectDict objectForKey:@(MysticProjectKeyRenderSize)] : nil;
    
    if(![projSizeObj isKindOfClass:[NSString class]] && [projSizeObj respondsToSelector:@selector(CGSizeValue)])
       {
           projSize = [projSizeObj CGSizeValue];
       }
    else
    {
        projSize = projSizeObj ? CGSizeFromString(projSizeObj) : projSize;
    }
    
    
    if([projectDict objectForKey:@(MysticProjectKeyOptions)])
    {
        
        for (NSDictionary *optDict in [projectDict objectForKey:@(MysticProjectKeyOptions)]) {
            MysticObjectType groupType = [optDict objectForKey:@(MysticProjectKeyOptionGroup)] ? [[optDict objectForKey:@(MysticProjectKeyOptionGroup)] integerValue] : MysticObjectTypeUnknown;
            NSString *optTag = [optDict objectForKey:@(MysticProjectKeyTag)];
            NSDictionary *optAdjustments = [optDict objectForKey:@(MysticProjectKeyAdjustments)];
            MysticLayerEffect effect = [[optDict objectForKey:@(MysticProjectKeyOptionLayerEffect)] integerValue];
            

            
            MysticLayerLevel optLevel = [optDict objectForKey:@(MysticProjectKeyLevel)] ? [[optDict objectForKey:@(MysticProjectKeyLevel)] integerValue] : MysticLayerLevelAuto;
            
            PackPotionOption *option = nil;
            if(groupType == MysticObjectTypeSetting)
            {
                option = [UserPotion makeOption:MysticObjectTypeSetting];
                
            }
            else if(groupType != MysticObjectTypeUnknown)
            {
                NSString *keyPath = [NSString stringWithFormat:@"%@.%@", MysticObjectTypeKey(groupType), optTag];
                NSDictionary *optInfo = [MysticOptionsDataSource objectAtKeyPath:keyPath];
                
                if(optInfo != nil)
                {
                    
                    option = [MysticOptionsDataSource itemForType:groupType info:optInfo itemKey:optTag];
                }
                else
                {
                    
                    
                    option = [MysticOptionsDataSource itemForType:groupType info:optDict itemKey:optTag];
                }
            }
            
            
            if(option)
            {
                if(optAdjustments && optAdjustments.allKeys.count > 1)
                {

                    [option applyAdjustments:optAdjustments];
                }
                option.level = optLevel;
                option.isConfirmed = YES;
                if(effect != MysticLayerEffectNone)
                {
                    
                    option.layerEffect = effect;
                }
                [theOptionsOptions addObject:option];
            }
            
        }
    }
    if(theOptionsOptions.count)
    {
        if(shouldAdd) {
            
            for (PackPotionOption *option in theOptionsOptions) {
                if(!option.optionSlotKey) option.optionSlotKey = [[MysticOptions current] makeSlotKeyForOption:option force:YES];
            }
            
            [theOptions addOptions:theOptionsOptions];
        }
        if(finishedBlock) finishedBlock(theOptions, YES);
        
        
    }
    else
    {
        if(finishedBlock) finishedBlock(theOptions, NO);
    }
    [projectDict autorelease];
    return theOptions;
}
+ (void) loadProject:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;
{

    __unsafe_unretained __block NSDictionary *_proj = projectDict ? [projectDict retain] : nil;
    [[self class] optionsFromProject:_proj addOptions:YES finished:^(MysticOptions *theOptions, BOOL success) {
        if(theOptions && success) [MysticEffectsManager manager].options = theOptions;
        [UserPotion resetHistory:[_proj objectForKey:@(MysticProjectKeyHistory)]];
        NSNumber *projHistoryIndex = [_proj objectForKey:@(MysticProjectKeyHistoryIndex)];
        if(projHistoryIndex) [UserPotion potion].historyIndex = projHistoryIndex.integerValue;
        NSNumber *projHistoryIndexChange = [_proj objectForKey:@(MysticProjectKeyHistoryChangeIndex)];
        if(projHistoryIndexChange) [UserPotion potion].historyChangeIndex = projHistoryIndexChange.integerValue;
        finishedBlock(theOptions, success);
        [_proj autorelease];
    }];
    
    
    
    
}

+ (void) loadMultiOption:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;
{
    __unsafe_unretained __block NSDictionary *_proj = projectDict ? [projectDict retain] : nil;
    [[self class] optionsFromProject:_proj addOptions:YES finished:^(MysticOptions *theOptions, BOOL success) {
        finishedBlock(theOptions, success);
        [_proj autorelease];
    }];
    
    
    
    
}




#pragma mark - Optimize for On Screen & offscreen

- (void) optimizeForOffScreen;
{
    if(self.topLevelOptions)
    {
        return [self.topLevelOptions optimizeForOffScreen];
    }
    for (PackPotionOption *option in self.allOptions) {
        option.layer = nil;
        option.ownedLayer = nil;
    }
    [self.filters empty];
    self.imageView = nil;
}

- (void) optimizeForOnScreen;
{
    
}



#pragma mark - Filter description

- (void) passDescription;
{
    DLog(@"%@", self.passDescriptionString);
}
- (NSString *) passDescriptionString;
{

    NSMutableArray *strs = [NSMutableArray array];
    NSMutableString *str = [NSMutableString string];
    
    [strs addObject:@"sourceImage"];
    [strs addObject:[NSString stringWithFormat:@"%@ <%p>", ILogStr(self.sourceImage), self.sourceImage]];
    [strs addObject:@"-"];
    [strs addObject:@"Options Obj"];
    [strs addObject:self.description];
    [strs addObject:@"-"];

    [strs addObjectsFromArray:@[@"filters", [NSString stringWithFormat:@"FilterManager <%p>", self.filters]]];
    [strs addObjectsFromArray:@[@"last output", NSStringFromClass([self.filters.lastOutput class])]];

    [strs addObject:@"desc"]; [strs addObject:[self.filters debugDescription]];
    
    
    
    return ALLogStrf([NSString stringWithFormat:@"%@ (pass #%d) <%p>", [self isKindOfClass:[MysticOptionsManager class]] ? @"Manager" : @"Options", (int)self.passIndex,  self], strs);
    
}



@end

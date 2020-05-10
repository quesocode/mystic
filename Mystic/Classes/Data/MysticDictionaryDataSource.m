//
//  MysticDictionaryDataSource.m
//  Mystic
//
//  Created by Me on 6/10/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDictionaryDataSource.h"
#import "Mystic.h"

@implementation MysticDictionaryDataSource
static NSMutableDictionary *MysticDictionaryDataSourceCache = nil;

+ (Class) packClass;
{
    return [MysticPack class];
}
+ (Class) itemClassForType:(MysticObjectType)type;
{
    Class optionClass = [PackPotionOption class];
    
    switch (type) {
        case MysticObjectTypeSpecial:
            optionClass = [PackPotionOptionSpecial class];
            break;
        case MysticObjectTypePotion:
            optionClass = [PackPotionOptionRecipe class];
            break;
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            break;
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            break;
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeTextPack:
        case MysticObjectTypePack:
            optionClass = [[self class] packClass];
            break;
        case MysticObjectTypeColorOverlay:
            optionClass = [PackPotionOptionColorOverlay class];
            break;
        case MysticObjectTypeLayerShape:
            optionClass = [NSDictionary class];
            break;
        default: break;
    }
    return optionClass;
}

+ (MysticDictionary *) data;
{
    return [Mystic core].data;

}
+ (void) preload:(MysticOptionTypes)type;
{
    if(!MysticDictionaryDataSourceCache) MysticDictionaryDataSourceCache = [[NSMutableDictionary alloc] init];
    if(type > 0)
    {
        NSString *typeKey = [NSString stringWithFormat:@"%@", @(type)];
        if(![MysticDictionaryDataSourceCache objectForKey:typeKey])
        {
            [MysticDictionaryDataSourceCache setObject:[NSMutableDictionary dictionary] forKey:typeKey];
        }
    }

}

+ (void) unload:(MysticOptionTypes)type;
{
    [[self class] removeAllCacheObjectsForType:type];
    if(MysticDictionaryDataSourceCache && MysticDictionaryDataSourceCache.allKeys.count <= 1)
    {
        [MysticDictionaryDataSourceCache release], MysticDictionaryDataSourceCache = nil;
    }
}
+ (id) objectAtKeyPath:(NSString *)keyPath;
{
    return [[self class] objectAtKeyPath:keyPath filter:nil];
}
+ (id) objectAtKeyPath:(NSString *)keyPath filter:(MysticBlockFilteredObj)filterBlock;
{
    MysticDictionary *mainData = [[self class] data];
    id obj = [mainData valueForKeyPath:keyPath];
    BOOL stop = NO;
    if(obj && filterBlock)
    {
        return filterBlock(obj, &stop);
    }
    return obj;
}
+ (NSString *) keyPathForType:(MysticObjectType)type;
{
    if(type == MysticObjectTypeUnknown) return @"items";
    return MysticObjectTypeKey(type);
}
+ (MysticObjectType) itemsType;
{
    return MysticObjectTypeUnknown;
}
+ (void) items:(MysticBlockData)block;
{
    if(block)
    {
        NSArray *itms = [[self class] items];
        block(itms, MysticDataStateComplete|MysticDataStateNew);
    }
}
+ (NSArray *) items;
{
    MysticObjectType itemsType = [[self class] itemsType];
    return [[self class] itemsForType:itemsType];
}
+ (NSArray *) itemsForType:(MysticObjectType)optionType;
{
    return [[self class] itemsForType:optionType filter:nil];
}

+ (NSArray *) itemsForType:(MysticObjectType)optionType filter:(MysticBlockFilteredObj)filter;
{
    NSString *key = [[self class] keyPathForType:optionType];
    
    NSDictionary *data = [[self class] objectAtKeyPath:key];
    NSArray *itemsOrderedKeys = [[self class] objectAtKeyPath:[@"orders." stringByAppendingString:key]];
    itemsOrderedKeys = itemsOrderedKeys ? itemsOrderedKeys : [[self class] objectAtKeyPath:@"orders"] && [[[self class] objectAtKeyPath:@"orders"] isKindOfClass:[NSArray class]] ? [[self class] objectAtKeyPath:@"orders"] : nil;
//    DLog(@"itemsType: %@  |  key: %@  | \nsource:  %@\n\nordered: %@\n data: %@", MysticString(optionType), [[self class] keyPathForType:optionType], [[self class] data], itemsOrderedKeys, data);

    
    if(!data || !data.count) return @[];
    return [[self class] itemsForType:optionType info:data keyOrder:itemsOrderedKeys filter:filter];
    
}

+ (NSArray *) itemsForType:(MysticObjectType)optionType keyOrder:(NSArray *)keyOrder filter:(MysticBlockFilteredObj)filter;
{
    NSString *key = [[self class] keyPathForType:optionType];
    NSDictionary *data = [[self class] objectAtKeyPath:key];
    if(!data || !data.count) return @[];
    return [[self class] itemsForType:optionType info:data keyOrder:keyOrder filter:filter];

}

+ (NSArray *) itemsForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder;
{
    return [[self class] itemsForType:optionType info:itemsDict keyOrder:keyOrder filter:nil];
}


+ (NSArray *) itemsForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder  filter:(MysticBlockFilteredObj)filter;
{
    Class optionClass = [[self class] itemClassForType:optionType];
    NSMutableArray *newItems = [NSMutableArray array];
    
    
    if(filter)
    {
        BOOL stop = NO;
        NSMutableDictionary *returnItemsDict = [NSMutableDictionary dictionary];
        
        for (NSString *packKey in itemsDict.allKeys)
        {
            NSDictionary *oDict = filter([itemsDict objectForKey:packKey], &stop);
            if(oDict) [returnItemsDict setObject:oDict forKey:packKey];
            if(stop) break;
        }
        
        itemsDict = [NSDictionary dictionaryWithDictionary:returnItemsDict];
        
        NSArray *filteredKeys = itemsDict ? [itemsDict allKeys] : nil;
        if(keyOrder && filteredKeys && filteredKeys.count && keyOrder.count != filteredKeys.count)
        {
            NSMutableArray *newKeyOrder = [NSMutableArray array];
            for (NSString *optionKey in keyOrder)
            {
                if([filteredKeys containsObject:optionKey]) [newKeyOrder addObject:optionKey];
            }
            keyOrder = newKeyOrder;
        }
        else  if(!keyOrder && filteredKeys)
        {
            keyOrder = filteredKeys;
        }
        
    }
    else
    {
        keyOrder = keyOrder ? keyOrder : [itemsDict allKeys];
    }
    for (NSString *optionKey in keyOrder)
    {
        if(![itemsDict objectForKey:optionKey] || [[[itemsDict objectForKey:optionKey] objectForKey:@"cancel"] boolValue]) continue;
        
        id newItm;
        
        if(optionType == MysticObjectTypeUnknown || optionClass == [NSDictionary class])
        {
            newItm = [itemsDict objectForKey:optionKey];
        }
        else
        {
            newItm = [[self class] itemForType:optionType info:[itemsDict objectForKey:optionKey] itemKey:optionKey class:optionClass];
            if([newItm respondsToSelector:@selector(setPosition:)]) [(PackPotionOption *)newItm setPosition:newItems.count];
        }
        [newItems addObject:newItm];
    }
    return newItems;
}

+ (NSArray *) orderedKeysForType:(MysticObjectType)type;
{
    NSString *key = nil;
    
    switch (type) {
        case MysticObjectTypePack:
            key = @"group-packs";
            break;
            
        default:
            key = [[self class] keyPathForType:type];
            break;
    }
    return [self orderedKeysForType:type atKey:key];
}
+ (NSArray *) orderedKeysForType:(MysticObjectType)type atKey:(NSString *)key;
{
    return [[self class] objectAtKeyPath:[@"orders." stringByAppendingString:key]];
}
+ (NSDictionary *) dataForType:(MysticObjectType)type;
{
    
    NSString *key = [[self class] keyPathForType:type];
    NSDictionary *data = [[self class] objectAtKeyPath:key];
    return data;
}

+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType;
{
    return [[self class] itemsInfoForType:optionType filter:nil];
}

+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType filter:(MysticBlockFilteredObj)filter;
{
    NSString *key = [[self class] keyPathForType:optionType];
    NSDictionary *data = [[self class] objectAtKeyPath:key];
    if(!data || !data.count) return @[];
    NSArray *itemsOrderedKeys = [[self class] objectAtKeyPath:[@"orders." stringByAppendingString:key]];
    return [[self class] itemsInfoForType:optionType info:data keyOrder:itemsOrderedKeys extraInfo:nil filter:filter];
}

+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder extraInfo:(NSDictionary *)extraInfo filter:(MysticBlockFilteredObj)filter;
{
    NSMutableArray *newItems = [NSMutableArray array];
    if(filter)
    {
        BOOL stop = NO;
        NSMutableDictionary *returnItemsDict = [NSMutableDictionary dictionary];
        
        for (NSString *packKey in itemsDict.allKeys)
        {
            NSDictionary *oDict = filter([itemsDict objectForKey:packKey], &stop);
            if(oDict) [returnItemsDict setObject:oDict forKey:packKey];
            if(stop) break;
        }
        
        itemsDict = [NSDictionary dictionaryWithDictionary:returnItemsDict];
        
        NSArray *filteredKeys = itemsDict ? [itemsDict allKeys] : nil;
        if(keyOrder && filteredKeys && filteredKeys.count && keyOrder.count != filteredKeys.count)
        {
            NSMutableArray *newKeyOrder = [NSMutableArray array];
            for (NSString *optionKey in keyOrder) if([filteredKeys containsObject:optionKey]) [newKeyOrder addObject:optionKey];
            keyOrder = newKeyOrder;
        }
        else  if(!keyOrder && filteredKeys) keyOrder = filteredKeys;
        
    }
    else
    {
        keyOrder = keyOrder ? keyOrder : [itemsDict allKeys];
    }
    for (NSString *optionKey in keyOrder)
    {
        if(![itemsDict objectForKey:optionKey] || [[[itemsDict objectForKey:optionKey] objectForKey:@"cancel"] boolValue]) continue;
        
        NSDictionary *oInfo = [itemsDict objectForKey:optionKey];
        if(extraInfo)
        {
            NSMutableDictionary *oInfo2 = [NSMutableDictionary dictionaryWithDictionary:oInfo];
            [oInfo2 addEntriesFromDictionary:extraInfo];
            oInfo = oInfo2;
        }
        [newItems addObject:oInfo];
    }
    return newItems;
}

+ (id) itemForType:(MysticObjectType)objectType info:(NSDictionary *)itemInfo itemKey:(NSString *)itemKey;
{
    Class optionClass = [[self class] itemClassForType:objectType];
    return [[self class] itemForType:objectType info:itemInfo itemKey:itemKey class:optionClass];
}
+ (id) itemForType:(MysticObjectType)objectType info:(NSDictionary *)itemInfo itemKey:(NSString *)itemKey class:(Class)itemClass;
{
    
    return itemClass == [NSDictionary class] ? itemInfo : [itemClass optionWithName:itemKey info:itemInfo];
}


#pragma mark - Number of entries

+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes;
{
    return [[self class] numberOfItemsOfType:optionTypes filter:nil];
}

+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes filter:(MysticBlockFilteredKeyObj)filter;
{
    return [self numberOfItemsOfType:optionTypes orderedKeys:nil filter:filter];
}
+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes orderedKeys:(NSArray *)orderedKeys filter:(MysticBlockFilteredKeyObj)filter;
{

    optionTypes = MysticTypeToOptionTypes(optionTypes);
    NSInteger c = 0;
    
    MysticObjectType optionType = MysticOptionTypesToObjectType(optionTypes);
    NSString *key = [[self class] keyPathForType:optionType];
    NSDictionary *data = [[self class] objectAtKeyPath:key];

    if(!data || !data.count) return c;
    
    if(filter)
    {
//        orderedKeys = orderedKeys ? orderedKeys : [[self class] orderedKeysForType:optionType];
        NSArray *datas = orderedKeys ? [data objectsForKeys:orderedKeys notFoundMarker:@(-1)] : data.allValues;
        orderedKeys = orderedKeys ? orderedKeys : data.allKeys;
        BOOL stop = NO;
        int i = 0;
        for (NSDictionary *oDict in datas) {
            if(![oDict isKindOfClass:[NSNumber class]] && filter([orderedKeys objectAtIndex:i], oDict, &stop)) c++;
            i++;
            if(stop) break;
        }
        filter(nil, nil, &stop);
    }
    else
    {
        c = data.allValues.count;
    }
  
    
    return c;
    
}

+ (NSInteger) numberOfItemsOfType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict filter:(MysticBlockFilteredKeyObj)filter;
{
    if(filter)
    {
        BOOL stop = NO;
        NSInteger c = 0;
        int i = 0;
        for (NSDictionary *oDict in itemsDict.allValues) {
            if(filter([itemsDict.allKeys objectAtIndex:i], oDict, &stop)) c++;
            i++;
            if(stop) break;
            
        }
        return c;
    }
    return itemsDict.allValues.count;
}


#pragma mark - Number of Sections

+ (NSInteger) numberOfSectionsOfType:(MysticOptionTypes)optionTypes;
{
    return [[self class] numberOfSectionsOfType:optionTypes filter:nil];
}

+ (NSInteger) numberOfSectionsOfType:(MysticOptionTypes)optionTypes filter:(MysticBlockFilteredObj)filter;
{
    optionTypes = MysticTypeToOptionTypes(optionTypes);
    return 0;
}

+ (NSInteger) numberOfItemsForSection:(NSInteger)section type:(MysticOptionTypes)optionTypes;
{
    return 0;
}

#pragma mark - Caching


+ (id) cacheObject:(id)obj forKey:(id)cacheKey forType:(MysticOptionTypes)type;
{
    if(!cacheKey) return obj;
    if(!MysticDictionaryDataSourceCache) MysticDictionaryDataSourceCache = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *targetDict = nil;
    if(type > 0)
    {
        NSString *typeKey = [NSString stringWithFormat:@"%@", @(type)];
        if(![MysticDictionaryDataSourceCache objectForKey:typeKey])
        {
            [MysticDictionaryDataSourceCache setObject:[NSMutableDictionary dictionary] forKey:typeKey];
        }
        targetDict = [MysticDictionaryDataSourceCache objectForKey:typeKey];
    }
    else
    {
        NSString *typeKey = @"cache";
        if(![MysticDictionaryDataSourceCache objectForKey:typeKey])
        {
            [MysticDictionaryDataSourceCache setObject:[NSMutableDictionary dictionary] forKey:typeKey];
        }
        targetDict = [MysticDictionaryDataSourceCache objectForKey:typeKey];
    }
    
    if(targetDict)
    {
        if(!obj)
        {
            [targetDict removeObjectForKey:cacheKey];
        }
        else
        {
            [targetDict setObject:obj forKey:cacheKey];
        }
    }
    return obj;
}
+ (id) cacheObject:(id)obj forKey:(id)cacheKey;
{
    return [[self class] cacheObject:obj forKey:cacheKey forType:(MysticOptionTypes)0];
}

+ (id) cacheObjectForKey:(id)cacheKey defaultObject:(id)defaultObject;
{
    return [self cacheObjectForKey:cacheKey forType:(MysticOptionTypes)0 defaultObject:defaultObject];
}
+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type defaultObject:(id)defaultObject;
{
    id obj = [self cacheObjectForKey:cacheKey forType:type];
    if(!obj && defaultObject)
    {
        [self cacheObject:defaultObject forKey:cacheKey forType:type];
        return defaultObject;
    }
    return obj;
}

+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type orBlockObject:(MysticBlockReturnsObj)buildObjBlock;
{
    id obj = [self cacheObjectForKey:cacheKey forType:type];
    if(!obj && buildObjBlock)
    {
        id newObj = buildObjBlock(nil);
        if(newObj)
        {
            [self cacheObject:newObj forKey:cacheKey forType:type];
        }
        return newObj;
    }
    return obj;
}


+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type;
{
    if(!cacheKey || !MysticDictionaryDataSourceCache) return nil;
    
    NSMutableDictionary *targetDict = nil;
    if(type > 0)
    {
        NSString *typeKey = [NSString stringWithFormat:@"%@", @(type)];
        targetDict = [MysticDictionaryDataSourceCache objectForKey:typeKey];
    }
    else
    {
        targetDict = MysticDictionaryDataSourceCache;
    }
    
    return targetDict ? [targetDict objectForKey:cacheKey] : nil;
}
+ (id) cacheObjectForKey:(id)cacheKey;
{
    return [[self class] cacheObjectForKey:cacheKey forType:(MysticOptionTypes)0];
}

+ (void) removeCacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type;
{
    [[self class] cacheObject:nil forKey:cacheKey forType:type];
}
+ (void) removeCacheObjectForKey:(id)cacheKey;
{
    [[self class] removeCacheObjectForKey:cacheKey forType:(MysticOptionTypes)0];
}

+ (void) removeAllCacheObjectsForType:(MysticOptionTypes)type;
{
    if(!MysticDictionaryDataSourceCache) return;
    NSString *typeKey = [NSString stringWithFormat:@"%@", @(type)];
    [MysticDictionaryDataSourceCache removeObjectForKey:typeKey];
    

}

+ (id) cacheObjectsForType:(MysticOptionTypes)type;
{
    if(!MysticDictionaryDataSourceCache) return nil;
    NSString *typeKey = [NSString stringWithFormat:@"%@", @(type)];
    return [MysticDictionaryDataSourceCache objectForKey:typeKey];
}
+ (void) clearCache;
{
    [MysticDictionaryDataSourceCache removeAllObjects];
}
+ (id) cache;
{
    return MysticDictionaryDataSourceCache;
}

@end


@implementation MysticDictionaryDataSourceShapes


+ (MysticDictionary *) data;
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"shapes" ofType:@"plist"];
    return [[[MysticDictionary alloc] initWithContentsOfFile:file] autorelease];
    
}
+ (NSString *) keyPathForType:(MysticObjectType)type;
{
    switch (type) {
        case MysticObjectTypeUnknown:
        case MysticObjectTypeLayerShape:
            return @"items";
            
            
        default: break;
    }
    return [super keyPathForType:type];
}
+ (MysticObjectType) itemsType;
{
    return MysticObjectTypeLayerShape;
}

@end
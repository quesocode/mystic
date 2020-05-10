//
//  MysticOptionsDataSource.m
//  Mystic
//
//  Created by Me on 6/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticOptionsDataSource.h"
#import "MysticBackgroundsDataSource.h"

#import "Mystic.h"
#import "PackPotionOptionCollectionItem.h"

@implementation MysticOptionsDataSource


static NSMutableDictionary *numberOfSections;
static NSMutableDictionary *numberOfItemsPerSection;

+ (void) initialize;
{
    if(!numberOfSections) numberOfSections = [[NSMutableDictionary dictionary] retain];
    if(!numberOfItemsPerSection) numberOfItemsPerSection = [[NSMutableDictionary dictionary] retain];
//    [MysticOptionsDataSource shared];

}

+ (MysticOptionsDataSource *) shared;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(configUpdated:) name:@"MysticConfigUpdated" object:nil];
    });
    return instance;
}

+ (void) removePackCache;
{
    [numberOfSections removeAllObjects];
    [numberOfItemsPerSection removeAllObjects];
}

+ (NSArray *)packs;
{
    return [[self class] optionTypes] != MysticOptionTypeUnknown ? [[self class] packsWithType:[[self class] packTypes]] : [NSArray array];
}
+ (MysticOptionTypes) optionTypes;
{
    return MysticOptionTypeUnknown;
}
+ (MysticOptionTypes) packTypes;
{
    return MysticOptionTypePack;
}

+ (NSInteger) numberOfPacksOfType:(MysticOptionTypes)optionTypes;
{
    NSString *s = [NSString stringWithFormat:@"%@", @(optionTypes)];
    if([numberOfSections objectForKey:s]) return [numberOfSections objectForKey:s] ? [[numberOfSections objectForKey:s] integerValue] : 0;

    NSString *sOrder = [s stringByAppendingString:@"-order"];
    
    optionTypes = MysticTypeToOptionTypes(optionTypes);
    NSDictionary *objTypesDict = MysticOptionTypesToObjectTypesDictionary(optionTypes);
    
    __block NSMutableArray *orderSections = [numberOfSections objectForKey:sOrder];
    if(!orderSections) orderSections = [NSMutableArray array];
    [orderSections retain];
    
    NSArray *orderedKeys = [[self class] orderedKeysForType:MysticObjectTypePack atKey:@"packs"];
    NSInteger c = [[self class] numberOfItemsOfType:MysticOptionTypePack orderedKeys:orderedKeys filter:^id(id key, NSDictionary *packDict, BOOL *stop) {
        if(key && packDict)
        {
            id p = [packDict objectForKey:@"group"] && [objTypesDict objectForKey:[packDict objectForKey:@"group"]] ? packDict : nil;
            if(p) [orderSections addObject:packDict];
            return p;
        }
        else
        {
            [orderSections release];
        }
        return nil;
    }];
    
    if(optionTypes & MysticOptionTypeShowFeaturedPack) c++;
    if(c > 0) [numberOfSections setObject:@(c) forKey:s];
    return c;
    
}






+ (NSInteger) numberOfItemsForSection:(NSInteger)section type:(MysticOptionTypes)optionTypes;
{
    NSInteger itemCount = 0;

    MysticObjectType objType = MysticOptionTypesToObjectType(optionTypes);
    NSDictionary *objTypesDict = MysticOptionTypesToObjectTypesDictionary(optionTypes);
    NSString *s = [NSString stringWithFormat:@"%@-order", @(optionTypes)];
    NSDictionary *pack = nil;
    NSString *groupKey = MysticObjectTypeKey(objType);

    BOOL hasFeaturedSection = (optionTypes & MysticOptionTypeShowFeaturedPack) ? YES : NO;
    NSNumber *specialCount = [self objectAtKeyPath:[@"group-packs." stringByAppendingFormat:@"%@.special_pack_count", groupKey]];
    BOOL hasSpecialSection = specialCount && [specialCount integerValue] > 0 ? YES : NO;
    int featuredSectionIndex = hasSpecialSection && !(optionTypes & MysticOptionTypeShowFeaturedPackTop) ? 1 : 0;
    BOOL isSectionFeatured = section == featuredSectionIndex && optionTypes & MysticOptionTypeShowFeaturedPack && (optionTypes & MysticOptionTypeShowFeaturedPackTop);
    int sectionDataIndex = hasFeaturedSection ? section - 1 : section;
    
    if(!isSectionFeatured && [numberOfSections objectForKey:s] && [(NSArray *)[numberOfSections objectForKey:s] count] > sectionDataIndex)
    {
        pack = [[numberOfSections objectForKey:s] objectAtIndex:sectionDataIndex];

    }
    groupKey = pack ? [pack objectForKey:@"group"] : MysticObjectTypeKey(objType);
    NSString *packTag = @"featured";

    if(section == featuredSectionIndex && optionTypes & MysticOptionTypeShowFeaturedPack)
    {
        NSNumber *fCount = [self objectAtKeyPath:[@"group-packs." stringByAppendingFormat:@"%@.featured_count", groupKey]];
        if(fCount)
        {
            itemCount = MIN(MYSTIC_FEATURED_MAX, [fCount integerValue]);
        }
        else
        {
            NSArray *featured = [self objectAtKeyPath:[@"group-packs." stringByAppendingFormat:@"%@.featured_layers", groupKey]];
            if(featured)
            {
                itemCount = featured.count;
            }
            else
            {
                itemCount = MYSTIC_FEATURED_MAX;
            }
        }
        
        
    }
    else
    {
        
        NSArray *packsInfo = [self objectAtKeyPath:[@"group-packs." stringByAppendingFormat:@"%@.packs", groupKey]];
        NSNumber *lastPackCount = nil;
        if((!packsInfo || packsInfo.count == 0) && section < 2)
        {
            lastPackCount = [self objectAtKeyPath:[@"group-packs." stringByAppendingFormat:@"%@.layer_count", groupKey]];
            packTag = [groupKey stringByAppendingString:@"-all"];
            
            
        }
        else
        {
            if(pack)
            {
                lastPackCount = [pack objectForKey:@"layers_primary_count"];
                packTag = [pack objectForKey:@"name"];
            }
            if(!lastPackCount)
            {
                NSString *lastPackTag = packsInfo && packsInfo.count > (section-1) ? [packsInfo objectAtIndex:(section-1)] : nil;
                packTag = lastPackTag;
                lastPackCount = [self objectAtKeyPath:[@"packs." stringByAppendingFormat:@"%@.layers_primary_count", lastPackTag]];
            }
        }
        
        if(lastPackCount)
        {
            itemCount = [lastPackCount integerValue];
        }
    }
    
    return itemCount;
}





+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes;
{
    return [self packsWithType:optionTypes maxNumberOfFeaturedItems:-1];
}



+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes maxNumberOfFeaturedItems:(NSInteger)max;
{
    return [[self class] packsWithType:optionTypes maxNumberOfFeaturedItems:max filter:nil];
}
+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes maxNumberOfFeaturedItems:(NSInteger)max filter:(MysticBlockFilteredObj)filter;
{
    
    NSInteger oMax = max;
    NSString *cacheKey = [NSString stringWithFormat:@"packsWithType-%d", (int)oMax];
    id cachedObj = [[self class] cacheObjectForKey:cacheKey forType:optionTypes];
    if(cachedObj) return cachedObj;

    NSInteger max2 = -1;
    if(optionTypes & MysticOptionTypeTopFortyItems)
    {
        max2 = 40;
    }
    if(optionTypes & MysticOptionTypeTopTenItems)
    {
        max2 = MYSTIC_FEATURED_MAX_TOP;
    }
    if(optionTypes & MysticOptionTypeShowFeaturedPack)
    {
        max2 = MYSTIC_FEATURED_MAX;
    }
    
    
    MysticPack *pack;
    optionTypes = MysticTypeToOptionTypes(optionTypes);
    BOOL useTypeTitleForFeatured = optionTypes & MysticOptionTypeUseTypeTitle;
    MysticObjectType objType = MysticOptionTypesToObjectType(optionTypes);
    __block NSDictionary *objTypesDict = MysticOptionTypesToObjectTypesDictionary(optionTypes);
    filter = filter ? filter : (objTypesDict.allKeys.count <= 1 ? nil : ^id(NSDictionary *packDict, BOOL *stop) {
        return [objTypesDict objectForKey:[packDict objectForKey:@"group"]] ? packDict : nil;
    });
    
    NSString *groupKey = objTypesDict.allKeys.count > 1 ? @"packs" : [NSString stringWithFormat:@"group-packs.%@", MysticObjectTypeKey(objType)];
    NSArray *orderedKeys = [[self class] orderedKeysForType:MysticObjectTypePack atKey:groupKey];
    NSArray *thePackData = [[self class] itemsForType:MysticObjectTypePack keyOrder:orderedKeys filter:filter];
        
    NSMutableArray *thePacks = [[NSMutableArray arrayWithArray:thePackData] retain];
    
    if(max < 0)
    {
        if((max2 != NSNotFound && thePacks.count <= 1) && (optionTypes & MysticOptionTypeShowFeaturedPack)) max2 = NSNotFound;
        max = max2 != -1 ? max2 : 0;
    }
    if(useTypeTitleForFeatured && !thePacks.count) useTypeTitleForFeatured = YES;
    
    BOOL useFeatured = thePacks.count >= 2;
    BOOL hasSpecial = NO;
    int insertFeaturedIndex = 0;
    if(thePacks.count)
    {
        MysticPack* firstPack = [thePacks objectAtIndex:0];
        hasSpecial = firstPack.isSpecial;
        if(hasSpecial) insertFeaturedIndex = 1;
    }
    if(optionTypes & MysticOptionTypeShowFeaturedPackTop) insertFeaturedIndex = 0;
    if((optionTypes & MysticOptionTypeShowFeaturedPack) || (optionTypes & MysticOptionTypeShowFeaturedPackTop))
    {
        if(max > 0 || max == NSNotFound)
        {
            if(optionTypes & MysticOptionTypeDataOnly)
            {
                NSString *featuredTitle = !useTypeTitleForFeatured ? [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_title", MysticObjectTypeKey(objType)] default:@"Featured"] : MysticObjectTypeTitleParent(objType, objType);
                [thePacks insertObject:@{@"name": featuredTitle,
                                         @"max": @(max),
                                         @"count": @(max),
                                         @"featured": @(YES),
                                         @"group": MysticObjectTypeKey(objType),
                                         } atIndex:insertFeaturedIndex];

            }
            else
            {
                pack = [[[self class] packClass] featuredPackForType:objType useTypeTitle:useTypeTitleForFeatured max:!useFeatured ? NSNotFound : max];
                pack.featuredPack = useFeatured;
                [thePacks insertObject:pack atIndex:insertFeaturedIndex];
            }
        }
        
        if(optionTypes & MysticOptionTypeShowFeaturedPack && thePacks.count == 1 && !(optionTypes & MysticOptionTypeDataOnly))
        {
            pack = [thePacks objectAtIndex:0];
            if(pack.featuredPack) pack.maxNumberOfPotions = NSNotFound;
        }
    }
    
    return [[self class] cacheObject:[thePacks autorelease] forKey:cacheKey forType:optionTypes];
}


+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder extraInfo:(NSDictionary *)extraInfo filter:(MysticBlockFilteredObj)filter;
{
    switch (optionType) {
        case MysticObjectTypePack:
            extraInfo = @{@"count": @(5)};
            break;
            
        default: break;
    }
    return [super itemsInfoForType:optionType info:itemsDict keyOrder:keyOrder extraInfo:extraInfo filter:filter];
}


+ (id) settingForKey:(NSString *)key;
{
    return [self settingForKey:key default:nil];
}
+ (id) settingForKey:(NSString *)key default:(id)defaultValue;
{
    id r = [self objectAtKeyPath:[@"settings." stringByAppendingString:key]];
    return r == nil && defaultValue != nil ? defaultValue : r;
}
+ (MysticObjectType) itemsType;
{
    return MysticObjectTypeUnknown;
}
- (void) dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MysticOptionsDataSource clearCache];
    [numberOfSections removeAllObjects];
    [numberOfItemsPerSection removeAllObjects];
    [super dealloc];

}
- (void) configUpdated:(id)notification;
{
    [MysticOptionsDataSource clearCache];
    [numberOfSections removeAllObjects];
    [numberOfItemsPerSection removeAllObjects];
}


+ (id) itemForType:(MysticObjectType)objectType info:(NSDictionary *)itemDictInput itemKey:(NSString *)itemKey class:(Class)itemClass;
{
    
    NSDictionary *itemDict = itemDictInput;
    MysticAssetCollectionItem *itemInfo = nil;
    switch (objectType) {
        case MysticObjectTypeColorOverlay:
        {
            MysticBackgroundsDataSource *dataSource = [[[MysticBackgroundsDataSource alloc] init] autorelease];
            itemInfo = [dataSource itemWithTag:itemKey info:itemDict];
            
            itemDict = itemInfo ? itemInfo.info : nil;
            
        }
            
        default: break;
    }
    PackPotionOptionCollectionItem*collectionItem = [itemClass optionWithName:itemKey info:itemDict];

    if([itemClass isSubclassOfClass:[PackPotionOptionCollectionItem class]])
    {
        collectionItem.item = itemInfo;
        
        return collectionItem;
    }
    return collectionItem;
}

@end

@implementation MysticSettings



@end

@implementation MysticOptionsDataSourceShapes

+ (Class) packClass;
{
    return [MysticLayerShapePack class];
}
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
+ (MysticOptionTypes) packTypes;
{
    return MysticOptionTypeLayerShapePacks|MysticOptionTypeShowFeaturedPack;
}
+ (MysticOptionTypes) optionTypes;
{
    return MysticOptionTypeLayerShape|MysticOptionTypeShowFeaturedPack;
}

+ (NSArray *) orderedKeysForType:(MysticObjectType)type;
{
    NSString *key = nil;
    
    switch (type) {
        case MysticObjectTypePack:
            key = @"packs";
            break;
        case MysticObjectTypeLayerShape:
            key = @"items";
            break;
            
        default:
            key = [[self class] keyPathForType:type];
            break;
    }
    return [self orderedKeysForType:type atKey:key];
}

@end

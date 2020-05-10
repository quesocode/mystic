//
//  MysticDictionaryDataSource.h
//  Mystic
//
//  Created by Me on 6/10/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@class MysticDictionary;

@interface MysticDictionaryDataSource : NSObject
+ (Class) packClass;
+ (Class) itemClassForType:(MysticObjectType)type;
+ (MysticDictionary *) data;
+ (void) preload:(MysticOptionTypes)optionTypes;
+ (void) unload:(MysticOptionTypes)optionTypes;
+ (void) items:(MysticBlockData)block;

+ (id) objectAtKeyPath:(NSString *)keyPath;
+ (id) objectAtKeyPath:(NSString *)keyPath filter:(MysticBlockFilteredObj)filterBlock;

+ (NSArray *) orderedKeysForType:(MysticObjectType)type;
+ (NSArray *) orderedKeysForType:(MysticObjectType)type atKey:(NSString *)key;
+ (NSDictionary *) dataForType:(MysticObjectType)type;

+ (NSString *) keyPathForType:(MysticObjectType)type;

+ (id) itemForType:(MysticObjectType)objectType info:(NSDictionary *)itemInfo itemKey:(NSString *)itemKey;
+ (id) itemForType:(MysticObjectType)objectType info:(NSDictionary *)itemInfo itemKey:(NSString *)itemKey class:(Class)itemClass;

+ (NSArray *) items;
+ (NSArray *) itemsForType:(MysticObjectType)optionType;
+ (NSArray *) itemsForType:(MysticObjectType)optionType filter:(MysticBlockFilteredObj)filter;
+ (NSArray *) itemsForType:(MysticObjectType)optionType keyOrder:(NSArray *)keyOrder filter:(MysticBlockFilteredObj)filter;

+ (NSArray *) itemsForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder;
+ (NSArray *) itemsForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder  filter:(MysticBlockFilteredObj)filter;

+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType;
+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType filter:(MysticBlockFilteredObj)filter;
+ (NSArray *) itemsInfoForType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict keyOrder:(NSArray *)keyOrder extraInfo:(NSDictionary *)extraInfo filter:(MysticBlockFilteredObj)filter;

+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes;
+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes filter:(MysticBlockFilteredKeyObj)filter;
+ (NSInteger) numberOfItemsOfType:(MysticObjectType)optionType info:(NSDictionary *)itemsDict filter:(MysticBlockFilteredKeyObj)filter;
+ (NSInteger) numberOfItemsOfType:(MysticOptionTypes)optionTypes orderedKeys:(NSArray *)orderedKeys filter:(MysticBlockFilteredKeyObj)filter;



+ (NSInteger) numberOfSectionsOfType:(MysticOptionTypes)optionTypes;
+ (NSInteger) numberOfSectionsOfType:(MysticOptionTypes)optionTypes filter:(MysticBlockFilteredObj)filter;
+ (NSInteger) numberOfItemsForSection:(NSInteger)section type:(MysticOptionTypes)optionTypes;

+ (void) clearCache;
+ (id) cacheObject:(id)obj forKey:(id)cacheKey forType:(MysticOptionTypes)type;
+ (id) cacheObject:(id)obj forKey:(id)cacheKey;

+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type;
+ (id) cacheObjectForKey:(id)cacheKey;

+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type orBlockObject:(MysticBlockReturnsObj)buildObjBlock;
+ (id) cacheObjectForKey:(id)cacheKey defaultObject:(id)defaultObject;
+ (id) cacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type defaultObject:(id)defaultObject;
+ (id) cacheObjectsForType:(MysticOptionTypes)type;
+ (id) cache;
+ (void) removeAllCacheObjectsForType:(MysticOptionTypes)type;

+ (void) removeCacheObjectForKey:(id)cacheKey forType:(MysticOptionTypes)type;
+ (void) removeCacheObjectForKey:(id)cacheKey;
@end


@interface MysticDictionaryDataSourceShapes : MysticDictionaryDataSource;

@end
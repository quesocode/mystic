//
//  MysticOptionsDataSource.h
//  Mystic
//
//  Created by Me on 6/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDictionaryDataSource.h"

@interface MysticOptionsDataSource : MysticDictionaryDataSource

+ (MysticOptionsDataSource *) shared;
+ (NSArray *)packs;
+ (MysticOptionTypes) packTypes;

+ (NSInteger) numberOfPacksOfType:(MysticOptionTypes)optionTypes;
+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes;
+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes maxNumberOfFeaturedItems:(NSInteger)max;
+ (NSArray *) packsWithType:(MysticOptionTypes)optionTypes maxNumberOfFeaturedItems:(NSInteger)max filter:(MysticBlockFilteredObj)filter;
+ (id) settingForKey:(NSString *)key;
+ (id) settingForKey:(NSString *)key default:(id)defaultValue;
+ (void) removePackCache;
+ (MysticObjectType) itemsType;

+ (MysticOptionTypes) optionTypes;

@end


@interface MysticSettings : MysticOptionsDataSource

@end


@interface MysticOptionsDataSourceShapes : MysticOptionsDataSource;

@end
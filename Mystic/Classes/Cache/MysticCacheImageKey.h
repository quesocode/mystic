//
//  MysticCacheImageKey.h
//  Mystic
//
//  Created by Travis on 10/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"


extern NSString * const MysticCacheImageKeyKeyQuality;
extern NSString * const MysticCacheImageKeyKeyTag;
extern NSString * const MysticCacheImageKeyKeyCacheKey;
extern NSString * const MysticCacheImageKeyKeyPrefix;

extern NSString * const MysticCacheImageKeyKeyType;
extern NSString * const MysticCacheImageKeyKeyOption;
extern NSString * const MysticCacheImageKeyKeySaveToMemory;
extern NSString * const MysticCacheImageKeyKeySaveToDisk;
extern NSString * const MysticCacheImageKeyKeyCache;
extern NSString * const MysticCacheImageKeyKeyName;

@class MysticOption, MysticCacheImage, MysticCacheImageKey, MysticImage, MysticCache;

@interface MysticCacheImageKey : NSObject

@property (nonatomic, assign) MysticCache *cache;
@property (nonatomic, assign) NSString *tag;
@property (nonatomic, assign) NSString *keyPrefix;

@property (nonatomic, assign) NSString *cacheKey;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) MysticImageType type;
@property (nonatomic, assign) MysticOption *option;
@property (nonatomic, assign) BOOL saveToDisk, saveToMemory;
@property (nonatomic, assign) CGFloat quality;
@property (nonatomic, readonly) NSArray *allKeys, *allValues;
@property (nonatomic, strong) MysticBlockKey keyFilter;


+ (MysticCacheImageKey *) options:(id)info;

+ (MysticCacheImageKey *) optionsWithImage:(MysticImage *)image;

- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey;
- (id) objectForKey:(id<NSCopying>)aKey;

@end

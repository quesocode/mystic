//
//  MysticCacheImageKey.m
//  Mystic
//
//  Created by Travis on 10/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticCacheImageKey.h"
#import "MysticImage.h"
#import "MysticCache.h"
#import "NSString+Mystic.h"

NSString * const MysticCacheImageKeyKeyQuality = @"quality";
NSString * const MysticCacheImageKeyKeyTag = @"tag";
NSString * const MysticCacheImageKeyKeyCacheKey = @"cacheKey";
NSString * const MysticCacheImageKeyKeyType = @"type";
NSString * const MysticCacheImageKeyKeyOption = @"option";
NSString * const MysticCacheImageKeyKeySaveToMemory = @"saveToMemory";
NSString * const MysticCacheImageKeyKeySaveToDisk = @"saveToDisk";
NSString * const MysticCacheImageKeyKeyCache = @"cache";
NSString * const MysticCacheImageKeyKeyName = @"name";
NSString * const MysticCacheImageKeyKeyPrefix = @"prefix";

@interface MysticCacheImageKey ()
{
    NSMutableDictionary *__store;
}


@end

@implementation MysticCacheImageKey

@synthesize
tag=_tag,
cacheKey=_cacheKey,
cache=_cache,
type=_type,
saveToDisk=_saveToDisk,
saveToMemory=_saveToMemory,
keyFilter=_keyFilter,
option=__option,
quality=_quality;

+ (MysticCacheImageKey *) options:(id)info;
{
    NSMutableDictionary *_info = [NSMutableDictionary dictionaryWithObjects:[info allValues] forKeys:[info allKeys]];
    id _c = [_info objectForKey:MysticCacheImageKeyKeyCache];
    if(_c && [_c isKindOfClass:[NSNumber class]])
    {
        [_info setObject:[MysticCache cache:[_c integerValue]] forKey:MysticCacheImageKeyKeyCache];
    }
    MysticCacheImageKey *opts = [[MysticCacheImageKey alloc] initWithDictionary:_info];
    return [opts autorelease];
}
+ (MysticCacheImageKey *) optionsWithImage:(MysticImage *)image;
{
    if(!image || [image isKindOfClass:[MysticImage class]]) return nil;
    MysticCacheImageKey *options = [[MysticCacheImageKey alloc] init];
    options.quality = image.quality;
    options.cache = image.cache;
    options.tag = image.tag;
    options.cacheKey = image.cacheKey;
    options.type = image.type;
    options.option = image.option;
    options.saveToDisk = image.saveToDisk;
    options.saveToMemory = image.saveToMemory;
    return [options autorelease];
}

- (void) dealloc;
{
    [__store release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        __store = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (id) initWithDictionary:(NSDictionary *)dictionary;
{
    self = [self init];
    if(self)
    {
        if(dictionary)
        {
            for (id key in dictionary.allKeys) {
                id realKey = self.keyFilter(key);
                [self setObject:[dictionary objectForKey:key] forKey:realKey];
            }
        }
    }
    return self;
}
- (MysticBlockKey) keyFilter;
{
     MysticBlockKey theFilter = ^ NSString *(id mkey)
    {
        NSString *sfx = nil;
        if([mkey isKindOfClass:[NSString class]])
        {
            
            if(MysticCacheImageKeyKeyQuality == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyQuality])
            {
                 mkey = MysticCacheImageKeyKeyQuality;
            }
            else if(MysticCacheImageKeyKeyTag == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyTag])
            {
                mkey = MysticCacheImageKeyKeyTag;
            }
            else if(MysticCacheImageKeyKeyPrefix == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyPrefix])
            {
                mkey = MysticCacheImageKeyKeyPrefix;
            }
            else if(MysticCacheImageKeyKeyCacheKey == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyCacheKey])
            {
                mkey = MysticCacheImageKeyKeyCacheKey;
            }
            else if(MysticCacheImageKeyKeyType == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyType])
            {
                mkey = MysticCacheImageKeyKeyType;
            }
            else if(MysticCacheImageKeyKeyOption == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyOption])
            {
                mkey = MysticCacheImageKeyKeyOption;
            }
            else if(MysticCacheImageKeyKeySaveToMemory == mkey || [mkey isEqualToString:MysticCacheImageKeyKeySaveToMemory])
            {
                mkey = MysticCacheImageKeyKeySaveToMemory;
            }
            else if(MysticCacheImageKeyKeySaveToDisk == mkey || [mkey isEqualToString:MysticCacheImageKeyKeySaveToDisk])
            {
                mkey = MysticCacheImageKeyKeySaveToDisk;
            }
            else if(MysticCacheImageKeyKeyCache == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyCache])
            {
                mkey = MysticCacheImageKeyKeyCache;
            }
            else if(MysticCacheImageKeyKeyName == mkey || [mkey isEqualToString:MysticCacheImageKeyKeyName])
            {
                mkey = MysticCacheImageKeyKeyName;
            }
        }
        NSString *s = sfx ? [mkey stringByAppendingString:sfx] : mkey;
        
//        if(self.keyPrefix)
//        {
//            s = [self.keyPrefix stringByAppendingString:s];
//        }
        return s;
    };
    return theFilter;
}

- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey;
{
    
    if(obj && aKey)
    {
        [__store setObject:obj forKey:self.keyFilter(aKey)];
    }
}
- (id) objectForKey:(id<NSCopying>)aKey;
{
    return aKey ? [__store objectForKey:self.keyFilter(aKey)] : nil;
}
- (void) setQuality:(CGFloat)quality;
{
    [self setObject:@(quality) forKey:MysticCacheImageKeyKeyQuality];
}
- (void) setSaveToDisk:(BOOL)saveToDisk;
{
    [self setObject:@(saveToDisk) forKey:MysticCacheImageKeyKeySaveToDisk];
}
- (void) setSaveToMemory:(BOOL)saveToMemory;
{
    [self setObject:@(saveToMemory) forKey:MysticCacheImageKeyKeySaveToMemory];
}
- (void) setType:(MysticImageType)type;
{
    [self setObject:@(type) forKey:MysticCacheImageKeyKeyType];
}
- (void) setCacheKey:(NSString *)value;
{
    
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyCacheKey];
}
- (void) setKeyPrefix:(NSString *)value;
{
    
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyPrefix];
}
- (void) setName:(NSString *)value;
{
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyName];
}
- (void) setTag:(NSString *)value;
{
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyTag];
}
- (void) setCache:(MysticCache *)value;
{
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyCache];
}
- (void) setOption:(MysticOption *)value;
{
    if(!value) return;
    [self setObject:value forKey:MysticCacheImageKeyKeyOption];
}

- (BOOL) saveToDisk;
{
    return [self objectForKey:MysticCacheImageKeyKeySaveToDisk] ? [[self objectForKey:MysticCacheImageKeyKeySaveToDisk] boolValue] : NO;
}

- (BOOL) saveToMemory;
{
    return [self objectForKey:MysticCacheImageKeyKeySaveToMemory] ? [[self objectForKey:MysticCacheImageKeyKeySaveToMemory] boolValue] : YES;
}
- (MysticOption *) option;
{
    return [self objectForKey:MysticCacheImageKeyKeyOption];
}
- (NSString *) cacheKey;
{
    NSString *theKey = [self objectForKey:MysticCacheImageKeyKeyCacheKey];
    if(!theKey)
    {
        theKey = self.tag;
        NSString *sfx = @"";
        if(!theKey)
        {
            NSMutableString *newKey = [NSMutableString string];
            for (id k in [self allKeys]) {
                [newKey appendFormat:@"|||%@: %@", k, [self objectForKey:k]];
            }

            theKey = newKey;
        }
        
        switch (self.type) {
            case MysticImageTypeJPNG:
            {
//                DLog(@"image is a JPNG");
                sfx = @".jpng";
                break;
            }
                
            default: break;
        }
        
        
        theKey = [[theKey md5] stringByAppendingString:sfx];

//        if(self.keyPrefix)
//        {
//            theKey = [self.keyPrefix stringByAppendingString:theKey];
//        }
        [self setObject:theKey forKey:MysticCacheImageKeyKeyCacheKey];
    }

    return theKey;
}
- (NSString *) name;
{
    return [self objectForKey:MysticCacheImageKeyKeyName];
}
- (NSString *) tag;
{
    return [self objectForKey:MysticCacheImageKeyKeyTag];
}
- (NSString *) keyPrefix;
{
    return [self objectForKey:MysticCacheImageKeyKeyPrefix];
}
- (MysticCacheImage *) cache;
{
    return [self objectForKey:MysticCacheImageKeyKeyCache];
}
- (CGFloat) quality;
{
    return [self objectForKey:MysticCacheImageKeyKeyQuality] ? [[self objectForKey:MysticCacheImageKeyKeyQuality] floatValue] : 1.0f;
}
- (MysticImageType) type;
{
    return [self objectForKey:MysticCacheImageKeyKeyType] ? [[self objectForKey:MysticCacheImageKeyKeyType] integerValue] : MysticImageTypeUnknown;
}
- (NSArray *) allKeys;
{
    return __store.allKeys;
}
- (NSArray *) allValues;
{
    return __store.allValues;
}
- (NSString *) debugDescription;
{
    return [__store description];
}
- (NSString *) description;
{
    NSString *string = [NSString stringWithFormat:@"MyIO: %@", self.cacheKey];
    return string;
}
@end

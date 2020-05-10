//
//  MysticDictionaryDownloader.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@interface MysticDictionaryDownloader : NSObject

+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary  complete:(MysticBlockObjObjObjBOOL)finished;
+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjObjBOOL)finished;
+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary init:(MysticBlockObjObjObjBOOL)initBlock start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjObjBOOL)finished;

+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary state:(MysticBlockData)finished;

+ (BOOL) removeAllCache;
+ (BOOL) removeCacheForURL:(NSURL *)url;
+ (BOOL) removeCacheForURL:(NSURL *)url filename:(NSString *)filename;
+ (NSString *) cacheDirectoryPath;
+ (NSString *) cachedPathForURL:(NSURL *)url;
+ (NSString *) cachedPathForURL:(NSURL *)url filename:(NSString *)filename;
+ (NSString *) cacheExistsForURL:(NSURL *)url;
+ (NSString *) cacheExistsForURL:(NSURL *)url filename:(NSString *)filename;
+ (NSDictionary *) cachedDictionaryForURL:(NSURL *)url;
+ (NSDictionary *) cachedDictionaryForURL:(NSURL *)url filename:(NSString *)filename;
+ (BOOL) hasCacheExpiredForURL:(NSURL *)url;
+ (BOOL) hasCacheExpiredForURL:(NSURL *)url filename:(NSString *)filename;

@end

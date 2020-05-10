//
//  MysticCache.h
//  Mystic
//
//  Created by travis weerts on 9/18/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "SDImageCache.h"
#import "MysticConstants.h"
#import "SDWebImageManager.h"

@class MysticCacheImage;

@interface MysticCache : SDImageCache;

@property (nonatomic, assign) MysticCacheType mysticCacheType;


+ (void) prepareCachesForNewProject;
+ (void) prepareCachesForLaunch;


+ (SDImageCache *) cache;
+ (MysticCache *) cache:(MysticCacheType)type;
+ (SDImageCache *) cacheType:(MysticCacheType)type;
+ (SDImageCache *) projectCache;
+ (SDImageCache *) imageCache;
+ (SDImageCache *) tempCache;
+ (SDImageCache *) downloadsCache;

+ (SDImageCache *) webCache;
+ (MysticCacheImage *) layerCache;
+ (MysticCache *) uiCache;


+ (SDWebImageManager *) uiManager;
+ (SDWebImageManager *) layerManager;
+ (SDWebImageManager *) webManager;
+ (long long) cacheSizeForAllExceptProject;

+ (NSString *) cacheDirectoryPath;


+ (BOOL) canSaveToDisk:(MysticCacheType)cacheType;
+ (BOOL) canSaveToMemory:(MysticCacheType)cacheType;
+ (void) clearMemory;
+ (void) clearDisk;
+ (void) clearAll;
+ (void) cleanDisk;
+ (void) cleanAll;
- (void) clearAll;
+ (void) clearAllSafely;
+ (void) clearOldProjectCaches;

+ (void) clear:(MysticCacheType)type;

- (UIImage*)cacheImageNamed:(NSString *)imageNamed cacheType:(MysticCacheType *)cacheType;
- (BOOL) deleteAllFiles;
+ (BOOL) deleteAllFiles:(NSString *)dir tag:(NSString *)tag files:(NSMutableArray *)deletedFiles;
+ (BOOL) deleteAllCacheTypeFiles:(MysticCacheType)type tag:(NSString *)tag files:(NSMutableArray *)deletedFiles;
+ (BOOL) deleteAllCacheFiles:(SDImageCache *)cache tag:(NSString *)tag files:(NSMutableArray *)deletedFiles;
+ (BOOL) deleteAllFiles:(NSString *)dir withTag:(NSString *)tag files:(NSMutableArray *)files;
+ (BOOL) deleteAllCacheFiles:(SDImageCache *)cache withTag:(NSString *)tag files:(NSMutableArray *)files;
+ (BOOL) deleteAllCacheTypeFiles:(MysticCacheType)type withTag:(NSString *)tag files:(NSMutableArray *)files;

@end

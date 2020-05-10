//
//  UserPotionManager.h
//  Mystic
//
//  Created by travis weerts on 1/30/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mystic.h"

@interface UserPotionManager : NSObject

+ (NSString *) cachePath;
+ (BOOL) clearCachedFiles;
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag  cacheType:(MysticCacheType)cacheType;
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag  cache:(MysticCacheType)cacheType;

+ (NSString *) setImagePNG:(UIImage *)image tag:(NSString *)tag cache:(MysticCacheType)cacheType;
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag;
+ (NSString *) setImagePNG:(UIImage *)image tag:(NSString *)tag;

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag  finished:(MysticBlock)finished;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType finished:(MysticBlock)finished;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType;

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType finishedPath:(MysticBlockString)finished;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType finishedPath:(MysticBlockString)finished;
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag  finishedPath:(MysticBlockString)finished;

+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed level:(int)level type:(MysticImageType)imgType finished:(MysticBlock)finished;
+ (void) cacheImageNamed:(NSString *)imageNamed done:(MysticBlockImage)done;
+ (UIImage*)cacheImageNamed:(NSString *)imageNamed;
+ (UIImage*)cacheImageWithTag:(NSString *)tag;
+ (NSString *) pathForImageNamed:(NSString *)filename;
+ (NSString *) imagePath;
+ (BOOL) clearCachedFilesWithTag:(NSString *)tag;
+ (BOOL) clearCachedFilesWithTags:(NSArray *)tags;
+ (NSString*) memcacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed type:(MysticImageType)imgType finishedPath:(MysticBlockString)finished;
+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType finishedPath:(MysticBlockString)finished;
+ (NSString*) cacheKeyForSize:(CGSize)size tag:(NSString *)tag;


+ (UIImage*) getImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
+ (UIImage*) getImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType;
+ (NSString*) cacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
+ (NSString*) cacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
+ (UIImage*)cacheProjectImageNamed:(NSString *)imageNamed cacheType:(MysticCacheType)cacheType;

+ (UIImage*)cacheProjectImageNamed:(NSString *)imageNamed;
+ (UIImage*)cacheProjectImageWithTag:(NSString *)tag;
+ (NSString *) projectPath;
+ (NSString *) pathForProjectImageNamed:(NSString *)filename;
+ (BOOL) hasImagesWithTagPrefix:(NSString *)tag;
+ (BOOL) clearCachedFilesWithTags:(NSArray *)tags count:(int *)c files:(NSMutableArray *)files;
+ (NSString *) cachePathForKey:(NSString *)key cacheType:(MysticCacheType)cacheType;

@end

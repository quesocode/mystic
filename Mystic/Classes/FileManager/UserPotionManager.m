//
//  UserPotionManager.m
//  Mystic
//
//  Created by travis weerts on 1/30/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "UserPotionManager.h"
#import "SDImageCache.h"
#import "JPNG.h"
#import "UserPotion.h"

@implementation UserPotionManager

//static NSMutableDictionary *imageCache;
static UserPotionManager *UserPotionManagerInstance = nil;

+ (UserPotionManager *) manager
{
    if(!UserPotionManagerInstance)
    {
        UserPotionManagerInstance = [[UserPotionManager alloc] init];
        
        
    }
    return UserPotionManagerInstance;
}
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag  cache:(MysticCacheType)cacheType;
{
    return [self setImage:image layerLevel:0 tag:tag type:MysticImageTypeJPG cacheType:cacheType];
}
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag  cacheType:(MysticCacheType)cacheType;
{
    return [self setImage:image layerLevel:0 tag:tag type:MysticImageTypeJPG cacheType:cacheType];

}

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag;
{
    return [self setImage:image layerLevel:level tag:tag type:MysticImageTypeJPG cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType;
{
    return [self setImage:image layerLevel:level tag:tag type:imgType cacheType:cacheType finishedPath:nil];
    
}
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag  finishedPath:(MysticBlockString)finished;
{
    return [self setImage:image layerLevel:level tag:tag type:MysticImageTypeJPG finishedPath:finished];
}
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag  finished:(MysticBlock)finished;
{
    return [self setImage:image layerLevel:level tag:tag type:MysticImageTypeJPG finished:finished];
}

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
{
    return [self setImage:image layerLevel:level tag:tag type:imgType finished:nil];
}

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType finished:(MysticBlock)finished;
{
    return [self setImage:image layerLevel:level tag:tag type:imgType finishedPath:^(NSString *string) {
        if(finished) finished();
    }];
}
+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType finishedPath:(MysticBlockString)finished;
{
    return [self setImage:image layerLevel:level tag:tag type:imgType cacheType:MysticCacheTypeMemoryOrDisk finishedPath:finished];
}
+ (NSString *) setImagePNG:(UIImage *)image tag:(NSString *)tag;
{
    return [self setImage:image layerLevel:0 tag:tag type:MysticImageTypePNG cacheType:MysticCacheTypeProject finishedPath:nil];

}
+ (NSString *) setImage:(UIImage *)image tag:(NSString *)tag;
{
    return [self setImage:image layerLevel:0 tag:tag type:MysticImageTypePNG cacheType:MysticCacheTypeProject finishedPath:nil];
    
}
+ (NSString *) setImagePNG:(UIImage *)image tag:(NSString *)tag cache:(MysticCacheType)cacheType;
{
    return [self setImage:image layerLevel:0 tag:tag type:MysticImageTypePNG cacheType:cacheType finishedPath:nil];
}

+ (NSString *) setImage:(UIImage *)image layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType finishedPath:(MysticBlockString)finished;
{
    tag = tag ? tag : @"photo";
    float w = CGImageGetWidth(image.CGImage);
    float h = CGImageGetHeight(image.CGImage);
    NSString *imgName = [self cacheKeyForSize:CGSizeMake(w, h) layerLevel:level tag:tag type:imgType];
    return [self cacheImage:image name:imgName type:imgType cacheType:cacheType finishedPath:finished];
}

+ (UIImage*) getImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
{
    return [self getImageForSize:size layerLevel:level tag:tag type:MysticImageTypeUnknown cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (UIImage*) getImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
{
    return [self getImageForSize:size layerLevel:level tag:tag type:imgType cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (UIImage*) getImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType  cacheType:(MysticCacheType)cacheType;
{
    NSString *imgName = [self cacheKeyForSize:size layerLevel:level tag:tag type:imgType];
    return [self cacheImageNamed:imgName cacheType:cacheType];
}

+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
{
    return [UserPotionManager getProjectImageForSize:size layerLevel:level tag:tag type:MysticImageTypeUnknown cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
{
    return [UserPotionManager getProjectImageForSize:size layerLevel:level tag:tag type:imgType cacheType:MysticCacheTypeMemoryOrDisk];
}

+ (UIImage*) getProjectImageForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType;
{
    NSString *imgName = [self cacheKeyForSize:size layerLevel:level tag:tag type:imgType];
    
    return [self cacheProjectImageNamed:imgName cacheType:cacheType];
}
+ (NSString*) cacheKeyForSize:(CGSize)size tag:(NSString *)tag;
{
    return [UserPotionManager cacheKeyForSize:size layerLevel:0 tag:tag type:MysticImageTypeUnknown];

}
+ (NSString*) cacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
{
    return [UserPotionManager cacheKeyForSize:size layerLevel:level tag:tag type:MysticImageTypeUnknown];
}
+ (NSString*) cacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag type:(MysticImageType)imgType;
{
    tag = tag ? tag : @"photo";
    return [NSString stringWithFormat:@"%@__%2.0fx%2.0f%@%@", tag, size.width, size.height, [NSString stringWithFormat:@"%@%@", level > 0 ? @"-" : @"", level > 0 ? @(level) : @""], imgType == MysticImageTypePNG ? @".png" : @".jpg"];
}

+ (NSString*) memcacheKeyForSize:(CGSize)size layerLevel:(int)level tag:(NSString *)tag;
{
    NSString *cacheKey = [self cacheKeyForSize:size layerLevel:level tag:tag];
    return [[MysticCache imageCache] cachePathForKey:cacheKey];
}



#pragma mark -
#pragma mark Image Caching
+ (NSString *) cachePathForKey:(NSString *)key cacheType:(MysticCacheType)cacheType;
{
    return [[MysticCache cacheType:cacheType] cachePathForKey:key];
}
+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed type:(MysticImageType)imgType finishedPath:(MysticBlockString)finished;
{
    return [self cacheImage:imageToCache name:imageNamed type:imgType cacheType:MysticCacheTypeMemoryOrDisk finishedPath:finished];
}
+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed type:(MysticImageType)imgType cacheType:(MysticCacheType)cacheType finishedPath:(MysticBlockString)finished;
{
    __unsafe_unretained __block SDImageCache *cache = [MysticCache cacheType:cacheType];
    __unsafe_unretained __block NSString *cachePath = [[cache cachePathForKey:imageNamed] retain];
    __unsafe_unretained __block MysticBlockString __finished = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block UIImage *__imageToCache = imageToCache ? [imageToCache retain] : nil;
    
    
    if(!imageNamed)
    {
        if(__finished) { __finished(cachePath); Block_release(__finished); }
        if(__imageToCache) [__imageToCache release];
        return [cachePath autorelease];
    }
//    if(cacheType == MysticCacheTypeProject && ![imageNamed hasPrefix:[NSString stringWithFormat:@"%@-", [UserPotion potion].uniqueTag]])
//    {
//        imageNamed = [imageNamed prefix:[NSString stringWithFormat:@"%@-", [UserPotion potion].uniqueTag]];
//    }
    
    
    mdispatch_high(^{
        if (__imageToCache)
        {
            BOOL toDisk = [MysticCache canSaveToDisk:cacheType];
            BOOL toMemory = [MysticCache canSaveToMemory:cacheType];
            if(imgType == MysticImageTypeJPG)
            {
                
                if(toDisk)
                {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if (![fileManager fileExistsAtPath:cache.diskCachePath])
                    {
                        [fileManager createDirectoryAtPath:cache.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                    }
                    
                    NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];

                    [UIImageJPEGRepresentation(__imageToCache, 1) writeToFile:cachePath atomically:NO];
                    [p drain];

                }
                else
                {
                    [cache storeImage:imageToCache imageData:nil forKey:imageNamed toDisk:toDisk toMemory:toMemory finished:__finished];
                }
                

                dispatch_async(dispatch_get_main_queue(), ^{
                    if(__finished) { __finished(cachePath); Block_release(__finished); }
                    if(__imageToCache) [__imageToCache release];
                    [cachePath release];

                    
                });
            }
            else if(imgType==MysticImageTypePNG)
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [cache storeImage:__imageToCache imageData:UIImagePNGRepresentation(imageToCache) forKey:imageNamed toDisk:toDisk toMemory:toMemory finished:__finished];
                    Block_release(__finished);
                    if(__imageToCache) [__imageToCache release];
                    [cachePath release];


                });
                
            }
            else if(imgType==MysticImageTypeJPNG)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cache storeImage:__imageToCache imageData:UIImageJPNGRepresentation(imageToCache, 1) forKey:imageNamed toDisk:toDisk toMemory:toMemory finished:__finished];
                    Block_release(__finished);
                    if(__imageToCache) [__imageToCache release];
                    [cachePath release];
                });
            }
        }
    });
    return cachePath;
}

+ (NSString *)cacheImage:(UIImage *)imageToCache name:(NSString *)imageNamed level:(int)level type:(MysticImageType)imgType finished:(MysticBlock)finished;
{
    NSString *cachePath = nil;
    if(!imageNamed)
    {
        
        if(finished) finished();
        return nil;
    }
    
        if (imageToCache)
        {
                if(imgType == MysticImageTypeJPG)
                {
                    [[MysticCache imageCache] storeImage:imageToCache forKey:imageNamed];
                    
                    cachePath = [[MysticCache imageCache] cachePathForKey:imageNamed];
                }
                else if(imgType==MysticImageTypePNG)
                {
                    [[MysticCache imageCache] storeImage:imageToCache forKey:imageNamed];
                    cachePath = [[MysticCache imageCache] cachePathForKey:imageNamed];
                }
                
                if(finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finished();
                    });
                }
            
        }
    return cachePath;
}



+ (UIImage*)cacheImageNamed:(NSString *)imageNamed;
{
    return [UserPotionManager cacheImageNamed:imageNamed cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (UIImage*)cacheImageNamed:(NSString *)imageNamed cacheType:(MysticCacheType)cacheType;
{
    SDImageCache *cache = [MysticCache cacheType:cacheType];
    return [cache cacheImageNamed:imageNamed];
    
}
+ (UIImage*)cacheProjectImageNamed:(NSString *)imageNamed;
{
    return [UserPotionManager cacheProjectImageNamed:imageNamed cacheType:MysticCacheTypeMemoryOrDisk];
}
+ (UIImage*)cacheProjectImageNamed:(NSString *)imageNamed cacheType:(MysticCacheType)cacheType;
{
    SDImageCache *cache = [MysticCache cacheType:cacheType];
    return [cache cacheImageNamed:imageNamed];
}
+ (void) cacheImageNamed:(NSString *)imageNamed done:(MysticBlockImage)done;
{
    if(imageNamed)
    {
        [[MysticCache imageCache] queryDiskCacheForKey:imageNamed done:^(UIImage *image, SDImageCacheType cacheType) {
            if(done) done(image);
        }];
         return;
    }
    if(done) done(nil);
    
}


+ (UIImage*)cacheImageWithTag:(NSString *)tag;
{
    if(tag)
    {
        NSError *error;
        @try
        {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *directory = [[UserPotionManager imagePath] stringByAppendingString:@"/"];
            NSError *error = nil;
            for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
                
                if([file hasPrefix:[NSString stringWithFormat:@"render-%@", tag]])
                {
                    return [[[UIImage alloc] initWithContentsOfFile:file] autorelease];
                }
            }
        }
        @catch (NSException *exception) {
            DLog(@"ERROR - UserPotionManager (cacheImageWithTag): %@", [error description]);
        }
    }
    return nil;
}

+ (UIImage*)cacheProjectImageWithTag:(NSString *)tag;
{
    if(tag)
    {
        NSError *error;
        @try
        {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *directory = [[MysticCache projectCache].diskCachePath stringByAppendingString:@"/"];
            NSError *error = nil;
            for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
                
                if([file hasPrefix:[NSString stringWithFormat:@"render-%@", tag]])
                {
                    return [[[UIImage alloc] initWithContentsOfFile:file] autorelease];
                }
            }
        }
        @catch (NSException *exception) {
            DLog(@"ERROR - UserPotionManager (cacheImageWithTag): %@", [error description]);
        }
    }
    return nil;
}




+ (NSString *) pathForImageNamed:(NSString *)filename;
{
    return [[UserPotionManager imagePath] stringByAppendingFormat:@"/%@", filename];
}

+ (NSString *) pathForProjectImageNamed:(NSString *)filename;
{
    return [[UserPotionManager projectPath] stringByAppendingFormat:@"/%@", filename];
}



+ (NSString *) projectPath;
{
    return [MysticCache projectCache].diskCachePath;
}


+ (NSString *) imagePath;
{
    return [MysticCache imageCache].diskCachePath;
}

+ (BOOL) hasImagesWithTagPrefix:(NSString *)tag;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [[UserPotionManager imagePath] stringByAppendingString:@"/"];
    
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            if([file hasPrefix:tag])
            {
                return YES;
            }
    }
    return NO;
}

+ (BOOL) clearCachedFilesWithTag:(NSString *)tag;
{
    int i = 0;
    return [self clearCachedFilesWithTags:[NSArray arrayWithObject:tag] count:&i files:nil];
}

+ (BOOL) clearCachedFilesWithTags:(NSArray *)tags;
{
    int i = 0;
    return [self clearCachedFilesWithTags:tags count:&i files:nil];

}
+ (BOOL) clearCachedFilesWithTags:(NSArray *)tags count:(int *)c files:(NSMutableArray *)files;
{
    BOOL success = NO;
    NSError *error;
    int x = 0;
    @try
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *directory = [[UserPotionManager imagePath] stringByAppendingString:@"/"];
        
        
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            for (NSString *tag in tags) {
                if([file hasPrefix:tag] && [fm fileExistsAtPath:[NSString stringWithFormat:@"%@%@", directory, file]])
                {
                    error = nil;
                    success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
                    if (!success || error != nil) {
                        DLog(@"UserPotionManager ERROR: There was an error removing: %@", [NSString stringWithFormat:@"%@%@", directory, file]);
                        DLog(@"UserPotionManager ERROR: %@", error.debugDescription);
                    }
                    else
                    {
                        x++;
                        if(files)
                        {
                            [files addObject:[NSString stringWithFormat:@"%@%@", directory, file]];
                        }
                    }
                }
            }
        }
        
        
        directory = [[UserPotionManager projectPath] stringByAppendingString:@"/"];
        
        NSError *error2 = nil;

        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error2]) {
            for (NSString *tag in tags) {
                if([file hasPrefix:tag] && [fm fileExistsAtPath:[NSString stringWithFormat:@"%@%@", directory, file]])
                {
                    error2 = nil;
                    success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error2];
                    if (!success || error2 != nil) {
                        DLog(@"UserPotionManager ERROR: There was an error removing project file: %@", [NSString stringWithFormat:@"%@%@", directory, file]);
                        DLog(@"UserPotionManager ERROR: %@", error2.debugDescription);
                    }
                    else
                    {
                        x++;
                        if(files)
                        {
                            [files addObject:[NSString stringWithFormat:@"%@%@", directory, file]];
                        }
                    }
                }
            }
        }
        
        
    }
    @catch (NSException *exception) {
        DLog(@"ERROR - UserPotionManager (clearCachedFiles): %@", [error description]);
        success = NO;
    }
    
    *c = x;
    return success;
}


+ (BOOL) clearCachedFiles;
{
    BOOL success = NO;
    NSError *error;
    @try
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *directory = [[UserPotionManager imagePath] stringByAppendingString:@"/"];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
            if (!success || error) {
                // it failed.
                DLog(@"there was error removing: %@", [NSString stringWithFormat:@"%@%@", directory, file]);
            }
        }
        
        directory = [[UserPotionManager projectPath] stringByAppendingString:@"/"];
        NSError *error2 = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error2]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error2];
            if (!success || error2) {
                // it failed.
                DLog(@"there was error removing: %@", [NSString stringWithFormat:@"%@%@", directory, file]);
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"ERROR - UserPotionManager (clearCachedFiles): %@", [error description]);
        success = NO;
    }
    return success;
}

+ (NSString *) cachePath;
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"mystic"];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return cachePath;
}

@end

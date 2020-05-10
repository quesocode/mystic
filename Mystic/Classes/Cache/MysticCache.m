//
//  MysticCache.m
//  Mystic
//
//  Created by travis weerts on 9/18/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticCache.h"
#import "MysticCacheImage.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageCompat.h"
#import "JPNG.h"
#import "MysticUser.h"


@implementation MysticCache

+ (SDImageCache *) cache; { return [SDImageCache sharedImageCache]; }
+ (BOOL)canSaveToDisk:(MysticCacheType)cacheType;
{
    if(cacheType == MysticCacheTypeMemory) return NO;
//    switch (cacheType) {
//        
//        default:
//            break;
//    }
    return YES;
}
+ (BOOL)canSaveToMemory:(MysticCacheType)cacheType;
{
    if(cacheType == MysticCacheTypeDisk) return NO;
    switch (cacheType) {
        case MysticCacheTypeProject:
        case MysticCacheTypeLayer: return NO;
        default: break;
    }
    
    return YES;
}

+ (SDWebImageManager *) uiManager;
{
    static dispatch_once_t oncem1;
    static SDWebImageManager* ui_Minstance;
    dispatch_once(&oncem1, ^{
        ui_Minstance = [[SDWebImageManager alloc] init];
        [ui_Minstance setImageCache:(id)[MysticCache uiCache]];
    });
    return ui_Minstance;
}

+ (SDWebImageManager *) layerManager;
{
    static dispatch_once_t oncem124;
    static SDWebImageManager* ui_Minstance23;
    dispatch_once(&oncem124, ^{
        ui_Minstance23 = [[SDWebImageManager alloc] init];
        [ui_Minstance23 setImageCache:(id)[MysticCache layerCache]];
    });
    return ui_Minstance23;
}
+ (SDWebImageManager *) webManager;
{
    return SDWebImageManager.sharedManager;
}
+ (MysticCache *) uiCache;
{
    static dispatch_once_t once12;
    static MysticCache* project_instance2;
    dispatch_once(&once12, ^{
        project_instance2 = [[MysticCache alloc] initWithNamespace:@"ui"];
        project_instance2.mysticCacheType = MysticCacheTypeUI;
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:project_instance2.diskCachePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            DLogError(@"Error: Unable to exclude directory from backup: %@", error);
        }
    });
    return project_instance2;
}
+ (MysticCache *) projectCache;
{
    static dispatch_once_t once1;
    static MysticCache* project_instance;
    dispatch_once(&once1, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *dirPath = [paths[0] stringByAppendingPathComponent:@"project"];
        dirPath = [dirPath stringByAppendingPathComponent:[MysticUser user].currentProjectName];
        project_instance = [[MysticCache alloc] initWithNamespace:@"project" diskCacheDirectory:dirPath];
        project_instance.mysticCacheType = MysticCacheTypeProject;

        MysticFileNameFilter theFilter = ^ NSString * (NSString *key){
            return key;
            //return [NSString stringWithFormat:@"%@.jpg", key];
        };
        [project_instance setFileNameFilter:theFilter];
        
        
    });
    return project_instance;
}
+ (MysticCache *) imageCache;
{
    static dispatch_once_t once2;
    static MysticCache* mystic_instance;
    dispatch_once(&once2, ^{
        mystic_instance = [[MysticCache alloc] initWithNamespace:@"image"];
        mystic_instance.mysticCacheType = MysticCacheTypeImage;

        MysticFileNameFilter theFilter = ^ NSString * (NSString *key){
            return key;

//            return [NSString stringWithFormat:@"%@.jpg", key];
        };
        [mystic_instance setFileNameFilter:theFilter];
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:mystic_instance.diskCachePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            DLogError(@"Error: Unable to exclude imageCache directory from backup: %@", error);
        }
    });
    return mystic_instance;

}
+ (MysticCache *) downloadsCache;
{
    static dispatch_once_t once244;
    static MysticCache* mystic_instance244;
    dispatch_once(&once244, ^{
        mystic_instance244 = [[MysticCache alloc] initWithNamespace:@"downloads"];
        mystic_instance244.mysticCacheType = MysticCacheTypeDownloads;
        MysticFileNameFilter theFilter = ^ NSString * (NSString *key){
            return key ;
        };
        [mystic_instance244 setFileNameFilter:theFilter];
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:mystic_instance244.diskCachePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            DLogError(@"Error: Unable to exclude downloadsCache directory from backup: %@", error);
        }
    });
    return mystic_instance244;
}
+ (MysticCache *) tempCache;
{
    static dispatch_once_t once28;
    static MysticCache* mystic_instance28;
    dispatch_once(&once28, ^{
        mystic_instance28 = [[MysticCache alloc] initWithNamespace:@"temp"];
        mystic_instance28.mysticCacheType = MysticCacheTypeImage;
        MysticFileNameFilter theFilter = ^ NSString * (NSString *key){
            return key && (![key hasSuffix:@".jpg"] && ![key hasSuffix:@".png"] && ![key containsString:@"."]) ? [NSString stringWithFormat:@"%@.jpg", key] : key ;
        };
        [mystic_instance28 setFileNameFilter:theFilter];
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:mystic_instance28.diskCachePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            DLogError(@"Error: Unable to exclude directory from backup: %@", error);
        }
    });
    return mystic_instance28;
}

+ (long long) cacheSizeForAllExceptProject;
{
    long long size = [MysticCache imageCache].getSize;
    size +=[MysticCache tempCache].getSize;
    size +=[MysticCache uiCache].getSize;
    size +=[MysticCache webCache].getSize;
    size +=[MysticCache layerCache].getSize;
    size +=[MysticCache downloadsCache].getSize;

    return size;

}
+ (MysticCacheImage *) layerCache;
{
    return [MysticCacheImage layerCache];
}
+ (SDImageCache *) webCache;
{
    return [SDImageCache sharedImageCache];
}
+ (MysticCache *) cache:(MysticCacheType)type;
{
    return (MysticCache *)[MysticCache cacheType:type];
}
+ (SDImageCache *) cacheType:(MysticCacheType)type;
{
    switch (type) {
        case MysticCacheTypeLayer: return [MysticCacheImage layerCache];
        case MysticCacheTypeWeb: return [MysticCache webCache];
        case MysticCacheTypeTemp: return [MysticCache tempCache];
        case MysticCacheTypeUI: return [MysticCache uiCache];
        case MysticCacheTypeDisk:
        case MysticCacheTypeProject: return [MysticCache projectCache];
        case MysticCacheTypeDownloads: return [MysticCache downloadsCache];

        case MysticCacheTypeMemory:
        case MysticCacheTypeMemoryOrDisk:
        case MysticCacheTypeImage: return [MysticCache imageCache];
        default: break;
    }
    return nil;
}

+ (void) clear:(MysticCacheType)type;
{
    switch (type) {
        case MysticCacheTypeLayer:
            [[MysticCache layerCache] clearMemory];
            [[MysticCache layerCache] clearDisk];
            break;
        case MysticCacheTypeTemp:
            [[MysticCache tempCache] clearMemory];
            [[MysticCache tempCache] clearDisk];
            break;
        case MysticCacheTypeDownloads:
            [[MysticCache downloadsCache] clearMemory];
            [[MysticCache downloadsCache] clearDisk];
            break;
        case MysticCacheTypeWeb:
            [[MysticCache webCache] clearMemory];
            [[MysticCache webCache] clearDisk];
            break;
    
        case MysticCacheTypeDisk:
        case MysticCacheTypeProject:
            [[MysticCache projectCache] clearMemory];
            [[MysticCache projectCache] clearDisk];
            break;
        case MysticCacheTypeMemory:
        case MysticCacheTypeMemoryOrDisk:
        case MysticCacheTypeImage:
            [[MysticCache imageCache] clearMemory];
            [[MysticCache imageCache] clearDisk];
            [[MysticCache tempCache] clearMemory];
            [[MysticCache tempCache] clearDisk];

            break;
        default: break;
    }
}

+ (void) clearMemory;
{
    [[MysticCache projectCache] clearMemory];
    [[MysticCache imageCache] clearMemory];
    [[MysticCache tempCache] clearMemory];
    [[MysticCache downloadsCache] clearMemory];

    [[MysticCache webCache] clearMemory];
    [[MysticCache layerCache] clearMemory];
    [[MysticCache uiCache] clearMemory];
}

+ (void) clearDisk;
{
    [[MysticCache projectCache] clearDisk];
    [[MysticCache imageCache] clearDisk];
    [[MysticCache tempCache] clearDisk];
    [[MysticCache webCache] clearDisk];
    [[MysticCache layerCache] clearDisk];
    [[MysticCache uiCache] clearDisk];
}

+ (void) cleanDisk;
{
    [[MysticCache projectCache] cleanDisk];
    [[MysticCache imageCache] cleanDisk];
    [[MysticCache tempCache] cleanDisk];
    [[MysticCache webCache] cleanDisk];
    [[MysticCache layerCache] cleanDisk];
    [[MysticCache uiCache] cleanDisk];
}

+ (void) clearAll;
{
    [MysticCache clearMemory];
    [MysticCache clearDisk];
}
+ (void) clearAllSafely;
{
    [[MysticCache imageCache] clearMemory];
    [[MysticCache tempCache] clearMemory];
    [[MysticCache webCache] clearMemory];
    [[MysticCache layerCache] clearMemory];
    [[MysticCache uiCache] clearMemory];
    
    [[MysticCache imageCache] clearDisk];
    [[MysticCache tempCache] clearDisk];
    [[MysticCache webCache] clearDisk];
    [[MysticCache layerCache] clearDisk];
    [[MysticCache uiCache] clearDisk];
}
+ (void) cleanAll;
{
    [MysticCache clearMemory];
    [MysticCache cleanDisk];
}

- (void) clearAll;
{
    [self clearMemory];
    [self clearDisk];
}

+ (void) prepareCachesForNewProject;
{
    [[MysticCache tempCache] clearDisk];
    [[MysticCache tempCache] clearMemory];
}


+ (void) clearOldProjectCaches;
{
    [[MysticCache projectCache] clearDisk];
    [[MysticCache projectCache] clearMemory];
}
+ (void) prepareCachesForLaunch;
{
    [[MysticCache imageCache] clearDisk];
    [[MysticCache imageCache] clearMemory];
}

- (UIImage*)cacheImageNamed:(NSString *)imageNamed cacheType:(MysticCacheType *)cacheType;
{
    if (!imageNamed)
    {
        *cacheType = MysticCacheTypeNone; return nil;
    }
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:imageNamed];
    if (image)
    {
        *cacheType = MysticCacheTypeMemory;
        return image;
    }
    UIImage *diskImage = [UIImage decodedImageWithImage:SDScaledImageForPath(imageNamed, [NSData dataWithContentsOfFile:[self cachePathForKey:imageNamed]])];
    if (diskImage)
    {
        *cacheType = MysticCacheTypeDisk;
        return diskImage;
    }
    *cacheType = MysticCacheTypeNone;
    return nil;
}
- (BOOL) deleteAllFiles;
{
    return [[self class] deleteAllFiles:self.diskCachePath tag:nil files:nil];
}
+ (BOOL) deleteAllCacheFiles:(SDImageCache *)cache tag:(NSString *)tag files:(NSMutableArray *)files;
{
    return !cache ? NO : [[self class] deleteAllFiles:cache.diskCachePath tag:tag files:files];
}
+ (BOOL) deleteAllCacheTypeFiles:(MysticCacheType)type tag:(NSString *)tag files:(NSMutableArray *)files;
{
    if(type == MysticCacheTypeProject)
    {
        NSString *dir = [[[self class] cache:type].diskCachePath stringByDeletingLastPathComponent];
        return [[self class] deleteAllFiles:dir withTag:tag files:files];
    }
    return [[self class] deleteAllCacheFiles:[[self class] cache:type] tag:tag files:files];
}
+ (BOOL) deleteAllCacheFiles:(SDImageCache *)cache withTag:(NSString *)tag files:(NSMutableArray *)files;
{
    if([cache isEqual:[MysticCache projectCache]])
    {
        NSString *dir = [cache.diskCachePath stringByDeletingLastPathComponent];
        return [[self class] deleteAllFiles:dir withTag:tag files:files];
    }
    return !cache ? NO : [[self class] deleteAllFiles:cache.diskCachePath withTag:tag files:files];
}
+ (BOOL) deleteAllCacheTypeFiles:(MysticCacheType)type withTag:(NSString *)tag files:(NSMutableArray *)files;
{
    if(type == MysticCacheTypeProject)
    {
        NSString *dir = [[[self class] cache:type].diskCachePath stringByDeletingLastPathComponent];
        return [[self class] deleteAllFiles:dir withTag:tag files:files];
    }
    
    return [[self class] deleteAllCacheFiles:[[self class] cache:type] withTag:tag files:files];
}
+ (BOOL) deleteAllFiles:(NSString *)dir tag:(NSString *)tag files:(NSMutableArray *)files;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [dir hasSuffix:@"/"] ? dir : [dir stringByAppendingString:@"/"];
    NSError *error = nil;
    BOOL success = YES;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        if(tag && [file hasPrefix:tag]) continue;
        success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!(!success || error) && files)  [files addObject:[NSString stringWithFormat:@"%@%@", directory, file]];
    }
    return success;
}
+ (BOOL) deleteAllFiles:(NSString *)dir withTag:(NSString *)tag files:(NSMutableArray *)files;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [dir hasSuffix:@"/"] ? dir : [dir stringByAppendingString:@"/"];
    NSError *error = nil;
    BOOL success = YES;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
//        DLog(@"delete all files 2: %@ %@", tag, file);

        if(tag && ![file hasPrefix:tag]) continue;
        success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!(!success || error) && files)  [files addObject:[NSString stringWithFormat:@"%@%@", directory, file]];
    }
    return success;
}
- (NSString *) description;
{
    switch (self.mysticCacheType) {
        case MysticCacheTypeProject: return @"<MysticCacheTypeProject>";
        case MysticCacheTypeImage: return @"<MysticCacheTypeImage>";
        case MysticCacheTypeLayer: return @"<MysticCacheTypeLayer>";
        case MysticCacheTypeWeb: return @"<MysticCacheTypeWeb>";
        case MysticCacheTypeUI: return @"<MysticCacheTypeUI>";
        default: break;
    }
    return [super description];
}

+ (NSString *) cacheDirectoryPath;
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists) [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return cachePath;
}
@end

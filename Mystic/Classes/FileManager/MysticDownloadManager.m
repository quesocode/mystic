//
//  MysticDownloadManager.m
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticDownloadManager.h"
#import "SDImageCache.h"
#import "SDWebImagePrefetcher.h"
#import "SDWebImageManager.h"

@interface MysticDownloadManager ()
{
    NSInteger _numberOfEffects, _currentQueueIndex;
    NSArray *_downloadQueue;
    BOOL __stopDownloader;
}
@end
@implementation MysticDownloadManager

+ (MysticDownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        __stopDownloader = NO;
        _numberOfEffects = NSNotFound;
        _currentQueueIndex = 0;
    }
    return self;
}

- (NSArray *) imageURLSToDownload;
{
    NSMutableArray *_imgs = [NSMutableArray array];
    NSArray *collections = [NSArray arrayWithObjects:[Mystic core].textures, [Mystic core].texts, [Mystic core].lights, [Mystic core].colorFilters, [Mystic core].badges, [Mystic core].frames, nil];
    for (NSArray *collection in collections) {
        for (PackPotionOption *opt in collection) {
            if(opt.previewURLString) [_imgs addObject:[NSURL URLWithString:opt.previewURLString]];
            if(opt.thumbURLString) [_imgs addObject:[NSURL URLWithString:opt.thumbURLString]];
            if(opt.imageURLString) [_imgs addObject:[NSURL URLWithString:opt.imageURLString]];
        }
    }
    return _imgs;
}
- (NSInteger) numberOfEffects;
{
    if(_numberOfEffects != NSNotFound) return _numberOfEffects;
    
    NSInteger num = 0;
    
    NSDictionary *mainData = [Mystic core].data;
    
    num += [(NSArray *)[mainData objectForKey:@"filters"] count];
    num += [(NSArray *)[mainData objectForKey:@"text"] count];
    num += [(NSArray *)[mainData objectForKey:@"textures"] count];
    num += [(NSArray *)[mainData objectForKey:@"lights"] count];
    num += [(NSArray *)[mainData objectForKey:@"frames"] count];
    if(kEnableShapes)
    {
        num += [(NSArray *)[mainData objectForKey:@"badges"] count];
    }
    
    return num;
}

- (void) downloadEffects:(void (^)(NSUInteger, NSUInteger, BOOL))completionBlock;
{
    
//    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:self.imageURLSToDownload completed:completionBlock];
//
//
    _downloadQueue = [self.imageURLSToDownload retain];
    if(_currentQueueIndex < [_downloadQueue count])
    {
        [self downloadImage:[_downloadQueue objectAtIndex:_currentQueueIndex] block:completionBlock];
    }
    else
    {
        if(completionBlock) completionBlock(_currentQueueIndex, [_downloadQueue count], YES);
    }
    
    
    
    
}

- (void) stopDownloader;
{
    __stopDownloader = YES;
    [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
}

- (void) resumeDownloader;
{
    
    __stopDownloader = NO;
    
}

- (void) resetDownloader;
{
    _currentQueueIndex = 0;
}
- (void) downloadImage:(NSURL *)url block:(void (^)(NSUInteger, NSUInteger, BOOL))block;
{
    @autoreleasepool {
        
    
        if(__stopDownloader) return;
        
        [MysticCache.layerCache clearMemory];
        MysticCache.layerManager.skipStoreDisk = NO;
        [MysticCache.layerManager downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
         
             if(finished)
             {
                 _currentQueueIndex++;
                 if(_currentQueueIndex < [_downloadQueue count])
                 {
                     if(block) block(_currentQueueIndex, [_downloadQueue count], NO);
                     [self downloadImage:[_downloadQueue objectAtIndex:_currentQueueIndex] block:block];
                     
                 }
                 else
                 {
                     if(block) block(_currentQueueIndex, [_downloadQueue count], YES);
                     [_downloadQueue release];
                 }
                 
                 
             }
             
         }];
    }
}


@end

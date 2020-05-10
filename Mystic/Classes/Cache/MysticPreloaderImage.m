//
//  MysticPreloaderImage.m
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticPreloaderImage.h"
#import "MysticCache.h"

@implementation MysticPreloaderImage

+ (MysticPreloaderImage *) sharedPreloader;
{
    static dispatch_once_t once;
    static MysticPreloaderImage* preloader_instance;
    dispatch_once(&once, ^{
        preloader_instance = [[MysticPreloaderImage alloc] init];
        preloader_instance.options = 0;
        preloader_instance.maxConcurrentDownloads = MYSTIC_OPTIONS_PRELOADER_MAX_CONCURRENT_DOWNLOADS;
    });
    return preloader_instance;
}


- (id)init
{
    if ((self = [super init]))
    {
        
        self.maxConcurrentDownloads = 2;
//        self.options = 0;
        self.options = SDWebImageLowPriority;

        self.manager.imageCache = (id)[MysticCache layerCache];
//        [self.manager setImageCache:(id)[MysticCache layerCache]];


    }
    return self;
}


//- (SDWebImageManager *) manager;
//{
//    return [MysticCache layerManager];
//}

@end

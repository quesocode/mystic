//
//  MysticPreloaderImage.h
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "SDWebImagePrefetcher.h"

@interface MysticPreloaderImage : SDWebImagePrefetcher
+ (MysticPreloaderImage *) sharedPreloader;

@end

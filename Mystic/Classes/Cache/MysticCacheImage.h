//
//  MysticCacheImage.h
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "SDImageCache.h"

@interface MysticCacheImage : MysticCache

@property (nonatomic, retain) NSString *nameSpace;
@property (nonatomic, assign) MysticBlockKey keyFilter;
@property (nonatomic, readonly) NSDictionary *imageOptions;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSArray *allKeys;
+ (MysticCacheImage *) layerCache;
+ (MysticImage *) addImage:(id)image options:(MysticCacheImageKey *)options;
- (MysticImage *) setImage:(id)image forKey:(id)key;
- (id) imageForKey:(id)key;
- (id) imageForOptions:(MysticCacheImageKey *)opts;
- (id) optionKey:(MysticOption *)option;

- (void) removeAllImages;
- (id) image:(id)image;
- (id) image:(id)image options:(MysticCacheImageKey *)opts;
- (int) saveImagesForOption:(MysticOption *)option finished:(MysticBlock)finished;
- (NSArray *) imagesForOption:(MysticOption *)option;
- (NSInteger) removeImagesForOption:(MysticOption *)option;
- (void) removeImageForOptionsKey:(id)okey;

@end




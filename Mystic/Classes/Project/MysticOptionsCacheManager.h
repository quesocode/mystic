//
//  MysticOptionsCacheManager.h
//  Mystic
//
//  Created by Me on 8/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@class MysticOptions, MysticOptionsCacheProcess;

@interface MysticOptionsCacheManager : NSObject

@property (nonatomic, readonly) UIImage *currentOptionsImage;
@property (nonatomic, copy) MysticBlockObjObj imageCacheRenderedCompleteBlock;

+ (MysticOptionsCacheManager *) sharedManager;

- (id) objectForKey:(id<NSCopying>)aKey;
- (id) objectForKey:(id<NSCopying>)passTag size:(CGSize)theSize;

- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey;
- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey forSize:(CGSize)imgSize;

- (void) removeObjectForKey:(id<NSCopying>)aKey;
- (BOOL) hasCacheForOptions:(MysticOptions *)thePass;
- (NSString *) storeImage:(UIImage *)theImage forOptions:(MysticOptions *)thePass context:(id)context;
- (void) cacheImage:(UIImage *)theImage forOptions:(MysticOptions *)options;
- (void) queueOptionsForCache:(MysticOptions *)thePass;
- (void) processQueue;
- (void) suspendQueue:(BOOL)val;
- (void) cancelQueue;
- (void) finishedQueueOperation:(MysticOptionsCacheProcess *)operation;
- (void) cancelledQueueOperation:(MysticOptionsCacheProcess *)operation;
- (void) setImageCacheRenderedCompleteBlock:(MysticBlockObjObj)blockValue forOptions:(MysticOptions *)options;
- (id) cachedImageForOptions:(MysticOptions *)options;
- (id) cachedImageForOptions:(MysticOptions *)options size:(CGSize)size;

- (MysticOptions *) cachedSubsetOptionsForOptions:(MysticOptions *)options;
- (NSString *) cachedImagePathForOptions:(MysticOptions *)options;
- (NSString *) cachedImagePathForOptions:(MysticOptions *)options size:(CGSize)size;

@end

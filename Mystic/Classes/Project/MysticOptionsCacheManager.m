//
//  MysticOptionsCacheManager.m
//  Mystic
//
//  Created by Me on 8/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticOptionsCacheManager.h"
#import "Mystic.h"
#import <CommonCrypto/CommonDigest.h>
#import "MysticRenderQueue.h"
#import "MysticOptionsCacheProcess.h"


@interface MysticOptionsCacheManager ()
{
    NSMutableDictionary *_passCache;
    int finishedOperations;
    NSString *_lastRenderedOptionsTag;
}
@end

static int kNumberOfCacheOptionsOperations = 0;

@implementation MysticOptionsCacheManager


+ (MysticOptionsCacheManager *) sharedManager;
{
    static dispatch_once_t myic_once;
    static MysticOptionsCacheManager* mysticic_instance;
    dispatch_once(&myic_once, ^{
        mysticic_instance = [[MysticOptionsCacheManager alloc] init];
        
    });
    return mysticic_instance;
    
}


- (void) dealloc;
{
    [_passCache release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _lastRenderedOptionsTag = nil;
        _passCache = [[NSMutableDictionary alloc] init];
        finishedOperations = 0;
    }
    return self;
}

- (id) objectForKey:(id<NSCopying>)aKey;
{
    return [_passCache objectForKey:aKey];
}

- (id) objectForKey:(id<NSCopying>)passTag size:(CGSize)theSize;
{
    NSString *filePath = nil;
    CGSize smallestFoundSize = CGSizeMake(100000, 100000);
    if([self objectForKey:passTag] != nil && [(NSMutableDictionary *)[self objectForKey:passTag] count])
    {
        if(!CGSizeEqualToSize(CGSizeZero, theSize))
        {
            for (NSValue *imgSizeKey in [(NSMutableDictionary *)[self objectForKey:passTag] allKeys])
            {
                CGSize imgSizeVal = [imgSizeKey CGSizeValue];
                if(CGSizeEqualToSize(theSize, imgSizeVal) || CGSizeLess(theSize, imgSizeVal))
                {
                    NSString *filePath2 = (id)[[self objectForKey:passTag] objectForKey:imgSizeKey];
                    
                    if(!filePath || CGSizeLess(imgSizeVal, smallestFoundSize))
                    {
                        filePath = filePath2;
                        smallestFoundSize = imgSizeVal;
                    }
                    
                    if(CGSizeEqualToSize(theSize, imgSizeVal))
                    {
                        filePath = filePath2;
                        break;
                    }
                }
            }
        }
        else
        {
            CGSize largestSize = CGSizeZero;
            for (NSValue *imgSizeKey in [(NSMutableDictionary *)[self objectForKey:passTag] allKeys])
            {
                CGSize imgSizeVal = [imgSizeKey CGSizeValue];
                
                NSString *filePath2 = (id)[[self objectForKey:passTag] objectForKey:imgSizeKey];
                
                if(!filePath || CGSizeGreater(imgSizeVal, largestSize))
                {
                    filePath = filePath2;
                    largestSize = imgSizeVal;
                }
                
                
            }
        }
    }
    
    return filePath;
}

- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey;
{
    [_passCache setObject:obj forKey:aKey];
}

- (void) setObject:(id)obj forKey:(id<NSCopying>)aKey forSize:(CGSize)imgSize;
{
    
//    NSString *imgSizeKeyStr = [NSString stringWithFormat:@"%2.0fx%2.0f", (float)imgSize.width,(float)imgSize.height];
    NSValue *imgSizeKey = [NSValue valueWithCGSize:imgSize];
    NSMutableDictionary *optionsCachedFiles = [self objectForKey:aKey];
    if(!optionsCachedFiles)
    {
        optionsCachedFiles = [NSMutableDictionary dictionary];
    }
    [optionsCachedFiles setObject:obj forKey:imgSizeKey];
    [self setObject:optionsCachedFiles forKey:aKey];
    
    
}
- (void) removeObjectForKey:(id<NSCopying>)aKey;
{
    [_passCache removeObjectForKey:aKey];
}

- (UIImage *) currentOptionsImage;
{
    return [self cachedImageForOptions:[MysticOptions current]];
}

- (BOOL) hasCacheForOptions:(MysticOptions *)thePass;
{
    BOOL f = NO;
    if([self objectForKey:thePass.tag] != nil)
    {
        if(!CGSizeEqualToSize(CGSizeZero, thePass.size))
        {
            for (NSValue *imgSizeKey in [(NSMutableDictionary *)[self objectForKey:thePass.tag] allKeys])
            {
                CGSize imgSizeVal = [imgSizeKey CGSizeValue];
                if(CGSizeEqualToSize(thePass.size, imgSizeVal) || CGSizeLess(thePass.size, imgSizeVal))
                {
                    f = YES;
                    break;
                }
            }
        }
        else
        {
            f = YES;
        }
    }
    return f;
}



- (void) cacheImage:(UIImage *)theImage forOptions:(MysticOptions *)thePass;
{
    if([[MysticOptionsCacheManager sharedManager] hasCacheForOptions:thePass])
    {
        return;
    }
    [self storeImage:theImage forOptions:thePass context:nil];

}
- (NSString *) storeImage:(UIImage *)theImage forOptions:(MysticOptions *)thePass context:(id)context;
{
    if(!theImage) return nil;
    NSString *passTag = thePass.tag;
    NSInteger passIndex = thePass.index;
    if(thePass.manager) if(passIndex+1 == thePass.manager.numberOfPasses) passTag = thePass.manager.tag;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *_diskCachePath = [paths[0] stringByAppendingPathComponent:@"ch.mysti.render"];
    NSString *imgTag = [NSString stringWithFormat:@"%@---pass-%@.jpg", [MysticOptions current].projectName, MObj(passTag)];
    NSString *cachedKey = [UserPotionManager cacheKeyForSize:thePass.size tag:imgTag];
    NSString *filePath = [[MysticCache projectCache] cachePathForKey:cachedKey];
    @autoreleasepool {
        NSData *data = UIImageJPEGRepresentation(theImage, (CGFloat)1.0);
        if (data)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:_diskCachePath]) [fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
        }
    }
    [self setObject:filePath forKey:passTag forSize:thePass.size];
    return filePath;
}

- (MysticOptions *) cachedSubsetOptionsForOptions:(MysticOptions *)options;
{
    MysticOptions *subset = options.unchangedSubsetOfOptions;
    return subset;
}
- (NSString *) cachedImagePathForOptions:(MysticOptions *)options;
{
    return [self cachedImagePathForOptions:options size:options.size];
}
- (NSString *) cachedImagePathForOptions:(MysticOptions *)options size:(CGSize)size;
{
    NSString *passTag = options.tag;
    NSString *filePath = [self objectForKey:passTag size:size];

    
    
    if(!filePath)
    {
        NSString *imgTag = [NSString stringWithFormat:@"%@---pass-%@", [MysticOptions current].projectName, MObj(passTag)];
        NSString *cachedKey = [UserPotionManager cacheKeyForSize:size tag:imgTag];
        NSString *cachedPath = [[MysticCache projectCache] cachePathForKey:cachedKey];
        if([[NSFileManager defaultManager] fileExistsAtPath:cachedPath])
        {
            filePath = cachedPath;
            [self setObject:filePath forKey:passTag];
        }
    }
    return filePath;
}
- (id) cachedImageForOptions:(MysticOptions *)options;
{
    return [self cachedImageForOptions:options size:options.size];
}
- (id) cachedImageForOptions:(MysticOptions *)options size:(CGSize)size;
{
    MysticImage *img = nil;

    if(options.isEmpty)
    {
        img = [[options sourceImageForSize:size] retain];
    }
    if(!img)
    {
        NSString *filePath = [self cachedImagePathForOptions:options size:size];
        if(filePath)
        {
            
            UIImage *_img  = [UIImage imageWithContentsOfFile:filePath];
            img = [MysticImageRender imageWithImage:_img] ;
            img.imageFilePath = filePath;
            
            
        }
    }
    return img;

}

#pragma mark - Caching Queue
- (void) cancelQueue;
{
//    DLog(@"process operation cancelling: (%d of %d)", finishedOperations, (int)[[MysticOptionsCacheManagerProcessQueue sharedQueue] operationCount]);

//    finishedOperations = 0;

    [[MysticOptionsCacheManagerProcessQueue sharedQueue] cancelAllOperations];
//    DLog(@"process operation cancelled: (%d of %d)", finishedOperations, (int)[[MysticOptionsCacheManagerProcessQueue sharedQueue] operationCount]);

}
- (void) suspendQueue:(BOOL)val;
{
    [[MysticOptionsCacheManagerProcessQueue sharedQueue] setSuspended:val];
}
- (void) queueOptionsForCache:(MysticOptions *)options;
{
    return;
//    
//    if([self hasCacheForOptions:options]) return;
//   
//    [self cancelQueue];
//    
//    MysticOptionsCacheProcess *operation = [[MysticOptionsCacheProcess alloc] init];
//    operation.options = options;
//    operation.manager = self;
//    operation.index = kNumberOfCacheOptionsOperations++;
//    
//    if([operation respondsToSelector:@selector(setName:)])
//    {
//        operation.name = [NSString stringWithFormat:@"%d) %@-%d", (int)[[MysticOptionsCacheManagerProcessQueue sharedQueue] operationCount], options.tag, (int)operation.index];
//    }
////    DLog(@"MysticOptionsCacheManager: Creating render operation: %@: %@", operation.name, options);
//    
//  
//    [[MysticOptionsCacheManagerProcessQueue sharedQueue] addOperation:operation];
//    [operation autorelease];
}
- (void) processQueue;
{
    finishedOperations = 0;
    
    if([MysticOptionsCacheManagerProcessQueue sharedQueue].operationCount)
    {
        MysticOptionsCacheProcess *o = [[MysticOptionsCacheManagerProcessQueue sharedQueue].operations objectAtIndex:0];
        
//        if([MysticUser is:Mk_DEBUG]) DLog(@"Options cache: %@", o.options ? o.options.tag : @"---");
        if([[MysticOptionsCacheManagerProcessQueue sharedQueue] isSuspended])
        {
            [self suspendQueue:NO];
        }
    }
    else
    {
        if(self.imageCacheRenderedCompleteBlock)
        {
            self.imageCacheRenderedCompleteBlock(nil, nil);
            [self setImageCacheRenderedCompleteBlock:nil forOptions:nil];
        }
    }
    
    
}

- (void) finishedQueueOperation:(MysticOptionsCacheProcess *)operation;
{
    
    finishedOperations++;
    NSString *filePath = [self storeImage:operation.image forOptions:operation.options context:operation];
    
    BOOL isLastPass = operation.options.manager && [operation.options isEqual:operation.options.manager.passes.lastObject];
    NSString *lastOptTag = isLastPass ? operation.options.manager.tag : operation.options.tag;
//    if(isLastPass)
//    {
//        if([MysticUser is:Mk_DEBUG]) DLog(@"finished the last operation of the manager: %@", operation.options.manager.tag);
//    }
    
    
    operation.image = nil;
    

    if(_lastRenderedOptionsTag && [lastOptTag isEqualToString:_lastRenderedOptionsTag])
    {
        
        if(self.imageCacheRenderedCompleteBlock)
        {
            UIImage *_img  = [UIImage imageWithContentsOfFile:filePath];
            MysticImageRenderPreview *img = [MysticImageRenderPreview imageWithImage:_img];
            img.imageFilePath = filePath;

            self.imageCacheRenderedCompleteBlock(img, operation.options);
            [self setImageCacheRenderedCompleteBlock:nil forOptions:nil];
        }
        
    }
}

- (void) cancelledQueueOperation:(MysticOptionsCacheProcess *)operation;
{
    finishedOperations++;
    operation.image = nil;
    if(_lastRenderedOptionsTag && [operation.options.tag isEqualToString:_lastRenderedOptionsTag])
    {
        
        if(self.imageCacheRenderedCompleteBlock)
        {
            self.imageCacheRenderedCompleteBlock(operation.image, operation.options);
            [self setImageCacheRenderedCompleteBlock:nil forOptions:nil];
        }
        
    }
}

- (void) setImageCacheRenderedCompleteBlock:(MysticBlockObjObj)blockValue forOptions:(MysticOptions *)options;
{
    self.imageCacheRenderedCompleteBlock = blockValue;
    
    if(_lastRenderedOptionsTag)
    {
        [_lastRenderedOptionsTag release];
        _lastRenderedOptionsTag = nil;
    }
    
    if(options && self.imageCacheRenderedCompleteBlock != nil)
    {
        _lastRenderedOptionsTag = [options.tag retain];
    }
    else
    {
        _lastRenderedOptionsTag = nil;
    }
}

@end

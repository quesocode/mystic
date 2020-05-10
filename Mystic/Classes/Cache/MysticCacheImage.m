//
//  MysticCacheImage.m
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticCacheImage.h"
#import "MysticImage.h"

@interface MysticCacheImage ()
{

}
@property (nonatomic, retain) NSMutableDictionary *allKeysForOptions, *allImageOptions;
@end
@implementation MysticCacheImage

@synthesize
    nameSpace=_nameSpace,
    keyFilter=_keyFilter,
    images=_images,
    allKeys=_allKeys;

+ (MysticCacheImage *) layerCache;
{
    static dispatch_once_t myic_once;
    static MysticCacheImage* mysticic_instance;
    dispatch_once(&myic_once, ^{
        mysticic_instance = [[MysticCacheImage alloc] initWithNamespace:@"layers"];
        MysticBlockKey theFilter = ^ NSString * (id key){
           key = [key isKindOfClass:[MysticCacheImageKey class]] ? [(MysticCacheImageKey *)key cacheKey] : key;
            if([key isKindOfClass:[NSString class]])
            {
                if([(NSString *)key hasSuffix:@"jpng"]) return [[key md5] stringByAppendingString:@".jpng"];
            }
            return [key hasPrefix:@"http"] ? [key md5] : key;
        };
        [mysticic_instance setKeyFilter:theFilter];
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:mysticic_instance.diskCachePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            DLogError(@"Error: Unable to exclude directory from backup: %@", error);
        }
    });
    return mysticic_instance;
    
}

+ (MysticImage *) addImage:(id)image options:(MysticCacheImageKey *)options;
{
    return [[MysticCacheImage layerCache] setImage:image forKey:options];
}
- (id) init;
{
    self = [self initWithNamespace:@"layers"];
    if(self)
    {
        self.allKeysForOptions = [NSMutableDictionary dictionary];
        
        self.allImageOptions = [NSMutableDictionary dictionary] ;

    }
    return self;
}
- (NSDictionary *) imageOptions;
{
    return [NSDictionary dictionaryWithDictionary:self.allImageOptions];
}
- (MysticBlockKey) keyFilter;
{
    return (MysticBlockKey)self.fileNameFilter;
}
- (void) setKeyFilter:(MysticBlockKey)keyFilter;
{
    [self setFileNameFilter:keyFilter];
}

- (MysticImage *) setImage:(id)image forKey:(id)keyOrOptions;
{
    if(!image)
    {
        ErrorLog(@"ERROR: MysticCacheImage: Attempting to store 'nil' for imageKeyOptions: %@", keyOrOptions);
        return nil;
    }
    
    if(!self.allImageOptions) self.allImageOptions = [NSMutableDictionary dictionary];
    if(!self.allKeysForOptions) self.allKeysForOptions = [NSMutableDictionary dictionary];
    
    
    MysticCacheImageKey *theOptions = [keyOrOptions isKindOfClass:[MysticCacheImageKey class]] ? (MysticCacheImageKey *)keyOrOptions : nil;
    
    NSString *key = self.keyFilter(keyOrOptions);
    MysticImage *mImage = [self image:image options:theOptions];
    mImage.cacheKey = key;
    theOptions = theOptions ? theOptions : mImage.info;
    
    [self.allImageOptions setObject:theOptions forKey:key];
    if(theOptions && theOptions.option)
    {
        NSString *optionKey = [self optionKey:theOptions.option];
        
        NSMutableArray *keys = [self.allKeysForOptions objectForKey:optionKey] ? [self.allKeysForOptions objectForKey:optionKey] : [NSMutableArray array];
        [keys addObject:key];
        if(![self.allKeysForOptions objectForKey:optionKey]) [self.allKeysForOptions setObject:keys forKey:optionKey];
        
    }

//    DLog(@"save image options cache: %@", keyOrOptions);
    [mImage saveToCache];
    return mImage;
}

- (id) optionKey:(MysticOption *)option;
{
    NSString *optionKey = [NSString stringWithFormat:@"%@<%p>", option.tag, option];

    NSMutableArray *ak = [NSMutableArray array];
    [ak addObjectsFromArray:self.allKeysForOptions.allKeys];
    if(optionKey)
    {
        for (NSString *okey in ak) {
            if([okey isEqualToString:optionKey]) return okey;
        }
    }
    return optionKey;
}
- (id) image:(id)image;
{
    return [self image:image options:nil];
}
- (id) image:(id)image options:(MysticCacheImageKey *)opts;
{
    if(!image) return nil;
    MysticImage *mImage = (MysticImage *)image;
    if(![mImage isKindOfClass:[MysticImage class]])
    {
        if([mImage respondsToSelector:@selector(CGImage)])
        {
            MysticImage *newImage = [[MysticImage alloc] initWithCGImage:[mImage CGImage]];
            newImage.info = opts;
            mImage = newImage;
        }
    }
    else
    {
        if(opts) mImage.info = opts;

        [mImage retain];
    }
    mImage.cache = mImage.cache ? mImage.cache : self;
    return [mImage autorelease];
}
- (id) imageForOptions:(MysticCacheImageKey *)okey;
{
    MysticCache *theCache = [okey isKindOfClass:[MysticCacheImageKey class]] ? [(MysticCacheImageKey *)okey cache] : self;
    id key = self.keyFilter(okey);
    UIImage *img ;
    MysticCacheType cacheType = MysticCacheTypeNone;
    if([theCache respondsToSelector:@selector(cacheImageNamed:cacheType:)])
    {
        img = [theCache cacheImageNamed:key cacheType:&cacheType];
    }
    else
    {
        img = [theCache cacheImageNamed:key];
    }
    
    if(!img)
    {
        img = [[MysticCacheImage layerCache] cacheImageNamed:key cacheType:&cacheType];
    }
    if(!img) return nil;
    MysticImage *returnImg = [MysticImage image:img options:okey];
    returnImg.cacheType = cacheType;
    returnImg.fromCache = cacheType != MysticCacheTypeNone;
//    ImageCacheLog(@"MysticCacheImage: imageForOptions: \r\n\tName: %@\r\n\tOptions: %@\r\n\tCache: %@\r\n\tOptions Cache: %@\r\n\tCache IMAGE: %@\r\n\tmImage: %@\r\n\r\n", okey.name,  okey, theCache, okey.cache, img, returnImg);
    
    return returnImg;
}
- (id) imageForKey:(id)okey;
{
    MysticCacheImageKey *theOptions = [okey isKindOfClass:[MysticCacheImageKey class]] ? okey : nil;
    MysticCache *theCache = theOptions ? [theOptions cache] : [MysticCacheImage layerCache];
    
    id key = self.keyFilter(okey);
    
    
    UIImage *img;
    
    MysticCacheType cacheType = MysticCacheTypeNone;
    if([theCache respondsToSelector:@selector(cacheImageNamed:cacheType:)])
    {
        img = [theCache cacheImageNamed:key cacheType:&cacheType];
    }
    else
    {
        img = [theCache cacheImageNamed:key];
    }
    
    
    if(!img)
    {
        img = [[MysticCacheImage layerCache] cacheImageNamed:key cacheType:&cacheType];
    }
    MysticCacheImageKey *options = [self.imageOptions objectForKey:self.keyFilter(key)];
    
    MysticImage *returnImg = [MysticImage image:img options:options];
    returnImg.cacheType = cacheType;
    returnImg.fromCache = cacheType != MysticCacheTypeNone;
    
    return returnImg;
}

- (void) removeImageForOptionsKey:(id)okey;
{
    
    
    
    MysticCacheImageKey *theOptions = [okey isKindOfClass:[MysticCacheImageKey class]] ? okey : nil;
    MysticCache *theCache = theOptions ? [theOptions cache] : [MysticCacheImage layerCache];
    
    id key = self.keyFilter(okey);
    
    MysticCacheType cacheType = MysticCacheTypeNone;
    [theCache removeImageForKey:key];
}

- (void) removeAllImages;
{
    
    
    [self clearMemory];
    [self.allImageOptions removeAllObjects];
    [self.allKeysForOptions removeAllObjects];
}

- (NSArray *) imagesForOption:(MysticOption *)option;
{
    if(self.allKeysForOptions.count)
    {
        NSString *optionKey = [self optionKey:option];
        if([self.allKeysForOptions objectForKey:optionKey])
        {
            NSArray *keys = [self.allKeysForOptions objectForKey:optionKey];

            NSMutableArray *__images = [NSMutableArray arrayWithCapacity:keys.count];
            for (NSString *key in keys) {
                MysticCacheImageKey *optionsForKey = [self.allImageOptions objectForKey:key];
                MysticImage *img = [self imageForKey:optionsForKey];
//                DLog(@"looking up image for key: \n\t Key: %@ \n\t Image: %@ \n\t saveToDisk: %@", key, ILogStr(img), MBOOL(img.saveToDisk));

                if(img)
                {
                    [__images addObject:img];
                }
            }
            return __images;
        }
    }
    return [NSArray array];
}

- (NSInteger) removeImagesForOption:(MysticOption *)option;
{
    
    
    
    
    NSInteger c = 0;
    if(self.allKeysForOptions.count)
    {
        NSString *optionKey = [self optionKey:option];
        if([self.allKeysForOptions objectForKey:optionKey])
        {
            NSArray *keys = [self.allKeysForOptions objectForKey:optionKey];
            
            for (NSString *key in keys) {
                MysticCacheImageKey *optionsForKey = [self.allImageOptions objectForKey:key];
                MysticImage *img = [self imageForKey:optionsForKey];
                //                DLog(@"looking up image for key: \n\t Key: %@ \n\t Image: %@ \n\t saveToDisk: %@", key, ILogStr(img), MBOOL(img.saveToDisk));
                
                if(img)
                {
                    [self removeImageForOptionsKey:(id)optionsForKey];
                    c++;
                }
                [self.allImageOptions removeObjectForKey:key];
            }
        }
    }
    return c;
}
- (int) saveImagesForOption:(MysticOption *)option finished:(MysticBlock)finished;
{
    
    
    NSArray *_cachedImages = [self imagesForOption:option];
    int i = 0;
    for (MysticImage *imgObj in _cachedImages)
    {
        if(imgObj.saveToDisk) i++;
        [imgObj saveToCache];
    }
    if(finished) finished();
    return i;
}
- (MysticCacheType) mysticCacheType;
{
    return MysticCacheTypeLayer;
}

- (NSString *) debugDescription;
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"MysticCacheImage <%p>: ", self];
    
    
    [str appendFormat:@"\n\n Options: %lu \n", (unsigned long)self.allKeysForOptions.count];
    int i = 1;
    NSArray *aks = self.allKeysForOptions.allKeys;
    for (id key in aks) {
        [str appendFormat:@"\n\t %d: %@  Keys: %lu", i, key, (unsigned long)[(NSArray *)[self.allKeysForOptions objectForKey:key] count]];
        i++;
    }
    
    [str appendFormat:@"\n\n Image Options: %lu \n", (unsigned long)self.allImageOptions.count];
    i = 1;
    NSArray *aiks = self.allImageOptions.allKeys;

    for (id key in aiks) {
        MysticCacheImageKey *io = [self.allImageOptions objectForKey:key];
        [str appendFormat:@"\n\t %d: %@  (%@)", i, io, io.cache];
        i++;
    }
    
    [str appendString:@" \n\n ---- \n\n"];
    return str;
}

- (NSString *) description;
{
    return @"<MysticCacheTypeLayer>";
}

@end

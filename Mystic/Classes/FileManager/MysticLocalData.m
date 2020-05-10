//
//  MysticDownloadManager.m
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLocalData.h"
#import "SDImageCache.h"
#import "SDWebImagePrefetcher.h"
#import "SDWebImageDownloader.h"
#import "SDWebImageManager.h"
#import "MysticCache.h"
#import "NSString+Mystic.h"
#import "JPNG.h"
#import "MysticConfigManager.h"
#import "NSDictionary+Merge.h"

@interface MysticLocalData ()
{
   
}
@property (nonatomic, retain) SDWebImagePrefetcher *downloader;
@end
@implementation MysticLocalData

+ (instancetype) manager;
{
    static dispatch_once_t pred;
    static MysticLocalData *sharedManager = nil;
    
    dispatch_once(&pred, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}
+ (void) data:(MysticDictionary *)dataInput finished:(MysticBlockObject)finished;
{
    MysticLocalData *manager = [MysticLocalData manager];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[[dataInput copy] autorelease]];
    manager.data = data;
    manager.finished = finished;
    manager.packs = [NSMutableDictionary dictionary];
    NSMutableDictionary *layers = [NSMutableDictionary dictionary];
    NSMutableArray *keys = [NSMutableArray array];

    [layers setObject:dataInput[@"textures"] forKey:@"textures"];
    [layers setObject:dataInput[@"text"] forKey:@"text"];
    [layers setObject:dataInput[@"filters"] forKey:@"filters"];
    [layers setObject:dataInput[@"frames"] forKey:@"frames"];
    [layers setObject:dataInput[@"lights"] forKey:@"lights"];
    [layers setObject:dataInput[@"badges"] forKey:@"badges"];
    for (NSString *key in [dataInput[@"badges"] allKeys]) [keys addObject:@{@"key":key, @"type":@"badges"}];
    for (NSString *key in [dataInput[@"filters"] allKeys]) [keys addObject:@{@"key":key, @"type":@"filters"}];
    for (NSString *key in [dataInput[@"frames"] allKeys]) [keys addObject:@{@"key":key, @"type":@"frames"}];
    for (NSString *key in [dataInput[@"lights"] allKeys]) [keys addObject:@{@"key":key, @"type":@"lights"}];
    for (NSString *key in [dataInput[@"text"] allKeys]) [keys addObject:@{@"key":key, @"type":@"text"}];
    for (NSString *key in [dataInput[@"textures"] allKeys]) [keys addObject:@{@"key":key, @"type":@"textures"}];

    [[MysticCache cache] clearDisk];
    [[MysticCache cache] clearMemory];

    DLogDebug(@"localizing setData: %ld", (unsigned long)dataInput.count);
    manager.layers = layers;
    manager.keys = keys;
    manager.finishedKeys = [NSMutableArray arrayWithArray:[[keys copy] autorelease]];
    [manager nextLayer];
//    if(finished) finished(data);
}
- (instancetype) init;
{
    self = [super init];
    if(self)
    {
        _downloadImage = YES;
        _downloadMask = YES;
        _downloadOriginal = YES;
        _downloadThumb = YES;
        _downloadPreview = NO;
    }
    return self;
}
- (void) nextLayer;
{
    if(!self.currentKey) self.currentKey = [self.finishedKeys firstObject];
    else
    {
        [self.finishedKeys removeObjectAtIndex:0];
        if(self.finishedKeys.count == 0)
        {
            self.currentKey = nil;
            self.keys = nil;
            self.layers = nil;
#ifdef MYSTIC_MAKE_CONFIG_LOCAL_PACKS_FILTERS_PLIST
            for (NSString *packName in self.packs.allKeys) {
                NSString *f = [[(MysticCache *)[MysticCache cache:MysticCacheTypeTemp] diskCachePath] hasSuffix:@"/"] ? @"" : @"/";
                f = [NSString stringWithFormat:@"%@%@", [(MysticCache *)[MysticCache cache:MysticCacheTypeTemp] diskCachePath], [f suffix:[packName suffix:@"/"]]];
                
                NSMutableDictionary *pack = [NSMutableDictionary dictionary];
                NSDictionary *dataPack = self.data[@"packs"][packName];
                if(dataPack) [pack setObject:dataPack forKey:@"pack"];
                pack = [pack makeMutable];
                [pack setObject:[self.packs objectForKey:packName] forKey:@"layers"];
                [pack writeToFile:[NSString stringWithFormat:@"%@filters.plist",f] atomically:NO];
                DLogSuccess(@"Localize Finished Pack: \n%@", [NSString stringWithFormat:@"%@filters.plist",f]);

            }
#endif
#ifdef MYSTIC_MAKE_CONFIG_LOCAL_FILTERS_PLIST
            if(self.finished)
            {
                [self.data writeToFile:[NSString stringWithFormat:@"%@/filters.plist",[MysticConfigManager configDirPath]] atomically:NO];
                DLog(@"  ");
                DLogSuccess(@"Localize Finished: \n%@", [NSString stringWithFormat:@"%@/filters.plist",[MysticConfigManager configDirPath]]);
                self.finished(self.data);
                self.data = nil;
                self.finishedKeys = nil;
                self.urls = nil;
                self.currentKey=nil;
                self.typeKey=nil;
                [[MysticCache cache] clearDisk];
                [[MysticCache cache] clearMemory];
            }
#endif
            DLogError(@"Finished localizing...");
            
            return;
        }
        self.currentKey = [self.finishedKeys firstObject];
    }
    self.typeKey = self.currentKey[@"type"];
    self.currentKey = self.currentKey[@"key"];
    
    NSDictionary *layersDict = self.layers[self.typeKey];
    NSDictionary *layerDict = [layersDict objectForKey:self.currentKey];
    [[MysticCache cache] clearMemory];
    [self layer:[NSMutableDictionary dictionaryWithDictionary:layerDict]];
}
- (void) layer:(NSMutableDictionary *)layer;
{
    self.urls = [NSMutableDictionary dictionary];
    NSMutableArray *urls = [NSMutableArray array];
    NSString *imageName = [layer[@"image"] lowercaseString];
    if(!layer[@"image"] && layer[@"jpng_big_url"])
    {
        imageName = (NSString *)layer[@"jpng_big_url"];
        imageName = [imageName lastPathComponent];
    }
    
    NSArray *comps = [imageName componentsSeparatedByString:@"."];
    NSString *ext = [comps.lastObject lowercaseString];
    ext = ext && ext.length ? ext : @"jpg";
    NSString *imgFileName = [NSString stringWithFormat:@"%@.%@", self.currentKey, ext];
//    imageName = comps.firstObject;
    BOOL isJPNG = NO;
    imageName = self.currentKey;
    
    NSDictionary *tags = layer[@"tags"];
    NSString *tag = nil;
    if(tags.count > 1)
    {
        for (NSString *tagKey in [tags allKeys]) {
            NSDictionary *tagInfo = tags[tagKey];
            if([tagInfo[@"primary"] boolValue])
            {
                tag = tagKey;
                break;
            }
        }
        
    }
    NSString *primaryTag = [[tag copy] autorelease];
    if(!tag) tag = [[tags allKeys] firstObject];
    
    if(!tag)
    {
        NSDictionary *dataPacks = self.data[@"packs"];
        for (NSString *packKey in dataPacks.allKeys) {
            NSDictionary *packData = dataPacks[packKey];
            NSArray *packLayers = packData[@"layers"];
            for (NSString *packLayerKey in packLayers) {
                if([packLayerKey isEqualToString:self.currentKey])
                {
                    tag = packLayerKey;
                    break;
                }
            }
            if(tag) break;
        }
    }
    if(tag)
    {
        if(![self.packs objectForKey:tag]) [self.packs setObject:[NSMutableDictionary dictionary] forKey:tag];
    }
    if(!tag) tag = @"unknown";
    imageName = [imageName prefix:[tag suffix:@"__"]];
    
    BOOL noJPNG = !(self.downloadImage && layer[@"jpng_big_url"] && [(NSString *)layer[@"jpng_big_url"] length] > 0);
    if(self.downloadOriginal && layer[@"image_url"] && layer[@"original_fileurl"] && noJPNG && ![(NSString *)layer[@"original_fileurl"] isEqualToString:layer[@"image_url"]])
    {
        NSString *_ext = [[layer[@"original_fileurl"] lastPathComponent] pathExtension];
        [urls addObject:[NSURL URLWithString:layer[@"original_fileurl"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"original",@"name":[NSString stringWithFormat:@"%@__%@___original.%@",self.typeKey, imageName, _ext]} forKey:layer[@"original_fileurl"]];
    }

    if(self.downloadImage && layer[@"image_url"] && noJPNG){
        NSString *_ext = [[layer[@"image_url"] lastPathComponent] pathExtension];
        [urls addObject:[NSURL URLWithString:layer[@"image_url"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"image",@"name":[NSString stringWithFormat:@"%@__%@.%@", self.typeKey, imageName, _ext]} forKey:layer[@"image_url"]];

    }
    if(self.downloadImage && !noJPNG){
        [urls addObject:[NSURL URLWithString:layer[@"jpng_big_url"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"image",@"name":[NSString stringWithFormat:@"%@__%@.%@", self.typeKey, imageName, @"jpng"]} forKey:layer[@"jpng_big_url"]];
        isJPNG = YES;
    }
    if(self.downloadPreview && layer[@"preview_url"] && layer[@"image_url"] && ![(NSString *)layer[@"image_url"] isEqualToString:layer[@"preview_url"]]) {
        NSString *_ext = [[layer[@"preview_url"] lastPathComponent] pathExtension];
        [urls addObject:[NSURL URLWithString:layer[@"preview_url"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"preview",@"name":[NSString stringWithFormat:@"%@__%@___preview.%@", self.typeKey, imageName, _ext]} forKey:layer[@"preview_url"]];

    }
    if(self.downloadThumb && layer[@"thumb_url"] && ![self.typeKey isEqualToString:@"filters"]) {
        NSString *_ext = [[layer[@"thumb_url"] lastPathComponent] pathExtension];
        [urls addObject:[NSURL URLWithString:layer[@"thumb_url"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"thumb",@"name":[NSString stringWithFormat:@"%@__%@___thumb.%@", self.typeKey, imageName, _ext]} forKey:layer[@"thumb_url"]];

    }
    if(self.downloadMask && layer[@"alphaMask"]) {
        NSString *_ext = [[layer[@"alphaMask"] lastPathComponent] pathExtension];
        [urls addObject:[NSURL URLWithString:layer[@"alphaMask"]]];
        [self.urls setObject:@{@"tag":tag,@"key":@"mask",@"name":[NSString stringWithFormat:@"%@__%@___mask.%@", self.typeKey, imageName, _ext]} forKey:layer[@"alphaMask"]];
        
    }
    
    int fc = (int)(self.keys.count - (float)self.finishedKeys.count+1);
    int c = (int)self.keys.count;
    float p = (float)((float)fc/(float)c);
    DLogDebug(@"Localize:   %@  %@ /  %@  %@ - %@  %@",
              ColorWrap([[NSString stringWithFormat:@"%2.1f%%", p*100] pad:6], COLOR_WHITE),
              [[NSString stringWithFormat:@"%d", fc] pad:4],
              [[NSString stringWithFormat:@"%d", c] pad:4],
              ColorWrap([[self.typeKey capitalizedString] pad:15], COLOR_PURPLE),
              ColorWrap(!primaryTag ? [[NSString stringWithFormat:@"??? -> %@", tag] pad:15] : [[primaryTag capitalizedString] pad:15], primaryTag ? COLOR_PURPLE : COLOR_RED),

              ColorWrap([[imgFileName pad:45] stringByAppendingFormat:@"     %d url%@",(int)self.urls.count, self.urls.count > 1 ? @"s" : @""],   isJPNG ? COLOR_GREEN_BRIGHT : COLOR_DULL));

    if(urls.count)
    {
        __unsafe_unretained __block NSMutableDictionary *newLayer = [[NSMutableDictionary dictionaryWithDictionary:layer] retain];
        SDWebImagePrefetcher *downloader = [[SDWebImagePrefetcher alloc] init];
        [downloader prefetchURLs:urls completed:^(NSUInteger finishedCount, NSUInteger totalCount, BOOL finished, UIImage *image, NSURL *url, SDImageCacheType cacheType, NSInteger currentIndex) {
            
            NSString *fileName = [MysticLocalData manager].urls[url.absoluteString][@"name"];
            NSString *key = [MysticLocalData manager].urls[url.absoluteString][@"key"];
            NSString *tag = [MysticLocalData manager].urls[url.absoluteString][@"tag"];

//            DLogHidden(@"    downloaded: %@  %@", key, fileName);
            if(fileName)
            {
                NSString *f = [[(MysticCache *)[MysticCache cache:MysticCacheTypeTemp] diskCachePath] hasSuffix:@"/"] ? @"" : @"/";
                f = [f suffix:[tag suffix:@"/"]];
                NSString *f2 = [NSString stringWithFormat:@"%@%@", [(MysticCache *)[MysticCache cache:MysticCacheTypeTemp] diskCachePath], f];
                BOOL isDir = NO;
                if(![[NSFileManager defaultManager] fileExistsAtPath:f2 isDirectory:&isDir])
                {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] createDirectoryAtPath:f2 withIntermediateDirectories:YES attributes:nil error:&error];
                    if(error) DLogError(@"Unable to create Tag cache dir: %@", f2);
                }
                
                
                if([url.absoluteString hasSuffix:@"jpng"])
                {
                    NSString *oof = [[f copy] autorelease];
                    f = [f stringByAppendingString:@"jpng/"];
                    BOOL isDir = NO;
                    NSString *ff = [[MysticCache cache:MysticCacheTypeTemp].diskCachePath stringByAppendingFormat:@"%@jpng/", oof];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:ff isDirectory:&isDir])
                    {
                        NSError *error = nil;
                        [[NSFileManager defaultManager] createDirectoryAtPath:ff withIntermediateDirectories:YES attributes:nil error:&error];
                        if(error)
                        {
                            DLogError(@"Unable to create JPNG cache dir: %@", f);
                            f = oof;
                        }
                    }
                }
                NSString *filePath = [NSString stringWithFormat:@"%@%@%@", [MysticCache cache:MysticCacheTypeTemp].diskCachePath, f, fileName];
//                NSString *filePathUser = [filePath replace:@"/Users/travis/" with:@"~/"];
                BOOL isDira = NO;
                if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDira])
                {
                    if([url.absoluteString hasSuffix:@"jpng"]) [UIImageJPNGRepresentation(image, 1) writeToFile:filePath atomically:NO];
                    else if([url.absoluteString hasSuffix:@"png"]) [UIImagePNGRepresentation(image) writeToFile:filePath atomically:NO];
                    else [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:NO];
                }
                
                if(key) [newLayer setObject:fileName forKey:key];
                NSArray *filterKeys = @[@"primary_tag", @"primary_tag_name", @"tags"];
                for (id k in filterKeys) {
                    id v = [newLayer objectForKey:k];
                    if(!v || [v isKindOfClass:[NSString class]] || isNull(v) || ([v isKindOfClass:[NSArray class]] && [(NSArray *)v count] == 0) || ([v isKindOfClass:[NSDictionary class]] && [[(NSDictionary *)v allValues] count] == 0))
                    {
                        [newLayer removeObjectForKey:k];
                    }
                }
                
                [[MysticLocalData manager].data setObject:[NSMutableDictionary dictionaryWithDictionary:[MysticLocalData manager].data[[MysticLocalData manager].typeKey]] forKey:[MysticLocalData manager].typeKey];
                
                [[MysticLocalData manager].data[[MysticLocalData manager].typeKey] setObject:newLayer forKey:[MysticLocalData manager].currentKey];
                if(![tag isEqualToString:@"unknown"] && [self.packs objectForKey:tag]) [[self.packs objectForKey:tag] setObject:newLayer forKey:self.currentKey];

                if(finishedCount == totalCount)
                {
                    [newLayer release];
                    [[MysticLocalData manager] nextLayer];
                }
            }
        }];
        self.downloader = downloader;
    }
    else [[MysticLocalData manager] nextLayer];
}
- (void) dealloc;
{
    [super dealloc];
    [_downloader release];
    [_data release], _data=nil;
    [_layers release], _layers=nil;
    [_keys release], _keys = nil;
    [_finishedKeys release], _finishedKeys = nil;
    [_currentKey release], _currentKey=nil;
    [_typeKey release], _typeKey=nil;
    if(_finished) Block_release(_finished);
}
@end

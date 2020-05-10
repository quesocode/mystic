//
//  MysticDictionaryDownloader.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDictionaryDownloader.h"
#import "NSString+Mystic.h"

@interface MysticDictionaryDownloader ()
{

}
@end
@implementation MysticDictionaryDownloader

+ (MysticDictionaryDownloader *) manager;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

+ (id) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary state:(MysticBlockData)finished;
{
//    __unsafe_unretained __block MysticBlockData _i = finished ? Block_copy(finished) : nil;

    if(!finished)
    {
        NSDictionary *localDict = filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSDictionary class]] ? filePathOrDictionary :  nil;
        if(!localDict && filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSString class]])
        {
            localDict = [NSDictionary dictionaryWithContentsOfFile:filePathOrDictionary];
        }
        return localDict;
    }
    return [[self class] dictionaryWithURL:url orDictionary:filePathOrDictionary init:^(id obj, id obj2, id obj3, BOOL success) {
        MysticDataState idataState = success ? MysticDataStateInit|MysticDataStateNew : MysticDataStateInit|MysticDataStateError;
        if(finished)
        {
            
            finished(obj, idataState);
            
        }
        
    } start:^(id sobj, BOOL ssuccess) {
        MysticDataState sdataState = MysticDataStateStart;
        sdataState = ssuccess ? sdataState|MysticDataStateDownloading : sdataState;
        if(finished)
        {

            
            
            finished(sobj, sdataState);

        }
    } complete:^(id fobj, id fobj2, id fobj3, BOOL fsuccess) {
        MysticDataState dataState = MysticDataStateFinish;
        dataState = fsuccess ? dataState|MysticDataStateChanged|MysticDataStateNew|MysticDataStateComplete : (fobj2 ? dataState|MysticDataStateCachedServer|MysticDataStateComplete : dataState|MysticDataStateCachedLocal);
        if(finished) finished(fobj, dataState);
    }];
}

+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary  complete:(MysticBlockObjObjObjBOOL)finished;
{
    return [[self class] dictionaryWithURL:url orDictionary:filePathOrDictionary start:nil complete:finished];
}
+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary init:(MysticBlockObjObjObjBOOL)initBlock start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjObjBOOL)finished;
{
    NSDictionary *localDict = nil;
    if(initBlock)
    {
        NSString *filename = [filePathOrDictionary isKindOfClass:[NSString class]] ? [filePathOrDictionary lastPathComponent] : nil;
        NSString *pathFilename = filename;
        if(!filename)
        {
            NSArray *_urls = [url.absoluteString componentsSeparatedByString:@"/"];
            if(_urls.count > 3)
            {
                NSArray *urls = [_urls subarrayWithRange:(NSRange){_urls.count - 2, 2}];
                pathFilename = [urls componentsJoinedByString:@"_"];
                
                
            }
            
            
        }
        
        NSString *cachedPath = [[self class] cachedPathForURL:url filename:pathFilename];
        
        localDict = [[self class] cachedDictionaryForURL:url filename:pathFilename];
        
        
        if(initBlock)
        {
            initBlock(localDict, url, [NSURL fileURLWithPath:cachedPath],  YES);
        }
    }
    __unsafe_unretained __block MysticBlockObjObjObjBOOL _f = finished;
    __unsafe_unretained __block MysticBlockObjBOOL _s = startBlock;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MysticDictionaryDownloader dictionaryWithURL:url orDictionary:filePathOrDictionary start:startBlock complete:finished];
//        if(_f) Block_release(_f);
//        if(_s) Block_release(_s);
    });
    return localDict;
}
+ (NSDictionary *) dictionaryWithURL:(NSURL *)url orDictionary:(id)filePathOrDictionary start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjObjBOOL)finished;
{
    __unsafe_unretained __block MysticBlockObjBOOL _s = startBlock ? Block_copy(startBlock) : nil;
    __unsafe_unretained __block MysticBlockObjObjObjBOOL _f = finished ? Block_copy(finished) : nil;
    
    
    NSString *filename = [filePathOrDictionary isKindOfClass:[NSString class]] ? [filePathOrDictionary lastPathComponent] : nil;
    NSString *pathFilename = filename;
    if(!filename)
    {
        NSArray *_urls = [url.absoluteString componentsSeparatedByString:@"/"];
        if(_urls.count > 3)
        {
            NSArray *urls = [_urls subarrayWithRange:(NSRange){_urls.count - 2, 2}];
            pathFilename = [urls componentsJoinedByString:@"_"];
            
            
        }
        
        
    }
    
    
    
    NSString *cachedPath = [[self class] cachedPathForURL:url filename:pathFilename];
    NSDictionary *localDict = nil;
    localDict = [[self class] cachedDictionaryForURL:url filename:pathFilename];
    
    if(localDict && ![[self class] hasCacheExpiredForURL:url filename:pathFilename])
    {
        __unsafe_unretained __block MysticBlockObjBOOL _s1 = startBlock ? Block_copy(startBlock) : nil;
        if(_s1)
        {
            _s1([NSURL fileURLWithPath:[[self class] cachedPathForURL:url filename:pathFilename]], NO);
            
            Block_release(_s1);
        }
        __unsafe_unretained __block MysticBlockObjObjObjBOOL _f1 = finished ? Block_copy(finished) : nil;

        if(_f1)
        {
            _f1(localDict, nil, [NSURL fileURLWithPath:cachedPath],  NO);
            Block_release(_f1);

        }
//        return localDict;
    }
    [[self class] setLastCheckedDate:[NSDate timeIntervalSinceReferenceDate] forUrl:url];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL downloadFromServer = NO;
    NSString *lastModifiedString = nil;
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSHTTPURLResponse *response;
    NSDate *lastModifiedServer = nil;
    NSDate *lastModifiedLocal = nil;
    NSDate *_lastModifiedServer = [[self class] lastModifiedDateFromServerForURL:url];
//    NSDictionary *_headers = nil;
//    [request setHTTPMethod:@"HEAD"];
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
//    if ([response respondsToSelector:@selector(allHeaderFields)]) {
//        _headers = [NSDictionary dictionaryWithDictionary:[response allHeaderFields]];
//        lastModifiedString = [_headers objectForKey:@"Mystic-Last-Modified-time"];
//        lastModifiedString = lastModifiedString ? lastModifiedString : [_headers objectForKey:@"Last-Modified"];
//    }
    
//    @try {
//        
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
//        df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
//        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//        lastModifiedServer = [df dateFromString:lastModifiedString];
//        [df release], df=nil;
//        
//    }
//    @catch (NSException * e) {
//        NSLog(@"Error parsing last modified date: %@ - %@", lastModifiedString, [e description]);
//    }
    
    
    
//    if ([fileManager fileExistsAtPath:cachedPath]) {
//        NSError *error = nil;
//        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cachedPath error:&error];
//        if (error) {
//            NSLog(@"Error reading file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
//        }
//        lastModifiedLocal = [fileAttributes fileModificationDate];
//    }
    

    
    // Download file from server if the server modified timestamp is later than the local modified timestamp
//    if (!lastModifiedLocal || [lastModifiedLocal laterDate:lastModifiedServer] == lastModifiedServer) {
//        downloadFromServer = YES;
//    }
    
    
//    if(filename && downloadFromServer)
//    {
//        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filename error:nil];
//        
//        NSDate *date = [attributes fileModificationDate];
//        if([lastModifiedServer laterDate:date] == date)
//        {
//            DLog(@"local file is newer than the server modified date... use the local file: %@", filename);
//            downloadFromServer = NO;
//        }
//    }
    
    BOOL _downloadFromServer = lastModifiedLocal && lastModifiedServer && [lastModifiedLocal isEqualToDate:lastModifiedServer] ? NO : downloadFromServer;

//    if (NO && _downloadFromServer) {
//        
//        if(_s) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _s(url, YES);
//                Block_release(_s), _s = nil;
//            });
//            
//        }
//        
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        if (data) {
//            [[self class] setLastModifiedDateFromServer:lastModifiedServer forURL:url];
//            
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//
//            if ([data writeToFile:cachedPath atomically:YES]) {
//                
//                __unsafe_unretained __block NSDictionary *baseFileData = [[[self class] cachedDictionaryForURL:url filename:pathFilename] retain];
//                if(_f) {
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        _f(baseFileData, url, cachedPath, YES);
//                        [baseFileData release];
//                        Block_release(_f), _f = nil;
//                    });
//                    
//                }
//                
//            }
//            
//            // Set the file modification date to the timestamp from the server
//            if (lastModifiedServer) {
//                NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:lastModifiedServer forKey:NSFileModificationDate];
//                NSError *error = nil;
//                if ([fileManager setAttributes:fileAttributes ofItemAtPath:cachedPath error:&error]) {
//                    
//                }
//                if (error) {
//                    NSLog(@"Error setting file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
//                }
//            }
//            
//            
//        }
//        else
//        {
//            if(_s) Block_release(_s), _s = nil;
//            if(_f) Block_release(_f), _f = nil;
//        }
//    }
//    else
//    {
        localDict = filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSDictionary class]] ? filePathOrDictionary :  nil;
        if(!localDict && filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSString class]])
        {
            localDict = [NSDictionary dictionaryWithContentsOfFile:filePathOrDictionary];
        }
        
        

        dispatch_async(dispatch_get_main_queue(),
       ^{
           
           if(_s)
           {
               _s(filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSString class]] ? [NSURL fileURLWithPath:filePathOrDictionary] :  nil, NO);
               Block_release(_s), _s = nil;
           }
           if(_f)
           {
               _f(localDict ? localDict : nil, url, filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSString class]] ? [NSURL fileURLWithPath:filePathOrDictionary] :  nil,  NO);
               Block_release(_f), _f = nil;
           }
       });
//    }
    if(!localDict)
    {
        localDict = filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSDictionary class]] ? filePathOrDictionary :  nil;
        if(!localDict && filePathOrDictionary && [filePathOrDictionary isKindOfClass:[NSString class]])
        {
            localDict = [NSDictionary dictionaryWithContentsOfFile:filePathOrDictionary];
        }
    }
    return localDict;
    
}



+ (void) setLastModifiedDateFromServer:(NSDate *)date forURL:(NSURL *)url;
{
    NSTimeInterval timestamp = [date timeIntervalSinceReferenceDate];
    [[NSUserDefaults standardUserDefaults] setInteger:timestamp forKey:[@"MysticTimeStamp-serverModified-" stringByAppendingString:[[url absoluteString] md5]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) setLastCheckedDate:(NSTimeInterval)timestamp forUrl:(NSURL *)url;
{
    [[NSUserDefaults standardUserDefaults] setInteger:timestamp forKey:[@"MysticTimeStamp-lastCheck-" stringByAppendingString:[[url absoluteString] md5]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval) lastCheckedDateForUrl:(NSURL *)url;
{
    NSTimeInterval t = [[NSUserDefaults standardUserDefaults] integerForKey:[@"MysticTimeStamp-lastCheck-" stringByAppendingString:[[url absoluteString] md5]]];

    return t == 0 ? [NSDate timeIntervalSinceReferenceDate] : t;
}


+ (NSDate *) lastModifiedDateFromServerForURL:(NSURL *)url;
{
    NSTimeInterval t = [[NSUserDefaults standardUserDefaults] integerForKey:[@"MysticTimeStamp-serverModified-" stringByAppendingString:[[url absoluteString] md5]]];
    
    return t == 0 ? nil : [NSDate dateWithTimeIntervalSinceReferenceDate:t];
}

+ (NSString *) cacheDirectoryPath;
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"config"];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return cachePath;
}
+ (NSString *) cachedPathForURL:(NSURL *)url;
{
    return [[self class] cachedPathForURL:url filename:nil];
}
+ (NSString *) cachedPathForURL:(NSURL *)url filename:(NSString *)filename;
{
    filename = filename ? [[filename componentsSeparatedByString:@"."] objectAtIndex:0] : nil;
    NSString *cachedPath = [[self class] cacheDirectoryPath];
    cachedPath = [cachedPath stringByAppendingFormat:@"/%@%@.plist", filename ? [filename stringByAppendingString:@"-"] : @"",  [[url absoluteString] md5]];
    return cachedPath;
}
+ (BOOL) hasCacheExpiredForURL:(NSURL *)url;
{
    return [[self class] hasCacheExpiredForURL:url filename:nil];
}

+ (BOOL) hasCacheExpiredForURL:(NSURL *)url filename:(NSString *)filename;
{
    if(![[self class] cacheExistsForURL:url filename:filename]) return YES;
    return (BOOL) (([NSDate timeIntervalSinceReferenceDate] - [[self class] lastCheckedDateForUrl:url]) >= MYSTIC_CONFIG_DICT_CACHE_EXP_TIME);
}
+ (NSString *) cacheExistsForURL:(NSURL *)url;
{
    return [[self class] cacheExistsForURL:url filename:nil];
}
+ (NSString *) cacheExistsForURL:(NSURL *)url filename:(NSString *)filename;
{
    NSString *cachedPath = [[self class] cachedPathForURL:url filename:filename];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachedPath isDirectory:&isDir];
    return (!cachePathExists || isDir) ? nil : cachedPath;

}
+ (NSDictionary *) cachedDictionaryForURL:(NSURL *)url;
{
    return [[self class] cachedDictionaryForURL:url filename:nil];
}
+ (NSDictionary *) cachedDictionaryForURL:(NSURL *)url filename:(NSString *)filename;
{
    NSString *cachedPath = [[self class] cacheExistsForURL:url filename:filename];
    
    
    return cachedPath ? [NSDictionary dictionaryWithContentsOfFile:cachedPath] : nil;

}
+ (BOOL) removeCacheForURL:(NSURL *)url;
{
    return [[self class] removeCacheForURL:url filename:nil];
}
+ (BOOL) removeCacheForURL:(NSURL *)url filename:(NSString *)filename;
{
    BOOL success = NO;
    NSError *error;
    @try
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        success = [fm removeItemAtPath:[self cachedPathForURL:url filename:filename] error:&error];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[@"MysticTimeStamp-lastCheck-" stringByAppendingString:[[url absoluteString] md5]]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[@"MysticTimeStamp-serverModified-" stringByAppendingString:[[url absoluteString] md5]]];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    @catch (NSException *exception) {
        DLog(@"ERROR - MysticDictionaryDownloader (clearCachedFiles): %@", [error description]);
        success = NO;
    }
    return success;
}

+ (BOOL) removeAllCache;
{
    BOOL success = NO;
    NSError *error;
    @try
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *directory = [[[self class] cacheDirectoryPath] stringByAppendingString:@"/"];
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[@"MysticTimeStamp-lastCheck-" stringByAppendingString:[file stringByDeletingPathExtension]]];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[@"MysticTimeStamp-serverModified-" stringByAppendingString:[file stringByDeletingPathExtension]]];
            
            if (!success || error) {
                // it failed.
                DLog(@"there was error removing: %@", [NSString stringWithFormat:@"%@%@", directory, file]);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];

        
    }
    @catch (NSException *exception) {
        DLog(@"ERROR - MysticDictionaryDownloader (clearCachedFiles): %@", [error description]);
        success = NO;
    }
    return success;
}
@end

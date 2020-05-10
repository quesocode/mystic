//
//  MysticConfigManager.m
//  Mystic
//
//  Created by travis weerts on 3/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <dispatch/dispatch.h>
#import <CommonCrypto/CommonDigest.h>
#import "MysticLocalData.h"
#import "MysticConfigManager.h"
//#import "AFPropertyListRequestOperation.h"
//#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "NSDictionary+Merge.h"
#import "MysticCore.h"
#import "MysticDictionary.h"

static NSTimeInterval lastCheckedForUpdateTimeInterval;
static NSString *configQueryStr = @"";

@interface MysticConfigManager ()
{
    dispatch_queue_t backgroundQueue;
    BOOL askingToUpdate;
}

@end
@implementation MysticConfigManager

static MysticConfigManager *MysticConfigInstance = nil;

@synthesize data=_data;


+ (MysticConfigManager *) manager
{
    if(!MysticConfigInstance) MysticConfigInstance = [[[self class] alloc] init];
    return MysticConfigInstance;
}

+ (void) setManager:(MysticConfigManager *) manager
{
    MysticConfigInstance = [manager retain];
}
+ (CGFloat) scale; { return [UIScreen mainScreen].scale; }
+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", digest[i]];
    return  output;
}

+(BOOL) getYesOrNo
{
    return (arc4random() % 30)+1 % 5 == 0;
}



- (void) dealloc
{
    [MysticConfigInstance release], MysticConfigInstance=nil;
    self.data = nil;
    if(backgroundQueue) dispatch_release(backgroundQueue), backgroundQueue=nil;
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self) askingToUpdate = NO;
    return self;
}



#pragma mark -
#pragma mark downloadConfig


- (void)updateConfig:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
{
    [self updateConfigUsingForce:NO start:startBlock complete:finished];
}
- (void)updateConfigUsingForce:(BOOL)forceUpdate start:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
{
    __unsafe_unretained __block MysticConfigManager *weakSelf = self;
    mdispatch_high(^{ [weakSelf downloadConfig:forceUpdate start:startBlock complete:finished];});
}

- (void)downloadConfig;
{
    [self downloadConfig:NO start:nil complete:nil];

}
- (void)downloadConfig:(MysticBlockBOOL)finished;
{
    [self downloadConfig:NO start:nil complete:finished];
}
- (void)downloadConfig:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
{
    [self downloadConfig:NO start:startBlock complete:finished];
}
- (void)downloadConfig:(BOOL)forceUpdate start:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
{
    BOOL shouldLocalize = NO;
#ifdef MYSTIC_MAKE_CONFIG_LOCAL
    forceUpdate = YES;
    shouldLocalize = YES;
#endif
    [MysticConfigManager copyBundledConfigTo:nil fileName:nil];

    @autoreleasepool {
        BOOL _hasCacheExpired = [[self class] hasCacheExpired];
        NSDate *_lastCheck = [NSDate dateWithTimeIntervalSinceReferenceDate:lastCheckedForUpdateTimeInterval];
        NSDate *_expireTime = [NSDate dateWithTimeIntervalSinceReferenceDate:lastCheckedForUpdateTimeInterval+kConfigCacheExpirationTime];
        
        
        [MysticConfigManager setLastCheckedForUpdate:[NSDate timeIntervalSinceReferenceDate]];
    
        NSString *appVersionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        appVersionStr = appVersionStr ? [appVersionStr stringByReplacingOccurrencesOfString:@"." withString:@""] : nil;
        
#ifdef USETESTURL
        NSString *configURLString = [NSString stringWithFormat:@"%@", MYSTIC_CONFIG_URL_DEBUG];
#else
        NSString *configURLString = MYSTIC_CONFIG_URL;
        if([Mystic isRiddleAnswer:@"testlayers"]  || [Mystic isRiddleAnswer:MysticChiefPassword])
        {
            configURLString = [NSString stringWithFormat:@"%@", MYSTIC_CONFIG_URL_DEBUG];
            DDLogHidden(@"Downloading config from: %@", configURLString);
        }
        
#endif
        
        
        DDLogHidden(@"Downloading config... forcing: %@    %@", MBOOL(forceUpdate), configURLString);

        
        NSURL *url = [NSURL URLWithString:configURLString];
        NSString *cachedPath = [MysticConfigManager filtersFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL downloadFromServer = NO;
        NSString *lastModifiedString = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSHTTPURLResponse *response;
        NSDate *lastModifiedServer = nil;
        NSDate *lastModifiedLocal = nil;
        
        [request setHTTPMethod:@"HEAD"];
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];
        }
        
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
            df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            lastModifiedServer = [df dateFromString:lastModifiedString];
            [df release], df=nil;
            
        }
        @catch (NSException * e) { DLogHidden(@"     Error parsing last modified date: %@ - %@", lastModifiedString, [e description]); }
        
        
        BOOL cachedFileExists = [fileManager fileExistsAtPath:cachedPath];
        if (cachedFileExists) {
            NSError *error = nil;
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cachedPath error:&error];
            if (error) DLogHidden(@"     Error reading file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
            lastModifiedLocal = [fileAttributes fileModificationDate];
            MysticDictionary *filtersCachedDict = [self fileData:nil useDefaultAsBackUp:NO];
            if(!filtersCachedDict[@"version"])
            {
                DLogHidden(@"     Error Cached filters.plist is OLD, and was deleted");
                [[NSFileManager defaultManager] removeItemAtPath:[MysticConfigManager filtersFilePath] error:nil];
                lastModifiedLocal = nil;
                downloadFromServer = YES;
                cachedFileExists = NO;
            }
        }
        
        // Download file from server if the server modified timestamp is later than the local modified timestamp
        if (!lastModifiedLocal || [lastModifiedLocal laterDate:lastModifiedServer] == lastModifiedServer) downloadFromServer = YES;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"] error:nil];
        NSDate *date = [attributes fileCreationDate];
        if(downloadFromServer && [lastModifiedServer laterDate:date] == date && cachedFileExists) downloadFromServer = NO;
        if(lastModifiedLocal == lastModifiedServer || !lastModifiedString) downloadFromServer = NO;
        
        if (forceUpdate || (downloadFromServer && lastModifiedLocal != lastModifiedServer)) {
            [self notify:@"MysticConfigWillDownloadUpdate" object:@"updated"];
            if(startBlock) mdispatch( ^{ startBlock(YES); });
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                [_lastModifiedServer release], _lastModifiedServer = nil;
                _lastModifiedServer = [lastModifiedServer retain];
                NSString *tempFilePath = [[MysticConfigManager filtersFilePath] stringByAppendingString:@".temp"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                // Save the data
                if ([data writeToFile:tempFilePath atomically:YES])
                {
                    MysticDictionary *tempConfig = [self fileData:tempFilePath useDefaultAsBackUp:NO];
                    if(tempConfig)
                    {
                        if(tempConfig[@"version"] || shouldLocalize)
                        {
                            MysticDictionary *currentData = [self fileData:nil useDefaultAsBackUp:YES];
                            NSDictionary *mergedData = [tempConfig dictionaryByMergingWith:currentData];
                            
                            if([mergedData writeToFile:[MysticConfigManager filtersFilePath] atomically:YES]) {
//                                DLogSuccess(@"     Config Cached: %@", [MysticConfigManager filtersFilePath]);
                                [self setData:[self fileData:nil useDefaultAsBackUp:YES] localize:YES];
                                [self notify:MysticEventConfigUpdated object:@"updated"];
                                [self notify:@"MysticConfigFinishUpdated" object:@"updated"];
                                if(finished) mdispatch( ^{ finished(YES); });
                            }
                        }
                        else
                        {
                            MysticDictionary *currentData = [self fileData:@"bundle" useDefaultAsBackUp:YES];
                            NSDictionary *mergedData = [currentData dictionaryByMergingWith:tempConfig];
                            // error - downloaded data corrupts data when merged
//                            NSDictionary *mergedData = currentData;
//                            DLogHidden(@"     Error Downloaded filters.plist is OLD, please MysticLocalData it");
                            [self setData:mergedData localize:shouldLocalize];
                            [self notify:MysticEventConfigUpdated object:@"updated"];
                            [self notify:@"MysticConfigFinishUpdated" object:@"updated"];
                            if(finished) mdispatch( ^{ finished(YES); });
                            lastModifiedServer = nil;
                            [_lastModifiedServer release], _lastModifiedServer = nil;
                        }
                        [fileManager removeItemAtPath:tempFilePath error:nil];
                    }
                }
                
                // Set the file modification date to the timestamp from the server
                if (lastModifiedServer) {
                    NSError *error = nil;
                    [fileManager setAttributes:@{NSFileModificationDate:lastModifiedServer} ofItemAtPath:cachedPath error:&error];
                    if(error) DLogError(@"     Error setting file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
                }
            }
        }
        else
        {
            mdispatch(^{
                [self notify:@"MysticConfigFinishUpdated" object:@"current"];
                if(startBlock) startBlock(NO);
                if(finished) finished(NO);
            });
        }
        DDLogHidden(@"   ");
    }
}

- (void) notify:(NSString *)name object:(id)obj;
{
    mdispatch(^{ [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:name object:obj]]; });
}

- (void) saveData:(id)data;
{
    [self saveData:data merge:NO];
}
- (void) saveData:(id)data merge:(BOOL)shouldMerge;
{
    NSString *tempFilePath = [[MysticConfigManager filtersFilePath] stringByAppendingString:@".temp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Save the data
//    DLog(@"save data: %@", [data class]);
    if ([data writeToFile:tempFilePath atomically:YES])
    {
        MysticDictionary *tempConfig = [self fileData:tempFilePath useDefaultAsBackUp:NO];
        if(tempConfig)
        {
            NSDictionary *mergedData = data;
            if(shouldMerge)
            {
                MysticDictionary *currentData = [self fileData:nil useDefaultAsBackUp:YES];
                mergedData = [tempConfig dictionaryByMergingWith:currentData];
            }
            
            if([mergedData writeToFile:[MysticConfigManager filtersFilePath] atomically:YES]) {
                [self setData:[self fileData:nil useDefaultAsBackUp:YES] localize:NO];
                [self notify:MysticEventConfigUpdated object:@"updated"];
                [self notify:@"MysticConfigFinishUpdated" object:@"updated"];
            }
            [fileManager removeItemAtPath:tempFilePath error:nil];

        }
    }
}

- (void) setData:(id)data; { [self setData:data localize:YES]; }
- (void) setData:(id)data localize:(BOOL)localize;
{
//    DLogHidden(@"Setting config data...");
    if(data && _data && [data isEqual:_data] && !localize) return;
    if(_data) [_data release], _data=nil;
    if(data) _data = [data isKindOfClass:[MysticDictionary class]] ? [data retain] : [data isKindOfClass:[NSDictionary class]] ? (id)[[NSDictionary dictionaryWithDictionary:data] retain] : nil;
    else _data = nil;
    [self notify:@"MysticConfigFinishUpdated" object:@"updated"];

#ifdef MYSTIC_MAKE_CONFIG_LOCAL
    DLogDebug(@"Making config data local... %@", MBOOL(localize));
    
    if(!localize) return;
    __unsafe_unretained __block MysticConfigManager *ws = self;
    [MysticLocalData data:_data finished:^(MysticDictionary *d){ [ws setData:d localize:NO]; }];
#endif
}

- (MysticDictionary *) fileData
{
    NSString *fPath = [MysticConfigManager filtersFilePath];
    return [self fileData:fPath useDefaultAsBackUp:YES];
}
- (MysticDictionary *) fileData:(NSString *)filePath useDefaultAsBackUp:(BOOL)useDefaultAsBackUp;
{
    filePath = filePath ? filePath : [MysticConfigManager filtersFilePath];
    BOOL isDir;
    NSString *_filePath = filePath;
    MysticDictionary *baseFileData = nil;
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || [filePath isEqualToString:@"bundle"])
    {
        _filePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
        baseFileData = [[[MysticDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"]] autorelease];
    }
    else
    {
        baseFileData = (id)[[[MysticDictionary alloc] initWithContentsOfFile:filePath] autorelease];
        if(!baseFileData && useDefaultAsBackUp)
        {
            _filePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
//            DLog(@"using default filepath2: %@", [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"]);
            baseFileData = [[[MysticDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"]] autorelease];
//            [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[filePath stringByAppendingString:@".error"] error:nil];
        }
    }
//    DLog(@"file path: %@", _filePath);

    baseFileData = baseFileData ? baseFileData : [[[MysticDictionary alloc] initWithContentsOfFile:_filePath] autorelease];
//    DLog(@"getting config data: %llu MB", MysticGetFileSize(_filePath, YES));
    
    return (MysticDictionary *)baseFileData;
}

#pragma mark - Utility Methods

+ (NSString *) pathForFilename:(NSString *)pathAndFileName
{
    pathAndFileName = [[pathAndFileName componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *path = [[NSBundle mainBundle] pathForResource:[pathAndFileName stringByAppendingString:@"@2x"] ofType:@"png"];
    if(!path)
    {
        path = [[NSBundle mainBundle] pathForResource:[pathAndFileName stringByAppendingString:@"@2x"] ofType:@"jpg"];
        if(!path)
        {
            path = [[NSBundle mainBundle] pathForResource:pathAndFileName ofType:@"jpg"];
            if(!path)
            {
                path = [[NSBundle mainBundle] pathForResource:pathAndFileName ofType:@"png"];
            }
        }
    }
    
    
    return path;
}

+ (NSString *)filtersFilePath
{
//    NSArray *documentPaths3 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory3 = [documentPaths3 objectAtIndex:0];
    return [[self configDirPath] stringByAppendingFormat:@"/filters.plist"] ;
}




+ (BOOL) clearConfigFiles;
{
    
    
    BOOL success = NO;
    NSError *error;
    @try
    {
        success = [[NSFileManager defaultManager] removeItemAtPath:[MysticConfigManager configDirPath] error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR - MysticConfigManager (clearConfigFiles): %@", [error description]);
        success = NO;
    }
    return success;
}
+ (NSString *) configDirSubPath:(NSString *)directoryName;
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"config/%@", directoryName]];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return cachePath;
}
+ (NSString *) configDirPath;
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
- (void) addConfig:(NSDictionary *)newConfig name:(NSString *)configName finished:(MysticBlockSender)finished;
{
    NSString *filePath = [[MysticConfigManager configDirSubPath:configName] stringByAppendingString:@"/filters.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:filePath] == YES) {
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    
    [newConfig writeToFile:filePath atomically:YES];
    
    [MysticConfigManager appendConfig:configName filePath:filePath];
    
    self.data = [self fileData];
    
    
}

+ (NSDictionary *) appendableConfigs
{
    NSDictionary *appendedConfigs = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[MysticConfigManager configDirPath] stringByAppendingString:@"/appended-filters.plist"];
    if([fileManager fileExistsAtPath:filePath])
    {
        appendedConfigs = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return appendedConfigs;
}

+ (NSDictionary *) appendConfig:(NSString *)name filePath:(NSString *)configPath
{
    NSDictionary *appendables = [MysticConfigManager appendableConfigs];
    NSMutableDictionary *appendedConfigs = appendables ? [NSMutableDictionary dictionaryWithDictionary:appendables] : [NSMutableDictionary dictionary];
    
    [appendedConfigs setObject:configPath forKey:name];
    
    NSDictionary *finalAppendedConfigs = [NSDictionary dictionaryWithDictionary:appendedConfigs];
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[MysticConfigManager configDirPath] stringByAppendingString:@"/appended-filters.plist"];
    
    if ([fileManager fileExistsAtPath:filePath] == YES) {
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [finalAppendedConfigs writeToFile:filePath atomically:YES];
    return finalAppendedConfigs;
}

+ (NSTimeInterval) lastCheckedForUpdate;
{
    return lastCheckedForUpdateTimeInterval;
}

+ (void) setLastCheckedForUpdate:(NSTimeInterval)time;
{
    lastCheckedForUpdateTimeInterval = time;
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:lastCheckedForUpdateTimeInterval forKey:@"MysticLastCheckedForUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) hasCacheExpired;
{
    
//    DLog(@"has cache expired: %2.0f - %2.0f == %2.0f >= %2.0f", [NSDate timeIntervalSinceReferenceDate], lastCheckedForUpdateTimeInterval, [NSDate timeIntervalSinceReferenceDate] - lastCheckedForUpdateTimeInterval, kConfigCacheExpirationTime);
    
    BOOL expired = (BOOL) ([NSDate timeIntervalSinceReferenceDate] >= lastCheckedForUpdateTimeInterval + kConfigCacheExpirationTime);
    if(!expired)
    {
        if(![[NSFileManager defaultManager] fileExistsAtPath:[MysticConfigManager filtersFilePath]]) return YES;
    }
    return expired;
    
}

+ (void) copyBundledConfigTo:(NSString *)cachePath fileName:(NSString *)filename;
{
    NSString *localPath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
    cachePath = cachePath ? cachePath : (NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists) [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSError *error = nil;
    NSString *newPath = [cachePath stringByAppendingPathComponent:filename ? filename : @"filters.plist"];
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:nil]) [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:localPath toPath:newPath error:&error];
    if(error) DLogError(@"Error copying bundled config:\n   bundle: %@\n   path: %@\n\n   error: %@\nreason: %@", localPath, newPath, error.localizedDescription, error.localizedFailureReason);
}


@end

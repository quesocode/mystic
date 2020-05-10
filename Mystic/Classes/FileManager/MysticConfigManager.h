//
//  MysticConfigManager.h
//  Mystic
//
//  Created by travis weerts on 3/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
///Users/travis/Desktop/mystic/new Mystic/Mystic/Classes/Potions/PackPotionOptionMulti.m:10:9: In file included from /Users/travis/Desktop/mystic/new Mystic/Mystic/Classes/Potions/PackPotionOptionMulti.m:10:

#import "MysticConstants.h"

@class MysticDictionary;

@interface MysticConfigManager : NSObject
{
    NSMutableData *receivedData;
    dispatch_queue_t updateCheckThread;
    NSDate *_lastModifiedServer;
    
}

@property (nonatomic, retain) id data;

+ (MysticConfigManager *) manager;
+ (void) setManager:(MysticConfigManager *) manager;
+ (BOOL) clearConfigFiles;
+ (NSString *) configDirSubPath:(NSString *)directoryName;
+ (NSString *) configDirPath;
+ (void) copyBundledConfigTo:(NSString *)cachePath fileName:(NSString *)filename;

#pragma mark - Utilities
+ (NSString *) md5:(NSString *) input;
+ (CGFloat) scale;
+(BOOL) getYesOrNo;
+ (NSString *) pathForFilename:(NSString *)pathAndFileName;

#pragma mark - Instance methods

- (void)updateConfig:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
- (void)updateConfigUsingForce:(BOOL)forceUpdate start:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
- (void) saveData:(id)data;
- (void) setData:(id)data localize:(BOOL)localize;


- (void) addConfig:(NSDictionary *)newConfig name:(NSString *)configName finished:(MysticBlockSender)finished;
- (void)downloadConfig;
- (void)downloadConfig:(MysticBlockBOOL)finished;
- (void)downloadConfig:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
- (void)downloadConfig:(BOOL)forceUpdate start:(MysticBlockBOOL)startBlock complete:(MysticBlockBOOL)finished;
- (MysticDictionary *) fileData:(NSString *)filePath useDefaultAsBackUp:(BOOL)useDefaultAsBackUp;

- (MysticDictionary *) fileData;

+ (NSTimeInterval) lastCheckedForUpdate;
+ (void) setLastCheckedForUpdate:(NSTimeInterval)time;
+ (BOOL) hasCacheExpired;
@end


//
//  MysticUser.h
//  Mystic
//
//  Created by travis weerts on 8/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

typedef enum
{
    MysticUserTypeNormal,
    MysticUserTypeChief,
    MysticUserTypeAdmin

} MysticUserType;

@interface MysticUser : NSObject
@property (nonatomic, readonly) NSInteger numberOfPotions;
@property (nonatomic) MysticUserType type;
@property (nonatomic, readonly) NSArray *potions, *potionPaths;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableDictionary *info;

@property (nonatomic, readonly) NSArray *recentColors;
@property (nonatomic, retain) NSMutableDictionary *sizes;
@property (nonatomic, readonly) NSString *lastProjectName, *currentProjectName;
@property (nonatomic, readonly) NSArray *itemsUsedRecently, *projectNames;
@property (nonatomic, readonly) NSDictionary *recentlyUsedItems, *projects, *lastProject, *project;

@property (nonatomic, readonly) NSString *mysticUserId;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, assign) CGSize maximumRenderSize;

@property (nonatomic, assign) MysticVersion appVersion;
@property (nonatomic, assign) BOOL privacy;
@property (nonatomic, assign) BOOL useAnimations;

@property (nonatomic, assign) BOOL highQuality;
@property (nonatomic, assign) BOOL mysticAlbum;
@property (nonatomic, assign) BOOL potionMode;
@property (nonatomic, assign) BOOL safeMode;
@property (nonatomic, assign) BOOL liveState;
@property (nonatomic, assign) BOOL autoUpdate;

@property (nonatomic, retain) NSString *riddleAnswer;




+ (MysticUser *) user;
+ (NSString *) cacheDirectoryPath;
+ (BOOL) showTips;
+ (BOOL) privacyEnabled;
+ (void) set:(id)value key:(id)key;
+ (id) get:(id)key;
+ (float) getf:(id)key;
+ (int) geti:(id)key;
+ (void) remove:(id)key;
+ (BOOL) toggle:(id)key;
+ (BOOL) is:(id)key;
+ (BOOL) remembers:(id)key as:(id)val old:(id *)old;
+ (void) remember:(id)key as:(id)value;
+ (void) remember:(id)key;
+ (void) forget:(id)key;
+ (void) forgetAll;
+ (BOOL) remembers:(id)key;
+ (BOOL) remembers:(id)key as:(id)val;
+ (void) setTemp:(id)value key:(id)key;
+ (id) temp:(id)key;
+ (int) temp:(id)key int:(int)defaultValue;
+ (BOOL) temp:(id)key bool:(BOOL)defaultValue;
+ (float) temp:(id)key float:(float)defaultValue;
+ (id) temp:(id)key value:(id)defaultValue;
+ (CGPoint) temp:(id)key point:(CGPoint)defaultValue;
+ (CGRect) temp:(id)key rect:(CGRect)defaultValue;
+ (CGSize) temp:(id)key size:(CGSize)defaultValue;

+ (void) removeTemp:(id)key;

- (BOOL) hasUsedItemRecently:(PackPotionOption *)item;
- (void) usedItemRecently:(PackPotionOption *)item;
- (NSArray *) itemsUsedRecentlyForType:(MysticObjectType)type;
- (NSInteger) numberOfItemsUsedRecentlyForType:(MysticObjectType)objType;
- (void) clearProjects;

- (NSString*)userId;
- (NSString*)deviceToken;
- (void)setDeviceToken:(NSString*)token;
- (void) savePotion:(NSDictionary *)project projectKeyName:(NSString *)projectKeyName projectName:(NSString *)projectName;
- (void) savePotion:(NSString *)name image:(UIImage *)thumbnail finished:(MysticBlockObjBOOL)finished;
- (void) setPotions:(NSArray *)value;
- (CGSize) sizeForType:(MysticImageSizeType)imageSizeType;
- (void) setSize:(CGSize)value forType:(MysticImageSizeType)imageSizeType;
- (void) saveProject:(NSDictionary *)project forName:(NSString *)projectName;
- (void) removeProject:(NSString *)projectName;

- (NSDictionary *) projectForName:(NSString *)projectName;
- (void) clearLastProject;
- (NSDictionary *) cachedProjectForName:(NSString *)projectName type:(NSString *)pType;
+ (NSString *) cachedPathForProjectName:(NSString *)projectName type:(NSString *)ext;
- (NSDictionary *) cachedProjectForName:(NSString *)projectName type:(NSString *)pType public:(BOOL)usePublic;
+ (id) cleanData:(NSDictionary *)dict public:(BOOL)public;
+ (NSDictionary *) prepareProjectForRead:(NSDictionary *)project;
+ (BOOL) clearProjectDir;
+ (NSDictionary *) projectFromFilePath:(NSString *)cachePath;
+ (NSDictionary *) prepareFileForProject:(NSDictionary *)project;

@end

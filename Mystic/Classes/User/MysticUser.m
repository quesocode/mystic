//
//  MysticUser.m
//  Mystic
//
//  Created by travis weerts on 8/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticUser.h"
#import "Mystic.h"
#import "UserPotion.h"
#import "UIColor+Mystic.h"

@interface MysticUser ()
{
    NSMutableDictionary *_sizes;
    NSMutableDictionary *_recentColorDict;
    NSMutableArray *_recentColorOrdered;
}
@property (nonatomic, retain) NSString *lastSaved;
@end
@implementation MysticUser

static NSString * const UserData = @"UserData";
static NSString * const UserId = @"UserId";
static NSString * const DeviceTokenKey = @"DeviceToken";
static NSString * const PotionsKey = @"UserPotions";
static NSString * const UserSettingQuality = @"UserSettingQuality";
static NSString * const UserSettingMysticAlbum = @"UserSettingMysticAlbum";
static NSString * const UserSettingPotionMode = @"UserSettingPotionMode";
static NSString * const UserSettingRiddleAnswer = @"UserSettingRiddleAnswer";
static NSString * const UserSettingPrivacy = @"UserSettingPrivacy";
static NSString * const UserSettingLiveState = @"UserSettingLiveState";
static NSString * const UserSettingSafeMode = @"UserSettingSafeMode";
static NSString * const UserSettingUseAnimations = @"UserSettingsUseAnimations";
static NSString * const UserSettingAutoUpdate = @"UserSettingAutoUpdate";
static NSString * const UserSettingAppVersion = @"UserSettingAppVersion";
static NSString * const UserSettingProjects = MYSTIC_USER_PROJECTS;
static NSString * const UserSettingProjectNames = MYSTIC_USER_PROJECT_NAMES;
static NSString * const UserSettingRecentlyUsedItems = @"UserSettingRecentlyUsedItems";
static NSString * const UserSettingRecentlyUsedItemsDict = @"UserSettingRecentlyUsedItemsDict";



@synthesize type, potions, potionPaths, data=_data, mysticUserId, privacy=_privacy, potionMode=_potionMode, safeMode=_safeMode, liveState=_liveState, riddleAnswer=_riddleAnswer, highQuality=_highQuality, mysticAlbum=_mysticAlbum, size=_size, sizes=_sizes, useAnimations=_useAnimations, autoUpdate=_autoUpdate, appVersion=_appVersion;

+ (void)initialize
{
	if (self == [MysticUser class])
	{
		// Register default values for our settings
		[[NSUserDefaults standardUserDefaults] registerDefaults:
            @{
                                                         UserId: @"",
                                                 DeviceTokenKey: @"",
                                                       UserData: @{},
                                                     PotionsKey: @[],
                                             UserSettingQuality: @NO,
                                         UserSettingMysticAlbum: @YES,
                                          UserSettingPotionMode: @NO,
                                        UserSettingRiddleAnswer: @"",
                                             UserSettingPrivacy: @NO,
                                           UserSettingLiveState: @YES,
                                            UserSettingSafeMode: @NO,
                                       UserSettingUseAnimations: @NO,
                                          UserSettingAutoUpdate: @YES,
                                          UserSettingAppVersion: @(MYSTIC_APP_VERSION),
                                                        Mk_TIME: @(1),
                                                       Mk_SCALE: @(0),
                                           @"settings-showTips": @YES,
                                            @"settings-private": @YES,
                                      @"settings-photo-quality": @(0),
                                                  @"tips-shown": @{},

            }];
	}
}


+ (MysticUser *) user;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}
+ (BOOL) showTips; { return [MysticUser is: @"settings-showTips"]; }
+ (BOOL) privacyEnabled; { return [MysticUser is: @"settings-private"]; }

+ (BOOL) remembers:(id)key as:(id)val;
{
    return [self remembers:key as:val old:nil];
    
}
+ (BOOL) remembers:(id)key as:(id)val old:(id *)old;
{
    id v = [self get:key];
    if(v) *old  = v;
    if(!v) return NO;
    return [v isEqual:val];
    
}
+ (void) remember:(id)key as:(id)value;
{
    [self set:value key:key];
}
+ (void) remember:(id)key;
{
    [self set:@YES key:key];
}
+ (void) forgetAll;
{
    NSDictionary *d =[[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (id k in d.allKeys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:k];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];    
}
+ (void) forget:(id)key;
{
    [self remove:key];
}
+ (BOOL) remembers:(id)key;
{
    
    return [self is:key];
}
+ (void) remove:(id)key;
{
    if(key && ![key isKindOfClass:[NSString class]]) key = [NSString stringWithFormat:@"%@", key];
    if(!key || ![[NSUserDefaults standardUserDefaults] objectForKey:key]) return;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (void) set:(id)value key:(id)key;
{
    if(!key || !value) return;
    if(![key isKindOfClass:[NSString class]]) key = [NSString stringWithFormat:@"%@", key];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (BOOL) is:(id)key;
{
    if(key && ![key isKindOfClass:[NSString class]]) key = [NSString stringWithFormat:@"%@", key];
    id v = [[self class] get:key];
    return v ? [v boolValue] : NO;
}
+ (float) getf:(id)key; { return [[[self class] get:key] floatValue]; }
+ (int) geti:(id)key; { return [[[self class] get:key] intValue]; }
+ (id) get:(id)key;
{
    if(key && ![key isKindOfClass:[NSString class]]) key = [NSString stringWithFormat:@"%@", key];
    return !key ? nil : [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
+ (BOOL) toggle:(id)key;
{
    if(key && ![key isKindOfClass:[NSString class]]) key = [NSString stringWithFormat:@"%@", key];
    if(!key) return NO;
    if([[self class] get:key]) { [[self class] remove:key]; return NO; }
    [[self class] set:@YES key:key];
    return YES;
}
+ (void) setTemp:(id)value key:(id)key;
{
    if(![MysticUser user].info) [MysticUser user].info = [NSMutableDictionary dictionary];
    if(!value) { [MysticUser removeTemp:key]; return; }
    if(!key) return;
    [[MysticUser user].info setObject:value forKey:key];
}
+ (int) temp:(id)key int:(int)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] intValue] : defaultValue;
}
+ (BOOL) temp:(id)key bool:(BOOL)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] boolValue] : defaultValue;
}
+ (float) temp:(id)key float:(float)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] floatValue] : defaultValue;
}
+ (CGPoint) temp:(id)key point:(CGPoint)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] CGPointValue] : defaultValue;
}
+ (CGRect) temp:(id)key rect:(CGRect)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] CGRectValue] : defaultValue;
}
+ (CGSize) temp:(id)key size:(CGSize)defaultValue;
{
    return [[self class] temp:key] ? [[[self class] temp:key] CGSizeValue] : defaultValue;
}
+ (id) temp:(id)key value:(id)defaultValue;
{
    return [[self class] temp:key] ? [[self class] temp:key] : defaultValue;
}
+ (id) temp:(id)key;
{
    if(![MysticUser user].info || !key) return nil;
    return [[MysticUser user].info objectForKey:key];
}
+ (void) removeTemp:(id)key;
{
    if(![MysticUser user].info || !key) return;
    [[MysticUser user].info removeObjectForKey:key];
    if([[MysticUser user].info allKeys].count == 0) [MysticUser user].info = nil;
    
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.sizes = [NSMutableDictionary dictionary];
        _recentColorDict = [NSMutableDictionary dictionary];
        _recentColorOrdered = [NSMutableArray array];
        [MysticUser forget:Mk_SHADER_WITH_FILE];
    }
    return self;
}
+ (void) addRecentColor:(UIColor *)color; { [[MysticUser user] addRecentColor:color]; }
- (NSArray *) recentColors; { return [NSArray arrayWithArray:_recentColorOrdered]; }
- (void) addRecentColor:(id)color;
{
    UIColor *c = [MysticColor color:color];
    if(!c) return;
    if(_recentColorDict[c.hexStringWithoutHash] != nil) return;
    [_recentColorDict setObject:c forKey:c.hexStringWithoutHash];
    [_recentColorOrdered addObject:c];
}
- (BOOL) isUser:(MysticUserType)thetype; { return self.type == thetype; }

- (NSString*)userId;
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserId];
    if (userId == nil || userId.length == 0) {
        userId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:UserId];
    }
    return userId;
}
- (NSString*)deviceToken { return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey]; }
- (void) setData:(NSDictionary *)value;
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:UserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSDictionary *) data;
{
    NSDictionary *__data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:UserData];
    return __data != nil ? __data : @{};
}
- (NSString *) mysticUserId;
{
    return self.data ? [self.data objectForKey:@"user_id"] : nil;
}

- (void)setDeviceToken:(NSString*)token;
{
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}

- (BOOL) liveState;
{
    
    return NO;
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingLiveState];
}
- (void) setLiveState:(BOOL)value;
{
    _liveState = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingLiveState];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) autoUpdate;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingAutoUpdate];
}

- (void) setAutoUpdate:(BOOL)value;
{
    _autoUpdate = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingAutoUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL) useAnimations;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingUseAnimations];
}

- (void) setUseAnimations:(BOOL)value;
{
    _useAnimations = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingUseAnimations];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) potionMode;
{
    return NO;
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingPotionMode];
}
- (void) setPotionMode:(BOOL)value;
{
    _potionMode = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingPotionMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (BOOL) highQuality;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingQuality];
}
- (void) setHighQuality:(BOOL)value;
{
    _highQuality = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingQuality];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) mysticAlbum;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingMysticAlbum];
}
- (void) setMysticAlbum:(BOOL)value;
{
    _mysticAlbum = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingMysticAlbum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) safeMode;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingSafeMode];
}
- (void) setSafeMode:(BOOL)value;
{
    _safeMode = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingSafeMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) privacy;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:UserSettingPrivacy];
}
- (void) setPrivacy:(BOOL)value;
{
    _privacy = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingPrivacy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) riddleAnswer;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserSettingRiddleAnswer];
}
- (void) setRiddleAnswer:(NSString *)value;
{
    _riddleAnswer = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:UserSettingRiddleAnswer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MysticVersion) appVersion;
{
    NSInteger v = [[NSUserDefaults standardUserDefaults] integerForKey:UserSettingAppVersion];
    if(v < 0 || v == NSNotFound)
    {
        v = (NSInteger)MYSTIC_APP_VERSION;
    }
    return (MysticVersion)v;
}
- (void) setAppVersion:(MysticVersion)value;
{
    _appVersion = value;
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:UserSettingAppVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *) itemsUsedRecently;
{
    id obj = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingRecentlyUsedItems];
    return obj ? obj : @[];


}
- (NSInteger) numberOfItemsUsedRecentlyForType:(MysticObjectType)objType;
{
    return [self itemsUsedRecentlyForType:objType].count;
}
- (NSArray *) itemsUsedRecentlyForType:(MysticObjectType)objType;
{
    NSString *itemTypeKey = MysticString(objType);
    
    NSArray *subItems = [self.recentlyUsedItems objectForKey:itemTypeKey];
    return subItems ? subItems : @[];

}
- (NSDictionary *) recentlyUsedItems;
{
    id obj = [[NSUserDefaults standardUserDefaults] dictionaryForKey:UserSettingRecentlyUsedItemsDict];
    return obj ? obj : @{};
}
- (BOOL) hasUsedItemRecently:(PackPotionOption *)item;
{
    return item ? [self.itemsUsedRecently containsObject:item.tag] : NO;
}
- (void) usedItemRecently:(PackPotionOption *)item;
{
    if(!item) return;

    if(item.tag && ![self hasUsedItemRecently:item])
    {
        NSMutableArray *recents = [NSMutableArray arrayWithArray:self.itemsUsedRecently];
        
        [recents insertObject:item.tag atIndex:0];
        
        
        
        
        
        NSMutableDictionary *recentsDict = [NSMutableDictionary dictionaryWithDictionary:self.recentlyUsedItems];
        NSString *itemTypeKey = MysticString(item.type);
        NSMutableArray *recentsDictSubArray = [recentsDict objectForKey:itemTypeKey] ? [NSMutableArray arrayWithArray:[recentsDict objectForKey:itemTypeKey]] : [NSMutableArray array];
        
        [recentsDictSubArray insertObject:item.tag atIndex:0];
        
        [recentsDict setObject:recentsDictSubArray forKey:itemTypeKey];
        
        
        
        
        
        
        if(recentsDictSubArray.count > MYSTIC_RECENT_USED_MAX)
        {
            NSString *lastTag = [recentsDictSubArray lastObject];
            BOOL f = NO;
            NSInteger i = 0;
            for (NSString *recentKey in recents) {
                if([recentKey isEqualToString:lastTag])
                {
                    [recents removeObjectAtIndex:i];
                    break;
                }
                i++;
            }
            
            [recentsDictSubArray removeLastObject];
            [recentsDict setObject:recentsDictSubArray forKey:itemTypeKey];

        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:recents forKey:UserSettingRecentlyUsedItems];
        [[NSUserDefaults standardUserDefaults] setObject:recentsDict forKey:UserSettingRecentlyUsedItemsDict];

        
        [[NSUserDefaults standardUserDefaults] synchronize];


    }
}

#pragma mark - Potions
- (NSInteger) numberOfPotions;
{
    return self.potions.count;
}
- (NSArray *) potionPaths;
{
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:PotionsKey];
    
    return userPotions ? userPotions : [NSArray array];
}
- (NSArray *) potions;
{
    NSMutableArray *_potions = [NSMutableArray array];
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:PotionsKey];

    if(userPotions && userPotions.count)
    {
        for (NSString *path in userPotions) {
            NSDictionary *prjDict = [[NSDictionary alloc] initWithContentsOfFile:path];
            PackPotionOptionRecipe *project = (PackPotionOptionRecipe *)[PackPotionOptionRecipe optionWithName:[prjDict objectForKey:@"name"] info:prjDict];
            project.recipeType = MysticRecipesTypeSaved;
            [_potions addObject:project];
        }
    }
    return _potions;
}
- (void) setPotions:(NSArray *)value;
{
    if(value)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:value]  forKey:PotionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(value==nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PotionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void) savePotion:(NSString *)name image:(UIImage *)thumbnail finished:(MysticBlockObjBOOL)finished;
{
    NSMutableArray *newPotions = [NSMutableArray array];
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:PotionsKey];
    if(userPotions && userPotions.count)
    {
        [newPotions addObjectsFromArray:userPotions];
    }
    
    
    [MysticProject saveAs:name image:thumbnail finished:^(NSString *newProjectFilePath) {
        
        [newPotions addObject:newProjectFilePath];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:newPotions]  forKey:PotionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        MysticProject *proj = [MysticProject projectFromFile:newProjectFilePath];
        
        if(finished) finished(proj, YES);
    }];
}
- (CGSize) maximumRenderSize;
{
//    return (CGSize){2048.f, 2048.f};
    return [MysticImage maximumImageSize];
}

- (CGSize) size;
{
    CGRect rect = CGRectZero;
    rect.size = [MysticUI scaleSize:[UserPotion potion].sourceImageSize bounds:self.maximumRenderSize];
    rect = CGRectIntegral(rect);
    return rect.size ;
}

- (void) setSize:(CGSize)value forType:(MysticImageSizeType)imageSizeType;
{
    [self.sizes setObject:[NSValue valueWithCGSize:value] forKey:[NSString stringWithFormat:@"size-%d", imageSizeType]];
}
- (CGSize) sizeForType:(MysticImageSizeType)imageSizeType;
{
    NSValue *sizeValue = [self.sizes objectForKey:[NSString stringWithFormat:@"size-%d", imageSizeType]];
    return sizeValue ? [sizeValue CGSizeValue] : self.size;
}

- (NSString *) lastProjectName;
{
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingProjectNames];
    id s = userPotions.count ? [userPotions lastObject] : nil;
    if(s && [s isEqualToString:self.currentProjectName]) s = userPotions.count > 1 ? [userPotions objectAtIndex:[userPotions indexOfObject:s]-1] : nil;
    return s;
}
- (NSArray *) projectNames;
{
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingProjectNames];
    return userPotions ? userPotions : @[];
}
- (NSDictionary *) lastProject;
{
    return [self projectForName:self.lastProjectName];
}
- (NSDictionary *) project;
{
    return [self projectForName:self.currentProjectName];
}
- (NSString *) currentProjectName;
{
    if(![MysticOptions current].projectName) return nil;
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingProjectNames];
    if(!userPotions || userPotions.count==0 || ![userPotions containsObject:[MysticOptions current].projectName])
    {
        NSMutableArray *_userPotions = [NSMutableArray arrayWithArray:userPotions ? userPotions : @[]];
        [_userPotions addObject:[MysticOptions current].projectName];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:_userPotions] forKey:UserSettingProjectNames];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [MysticOptions current].projectName;
}
- (void) saveProject:(NSDictionary *)project forName:(NSString *)projectName;
{
    if((!self.lastSaved && self.lastProjectName) || (self.lastProjectName && ![self.lastProjectName isEqualToString:projectName] && ![self.lastSaved isEqualToString:projectName])) [[MysticUser user] removeProject:self.lastProjectName];
    self.lastSaved = projectName;
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingProjectNames];
    if(![userPotions containsObject:projectName])
    {
        NSMutableArray *_userPotions = [NSMutableArray arrayWithArray:userPotions];
        [_userPotions addObject:projectName];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:_userPotions] forKey:UserSettingProjectNames];
    }
    NSMutableDictionary *_userProjects = [NSMutableDictionary dictionaryWithDictionary:self.projects];
    [_userProjects setObject:project forKey:projectName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionaryWithDictionary:_userProjects]];
    if(data) [[NSUserDefaults standardUserDefaults] setObject:data forKey:UserSettingProjects];
    NSDictionary *cleanProject = [[self class] prepareProjectForFile:project];
    BOOL success = [cleanProject writeToFile:[[self class] cachedPathForProjectName:projectName] atomically:YES];
    NSDictionary *cleanProject2 = [[self class] cleanData:cleanProject public:YES];
    if ([NSJSONSerialization isValidJSONObject: cleanProject2]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:cleanProject2 options: NSJSONWritingPrettyPrinted error:&error];
        if(data && !error) [data writeToFile:[[self class] cachedPathForProjectName:projectName type:@"json"] atomically:YES];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) savePotion:(NSDictionary *)project projectKeyName:(NSString *)projectKeyName projectName:(NSString *)projectName;
{
    NSError *error = nil;

    NSDictionary *cleanProject = [[self class] prepareProjectForFile:project];
    NSMutableDictionary *cleanProject2 = [NSMutableDictionary dictionaryWithDictionary:cleanProject];
    NSString *thumbnailName = [projectKeyName suffix:[[UserPotion potion].thumbnailImagePath lastPathComponent]];
    
    NSString *newThumbPath = [[[self class] cacheDirectoryPath] stringByAppendingFormat:@"/%@", thumbnailName];
    [[NSFileManager defaultManager] copyItemAtPath:[UserPotion potion].thumbnailImagePath toPath:newThumbPath error:&error];
//    [cleanProject2 setObject:thumbnailName forKey:[NSString stringWithFormat:@"%@", @(MysticProjectKeyImageThumb)]];
    [cleanProject2 setObject:projectName ? projectName : @"Potion Name" forKey:@"name"];
    [cleanProject2 setObject:@"Potion Description" forKey:@"description"];
    [cleanProject2 setObject:thumbnailName forKey:@"thumbnail"];

    
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyHistory)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyHistoryIndex)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyHistoryChangeIndex)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyImageThumbPath)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyImageResizedPath)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyImageSrcPath)]];
    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyImageOriginalPath)]];
//    [cleanProject2 removeObjectForKey:[NSString stringWithFormat:@"%@",@(MysticProjectKeyRenderSize)]];
    
    NSDictionary *cleanProject3 = [NSDictionary dictionaryWithDictionary:[[self class] cleanData:[NSDictionary dictionaryWithDictionary:cleanProject2] public:YES]];
    


    NSError *error2;

    BOOL success = [cleanProject3 writeToFile:[[self class] cachedPathForProjectName:projectKeyName type:@"plist"] atomically:YES];
    
    
    
    NSMutableDictionary *__potions = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:[[MysticConfigManager configDirPath] stringByAppendingPathComponent:@"potions.plist"]])
    {
        __potions = [NSMutableDictionary dictionaryWithContentsOfFile:[[MysticConfigManager configDirPath] stringByAppendingPathComponent:@"potions.plist"]];
    }
    else
    {
        __potions = [NSMutableDictionary dictionaryWithDictionary:@{@"order": [NSMutableArray array], @"potions":[NSMutableDictionary dictionary]}];
    }
    
    if(__potions)
    {
        NSMutableDictionary *otherPotions = [NSMutableDictionary dictionaryWithDictionary:[__potions objectForKey:@"potions"]];
        NSMutableArray *potionOrders = [NSMutableArray arrayWithArray:[__potions objectForKey:@"order"]];
        
        NSString *potionKey = [NSString stringWithFormat:@"potion-%u", (int)(potionOrders.count + 1)];
        [otherPotions setObject:cleanProject3 forKey:potionKey];
        [potionOrders addObject:potionKey];
        
        [__potions setObject:otherPotions forKey:@"potions"];
        [__potions setObject:potionOrders forKey:@"order"];
        BOOL success2 = [__potions writeToFile:[[MysticConfigManager configDirPath] stringByAppendingPathComponent:@"potions.plist"] atomically:YES];
        
    }
    
}
- (NSDictionary *) projects ;
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:UserSettingProjects]) return nil;
    NSDictionary *userProjects = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UserSettingProjects]];
    return userProjects ? userProjects : @{};
}
- (NSDictionary *) projectForName:(NSString *)projectName;
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:UserSettingProjects]) return nil;
    NSDictionary *userProjects = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UserSettingProjects]];
    return userProjects ? [userProjects objectForKey:projectName] : nil;
}

- (NSDictionary *) cachedProjectForName:(NSString *)projectName type:(NSString *)pType;
{
    return [self cachedProjectForName:projectName type:pType public:NO];
}
- (NSDictionary *) cachedProjectForName:(NSString *)projectName type:(NSString *)pType public:(BOOL)usePublic;
{
    pType = [pType lowercaseString];
    NSString *cachePath = [[self class] cachedPathForProjectName:projectName type:pType];
    if(cachePath && [[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        if([pType isEqualToString:@"json"])
        {
            NSData *jData = [NSData dataWithContentsOfFile:cachePath];
            NSError *error = nil;
            id cachedProject = [NSJSONSerialization JSONObjectWithData:jData options:0 error:&error];
            return [[self class] cleanData:cachedProject public:usePublic];
        }
        else
        {
            NSDictionary *cachedProject = [NSDictionary dictionaryWithContentsOfFile:cachePath];
            if(cachedProject)
            {
                return [[self class] cleanData:cachedProject public:usePublic];
            }
        }
    }
    return nil;
}

+ (NSDictionary *) projectFromFilePath:(NSString *)cachePath;
{
    if(cachePath && [[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        if([cachePath containsString:@"json"])
        {
            NSData *jData = [NSData dataWithContentsOfFile:cachePath];
            NSError *error = nil;
            id cachedProject = [NSJSONSerialization JSONObjectWithData:jData options:0 error:&error];
            NSDictionary *cleanedProject = [[self class] cleanData:cachedProject public:YES];
            return [[self class] prepareFileForProject:cleanedProject];
        }
        else
        {
            NSDictionary *cachedProject = [NSDictionary dictionaryWithContentsOfFile:cachePath];
            if(cachedProject)
            {
                NSDictionary *cleanedProject = [[self class] cleanData:cachedProject public:YES];
                return [[self class] prepareFileForProject:cleanedProject];
            }
        }
    }
    return nil;
}
+ (id) cleanData:(NSDictionary *)dict public:(BOOL)public;
{
    if(!public) return dict;
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [_dict removeObjectsForKeys:@[@(MysticProjectKeyImageSrcPath),
                                  @(MysticProjectKeyImageOriginalPath),
                                  @(MysticProjectKeyImageResizedPath),
                                  [NSString stringWithFormat:@"%@", @(MysticProjectKeyImageSrcPath)],
                                  [NSString stringWithFormat:@"%@", @(MysticProjectKeyImageOriginalPath)],
                                  [NSString stringWithFormat:@"%@", @(MysticProjectKeyImageResizedPath)]]];
    return _dict;
}
- (void) clearLastProject;
{
    mdispatch_high(^{
        NSString *name = self.lastProjectName;
        NSString *current = self.currentProjectName;
        if(!name && !current) { [self clearProjects]; }
        else [self removeProject:name];
    });
}
- (void) clearProjects;
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserSettingProjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserSettingProjectNames];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableArray *deletedFiles = [NSMutableArray array];
    [MysticCache deleteAllCacheTypeFiles:MysticCacheTypeProject tag:nil files:deletedFiles];
}

- (void) removeProject:(NSString *)projectName;
{
    if(!projectName) return;
    NSArray *userPotions = [[NSUserDefaults standardUserDefaults] arrayForKey:UserSettingProjectNames];
    if([userPotions containsObject:projectName])
    {
        NSMutableArray *_userPotions = [NSMutableArray arrayWithArray:userPotions];
        [_userPotions removeObject:projectName];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:_userPotions] forKey:UserSettingProjectNames];
    }
    NSMutableDictionary *_userProjects = [NSMutableDictionary dictionaryWithDictionary:self.projects];
    if(isM(_userProjects[projectName]))
    {
        [_userProjects removeObjectForKey:projectName];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionaryWithDictionary:_userProjects]];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:UserSettingProjects];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self deleteProjectFiles:projectName finished:nil];

}

- (void) deleteProjectFiles:(NSString *)projectName finished:(MysticBlockObject)f;
{
    if(!projectName) { if(f) f(nil); return; }
    __unsafe_unretained __block MysticBlockObject finished = f ? f : nil;
    mdispatch_default(^{
        @autoreleasepool {
            NSDictionary *cachedProj = [self cachedProjectForName:projectName type:@"plist"];
            NSString *cachedProjPath = [[self class] cachedPathForProjectName:projectName type:@"plist"];
            NSString *cachedProjPathJson = [[self class] cachedPathForProjectName:projectName type:@"json"];
            NSMutableArray *theKeys = [NSMutableArray array];
            NSMutableArray *renderFiles = [NSMutableArray array];
            NSMutableArray *files = [NSMutableArray array];
            int d = 0;
            BOOL isDir = NO;
            NSError *error = nil;
            if([[NSFileManager defaultManager] fileExistsAtPath:cachedProjPath isDirectory:&isDir])
            {
                [[NSFileManager defaultManager] removeItemAtPath:cachedProjPath error:&error];
                if(!error && !isDir) { [files addObject:cachedProjPath]; d++; }
            }
            error = nil;
            isDir = NO;
            if([[NSFileManager defaultManager] fileExistsAtPath:cachedProjPathJson isDirectory:&isDir])
            {
                [[NSFileManager defaultManager] removeItemAtPath:cachedProjPathJson error:&error];
                if(!error && !isDir) { [files addObject:cachedProjPathJson]; d++; }
            }
            [MysticCache deleteAllCacheTypeFiles:MysticCacheTypeProject withTag:projectName files:files];
            if(finished) finished((id)@{@"name": projectName,
                                        @"path": MObj(cachedProjPath),
                                        @"delete": @(d),
                                        @"proj":  MObj(cachedProj),
                                        @"files": files,
                                        });
            files = nil;
        }
    });
}
+ (BOOL) clearProjectDir;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [[[self class] cacheDirectoryPath] stringByAppendingString:@"/"];
    NSError *error = nil;
    BOOL success = YES;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL _success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        success = !success ? NO : _success;
    }
    return success;
}
+ (NSString *) cacheDirectoryPath;
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    BOOL isDir;
//    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"user"];
//    if(![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir]) [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
//    return cachePath;
}
+ (NSString *) cachedPathForProjectName:(NSString *)projectName;
{
    return [[self class] cachedPathForProjectName:projectName type:nil];
}
+ (NSString *) cachedPathForProjectName:(NSString *)projectName type:(NSString *)ext;
{
    projectName = projectName ? [[projectName componentsSeparatedByString:@"."] objectAtIndex:0] : nil;
    NSString *cachedPath = [[self class] cacheDirectoryPath];
    cachedPath = [cachedPath stringByAppendingFormat:@"/%@.%@", projectName, ext ? ext : @"plist"];
    return cachedPath;
}

+ (NSDictionary *) prepareProjectForRead:(NSDictionary *)project;
{
    return [[self class] prepareProjectForFile:project keyType:NO];
}
+ (NSDictionary *) prepareProjectForFile:(NSDictionary *)project;
{
    return [[self class] prepareProjectForFile:project keyType:YES];
}
+ (NSDictionary *) prepareProjectForFile:(NSDictionary *)project keyType:(BOOL)keyToString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id key in project.allKeys) {
        id newKey;
        if(keyToString)
        {
            if(![key isKindOfClass:[NSString class]]) newKey = [NSString stringWithFormat:@"%@", key];
            else newKey = key;
        }
        else
        {
            if([key isKindOfClass:[NSString class]] && [key hasPrefix:[NSString stringWithFormat:@"%d", MysticProjectKeyPrefix]])
            {
                newKey = @([(NSNumber *)key integerValue]);
            }
            else newKey = key;
        }
        id val = [project objectForKey:key];
        id newval;
        if([val isKindOfClass:[NSDictionary class]])
        {
            newval = [[self class] prepareProjectForFile:val keyType:keyToString];
        }
        else if([val isKindOfClass:[NSArray class]])
        {
            newval = [[self class] prepareProjectArrayForFile:val keyType:keyToString];

        }
        else if([val isKindOfClass:[NSNumber class]] || [val isKindOfClass:[NSDate class]] || [val isKindOfClass:[NSData class]])
        {
            newval = val;
        }
        else if([val isKindOfClass:[UIColor class]])
        {
            newval = [(UIColor *)val rgbaString];
        }
        else if([val isKindOfClass:[NSValue class]])
        {
            if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"CGRect"])
            {
                CGRect r = [(NSValue *)val CGRectValue];
                newval = NSStringFromCGRect(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"CGSize"])
            {
                CGSize r = [(NSValue *)val CGSizeValue];
                newval = NSStringFromCGSize(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"CGPoint"])
            {
                CGPoint r = [(NSValue *)val CGPointValue];
                newval = NSStringFromCGPoint(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"CGAffineTransform"])
            {
                CGAffineTransform r = [(NSValue *)val CGAffineTransformValue];
                newval = NSStringFromCGAffineTransform(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"NSRange"])
            {
                NSRange r = [(NSValue *)val rangeValue];
                newval = NSStringFromRange(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"UIEdgeInsets"])
            {
                UIEdgeInsets r = [(NSValue *)val UIEdgeInsetsValue];
                newval = NSStringFromUIEdgeInsets(r);
            }
            else if([[NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding] containsString:@"UIOffset"])
            {
                UIOffset r = [(NSValue *)val UIOffsetValue];
                newval = NSStringFromUIOffset(r);
            }
        }
        else
        {
            newval = [NSString stringWithFormat:@"%@", val];
        }
        newval = newval ? newval : (id)[NSNull null];

        [dict setObject:newval forKey:newKey];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (NSDictionary *) prepareFileForProject:(NSDictionary *)project;
{
    return [self prepareProjectForFile:project keyType:NO];
}


+ (NSArray *) prepareProjectArrayForFile:(NSArray *)projectArray  keyType:(BOOL)keyToString;
{
    NSMutableArray *dict = [NSMutableArray array];
    for (int i = 0; i<projectArray.count; i++)
    {
        id val = [projectArray objectAtIndex:i];
        id newval;
        if([val isKindOfClass:[NSDictionary class]])
        {
            newval = [[self class] prepareProjectForFile:val keyType:keyToString];
        }
        else if([val isKindOfClass:[NSArray class]])
        {
            newval = [[self class] prepareProjectArrayForFile:val keyType:keyToString];
        }
        else
        {
            newval = val;
        }
        [dict insertObject:newval atIndex:i];
    }
    return [NSArray arrayWithArray:dict];
}

@end

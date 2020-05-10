//
//  MysticCore.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "MysticConfigManager.h"
#import "MysticConstants.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class MysticControlObject, PackPotionOption;

@interface Mystic : MysticConfigManager
{
    
}


@property (nonatomic, assign) NSArray *options;
@property (nonatomic, readonly) NSArray *quotes, *quoteCategories, *packs, *texts, *filters, *frames, *masks, *textures, *colors, *badges, *lights, *settings, *camLayerTools, *layerSettings, *recipes, *potions, *colorFilters, *fonts, *fontStyles, *fontFamilies, *blendingModes, *mixtures, *colorOverlays;
- (NSArray *) settingsForOption:(PackPotionOption *)targetOption;
- (NSArray *) settingsWithFilter:(BOOL)withFilter;
- (NSArray *) colorsForObject:(MysticObjectType)objectType option:(MysticOptionColorType)optionType;
- (NSArray *) colorsForOption:(PackPotionOption *)option option:(MysticOptionColorType)optionType;
- (NSArray *) colorsForOption:(PackPotionOption *)option option:(MysticOptionColorType)optionType setting:(MysticObjectType)setting;
+ (void) resignFirstResponder;

+ (NSArray *) mainObjectTypes;
+ (NSArray *) topicsForType:(MysticObjectType)objType;
+ (NSArray *) topicsForType:(MysticObjectType)objType includeFeatured:(NSInteger)includeFeaturedCount;
+ (void) specialOptions:(MysticBlockData)finished;
- (void) specialOptions:(MysticBlockData)finished;
+ (void) potions:(MysticBlockData)finished;
+ (void) potionsWithType:(MysticRecipesType)type finished:(MysticBlockData)finished;
+ (void) recipes:(MysticBlockData)finished;
+ (void) recipesWithType:(MysticRecipesType)type finished:(MysticBlockData)finished;

+ (BOOL) trackDiagnostics;
+ (BOOL) storeEnabled;
+ (BOOL) useNativeShare;
+ (BOOL) useWriteOnCam;

+ (void) displayMessage;
+ (BOOL) hasUnseenMessage;
+ (NSString *) messageKey;
+ (NSString *) messageUrl;
+ (NSString *) messageCancelUrl;
+ (BOOL) messageIsReminder;
+ (void) rememberMessageKey;
+ (id) sharedLibrary;

+ (NSString *) riddleQuestion;
+ (NSString *) riddleAnswer;
+ (NSString *) riddleTitle;
- (NSArray *) quotesFromCategory:(NSString *)categoryTitle;
- (NSArray *) quotesFromCategoryAtIndex:(NSInteger)categoryIndex;

- (NSArray *) colorOverlays:(MysticBlockObjBOOL)startBlock dataBlock:(MysticBlockData)finished;

+ (NSString *) buildNumber;
+ (void) freeMemory;
+ (NSString *) version;
+ (CGRect) cropRectForImageCapture;
+ (NSString *) imageCapturePreset;
+ (NSString *) randomHash;
+ (NSString *) randomHash:(int)charCount;

+ (Mystic *) core;
+ (NSArray *) effectsOfType:(MysticObjectType)objectType;
+ (BOOL) option:(MysticControlObject *)option1 equals:(MysticControlObject *)option2;
+ (NSArray *) options:(MysticObjectType)optionType;
+ (NSArray *) optionsForType:(MysticObjectType)optionType;
+ (NSArray *) optionsForType:(MysticObjectType)optionType info:(NSDictionary *)mainData;
+ (PackPotionOption *) randomOptionOfType:(MysticObjectType)optionType;
+ (PackPotionOption *) findOptionWithType:(MysticObjectType)optionType tag:(NSString *)tag;

+ (BOOL) hasAnsweredRiddle;
+ (void) setAnsweredRiddle:(BOOL)answered;
+ (NSString *) setRiddleAnswer:(NSString *)answered finished:(MysticBlockObjBOOL)finishedAnswer;
+ (BOOL) hasInternetConnection;
+ (NSArray *) packTitles;
+ (BOOL) hasUserSeenTipWithName:(MysticTipName)tipName;
+ (void) rememberUserSeenTipWithName:(MysticTipName)tipName;
+ (void) resetUserTips;
+ (void) forgetUserSeenTipWithName:(MysticTipName)tipName;
+ (void) showTip:(MysticTipName)tipName;
+ (void) showTip:(MysticTipName)tipName title:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle complete:(MysticBlock)buttonBlock;
+ (BOOL) isRiddleAnswer:(NSString *)answer;
@end
//
//  UserPotion.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//


#import "Mystic.h"
#import "GPUImage.h"


static NSString *kMysticUndoRedoChangedNotification=@"kMysticUndoRedoChangedNotification";


@class PackPotionOptionText, PackPotionOptionFrame, PackPotionOptionTexture, PackPotionOptionFilter, PackPotionOptionLight, PackPotion, MysticPack, MysticControlObject, PackPotionOptionBadge, MysticProject, MysticOptions, PackPotionOptionSetting, PackPotionOptionCamLayer ;

@protocol UserPotionDelegate <NSObject>

@optional

@end

@interface UserPotionBase : NSObject

@property (nonatomic, readonly) NSMutableArray *layers;
@property (nonatomic, readonly) MysticOptions *effects;
@property (nonatomic, retain) NSString *tag, *uniqueTag, *sourceImagePath, *sourceImageResizedPath, *originalImagePath, *sourceImageURL, *thumbnailImagePath;
@property (nonatomic, readonly) NSString *sourceImageTag, *sourceImageResizedTag, *originalImageTag, *thumbnailTag;

@property (nonatomic, retain) NSMutableDictionary *cachedLayerImages, *userInfoExtras;
@property (nonatomic) int lastCachedLevel;
@property (nonatomic) CGSize renderSize, sourceImageSize, originalImageSize, previewSize;
@property (nonatomic, assign) NSInteger historyIndex, historyChangeIndex;
@property (nonatomic, readonly) NSInteger numberOfHistoryItems;
@property (nonatomic, retain) NSMutableArray *history;

@property (nonatomic) float lastSettingsResult, currentSettingsResult;
@property (nonatomic, retain) NSMutableDictionary *renderedOptions;
@property (nonatomic, assign) NSDictionary *media;
@property (nonatomic) CGRect cropRect;
@property (nonatomic, readonly) UIImage *originalImage, *thumbnailPreviewImage;
@property (nonatomic, assign) UIImage *sourceImage, *sourceImageResized, *thumbnailImage;
@property (nonatomic, retain) UIImage *finalImage, *lastCachedImg, *inputSourceImage;
@property (nonatomic, readonly) NSDictionary *userInfo;
@property (nonatomic) MysticObjectType editingType;
@property (nonatomic, assign) MysticMode mode;
@property (nonatomic, assign) id <UserPotionDelegate> delegate;
@property (nonatomic, retain) PackPotionOptionText *textOption, *previewOptionText;
@property (nonatomic, retain) PackPotionOptionFrame *frameOption, *previewOptionFrame;
@property (nonatomic, retain) PackPotionOptionMask *maskOption, *previewOptionMask;
@property (nonatomic, retain) PackPotionOptionTexture *textureOption, *previewOptionTexture;
@property (nonatomic, retain) PackPotionOptionFilter *filterOption, *previewOptionFilter;
@property (nonatomic, retain) PackPotionOptionLight *lightOption, *previewOptionLight;
@property (nonatomic, retain) PackPotionOptionBadge *badgeOption, *previewOptionBadge;
@property (nonatomic, retain) PackPotionOptionCamLayer *camLayerOption, *previewOptionCamLayer;
@property (nonatomic, retain) PackPotionOptionSetting *settingsOption, *previewOptionSettings;



@property (nonatomic, retain) GPUImagePicture *imagePicture;

@property (nonatomic) BOOL applyFilterToText, applyFilterToTexture, applyFilterToBadge, applyFilterToFrame, applyFilterToLight, applySettingsFirst, invertTextColor, invertBadgeColor, invertFrameColor, moreSettingsToggled, invertTextureColor, invertLightColor, invertCamLayerColor, applyFilterToCamLayer, applySunshineToFilter, flipVertical, flipHorizontal, desaturate;

@property (nonatomic, assign) float brightness, gamma, exposure, textureAlpha, lightingAlpha, textAlpha, badgeAlpha, colorAlpha, highlights, shadows, sharpness, contrast, vignetteStart, vignetteEnd, saturation, vignetteValue, tiltShift, textureRotation, badgeRotation, frameRotation, lightRotation, textRotation, rotation, frameAlpha, maskRotation, camLayerRotation, camLayerAlpha, blackLevels, midLevels, whiteLevels, haze, unsharpMask, temperature, tint;
@property (nonatomic, assign) GPUVector3 rgb;
@property (nonatomic, assign) BOOL isPrepared;

@property (nonatomic, retain) UIColor *textColor, *badgeColor, *frameBackgroundColor;

@property (nonatomic, assign) CGRect transformRect, transformTextRect, transformBadgeRect, transformMaskRect, transformCamLayerRect;


#pragma mark - History
+ (BOOL) hasHistory;
+ (BOOL) canUndo;
+ (BOOL) canRedo;
+ (void) resetHistory:(NSArray *)history;

+ (BOOL) hasPreviousHistory;
+ (BOOL) hasNextHistory;
+ (void) clearHistory;
+ (void) removeLastHistoryItem;
+ (NSInteger) indexOfHistoryItemBefore:(id)item;
+ (NSInteger) indexOfHistoryItemAfter:(id)item;
+ (NSDictionary *) lastHistoryItem;
+ (NSDictionary *) nextHistoryItem;
+ (NSDictionary *) topHistoryItem;
+ (UIImage *) historyImageAtIndex:(NSInteger)index resized:(BOOL)useResized;
+ (UIImage *) historySourceImageAndResized:(BOOL)resized;
+ (void) addHistoryItem:(NSDictionary *)item;
+ (NSInteger) numberOfHistoryItems;
+ (NSDictionary *) useNextHistoryItem;
+ (NSDictionary *) useLastHistoryItem;
+ (NSDictionary *) historyItemAtIndex:(NSInteger)index;
+ (NSDictionary *) historyItemAtHistoryIndex:(NSInteger)i;
+ (NSDictionary *) useCurrentHistoryItem;
+ (NSInteger) indexOfHistoryItem:(id)item;

+ (NSDictionary *)userInfo;
- (UIImage *) imageForRenderSize:(CGSize)size;

+ (GPUImageOutput<GPUImageInput> *) input:(GPUImageOutput<GPUImageInput> *)parent hasTarget:(GPUImageOutput<GPUImageInput> *)target;
+ (BOOL) canRender;


+ (void) startNewProject;
+ (NSDictionary *) previousProject;
+ (void) openProject:(MysticProject *)project finished:(MysticBlockObjBOOL)finished;
- (void) openProject:(MysticProject *)project finished:(MysticBlockObjBOOL)finished;

+ (BOOL) previousProjectExists;
+ (BOOL) projectExists;
+ (NSDictionary *) currentProject;
+ (void)saveAndUploadRecipe:(NSString *)recipeName image:(UIImage *)preview finished:(MysticBlockObjBOOL)finishedSaving;

+ (void)saveAndUploadProject:(NSString*)pname image:(UIImage *)preview finished:(MysticBlockObjBOOL)finishedSaving;

+ (void)saveAndUploadProject:(MysticBlockObjBOOL)finishedSaving;

+ (NSString *) previousUserInfoFilePath;

+ (NSString *) userInfoFilePath;
+ (void)saveProject;

+ (MysticOptions *)effects:(BOOL)enabled;
+ (MysticOptions *) effects;
+ (MysticOptions *) renderEffects;
- (MysticOptions *) effectsWithEffects:(id)effs;
+ (void) reset:(BOOL)clearTag;
+ (void) reset;
+ (void) resetSettings;
+ (void) resetEdits;
+ (void) resetPotion;

+ (void) removePreviews;
+ (void) removePreviewsForType:(MysticObjectType)type;
+ (UserPotionBase *) potion;
+ (void) ignoreChanges;
+ (BOOL) isIgnoringChanges;
- (CGAffineTransform) currentSourceImageTransform;
- (void) setTransform:(CGAffineTransform)transform forType:(MysticObjectType)type;
- (BOOL) confirmOptionType:(MysticObjectType)type;
- (BOOL) confirmOption:(PackPotionOption *)option;

+ (PackPotionOption *) optionForType:(MysticObjectType)type;
+ (void) cancelOption:(MysticOption *)option;
+ (void) removeOption:(MysticOption *)option;

+ (void) removeOptionForType:(MysticObjectType)type;
+ (void) cancelOptionForType:(MysticObjectType)type;
+ (PackPotionOption *) previewOptionForType:(MysticObjectType)type;
+ (PackPotionOption *) confirmedOptionForType:(MysticObjectType)type;
+ (PackPotionOption *) setOption:(PackPotionOption *)option type:(MysticObjectType)type;
+ (BOOL) confirmOption:(PackPotionOption *)option;
+ (BOOL) confirmOptionType:(MysticObjectType)type;

+ (BOOL) hasOption:(MysticControlObject *)option;
+ (BOOL) isChoosingType:(MysticObjectType)type;
+ (BOOL) isChangingType:(MysticObjectType)type;
+ (BOOL) hasChosenType:(MysticObjectType)type;
+ (BOOL) hasConfirmedType:(MysticObjectType)type;
+ (BOOL) hasChosenToCancelType:(MysticObjectType)type;
+ (BOOL) isChangingButMadeNoChoice:(MysticObjectType)type;
+ (BOOL) hasUserAppliedSettingOfType:(MysticObjectType)type;
+ (BOOL) hasUserAppliedSettingOfType:(MysticObjectType)type option:(PackPotionOption *)option;
+ (BOOL) confirmed;

+ (BOOL) isSavingImage;
- (BOOL) effectOfType:(MysticObjectType)type effects:(NSArray *)effects;
+ (UIImage *) imageOfSize:(CGSize)size;
- (BOOL) hasSettingsAppliedOrFilter:(BOOL)checkFilter;

- (void) setDefaults;
+ (BOOL) hasChanges;
- (BOOL) hasChanges;
- (BOOL) hasSettingsApplied;
- (PackPotionOption *) confirmedOptionForType:(MysticObjectType)type;
+ (UIImage *) imageOfSize:(CGSize)size image:(UIImage *)img;
+ (UIImage *) imageOfRenderSize:(UIImage *)img;
- (void) setSourceImage:(UIImage *)sourceImage finished:(MysticBlock)finished;

- (void) preparePhoto:(id)media previewSize:(CGSize)size reset:(BOOL)shouldReset finished:(MysticBlockSizeImagePath)finished;
@end

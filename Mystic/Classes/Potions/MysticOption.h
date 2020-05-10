//
//  MysticOption.h
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticControlObject.h"
#import "GPUImage.h"


@class MysticOption, MysticOptions, MysticPreloaderImage, GPUImageTransformFilter, MysticFilterLayer, MysticImageFilter, MysticImageLayer, PackPotionOptionColor, MysticPack, MysticPackIndex;

@protocol MysticOptionDelegate

@required




@optional

- (void) option:(MysticOption *)option;

@end

@interface MysticOption : MysticControlObject <MysticControlObjectDelegate>
{
    UIImage *_iconImg;
    BOOL _iconImgError;
    BOOL _shouldRender;

}
@property (nonatomic, retain) NSMutableDictionary *tempInfo;
@property (nonatomic, retain) MysticPackIndex *packIndex;
@property (nonatomic, assign) MysticOptionState state;
@property (nonatomic, assign) MysticOptions *owner, *weakOwner;
@property (nonatomic, retain) MysticPreloaderImage *downloader;
@property (nonatomic, readonly) NSString *shortName, *nickName, *layerTitle, *layerSubtitle, *shortDebugDescription, *normalBlendingTitle;
@property (nonatomic, retain) NSArray *downloads;
@property (nonatomic, retain) NSMutableArray *adjustOrder;

@property (nonatomic, copy) MysticBlockSetImageView imageViewBlock;
@property (nonatomic, readonly) NSArray *downloadURLs, *layers, *extraBlendingModes, *blendingModeOptions;
@property (nonatomic, assign) MysticObjectType setting, accessorySetting;
@property (nonatomic, readonly) UIColor *specialColor;
@property (nonatomic, assign) MysticFilterLayer *layer;
@property (nonatomic, retain) MysticFilterLayer *ownedLayer;
@property (nonatomic, assign) NSUInteger instanceIndex;
@property (nonatomic, retain) MysticImageLayer *sourceImage, *renderedImage;
@property (nonatomic, retain) NSString *optionSlotKey;

@property (nonatomic, assign) MysticObjectType editState, browseState, focusState, refreshState;
@property (nonatomic, readonly) NSInteger numberOfDownloads, numberOfDownloadsLeft;
@property (nonatomic, readonly) BOOL hasDownloads, hasDownloadsLeft, canBeChosen, allowNormalBlending, allowNoBlending, requiresFrameRefresh, shouldApplyAdjustmentsFromSimilarOption;
@property (nonatomic, assign) NSInteger numberOfDownloaded, position;
@property (nonatomic, assign) BOOL ignoreRender, featured, isDownloaded, isDownloading, controlWasVisible, readyForRender, prepared, shouldRender, showLayerPreview, isConfirmed, lastPicked, inFocus, isDefaultChoice, hasOverlaysToRender, isRenderableOption, isAdded, canReorder, sourceNeedsRefresh, canReplaceColor, createNewCopy, ignoreActualRender, fillTransparency, canInvertTexture, canChooseCancelColor, userChoiceRequiresImageReload, allowColorReplacement, cameFromFeaturedPack, fillBackgroundColor, requiresCompleteReload, resetAdjustmentsAfterCancel, hasRendered;
@property (nonatomic, assign) GPUImageTransformFilter *transformFilter;
@property (nonatomic, assign) GPUImagePicture *picture;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, assign) NSInteger autoLevel, shaderIndex;
@property (nonatomic, assign) MysticLayerLevelRule levelRules;
@property (nonatomic, assign) MysticImageFilter *imageFilter;
@property (nonatomic, assign) MysticRenderOptions preparedWithSettings;
@property (nonatomic, retain) MysticOption *targetOption;
@property (nonatomic, readonly) BOOL hasSourceImage, isSelectableOption, hasValues;
@property (nonatomic, retain) id sourceImageInput;

+ (id) option;
+ (MysticObjectType) typeForClass:(Class)optionClass;

+ (id) optionWithName:(NSString *)name image:(id)imageOrImageName type:(MysticObjectType)type info:(NSDictionary *)optionInfo;
- (CGFloat) increment:(MysticToolType)toolType;
- (void) valueChanged:(MysticToolType)toolType change:(NSNumber *)amount;
- (void) layerInfo;
- (BOOL) hasObserver:(NSObject *)observer;
- (void) removeAdjustOrder:(MysticObjectType)setting;
- (void) addAdjustOrder:(MysticObjectType)setting;
- (void) resetAdjustOrder;
- (id) tempValueForKey:(id)keyOrSettingObjKey;
- (void) setTempInfo:(id)value key:(id)keyOrSettingObjKey;


- (void) setColorOption:(PackPotionOptionColor *)colorOption;
- (BOOL) containsDownload:(NSString *)urlToDownload;
- (void) addDownload:(NSString *)urlToDownload;
- (void) addDownload:(NSString *)urlToDownload key:(NSString *)key;
- (void) removeDownload:(NSString *)urlToDownload;
- (void) downloadAndNotify:(NSArray *)downloads;
- (void) prepareForSettings:(MysticRenderOptions)settings;
- (BOOL) isPreparedForSettings:(MysticRenderOptions)settings;
- (void) setReadyForRender:(BOOL)value andUpdateObservers:(BOOL)updateObservers;
- (NSString *) keyForURL:(NSURL *)url;
- (NSDictionary *) downloadForURL:(NSURL *)url;
- (NSString *) shortName:(NSInteger)maxLength;
- (GPUImageOutput<GPUImageInput> *) addFilters:(GPUImageOutput<GPUImageInput> *)input layer:(MysticFilterLayer *)layer effects:(MysticOptions *)options context:(NSDictionary *)userInfo;
- (NSInteger) numberOfFiltersMatchingOptions:(MysticFilterOption)filterOptions;
- (NSArray *) filterTypesMatchingOptions:(MysticFilterOption)filterOption;
- (BOOL) hasFiltersMatching:(MysticFilterOption)filterOption;
- (BOOL) updateAllFilters;
- (BOOL) updateFiltersMatching:(MysticFilterOption)filterOption;
- (BOOL) updateFilters;
- (BOOL) updateFilters:(MysticObjectType)settingType;
- (void) reordered;
- (MysticObjectType) refreshStateForState:(MysticObjectType)refreshState;
- (void) update;
- (void) setIcon:(UIImage *)i;
- (id) filter:(id)filterKey;
- (MysticFilterLayer *) layerWithTag:(NSString *)layerTag;
- (NSArray *) adjustmentsTypes:(BOOL)toString;
- (NSArray *) adjustmentsTypesMatching:(MysticFilterOption)filterOption toString:(BOOL)toString;

- (void) setupFilter:(MysticImageFilter *)imageFilter;
- (void) enableState:(MysticOptionState)state;
- (void) disableState:(MysticOptionState)state;

- (MysticImageLayer *) sourceImageAtSize:(CGSize)atSize;
- (MysticImageLayer *) sourceImageAtSize:(CGSize)atSize contentMode:(UIViewContentMode)contentMode;
- (void) confirmCancel;
- (void) resetAdjustments;

@end

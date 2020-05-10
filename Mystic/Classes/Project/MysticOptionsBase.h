//
//  MysticOptionsBase.h
//  Mystic
//
//  Created by Me on 6/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "MysticOptionsProtocol.h"

@class MysticOptions, MysticOptionsManager, MysticPreloaderImage, MysticFilterManager, PackPotionOption, MysticGPUImageView, MysticOption, MysticOptions, MysticImage;


@interface MysticOptionsBase : NSObject <NSFastEnumeration>
@property (nonatomic, assign) NSUInteger indexOfChangedOption, passIndex;
@property (nonatomic, retain) MysticFilterManager *filters;
@property (nonatomic, retain) MysticOptions * parentOptions;
@property (nonatomic, readonly) BOOL hasUnrenderedOptions;
@property (nonatomic, retain) UIImage *sourceImage, *renderedImage;
@property (nonatomic, readonly) MysticImage *currentRenderedImage;
@property (nonatomic, copy) NSString *tagPrefix, *tag, *originalTag;
@property (nonatomic, retain) MysticPreloaderImage *preloader;
@property (nonatomic, copy) MysticBlockDownloadProgress progressBlock, progressBlockCall;
@property (nonatomic, readonly) MysticOptions *liveOptions, *confirmedOptions, *renderOptions, *unchangedSubsetOfOptions, *changedSubsetOfOptions, *topLevelOptions, *topSelf, *nonRenderedOptions;
@property (nonatomic, retain) MysticOptions *liveTargetOptions;
@property (nonatomic, readonly) NSArray *options, *allOptions, *types,  *sortedOptions, *transformingOptions, *sortedAllOptions, *optionsToRender, *sortedRenderOptions, *optionsOrderedByLevel;
@property (nonatomic, readonly) NSDictionary *changedOptions, *renderableOptions;
@property (nonatomic, readonly) NSString *hashTags, *fullDescription, *changedDescription;
@property (nonatomic, readonly) NSInteger totalCount, count, numberOfOptionsToRender, numberOfTextures, numberOfInputs, numberOfShaders, numberOfLiveOptions, nextLevel, previousLevel, highestLevel, lowestLevel, topLevel, numberOfInputTextures, numberOfChangedOptions, numberOfUnrenderedOptions, numberOfRenderedOptions;
@property (nonatomic, assign) BOOL hasChanged, isCancelled, isReady, isRenderOptions, isLive, hasRendered;
@property (nonatomic, readonly) BOOL hasFilters, needsRender, hasMadeChanges, isEmpty, requiresCompleteReload, hasRenderedOptions;
@property (nonatomic, readonly) PackPotionOption *previewOption, *transformingOption, *pickingOption;
@property (nonatomic, assign) CGSize size, smallestTextureSize;
@property (nonatomic, assign) MysticObjectType smallestTextureSizeType;
@property (nonatomic, assign) MysticGPUImageView *imageView;
@property (nonatomic, assign)  MysticRenderOptions settings, optionRules;
@property (nonatomic, assign) NSInteger index, renderIndex;
@property (nonatomic, assign) MysticSortOrder sortOrder;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign)  MysticOptionsManager *manager;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) NSString *optionsUnrenderedAdjustmentsDescription, *optionsAndAdjustmentsDescription, *optionsRenderedAdjustmentsDescription, *optionsAllAdjustmentsDescription;
+ (id) options;
+ (NSString *) renderImageTypeStr:(MysticRenderOptions)settings;
+ (NSString *) renderImageTypeString:(MysticRenderOptions)settings;
+ (MysticRenderOptions) renderImageType:(MysticRenderOptions)settings;
+ (NSInteger) numberOfInputTextures:(id <NSFastEnumeration>)fromOptions includeSubTextures:(BOOL)includeSubs;

+ (void) enable:(MysticRenderOptions)newOption;
+ (void) disable:(MysticRenderOptions)newOption;
+ (BOOL) isEnabled:(MysticRenderOptions)settingOption;
+ (BOOL) isDisabled:(MysticRenderOptions)settingOption;
- (PackPotionOption *) transformingOption:(MysticObjectType)orType orUseOptionOfSameType:(BOOL)forceFind;

- (BOOL) isEnabled:(MysticRenderOptions)settingOption;
- (BOOL) isDisabled:(MysticRenderOptions)settingOption;
- (void) useCleanFilters;

+ (void) reset;
- (id) similarOption:(PackPotionOption *)option;
- (void) reset;
- (void) transform:(PackPotionOption *)option;
- (PackPotionOption *) transformingOption:(MysticObjectType)orType;
- (BOOL) hasInputAboveOption:(PackPotionOption *)option;
- (id) inputAboveOption:(PackPotionOption *)option;
- (void) setTextureSize:(CGSize)textureSize forOption:(PackPotionOption *)option;
- (PackPotionOption *) lastPickedOptionOfType:(MysticObjectType)pickedType;
- (PackPotionOption *) lastPickedOptionOfType:(MysticObjectType)pickedType forState:(MysticOptionState)optionState;

- (void) preloaded:(NSURL *)url;
- (void) setNeedsRender;
- (id) initWithOptions:(NSArray *)opts;
- (NSInteger) nextLevel:(MysticOption *)option;
- (NSInteger) positionOf:(MysticOption *)option;
- (PackPotionOption *) option:(MysticObjectType)type;
- (PackPotionOption *) activeOption:(PackPotionOption *)optionInstance;
- (PackPotionOption *) activeOption:(PackPotionOption *)optionInstance exactMatch:(BOOL)checkForEqual;

- (NSArray *) options:(id)type;
- (NSArray *) options:(id)type forState:(MysticOptionState)optionState;
- (NSInteger) numberOfOption:(PackPotionOption *)option;
- (NSInteger) numberOfOption:(PackPotionOption *)option forState:(MysticOptionState)optionState;
- (NSInteger) numberOfOptions:(id)type;
- (NSInteger) numberOfOptions:(id)type forState:(MysticOptionState)optionState;
- (void) useOptions:(NSArray *)optionsArray;

- (void) prepareForRender;
- (BOOL) isHighestOption:(PackPotionOption *)option;
- (NSInteger) updateInputs;
- (id) makeSlotKeyForOption:(MysticOption *)option;
+ (id) slotKeyForOption:(MysticOption *)option;
+ (id) slotKeyForOption:(MysticOption *)option or:(id)obj;
- (id) makeSlotKeyForOption:(MysticOption *)option force:(BOOL)force;
+ (id) slotKeyForOption:(MysticOption *)option force:(BOOL)force;


- (id) optionForSlotKey:(id)slotKey;
- (void) enable:(MysticRenderOptions)newOption;
- (void) disable:(MysticRenderOptions)newOption;
- (PackPotionOption *) highestOption:(MysticObjectType)type;
- (PackPotionOption *) lowestOption:(MysticObjectType)type;
- (void) recycleFilters:(MysticFilterManager *)junkFilters;
- (BOOL) hasChangedValue;

- (void) load:(MysticRenderOptions)opts progress:(MysticBlockDownloadProgress)progressBlock ready:(MysticBlockSender)onready;
- (void) clean;
- (void) refresh:(MysticOption *)option;
- (NSString *) message:(NSString *)defaultMessage prefix:(NSString *)prefix type:(MysticShareType)shareType;
- (NSInteger) moveDown:(MysticOption *)option;
- (NSInteger) moveUp:(MysticOption *)option;
- (NSInteger) groupIndexOfOption:(PackPotionOption *)option;
+ (NSString *) description:(id)opts;
- (NSDictionary *) changedOptions:(BOOL)changedValue includeAboveOptions:(BOOL)includeAbove;
- (NSArray *) sortedOptions:(NSArray *)opts;
- (void) addOption:(PackPotionOption *)option;
- (void) addOptions:(NSArray *)options;
- (BOOL) removeOption:(MysticOption *)option;
- (BOOL) removeOptions:(NSArray *)options;
- (BOOL) removeOptions:(NSArray *)options cancel:(BOOL)shouldCancel;
- (void) removeAllOptions;

- (BOOL) cancelOption:(PackPotionOption *)option;
- (void) setHasChanged:(BOOL)hv changeOptions:(BOOL)shouldChangeOptions;

- (void) setOptionsToRendered:(NSArray *)options rendered:(BOOL)hasRendered;
- (BOOL) setNeedsRender:(BOOL)value force:(BOOL)force;


- (int) saveCachedImages:(MysticBlock)finished;
- (BOOL) contains:(MysticOption *)option;
- (BOOL) contains:(PackPotionOption *)option equal:(BOOL)checkForEqual;

- (BOOL) contains:(PackPotionOption *)option forState:(MysticOptionState)state;
- (BOOL) contains:(PackPotionOption *)option forState:(MysticOptionState)state equal:(BOOL)checkForEqual;
+ (id) duplicate:(MysticOptions *)optionsSource;
- (id) copyWithOptionsInRange:(NSRange)range;
- (void) liveTargetOptions:(MysticOptions *)value;

- (void) resort;
- (void) prepare;
- (void) unprepare;
- (PackPotionOption *) preloadOptionForURL:(NSURL *)url;
- (void) reorder:(NSArray *)newOrder;
- (void) updateOptions;
- (void) updateOptions:(id)newValue;
- (void) updateOptions:(id)newValue force:(BOOL)useForce;
- (MysticOptions *) render:(MysticOptions *)renders;
- (void) reportStatus;
- (void) finishedRendering;
- (BOOL) setNeedsRender:(BOOL)value;
- (NSInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objs count:(NSUInteger)count;
- (NSEnumerator *) objectEnumerator;
- (NSEnumerator *) reversedObjectEnumerator;
- (void) pick:(PackPotionOption *)option;
- (void) focus:(PackPotionOption *)option;
- (UIImage *) addOverlays:(UIImage *)bgImage;
- (PackPotionOption *) selectableOption:(MysticObjectType)btype;

- (BOOL) confirm:(id)optionOrOptionsOrType;
- (PackPotionOption *) pickingOptionOfType:(MysticObjectType)type;
- (PackPotionOption *) focused:(MysticObjectType)type;

- (MysticImage *) sourceImageForSize:(CGSize)renderSize;

+ (NSInteger) numberOfShaders:(id <NSFastEnumeration>)fromOptions;
+ (NSInteger) numberOfInputs:(id <NSFastEnumeration>)fromOptions;
+ (NSInteger) numberOfInputTextures:(id <NSFastEnumeration>)fromOptions;
+ (PackPotionOption *) makeOption:(MysticObjectType)newType userInfo:(NSDictionary *)info;

@end

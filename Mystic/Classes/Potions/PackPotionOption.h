//
//  PackPotionOption.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//
#import "MysticOption.h"
#import "MysticConstants.h"
#import "GPUImage.h"
#import "MysticLayerRenderQueue.h"


@class EffectControl, MysticImageLayer, MysticPack, PackPotionOptionMulti;

@interface PackPotionOption : MysticOption
@property (nonatomic, retain) PackPotionOptionMulti *multiOption;
@property (nonatomic, retain) MysticPack *activePack;
@property (nonatomic, retain) NSMutableArray *observeProps;
@property (nonatomic, readonly) PackPotionOption *activeOption;
@property (nonatomic, retain) PackPotionOption *targetOption;
@property (nonatomic, readonly) NSString *imageExtension, *imageName, *imageNameExtension;
@property (nonatomic, assign) PackPotionOption *manager;
@property (nonatomic, assign) PackPotionOption *optionToReplace;
@property (nonatomic, assign) MysticBrush maskBrush;
@property (nonatomic, assign) MysticPosition rotatePosition;
@property (nonatomic, readonly) MysticImageType layerImageType;
@property (nonatomic, readonly) NSInteger count, autoLayerLevel;
@property (nonatomic, assign) MysticShaderIndex shaderIndexPath;
@property (nonatomic, assign) MysticFilterType vignetteBlendingType;

@property (nonatomic, readonly) MysticFilterType originalBlendingMode, filterType, blendingType, normalBlendingType, adjustedBlendingType;
@property (nonatomic, assign) MysticLayerEffect maxLayerEffect;
@property (nonatomic, assign) MysticColorType foregroundColorType, backgroundColorType;
@property (nonatomic, readonly) UIImageResizingMode fillMode;
@property (nonatomic, assign) MysticStretchMode stretchMode;
@property (nonatomic, readonly) NSInteger smartLevel;
@property (nonatomic, readonly) CGBlendMode CGBlendMode;
@property (nonatomic, readonly) NSInteger numberOfAdjustments, numberOfInputTextures;

@property (nonatomic, retain) NSMutableDictionary *colorTypes, *resourcePaths, *renderedAdjustments;
@property (nonatomic, assign) NSUInteger stackPosition;

@property (nonatomic, readonly) UIImage *layerImage, *layerPreviewImage, *layerThumbImage, *layerOriginalImage, *alphaMaskImage;
@property (nonatomic, retain) UIImage *thumbnail, *thumbnailHighlighted, *thumbnailSelected;
@property (nonatomic, assign) UIImage *maskImage, *customLayerImage, *mapImage;
@property (nonatomic, retain) NSString *maskImagePath, *mapImagePath;
@property (nonatomic, assign) MysticObjectType stretchModeSetting;
@property (nonatomic, readonly) UIEdgeInsets stretchingInsets;
@property (nonatomic, assign) CGSize layerImageSize, originalImageSize, thumbImageSize, previewImageSize;

@property (nonatomic, assign) BOOL ignoreRender, featured, userProvidedImage, hasChanged, isTransforming, controlWasVisible, readyForRender, isHTMLEmail, hasImage, isPreviewOption, canFillBackgroundColor, canFillTransformBackgroundColor, hasTextureCoordinate, ignoreUnadjustedAdjustments, hasProcessedThumbnail, forceReizeLayerImage;

@property (nonatomic, readonly) BOOL hasFlip, shouldInvert, hasAdjustments, canTransform, hasForegroundColor, isBlended, hasInput, hasShader, isActive,  hasAlphaMask, hasAlphaChannel, shouldRegisterForChanges, usesAccessory, showInLayers, hasCustomLayerEffects, canBeConfirmed, hasCustomShader, resizeLayerImage, hasUnRenderedAdjustments, hasMaskImage, hasMapImage, hasPreAdjustments, hasPostAdjustments, useSourceImageForPreview, hasGrain;
@property (nonatomic, readonly) NSString *blendingModeStr, *blending, *backgroundColorVec4Str,  *stackPositionKey, *hashTags, *alphaMaskImageURLString;
@property (nonatomic, retain) NSString *uniqueTag;
@property (nonatomic, readonly) id customShaderString;
@property (nonatomic, readonly) NSDictionary* customShader;


@property (nonatomic, readonly) NSDictionary *adjustments, *userInfo, *unRenderedAdjustments, *allAdjustments, *textures, *adjustmentsAndRefreshingAdjustments;

@property (nonatomic, readonly) NSArray *availableAdjustmentTypes,  *availablePostAdjustmentTypes, *availablePreAdjustmentTypes, *orderedAvailableAdjustmentTypes, *orderedAvailablePreAdjustmentTypes, *orderedAvailablePostAdjustmentTypes, *refreshingAdjustments;



#pragma mark - User Defined Settings

@property (nonatomic, assign) MysticLayerEffect layerEffect;

@property (nonatomic, assign) CGAffineTransform transform, rotateTransform, transformXY, transformOnlyXY, transformTextureXY, transformTextureOnlyXY;

@property (nonatomic, assign) GPUMatrix4x4 colorMatrix;

@property (nonatomic, retain) NSString *blendingMode, *tweet, *facebook, *emailMessage, *emailTo, *emailCC, *emailBCC, *emailSubject, *pinterest, *messageLink, *folderName, *layerImagePath, *previewImagePath, *originalLayerImagePath, *sourceImageURL, *thumbnailImagePath;

@property (nonatomic, retain) UIColor *backgroundColor, *foregroundColor, *chromaColor, *realBackgroundColor, *originalForegroundColor, *maskBackgroundColor, *transformBackgroundColor, *falseDarkColor, *falseLightColor, *shadowTintColor, *highlightTintColor, *vignetteColor, *grainColor, *halftoneHighlight, *halftoneShadow, *sketchHighlight, *sketchShadow;



@property (nonatomic, assign) BOOL anchorTopLeft, ignoreAspectRatio,  presetSunshine, presetBlending, presetInvert, inverted, blended, stretchLayerImage, applySunshine, flipHorizontal, flipVertical, desaturate, smoothing, showBg, autoEnhance, hasSetAdjustmentTransformRect, flipTextureHorizontal, flipTextureVertical, shouldBlendWithPreviousTextureFirst;
@property (nonatomic, assign) CGPoint vignetteCenter;
@property (nonatomic, assign) float colorMatrixIntensity, vibrance, brightness, gamma, exposure, highlights, shadows, sharpness, contrast, vignetteStart, vignetteEnd, saturation, vignetteValue, tiltShift, rotation, alpha,haze, hazeSlope, blackLevels, midLevels, whiteLevels, unsharpMask, presetIntensity, intensity, smoothingSensitivity, sensitivity, tint, temperature, wearAndTear, wearAndTearValue, minBlackLevel, maxWhiteLevel, midLevelsValueFixed, shadowIntensity, highlightIntensity, mapBrightest, mapDarkest, grainThreshold, grainTime, grainAlpha;


@property (nonatomic, assign) CGFloat sphereRadius, sphereRefractiveIndex, pixellatePixelWidth, halftonePixelWidth, sketchStrength, sketchWidth, sketchHeight, toonWidth, toonHeight, toonThreshold, toonLevels,swirlRadius,swirlAngle,pinchRadius,pinchScale,tiltShiftTop, tiltShiftBottom, tiltShiftBlurSizeInPixels, tiltShiftFallOff, unsharpBlurRadius, buldgeRadius, buldgeScale, blurCircleRadius,blurCircleExcludeRadius,blurCircleExcludeSize,blurCircleAspectRatio,blurZoomSize,blurMotionSize,blurMotionAngle, blurRadius,blurRadiusFractionWidth,blurRadiusFractionHeight;
@property (nonatomic, assign) NSInteger blurPasses,posterizeLevels;

@property (nonatomic, assign) CGPoint sphereCenter, stretchCenter, pinchCenter, buldgeCenter, swirlCenter,blurZoomCenter, blurCirclePoint;


@property (nonatomic, assign) CGFloat skinToneAdjust, skinHue, skinHueMaxShift, skinMaxSaturation, skinHueThreshold;
@property (nonatomic, assign) int skinUpperTone;

@property (nonatomic, assign) float blackLevelsRed, midLevelsRed, whiteLevelsRed, minBlackLevelRed, maxWhiteLevelRed, midLevelsValueRed;
@property (nonatomic, assign) float blackLevelsGreen, midLevelsGreen, whiteLevelsGreen, minBlackLevelGreen, maxWhiteLevelGreen, midLevelsValueGreen;
@property (nonatomic, assign) float blackLevelsBlue, midLevelsBlue, whiteLevelsBlue, minBlackLevelBlue, maxWhiteLevelBlue, midLevelsValueBlue;

@property (nonatomic, readonly) float hsbHue, hsbBrightness, hsbSaturation, hazeSlopeValue, midLevelsValue;

@property (nonatomic, assign) MysticHSB hsb;

@property (nonatomic, assign) MysticAttr attributes;

@property (nonatomic, assign) GPUVector3 rgb;
@property (nonatomic, assign) CGRect transformRect, cropRect, adjustedRect,  transformRectNormal, originalTransformRect, transformRectInitial;
@property (nonatomic, readonly) NSString *adjustmentsDescription, *allAdjustmentsDescription, *unrenderedAdjustmentsDescription, *renderedAdjustmentsDescription;
@property (nonatomic, readonly) NSArray *adjustedColors, *adjustColorsFinal,*adjustColorsRender, *adjustColorsSourceColors;
@property (nonatomic, readonly) NSDictionary*lastAdjustColorInfo;
@property (nonatomic, readonly) UIColor*lastAdjustColor;
@property (nonatomic, readonly) NSInteger lastAdjustColorIndex;
@property (nonatomic, retain) NSMutableArray *adjustColors;

- (NSString *) uniqueTag:(NSArray *)onlyKeys ignoreKeys:(NSArray *)ignoreKeys;

+ (PackPotionOption *) optionWithType:(MysticObjectType)optionType info:(NSDictionary *)info;

- (void) setRefreshAdjustments:(id)value;
- (void) addRefreshAdjustments:(id)value;
- (void) removeRefreshAdjustments:(id)value;
- (BOOL) isRefreshingAdjustments:(id)value;
- (BOOL) isRefreshingAdjustment:(MysticObjectType)value;
- (void) updateTransform:(BOOL)allTransforms;

- (MysticAdjustColorInfo) adjustColor:(UIColor *)c toColor:(UIColor *)c2 intensity:(float)a point:(CGPoint)p1 threshold:(MysticThreshold)threshold index:(NSInteger)i;

- (NSInteger) indexOfAdjustColor:(UIColor *)color;
- (UIColor *) adjustedColorAtIndex:(NSInteger)index;
- (CGFloat) adjustColorIntensityAtIndex:(NSInteger)index;
- (NSDictionary *) adjustColorAtIndex:(NSInteger)i;
- (BOOL) removeAdjustColorAtIndex:(NSInteger)i;
- (void) finalizeAdjustColors;
- (void) removeAdjustColors;
- (BOOL) hasRenderedAdjustment:(MysticObjectType)setting;

- (void) setBlending:(NSString *)value;
- (void) setBlendingType:(MysticFilterType)value;
- (void) resetBlending;
- (NSString *) uniqueTagForSize:(CGSize)size;
- (BOOL) hasTag:(NSString *)tag;
- (BOOL) belongsToPack:(MysticPack *)pack;

- (BOOL) isSame:(PackPotionOption *)asOption;
- (BOOL) inState:(MysticOptionState)state;
- (void) setValue:(id)value forSetting:(MysticObjectType)adjustmentType;

- (void) layerImage:(MysticBlockImage)layerImageFinished;
- (void) setColorType:(MysticOptionColorType)optType color:(id)color;
- (UIColor *) color:(MysticOptionColorType)ctype;
- (void) resetTransform;
- (MysticColorType) colorType:(MysticOptionColorType)ctype;
- (MysticColorType) colorTypeValue:(MysticOptionColorType)ctype;

- (BOOL) hasAdjusted:(MysticObjectType)type;
- (MysticImageLayer *) layerImageForSize:(CGSize)renderSize allowDownload:(BOOL)allowDownload;
- (MysticImageLayer *) layerImageForSize:(CGSize)renderSize;
- (MysticImageLayer *) image:(MysticOptions *)effects;
- (MysticImageLayer *) imageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize;
- (MysticImageLayer *) layerImageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize;
- (NSString *) layerImageKeyForSize:(CGSize)renderSize;
- (void) layerImageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize finished:(MysticBlockImage)finishedImageBlock;
- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption;
- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption setting:(MysticObjectType)setting;
- (void) applyPreviousAdjustmentsFrom:(PackPotionOption *)otherOption;
- (void) applyAdjustments:(NSDictionary *)theAdjustments;

- (NSInteger) setUserChoiceLevel;
- (void) setUserInfo:(NSDictionary *)userInfo;
- (void) addResourcePath:(NSString *)path name:(NSString *)resourceName;
- (UIImage *) imageForSize:(CGSize)renderSize download:(BOOL)shouldDownload;
- (void) updateTag;

- (NSInteger) moveUp;
- (NSInteger) moveDown;
- (void) setDefaultSettings;
- (int) saveCachedImages:(MysticBlock)finished;
- (NSString *) uniqueTag:(NSArray *)keys;
- (NSString *) uniqueTagIgnore:(NSArray *)keys;
- (void) setMapImage:(UIImage *)image complete:(MysticBlock)complete;

- (void) registerForChangeNotification;
- (void)unregisterForChangeNotification;
- (UIImage *) render:(MysticOptions *)effects background:(UIImage *)bgImage;
- (BOOL) reset:(MysticObjectType)adjustmentType;
- (id) setUserChoice:(BOOL)force finished:(MysticBlock)finished;
- (BOOL) hasUserSelectedColorOfOptionType:(MysticOptionColorType)ctype;
- (NSString *) downloadUrlForSettings:(MysticRenderOptions)settings;
- (id) valueForType:(MysticObjectType)type;
- (void) resetAdjustments;
- (void) setAdjustmentsToRendered:(NSDictionary *)theAdjustments;
- (void) setAdjustmentsToRendered;
- (MysticAdjustmentState) adjustmentState:(MysticObjectType)type;
- (NSString *) adjustmentsDescription:(id)adj;
- (void) undoAdjustment:(MysticObjectType)adjustmentType;
- (void) undoLastAdjustment;
- (void) setMaskImage:(UIImage *)image complete:(MysticBlock)complete;
- (void) setCustomLayerImage:(UIImage *)image complete:(MysticBlock)complete;
- (NSString *) printAdjustColors:(NSString *)prefix;
- (void) removeOption;
@end


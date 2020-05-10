//
//  MysticTypedefs.h
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#ifndef MysticTypedefs_h
#define MysticTypedefs_h

#import "MysticDefinitions.h"

@class MysticAnimationBlockObject, MysticButton, MysticBarButtonItem, MysticTools, MysticTransformButton, MysticDrawingContext, MysticAttrString, MysticSlider, PackPotionOption, MysticScrollView, MysticInputView;
@protocol MysticLayerViewAbstract;

typedef void (^MysticBlockAnimation)();
typedef NSDictionary * (^MysticBlockAnimationInfo)();

typedef void (^MysticBlockAnimationFinished)(BOOL finished);
typedef void (^MysticBlockAnimationCompleteBOOL)(BOOL finished);

typedef void (^MysticBlockAnimationComplete)(BOOL finished, MysticAnimationBlockObject *obj);
typedef void (^MysticBlockAnimationCompleteForward)(MysticBlockAnimationComplete animBlock, BOOL finished, MysticAnimationBlockObject *obj);

typedef void (^MysticBlockAnimationKeyFrame)(float start, float time);

typedef void (^MysticBlockTouch)(NSSet *touches, UIEvent*event, id sender);
typedef void (^MysticBlockTouchTap)(UITouch *touch, UIEvent*event, id sender);
typedef void (^MysticBlockTouchDoubleTap)(UITouch *touch, UIEvent*event, id sender);

typedef void (^MysticBlock)();
typedef void (^MysticBlockSender)(id sender);
typedef void (^MysticBlockButton)(MysticButton *sender);

typedef void (^MysticBlockColorButton)(id sender, UIColor *color, id obj, BOOL success);

typedef void (^MysticBlockObject)(id object);
typedef float (^MysticBlockSliderValue)(float value, BOOL setValue, id slider);

typedef void (^MysticBlockString)(NSString *string);
typedef void (^MysticBlockObjBOOL)(id obj, BOOL success);
typedef void (^MysticBlockObjBOOLBOOL)(id obj, BOOL bool1, BOOL bool2);

typedef void (^MysticBlockObjBOOLObj)(id obj, BOOL success, id context);
typedef void (^MysticBlockSetImageView)(id view, MysticBlockObjBOOL c);
typedef void (^MysticDrawBlock)(CGContextRef context, CGRect rect, CGRect bounds, UIView *view);
typedef void (^MysticBlockObjObj)(id obj, id obj2);
typedef void (^MysticBlockObjObjBOOL)(id obj, id obj2, BOOL success);
typedef void (^MysticBlockObjObjObjBOOL)(id obj, id obj2, id obj3, BOOL success);

typedef void (^MysticBlockObjObjObj)(id obj, id obj2, id obj3);
typedef void (^MysticBlockPathChoice)(id obj, id obj2, CGContextRef context);

typedef void (^MysticBlockArrayBOOL)(NSArray *objs, BOOL success);
typedef void (^MysticBlockArray)(NSArray *objs);

typedef id (^MysticBlockMakeTile)(int index, id data, CGRect frame, MysticScrollView *scrollView);
typedef void (^MysticBlockUpdateTile)(int index, id data, id tile, BOOL selected, MysticScrollView *scrollView);
typedef void (^MysticBlockOption)(id option, MysticBlockObjObj finished);


typedef void (^MysticBlockDownloadEffects)(NSInteger currentIndex, NSInteger totalDownloads, BOOL finished);
typedef void (^MysticBlockBOOL)(BOOL active);

typedef void (^MysticBlockBOOLComplete)(BOOL active, MysticBlock completed);
typedef void (^MysticBlockAssetsGroup)(id object, MysticBlockObjObjBOOL finished);

typedef void (^MysticBlockSize)(CGSize size);
typedef void (^MysticBlockSizeImage)(CGSize size, UIImage *image);
typedef void (^MysticBlockSizeImagePath)(CGSize size, UIImage *image, NSString *filePath);

typedef void (^MysticBlockImage)(UIImage *image);
typedef void (^MysticBlockImageObj)(UIImage *image, id obj);
typedef void (^MysticBlockImageObjOptions)(UIImage *image, id obj, id options, BOOL cancelled);
typedef void (^MysticBlockImageObjOptionsPass)(UIImage *image, id obj, id options, BOOL cancelled, MysticBlockImageObjOptions nextPassBlock);

typedef void (^MysticBlockDownloadProgress)(NSUInteger receivedSize, NSUInteger expectedSize);
typedef void (^MysticBlockProgress)(CGFloat percentDone);
typedef void (^MysticBlockNeedsBlock)(MysticBlock block);
typedef void (^MysticBlockNeedsArray)(NSArray *array);
typedef void (^MysticBlockAPI)(NSDictionary *results, NSError *error);
typedef void (^MysticBlockAPIUpload)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^MysticBlockRender)(UIImage *image, NSIndexSet *levels, NSIndexSet *cachedLevels, NSUInteger reloadIndex);
typedef void (^ActionBlock)();
typedef void (^MysticBlockObjObjComplete)(id object, id obj2, MysticBlockObjBOOL completed);
typedef void (^MysticAlertBlock)(id obj1, id obj2);
typedef BOOL (^MysticBlockReturnsBOOL)(id object);
typedef id (^MysticBlockReturnsObj)(id object);
typedef NSString *(^MysticBlockObjString)(id obj);
typedef id (^MysticBlockFilteredObj)(id object, BOOL *stop);
typedef id (^MysticBlockFilteredKeyObj)(id key, id object, BOOL *stop);
typedef id (^MysticBlockFilteredKeyObjBOOL)(id key, id object, BOOL finished, BOOL *stop);
typedef UIImage* (^MysticBlockReturnsImageFromObj)(id object);

typedef void (^MysticBlockLayerView)(id <MysticLayerViewAbstract> layer);
typedef void (^MysticSliderBlock)(MysticSlider *slider);


typedef MysticButton* (^MysticBlockButtonItem)(MysticButton *button, MysticBarButtonItem *item);

typedef UIImage *(^MysticBlockReturnsImage)(CGSize newSize);

typedef UIImage *(^MysticBlockReturnsImageFromView)(UIView *view, CGSize size, CGFloat scale);


typedef NSArray *(^MysticBlockReturnsArray)();
typedef NSString *(^MysticBlockKeyString)(NSString *key);
typedef NSString *(^MysticBlockKey)(id key);

typedef id (^MysticObjBlock)();
typedef void (^EffectContolAction)(id sender, BOOL selected);
typedef void (^MysticChoiceBlock)(id sender, BOOL selected);

typedef enum {
    MysticSketchToolTypeMask = 0,
    MysticSketchToolTypeMaskErase,
    MysticSketchToolTypeSketch,
    MysticSketchToolTypePaint,
    MysticSketchToolTypeAirBrush,
    
} MysticSketchToolType;

typedef enum
{
    MysticBrushTypeDefault = 0,
    MysticBrushTypeGrunge,
    MysticBrushTypePen,
    MysticBrushTypePencil,
    MysticBrushTypeWatercolor,
} MysticBrushType;


struct MysticBrush {
    MysticBrushType type;
    CGFloat size;
    CGFloat opacity;
    CGFloat feather;
    CGFloat minSize;
    CGFloat maxSize;


};
typedef struct MysticBrush MysticBrush;

typedef enum  {
    MysticBrushSettingAll=-1,
    MysticBrushSettingType,
    MysticBrushSettingSize,
    MysticBrushSettingOpacity,
    MysticBrushSettingFeather,
} MysticBrushSetting;

extern MysticBrush const MysticBrushDefault;



struct MysticShaderIndex {
    NSInteger stackIndex;
    NSInteger index;
    NSInteger count;
    NSInteger previousIndex;
    NSInteger offset;
};
typedef struct MysticShaderIndex MysticShaderIndex;

extern MysticShaderIndex const MysticShaderIndexUnknown;

typedef struct MFRange {
    float location;
    float length;
    float centerLength;
    float center;
} MFRange;

typedef enum
{
    MysticUserRememberBetaVersion,
    
} MysticUserRemember;

typedef enum
{
    MysticVersionLight = 1,
    MysticVersionCosmos,
} MysticVersion;

typedef enum {
    MysticLayerControlNone                   = 1 << 0,
    MysticLayerControlDelete                 = 1 << 1,
    MysticLayerControlResize                 = 1 << 2,
    MysticLayerControlCustom                 = 1 << 3,
    MysticLayerControlHandles                = 1 << 4,
    MysticLayerControlHandleTop              = 1 << 5,
    MysticLayerControlHandleBottom           = 1 << 6,
    MysticLayerControlHandleLeft             = 1 << 7,
    MysticLayerControlHandleRight            = 1 << 8,
    MysticLayerControlBorder                 = 1 << 9,
    MysticLayerControlContent                = 1 << 10,
    MysticLayerControlAll                    = 1 << 20,
    MysticLayerControlAllExceptContent       = 1 << 21,
    MysticLayerControlMax                    = 1 << 30,
} MysticLayerControl;

typedef enum
{
    MysticColorInputOptionNone = 1 << 0,
    MysticColorInputOptionHex = 1 << 1,
    MysticColorInputOptionAlpha = 1 << 2,
    MysticColorInputOptionRecent = 1 << 3,
    MysticColorInputOptionLibrary = 1 << 4,
    
} MysticColorInputOptions;
typedef enum
{
    MysticToolsTransformTypeNone = 0,
    MysticToolsTransformUp,
    MysticToolsTransformDown,
    MysticToolsTransformLeft,
    MysticToolsTransformRight,
    MysticToolsTransformPlus,
    MysticToolsTransformMinus,
    MysticToolsTransformRotateLeft,
    MysticToolsTransformRotateRight,
    MysticToolsTransformFlipLandscape,
    MysticToolsTransformFlipPortrait,
    MysticToolsTransformWidthPlus,
    MysticToolsTransformWidthMinus,
    MysticToolsTransformHeightPlus,
    MysticToolsTransformHeightMinus,
    MysticToolsTransformRotateClockwise,
    MysticToolsTransformRotateCounterClockwise,
    
} MysticToolsTransformType;
typedef void (^MysticBlockTools)(MysticTransformButton *button, MysticToolsTransformType transformType, MysticTools *tools, BOOL finished);

typedef enum
{
    MysticProjectKeyPrefix = 5432,
    MysticProjectKeyOptions = 543210,
    MysticProjectKeyOptionGroup,
    MysticProjectKeyTag,
    MysticProjectKeyLevel,
    MysticProjectKeyAdjustments,
    MysticProjectKeyImageOriginalPath,
    MysticProjectKeyImageSrcPath,
    MysticProjectKeyImageResizedPath,
    MysticProjectKeyImageThumbPath,
    MysticProjectKeyRenderSize,
    MysticProjectKeyHistory,
    MysticProjectKeyLastHistory,
    MysticProjectKeyHistoryIndex,
    MysticProjectKeyHistoryChangeIndex,
    MysticProjectKeyImageThumb,
    MysticProjectKeyPotionName,
    MysticProjectKeyPotionDescription,
    MysticProjectKeyOptionLayerEffect,
    
    
    
} MysticProjectKeys;


typedef enum
{
    MysticDataStateNone                            = 1 << 0,
    MysticDataStateInit                            = 1 << 1,
    MysticDataStateStart                            = 1 << 2,
    MysticDataStateFinish                            = 1 << 3,
    MysticDataStateError                            = 1 << 4,
    MysticDataStateCached                            = 1 << 5,
    MysticDataStateChanged                            = 1 << 6,
    MysticDataStateDownloading                      = 1 << 7,
    MysticDataStateNew                          = 1 << 8,
    MysticDataStateCachedLocal                  = 1 << 9,
    MysticDataStateCachedServer                 = 1 << 10,
    MysticDataStateComplete                     = 1 << 11,
    
    
    
} MysticDataState;

typedef void (^MysticBlockData)(id data, MysticDataState dataState);


typedef enum
{
    MysticCollectionFilterNone                      = 1 << 0,
    MysticCollectionFilterAll                       = 1 << 1,
    MysticCollectionFilterRecent                    = 1 << 2,
    MysticCollectionFilterUserRecent                = 1 << 3,
    MysticCollectionFilterFavorites                 = 1 << 4,
    
    
    
} MysticCollectionFilter;

typedef enum
{
    MysticAnimationTypeNone                      = 1 << 0,
    MysticAnimationTypeNormal                       = 1 << 1,
    MysticAnimationTypeKeyFrame                    = 1 << 2,
    MysticAnimationTypeSpring                       = 1 << 3,
    
    
    
} MysticAnimationType;

typedef enum {
    MysticCollectionItemTypeUnknown = 0,
    MysticCollectionItemTypeBlock,
    MysticCollectionItemTypeText,
    MysticCollectionItemTypeImage,
    MysticCollectionItemTypeAttributedText,
    MysticCollectionItemTypeLink,
    MysticCollectionItemTypeButton,
    MysticCollectionItemTypeHTML,
    MysticCollectionItemTypeVideo,
    MysticCollectionItemTypeColor,
    MysticCollectionItemTypeGradient,
    
} MysticCollectionItemType;

typedef enum {
    
    MysticSizeOptionNone  = 1<<0,
    MysticSizeOptionMatchLeast = 1<< 1,
    MysticSizeOptionMatchGreatest = 1<<2,
    
    MysticSizeOptionMatchWidth = 1<<3,
    MysticSizeOptionMatchHeight = 1<<4,
    
    
    MysticSizeOptionMatchDefault = MysticSizeOptionMatchGreatest,
    
    
} MysticSizeOptions;

typedef enum {
    MysticToolTypeUnknown = 0,
    MysticToolTypeNoMarginLeft,
    MysticToolTypeNoMarginRight,
    MysticToolTypeIntensity,
    MysticToolTypeColor,
    MysticToolTypeColorAndIntensity,
    MysticToolTypeSize,
    MysticToolTypeBlend,
    MysticToolTypeSettings,
    MysticToolTypeLayerSettings,
    MysticToolTypeLayerEffects,
    MysticToolTypeLayerHSB,
    MysticToolTypeLayerHSBHue,
    MysticToolTypeLayerHSBSaturation,
    MysticToolTypeLayerHSBBrightness,
    MysticToolTypeLayerShadow,
    MysticToolTypeSeparator,
    MysticToolTypeNoSpace,
    MysticToolTypeSizeWidth,
    MysticToolTypeSizeHeight,
    MysticToolTypePaddingVertical,
    MysticToolTypePaddingHorizontal,
    MysticToolTypeAlignToContainer,
    MysticToolTypeAlignVertical,
    MysticToolTypeAlignLeft,
    MysticToolTypeAlignRight,
    MysticToolTypeAlignCenter,
    MysticToolTypeAlignFull,
    MysticToolTypeLineHeight,
    MysticToolTypeTextAlign,
    MysticToolTypePadding,
    MysticToolTypeReset,
    MysticToolTypeBrowse,
    MysticToolTypeBrowsePacks,
    MysticToolTypeVariant,
    MysticToolTypeMove,
    MysticToolTypeMoveUp,
    MysticToolTypeMoveDown,
    MysticToolTypeTitle,
    MysticToolTypeManageLayers,
    MysticToolTypeFont,
    MysticToolTypeFontVariant,
    MysticToolTypeFonts,
    MysticToolTypeFontSize,
    MysticToolTypeFontSpacing,
    MysticToolTypeRotate,
    MysticToolTypeRotateAndFlip,
    MysticToolTypeRotateLeft,
    MysticToolTypeRotateRight,
    MysticToolTypeRotateClockwise,
    MysticToolTypeRotateCounterClockwise,
    MysticToolTypeEditLayer,
    MysticToolTypeFlipHorizontal,
    MysticToolTypeFlipVertical,
    MysticToolTypeSizeBigger,
    MysticToolTypeSizeSmaller,
    MysticToolTypeDots,
    MysticToolTypeFontLineHeight,
    MysticToolTypeMask,
    MysticToolTypeMaskEmpty,
    MysticToolTypeMaskFill,
    MysticToolTypeMaskBrush,
    MysticToolTypeMaskErase,
    MysticToolTypeMaskShape,
    MysticToolTypeMaskTexture,
    MysticToolTypeMaskFeather,
    MysticToolTypeMaskSize,
    MysticToolTypeMaskOpacity,
    MysticToolTypeAdd,
    MysticToolTypeDuplicate,
    MysticToolTypeRemove,
    MysticToolTypeGrid,
    MysticToolTypeAlign,
    MysticToolTypeFilter,
    MysticToolTypeTexture,
    MysticToolTypeBadge,
    MysticToolTypeFrame,
    MysticToolTypeLight,
    MysticToolTypeCam,
    MysticToolTypeCamLayer,
    MysticToolTypeDesign,
    MysticToolTypeText,
    MysticToolTypePotion,
    MysticToolTypeLogo,
    MysticToolTypeShare,
    MysticToolTypeCustom,
    MysticToolTypeFlexible,
    MysticToolTypeStatic,
    MysticToolTypeDelete,
    MysticToolTypeCancel,
    MysticToolTypeClose,
    MysticToolTypeConfirm,
    MysticToolTypeMoveAndSize,
    MysticToolTypePanUp,
    MysticToolTypePanDown,
    MysticToolTypePanLeft,
    MysticToolTypePanRight,
    MysticToolTypeOpenPack,
    MysticToolTypeNoPadding,
    MysticToolTypeHashTags,
    MysticToolTypeFavorites,
    MysticToolTypeRecents,
    MysticToolTypeAll,
    MysticToolTypeList,
    MysticToolTypeKnob,
    MysticToolTypeForward,
    MysticToolTypeBack,
    MysticToolTypeSlider,
    MysticToolTypeContent,
    MysticToolTypePosition,
    MysticToolTypeShadow,
    MysticToolTypeBorder,
    MysticToolTypeEmboss,
    MysticToolTypeBevel,
    MysticToolTypeInnerBevel,
    MysticToolTypeInnerShadow,
    MysticToolTypeStaticHeader,
    MysticToolTypeStaticFooter,
    
} MysticToolType;

typedef enum {
    MysticToolbarStateNone,
    MysticToolbarStateBrowse,
    MysticToolbarStateEdit,
    MysticToolbarStateBlending,
    MysticToolbarStateSettings,
    MysticToolbarStateSearch,
    MysticToolbarStateCustom
} MysticToolbarState;

typedef enum {
    MysticOptionColorTypeBackground,
    MysticOptionColorTypeForeground,
    MysticOptionColorTypeChromaKey,
    MysticOptionColorTypeUnknown,
    
} MysticOptionColorType;


typedef enum {
    MysticLayoutModeSpacedHorizontally,
    MysticLayoutModeSpacedVertically,
    MysticLayoutModeCenterHorizontally,
    MysticLayoutModeCenterVertically,
    MysticLayoutModeCentered
    
} MysticLayoutMode;

typedef enum {
    MysticDrawerSectionMain = -1,
    MysticDrawerSectionLayers = 0,
    MysticDrawerSectionAdd,
    MysticDrawerSectionAddSpecial,
    
} MysticDrawerSection;

typedef enum  {
    MysticScrollDirectionNone,
    MysticScrollDirectionLeft,
    MysticScrollDirectionRight,
    MysticScrollDirectionUp,
    MysticScrollDirectionDown,
    MysticScrollDirectionCrazy,
    MysticScrollDirectionVertical,
    MysticScrollDirectionHorizontal,
    MysticScrollDirectionVerticalAndHorizontal,
} MysticScrollDirection;

typedef enum
{
    MysticStoreTypeDefault,
    MysticStoreTypeText,
    MysticStoreTypeTextures,
    MysticStoreTypeFilters,
    MysticStoreTypeLights,
    MysticStoreTypeFrames,
    MysticStoreTypeFeatures,
    MysticStoreTypeFonts,
    MysticStoreTypeShapes,
    MysticStoreTypeColors,
} MysticStoreType;

typedef enum
{
    MysticCacheTypeNone,
    MysticCacheTypeMemory,
    MysticCacheTypeDisk,
    MysticCacheTypeMemoryOrDisk,
    MysticCacheTypeProject,
    MysticCacheTypeImage,
    MysticCacheTypeWeb,
    MysticCacheTypeLayer,
    MysticCacheTypeTemp,
    MysticCacheTypeUI,
    MysticCacheTypeDownloads,
    
} MysticCacheType;

typedef enum {
    MysticBackgroundTypeUnknown = 0,
    MysticBackgroundTypePhoto,
    MysticBackgroundTypeBackground,
    MysticBackgroundTypeColor,
    MysticBackgroundTypeLight,
    MysticBackgroundTypeDark,
    
} MysticBackgroundType;

typedef enum
{
    MysticRenderTypePreview,
    MysticRenderTypeLow,
    MysticRenderTypeMedium,
    MysticRenderTypeHigh,
    
} MysticRenderType;

typedef enum
{
    MysticSnapPositionNone,
    MysticSnapPositionAll,
    MysticSnapPositionCenter,
    MysticSnapPositionCenterHorizontal,
    MysticSnapPositionCenterVertical,
    MysticSnapPositionCenters,
    MysticSnapPositionBounds,
    MysticSnapPositionCorners
    
} MysticSnapPosition;

typedef enum
{
    MysticTextAlignmentNSDefault,
    MysticTextAlignmentNSCenter = MysticTextAlignmentNSDefault,
    MysticTextAlignmentNSLeft,
    MysticTextAlignmentNSRight,
    MysticTextAlignmentNSJustified,
    
    
    MysticTextAlignmentDefault,
    MysticTextAlignmentCenter = MysticTextAlignmentDefault,
    MysticTextAlignmentLeft,
    MysticTextAlignmentRight,
    MysticTextAlignmentFill,
    MysticTextAlignmentJustified,
    MysticTextAlignmentJustifiedRight,
    
    
} MysticTextAlignment;


typedef enum
{
    MysticLayerPanelStateUnknown = -1,
    MysticLayerPanelStateUnInit,
    MysticLayerPanelStateInit,
    MysticLayerPanelStateOpen,
    MysticLayerPanelStateClosed,
    MysticLayerPanelStateHidden,
    MysticLayerPanelStateOpening,
    
    
} MysticLayerPanelState;


typedef enum
{
    MysticPanelTypeUnknown=-1,
    MysticPanelTypeNone,
    MysticPanelTypeOptionLayer,
    MysticPanelTypeCustom,
    MysticPanelTypeBlend,
    MysticPanelTypeColor,
    MysticPanelTypeColorAndIntensity,
    MysticPanelTypeIntensity,
    MysticPanelTypeMove,
    MysticPanelTypeSize,
    MysticPanelTypeAdjust,
    MysticPanelTypeSlider,
    MysticPanelTypeToggleIcon,
    MysticPanelTypeFont,
    MysticPanelTypeFontStyle,
    MysticPanelTypeFontAlign,
    MysticPanelTypeFonts,
    
    MysticPanelTypeAdjustMove,
    MysticPanelTypeMore,
    MysticPanelTypeShape,
    MysticPanelTypeFontAdjust,
    MysticPanelTypeAboveSettings,
    MysticPanelTypeBelowSettings,
    MysticPanelTypeOptionLayerSettings,
    MysticPanelTypeOptionImageLayerSettings,
    MysticPanelTypeOptionSettings,
    MysticPanelTypeOptionFilter,
    MysticPanelTypeOptionFilterSettings,
    MysticPanelTypeOptionColorAdjust,
    MysticPanelTypePotions,
    MysticPanelTypeOptionPotions,
    MysticPanelTypeOptionPotion,
    MysticPanelTypeOptionEditPotion,
    MysticPanelTypeOptionSpecial,
    MysticPanelTypeSaturation,
    MysticPanelTypeTone,
    MysticPanelTypeVibrance,
    MysticPanelTypeSkin,
    MysticPanelTypeSkinHue,
    MysticPanelTypeSkinHueThreshold,
    MysticPanelTypeSkinHueMaxShift,
    MysticPanelTypeSkinMaxSaturationShift,
    MysticPanelTypeSkinUpperTone,
    MysticPanelTypeBrightness,
    MysticPanelTypeContrast,
    MysticPanelTypeHaze,
    MysticPanelTypeGamma,
    MysticPanelTypeExposure,
    MysticPanelTypeShadows,
    MysticPanelTypeHighlights,
    MysticPanelTypeShadowsTone,
    MysticPanelTypeHighlightsTone,
    MysticPanelTypeGrain,
    MysticPanelTypeBackground,
    MysticPanelTypeForeground,
    MysticPanelTypeHue,
    MysticPanelTypeLevels,
    MysticPanelTypeColorBalance,
    MysticPanelTypeMask,
    MysticPanelTypeMaskBrush,
    MysticPanelTypeMaskErase,
    MysticPanelTypeMaskEmpty,
    MysticPanelTypeMaskFill,
    MysticPanelTypeMaskShape,
    MysticPanelTypeFlipVertical,
    MysticPanelTypeFlipHorizontal,
    MysticPanelTypeFlip,
    MysticPanelTypeVignette,
    MysticPanelTypeStretch,
    MysticPanelTypeAdjustColor,
    MysticPanelTypeSketch,
    MysticPanelTypeInvert,
    MysticPanelTypeTiltShift,
    MysticPanelTypeUnsharpMask,
    MysticPanelTypeSharpness,
    MysticPanelTypeBlur,
    MysticPanelTypeBlurCircle,
    MysticPanelTypeBlurZoom,
    MysticPanelTypeBlurMotion,
    MysticPanelTypeHalftone,
    MysticPanelTypeSketchFilter,
    MysticPanelTypePosterize,
    MysticPanelTypeDistortBuldge,
    MysticPanelTypeDistortPinch,
    MysticPanelTypeDistortStretch,
    MysticPanelTypeDistortGlassSphere,
    MysticPanelTypeDistortSwirl,
    MysticPanelTypePixellate,
    MysticPanelTypeToon,
    
    
    MysticPanelTypeTest,
} MysticPanelType;


typedef enum
{
    MysticRiddleAnswerNone,
    MysticRiddleAnswerTreasure,
    MysticRiddleAnswerAdmin,
    MysticRiddleAnswerWriteOnCam,
    MysticRiddleAnswerFont,
    MysticRiddleAnswerDrawing,
    MysticRiddleAnswerClearCache,
    MysticRiddleAnswerClearAll,
    MysticRiddleAnswerTest,
    MysticRiddleAnswerVersionCosmos,
    MysticRiddleAnswerVersionLight,
    
} MysticRiddleAnswer;

typedef enum {
    MysticUserGenderUnknown,
    MysticUserGenderMale,
    MysticUserGenderFemale
    
} MysticUserGender;


typedef enum {
    MysticSliderStateNone = 0,
    MysticSliderStateRGB,
    MysticSliderStateRed,
    MysticSliderStateBlue,
    MysticSliderStateGreen
    
} MysticSliderState;

typedef enum {
    MysticPickerSourceTypeUnknown,
    MysticPickerSourceTypeCamera,
    MysticPickerSourceTypePhotoLibrary,
    MysticPickerSourceTypeAlbum,
    MysticPickerSourceTypeCameraOrPhotoLibrary,
    MysticPickerSourceTypeCropper
    
} MysticPickerSourceType;

typedef enum
{
    MysticIrisStateUnknown,
    MysticIrisStateOpened,
    MysticIrisStateClosed,
} MysticIrisState;

typedef enum NavigationBarBorderStyle {
    NavigationBarBorderStyleNone,
    NavigationBarBorderStyleBottom,
} NavigationBarBorderStyle;

typedef enum {
    MysticAnimationTransitionNormal,
    MysticAnimationTransitionFade,
    MysticAnimationTransitionHideBottom,
    MysticAnimationTransitionHideTop,
    
} MysticAnimationTransition;
typedef enum {
    MysticShareTypeUnknown,
    MysticShareTypePreview,
    MysticShareTypeFull,
    MysticShareTypeSave,
    MysticShareTypeEmail,
    MysticShareTypeEmailSubject,
    MysticShareTypeEmailTo,
    MysticShareTypeEmailHTML,
    MysticShareTypeCopy,
    MysticShareTypeMessage,
    MysticShareTypeFacebook,
    MysticShareTypeTwitter,
    MysticShareTypeOpen,
    MysticShareTypePinterest,
    MysticShareTypeLink,
    MysticShareTypeInstagram,
    MysticShareTypePostcard,
    MysticShareTypePotion,
    MysticShareTypeTribe,
    MysticShareTypeOther
    
} MysticShareType;


typedef enum {
    MysticImageSizeTypeUnknown,
    MysticImageSizeTypePreview,
    MysticImageSizeTypeFull,
    MysticImageSizeTypeSave,
    MysticImageSizeTypeEmail,
    MysticImageSizeTypeEmailSubject,
    MysticImageSizeTypeEmailTo,
    MysticImageSizeTypeEmailHTML,
    MysticImageSizeTypeCopy,
    MysticImageSizeTypeMessage,
    MysticImageSizeTypeFacebook,
    MysticImageSizeTypeTwitter,
    MysticImageSizeTypeOpen,
    MysticImageSizeTypePinterest,
    MysticImageSizeTypeLink,
    MysticImageSizeTypeOther
    
} MysticImageSizeType;




typedef enum {
    MysticColorTypeUndefined = -2,
    MysticColorTypeNone = -1,
    MysticColorTypeUnknown,
    MysticColorTypeWhite,
    MysticColorTypeBlack,
    MysticColorTypePink,
    MysticColorTypeCustom,
    
    MysticColorTypeBlue,
    MysticColorTypeYellow,
    MysticColorTypeRed,
    MysticColorTypeGreen,
    MysticColorTypeGold,
    MysticColorTypeKhaki,
    MysticColorTypeBrown,
    MysticColorTypeOrange,
    MysticColorTypeBeige,
    MysticColorTypePinkDark,
    MysticColorTypeBackgroundLightGray,
    MysticColorTypeBackground,
    MysticColorTypeBackgroundBrown,
    MysticColorTypeBackgroundBlack,
    MysticColorTypeBackgroundWhite,
    MysticColorTypeBackgroundGray,
    MysticColorTypeWhiteBarInactive,
    MysticColorTypeWhiteBarActive,
    MysticColorTypeBottomBarBackground,
    MysticColorTypeBottomBarBackgroundDark,
    MysticColorTypeBottomBarBackgroundLight,
    MysticColorTypeBorderOnLight,
    MysticColorTypeClearButton,
    MysticColorTypeSliderMin,
    MysticColorTypeSliderMax,
    MysticColorTypeSliderMid,
    MysticColorTypeSliderMinLight,
    MysticColorTypeSliderMaxLight,
    MysticColorTypeSliderMidLight,
    
    MysticColorTypeDrawerIconBackground,
    
    MysticColorTypeBottomBarButtonBackground,
    MysticColorTypeBottomBarButtonBackgroundHighlighted,
    MysticColorTypeBottomBarButtonBackgroundSelected,
    MysticColorTypeBottomBarButtonBackgroundDisabled,
    
    MysticColorTypeBottomBarButtonTitle,
    MysticColorTypeBottomBarButtonTitleSelected,
    MysticColorTypeBottomBarButtonTitleHighlighted,
    MysticColorTypeBottomBarButtonTitleDisabled,
    
    MysticColorTypeBottomBarButtonIcon,
    MysticColorTypeBottomBarButtonIconSelected,
    MysticColorTypeBottomBarButtonIconHighlighted,
    MysticColorTypeBottomBarButtonIconDisabled,
    MysticColorTypeMoreArtArrow,
    MysticColorTypeResizableControlBorder,
    MysticColorTypeTabBarBackground,
    MysticColorTypeButtonText,
    MysticColorTypeClear,
    MysticColorTypeChromaGreen,
    MysticColorTypeChromaBlue,
    MysticColorTypeControlsBackground,
    MysticColorTypeControlInactive,
    MysticColorTypeControlActive,
    MysticColorTypeControlActiveDark,
    MysticColorTypeControlBorderActive,
    MysticColorTypeControlBorderInactive,
    MysticColorTypeControlIcon,
    MysticColorTypeControlIconActive,
    MysticColorTypeControlIconInactive,
    MysticColorTypeControlIconHighlighted,
    MysticColorTypeControlIconSelected,
    MysticColorTypeControlOverlay,
    MysticColorTypeControlOverlayHighlighted,
    MysticColorTypeControlOverlaySelected,
    MysticColorTypeBarButtonIconInactive,
    MysticColorTypeBarButtonIconActive,
    MysticColorTypeBarButtonIconHighlighted,
    MysticColorTypeBarButtonIconSelected,
    MysticColorTypeBarButtonIconDisabled,
    MysticColorTypeBarButtonIconApplication,
    MysticColorTypeNipple,
    MysticColorTypeBarButtonIconSelectedToggle,
    MysticColorTypePanelBorderColor,
    MysticColorTypeTabBackground,
    MysticColorTypeTabBackgroundSelected,
    MysticColorTypeTabBackgroundActive,
    MysticColorTypeTabBackgroundHighlighted,
    MysticColorTypeTabBackgroundDisabled,
    MysticColorTypeTabBackgroundApplication,
    MysticColorTypeTabCircle,
    MysticColorTypeTabIconInactive,
    MysticColorTypeTabIconActive,
    MysticColorTypeTabIconHighlighted,
    MysticColorTypeTabIconSelected,
    MysticColorTypeTabIconDisabled,
    MysticColorTypeTabIconApplication,
    MysticColorTypeTabBadge,
    MysticColorTypeTabBadgeHighlighted,
    MysticColorTypeTabBadgeText,
    MysticColorTypeTabBadgeTextHighlighted,
    MysticColorTypeTabTitle,
    MysticColorTypeTabTitleActive,
    MysticColorTypeTabTitleSelected,
    MysticColorTypeTabTitleHighlighted,
    MysticColorTypeTabTitleDisabled,
    MysticColorTypeDrawerMainBackground,
    MysticColorTypeShutter,
    MysticColorTypeShutterDisabled,
    MysticColorTypeShutterHighlighted,
    MysticColorTypeLibrary,
    MysticColorTypeLibraryHighlighted,
    MysticColorTypeCameraInfo,
    MysticColorTypeCameraInfoHighlighted,
    MysticColorTypeCameraX,
    MysticColorTypeCameraXHighlighted,
    MysticColorTypePanelConfirm,
    MysticColorTypePanelConfirmHighlighted,
    MysticColorTypePanelBottomIcon,
    MysticColorTypePanelBottomIconHighlighted,
    MysticColorTypePanelToolbarBackground,
    MysticColorTypePanelContentBackground,
    MysticColorTypePanelBackground,
    MysticColorTypePanelSubContentBackground,
    
    MysticColorTypeInputToolbarBackground,
    MysticColorTypeInputConfirm,
    MysticColorTypeInputBackground,
    MysticColorTypeInputToolbarBorder,
    MysticColorTypeInputToolbarText,
    MysticColorTypeInputToolbarTextPrefix,
    MysticColorTypeInputPickerLabel,
    
    MysticColorTypeControlInactiveOverlay,
    MysticColorTypeSegmentControl,
    MysticColorTypeSegmentControlImageColor,
    MysticColorTypeSegmentControlImageColorSelected,
    MysticColorTypeSegmentControlImageColorHighlighted,
    MysticColorTypeSegmentControlImageColorDisabled,
    MysticColorTypeSegmentControlTextColor,
    MysticColorTypeSegmentControlTextColorSelected,
    MysticColorTypeSegmentControlTextColorHighlighted,
    MysticColorTypeSegmentControlTextColorDisabled,
    
    MysticColorTypePanelTabBackground,
    
    MysticColorTypeControlSubBtn,
    
    MysticColorTypeHorizontalText,
    MysticColorTypeHorizontalTextSelected,
    MysticColorTypeHorizontalNavButton,
    MysticColorTypeHorizontalNavButtonDisabled,
    
    MysticColorTypePopup,
    MysticColorTypePopupHighlighted,
    
    
    MysticColorTypeBright,
    MysticColorTypeNeutral,
    MysticColorTypeDark,
    
    MysticColorTypePackTitle,
    
    MysticColorTypePinkMuted,
    MysticColorTypeCollectionBackground,
    MysticColorTypeCollectionBackgroundIcon,
    MysticColorTypeCollectionNavBarBackground,
    MysticColorTypeCollectionNavBarIcon,
    MysticColorTypeCollectionNavBarText,
    MysticColorTypeCollectionNavBarHighlighted,
    MysticColorTypeCollectionSectionHeaderBackground,
    MysticColorTypeCollectionSectionBackground,
    MysticColorTypeCollectionFeaturedSectionBackground,
    MysticColorTypeCollectionSectionHeaderText,
    MysticColorTypeCollectionSectionHeaderTextLight,
    MysticColorTypeCollectionSectionHeaderIcon,
    MysticColorTypeCollectionSectionHeaderHighlighted,
    MysticColorTypeCollectionToolbarBackground,
    MysticColorTypeCollectionToolbarText,
    MysticColorTypeCollectionToolbarTextHighlighted,
    MysticColorTypeCollectionToolbarIcon,
    MysticColorTypeCollectionToolbarIconSelected,
    MysticColorTypeCollectionToolbarIconHighlighted,
    MysticColorTypeCollectionBottomBarBackground,
    MysticColorTypeCollectionTopBarBackground,
    
    MysticColorTypeLayerPanelBackground,
    MysticColorTypeLayerPanelBottomBarBorder,
    MysticColorTypeKnob,
    MysticColorTypeKnobHighlighted,
    MysticColorTypeKnobSelected,
    MysticColorTypeKnobDisabled,
    
    MysticColorTypeInputAccessoryIcon,
    MysticColorTypeInputAccessoryIconHighlighted,
    MysticColorTypeInputAccessoryIconSelected,
    MysticColorTypeInputAccessoryIconDisabled,
    
    MysticColorTypeKnobBackgroundHighlighted,
    MysticColorTypeKnobBackground,
    MysticColorTypeKnobBackgroundOpen,
    MysticColorTypeNavBar,
    MysticColorTypeNavBarText,
    MysticColorTypeNavBarIcon,
    MysticColorTypeNavBarIconHighlighted,
    MysticColorTypeNavBarIconSelected,
    MysticColorTypeNavBarIconConfirm,
    MysticColorTypeNavBarIconConfirmHighlighted,
    MysticColorTypeNavBarIconCancel,
    MysticColorTypeNavBarIconCancelHighlighted,
    MysticColorTypeNavBarIconDull,
    MysticColorTypeNavBarIconDark,
    MysticColorTypeTranslucentNavBar,
    
    MysticColorTypeTopicBackgroundSelected,
    MysticColorTypeTopicBackground,
    MysticColorTypeTopicBackgroundHighlighted,
    MysticColorTypeTopicBorder,
    MysticColorTypeTopicBorderHighlighted,
    MysticColorTypeTopicBorderSelected,
    MysticColorTypeTopicText,
    MysticColorTypeTopicTextSelected,
    MysticColorTypeTopicTextHighlighted,
    
    MysticColorTypeShareBackground,
    MysticColorTypeShareButtonBorder,
    MysticColorTypeShareButtonText,
    MysticColorTypeShareButtonTextHighlighted,
    MysticColorTypeShareButtonTextFinished,
    MysticColorTypeShareButtonImage,
    MysticColorTypeShareButtonImageHighlighted,
    MysticColorTypeShareButtonImageFinished,
    MysticColorTypeShareButtonBackground,
    MysticColorTypeShareButtonBackgroundHighlighted,
    MysticColorTypeShareToolbarText,
    MysticColorTypeShareToolbarTextHighlighted,
    MysticColorTypeShareToolbarSubText,
    MysticColorTypeShareToolbarSubTextHighlighted,
    MysticColorTypeShareToolbarBackground,
    MysticColorTypeShareToolbarIcon,
    MysticColorTypeShareToolbarIconHighlighted,
    MysticColorTypeShareToolbarCancelIconHighlighted,
    MysticColorTypeShareToolbarCancelIcon,
    MysticColorTypeShareButtonAccessory,
    MysticColorTypeShareToolbarTitle,
    MysticColorTypeShareToolbarTitleHighlighted,
    MysticColorTypeNavBarTranslucentAndColor,
    MysticColorTypeDrawerToolbar,
    MysticColorTypeDrawerToolbarText,
    MysticColorTypeDrawerToolbarIcon,
    MysticColorTypeDrawerToolbarIconHighlighted,
    MysticColorTypeDrawerToolbarIconDark,
    MysticColorTypeDrawerToolbarSearch,
    MysticColorTypeToolbarSeparator,
    
    MysticColorTypeFontToolbar,
    MysticColorTypeDrawerNavBar,
    MysticColorTypeDrawerNavBarText,
    MysticColorTypeDrawerNavBarLogo,
    MysticColorTypeDrawerNavBarButton,
    MysticColorTypeDrawerNavBarButtonAction,
    MysticColorTypeDrawerNavBarButtonDim,
    MysticColorTypeDrawerSection,
    MysticColorTypeDrawerSectionText,
    MysticColorTypeDrawerSectionToolbar,
    MysticColorTypeDrawerMainCellBorder,
    MysticColorTypeDrawerBackground,
    MysticColorTypeDrawerBackgroundCell,
    MysticColorTypeDrawerBackgroundCellMain,
    MysticColorTypeDrawerBackgroundCellLayers,
    MysticColorTypeDrawerBackgroundCellAddBasic,
    MysticColorTypeDrawerBackgroundCellAddSpecial,
    MysticColorTypeDrawerBackgroundCellBorder,
    MysticColorTypeDrawerCellImageViewBackground,
    MysticColorTypeDrawerBorder,
    MysticColorTypeDrawerText,
    MysticColorTypeDrawerTextSubtitle,
    MysticColorTypeDrawerIconBorder,
    MysticColorTypeDrawerTextAdd,
    MysticColorTypeDrawerIcon,
    MysticColorTypeDrawerIconAdd,
    MysticColorTypeDrawerAccessory,
    MysticColorTypeDrawerAccessoryHighlighted,
    MysticColorTypeBottomBar,
    MysticColorTypeIconLight,
    MysticColorTypeIconDark,
    MysticColorTypeBackgroundCameraControls,
    MysticColorTypeObjectText,
    MysticColorTypeObjectTexture,
    MysticColorTypeObjectLight,
    MysticColorTypeObjectFilter,
    MysticColorTypeObjectBlend,
    MysticColorTypeObjectSettings,
    MysticColorTypeObjectFrame,
    MysticColorTypeObjectRecipe,
    MysticColorTypeObjectColor,
    MysticColorTypeObjectFont,
    MysticColorTypeObjectMixture,
    MysticColorTypeHUDIcon,
    MysticColorTypeHUDIconDisabled,
    MysticColorTypeHUDIconEnabled,
    MysticColorTypeHUDBackground,
    MysticColorTypeRightDrawerNavBarTitle,
    MysticColorTypeMainBackground,
    MysticColorTypeBlurTint,
    MysticColorTypeBlurTintTransformTool,
    MysticColorTypeBlurTintHUD,
    MysticColorTypeIntroHint,
    MysticColorTypeIntroButtonText,
    MysticColorTypeJournalNavBar,
    MysticColorTypeJournalCellBackground,
    MysticColorTypeJournalCellHighlighted,
    MysticColorTypeJournalCellTitle,
    MysticColorTypeJournalCellSubtitle,
    
    
    MysticColorTypeMenuText,
    MysticColorTypeMenuTextDark,
    MysticColorTypeMenuTextHighlighted,
    MysticColorTypeMenuTextSelected,
    MysticColorTypeMenuTextUnselected,
    
    MysticColorTypeMenuIcon,
    MysticColorTypeMenuIconHighlighted,
    MysticColorTypeMenuIconSelected,
    MysticColorTypeMenuIconConfirm,
    MysticColorTypeMenuIconCancel,
    MysticColorTypeMenuIconRedo,
    MysticColorTypeMenuIconUndo,
    MysticColorTypeMenuIconRedoDisabled,
    MysticColorTypeMenuIconUndoDisabled,
    
    MysticColorTypeSizeControlIcon,
    MysticColorTypeSizeControlText,
    MysticColorTypeSizeControlTextDisabled,
    MysticColorTypeToolbarIcon,
    MysticColorTypeToolbarText,
    
    MysticColorTypeTransformToolIcon,
    MysticColorTypeTransformToolBorder,
    MysticColorTypeTransformToolBackground,
    
    MysticColorTypeLayerIconBackground,
    MysticColorTypeDrawerIconImage,
    MysticColorTypeDrawerIconImageOverlay,
    
    MysticColorTypeRandom,
    MysticColorTypeWarning,
    MysticColorTypeError,
    MysticColorTypeFailure,
    MysticColorTypeSuccess,
    MysticColorTypeInfo,
    
    MysticColorTypeAuto,
    MysticColorTypeChoice1,
    MysticColorTypeChoice2,
    
#pragma mark - First colors
    
    MysticColorTypeChoice94,
    MysticColorTypeChoice95,
    MysticColorTypeChoice96,
    MysticColorTypeChoice97,
    MysticColorTypeChoice98,
    MysticColorTypeChoice99,
    MysticColorTypeChoice100,
    MysticColorTypeChoice101,
    
    
    MysticColorTypeChoice3,
    MysticColorTypeChoice4,
    MysticColorTypeChoice5,
    MysticColorTypeChoice6,
    MysticColorTypeChoice7,
    MysticColorTypeChoice8,
    MysticColorTypeChoice9,
    MysticColorTypeChoice10,
    MysticColorTypeChoice11,
    MysticColorTypeChoice12,
    MysticColorTypeChoice13,
    MysticColorTypeChoice14,
    MysticColorTypeChoice15,
    MysticColorTypeChoice16,
    MysticColorTypeChoice17,
    MysticColorTypeChoice18,
    MysticColorTypeChoice19,
    MysticColorTypeChoice20,
    MysticColorTypeChoice21,
    MysticColorTypeChoice22,
    MysticColorTypeChoice23,
    MysticColorTypeChoice24,
    MysticColorTypeChoice25,
    MysticColorTypeChoice26,
    MysticColorTypeChoice27,
    MysticColorTypeChoice28,
    MysticColorTypeChoice29,
    MysticColorTypeChoice30,
    MysticColorTypeChoice31,
    MysticColorTypeChoice32,
    MysticColorTypeChoice33,
    MysticColorTypeChoice34,
    MysticColorTypeChoice35,
    MysticColorTypeChoice36,
    MysticColorTypeChoice37,
    MysticColorTypeChoice38,
    MysticColorTypeChoice39,
    MysticColorTypeChoice40,
    MysticColorTypeChoice41,
    MysticColorTypeChoice42,
    MysticColorTypeChoice43,
    MysticColorTypeChoice44,
    MysticColorTypeChoice45,
    MysticColorTypeChoice46,
    MysticColorTypeChoice47,
    MysticColorTypeChoice48,
    MysticColorTypeChoice49,
    MysticColorTypeChoice50,
    MysticColorTypeChoice51,
    MysticColorTypeChoice52,
    MysticColorTypeChoice53,
    MysticColorTypeChoice54,
    MysticColorTypeChoice55,
    MysticColorTypeChoice56,
    MysticColorTypeChoice57,
    MysticColorTypeChoice58,
    MysticColorTypeChoice59,
    MysticColorTypeChoice60,
    MysticColorTypeChoice61,
    MysticColorTypeChoice62,
    MysticColorTypeChoice63,
    MysticColorTypeChoice64,
    MysticColorTypeChoice65,
    MysticColorTypeChoice66,
    MysticColorTypeChoice67,
    MysticColorTypeChoice68,
    MysticColorTypeChoice69,
    MysticColorTypeChoice70,
    MysticColorTypeChoice71,
    MysticColorTypeChoice72,
    MysticColorTypeChoice73,
    MysticColorTypeChoice74,
    MysticColorTypeChoice75,
    MysticColorTypeChoice76,
    MysticColorTypeChoice77,
    MysticColorTypeChoice78,
    MysticColorTypeChoice79,
    MysticColorTypeChoice80,
    MysticColorTypeChoice81,
    MysticColorTypeChoice82,
    MysticColorTypeChoice83,
    MysticColorTypeChoice84,
    MysticColorTypeChoice85,
    MysticColorTypeChoice86,
    MysticColorTypeChoice87,
    MysticColorTypeChoice88,
    MysticColorTypeChoice89,
    MysticColorTypeChoice90,
    MysticColorTypeChoice91,
    MysticColorTypeChoice92,
    MysticColorTypeChoice93,
    MysticColorTypeLast,
    
    MysticColorTypeChoice102,
    MysticColorTypeChoice103,
    MysticColorTypeChoice104,
    MysticColorTypeChoice105,
    MysticColorTypeChoice106,
    MysticColorTypeChoice107,
    MysticColorTypeChoice108,
    MysticColorTypeChoice109,
    MysticColorTypeChoice110,
    MysticColorTypeChoice111,
    MysticColorTypeChoice112,
    MysticColorTypeChoice113,
    MysticColorTypeChoice114,
    MysticColorTypeChoice115,
    MysticColorTypeChoice116,
    MysticColorTypeChoice117,
    MysticColorTypeChoice118,
    MysticColorTypeChoice119,
    MysticColorTypeChoice120,
    MysticColorTypeChoice121,
    
    MysticColorTypeLastChoice,
    
    
} MysticColorType;


typedef enum {
    MysticColorTypeControlBackground1 = MysticColorTypeChoice50,
    MysticColorTypeControlBackgroundSpecial = MysticColorTypeChoice3,
    
} MysticColorTypeControlBackground;

typedef enum {
    MysticColorTypeBlend1 = MysticColorTypeChoice102,
    MysticColorTypeBlend2,
    MysticColorTypeBlend3,
    MysticColorTypeBlend4,
    MysticColorTypeBlend5,
    MysticColorTypeBlend6,
    MysticColorTypeBlend7,
    MysticColorTypeBlend8,
    MysticColorTypeBlend9,
    MysticColorTypeBlend10,
    MysticColorTypeBlend11,
    MysticColorTypeBlend12,
    MysticColorTypeBlend13,
    MysticColorTypeBlend14,
    MysticColorTypeBlend15,
    MysticColorTypeBlend16,
    MysticColorTypeBlend17,
    MysticColorTypeBlend18,
    MysticColorTypeBlend19,
    MysticColorTypeBlend20
} MysticColorTypeBlend;


typedef enum {
    MysticColorTypeLayerEffectNone = MysticColorTypeAuto,
    MysticColorTypeLayerEffectInvertedWhite = MysticColorTypeChoice1,

    MysticColorTypeLayerEffectInverted = MysticColorTypeChoice2,
    MysticColorTypeLayerEffectDesaturate,
    MysticColorTypeLayerEffectOne,
    MysticColorTypeLayerEffectTwo,
    MysticColorTypeLayerEffectThree,
    MysticColorTypeLayerEffectFour,
    MysticColorTypeLayerEffectRandom = MysticColorTypeRandom,
    MysticColorTypeLayerEffectLast,
} MysticColorTypeLayerEffect;

typedef enum {
    MysticStretchModeNone = -1,
    MysticStretchModeAuto,
    MysticStretchModeFill,
    MysticStretchModeAspectFit,
    MysticStretchModeAspectFill,
} MysticStretchMode;

typedef enum {
    MysticBorderStyleNone,
    MysticBorderStyleBottom,
    MysticBorderStyleTop,
} MysticBorderStyle;

typedef enum {
    MysticToggleStateOff,
    MysticToggleStateOn,
    MysticToggleStateFirst,
    MysticToggleStateSecond,
    MysticToggleStateThird,
    MysticToggleStateFourth,
    MysticToggleStateFifth,
    MysticToggleStateSixth
} MysticToggleState;


typedef enum {
    MysticViewTypeRemove = -1,
    
    MysticViewTypeUnknown = 17347484,
    MysticViewTypeControls,
    MysticViewTypeButton1,
    MysticViewTypeButton2,
    MysticViewTypeButton3,
    MysticViewTypeButton4,
    MysticViewTypeButton5,
    MysticViewTypeButton6,
    MysticViewTypeButton7,
    MysticViewTypeButton8,
    MysticViewTypeButtonConfirm,
    MysticViewTypeButtonCancel,
    MysticViewTypeButtonBack,
    MysticViewTypeButtonForward,
    MysticViewTypeSlider,
    MysticViewTypeGrid,
    MysticViewTypeHUD,
    MysticViewTypeToolbar,
    MysticViewTypeToolbarLayer,
    MysticViewTypeToolbarPanel,
    MysticViewTypeToolbarFont,
    MysticViewTypeToolbarSize,
    
    MysticViewTypeLayers,
    MysticViewTypeLayersShapes,
    MysticViewTypeLayersLabels,
    MysticViewTypeLayersFonts,
    MysticViewTypeToggler,
    MysticViewTypeButtonSettings,
    MysticViewTypeButtonShuffle,
    MysticViewTypeImage,
    MysticViewTypeScrollView,
    MysticViewTypeScrollView2,
    MysticViewTypePreview,
    MysticViewTypeControl,
    MysticViewTypeButtonMenu,
    MysticViewTypeButtonMenuItem,
    MysticViewTypePanel,
    MysticViewTypeSubPanel,
    MysticViewTypeSubView,
    MysticViewTypeTabBar,
    MysticViewTypeTabBarMain,
    MysticViewTypeTabBarPanel,
    MysticViewTypeTabBarPanelSettings,
    MysticViewTypeTabBarPanelSettingsLayer,
    MysticViewTypeTabBarFont,
    MysticViewTypeTabBarAddLayer,
    MysticViewTypeShareButton,
    MysticViewTypeDefault,
    MysticViewTypeBorderButton,
    MysticViewTypeContainer,
    MysticViewTypeTabBarShape,
    MysticViewTypeTabBarShapeAlign,
    MysticViewTypeBackground,
    MysticViewTypeBackgroundBorder,
    MysticViewTypeButtonAlignMiddle,
    MysticViewTypeButtonAlignOutside,
    MysticViewTypeButtonAlignInside,
    MysticViewTypeBorder,
    MysticViewTypeFill,
    MysticViewTypeDebug,
    MysticViewTypeDebugFill,
    MysticViewTypeDebugBorder,

    MysticViewTypeMask,
    MysticViewTypeDebugMask,
    MysticViewTypeEyeDropper,
    MysticViewTypeTabBarPanelSketch,
    MysticViewTypeUndo,
    MysticViewTypeRedo,
    
} MysticViewType;

typedef NS_ENUM(NSInteger, MysticPermissionType) {
    MysticPermissionTypeUnknown=0,
    MysticPermissionTypeCamera,
    MysticPermissionTypePhotos,
};

typedef NS_ENUM(NSInteger, MysticAuthorizationStatus) {
    MysticAuthorizationStatusUnknown=-1,
    MysticAuthorizationStatusNotDetermined,
    MysticAuthorizationStatusRestricted,
    MysticAuthorizationStatusDenied,
    MysticAuthorizationStatusAuthorized,
    
};

typedef NS_ENUM(NSInteger, MysticIconType) {
    MysticIconTypeUnknown = -1,
    MysticIconTypeNone,
    MysticIconTypeSquare,
    MysticIconTypeCircle,
    MysticIconTypePentagon,
    MysticIconTypeSextagon,
    MysticIconTypeSticker,
    MysticIconTypeStar,
    MysticIconTypeStarFat,
    MysticIconTypeStarRound,
    MysticIconTypeStarVintage,
    MysticIconTypeRectRound,
    MysticIconTypeChat,
    MysticIconTypeBack,
    MysticIconTypeDragger,
    MysticIconTypeToolHide,
    MysticIconTypeForward,
    MysticIconTypeImage,
    MysticIconTypeCamera,
    MysticIconTypeShare,
    MysticIconTypeFilter,
    MysticIconTypeSettingFilter,
    MysticIconTypeFrame,
    MysticIconTypeColorOverlay,
    MysticIconTypeBigger,
    MysticIconTypeSmaller,
    MysticIconTypeFlip,
    MysticIconTypeFlipVertical,
    MysticIconTypeFlipHorizontal,
    MysticIconTypeRotate,
    MysticIconTypeRotateLeft,
    MysticIconTypeRotateRight,
    MysticIconTypeUp,
    MysticIconTypeDown,
    MysticIconTypeLeft,
    MysticIconTypeRight,
    MysticIconTypeText,
    MysticIconTypeTexture,
    MysticIconTypeLight,
    MysticIconTypeShape,
    MysticIconTypeBadge,
    MysticIconTypeInfo,
    MysticIconTypeCog,
    MysticIconTypeCogBorder,
    MysticIconTypeBackground,
    
    MysticIconTypeToolBarFavorites,
    MysticIconTypeToolBarRecents,
    MysticIconTypeToolBarAll,
    MysticIconTypeColor,
    MysticIconTypeGrid,
    MysticIconTypeGridVisible,
    MysticIconTypeSettings,
    MysticIconTypeAdjustments,
    MysticIconTypeWriteOnCam,
    MysticIconTypeLogo,
    MysticIconTypePhoto,
    MysticIconTypeBook,
    MysticIconTypeHeart,
    MysticIconTypeMove,
    MysticIconTypeMenu,
    MysticIconTypeCloud,
    MysticIconTypeQuestion,
    MysticIconTypePrivate,
    MysticIconTypeEditLayer,
    MysticIconTypeLock,
    MysticIconTypeUnlocked,
    MysticIconTypeArrowUp,
    MysticIconTypeArrowDown,
    MysticIconTypeArrowLeft,
    MysticIconTypeArrowRight,
    
    MysticIconTypeArrowSmallUp,
    MysticIconTypeArrowSmallDown,
    MysticIconTypeArrowSmallLeft,
    MysticIconTypeArrowSmallRight,
    
    MysticIconTypeAlignGroupVertical,
    MysticIconTypeAlignGroupHorizontal,
    MysticIconTypeAlignGroupTop,
    MysticIconTypeAlignGroupLeft,
    MysticIconTypeAlignGroupBottom,
    MysticIconTypeAlignGroupRight,
    MysticIconTypeAlignGroupVerticalNoBorder,
    MysticIconTypeAlignGroupHorizontalNoBorder,
    MysticIconTypeAlignGroupTopNoBorder,
    MysticIconTypeAlignGroupLeftNoBorder,
    MysticIconTypeAlignGroupBottomNoBorder,
    MysticIconTypeAlignGroupRightNoBorder,
    MysticIconTypeAlignToArtboard,
    MysticIconTypeAlignToSelection,
    MysticIconTypeAlignToKeyObject,
    
    
    MysticIconTypeFontAdd,
    MysticIconTypeFontEdit,
    MysticIconTypeFontColor,
    MysticIconTypeLayerColor = MysticIconTypeFontColor,
    MysticIconTypeFontMove,
    MysticIconTypeFontClone,
    MysticIconTypeFontSelect,
    MysticIconTypeFontDelete,
    MysticIconTypeFontDeselect,
    MysticIconTypeFontAlign,
    MysticIconTypeFontLineHeight,
    MysticIconTypeFontBorder,
    MysticIconTypeFontShadow,
    MysticIconTypeFontStyle,
    
    MysticIconTypeShapeAdd,
    MysticIconTypeShapeEdit,
    MysticIconTypeShapeColor,
    MysticIconTypeShapeMove,
    MysticIconTypeShapeClone,
    MysticIconTypeShapeRezize,
    MysticIconTypeShapeSelect,
    MysticIconTypeShapeDelete,
    MysticIconTypeShapeDeselect,
    MysticIconTypeShapeAlign,
    MysticIconTypeShapeLineHeight,
    MysticIconTypeShapeBorder,
    MysticIconTypeShapeStyle,
    
    MysticIconTypeMoreArtArrow,
    MysticIconTypeSaturation,
    MysticIconTypeBrightness,
    MysticIconTypeLevels,
    MysticIconTypeColorBalance,
    MysticIconTypeRGB,
    MysticIconTypeTone,
    MysticIconTypeLayers,
    MysticIconTypeOptions,
    MysticIconTypeShadows,
    MysticIconTypeHighlights,
    MysticIconTypeShadowsHighlights,
    MysticIconTypeContrast,
    MysticIconTypeGamma,
    MysticIconTypeExposure,
    MysticIconTypeHue,
    MysticIconTypeHaze,
    MysticIconTypeBlur,
    MysticIconTypeSharpness,
    MysticIconTypeTiltShift,
    MysticIconTypeUnsharpMask,
    MysticIconTypeIntensity,
    MysticIconTypeVignette,
    MysticIconTypeFill,
    MysticIconTypeWearAndTear,
    MysticIconTypeSymbols,
    MysticIconTypeControlSelected,
    MysticIconTypeControlNormal,
    MysticIconTypeControlHighlighted,
    MysticIconTypeBlend,
    MysticIconTypeMix,
    MysticIconTypeMoveAndSize,
    MysticIconTypeInvert,
    MysticIconTypeColors,
    MysticIconTypeOpacity,
    MysticIconTypeCheck,
    MysticIconTypeCheckThick,
    MysticIconTypeConfirm,
    MysticIconTypeConfirmThick,
    MysticIconTypeConfirmFat,
    MysticIconTypeToolBarConfirm,
    MysticIconTypeToolConfirm,
    
    MysticIconTypeLayerResize,
    MysticIconTypeLayerX,
    MysticIconTypeCancel,
    MysticIconTypeAlert,
    MysticIconTypeImageMask,
    MysticIconTypeAccessory,
    MysticIconTypeAccessoryUp,
    MysticIconTypeAccessoryDown,
    MysticIconTypeAccessoryLeft,
    MysticIconTypeAccessoryRight,
    MysticIconTypePlus,
    MysticIconTypeAdd,
    MysticIconTypeSubtract,
    MysticIconTypeMinus,
    MysticIconTypeTune,
    MysticIconTypeVibrance,
    MysticIconTypeSkin,
    MysticIconTypeHighlightColor,
    MysticIconTypeTuneShadowColor,
    MysticIconTypeTips,
    MysticIconTypeDrawerNippleLeft,
    MysticIconTypeDrawerNippleRight,
    MysticIconTypeNippleTopBorder,
    MysticIconTypeNippleTop,
    MysticIconTypeNippleBottom,
    MysticIconTypeNippleLeft,
    MysticIconTypeNippleRight,
    MysticIconTypeDuplicate,
    MysticIconTypeRemove,
    MysticIconTypeDelete,
    MysticIconTypeRecipe,
    MysticIconTypeMoveUp,
    MysticIconTypeMoveDown,
    MysticIconTypeCategories,
    MysticIconTypeLove,
    MysticIconTypeVisions,
    MysticIconTypeAction,
    MysticIconTypeCamLayer,
    MysticIconTypePhotoLayer,
    MysticIconTypeAlign,
    MysticIconTypeAlignLeft,
    MysticIconTypeAlignRight,
    MysticIconTypeAlignCenter,
    MysticIconTypeAlignFill,
    MysticIconTypeAlignJustified,
    MysticIconTypeAlignJustifiedRight,
    
    MysticIconTypePosition,
    MysticIconTypePositionNone,
    MysticIconTypePositionTopLeft,
    MysticIconTypePositionTop,
    MysticIconTypePositionTopRight,
    MysticIconTypePositionLeft,
    MysticIconTypePositionCenter,
    MysticIconTypePositionRight,
    MysticIconTypePositionBottomLeft,
    MysticIconTypePositionBottom,
    MysticIconTypePositionBottomRight,
    
    MysticIconTypeLineHeight,
    MysticIconTypeLineHeightMinus,
    MysticIconTypeLineHeightPlus,
    MysticIconTypeFontSpacing,
    
    MysticIconTypeFont,
    MysticIconTypeFonts,
    MysticIconTypeFontNormal,
    MysticIconTypeFontBold,
    MysticIconTypeFontItalic,
    MysticIconTypeFontBoldItalic,
    MysticIconTypeFontLight,
    MysticIconTypeFontCondensed,
    MysticIconTypeSettingTone,
    MysticIconTypeSettingRGB,
    MysticIconTypeSettingSaturation,
    MysticIconTypeSettingBrightness,
    MysticIconTypeSettingContrast,
    MysticIconTypeSettingGamma,
    MysticIconTypeSettingExposure,
    MysticIconTypeSettingLevels,
    MysticIconTypeSettingColorBalance,
    MysticIconTypeSettingShadows,
    MysticIconTypeSettingHighlights,
    MysticIconTypeSettingHaze,
    MysticIconTypeSettingCleanUp,
    MysticIconTypeSettingReset,
    MysticIconTypeReset,
    MysticIconTypeSize,
    MysticIconTypeRefresh,
    MysticIconTypeAlbum,
    MysticIconTypeShuffle,
    MysticIconTypeSearch,
    MysticIconTypeQuality,
    MysticIconTypeType,
    MysticIconTypePotionMode,
    MysticIconTypeRiddle,
    MysticIconTypeFeedback,
    MysticIconTypeClose,
    MysticIconTypeQuote,
    MysticIconTypeClear,
    MysticIconTypeSunshine,
    MysticIconTypeRevealDown,
    MysticIconTypeHelp,
    MysticIconTypeCheckUpdate,
    MysticIconTypeDownloadEffects,
    MysticIconTypeCredits,
    MysticIconTypeBrowse,
    MysticIconTypeChoose,
    MysticIconTypeSquares,
    MysticIconTypeDots,
    MysticIconTypeFacebook,
    MysticIconTypeSave,
    MysticIconTypeOpen,
    MysticIconTypeInstagram,
    MysticIconTypeTweet,
    MysticIconTypeEmail,
    MysticIconTypePostcard,
    MysticIconTypePinterest,
    MysticIconTypeTag,
    MysticIconTypeMiniSlider,
    
    
    MysticIconTypeBlendOverlay,
    MysticIconTypeProject,
    MysticIconTypePotion,
    MysticIconTypeUser,
    MysticIconTypeCameraSwitch,
    MysticIconTypeCameraPlus,
    MysticIconTypeShutter,
    MysticIconTypeLibrary,
    MysticIconTypeCameraInfo,
    
    MysticIconTypeFlashOn,
    MysticIconTypeFlash,
    MysticIconTypeFlashAuto,
    MysticIconTypeFlashOff,
    MysticIconTypeNewProject,
    MysticIconTypePhotoLibrary,
    MysticIconTypeToolFlipHorizontalRight,
    MysticIconTypeToolFlipVerticalBottom,
    MysticIconTypeToolFlipVerticalBottomColor,
    MysticIconTypeToolFlipHorizontalRightColor,
    MysticIconTypeToolFlipVerticalColor,
    MysticIconTypeToolFlipHorizontalColor,
    MysticIconTypeEffectNone,
    MysticIconTypeEffect0,
    MysticIconTypeEffect1,
    MysticIconTypeEffect2,
    MysticIconTypeEffect3,
    MysticIconTypeEffect4,
    MysticIconTypeEffect5,
    MysticIconTypeEffect6,
    MysticIconTypeEffect7,
    MysticIconTypeEffectRandom,
    MysticIconTypeX,
    MysticIconTypeStretchOn,
    MysticIconTypeStretchOff,
    MysticIconTypeFit,
    MysticIconTypeEyeDrop,
    MysticIconTypeToolCircleCheck,
    MysticIconTypeToolCircleCheckBorder,
    MysticIconTypeToolCircleCheckNoBorder,
    MysticIconTypeEraser,
    MysticIconTypePen,
    MysticIconTypeDesigns,
    MysticIconTypeMask,
    MysticIconTypeCommunity,
    MysticIconTypeCustom,
    MysticIconTypeToolSquaresGrid,
    MysticIconTypeToolSquareBorder,
    MysticIconTypeKnob,
    MysticIconTypeKnobOpen,
    MysticIconTypeKnobClosed,
    MysticIconTypeKnobWide,
    MysticIconTypeKnobWideOpen,
    MysticIconTypeKnobWideClosed,
    MysticIconTypeUserProfilePicture,
    MysticIconTypeUserProfilePictureCircle,
    MysticIconTypeUserProfilePictureCircleBorder,
    MysticIconTypeKnobDisabled,
    MysticIconTypeKnobDisabledOpen,
    MysticIconTypeKnobDisabledClosed,
    MysticIconTypeKnobBorder,
    MysticIconTypeKnobBorderOpen,
    MysticIconTypeKnobBorderClosed,
    MysticIconTypeBadgeCheck,
    MysticIconTypeBadgeCircle,
    MysticIconTypeToolBarX,
    MysticIconTypeToolBarX2,
    MysticIconTypeToolBarList,
    MysticIconTypeToolBarEquals,
    MysticIconTypeToolX,
    MysticIconTypeToolFlipVertical,
    MysticIconTypeToolFlipHorizontal,
    MysticIconTypeToolBrowsePack,
    MysticIconTypeToolPlus,
    MysticIconTypeToolMinus,
    MysticIconTypeToolLeft,
    MysticIconTypeToolRight,
    MysticIconTypeToolLeftCenter,
    MysticIconTypeToolRightCenter,
    MysticIconTypeToolUp,
    MysticIconTypeToolDown,
    MysticIconTypeToolRotateLeft,
    MysticIconTypeToolRotateRight,
    MysticIconTypeToolUpCenter,
    MysticIconTypeToolDownCenter,
    MysticIconTypeToolHome,
    MysticIconTypeToolDuplicate,
    MysticIconTypeToolLayerSettings,
    MysticIconTypeToolLayerSettingsHighlighted,
    MysticIconTypeToolCog,
    MysticIconTypeToolMove,
    MysticIconTypeToolTrash,
    MysticIconTypeToolColor,
    MysticIconTypeToolPosition,
    MysticIconTypeToolFont,
    MysticIconTypeToolFontColor,
    MysticIconTypeToolFontEffect,
    MysticIconTypeToolEffects,
    MysticIconTypeToolKeyboard,
    MysticIconTypeToolContent,
    MysticIconTypeMenuHeart,
    MysticIconTypeMenuJournal,
    MysticIconTypeMenuCommunity,
    MysticIconTypeMenuLogo,
    MysticIconTypeMenuSettings,
    MysticIconTypeMenuSearch,
    MysticIconTypeMenuSort,
    MysticIconTypeHashTags,
    MysticIconTypeShareCancel,
    MysticIconTypeShareSettings,
    MysticIconTypeShareSave,
    MysticIconTypeShareFacebook,
    MysticIconTypeShareInstagram,
    MysticIconTypeShareTwitter,
    MysticIconTypeShareEmail,
    MysticIconTypeSharePinterest,
    MysticIconTypeSharePostcard,
    MysticIconTypeShareCopy,
    MysticIconTypeSharePotion,
    MysticIconTypeShareLink,
    MysticIconTypeShareMysticTribe,
    MysticIconTypeShareOther,
    MysticIconTypeShareIcon,
    MysticIconTypeToolShadowAndBorder,
    MysticIconTypeToolLayerBevel,
    MysticIconTypeToolLayerEmboss,
    MysticIconTypeToolLayerInnerBevel,
    MysticIconTypeToolLayerInnserShadow,
    MysticIconTypeShareCircleSave,
    MysticIconTypeShareCircleFacebook,
    MysticIconTypeShareCircleInstagram,
    MysticIconTypeShareCircleTwitter,
    MysticIconTypeShareCircleEmail,
    MysticIconTypeShareCirclePinterest,
    MysticIconTypeShareCirclePostcard,
    MysticIconTypeShareCircleCopy,
    MysticIconTypeShareCirclePotion,
    MysticIconTypeShareCircleLink,
    MysticIconTypeShareCircleTribe,
    MysticIconTypeShareCircleOther,
    
    
    MysticIconTypePointerLeft,
    MysticIconTypePointerRight,
    MysticIconTypeSkinnyX,
    MysticIconTypeSkinnyMenu,
    
    MysticIconTypeTabMenu,
    MysticIconTypeTabShare,
    MysticIconTypeBackgroundColor,
    MysticIconTypeBadgeCircleHighlighted,
    MysticIconTypeBadgeCheckHighlighted,
    
    MysticIconTypeWand,
    MysticIconTypeAccessoryDrag,
    MysticIconTypeSpecial,
    
    MysticIconTypeLayerPosition,
    MysticIconTypeLayerEffects,
    MysticIconTypeLayerShadowBlur,
    MysticIconTypeLayerShadowColor,
    MysticIconTypeLayerShadowAlpha,
    MysticIconTypeLayerBorderWidth,
    MysticIconTypeLayerBorderColor,
    MysticIconTypeLayerBorderAlpha,
    MysticIconTypeBorderAlignMiddle,
    MysticIconTypeBorderAlignOutside,
    MysticIconTypeBorderAlignInside,
    
    MysticIconTypeMaskFill,
    MysticIconTypeMaskErase,
    MysticIconTypeMaskBrush,
    MysticIconTypeMaskEmpty,
    MysticIconTypeMaskLayer,
    MysticIconTypeMaskShape,
    
    MysticIconTypeStretch,
    MysticIconTypeStretchNone,
    MysticIconTypeStretchAspectFit,
    MysticIconTypeStretchAspectFill,
    MysticIconTypeStretchFill,
    
    MysticIconTypeAdjustColor,
    MysticIconTypeXThick,
    MysticIconTypeScribble,
    MysticIconTypeSketchHide,
    MysticIconTypeSketchBrush,
    MysticIconTypeSketchEraser,
    MysticIconTypeSketchUndo,
    MysticIconTypeSketchRedo,
    MysticIconTypeSketchSettings,
    MysticIconTypeSketchLayers,
    MysticIconTypeBluetooth,
    MysticIconTypeSketchBrushAdd,
    MysticIconTypeSketchBrushDelete,
    MysticIconTypeSketchBrushEdit,
    MysticIconTypeSketchBrushBack,
    MysticIconTypeSketchBrushDuplicate,
    MysticIconTypeMergeDown,
    MysticIconTypeSketchVisible,
    MysticIconTypeSketchHidden,
    MysticIconTypeSketchBlend,
    MysticIconTypeSketchLock,
    MysticIconTypeSketchUnlock,
    
    MysticIconTypeSettingsPhotoQuality,
    MysticIconTypeSettingsEmptyCache,
    MysticIconTypeSettingsShowTips,
    MysticIconTypeSettingsKeepPrivate,
    MysticIconTypeSettingsAccessories,
    MysticIconTypeSettingsAboutMystic,
    MysticIconTypeSettingsSubmitBug,
    MysticIconTypeSettingsRestorePurchases,
    MysticIconTypeGrain,
    
    MysticIconTypeCompare,
    MysticIconTypeTest,
    
    MysticIconTypeBlurCircle,
    MysticIconTypeBlurZoom,
    MysticIconTypeBlurGaussian,
    MysticIconTypeBlurMotion,
    
    MysticIconTypeHalfTone,
    MysticIconTypeSketchFilter,
    MysticIconTypePosterize,
    MysticIconTypeDistortBuldge,
    MysticIconTypeDistortPinch,
    MysticIconTypeDistortStretch,
    MysticIconTypeDistortGlassSphere,
    MysticIconTypeDistortSwirl,
    MysticIconTypePixellate,
    MysticIconTypeToon,
    
    
};

typedef enum {
    
    MysticAlignTypeTop,
    MysticAlignTypeBottom,
    
} MysticAlignType;

typedef enum {
    MysticInputTypeUnknown,
    MysticInputTypeColor,
    MysticInputTypeFont,
    MysticInputTypeFontEffect,
    
} MysticInputType;
typedef enum {
    MysticSortOrderNormal,
    MysticSortOrderReverse,
    MysticSortOrderRandom,
} MysticSortOrder;

typedef enum {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;



typedef enum {
    MysticAttrNone                                     = 1 << 0,
    
    MysticAttrShader                                   = 1 << 1,
    MysticAttrVertex                                   = 1 << 2,
    MysticAttrUsesTexture                              = 1 << 3,
    
} MysticAttr;

typedef enum {
    MysticPositionUnknown                               = 1 << -1,
    
    MysticPositionTopLeft                               = 1 << 0,
    MysticPositionTop                                   = 1 << 1,
    MysticPositionTopRight                              = 1 << 2,
    
    MysticPositionLeft                                  = 1 << 3,
    MysticPositionCenter                                = 1 << 4,
    MysticPositionRight                                 = 1 << 5,
    
    MysticPositionBottomLeft                            = 1 << 6,
    MysticPositionBottom                                = 1 << 7,
    MysticPositionBottomRight                           = 1 << 8,
    
    MysticPositionLeftTop                               = 1 << 9,
    MysticPositionRightTop                              = 1 << 10,
    MysticPositionLeftTopAligned                        = 1 << 11,
    MysticPositionRightTopAligned                       = 1 << 12,
    
    MysticPositionLeftBottom                            = 1 << 13,
    MysticPositionRightBottom                           = 1 << 14,
    MysticPositionLeftBottomAligned                     = 1 << 15,
    MysticPositionRightBottomAligned                    = 1 << 16,
    
    MysticPositionCenterVertical                        = 1 << 17,
    
    MysticPositionThirdsHorizontal                      = 1 << 18,
    
    MysticPositionTopOnly                               = 1 << 19,
    
    MysticPositionLeftOnly                              = 1 << 20,
    MysticPositionCenterOnly                            = 1 << 21,
    MysticPositionRightOnly                             = 1 << 22,
    
    MysticPositionBottomOnly                            = 1 << 23,
    MysticPositionCenterVerticalOnly                    = 1 << 24,
    
    MysticPositionInside                                = 1 << 25,
    MysticPositionOutside                               = 1 << 26,
    MysticPositionMiddle                                = 1 << 27,
    
    MysticPositionVerticalDivisions                     = 1 << 28,
    MysticPositionHorizontalDivisions                   = 1 << 29,
    
    
} MysticPosition;


typedef enum {
    MysticAlignPositionNone                                  = -1,
    MysticAlignPositionTopLeft                               = 0,
    MysticAlignPositionTop                                   = 1,
    MysticAlignPositionTopRight                              = 2,
    
    MysticAlignPositionLeft                                  = 3,
    MysticAlignPositionCenter                                = 4,
    MysticAlignPositionRight                                 = 5,
    
    MysticAlignPositionBottomLeft                            = 6,
    MysticAlignPositionBottom                                = 7,
    MysticAlignPositionBottomRight                           = 8,
    
    
    
} MysticAlignPosition;


typedef enum {
    MysticProductTypeFeatured,
    MysticProductTypeCharity,
    MysticProductTypeOther,
    MysticProductTypeUnknown,
    MysticProductTypeAdvanced,
    MysticProductTypeAll
} MysticProductType;

typedef enum {
    MysticStyleTypeNormal,
    MysticStyleTypeLeftNav,
    MysticStyleTypeRightNav
} MysticStyleType;

typedef enum {
    MysticRenderOptionsNil                                  = 1 << -1,
    MysticRenderOptionsNone                                 = 1 << 0,
    MysticRenderOptionsAuto                                 = 1 << 1,
    MysticRenderOptionsPreview                              = 1 << 2,
    MysticRenderOptionsSource                               = 1 << 3,
    MysticRenderOptionsThumb                                = 1 << 4,
    MysticRenderOptionsOriginal                             = 1 << 5,
    MysticRenderOptionsRefresh                              = 1 << 6,
    MysticRenderOptionsSaveImageOutput                      = 1 << 7,
    
    MysticRenderOptionsForceProcess                         = 1 << 8,
    MysticRenderOptionsEmptyFirst                           = 1 << 9,
    MysticRenderOptionsOutputShader                         = 1 << 10,
    MysticRenderOptionsPass                                 = 1 << 11,
    MysticRenderOptionsPassLast                             = 1 << 12,
    MysticRenderOptionsManager                              = 1 << 13,
    MysticRenderOptionsClearFiltersOnComplete               = 1 << 14,
    MysticRenderOptionsFilterUpToFocus                      = 1 << 15,
    MysticRenderOptionsFilterUpToTransform                  = 1 << 16,
    
    MysticRenderOptionsSortFocusOptionOnTop                 = 1 << 17,
    MysticRenderOptionsSortTransformingOptionOnTop          = 1 << 18,
    MysticRenderOptionsReturnImage                          = 1 << 19,
    MysticRenderOptionsIcon                                 = 1 << 20,
    
    MysticRenderOptionsDebug                                = 1 << 21,
    MysticRenderOptionsSetupRender                          = 1 << 22,
    MysticRenderOptionsRevealPlaceholder                    = 1 << 23,
    MysticRenderOptionsRebuildBuffer                        = 1 << 24,
    MysticRenderOptionsSaveState                            = 1 << 25,
    MysticRenderOptionsBuildFromGroudUp                     = 1 << 26,
    MysticRenderOptionsSaveLayers                           = 1 << 27,
    MysticRenderOptionsBiggest                              = 1 << 28,
    
    
} MysticRenderOptions;


typedef enum {
    MysticOptionStateAny                    = 1 << 0,
    MysticOptionStateNone                   = 1 << 1,
    MysticOptionStatePreviewing             = 1 << 2,
    MysticOptionStateNotPreviewing          = 1 << 3,
    MysticOptionStateConfirmed              = 1 << 4,
    MysticOptionStateUnconfirmed            = 1 << 5,
    MysticOptionStateInFocus                = 1 << 6,
    MysticOptionStateOutOfFocus             = 1 << 7,
    MysticOptionStateChoosing               = 1 << 8,
    MysticOptionStateEditing                = 1 << 9,
    
} MysticOptionState;

typedef enum {
    MysticButtonTypeUnknown = -1,
    MysticButtonTypeNormal = 12345,
    MysticButtonTypeText,
    MysticButtonTypeFrame,
    MysticButtonTypeTexture,
    MysticButtonTypeBadge,
    MysticButtonTypeShape,
    
    MysticButtonTypeLight,
    MysticButtonTypeFilter,
    MysticButtonTypeEffects,
    MysticButtonTypeMask,
    MysticButtonTypeRecipe,
    MysticButtonTypeShop,
    MysticButtonTypeSettings,
    MysticButtonTypePreferences,
    MysticButtonTypeFeedback,
    MysticButtonTypeCamLayer,
    MysticButtonTypeBlending,
    MysticButtonTypeCancel,
    MysticButtonTypeManageLayers,
    MysticButtonTypeMixtures,
    MysticButtonTypeMagic,
    MysticButtonTypeChooseLayer,
    MysticButtonTypePotions,
    MysticButtonTypeAddLayer,
} MysticButtonType;

typedef enum {
    MysticUITypeNone,
    MysticUITypeView,
    MysticUITypeField,
    MysticUITypeCarousel,
    MysticUITypeSearchButton,
    MysticUITypeLeftButton,
    MysticUITypeRightButton,
    MysticUITypeLabel
} MysticUIType;


typedef enum {
    
    MysticObjectSelectionTypeUnknown,
    MysticObjectSelectionTypeOption,
    MysticObjectSelectionTypePack,
    MysticObjectSelectionTypeSetting,
    MysticObjectSelectionTypePackAndOption,
    
} MysticObjectSelectionType;


typedef enum {
    MysticRecipesTypeAll,
    MysticRecipesTypeFeatured,
    MysticRecipesTypeSaved,
    MysticRecipesTypeProject,
    MysticRecipesTypeCommunity
} MysticRecipesType;

typedef enum {
    MysticTipNameUnknown,
    MysticTipNameBlendingNoFilter,
    
} MysticTipName;




typedef enum {
    MysticLayerLevelAuto = -1,
    MysticLayerLevelImage,
    MysticLayerLevelAboveImage                  = MysticLayerLevelImage + 100,
    MysticLayerLevelBlendedSettings             = MysticLayerLevelAboveImage + 100,
    MysticLayerLevelBlendedShape                = MysticLayerLevelBlendedSettings + 100,
    MysticLayerLevelBlendedBadge                = MysticLayerLevelBlendedShape + 100,
    MysticLayerLevelBlendedText                 = MysticLayerLevelBlendedBadge + 100,
    MysticLayerLevelBlendedCam                  = MysticLayerLevelBlendedText + 100,
    MysticLayerLevelBlendedLight                = MysticLayerLevelBlendedCam + 100,
    MysticLayerLevelBlendedFrame                = MysticLayerLevelBlendedLight + 100,
    MysticLayerLevelBlendedTexture              = MysticLayerLevelBlendedFrame + 100,
    MysticLayerLevelBlendedMask                 = MysticLayerLevelBlendedTexture + 100,
    MysticLayerLevelAboveBlended                = MysticLayerLevelBlendedMask + 100,
    MysticLayerLevelFilter                      = MysticLayerLevelAboveBlended + 100,
    MysticLayerLevelCam                         = MysticLayerLevelFilter + 100,
    MysticLayerLevelFrame                       = MysticLayerLevelCam + 100,
    MysticLayerLevelShape                       = MysticLayerLevelFrame + 100,
    MysticLayerLevelBadge                       = MysticLayerLevelShape + 100,
    MysticLayerLevelLight                       = MysticLayerLevelBadge + 100,
    MysticLayerLevelTexture                     = MysticLayerLevelLight + 100,
    MysticLayerLevelText                        = MysticLayerLevelTexture + 100,
    MysticLayerLevelMask                        = MysticLayerLevelText + 100,
    MysticLayerLevelSettings                    = MysticLayerLevelMask + 100,
    MysticLayerLevelAboveSettings               = MysticLayerLevelSettings + 100,
    MysticLayerLevelAlwaysTop                   = MysticLayerLevelAboveSettings + 100,
    MysticLayerLevelHighest                     = MysticLayerLevelAboveSettings + 1000,
    MysticLayerLevelHighestUnlessMoved          = MysticLayerLevelAboveSettings + 2000,
    MysticLayerLevelStaysBelowHighest           = MysticLayerLevelAboveSettings + 3000,
    MysticLayerLevelStaysHighest                = MysticLayerLevelAboveSettings + 4000,
    MysticLayerLevelTop                         = MysticLayerLevelAboveSettings + 5000,
    
    MysticLayerLevelMax                         = MysticLayerLevelAboveSettings + 15000,
    
    
} MysticLayerLevel;

typedef enum
{
    MysticLayerLevelRuleAuto                                    = 1 << 0,
    MysticLayerLevelRuleNextLevel                               = 1 << 1,
    MysticLayerLevelRuleAlwaysAbovePic                          = 1 << 2,
    MysticLayerLevelRuleAlwaysBelowBlended                      = 1 << 3,
    MysticLayerLevelRuleAlwaysAboveBlended                      = 1 << 4,
    MysticLayerLevelRuleAlwaysAboveSettings                     = 1 << 5,
    MysticLayerLevelRuleAlwaysBelowTop                          = 1 << 6,
    MysticLayerLevelRuleAlwaysHighestBelowTop                   = 1 << 7,
    MysticLayerLevelRuleAlwaysOnTop                             = 1 << 8,
    MysticLayerLevelRuleAlwaysHighest                           = 1 << 9,
    MysticLayerLevelRuleAlwaysHighestUnlessMoved                = 1 << 10,
    MysticLayerLevelRuleStaysBelowHighest                       = 1 << 11,
    MysticLayerLevelRuleStaysHighest                            = 1 << 12,
    MysticLayerLevelRuleTop                                     = 1 << 13,
    
    
} MysticLayerLevelRule;

typedef enum
{
    MysticFilterOptionAuto                                    = 1 << 0,
    MysticFilterOptionBeforeLayers                            = 1 << 1,
    MysticFilterOptionAfterLayers                             = 1 << 2,
    MysticFilterOptionTransformLayers                         = 1 << 3,
    MysticFilterOptionAll                                     = 1 << 4,
    
    
} MysticFilterOption;


typedef enum {
    
    
    MysticOptionTypeNone                               = 0,
    MysticOptionTypeUnknown                            = 4 << 0,
    MysticOptionTypeAll                                = 4 << 1,
    MysticOptionTypeLayer                              = 4 << 2,
    MysticOptionTypePack                               = 4 << 3,
    MysticOptionTypeFilter                             = 4 << 4,
    MysticOptionTypeFrame                              = 4 << 5,
    MysticOptionTypeText                               = 4 << 6,
    MysticOptionTypeDesign                             = 4 << 7,
    MysticOptionTypeTexture                            = 4 << 8,
    MysticOptionTypeLight                              = 4 << 9,
    MysticOptionTypeBadge                              = 4 << 10,
    MysticOptionTypeSetting                            = 4 << 11,
    MysticOptionTypeRecipe                             = 4 << 12,
    MysticOptionTypeFont                               = 4 << 13,
    MysticOptionTypeFontStyle                          = 4 << 14,
    MysticOptionTypeShape                              = 4 << 15,
    MysticOptionTypeColorOverlay                       = 4 << 16,
    MysticOptionTypeLayerPacks                         = 4 << 17,
    MysticOptionTypeLayerShape                         = 4 << 18,
    MysticOptionTypeLayerShapePacks                    = 4 << 19,
    
    
    MysticOptionTypeAllItems                           = 4 << 20,
    MysticOptionTypeTopTenItems                        = 4 << 21,
    MysticOptionTypeTopFortyItems                      = 4 << 22,
    
    MysticOptionTypeShowFeaturedPack                   = 4 << 23,
    MysticOptionTypeShowFeaturedPackTop                = 4 << 24,
    MysticOptionTypeUseTypeTitle                       = 4 << 25,
    MysticOptionTypeRecentlyUsed                       = 4 << 26,
    MysticOptionTypeDataOnly                           = 4 << 27,
    
    
    
} MysticOptionTypes;

typedef enum {
    MysticDirectionUnknown                  = 1 << 0,
    MysticDirectionNone                     = 1 << 1,
    MysticDirectionUp                       = 1 << 2,
    MysticDirectionDown                     = 1 << 3,
    MysticDirectionLeft                     = 1 << 4,
    MysticDirectionRight                    = 1 << 5,
    
} MysticDirection;

typedef enum {
    MysticChoiceUnknown                     = 1 << 0,
    MysticChoiceNone                        = 1 << 1,
    MysticChoiceFill                        = 1 << 2,
    MysticChoiceBorder                      = 1 << 3,
    MysticChoiceShadow                      = 1 << 4,
    MysticChoiceEmboss                      = 1 << 5,
    MysticChoiceBevel                       = 1 << 6,
    MysticChoiceExtrude                     = 1 << 7,
    MysticChoiceInnerShadow                 = 1 << 8,
    MysticChoiceInnerBevel                  = 1 << 9,
    
    
} MysticChoiceProperty;

typedef enum {
    MysticAlertStyleNone = -1,
    MysticAlertStyleDefault,
    MysticAlertStyleInput,
    MysticAlertStyleCancel,
    MysticAlertStyleOk,
    MysticAlertStyleMultiple,
    
} MysticAlertStyle;

typedef enum
{
    MysticObjectTypeUnknown            ,
    MysticObjectTypePack,
    MysticObjectTypeTextPack,
    MysticObjectTypeTexturePack,
    MysticObjectTypeLightPack,
    MysticObjectTypeFramePack,
    MysticObjectTypeBadgePack,
    MysticObjectTypeOption,
    MysticObjectTypeFilter            ,
    MysticObjectTypeFilterAlpha            ,
    MysticObjectTypeOverlay            ,
    MysticObjectTypeFrame              ,
    MysticObjectTypePotion             ,
    MysticObjectTypeRecipe = MysticObjectTypePotion,
    MysticObjectTypeText              ,
    MysticObjectTypeCamLayer,
    MysticObjectTypeTextOverlay,
    MysticObjectTypeMask              ,
    MysticObjectTypeTexture              , // 17
    MysticObjectTypeLight              ,
    MysticObjectTypeImage,
    MysticObjectTypeBlendedLayer,
    MysticObjectTypeColor,
    MysticObjectTypeTextColor,
    MysticObjectTypeBadgeColor,
    MysticObjectTypeFrameBackgroundColor,
    MysticObjectTypeBadge,
    MysticObjectTypeBadgeOverlay,
    MysticObjectTypeSetting,  // 27
    MysticObjectTypeFont,
    MysticObjectTypeBlend,
    MysticObjectTypeMixture,
    MysticObjectTypeAll,
    MysticObjectTypeLayer,
    MysticObjectTypeDesign,
    MysticObjectTypeShape, // 34
    
    
    MysticObjectTypeFontStyle, // 35
    MysticObjectTypeColorOverlay,
    MysticObjectTypeBackground,
    MysticObjectTypeGradient,
    MysticObjectTypeCustom,
    
    MysticObjectTypeSourceSetting,
    MysticObjectTypeSpecial,
    MysticObjectTypeLayerShape,
    MysticObjectTypeSketch, // 43
    MysticObjectTypeMulti,
    MysticObjectTypeLastOfObjects,
    
    // add new types below here
    MysticObjectTypeDesignSettings,
    MysticObjectTypeTextureSettings,
    MysticObjectTypeCamLayerSettings,
    MysticObjectTypeBadgeSettings,
    MysticObjectTypeFrameSettings,
    MysticObjectTypeLightSettings,
    
    
    
    MysticSettingUnknown,
    MysticSettingChangeSource,
    MysticSettingPotions,
    MysticSettingDesign,
    
    MysticSettingChooseDesign,
    MysticSettingChooseFilter,
    MysticSettingChooseText,
    MysticSettingChooseBadge,
    MysticSettingChooseFrame,
    MysticSettingChooseTexture,
    MysticSettingChooseLighting,
    MysticSettingChooseCamLayer,
    MysticSettingChoosePotion,
    MysticSettingChooseFont,
    MysticSettingChooseBlending,
    MysticSettingChooseColor,
    MysticSettingChooseColorAndIntensity,
    MysticSettingChooseColorFilter,
    MysticSettingColorAndIntensity,
    MysticSettingColor,
    MysticSettingColorAdjust,
    MysticSettingColorAdjustHue,
    MysticSettingColorOffsetHue,
    MysticSettingColorAdjustSaturation,
    MysticSettingColorAdjustBrightness,
    MysticSettingColorAdjustAlpha,
    MysticSettingColorAdjustAll,
    MysticSettingChooseTextType,
    MysticSettingChooseType,
    
    
    MysticSettingEditDesign,
    MysticSettingEditFilter,
    MysticSettingEditText,
    MysticSettingEditBadge,
    MysticSettingEditFrame,
    MysticSettingEditTexture,
    MysticSettingEditLighting,
    MysticSettingEditCamLayer,
    MysticSettingEditPotion,
    MysticSettingEditFont,
    MysticSettingEditBlending,
    MysticSettingEditColor,
    MysticSettingEditColorFilter,
    MysticSettingEditTextType,
    MysticSettingEditType,
    MysticSettingEditSettings,
    MysticSettingEditLayer,
    MysticSettingEditMask,
    
    MysticSettingNone,
    MysticSettingNoneFromConfirm,
    MysticSettingNoneFromCancel,
    MysticSettingNoneFromBack,
    MysticSettingLaunch,
    
    
    MysticSettingUnLaunched,
    MysticSettingDraw,
    MysticSettingDrawMask,
    MysticSettingShop,
    MysticSettingFilter,
    
    MysticSettingFontAdd,
    MysticSettingFontSelect,
    MysticSettingFontDelete,
    MysticSettingFontClone,
    MysticSettingFontEdit,
    MysticSettingFontColor,
    MysticSettingFontMove,
    MysticSettingFontStyle,
    MysticSettingFontEffect,
    MysticSettingFontAlign,
    
    MysticSettingShapeAdd,
    MysticSettingShapeSelect,
    MysticSettingShapeDelete,
    MysticSettingShapeClone,
    MysticSettingShapeEdit,
    MysticSettingShapeColor,
    MysticSettingShapeMove,
    MysticSettingShapeResize,
    MysticSettingShapeStyle,
    MysticSettingShapeEffect,
    MysticSettingShapeAlign,
    MysticSettingShapeAlignLeft,
    MysticSettingShapeAlignRight,
    MysticSettingShapeAlignCenterHorizontal,
    MysticSettingShapeAlignTop,
    MysticSettingShapeAlignBottom,
    MysticSettingShapeAlignCenterVertical,
    MysticSettingShapeAlignTo,
    
    MysticSettingAlignToKeyObject,
    MysticSettingAlignToSelection,
    MysticSettingAlignToArtboard,
    
    MysticSettingText,
    MysticSettingTextColor,
    MysticSettingTextTransform,
    MysticSettingTextAlpha,
    MysticSettingBackground,
    
    MysticSettingAddLayer,
    MysticSettingBadge,
    MysticSettingMask,
    MysticSettingBrightness,
    MysticSettingVibrance,
    MysticSettingSkin,
    MysticSettingSkinHue,
    MysticSettingSkinHueThreshold,
    MysticSettingSkinMaxHueShift,
    MysticSettingSkinMaxSaturationShift,
    MysticSettingSkinUpperSkinToneColor,
    MysticSettingHighlightTintColor,
    MysticSettingShadowTint,
    MysticSettingHighlightTint,
    MysticSettingShadowTintColor,
    MysticSettingHighlightIntensity,
    MysticSettingShadowIntensity,
    MysticSettingFrame,
    MysticSettingFrameColor,
    MysticSettingBadgeColor,
    MysticSettingTexture,
    MysticSettingLighting,
    MysticSettingExposure,
    MysticSettingHSB,
    MysticSettingHSBHue,
    MysticSettingHSBSaturation,
    MysticSettingHSBBrightness,
    MysticSettingGamma,
    MysticSettingSaturation,
    MysticSettingVignette,
    MysticSettingVignetteColorAlpha,
    MysticSettingVignetteBlending,
    
    MysticSettingContrast,
    MysticSettingFill,
    MysticSettingHighlights,
    MysticSettingShadows,
    MysticSettingColorOverlay,
    MysticSettingShadowsHighlights,
    MysticSettingIntensity,
    MysticSettingBadgeAlpha,
    MysticSettingTextureAlpha,
    MysticSettingFrameAlpha,
    MysticSettingLightAlpha,
    MysticSettingLightingAlpha = MysticSettingLightAlpha,
    MysticSettingFilterAlpha,
    MysticSettingBadgeTransform,
    MysticSettingFrameTransform,
    MysticSettingMaskTransform,
    MysticSettingTransform,
    MysticSettingTemperature,
    MysticSettingHaze,
    MysticSettingHazeSlope,
    MysticSettingCamLayer,
    MysticSettingReset,
    MysticSettingSettings,
    MysticSettingPreview,
    MysticSettingFeedback,
    MysticSettingCrop,
    MysticSettingRGB,
    MysticSettingPreferences,
    MysticSettingCamLayerAlpha,
    MysticSettingCamLayerTakePhoto,
    MysticSettingBlending,
    MysticSettingCamLayerSetup,
    MysticSettingLevels,
    

    MysticSettingShape,
    MysticSettingCropSourceImage,
    MysticSettingWearAndTear,
    MysticSettingRecipe,
    MysticSettingOpenPhoto,
    MysticSettingColorFilter,
    
    MysticSettingTypeNew,
    MysticSettingType,
    MysticSettingSelectType,
    MysticSettingSelectTypeInit,
    MysticSettingTypeAlpha,
    MysticSettingRecipeProject,
    MysticSettingRecipeProjects,
    MysticSettingStartProject,
    MysticSettingAboutProject,
    MysticSettingAboutProjects,
    MysticSettingShare,
    MysticSettingAlpha,
    MysticSettingCamLayerColor,
    MysticSettingNewProject,
    MysticSettingColorBalance,
    MysticSettingColorBalanceRed,
    MysticSettingColorBalanceGreen,
    MysticSettingColorBalanceBlue,
    MysticSettingLayers,
    MysticSettingOptions,
    MysticSettingLayerEffect,
    MysticSettingForegroundColor,
    MysticSettingBackgroundColor,
    
    MysticSettingSettingsLayer,
    MysticSettingMixtures,
    MysticSettingPaint,
    MysticSettingInTransition,
    MysticSettingMenu,
    MysticSettingAutoEnhance,
    MysticSettingTransformAdjusted,
    MysticSettingAdjustTransformRect,
    MysticSettingFalseColor,
    MysticSettingTransformOriginal,
    MysticSettingNoneFromLoadProject,
    
    MysticSettingLayerContent,
    MysticSettingLayerPosition,
    MysticSettingLayerColor,
    MysticSettingLayerShadow,
    MysticSettingLayerBorder,
    MysticSettingLayerInnerShadow,
    MysticSettingLayerExtrude,
    MysticSettingLayerEmboss,
    MysticSettingLayerGlow,
    MysticSettingLayerBevel,
    MysticSettingLayerInnerBevel,
    
    MysticSettingMaskLayer,
    MysticSettingMaskFill,
    MysticSettingMaskEmpty,
    MysticSettingMaskErase,
    MysticSettingMaskBrush,
    MysticSettingMaskShape,
    
    MysticSettingFlipVertical,
    MysticSettingFlipHorizontal,
    
    MysticSettingLevelsRed,
    MysticSettingLevelsGreen,
    MysticSettingLevelsBlue,
    MysticSettingLevelsRGB,
    
    MysticSettingStretch,
    MysticSettingStretchNone,
    MysticSettingStretchAspectFill,
    MysticSettingStretchAspectFit,
    MysticSettingStretchFill,
    MysticSettingAdjustColor,
    MysticSettingEyeDropper,
    
    MysticSettingSketchBrush,
    MysticSettingSketchEraser,
    MysticSettingSketchSettings,
    MysticSettingSketchLayers,
    
    MysticSettingImageShortcut,
    MysticSettingGrain,
    MysticSettingInvert,
    
    MysticSettingImageProcessing, // everything past this point is an image process filter
    MysticSettingSharpness,
    MysticSettingUnsharpMask,
    MysticSettingTiltShift,
    
    MysticSettingBlur,
    MysticSettingBlurCircle,
    MysticSettingBlurZoom,
    MysticSettingBlurGaussian,
    MysticSettingBlurMotion,
    MysticSettingHalfTone,
    MysticSettingSketchFilter,
    MysticSettingPosterize,
    MysticSettingDistortBuldge,
    MysticSettingDistortPinch,
    MysticSettingDistortStretch,
    MysticSettingDistortGlassSphere,
    MysticSettingDistortSwirl,
    MysticSettingPixellate,
    MysticSettingToon,
    
#ifdef DEBUG
    MysticSettingTest,
#endif
    
} MysticObjectType;

typedef enum {
    MysticAccessoryTypeNone=0,
    MysticAccessoryTypeClose,
    MysticAccessoryTypeInfo,
    MysticAccessoryTypeQuestion,
    
} MysticAccessoryType;
typedef enum
{
    
    MysticTabStyleNormal,
    MysticTabStyleDefault = MysticTabStyleNormal,
    MysticTabStylePanel,
} MysticTabStyle;


typedef enum
{
    
    MysticAdjustmentStateNotAdjusted = 1,
    MysticAdjustmentStateRendered,
    MysticAdjustmentStateUnrendered,
} MysticAdjustmentState;

typedef enum
{
    MysticStringStyleNormal,
    MysticStringStyleInput,
    MysticStringStyleInputPickColor,
    MysticStringStyleInputToolbar,
    MysticStringStyleInputToolbarBottom,
    MysticStringStyleInputButton,
    MysticStringStyleInputBlack,
    MysticStringStyleInputPickerLabel,
    MysticStringStyleButton,
    MysticStringStyleToolbarTitle,
    MysticStringStyleToolbarTitleDull,
    MysticStringStyleNav,
    MysticStringStyleBrushPropertyTitle,
    MysticStringStyleDoneButton,
    MysticStringStyleBrushSliderLabel,
    MysticStringStyleNavigationTitle,
    MysticStringStyleNavigationButton,
    MysticStringStyleMessage,
    MysticStringStyleSettingsCellTitle,
    MysticStringStyleSettingsCellDetail,
    MysticStringStyleSettingsCellSubtitle,
    MysticStringStyleSettingsTitle,
    MysticStringStyleSettingsNavButtonLeft,
    MysticStringStyleSettingsNavButtonRight,
    MysticStringStyleTipTitle,
    MysticStringStyleTipMessage,
    MysticStringStyleAccessTitle,
    MysticStringStyleAccessDescription,
    MysticStringStyleAccessButton,
    MysticStringStyleStoreRestore,
    MysticStringStyleStoreItemButton,
    MysticStringStyleStoreItemTitle,
    MysticStringStyleStoreItemSubtitle,
    MysticStringStyleStoreCategory,
    MysticStringStyleStoreDonateTitle,
    MysticStringStyleStoreDonateDescription,
    MysticStringStyleStoreDonateWhyButton,
    MysticStringStyleStoreDonateButton,
    MysticStringStyleStoreNevermindButton,


    MysticStringStyleTipButton,
} MysticStringStyle;


typedef enum
{
    MysticLayoutStyleUnknown,
    MysticLayoutStyleNormal = 12345,
    MysticLayoutStyleDefault = MysticLayoutStyleNormal,
    MysticLayoutStyleFixed,
    MysticLayoutStyleFlexible,
    MysticLayoutStyleList,
    MysticLayoutStyleGrid,
    MysticLayoutStyleListToGrid,
    MysticLayoutStyleHorizontal,
    MysticLayoutStyleVertical,
} MysticLayoutStyle;

typedef enum
{
    MysticConfirmTypeHidden,
    MysticConfirmTypeBottomBar            ,
    MysticConfirmTypeTopBar,
    MysticConfirmTypeTopBarWithBottomBar
} MysticConfirmType;

typedef enum
{
    MysticViewTagUnknown,
    MysticViewTagBottomBar,
    MysticViewTagTopBar,
    MysticViewTagTopSubBar,
    MysticViewTagBottomToolBar,
    MysticViewTagBottomHeader,
    MysticViewTagBody,
    
} MysticViewTag;


typedef enum
{
    MysticScrollViewRevealStyleNext,
    MysticScrollViewRevealStyleDefault = MysticScrollViewRevealStyleNext,
    MysticScrollViewRevealStyleCenter,
} MysticScrollViewRevealStyle;


typedef enum
{
    EffectObjectTypeUnknown            ,
    EffectObjectTypeFilter            ,
    EffectObjectTypeOverlay            ,
    EffectObjectTypeFrame              ,
    EffectObjectTypePotion             ,
    EffectObjectTypeText              ,
    EffectObjectTypeImage,
    EffectObjectTypeCamLayer
} EffectObjectType;

typedef enum {
    MysticLayerEffectNone = 1234,
    MysticLayerEffectInverted,
    MysticLayerEffectDesaturate,
    MysticLayerEffectOne,
    MysticLayerEffectTwo,
    MysticLayerEffectThree,
    MysticLayerEffectFour,
    
    MysticLayerEffectRandom,
    MysticLayerEffectLast,
    MysticLayerEffectFive,
    MysticLayerEffectSix,
    MysticLayerEffectSeven,
} MysticLayerEffect;

typedef enum {
    MysticFontStyleUnknown          = 1 << -1,
    MysticFontStyleNormal           = 1 << 0,
    MysticFontStyleBold             = 1 << 1,
    MysticFontStyleItalic           = 1 << 2,
    MysticFontStyleBoldItalic       = 1 << 3,
    MysticFontStyleLight            = 1 << 4,
    MysticFontStyleCondensed        = 1 << 5,
    MysticFontStyleBlack            = 1 << 6,
    
} MysticFontStyle;

typedef enum
{
    
    MysticFilterTypeUnknown,
    
    MysticFilterTypeBlendScreen            ,
    MysticFilterTypeBlendMultiply         ,
    MysticFilterTypeBlendOverlay           ,
    MysticFilterTypeBlendDissolve,
    MysticFilterTypeBlendNormal,
    MysticFilterTypeBlendDarken,
    MysticFilterTypeBlendLighten,
    MysticFilterTypeBlendColorBurn,
    MysticFilterTypeBlendSoftlight,
    MysticFilterTypeBlendHardlight,
    MysticFilterTypeBlendAdd,
    MysticFilterTypeBlendExclusion,
    MysticFilterTypeBlendDifference,
    MysticFilterTypeBlendDivide,
    MysticFilterTypeBlendAlpha,
    MysticFilterTypeBlendAlphaMix,
    MysticFilterTypeBlendMix,
    MysticFilterTypeBlendColorDodge,
    MysticFilterTypeBlendColor,
    MysticFilterTypeBlendHue,
    MysticFilterTypeBlendSaturation,
    MysticFilterTypeBlendLuminosity,
    MysticFilterTypeBlendChromaKey,
    MysticFilterTypeBlendTextureMap,
    MysticFilterTypeWhiteBalance,
    MysticFilterTypeDropBlack,
    MysticFilterTypeDropWhite,
    MysticFilterTypeBlendLinearBurn,
    MysticFilterTypeBlendSubtract,
    MysticFilterTypeBlendCutout,
    MysticFilterTypeBlendMaskScreen,
    MysticFilterTypeBlendMaskMultiply,
    MysticFilterTypeBlendMaskMultiplyNoFill,
    MysticFilterTypeBlendMaskScreenNoFill,
    MysticFilterTypeBlendMaskShowBlack,
    MysticFilterTypeMask,
    MysticFilterTypeGreenMask,
    MysticFilterTypeDropGreen,
    
    
    MysticFilterTypeUnsharpMask,
    MysticFilterTypeSharpen,
    MysticFilterTypeColor,
    MysticFilterTypeVignette,
    MysticFilterTypePyramid,
    MysticFilterTypeLookup,
    MysticFilterTypeChromaKey,
    MysticFilterTypeCrop,
    MysticFilterTypeSaturation,
    MysticFilterTypeExposure,
    MysticFilterTypeHSB,
    MysticFilterTypeGamma,
    MysticFilterTypeBrightness,
    MysticFilterTypeContrast,
    MysticFilterTypeColorMatrix,
    MysticFilterTypeRGB,
    MysticFilterTypeHue,
    MysticFilterTypeTransform,
    MysticFilterTypeRotate,
    MysticFilterTypeToneCurve         ,
    MysticFilterTypeHighlightShadow     ,
    MysticFilterTypeAmatorka            ,
    MysticFilterTypeMissEtikate       ,
    MysticFilterTypeSoftElegance       ,
    MysticFilterTypeColorInvert       ,
    MysticFilterTypeGrayscale             ,
    MysticFilterTypeMonochrome           ,
    MysticFilterTypeSepia                  ,
    MysticFilterTypeOpacity            ,
    MysticFilterTypeLuminance         ,
    MysticFilterTypeLuminosity            ,
    MysticFilterTypeAverageColor          ,
    
    
    MysticFilterTypeMysticFilter1,
    MysticFilterTypeBlendAlphaMask,
    MysticFilterTypeBlendAlphaMaskFillBg,
    MysticFilterTypeBlendAlphaOver,
    MysticFilterTypeBlendAlphaDebug,
    MysticFilterTypeAdjustColor,
    MysticFilterTypeBlendAuto
    
} MysticFilterType;



typedef enum
{
    MysticCameraUnknown,
    MysticCameraFront            ,
    MysticCameraBack
} MysticCameraType;

typedef enum
{
    MysticAdjustTypeUnknown = -1,
    MysticAdjustTypeMin            ,
    MysticAdjustTypeMax
} MysticAdjustType;

typedef enum
{
    MysticImageTypeUnknown,
    MysticImageTypePNG            ,
    MysticImageTypeJPG,
    MysticImageTypeJPNG,
    MysticImageTypePDF,
    MysticImageTypeSVG,
    MysticImageTypeGIF,
    MysticImageTypeEPS,
    MysticImageTypeLayer,
    MysticImageTypeOriginal,
    MysticImageTypePreview,
    MysticImageTypeThumb,
} MysticImageType;

typedef enum
{
    MysticFlashUnknown,
    MysticFlashOn            ,
    MysticFlashOff,
    MysticFlashAuto
} MysticFlashType;

typedef enum
{
    MysticModeOff,
    MysticModeOn
} MysticMode;

typedef enum
{
    MysticSizeTypeUnknown = 1 << -1,
    MysticSizeTypeNone = 1 << 0,
    MysticSizeTypeWidth = 1 << 1 ,
    MysticSizeTypeHeight = 1 << 2,
    MysticSizeTypeEqual = 1 << 3,
} MysticSizeType;


typedef enum {
    MysticLayerStateNormal,
    MysticLayerStateChooseImage,
    MysticLayerStateChooseType,
    MysticLayerStateChooseText,
    MysticLayerStateChooseLight,
    MysticLayerStateChooseFrame,
    MysticLayerStateChooseTexture,
    MysticLayerStateChooseBadge,
    MysticLayerStateChooseSettings,
    MysticLayerStateChooseFilter,
    MysticLayerStateEditImage,
    MysticLayerStateEditLight,
    MysticLayerStateEditFrame,
    MysticLayerStateEditTexture,
    MysticLayerStateEditBadge,
    MysticLayerStateEditSettings,
    MysticLayerStateEditFilter,
    MysticLayerStateEditText,
    MysticLayerStateFinished
    
} MysticLayerState;


struct MysticCollectionRange {
    NSInteger firstSection;
    NSInteger firstItem;
    NSInteger lastSection;
    NSInteger lastItem;
    NSInteger count;
};
typedef struct MysticCollectionRange MysticCollectionRange;

extern MysticCollectionRange const MysticCollectionRangeUnknown;
extern MysticCollectionRange const MysticCollectionRangeZero;


struct MysticTableLayout {
    NSInteger rows;
    NSInteger columns;
};
typedef struct MysticTableLayout MysticTableLayout;

struct MysticGridIndex {
    NSInteger column;
    NSInteger row;
};
typedef struct MysticGridIndex MysticGridIndex;

struct MysticHSB {
    GLfloat hue;
    GLfloat saturation;
    GLfloat brightness;
    GLfloat alpha;

};

typedef struct MysticHSB MysticHSB;


struct MysticHSBInt {
    int hue;
    float saturation;
    float brightness;
};
typedef struct MysticHSBInt MysticHSBInt;

extern MysticHSB const MysticHSBDefault;

struct MysticRGB {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};
typedef struct MysticRGB MysticRGB;
struct MysticMinMax {
    CGFloat min;
    CGFloat mid;
    CGFloat max;
};
typedef struct MysticMinMax MysticMinMax;
struct MysticThreshold {
    MysticMinMax range;
    CGFloat threshold;
    CGFloat smoothing;
    CGFloat intensity;
    CGFloat sharpness;
    CGFloat contrast;
    CGFloat threshold2;
    CGFloat threshold3;

};
typedef struct MysticThreshold MysticThreshold;

typedef void (^MysticBlockInput)(UIColor *color, UIColor *selectedColor, CGPoint p, MysticThreshold threshold, int index, MysticInputView *input, BOOL finished);


extern MysticThreshold const MysticThresholdDefault;
extern MysticThreshold const MysticThresholdLow;
extern MysticThreshold const MysticThresholdHigh;
extern MysticThreshold const MysticThresholdMedium;


struct MysticAdjustColorInfo {
    NSInteger index;
    BOOL added;
};
typedef struct MysticAdjustColorInfo MysticAdjustColorInfo;

typedef enum {
    MysticColorStateUnknown=-1,
    MysticColorStateRed,
    MysticColorStateGreen,
    MysticColorStateBlue,
    MysticColorStateAlpha,
    MysticColorStateHue,
    MysticColorStateSaturation,
    MysticColorStateBrightness,
    MysticColorStateSmooth,

} MysticColorState;

typedef enum {
    MysticTuneUnknown=-1,
    MysticTuneRed,
    MysticTuneGreen,
    MysticTuneBlue,
    MysticTuneAlpha,
    MysticTuneHue,
    MysticTuneSaturation,
    MysticTuneBrightness,
    MysticTuneSmooth,
    MysticTuneThreshold,
    MysticTuneRange,
    MysticTuneBlend,
    
} MysticTune;

struct CGSizeRatio {
    
    CGFloat width;
    CGFloat height;
    CGFloat ratio;
    MysticSizeType type;
    
};
typedef struct CGSizeRatio CGSizeRatio;



struct CGSizes {
    CGSizeRatio first;
    CGSizeRatio second;
    CGSizeRatio big;
    CGSizeRatio small;
    
    
};
typedef struct CGSizes CGSizes;



struct CGScale {
    CGFloat scale;
    CGFloat width;
    CGFloat height;
    CGFloat inverse;
    CGSizes sizes;
    MysticSizeType type;
    CGFloat equalScale;
    CGSize size;

    CGSize inverseSize;
    CGFloat ratio;
    MysticSizeType ratioType;
    CGFloat x;
    CGFloat y;
    CGSize equalSize;
    CGFloat min;
    CGFloat max;

};
typedef struct CGScale CGScale;
extern CGSizes const CGSizesZero;
extern CGScale const CGScaleEqual;
extern CGScale const CGScaleZero;
extern CGScale const CGScaleUnknown;

extern CGSizeRatio const CGSizeRatioZero;





struct MysticVector4 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
    GLfloat four;
};
typedef struct MysticVector4 MysticVector4;


struct MysticGridSize {
    CGFloat rows;
    CGFloat columns;
};
typedef struct MysticGridSize MysticGridSize;

struct CGRectMinMaxWithin
{
    CGRect frame;
    BOOL min;
    BOOL max;
    CGRect frameMin;
    CGRect frameMax;
    CGRect frameOriginal;
    BOOL changed;
};
typedef struct CGRectMinMaxWithin CGRectMinMaxWithin;

struct MysticKeyboardInfo
{
    CGRect frameBegin;
    CGRect frameEnd;
    NSTimeInterval time;
    UIViewAnimationCurve curve;
    UIViewAnimationOptions options;
};
typedef struct MysticKeyboardInfo MysticKeyboardInfo;

struct MysticColorHSB {
    
    GLfloat hue;
    GLfloat saturation;
    GLfloat brightness;
    GLfloat alpha;
    
};
typedef struct MysticHSB MysticColorHSB ;

struct CGFrameBounds {
    CGRect frame;
    CGRect bounds;
};
typedef struct CGFrameBounds CGFrameBounds;

struct CGScaleTransformOffset {
    CGScale scale;
    CGAffineTransform transform;
    CGPoint offset;
};
typedef struct CGScaleTransformOffset CGScaleTransformOffset;
extern CGScaleTransformOffset const CGScaleTransformOffsetEqual;




struct CGRectRect {
    CGRect extra;
    CGRect frame1;
    CGRect frame2;
    CGRect originalFrame1;
    CGRect originalFrame2;
    CGScale scale;

};
typedef struct CGRectRect CGRectRect;

struct CGScaleOfView {
    CGScale scale;
    CGAffineTransform transform;
    CGPoint offset;
    CGRect frame1;
    CGRect frame2;
    CGRectRect views;
};
typedef struct CGScaleOfView CGScaleOfView;
extern CGScaleOfView const CGScaleOfViewEqual;


struct CGFrameInsets {
    CGRect frame;
    UIEdgeInsets insets;
};
typedef struct CGFrameInsets CGFrameInsets;

struct MysticVector3 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
};
typedef struct MysticVector3 MysticVector3;

struct MysticMatrix4x4 {
    MysticVector4 one;
    MysticVector4 two;
    MysticVector4 three;
    MysticVector4 four;
};
typedef struct MysticMatrix4x4 MysticMatrix4x4;

struct MysticMatrix3x3 {
    MysticVector3 one;
    MysticVector3 two;
    MysticVector3 three;
};
typedef struct MysticMatrix3x3 MysticMatrix3x3;

extern NSString * const MysticAttrStringNewLineName;

extern CGPoint const CGPointVignetteCenterDefault;

extern CGPoint const CGPointUnknown;
extern CGSize const MysticSizeUnknown, MysticSizeOriginal, CGSizeUnknown, MysticSizeThumbnail, CGSizeOne;
extern CGRect const CGRectUnknown;
extern CGRect const BorderDashedRect;
extern NSString * const BorderDashed;
extern NSString * const BorderDashedSpaced;
extern NSString * const BorderDashedDouble;
extern NSString * const BorderDashedSpacedWide;
extern NSString * const BorderDashedSpacedWider;


extern CGRect const MysticRectUnknown;
extern CGAffineTransform const CGAffineTransformUnknown;
extern CGRect const MysticDefaultTransformRect;
extern UIEdgeInsets const MysticInsetsUnknown;
extern CGSize const MysticSizeControlIcon;
extern CGSize const MysticSizeControlIconSmall;

extern NSString * const MysticLayerKeyGroup;

extern NSString * const MysticLayerKeyTransform;
extern NSString * const MysticLayerKeyTransformRotate;
extern NSString * const MysticLayerKeySettingBrightness;
extern NSString * const MysticLayerKeySettingContrast;
extern NSString * const MysticLayerKeySettingLevels;
extern NSString * const MysticLayerKeySettingHighlightsShadows;
extern NSString * const MysticLayerKeySettingTiltShift;
extern NSString * const MysticLayerKeySettingSharpness;
extern NSString * const MysticLayerKeySettingGamma;
extern NSString * const MysticLayerKeySettingExposure;
extern NSString * const MysticLayerKeySettingTemperature;
extern NSString * const MysticLayerKeySettingRGB;
extern NSString * const MysticLayerKeySettingHSB;

extern NSString * const MysticLayerKeySettingHaze;
extern NSString * const MysticLayerKeySettingVignette;
extern NSString * const MysticLayerKeySettingSaturation;
extern NSString * const MysticLayerKeySettingUnsharpmask;

extern NSString * const MysticLayerKeySettingToon;
extern NSString * const MysticLayerKeySettingSketchFilter;
extern NSString * const MysticLayerKeySettingHalftone;
extern NSString * const MysticLayerKeySettingPixellate;
extern NSString * const MysticLayerKeySettingPosterize;
extern NSString * const MysticLayerKeySettingBlur;
extern NSString * const MysticLayerKeySettingBlurCircle;
extern NSString * const MysticLayerKeySettingBlurMotion;
extern NSString * const MysticLayerKeySettingBlurZoom;
extern NSString * const MysticLayerKeySettingDistortBuldge;
extern NSString * const MysticLayerKeySettingDistortStretch;
extern NSString * const MysticLayerKeySettingDistortPinch;
extern NSString * const MysticLayerKeySettingDistortGlassSphere;
extern NSString * const MysticLayerKeySettingDistortSwirl;



extern NSString * const MysticChiefPassword;
extern NSString * const MysticDefaultFontText;


extern NSString * const MysticInfoTypeKey;
extern NSString * const MysticInfoValueKey;

extern NSString * const MysticInternetNeededEventName;
extern NSString * const MysticInternetAvailableEventName;
extern NSString * const MysticInternetUnavailableEventName;

extern NSString * const MysticUserPotionChangedEventName;
extern NSString * const MysticUserPotionConfirmedEventName;
extern NSString * const MysticEventUserSelectedMediaName;
extern NSString * const MysticEventConfigUpdated;
extern NSString * const MysticEventLayersChanged;


extern NSString * const MysticEventStartDownloadingLayerImage;
extern NSString * const MysticEventDownloadingLayerImage;
extern NSString * const MysticEventFinishedDownloadingLayerImage;

extern NSString * const MysticEventLayersDeleted;
extern NSString * const MysticEventLayersMoved;
extern NSString * const MysticEventNewLayer;
extern NSString * const MysticEventLayerBecameActive;
extern NSString * const MysticEventLayerWillBecomeActive;
extern NSString * const MysticEventLayerBecameInActive;
extern NSString * const MysticEventLayerWillBecomeInActive;
extern NSString * const MysticEventWillAddLayer;
extern NSString * const MysticEventLayerAdded;
extern NSString * const MysticEventWillRemoveAllLayers;
extern NSString * const MysticEventRemovedAllLayers;

extern NSString * const MysticEventProductsRestoredNotification;
extern NSString * const MysticEventProductsRestoringNotification;
extern NSString * const MysticEventProductFailedNotification;
extern NSString * const MysticEventProductPurchasingNotification;
extern NSString * const MysticEventProductPurchasedNotification;
extern NSString * const MysticEventProductsLoadedNotification;
extern NSString * const MysticEventProductDownloadingNotification;
extern NSString * const MysticEventProductFailedNotification;


extern NSString * const MysticEventPhotoReloaded;
extern NSString * const MysticEventPhotoReloading;


extern NSString * const MysticShopProductIdentifierHandwritingCam;

extern float const kCamLayerExposure;
extern float const kCamLayerContrast;
extern float const kCamLayerSaturation;
extern float const kCamLayerSharpness;
extern float const kCamLayerWhiteLevels, kCamLayerBlackLevels;

extern float const kImageShadowHeight;
extern float const kBottomBarViewHeight;
extern float const kBottomBarHeight;
extern float const kBottomBarSmallHeight;
extern float const kBottomBarColorHeight;
extern float const kBottomBarMediumHeight;

extern float const kBottomToolBarHeight;
extern float const kTopSubBarHeight;
extern float const kBottomBarHeaderHeight;
extern float const kBottomBarHeaderBigHeight, kBottomBarHeaderMediumHeight;
extern float const kBottomBarWithLabelHeight;
extern float const kBottomBarViewWithLabelHeight;

extern float const kControlWidth;
extern float const kControlHeight;

extern float const kBgBlackAlpha;
extern float const kDefaultRotation;
extern float const kMoveStepIncrement;
extern float const kRotateStepIncrement;
extern float const kRotateSmallStepIncrement;
extern float const kSizeStepIncrement;
extern float const kFrameSizeStepIncrement;

extern float const kUnsharpMask;
extern float const kUnsharpMaskMin;
extern float const kUnsharpMaskMax;
extern float const kUnsharpMaskPixelSize;

extern float const kLevels;
extern float const kLevelsMin;
extern float const kLevelsMax;

extern float const kHaze;
extern float const kHazeMin;
extern float const kHazeMax;

extern float const kHazeSlope;
extern float const kHazeSlopeMin;
extern float const kHazeSlopeMax;

extern float const kTextAlpha;
extern float const kTextAlphaMin;
extern float const kTextAlphaMax;

extern float const kBadgeAlpha;
extern float const kBadgeAlphaMax;
extern float const kBadgeAlphaMin;

extern float const kColorAlpha;
extern float const kColorAlphaMax;
extern float const kColorAlphaMin;

extern float const kTextureAlpha;
extern float const kTextureAlphaMax;
extern float const kTextureAlphaMin;

extern float const kGamma;
extern float const kGammaMax;
extern float const kGammaMin;

extern float const kBrightness;
extern float const kBrightnessMax;
extern float const kBrightnessMin;

extern float const kExposure;
extern float const kExposureMax;
extern float const kExposureMin;

extern float const kSaturation;
extern float const kSaturationMax;
extern float const kSaturationMin;

extern float const kSharpness;
extern float const kSharpnessMax;
extern float const kSharpnessMin;

extern float const kHighlights;
extern float const kHighlightsMax;
extern float const kHighlightsMin;

extern float const kShadows;
extern float const kShadowsMax;
extern float const kShadowsMin;

extern float const kContrast;
extern float const kContrastMax;
extern float const kContrastMin;

extern float const kLightAlpha;
extern float const kLightAlphaMax;
extern float const kLightAlphaMin;

extern float const kCamLayerAlpha;
extern float const kCamLayerAlphaMax;
extern float const kCamLayerAlphaMin;

extern float const kLayerIntensity;
extern float const kFrameAlpha;
extern float const kFrameAlphaMax;
extern float const kFrameAlphaMin;

extern float const kVignette;
extern float const kVignetteMin;
extern float const kVignetteMax;
extern float const kVignetteStart;
extern float const kVignetteEnd;


extern NSTimeInterval const k24HoursInSeconds;
extern NSTimeInterval const k12HoursInSeconds;
extern NSTimeInterval const kConfigCacheExpirationTime;
extern NSTimeInterval const kConfigCacheExpirationTime30Min;

extern int const kposterizeLevels,kblurPasses;

extern float const ksphereRadius, ksphereRefractiveIndex, kpixellatePixelWidth, khalftonePixelWidth, ksketchStrength, ksketchWidth, ksketchHeight, ktoonWidth, ktoonHeight, ktoonThreshold, kbuldgeRadius,kbuldgeScale,  ktoonLevels, kswirlRadius,kswirlAngle,kpinchRadius,kpinchScale,ktiltShiftTop, ktiltShiftBottom, ktiltShiftBlurSizeInPixels, ktiltShiftFallOff, kunsharpBlurRadius, kblurCircleRadius,kblurCircleExcludeRadius,kblurCircleExcludeSize,kblurCircleAspectRatio,kblurZoomSize,kblurMotionSize,kblurMotionAngle, kblurRadius,kblurRadiusFractionWidth,kblurRadiusFractionHeight;



extern float const kHue;
extern float const kHueMin;
extern float const kHueMax;
extern float const kHueValueMin;
extern float const kHueValueMax;



extern float const kTemperature;
extern float const kTemperatureMin;
extern float const kTemperatureMax;
extern float const kTemperatureValueMin;
extern float const kTemperatureValueMax;



extern float const kTint;
extern float const kTintMin;
extern float const kTintMax;

extern float const kTiltShiftBlurRadius;

extern float const kTiltShift;
extern float const kTiltShiftMin;
extern float const kTiltShiftMax;
extern float const kTiltShiftTopOffset;
extern float const kTiltShiftBottomOffset;
extern float const kTiltShiftFallOffRate;
extern float const kSettingTiltShiftApplied;


extern float const kNoSettingsApplied;
extern float const kSettingBrightnessApplied;
extern float const kSettingGammaApplied;
extern float const kSettingExposureApplied;
extern float const kSettingHighlightApplied;
extern float const kSettingShadowApplied;
extern float const kSettingSaturationApplied;
extern float const kSettingSharpnessApplied;
extern float const kSettingVignetteApplied;
extern float const kSettingContrastApplied;
extern float const kSettingTemperatureApplied;


extern NSTimeInterval const kRenderTimeout;
int static numberOfOverlaysMade;


BOOL static kApplySunshineToFilter;
BOOL static kApplySettingsFirst;
BOOL static kApplyFilterToText;
BOOL static kApplyFilterToTexture;
BOOL static kApplyFilterToBadge;
BOOL static kApplyFilterToFrame;
BOOL static kApplyFilterToLight;
BOOL static kApplyFilterToCamLayer;

extern BOOL const kEnableStore;
extern BOOL const kEnableWriteMeCam;
extern BOOL const kEnableShapes;
extern BOOL const kEnableNativeShare;

extern BOOL const kDownloadBothPreviewAndImage;

extern int const kMysticTag;

extern int const kMaxNumberOfFeatured;

extern int const kHighestLayerLevel, kPhotoLayerLevel, kPhotoSettingsLayerLevel, kMaskLayerLevel, kFrameLayerLevel, kLightLayerLevel, kBadgeLayerLevel, kTextLayerLevel, kTextureLayerLevel, kFilterLayerLevel, kFilterAlphaLayerLevel, kBadgeAlphaLayerLevel, kTextAlphaLayerLevel, kFrameNoBlendLayerLevel, kLightNoBlendLayerLevel,kTextureNoBlendLayerLevel,  kBadgeNoBlendLayerLevel, kTextNoBlendLayerLevel, kPhotoSourceSettingsLayerLevel, kCamLayerNoBlendLayerLevel, kCamLayerLayerLevel ;



extern NSString * const kMysticBlockTitle;
extern NSString * const kMysticBlockSubTitle;
extern NSString * const kMysticBlockEnabled;
extern NSString * const kMysticBlockTagId;

extern NSString * const kMysticBlockText;
extern NSString * const kMysticBlockImageUrl;
extern NSString * const kMysticBlockThumbnailUrl;
extern NSString * const kMysticBlockImageHighUrl;
extern NSString * const kMysticBlockImageFullUrl;

extern NSString * const kMysticBlockVideoUrl;
extern NSString * const kMysticBlockLinkUrl;
extern NSString * const kMysticBlockLayout;
extern NSString * const kMysticBlockType;
extern NSString * const kMysticBlockAttrText;
extern NSString * const kMysticBlockSize;
extern NSString * const kMysticBlockHTML;
extern NSString * const kMysticBlockBlocks;
extern NSString * const kMysticBlockFilename;
extern NSString * const kMysticBlockFilepath;
extern NSString * const kMysticBlockColor;
extern NSString * const kMysticBlockDisplayColor;
extern NSString * const kMysticBlockColors;

extern NSString * const SPACE;
extern NSString * const SKP;
extern NSString * const LINE;
extern NSString * const kBGb;
extern NSString * const kBGd;
extern NSString * const kBG;
extern NSString * const kBGk;

extern NSString * const kBGEnd;
extern NSString * const kBGPrefix;

extern NSString * const kNullKey;


extern NSString * const mkLine;
extern NSString * const mkLineMed;
extern NSString * const mkLineFat;
extern NSString * const mkLineThin;
extern NSString * const mkLBlock;
extern NSString * const mkLDouble;
extern NSString * const mkLDots;
extern NSString * const mkLStar;

extern NSString * const mkLineKey;
extern NSString * const mkLineMedKey;
extern NSString * const mkLineFatKey;
extern NSString * const mkLineThinKey;
extern NSString * const mkLBlockKey;
extern NSString * const mkLDoubleKey;
extern NSString * const mkLDotsKey;
extern NSString * const mkLStarKey;

extern NSString * const mkLineIndent;
extern NSString * const mkLineMedIndent;
extern NSString * const mkLineFatIndent;
extern NSString * const mkLineThinIndent;
extern NSString * const mkLBlockIndent;
extern NSString * const mkLDoubleIndent;
extern NSString * const mkLDotsIndent;
extern NSString * const mkLStarIndent;

extern NSString * const mkLineFull;
extern NSString * const mkLineMedFull;
extern NSString * const mkLineFatFull;
extern NSString * const mkLineThinFull;
extern NSString * const mkLBlockFull;
extern NSString * const mkLDoubleFull;
extern NSString * const mkLDotsFull;
extern NSString * const mkLStarFull;

extern NSString * const mkLineSpaceNone;
extern NSString * const mkLineMedSpaceNone;
extern NSString * const mkLineFatSpaceNone;
extern NSString * const mkLineThinSpaceNone;
extern NSString * const mkLBlockSpaceNone;
extern NSString * const mkLDoubleSpaceNone;
extern NSString * const mkLDotsSpaceNone;
extern NSString * const mkLStarSpaceNone;

extern NSString * const mkLineSpaceAfter;
extern NSString * const mkLineMedSpaceAfter;
extern NSString * const mkLineFatSpaceAfter;
extern NSString * const mkLineThinSpaceAfter;
extern NSString * const mkLBlockSpaceAfter;
extern NSString * const mkLDoubleSpaceAfter;
extern NSString * const mkLDotsSpaceAfter;
extern NSString * const mkLStarSpaceAfter;

extern NSString * const mkLineSpaceBefore;
extern NSString * const mkLineMedSpaceBefore;
extern NSString * const mkLineFatSpaceBefore;
extern NSString * const mkLineThinSpaceBefore;
extern NSString * const mkLBlockSpaceBefore;
extern NSString * const mkLDoubleSpaceBefore;
extern NSString * const mkLDotsSpaceBefore;
extern NSString * const mkLStarSpaceBefore;



#endif /* MysticTypedefs_h */

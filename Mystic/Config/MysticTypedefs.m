//
//  MysticTypedefs.m
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticTypedefs.h"


BOOL const kEnableStore = NO;
BOOL const kEnableWriteMeCam = YES;
BOOL const kEnableShapes = NO;
BOOL const kEnableNativeShare = YES;
BOOL const kDownloadBothPreviewAndImage = YES;

MysticShaderIndex const MysticShaderIndexUnknown ={-1,-1,-1,-1,-1};

MysticCollectionRange const MysticCollectionRangeUnknown = {-1,-1,-1,-1,-1};
MysticCollectionRange const MysticCollectionRangeZero = {0,0,0,0,0};
CGSize const CGSizeUnknown = {99999.9f, 99999.9f};
CGSize const MysticSizeUnknown = {99999.9f, 99999.9f};
CGSize const MysticSizeOriginal = {8888888.9f, 8888888.9f};
CGSize const MysticSizeThumbnail = {250.f, 250.f};
CGSize const CGSizeOne = {1.f,1.f};
CGRect const MysticRectUnknown = {99999.9f, 99999.9f, 99999.9f, 99999.9f};
CGRect const CGRectUnknown = {99999.9f, 99999.9f, 99999.9f, 99999.9f};
CGRect const BorderDashedRect = {1, 0, 1, 1};
NSString * const BorderDashed = @"1,1";
NSString * const BorderDashedSpaced = @"1,3";
NSString * const BorderDashedSpacedWide = @"1,3";
NSString * const BorderDashedSpacedWider = @"1,4";
NSString * const BorderDashedDouble = @"2,2";


CGAffineTransform const CGAffineTransformUnknown = {MYSTIC_FLOAT, MYSTIC_FLOAT, MYSTIC_FLOAT, MYSTIC_FLOAT, MYSTIC_FLOAT, MYSTIC_FLOAT};
CGRect const MysticDefaultTransformRect = {0.0f, 0.0f, 1.0f, 1.0f};
MysticThreshold const MysticThresholdDefault = {{-0.25f, 0.35, 0.25f},0.22f,0.86f,1.f};
MysticThreshold const MysticThresholdLow = {{-0.1f,0.1,0.1f},0.1f,0.1f,0.01f};
MysticThreshold const MysticThresholdHigh = {{-0.8,0.8, 0.8f},0.8f,0.8f,0.6f};
MysticThreshold const MysticThresholdMedium = {{-0.5,0.5,0.5f},0.5f,0.5f,0.35f};


MysticHSB const MysticHSBDefault = {0.0f, 1.0f, 1.0f};

CGSizeRatio const CGSizeRatioZero = {0,0,0,MysticSizeTypeNone};
CGSizes const CGSizesZero = {{0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}};
CGScale const CGScaleEqual = {1.0f, 1.0f, 1.0f, 1.0f, {{0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}}, MysticSizeTypeEqual, 1, {1,1},{1,1}, 1, MysticSizeTypeNone, 1, 1, {1,1}, 1, 1};
CGScale const CGScaleZero = {0.f, 0.f, 0.f, 0.f, {{0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}, {0,0,0,MysticSizeTypeNone}}, MysticSizeTypeNone, 0, {0,0},{0,0}, 0, MysticSizeTypeNone, 0, 0, {0,0}, 0, 0};

CGScale const CGScaleUnknown = {999.f, 999.f, 999.f, 999.f, {{0,0,0,MysticSizeTypeUnknown}, {0,0,0,MysticSizeTypeUnknown}, {0,0,0,MysticSizeTypeUnknown}, {0,0,0,MysticSizeTypeUnknown}}, MysticSizeTypeUnknown, 999.f, {99999.9f, 99999.9f},{99999.9f, 99999.9f}, 999.f, MysticSizeTypeUnknown, 999.f, 999.f, {999.f,999.f}, 999, 999};


CGScaleTransformOffset const CGScaleTransformOffsetEqual = {{1.0f, 1.0f, 1.0f, 1.0f, {{0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}}, MysticSizeTypeEqual, 1, {1,1},{1,1}, 1, MysticSizeTypeNone, 1, 1, {1,1}},{1,0,0,1,0,0},{0,0}};


CGScaleOfView const CGScaleOfViewEqual = {{1.0f, 1.0f, 1.0f, 1.0f, {{0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}}, MysticSizeTypeEqual, 1, {1,1},{1,1}, 1, MysticSizeTypeNone, 1, 1, {1,1}},
    {1,0,0,1,0,0}, // transform
    {0,0}, // offset
    {0,0,0,0}, // frame1
    {0,0,0,0}, // frame2
    {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{1.0f, 1.0f, 1.0f, 1.0f, {{0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}, {0,0,0,MysticSizeTypeEqual}}, MysticSizeTypeEqual, 1, {1,1},{1,1}, 1, MysticSizeTypeNone, 1, 1, {1,1}}}};

CGPoint const CGPointVignetteCenterDefault = {0.5,0.5};
CGPoint const CGPointUnknown = {MYSTIC_FLOAT_UNKNOWN, MYSTIC_FLOAT_UNKNOWN};
UIEdgeInsets const MysticInsetsUnknown = {99999.9f, 99999.9f, 99999.9f,99999.9f};


MysticBrush const MysticBrushDefault = {0,0.15,1,0,1,100};

int const kMaxNumberOfFeatured = 12;

NSTimeInterval const kRenderTimeout = 0.25;

NSTimeInterval const k24HoursInSeconds = 86400.0f;
NSTimeInterval const k12HoursInSeconds = 86400.0f;


// checks every 5 min

NSTimeInterval const kConfigCacheExpirationTime30Min = 1800.f;
NSTimeInterval const kConfigCacheExpirationTime = 300.0f;


CGSize const MysticSizeControlIcon = {30.f, 30.f};
CGSize const MysticSizeControlIconSmall = {20.f, 20.f};

int static numberOfOverlaysMade = 0;


#ifdef MYSTIC_PROCESS_SAFE_MODE

BOOL static kApplySettingsFirst = NO;
BOOL static kApplyFilterToText = NO;
BOOL static kApplyFilterToTexture = NO;
BOOL static kApplyFilterToBadge = NO;
BOOL static kApplyFilterToFrame = NO;
BOOL static kApplyFilterToLight = NO;
BOOL static kApplyFilterToCamLayer = NO;
BOOL static kApplySunshineToFilter = NO;

#else

BOOL static kApplySettingsFirst = NO;
BOOL static kApplyFilterToText = YES;
BOOL static kApplyFilterToTexture = YES;
BOOL static kApplyFilterToBadge = YES;
BOOL static kApplyFilterToFrame = NO;
BOOL static kApplyFilterToLight = YES;
BOOL static kApplyFilterToCamLayer = NO;
BOOL static kApplySunshineToFilter = NO;

#endif




//float const kMoveStepIncrement = 0.03;
float const kMoveStepIncrement = 0.01;
float const kRotateStepIncrement = 0.5f;
float const kRotateSmallStepIncrement = 0.01f;
float const kSizeStepIncrement = 0.01f;
float const kFrameSizeStepIncrement = 0.01f;
float const kDefaultRotation = 0.0f;

float const kLayerIntensity = 1.0f;
float const kBgBlackAlpha = 0.0f;
float const kFrameAlpha = 1.0f;
float const kTextAlpha = 1.0f;
float const kBadgeAlpha = 2.0f;
float const kColorAlpha = 0.5f;
float const kTextureAlpha = 1.0f;
float const kLightAlpha = 1.0f;
float const kGamma = 1.0f;
float const kExposure = 0.0f;

float const kHighlights = 1.0f;
float const kShadows = 0.0f;
float const kVignetteMin = 0.0f;
float const kVignette = 0.0f;
float const kVignetteMax = 1.0f;
float const kVignetteStart = 0.5f;
float const kVignetteEnd = 0.75f;

float const kCamLayerBlackLevels = 0.2;
float const kCamLayerWhiteLevels = 0.55;
float const kCamLayerExposure = 0.0f;
float const kCamLayerContrast = 1.0f;
float const kCamLayerSaturation = 1.0f;
float const kCamLayerSharpness = 0.2;

float const kTextAlphaMax = 1.0f;
float const kFrameAlphaMax = 1.0f;
float const kBadgeAlphaMax = 1.0f;
float const kColorAlphaMax = 1.0f;
float const kTextureAlphaMax = 1.0f;
float const kLightAlphaMax = 1.0f;
float const kGammaMax = 2.0f;
float const kExposureMax = 2.0f;

float const kHighlightsMax = 1.0f;
float const kShadowsMax = 1.0f;

float const kFrameAlphaMin = 0.0f;
float const kTextAlphaMin = 0.0f;
float const kBadgeAlphaMin = 0.0f;
float const kColorAlphaMin = 0.0f;
float const kTextureAlphaMin = 0.0f;
float const kLightAlphaMin = 0.0f;
float const kGammaMin = 0.0f;


float const kSharpness = 0.0f;
float const kSharpnessMax = 6.0f;
float const kSharpnessMin = 0.0f;


float const kExposureMin = -2.0f;

float const kHighlightsMin = 0.0f;
float const kShadowsMin = 0.0f;

float const kContrastMin = 0.0f;
float const kContrast = 1.0f;
float const kContrastMax = 2.0f;

float const kBrightnessMax = 0.6f;
float const kBrightness = 0.0f;
float const kBrightnessMin = -0.6f;

float const kSaturationMin = 0.0f;
float const kSaturation = 1.0f;
float const kSaturationMax = 2.0f;

float const kLevels = 0.0f;
float const kLevelsMin = 0.0f;
float const kLevelsMax = 1.0f;

float const kUnsharpMask = 1.0f;
float const kUnsharpMaskMin = 0.0f;
float const kUnsharpMaskMax = 5.0f;
float const kUnsharpMaskPixelSize = 4.0f;

float const kHaze = 0.0f;
float const kHazeMin = -0.4f;
float const kHazeMax = 0.4f;

float const kHazeSlope = 0.0f;
float const kHazeSlopeMin = -0.4f;
float const kHazeSlopeMax = 0.4f;

float const kCamLayerAlphaMin = 0.0f;
float const kCamLayerAlphaMax = 1.0f;
float const kCamLayerAlpha = 1.0f;

float const kImageShadowHeight = 12.0f;
float const kBottomBarViewHeight = 110.0f;
float const kBottomBarHeight = 109.0f;
float const kBottomBarSmallHeight = 70.0f;
float const kBottomBarColorHeight = 50.0f;

float const kBottomBarMediumHeight = 90.0f;

float const kBottomBarWithLabelHeight = 110.0f;
float const kBottomBarViewWithLabelHeight = 110.0f;
float const kBottomToolBarHeight = 80.0f;
float const kTopSubBarHeight = 50.0f;
float const kBottomBarHeaderHeight = 40.0f;
float const kBottomBarHeaderMediumHeight = 50.0f;
float const kBottomBarHeaderBigHeight = 70.0f;

float const kTint = 0.0f;
float const kTintMin = 0.0f;
float const kTintMax = 100.0f;

float const kHue = 0.f;
float const kHueMin = 0.f;
float const kHueMax = 360.f;
float const kHueValueMin = 0.f;
float const kHueValueMax = 360.f;

int const   kposterizeLevels = 7;
int const   kblurPasses = 1;

float const ksphereRadius = 0.25f;
float const ksphereRefractiveIndex = 0.71f;
float const kpixellatePixelWidth = 0.05f;
float const khalftonePixelWidth = 0.02f;
float const ksketchStrength = 1.0f;
float const ksketchWidth = 1.f;
float const ksketchHeight = 1.f;
float const ktoonWidth = 1.f;
float const ktoonHeight = 1.f;
float const kbuldgeRadius = 0.25f;
float const kbuldgeScale = 0.5f;

float const ktoonThreshold = 0.2f;
float const ktoonLevels = 10.f;
float const kswirlRadius = 0.5f;
float const kswirlAngle = 1.0f;
float const kpinchRadius = 1.0f;
float const kpinchScale = 1.0f;
float const ktiltShiftTop = 0.2f;
float const ktiltShiftBottom = 0.8f;
float const ktiltShiftBlurSizeInPixels = 7.0f;
float const ktiltShiftFallOff = 0.2f;
float const kunsharpBlurRadius = 4.0f;
float const kblurCircleRadius = 5.0f;
float const kblurCircleExcludeRadius = 0.1875f;
float const kblurCircleExcludeSize = 0.09375f;
float const kblurCircleAspectRatio = 1.0f;
float const kblurMotionSize = 1.0f;
float const kblurMotionAngle = 0.0f;
float const kblurZoomSize = 1.0f;
float const kblurRadius = 2.0f;
float const kblurRadiusFractionWidth = 0.0f;
float const kblurRadiusFractionHeight = 0.0f;



float const kTemperature = 1.f;
float const kTemperatureMin = 0.f;
float const kTemperatureMax = 2.f;
float const kTemperatureValueMin = 1500.f;
float const kTemperatureValueMax = 8500.f;

int const kPhotoLayerLevel = 0;
int const kPhotoSourceSettingsLayerLevel = 1  ;
int const kMaskLayerLevel = 3;
int const kFrameLayerLevel = 5;
int const kLightLayerLevel = 4;
int const kBadgeLayerLevel = 6;
int const kCamLayerLayerLevel = 7;
int const kTextLayerLevel = 8;
int const kTextureLayerLevel = 9;

int const kFilterLayerLevel = 10;
int const kFilterAlphaLayerLevel = 11;
int const kBadgeAlphaLayerLevel = 12;
int const kTextAlphaLayerLevel = 13;
int const kFrameNoBlendLayerLevel = 14;
int const kBadgeNoBlendLayerLevel = 15;
int const kCamLayerNoBlendLayerLevel = 16;
int const kLightNoBlendLayerLevel = 17;
int const kTextureNoBlendLayerLevel = 18;
int const kTextNoBlendLayerLevel = 19;
int const kPhotoSettingsLayerLevel = 20  ;
int const kHighestLayerLevel = 21;

float const kNoSettingsApplied = 0.0f;
float const kSettingBrightnessApplied = 444444.0f;
float const kSettingGammaApplied = 66666666.0f;
float const kSettingExposureApplied = 5555555.0f;
float const kSettingHighlightApplied = 99999999999.0f;
float const kSettingShadowApplied = 8888888888.0f;
float const kSettingSaturationApplied = 2222.0f;
float const kSettingSharpnessApplied = 777777777.0f;
float const kSettingVignetteApplied = 33333.0f;
float const kSettingContrastApplied = 1.0f;
float const kSettingTemperatureApplied = 111111111111111.0f;

float const kSettingTiltShiftApplied = 1.5f;
float const kTiltShift = 0.2f;
float const kTiltShiftMin = 0.2f;
float const kTiltShiftMax = 0.8f;
float const kTiltShiftTopOffset = -0.2f;
float const kTiltShiftBottomOffset = 0.2f;
float const kTiltShiftFallOffRate = 0.25f;
float const kTiltShiftBlurRadius = 7.0f;


float const kControlWidth = 70.0f;
float const kControlHeight = 71.0f;


int const kMysticTag = 7864311;

NSString * const MysticChiefPassword = @"followurdreams11";
NSString * const MysticAttrStringNewLineName = @"MysticNewLine";


NSString * const MysticLayerKeyGroup = @"group";

NSString * const MysticLayerKeyTransform = @"transform";
NSString * const MysticLayerKeyTransformRotate = @"transformRotate";
NSString * const MysticLayerKeySettingBrightness = @"SettingBrightness";
NSString * const MysticLayerKeySettingContrast = @"SettingContrast";
NSString * const MysticLayerKeySettingLevels = @"SettingLevels";
NSString * const MysticLayerKeySettingHighlightsShadows = @"SettingHighlightsShadows";
NSString * const MysticLayerKeySettingTiltShift = @"SettingTiltShift";
NSString * const MysticLayerKeySettingSharpness = @"SettingSharpness";
NSString * const MysticLayerKeySettingGamma = @"SettingGamma";
NSString * const MysticLayerKeySettingExposure = @"SettingExposure";
NSString * const MysticLayerKeySettingTemperature = @"SettingTemperature";
NSString * const MysticLayerKeySettingRGB = @"SettingRGB";
NSString * const MysticLayerKeySettingHSB = @"SettingHSB";

NSString * const MysticLayerKeySettingHaze = @"SettingHaze";
NSString * const MysticLayerKeySettingVignette = @"SettingVignette";
NSString * const MysticLayerKeySettingSaturation = @"SettingSaturation";
NSString * const MysticLayerKeySettingUnsharpmask = @"SettingUnsharpmask";


NSString * const MysticLayerKeySettingToon = @"SettingToon";
NSString * const MysticLayerKeySettingSketchFilter = @"SettingSketchFilter";
NSString * const MysticLayerKeySettingHalftone = @"SettingHalftone";
NSString * const MysticLayerKeySettingPixellate = @"SettingPixellate";
NSString * const MysticLayerKeySettingPosterize = @"SettingPosterize";
NSString * const MysticLayerKeySettingBlur = @"SettingBlur";
NSString * const MysticLayerKeySettingBlurCircle = @"SettingBlurCircle";
NSString * const MysticLayerKeySettingBlurMotion = @"SettingBlurMotion";
NSString * const MysticLayerKeySettingBlurZoom = @"SettingBlurZoom";
NSString * const MysticLayerKeySettingDistortBuldge = @"SettingDistortBuldge";
NSString * const MysticLayerKeySettingDistortStretch = @"SettingDistortStretch";
NSString * const MysticLayerKeySettingDistortPinch = @"SettingDistortPinch";
NSString * const MysticLayerKeySettingDistortGlassSphere = @"SettingDistortGlassSphere";
NSString * const MysticLayerKeySettingDistortSwirl = @"SettingDistortSwirl";


NSString * const MysticDefaultFontText = MYSTIC_DEFAULT_FONT_TEXT;

NSString * const MysticInfoTypeKey = @"MysticInfoTypeKey";
NSString * const MysticInfoValueKey = @"MysticInfoValueKey";

NSString * const MysticInternetNeededEventName = @"MysticInternetNeededEventName";
NSString * const MysticInternetAvailableEventName = @"MysticInternetAvailableEventName";
NSString * const MysticInternetUnavailableEventName = @"MysticInternetUnavailableEventName";

NSString * const MysticUserPotionChangedEventName = @"MysticUserPotionChangedEvent";
NSString * const MysticEventUserSelectedMediaName = @"MysticEventUserSelectedMediaName";
NSString * const MysticUserPotionConfirmedEventName = @"MysticUserPotionConfirmedEvent";
NSString * const MysticEventConfigUpdated = @"MysticConfigUpdated";
NSString * const MysticEventLayersChanged = @"MysticEventLayersChanged";
NSString * const MysticEventLayerBecameInActive = @"MysticEventLayerBecameInActive";
NSString * const MysticEventLayerWillBecomeInActive = @"MysticEventLayerWillBecomeInActive";
NSString * const MysticEventLayersDeleted = @"MysticEventLayersDeleted";
NSString * const MysticEventLayersMoved = @"MysticEventLayersMoved";
NSString * const MysticEventNewLayer = @"MysticEventNewLayer";
NSString * const MysticEventLayerBecameActive = @"MysticEventLayerBecameActive";
NSString * const MysticEventLayerWillBecomeActive = @"MysticEventLayerWillBecomeActive";
NSString * const MysticEventWillAddLayer = @"MysticEventWillAddLayer";
NSString * const MysticEventLayerAdded = @"MysticEventLayerAdded";
NSString * const MysticEventWillRemoveAllLayers = @"MysticEventWillRemoveAllLayers";
NSString * const MysticEventRemovedAllLayers = @"MysticEventRemovedAllLayers";

NSString * const MysticEventPhotoReloading = @"MysticEventPhotoReloading";
NSString * const MysticEventPhotoReloaded = @"MysticEventPhotoReloaded";


NSString * const MysticEventProductsLoadedNotification = @"MysticProductsLoadedNotification";
NSString * const MysticEventProductPurchasingNotification = @"MysticProductPurchasingNotification";
NSString * const MysticEventProductFailedNotification = @"MysticProductFailedNotification";
NSString * const MysticEventProductPurchasedNotification = @"MysticProductPurchasedNotification";
NSString * const MysticEventProductDownloadingNotification = @"MysticProductDownloadingNotification";
NSString * const MysticEventProductsRestoringNotification = @"MysticProductsRestoringNotification";
NSString * const MysticEventProductsRestoredNotification = @"MysticProductsRestoredNotification";


NSString * const MysticEventStartDownloadingLayerImage = @"MysticEventStartDownloadingLayerImage";
NSString * const MysticEventDownloadingLayerImage = @"MysticEventDownloadingLayerImage";
NSString * const MysticEventFinishedDownloadingLayerImage = @"MysticEventFinishedDownloadingLayerImage";

NSString * const MysticShopProductIdentifierHandwritingCam = @"ch.mysti.ch.handwritingcam";

NSString * const kBGb = @"&kBGb;";
NSString * const kBGd = @"&kBGd;";
NSString * const kBGk = @"&kBGk;";

NSString * const kBG = @"&kBG;";
NSString * const kBGEnd = @"&kBGEnd;";
NSString * const kBGPrefix = @"&kBG";

NSString * const kNullKey = @"&;";

NSString * const LINE = @" - ";
NSString * const SPACE = @" ";

NSString * const SKP = @"#s";
NSString * const mkLine = @"|-";
NSString * const mkLineMed = @"|-+";
NSString * const mkLineFat = @"|-++";
NSString * const mkLineThin= @"|--";
NSString * const mkLBlock= @"|&";
NSString * const mkLDouble= @"|=";
NSString * const mkLDots= @"|..";
NSString * const mkLStar= @"|*";


NSString * const mkLineKey = @"|-";
NSString * const mkLineMedKey = @"|-+";
NSString * const mkLineFatKey = @"|-++";
NSString * const mkLineThinKey= @"|--";
NSString * const mkLBlockKey= @"|&";
NSString * const mkLDoubleKey= @"|=";
NSString * const mkLDotsKey= @"|..";
NSString * const mkLStarKey= @"|*";


NSString * const mkLineIndent = @":-";
NSString * const mkLineMedIndent = @":-+";
NSString * const mkLineFatIndent = @":-++";
NSString * const mkLineThinIndent= @":--";
NSString * const mkLBlockIndent= @":&";
NSString * const mkLDoubleIndent= @":=";
NSString * const mkLDotsIndent= @":..";
NSString * const mkLStarIndent= @":*";

NSString * const mkLineFull = @" - ";
NSString * const mkLineMedFull = @" -+ ";
NSString * const mkLineFatFull = @" -++ ";
NSString * const mkLineThinFull= @" -- ";
NSString * const mkLBlockFull= @" & ";
NSString * const mkLDoubleFull= @" = ";
NSString * const mkLDotsFull= @" .. ";
NSString * const mkLStarFull= @" * ";

NSString * const mkLineSpaceNone= @"-";
NSString * const mkLineMedSpaceNone= @"-+";
NSString * const mkLineFatSpaceNone= @"-++";
NSString * const mkLineThinSpaceNone= @"--";
NSString * const mkLBlockSpaceNone= @"&";
NSString * const mkLDoubleSpaceNone= @"=";
NSString * const mkLDotsSpaceNone= @"..";
NSString * const mkLStarSpaceNone= @"*";

NSString* const mkLineSpaceAfter=@"- ";
NSString* const mkLineMedSpaceAfter=@"-+ ";
NSString* const mkLineFatSpaceAfter=@"-++ ";
NSString* const mkLineThinSpaceAfter=@"-- ";
NSString* const mkLBlockSpaceAfter=@"& ";
NSString* const mkLDoubleSpaceAfter=@"= ";
NSString* const mkLDotsSpaceAfter=@".. ";
NSString* const mkLStarSpaceAfter=@"* ";

NSString* const mkLineSpaceBefore=@" -";
NSString* const mkLineMedSpaceBefore=@" -+";
NSString* const mkLineFatSpaceBefore=@" -++";
NSString* const mkLineThinSpaceBefore=@" --";
NSString* const mkLBlockSpaceBefore=@" &";
NSString* const mkLDoubleSpaceBefore=@" =";
NSString* const mkLDotsSpaceBefore=@" ..";
NSString* const mkLStarSpaceBefore=@" *";


NSString * const kMysticBlockTitle = @"title";
NSString * const kMysticBlockSubTitle = @"subtitle";
NSString * const kMysticBlockEnabled = @"enabled";
NSString * const kMysticBlockTagId = @"tag";
NSString * const kMysticBlockText = @"text";
NSString * const kMysticBlockImageUrl = @"image";
NSString * const kMysticBlockThumbnailUrl = @"thumbnail";
NSString * const kMysticBlockImageHighUrl = @"image-high";
NSString * const kMysticBlockImageFullUrl = @"image-full";
NSString * const kMysticBlockVideoUrl = @"video";
NSString * const kMysticBlockLinkUrl = @"link";
NSString * const kMysticBlockLayout = @"layout";
NSString * const kMysticBlockType = @"type";
NSString * const kMysticBlockAttrText = @"attrText";
NSString * const kMysticBlockSize = @"size";
NSString * const kMysticBlockHTML = @"html";
NSString * const kMysticBlockBlocks = @"blocks";
NSString * const kMysticBlockFilename = @"filename";
NSString * const kMysticBlockFilepath = @"file";
NSString * const kMysticBlockColor = @"color";
NSString * const kMysticBlockDisplayColor = @"color-display";
NSString * const kMysticBlockColors = @"gradient";

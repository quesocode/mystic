//
//  PackPotionOption.m
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#import "MysticLog.h"

#import "MysticEffectsManager.h"
#import "PackPotionOption.h"
#import "Mystic.h"
#import "UIColor+Mystic.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "EffectControl.h"
#import "MysticController.h"
#import "MysticCacheImage.h"
#import "UserPotion.h"
#import "MysticRenderEngine.h"
#import "MysticImageFilter.h"
#import "PackPotionOptionColor.h"
#import "NSArray+Mystic.h"
#import "JPNG.h"
#import "NSNumber+Mystic.h"




MysticMatrix4x4 MysticMatrix4x4From(GPUMatrix4x4 matrix)
{
    return (MysticMatrix4x4){
        {matrix.one.one, matrix.one.two, matrix.one.three, matrix.one.four},
        {matrix.two.one, matrix.two.two, matrix.two.three, matrix.two.four},
        {matrix.three.one, matrix.three.two, matrix.three.three, matrix.three.four},
        {matrix.four.one, matrix.four.two, matrix.four.three, matrix.four.four}
    };
    
}


@interface PackPotionOption () <MysticControlObjectDelegate>
{
    MysticFilterType __blendingMode;
    NSInteger __userBlended, lastFinalAdjustCount, mapImageCount;
    NSArray *observeProps, *floatProps, *intProps, *boolProps, *otherProps, *sizeProps,*rectProps, *ignoreProps, *insetsProps;
    NSMutableArray *cachedImages;
    BOOL __shouldBlendWithPreviousTextureFirst;
}
@property (nonatomic, retain) NSMutableDictionary *refreshingAdjustmentsDict;
@property (nonatomic, retain) NSString *uniqueTagValue;
@property (nonatomic, assign) BOOL registeredForChanges, hasSavedMaskImage, hasSavedMapImage;

@end

@implementation PackPotionOption

@dynamic targetOption, readyForRender;

@synthesize ignoreRender=_ignoreRender, isPreviewOption=_isPreviewOption, sourceImage=_sourceImage, renderedImage=_renderedImage, hasImage, inverted=_inverted,blended=_blended, featured=_featured, presetIntensity=_presetIntensity, presetBlending=_presetBlending, presetInvert=_presetInvert, presetSunshine=_presetSunshine, foregroundColor=_foregroundColor, blendingModeStr, layerImage=_layerImage, blending, intensity=_intensity, chromaColor=_chromaColor, smoothingSensitivity=_smoothingSensitivity, sensitivity=_sensitivity, shouldInvert,  backgroundColorVec4Str, smoothing=_smoothing, colorTypes=_colorTypes, adjustments, hasAdjustments, tint=_tint, midLevels=_midLevels, uniqueTag=_uniqueTag, stackPosition=_stackPosition, stackPositionKey, transform=_transform, canTransform, foregroundColorType, backgroundColorType, userInfo, layerImagePath=_layerImagePath, previewImagePath=_previewImagePath, originalLayerImagePath=_originalLayerImagePath, cropRect, layerImageSize=_layerImageSize, previewImageSize=_previewImageSize, thumbImageSize=_thumbImageSize, originalImageSize=_originalImageSize, hasForegroundColor, sourceImageURL=_sourceImageURL, hasInput, hasShader, layerEffect, maxLayerEffect, hasChanged=_hasChanged, isTransforming=_isTransforming,  thumbnailHighlighted=_thumbnailHighlighted, thumbnail=_thumbnail, thumbnailSelected=_thumbnailSelected,controlWasVisible, alphaMaskImage, alphaMaskImageURLString, fillMode, blendingType=_blendingType, colorMatrix=_colorMatrix, colorMatrixIntensity=_colorMatrixIntensity, observeProps=_observeProps, registeredForChanges=_registeredForChanges, rotateTransform=_rotateTransform, activePack=_activePack, hsb=_hsb, adjustedRect=_adjustedRect, usesAccessory=_usesAccessory, showBg=_showBg, hasProcessedThumbnail=_hasProcessedThumbnail;

@synthesize emailBCC=_emailBCC, emailCC=_emailCC, emailTo=_emailTo, emailMessage=_emailMessage, emailSubject=_emailSubject, tweet=_tweet, facebook=_facebook, isHTMLEmail, messageLink=_messageLink, folderName=_folderName, stretchLayerImage=_stretchLayerImage, shouldBlendWithPreviousTextureFirst=_shouldBlendWithPreviousTextureFirst;

@synthesize blurPasses=_blurPasses;
@synthesize sphereRadius=_sphereRadius, sphereRefractiveIndex=_sphereRefractiveIndex, pixellatePixelWidth=_pixellatePixelWidth, halftonePixelWidth=_halftonePixelWidth, sketchStrength=_sketchStrength, sketchWidth=_sketchWidth, sketchHeight=_sketchHeight, toonWidth=_toonWidth, toonHeight=_toonHeight, toonThreshold=_toonThreshold, toonLevels=_toonLevels, posterizeLevels=_posterizeLevels,swirlRadius=_swirlRadius,swirlAngle=_swirlAngle,pinchRadius=_pinchRadius,pinchScale=_pinchScale,tiltShiftTop=_tiltShiftTop, tiltShiftBottom=_tiltShiftBottom, tiltShiftBlurSizeInPixels=_tiltShiftBlurSizeInPixels, tiltShiftFallOff=_tiltShiftFallOff, unsharpBlurRadius=_unsharpBlurRadius, blurCircleRadius=_blurCircleRadius,blurCircleExcludeRadius=_blurCircleExcludeRadius,blurCircleExcludeSize=_blurCircleExcludeSize,blurCircleAspectRatio=_blurCircleAspectRatio,blurZoomSize=_blurZoomSize,blurMotionSize=_blurMotionSize,blurMotionAngle=_blurMotionAngle, blurRadius=_blurRadius,blurRadiusFractionWidth=_blurRadiusFractionWidth,blurRadiusFractionHeight=_blurRadiusFractionHeight;

@synthesize sphereCenter=_sphereCenter, stretchCenter=_stretchCenter, pinchCenter=_pinchCenter, buldgeCenter=_buldgeCenter, swirlCenter=_swirlCenter,blurZoomCenter=_blurZoomCenter, blurCirclePoint=_blurCirclePoint;

+ (PackPotionOption *) optionWithName:(NSString *)name info:(NSDictionary *)info;
{
    PackPotionOption *option = (PackPotionOption *)[super optionWithName:name info:info];
    
    option.featured = [info objectForKey:@"featured"] ? [[info objectForKey:@"featured"] boolValue] : NO;
    option.presetBlending = [info objectForKey:@"preset_blending"] ? [[info objectForKey:@"preset_blending"] boolValue] : NO;
    option.presetSunshine = [info objectForKey:@"preset_sunshine"] ? [[info objectForKey:@"preset_sunshine"] boolValue] : NO;
    option.presetInvert = [info objectForKey:@"preset_invert"] ? [[info objectForKey:@"preset_invert"] boolValue] : NO;
    
    option.presetIntensity = [info objectForKey:@"preset_intensity"] ? [[info objectForKey:@"preset_intensity"] floatValue] : 1.0f;
    option.presetIntensity = option.presetIntensity <= 0.0 ? 0.0 : option.presetIntensity;
    
    
    return option;
}

- (void) dealloc;
{
    [self unregisterForChangeNotification];
    [_adjustColors release];
    [observeProps release];
    [sizeProps release];
    [cachedImages release];
    [boolProps release];
    [otherProps release];
    [intProps release];
    [floatProps release];
    [insetsProps release];
    [_maskImagePath release];
    [rectProps release];
    [ignoreProps release];
    [_activePack release];
    [_thumbnail release], _thumbnail=nil;
    [_thumbnailHighlighted release], _thumbnailHighlighted = nil;
    [_thumbnailSelected release], _thumbnailSelected=nil;
    [_resourcePaths release], _resourcePaths=nil;
    if(_refreshingAdjustmentsDict) [_refreshingAdjustmentsDict release];
    if(_colorTypes)
    {
        [_colorTypes removeAllObjects];
        [_colorTypes release], _colorTypes=nil;
    }
    [_sourceImageURL release], _sourceImageURL=nil;
    [_backgroundColor release], _backgroundColor=nil;
    [_foregroundColor release], _foregroundColor=nil;
    [_chromaColor release], _chromaColor=nil;
    [_blendingMode release], _blendingMode=nil;
    [_tweet release], _tweet = nil;
    [_facebook release], _facebook=nil;
    [_emailMessage release], _emailMessage=nil;
    [_emailTo release], _emailTo = nil;
    [_emailSubject release], _emailSubject=nil;
    [_emailCC release], _emailCC=nil;
    [_emailBCC release], _emailBCC=nil;
    [_folderName release], _folderName=nil;
    [_messageLink release], _messageLink=nil;
    [_pinterest release], _pinterest=nil;
    [_layerImagePath release], _layerImagePath=nil;
    [_originalLayerImagePath release], _originalLayerImagePath=nil;
    [_previewImagePath release], _previewImagePath=nil;
    
    [_observeProps release], _observeProps=nil;
    
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if(self)
    {
        mapImageCount = 0;
        lastFinalAdjustCount=0;
        _ignoreUnadjustedAdjustments = YES;
        _hasSavedMaskImage = NO;
        _hasSavedMapImage=NO;
        _shaderIndexPath = (MysticShaderIndex){-1,-1,-1,-1,-1};
        layerEffect = MysticLayerEffectNone;
        __userBlended = NSNotFound;
        _originalBlendingMode = MysticFilterTypeBlendNormal;
        _vignetteBlendingType = MysticFilterTypeBlendNormal;
        _ignoreRender = NO;
        _showBg = YES;
        _mapDarkest=NAN;
        _mapBrightest=NAN;
        _isPreviewOption = YES;
        cachedImages = [[NSMutableArray array] retain];
        _hasChanged = YES;
        _attributes = MysticAttrNone;
        _canFillBackgroundColor = NO;
        _canFillTransformBackgroundColor = NO;
        _hasSetAdjustmentTransformRect = NO;
        _intensity = 1.0f;
        _rotatePosition = MysticPositionUnknown;
        _sensitivity = 0.4f;
        _smoothingSensitivity = 0.1f;
        _smoothing = NO;
        __blendingMode = MysticFilterTypeUnknown;
        _transform = CGAffineTransformIdentity;
        _rotateTransform = CGAffineTransformIdentity;
        _layerImagePath = nil;
        _previewImagePath = nil;
        _originalLayerImagePath = nil;
        _shouldBlendWithPreviousTextureFirst = NO;
        maxLayerEffect = MysticLayerEffectFour;
        cropRect = CGRectZero;
        _layerImageSize = MysticSizeUnknown;
        _originalImageSize = MysticSizeUnknown;
        _thumbImageSize = MysticSizeUnknown;
        _previewImageSize = MysticSizeUnknown;
        _adjustedRect = MysticDefaultTransformRect;
        _transformRect = MysticDefaultTransformRect;
        _originalTransformRect = MysticDefaultTransformRect;
        _hasProcessedThumbnail = NO;
        _transformRectInitial = CGRectUnknown;
        _colorMatrix = (GPUMatrix4x4){{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
        self.rgb = (GPUVector3){1.0f,1.0f,1.0f};
        self.stackPosition = 1;
        self.colorTypes = [NSMutableDictionary dictionary];
        self.flipVertical = NO;
        self.flipHorizontal = NO;
        self.applySunshine = NO;
        self.stretchLayerImage = YES;
        self.brightness = kBrightness;
        self.skinHue = kMysticSkinHue;
        self.skinToneAdjust = kMysticSkin;
        self.skinHueMaxShift = kMysticSkinMaxHueShift;
        self.skinHueThreshold = kMysticSkinHueThreshold;
        self.skinMaxSaturation = kMysticSkinMaxSaturationShift;
        self.skinUpperTone = kMysticSkinUpperSkinToneColor;
        self.vibrance = 1.2;
        self.temperature = kTemperature;
        self.tint = kTint;
        self.tiltShift = kTiltShift;
        self.gamma = kGamma;
        self.exposure = kExposure;
        self.shadows = kShadows;
        self.highlights = kHighlights;
        self.sharpness = kSharpness;
        self.contrast = kContrast;
        self.unsharpMask = kUnsharpMask;
        self.saturation = kSaturation;
        self.vignetteStart = kVignetteStart;
        self.vignetteEnd = self.vignetteStart;
        _vignetteCenter = CGPointUnknown;
        self.blackLevels = kLevelsMin;
        self.whiteLevels = kLevelsMax;
        self.midLevels = kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
        self.minBlackLevel = 0.0f;
        self.maxWhiteLevel = 1.0f;
        self.minBlackLevelRed = 0.0f;
        self.maxWhiteLevelRed = 1.0f;
        self.minBlackLevelGreen = 0.0f;
        self.maxWhiteLevelGreen = 1.0f;
        self.minBlackLevelBlue = 0.0f;
        self.maxWhiteLevelBlue = 1.0f;
        
        self.blendingMode = nil;
        self.hsb = MysticHSBDefault;
        
        [self setDefaultSettings];
        
        
        self.observeProps = [NSMutableArray arrayWithArray:@[
                                                             @"level",
                                                             @"autoEnhance",
                                                             @"layerEffect",
                                                             @"fillMode",
                                                             @"ignoreRender",
                                                             @"stretchMode",
                                                             @"blendingType",
                                                             @"flipVertical",
                                                             @"flipHorizontal",
                                                             @"desaturate",
                                                             @"inverted",
                                                             @"blended",
                                                             @"smoothing",
                                                             @"applySunshine",
                                                             @"transformRect",
                                                             @"cropRect",
                                                             @"brightness",
                                                             @"vibrance",
                                                             @"contrast",
                                                             @"exposure",
                                                             @"gamma",
                                                             @"shadowIntensity",
                                                             @"highlightIntensity",
                                                             @"whiteLevels",
                                                             @"blackLevels",
                                                             @"midLevels",
                                                             @"saturation",
                                                             @"highlights",
                                                             @"shadows",
                                                             @"haze",
                                                             @"vignetteEnd",
                                                             @"vignetteStart",
                                                             @"tiltShift",
                                                             @"sharpness",
                                                             @"rotation",
                                                             @"unsharpMask",
                                                             @"tint",
                                                             @"temperature",
                                                             @"intensity",
                                                             @"showBg",
                                                             ]];
        sizeProps = [@[] retain];
        intProps = [@[@"level", @"stackPosition", @"type", @"blendingType", @"layerEffect", @"fillMode", @"stretchMode", @"skinUpperTone"] retain];
        boolProps = [@[@"flipVertical", @"flipHorizontal",@"flipTextureVertical", @"flipTextureHorizontal", @"desaturate", @"userProvidedImage", @"inverted", @"blended", @"smoothing", @"applySunshine", @"ignoreRender", @"autoEnhance"] retain];
        rectProps = [@[@"transformRect", @"cropRect"] retain];
        otherProps = [@[@"colorTypes", @"tag", @"name", @"sourceImageURL", @"thumbURLString", @"imageURLString", @"previewURLString"] retain];
        floatProps = [@[@"brightness",@"vibrance", @"contrast", @"exposure", @"gamma", @"whiteLevels", @"blackLevels", @"midLevels", @"saturation", @"highlights", @"shadows", @"haze", @"vignetteEnd", @"vignetteState", @"vignetteValue", @"tiltShift", @"sharpness", @"rotation", @"unsharpMask", @"tint", @"temperature", @"intensity", @"skinToneAdjust", @"skinHue", @"skinHueMaxShift", @"skinMaxSaturation", @"skinHueThreshold", @"highlightIntensity", @"shadowIntensity"] retain];
        insetsProps = [@[@"stretchingInsets"] retain];
        ignoreProps = [@[@"colorTypes", @"userProvidedImage", @"tag", @"name", @"sourceImageURL", @"thumbURLString", @"imageURLString", @"previewURLString"] retain];
    }
    return self;
}

- (void) commonInit;
{
    [super commonInit];
    if(isM(self.info[@"image_url"])) self.attributes |= MysticAttrUsesTexture;
    if(isM(self.info[@"shader"])) self.attributes |= MysticAttrShader;
    if(isM(self.info[@"vertex"])) self.attributes |= MysticAttrVertex;
}

- (void) setShouldBlendWithPreviousTextureFirst:(BOOL)shouldBlendWithPreviousTextureFirst;
{
    _shouldBlendWithPreviousTextureFirst=shouldBlendWithPreviousTextureFirst;
    __shouldBlendWithPreviousTextureFirst = YES;
}
- (BOOL) shouldBlendWithPreviousTextureFirst;
{
    if(__shouldBlendWithPreviousTextureFirst) return _shouldBlendWithPreviousTextureFirst;
    switch (self.blendingType) {
        case MysticFilterTypeBlendMaskScreen:
        case MysticFilterTypeBlendMaskMultiply:
        case MysticFilterTypeBlendMaskShowBlack:
        case MysticFilterTypeBlendMaskMultiplyNoFill:
        case MysticFilterTypeBlendMaskScreenNoFill:
        case MysticFilterTypeBlendAlphaMask:
        case MysticFilterTypeBlendAlphaMaskFillBg:
            return NO;
            
        default:
            break;
    }
    return _shouldBlendWithPreviousTextureFirst;
}
- (void) setColorOption:(PackPotionOptionColor *)colorOption;
{
    [super setColorOption:colorOption];
    
    [self setColorType:colorOption.optionType color:@(colorOption.colorType)];
    
}

- (void) setVibrance:(float)vibrance;
{
    _vibrance = (vibrance-1.2);
}

- (void) setBlackLevels:(float)value;
{
    _blackLevels = value;
    self.blackLevelsBlue = value;
    self.blackLevelsGreen = value;
    self.blackLevelsRed = value;
}

- (void) setWhiteLevels:(float)value;
{
    _whiteLevels = value;
    self.whiteLevelsBlue = value;
    self.whiteLevelsGreen = value;
    self.whiteLevelsRed = value;
}

- (void) setMidLevels:(float)value;
{
    _midLevels = value;
    self.midLevelsBlue = value;
    self.midLevelsGreen = value;
    self.midLevelsRed = value;
}

- (void) setMinBlackLevel:(float)value;
{
    _minBlackLevel = value;
    self.minBlackLevelBlue = value;
    self.minBlackLevelGreen = value;
    self.minBlackLevelRed = value;
}

- (void) setMaxWhiteLevel:(float)value;
{
    _maxWhiteLevel = value;
    self.maxWhiteLevelBlue  = value;
    self.maxWhiteLevelGreen = value;
    self.maxWhiteLevelRed = value;
}

- (BOOL) showInLayers; { return YES; }


- (NSInteger) count;
{
    return 1;
}
- (BOOL) userProvidedImage; { return NO; }
- (BOOL) shouldRegisterForChanges; { return YES; }
- (void) registerForChangeNotification;
{
    if(!self.shouldRegisterForChanges || self.registeredForChanges) return;
    NSMutableArray *theProps = [NSMutableArray arrayWithArray:self.observeProps];
    for (NSString *key in theProps) {
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
    self.registeredForChanges = YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    PackPotionOption *opt = (PackPotionOption *)object;
    opt.hasChanged = YES;
    [self updateTag];
}
- (void)unregisterForChangeNotification;
{
    if(!self.shouldRegisterForChanges || !self.registeredForChanges) return;
    NSMutableArray *theProps = [NSMutableArray arrayWithArray:self.observeProps];
    for (NSString *key in theProps) [self removeObserver:self forKeyPath:key];
    self.registeredForChanges = NO;
}

- (void) updateTag;
{
    self.uniqueTag = nil;
//    [_uniqueTag release], _uniqueTag=nil;
}

- (void) setHasChanged:(BOOL)value;
{
    [self updateTag];
    if(value) self.shouldRender = YES;
    if(_hasChanged != value) _hasChanged = value;
}

- (void) setIsConfirmed:(BOOL)isConfirmed;
{
    [super setIsConfirmed:isConfirmed];
    if(isConfirmed) self.isPreviewOption = NO;
}
- (BOOL) inState:(MysticOptionState)state;
{
    BOOL inState = YES;
    if(self.state == state || self.state & state)
    {
        return YES;
    }
    if(state & MysticOptionStateAny)
    {
        return YES;
    }
    if(state & MysticOptionStateConfirmed) inState = self.isConfirmed;
    if(inState && state & MysticOptionStatePreviewing) inState = !self.isConfirmed;
    return inState;
}
- (BOOL) canBeConfirmed; { return YES; }

- (BOOL) isSame:(PackPotionOption *)option2;
{
    if(!option2) return NO;
    PackPotionOption *option1 = self;
    if((option1 == nil && option2.cancelsEffect) || (option2 == nil && option1.cancelsEffect)) return YES;
    
    if(option1 && option2 && option1.groupType==option2.groupType)
    {
        if([option1.tag isEqualToString:option2.tag]) return YES;
    }
    return NO;
}

- (BOOL) allowsMultipleSelections; { return NO; }
- (BOOL) hasInput; { return YES; }
- (BOOL) hasImage;
{
    return self.attributes & MysticAttrUsesTexture ? YES : NO;
}
- (BOOL) hasShader; { return YES; }
- (BOOL) isActive;
{
    if(self.isActiveAction) return self.isActiveAction(self);
    return [[MysticOptions current] contains:self];
}

- (void) setLayerEffect:(MysticLayerEffect)value;
{

    if(value != layerEffect) self.hasChanged = YES;
    layerEffect = value;
    
    if(self.hasCustomLayerEffects) return;
    
    switch (layerEffect)
    {
        case MysticLayerEffectInverted: self.inverted = YES; break;
        default: self.inverted = NO; break;
    }
    
    if(layerEffect == MysticLayerEffectRandom)
    {
        
        
        float maxx = 10000.f;
        int max = 10000;
        int min = 50;
        
        int min2 = 700;
        
        int randAlpha = rand() % (max - min2) + min2;
        self.colorMatrixIntensity = (float)randAlpha/maxx;
        
        int randNum1 = rand() % (max - min) + min;
        int randNum2 = rand() % (max - min) + min;
        int randNum3 = rand() % (max - min) + min;
        int randNum4 = rand() % (max - min) + min;
        int randNum5 = rand() % (max - min) + min;
        int randNum6 = rand() % (max - min) + min;
        int randNum7 = rand() % (max - min) + min;
        int randNum8 = rand() % (max - min) + min;
        int randNum9 = rand() % (max - min) + min;
        
        float r1 = (float)randNum1/maxx;
        float r2 = (float)randNum2/maxx;
        float r3 = (float)randNum3/maxx;
        float r4 = (float)randNum4/maxx;
        float r5 = (float)randNum5/maxx;
        float r6 = (float)randNum6/maxx;
        float r7 = (float)randNum7/maxx;
        float r8 = (float)randNum8/maxx;
        float r9 = (float)randNum9/maxx;
        self.colorMatrix = (GPUMatrix4x4){
            {r1, r2, r3, 0.0},
            {r4, r5, r6 ,0.0},
            {r7, r8, r9, 0.0},
            {0,0,0,1.0},
        };;
    }
    
}
- (NSDictionary *) textures;
{
    NSMutableDictionary *textures = [NSMutableDictionary dictionary];
    if(self.hasMaskImage) [textures setObject:@{@"name":@"mask",@"blend":@(MysticFilterTypeBlendMaskShowBlack)} forKey:@(MysticFilterTypeBlendMaskShowBlack)];
    if(self.adjustColorsFinal.count > 0 && self.hasMapImage) [textures setObject:@{@"name":@"adjustColors",@"blend":@(MysticFilterTypeAdjustColor)} forKey:@(MysticFilterTypeAdjustColor)];

    return textures;
}
- (NSInteger) numberOfInputTextures;
{
    NSInteger i = 0;
    if(self.hasInput) i++;
    if(self.hasMaskImage) i++;
    if(self.adjustColorsFinal.count > 0 && self.hasMapImage) i=i<1?2:i+1;
    return i;
}
- (void) setUserInfo:(NSDictionary *)values;
{
    BOOL downloadSourceImage = NO;
    NSDictionary *project = values;
    void (*objc_msgSendFloat)(id self, SEL _cmd, float value) = (void*)objc_msgSend;
    float floatval;
    SEL sel;
    NSString *selStr;
    for (NSString *floatStr in floatProps) {
        if([project objectForKey:floatStr]){
            floatval = [[project objectForKey:floatStr] floatValue];
            NSString *floatStrC = [NSString stringWithFormat:@"%@%@",[[floatStr substringToIndex:1] uppercaseString],[floatStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", floatStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendFloat(self, sel, floatval);
        }
    }
    
    
    void (*objc_msgSendInt)(id self, SEL _cmd, int value) = (void*)objc_msgSend;
    
    
    int intval;
    
    for (NSString *keyStr in intProps) {
        if([project objectForKey:keyStr]){
            intval = [[project objectForKey:keyStr] intValue];
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendInt(self, sel, intval);
        }
    }
    
    
    void (*objc_msgSendBOOL)(id self, SEL _cmd, BOOL value) = (void*)objc_msgSend;
    BOOL boolval;
    for (NSString *keyStr in boolProps) {
        if([project objectForKey:keyStr]){
            boolval = [[project objectForKey:keyStr] boolValue];
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendBOOL(self, sel, boolval);
        }
    }
    
    void (*objc_msgSendRect)(id self, SEL _cmd, CGRect value) = (void*)objc_msgSend;
    
    CGRect rectVal;
    
    for (NSString *keyStr in rectProps) {
        if([project objectForKey:keyStr]){
            rectVal = CGRectFromString([project objectForKey:keyStr]);
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendRect(self, sel, rectVal);
        }
    }
    
    void (*objc_msgSendSize)(id self, SEL _cmd, CGSize value) = (void*)objc_msgSend;
    
    CGSize sizeVal;
    
    for (NSString *keyStr in sizeProps) {
        if([project objectForKey:keyStr]){
            sizeVal = CGSizeFromString([project objectForKey:keyStr]);
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSendSize(self, sel, sizeVal);
        }
    }
    
    id val;
    for (NSString *keyStr in otherProps) {
        if([project objectForKey:keyStr]){
            val = [project objectForKey:keyStr];
            NSString *keyStrC = [NSString stringWithFormat:@"%@%@",[[keyStr substringToIndex:1] uppercaseString],[keyStr substringFromIndex:1] ];
            selStr = [NSString stringWithFormat:@"set%@:", keyStrC];
            sel = NSSelectorFromString(selStr);
            if([self respondsToSelector:sel]) objc_msgSend(self, sel, val);
        }
    }
    
    id blnd = [project objectForKey:@"blending"];
    if(blnd != nil){
        if([blnd isKindOfClass:[NSNumber class]]) [self setBlendingType:[[project objectForKey:@"blending"] integerValue]];
        else [self setBlending:blnd];
    }
    
    
    if(self.userProvidedImage)
    {
        DLog(@"need to download user provided image: %@ (%@)", self.sourceImageURL, [self class]);
    }
    
    if(values[@"maskImagePath"]) self.maskImagePath = values[@"maskImagePath"];
    
}
- (NSDictionary *)userInfo;
{
    NSMutableDictionary *_userInfo = [NSMutableDictionary dictionary];
    [_userInfo setObject:self.tag forKey:@"tag"];
    [_userInfo setObject:self.name forKey:@"name"];
    if(self.blending) [_userInfo setObject:self.blending forKey:@"blending"];
    [_userInfo setObject:[NSNumber numberWithInteger:self.level] forKey:@"level"];
    [_userInfo setObject:[NSNumber numberWithInteger:self.stackPosition] forKey:@"stackPosition"];
    [_userInfo setObject:[NSNumber numberWithInteger:self.blendingType] forKey:@"blendingType"];
    [_userInfo setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    [_userInfo setObject:[NSNumber numberWithInteger:self.layerEffect] forKey:@"layerEffect"];
    [_userInfo setObject:[MysticUI stringFromRect:self.transformRect] forKey:@"transformRect"];
    [_userInfo setObject:[MysticUI stringFromRect:self.cropRect] forKey:@"cropRect"];
    [_userInfo setObject:[NSDictionary dictionaryWithDictionary:self.colorTypes] forKey:@"colorTypes"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vibrance] forKey:@"vibrance"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.brightness] forKey:@"brightness"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.skinToneAdjust] forKey:@"skinToneAdjust"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.skinHue] forKey:@"skinHue"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.skinHueMaxShift] forKey:@"skinHueMaxShift"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.skinHueThreshold] forKey:@"skinHueThreshold"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.skinMaxSaturation] forKey:@"skinMaxSaturation"];
    [_userInfo setObject:[NSNumber numberWithInt:self.skinUpperTone] forKey:@"skinUpperTone"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.contrast] forKey:@"contrast"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.exposure] forKey:@"exposure"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.gamma] forKey:@"gamma"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.whiteLevels] forKey:@"whiteLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.midLevels] forKey:@"midLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.blackLevels] forKey:@"blackLevels"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.saturation] forKey:@"saturation"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.highlights] forKey:@"highlights"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.shadows] forKey:@"shadows"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.haze] forKey:@"haze"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vignetteEnd] forKey:@"vignetteEnd"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.vignetteStart] forKey:@"vignetteStart"];
    if(self.vignetteColor) [_userInfo setObject:self.vignetteColor.hexString forKey:@"vignetteColor"];
    if(!CGPointIsUnknown(self.vignetteCenter)) [_userInfo setObject:[NSValue valueWithCGPoint:self.vignetteCenter] forKey:@"vignetteCenter"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.tiltShift] forKey:@"tiltShift"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.sharpness] forKey:@"sharpness"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.rotation] forKey:@"rotation"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.alpha] forKey:@"alpha"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.unsharpMask] forKey:@"unsharpMask"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.intensity] forKey:@"intensity"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.smoothingSensitivity] forKey:@"smoothingSensitivity"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.sensitivity] forKey:@"sensitivity"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.tint] forKey:@"tint"];
    [_userInfo setObject:[NSNumber numberWithFloat:self.temperature] forKey:@"temperature"];
    [_userInfo setObject:[NSNumber numberWithBool:self.userProvidedImage] forKey:@"userProvidedImage"];
    [_userInfo setObject:[NSNumber numberWithBool:self.applySunshine] forKey:@"applySunshine"];
    [_userInfo setObject:[NSNumber numberWithBool:self.inverted] forKey:@"inverted"];
    [_userInfo setObject:[NSNumber numberWithBool:self.flipVertical] forKey:@"flipVertical"];
    [_userInfo setObject:[NSNumber numberWithBool:self.flipHorizontal] forKey:@"flipHorizontal"];
    [_userInfo setObject:[NSNumber numberWithBool:self.desaturate] forKey:@"desaturate"];
    [_userInfo setObject:[NSNumber numberWithBool:self.blended] forKey:@"blended"];
    [_userInfo setObject:[NSNumber numberWithBool:self.smoothing] forKey:@"smoothing"];
    [_userInfo setObject:[NSNumber numberWithBool:self.autoEnhance] forKey:@"autoEnhance"];
    
    if(self.sourceImageURL) [_userInfo setObject:self.sourceImageURL forKey:@"sourceImageURL"];
    if(self.thumbURLString) [_userInfo setObject:self.thumbURLString forKey:@"thumbURLString"];
    if(self.imageURLString) [_userInfo setObject:self.imageURLString forKey:@"imageURLString"];
    if(self.previewURLString) [_userInfo setObject:self.previewURLString forKey:@"previewURLString"];
    if(self.hasMaskImage) [_userInfo setObject:self.maskImagePath forKey:@"maskImagePath"];
    if(_layerImagePath) [_userInfo setObject:_layerImagePath forKey:@"layerImagePath"];
    if(_previewImagePath) [_userInfo setObject:_previewImagePath forKey:@"previewImagePath"];
    if(_originalLayerImagePath) [_userInfo setObject:_originalLayerImagePath forKey:@"originalLayerImagePath"];
    
    return [NSDictionary dictionaryWithDictionary:_userInfo];
}
- (NSString *) originalLayerImagePath;
{
    if(_originalLayerImagePath) return _originalLayerImagePath;
    if(self.info[@"original_path"]) self.info[@"original_path"];

    return self.layerImagePath;
}

- (NSString *) previewImagePath;
{
    if(_previewImagePath) return _previewImagePath;
    if(self.info[@"preview_path"]) self.info[@"preview_path"];
    
    return self.layerImagePath;
}



- (NSString *) stackPositionKey;
{
    return [NSString stringWithFormat:@"%@%@-%lu", MysticObjectTypeToString(self.type), self.tag, (unsigned long)self.stackPosition];
}
- (NSString *) uniqueTag:(NSArray *)onlyKeys ignoreKeys:(NSArray *)ignoreKeys;
{
    if(!onlyKeys && self.uniqueTagValue) return self.uniqueTagValue;
    NSMutableArray *_ignoreKeys = [NSMutableArray arrayWithArray:ignoreProps];
    if(ignoreKeys && ignoreKeys.count) [_ignoreKeys addObjectsFromArray:ignoreKeys];
    
    onlyKeys = onlyKeys && onlyKeys.count ? onlyKeys : nil;
    
    
    NSMutableString *__tag = [NSMutableString stringWithFormat:@"%@", (onlyKeys && [onlyKeys containsObject:@"tag"]) || !onlyKeys ? self.tag : @""];
    NSString *selStr;
    SEL sel;
    
    NSArray *ignoreInt = @[@"level", @"stackPosition"];
    NSMutableArray *_intProps = [NSMutableArray array];
    [_intProps addObjectsFromArray:@[@"foregroundColorType", @"backgroundColorType"]];
    for (NSString *key in intProps) {
        if((onlyKeys && ![onlyKeys containsObject:key]) || [ignoreProps containsObject:key] || [ignoreInt containsObject:key]) continue;
        [_intProps addObject:key];
    }
    
    
    for (NSString *keyStr in _intProps) {
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            int *intvalp = [self performValueSelector:sel];
            [__tag appendFormat:@"-%@:%d", keyStr, *intvalp];
            free(intvalp);
        }
    }
    
    for (NSString *keyStr in floatProps) {
        if((onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            float *floatvalp = [self performValueSelector:sel];
            float floatval = *floatvalp;
            [__tag appendFormat:@"-%@:%2.3f", keyStr, floatval];
            free(floatvalp);
        }
    }
    
    
    
    for (NSString *keyStr in boolProps) {
        if((onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            BOOL *boolvalp = [self performValueSelector:sel];
            BOOL boolval = *boolvalp;
            [__tag appendFormat:@"%@", boolval ? [[@"-" stringByAppendingString:keyStr] stringByAppendingString:@":ON"] : [[@"-" stringByAppendingString:keyStr] stringByAppendingString:@":OFF"]];
            free(boolvalp);
        }
    }
    
    for (NSString *keyStr in insetsProps) {
        if((onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            UIEdgeInsets *insetsP = [self performValueSelector:sel];
            [__tag appendFormat:@"-%@:%@", keyStr, NSStringFromUIEdgeInsets(*insetsP)];
            free(insetsP);
        }
    }
    
    
    for (NSString *keyStr in rectProps) {
        if((onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            CGRect *rectValP = [self performSelector:sel value:nil];
            CGRect rectVal = *rectValP;
            
            [__tag appendFormat:@"-%@:%2.3fx%2.3fx%2.3fx%2.3f", keyStr, rectVal.origin.x, rectVal.origin.y, rectVal.size.width, rectVal.size.height];
            free(rectValP);
        }
    }
    
    
    CGSize sizeVal;
    
    for (NSString *keyStr in sizeProps) {
        if((onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            CGSize *sizeValp = [self performSelector:sel value:nil];
            sizeVal = *sizeValp;
            
            [__tag appendFormat:@"-%@:%2.3fx%2.3f", keyStr, sizeVal.width, sizeVal.height];
            free(sizeValp);
        }
    }
    
    id val;
    
    
    
    for (NSString *keyStr in otherProps) {
        if([keyStr isEqualToString:@"tag"] || (onlyKeys && ![onlyKeys containsObject:keyStr]) || [_ignoreKeys containsObject:keyStr]) continue;
        selStr = keyStr;
        sel = NSSelectorFromString(selStr);
        if([self respondsToSelector:sel])
        {
            val = [self performSelector:sel withObject:self];
            if(val) [__tag appendFormat:@"-%@:%@", keyStr, val];
            val = nil;
        }
    }
    if(!onlyKeys || (onlyKeys && [onlyKeys containsObject:@"blending"]))
    {
        id blnd = self.blending;
        if(blnd != nil){
            [__tag appendFormat:@"-blending:%@", blnd];
        }
        blnd = nil;
    }
    if(!onlyKeys || (onlyKeys && [onlyKeys containsObject:@"layerEffect"]))
    {
        if(![_ignoreKeys containsObject:@"layerEffect"])
        {
            if(self.layerEffect == MysticLayerEffectRandom)
            {
                MysticMatrix4x4 m2 = MysticMatrix4x4From(self.colorMatrix);
                
                float colorMatrixF = MysticMatrix4x4Sum(m2);
                
                [__tag appendFormat:@"-r%f-%f", colorMatrixF, self.colorMatrixIntensity];
            }
        }
    }
    if(self.adjustColors.count)
    {
        for (NSDictionary *d in self.adjustColors) {
            [__tag appendFormat:@"%@-%@-%2.2f--%@", [d[@"color"] hexString], [d[@"source"] hexString], [d[@"intensity"] floatValue], [(NSArray *)d[@"threshold"] componentsJoinedByString:@","]];
        }
    }
    if(self.hasMaskImage) [__tag appendString:@"masked-"];
    
    NSString *returnTag;
    const char *str = [__tag UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    returnTag = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                 r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    returnTag = [returnTag substringToIndex:6];
    if(!onlyKeys)
    {
        self.uniqueTagValue = returnTag;
//        if(_uniqueTag) [_uniqueTag release], _uniqueTag=nil;
//        _uniqueTag = [[NSString stringWithString:returnTag] retain];
    }
    
    return returnTag;
}
- (NSString *) uniqueTag:(NSArray *)keys;
{
    return [self uniqueTag:keys ignoreKeys:nil];
}
- (NSString *) uniqueTagIgnore:(NSArray *)keys;
{
    return [self uniqueTag:nil ignoreKeys:keys];
}
- (NSString *) uniqueTag;
{
    if(self.uniqueTagValue) return self.uniqueTagValue;
    self.uniqueTagValue = [self uniqueTag:nil ignoreKeys:nil];
    return self.uniqueTagValue;
    
}
- (void) setUniqueTag:(NSString *)uniqueTag;
{
    self.uniqueTagValue = uniqueTag;
}
- (NSString *) uniqueTagForSize:(CGSize)size;
{
    //    return [NSString stringWithFormat:@"layer-%@-%@-%@", self.name,  [self layerImageKeyForSize:size], [self.info objectForKey:@"updated"] ? [self.info objectForKey:@"updated"] : @"na"];
    return [NSString stringWithFormat:@"layer-%@-%@", self.name,  [self layerImageKeyForSize:size]];
    
}
- (NSInteger) integerValue;
{
    return self.level;
}

- (NSString *) hashTags;
{
    NSString *h = [self.info objectForKey:@"hashtags"];
    
    BOOL useFolder = NO;
    
    if(self.folderName && ![self.folderName isEqualToString:@""])
    {
        if(h && ![h isEqualToString:@""])
        {
            if ([h rangeOfString:self.folderName].location == NSNotFound) {
                useFolder = YES;
                h = [h stringByAppendingString:@" "];
            }
        }
        else
        {
            h = @"";
            useFolder = YES;
        }
    }
    h = useFolder ? [h stringByAppendingFormat:@"#%@", self.folderName] : h;
    return h && ![h isEqualToString:@""] ? h : nil;
}
- (NSUInteger) level;
{
    NSInteger l = super.level;
    if(l == NSNotFound)
    {
        l = self.smartLevel;
    }
    return l == NSNotFound ? MysticLayerLevelAuto : l;
    
}

- (NSInteger) smartLevel;
{
    if(self.isTransforming) return MysticLayerLevelTop;
    
    NSInteger l = MysticLayerLevelAuto;
    
    
    
    switch (self.type) {
        case MysticObjectTypeFont:
        case MysticObjectTypeText:
            l = self.blended ? MysticLayerLevelBlendedText : MysticLayerLevelText;
            break;
        case MysticObjectTypeTexture:
            l = self.blended ? MysticLayerLevelBlendedTexture : MysticLayerLevelTexture;
            break;
        case MysticObjectTypeFrame:
            l = self.blended ? MysticLayerLevelBlendedFrame : MysticLayerLevelFrame;
            break;
        case MysticObjectTypeLight:
            l = self.blended ? MysticLayerLevelBlendedLight : MysticLayerLevelLight;
            break;
        case MysticObjectTypeBadge:
            l = self.blended ? MysticLayerLevelBlendedBadge : MysticLayerLevelBadge;
            break;
        case MysticObjectTypeMask:
            l = self.blended ? MysticLayerLevelBlendedMask : MysticLayerLevelMask;
            break;
        case MysticObjectTypeFilter:
            l = MysticLayerLevelFilter;
            //l = self.blended ? MysticLayerLevelBlended : MysticLayerLevel;
            break;
        case MysticObjectTypeCamLayer:
            l = self.blended ? MysticLayerLevelBlendedCam : MysticLayerLevelCam;
            break;
        case MysticObjectTypeSetting:
            l = self.blended ? MysticLayerLevelBlendedSettings : MysticLayerLevelSettings;
            break;
        default: break;
    }
    
    return l;
}

- (BOOL) anchorTopLeft; { return NO; }
- (BOOL) ignoreAspectRatio; { return YES; }
- (BOOL) canTransform;
{
    switch (self.type) {
        case MysticObjectTypeBadge:
        case MysticObjectTypeText:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeFrame:
        case MysticObjectTypeTexture:
        case MysticObjectTypeLight:
        case MysticObjectTypeCustom:
            return YES;
            
        default: break;
    }
    return NO;
}
- (void) setOriginalTransformRect:(CGRect)originalTransformRect;
{
    _originalTransformRect = originalTransformRect;
    self.transformRect = originalTransformRect;
}
//- (CGRect) transformRect;
//{
//    if(CGRectIsUnknown(_transformRectInitial)) _transformRectInitial=_transformRect;
//    return _transformRect;
//}
- (CGRect) transformRectNormal;
{
    if(CGRectEqualToRect(self.adjustedRect, MysticDefaultTransformRect)) return self.transformRect;
    CGRect normalRect = self.transformRect;
    
    normalRect.size.width = (normalRect.size.width * MysticDefaultTransformRect.size.width) / self.adjustedRect.size.width;
    normalRect.size.height = (normalRect.size.height * MysticDefaultTransformRect.size.height) / self.adjustedRect.size.height;
    
    return normalRect;
}
- (void) resetTransform;
{
    self.rotation = kDefaultRotation;
    self.flipHorizontal = NO;
    self.flipVertical = NO;
    
    self.transformRect = self.originalTransformRect;
    _transform = CGAffineTransformIdentity;
    
    self.rotateTransform = CGAffineTransformIdentity;
    if(self.transformFilter) self.transformFilter.affineTransform = self.transform;
    if(self.layer.textures.count)
    {
        for (NSDictionary *texture in self.layer.textures.allValues) {
            GPUImageTransformFilter *transform = texture[@"transform"];
            transform.affineTransform = self.transformTextureOnlyXY;
            //            DLog(@"option texture:  %@", texture);
        }
    }
    
}
- (void) updateTransform:(BOOL)all;
{
    self.transformFilter.affineTransform = self.transform;
    if(self.layer.textures.count)
        for (NSDictionary *t in self.layer.textures.allValues)
            [(GPUImageTransformFilter *)t[@"transform"] setAffineTransform:all?self.transformTextureXY:self.transformTextureOnlyXY];
}

- (BOOL) hasTransform;
{
    return !CGAffineTransformIsIdentity(self.transform);
}
- (CGAffineTransform) transform;
{
    return !CGAffineTransformIsIdentity(_transform) ? _transform:[self transformFromRect:self.transformRect];
}
- (CGAffineTransform) transformXY;
{
    return !CGAffineTransformIsIdentity(_transform) ? _transform :[self transformXYFromRect:self.transformRect];
}
- (CGAffineTransform) transformTextureXY;
{
    CGAffineTransform trans = CGAffineTransformIdentity;
    if(self.flipTextureHorizontal)
    {
        if(!CGAffineTransformIsIdentity(trans)) trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(-1,1));
        else trans = CGAffineTransformMakeScale(-1,1);
    }
    if(self.flipTextureVertical)
    {
        if(!CGAffineTransformIsIdentity(trans)) trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(1,-1));
        else trans = CGAffineTransformMakeScale(1,-1);
    }
    if(self.rotation != kDefaultRotation)
    {
        CGFloat angle = normalizedDegreesToRadians(self.rotation);
        if(!CGAffineTransformIsIdentity(trans)) trans = CGAffineTransformConcat(trans, CGAffineTransformMakeRotation(angle));
        else trans = CGAffineTransformMakeRotation(angle);
    }
    if(!CGRectEqualToRect(self.transformRect, MysticDefaultTransformRect))
    {
        if(self.transformRect.origin.x || self.transformRect.origin.y)
        {
            if(!CGAffineTransformIsIdentity(trans)) trans = CGAffineTransformConcat(trans, CGAffineTransformMakeTranslation(self.transformRect.origin.x, self.transformRect.origin.y));
            else trans = CGAffineTransformMakeTranslation(self.transformRect.origin.x, self.transformRect.origin.y);
        }
    }
    return trans;
}
- (CGAffineTransform) transformOnlyXY;
{
    CGAffineTransform trans = _transform;
    
    if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        return trans;
    
    return [self transformOnlyXYFromRect:self.transformRect];
}
- (CGAffineTransform) transformTextureOnlyXY;
{
    CGAffineTransform trans = CGAffineTransformIdentity;
    if(!CGRectEqualToRect(self.transformRect, MysticDefaultTransformRect))
    {
        if(self.transformRect.origin.x || self.transformRect.origin.y)
        {
            
            
            if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
            {
                trans = CGAffineTransformConcat(trans, CGAffineTransformMakeTranslation(self.transformRect.origin.x, self.transformRect.origin.y));
            }
            else
            {
                trans = CGAffineTransformMakeTranslation(self.transformRect.origin.x, self.transformRect.origin.y);
            }
        }
    }
    
    return trans;
}
- (CGAffineTransform) transformXYFromRect:(CGRect)transRect;
{
    CGAffineTransform trans = _transform;
    
    PackPotionOption *effect = self;
    
    
    if(effect.flipHorizontal)
    {
        
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(-1,1));
        }
        else
        {
            trans = CGAffineTransformMakeScale(-1,1);
        }
        
    }
    
    if(effect.flipVertical)
    {
        
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(1,-1));
        }
        else
        {
            trans = CGAffineTransformMakeScale(1,-1);
        }
        
    }
    
    if(effect.rotation != kDefaultRotation)
    {
        
        CGFloat angle = normalizedDegreesToRadians(effect.rotation);
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeRotation(angle));
        }
        else
        {
            trans = CGAffineTransformMakeRotation(angle);
        }
        
    }
    if(!CGRectEqualToRect(transRect, MysticDefaultTransformRect))
    {
        if(transRect.origin.x || transRect.origin.y)
        {
            
            
            if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
            {
                trans = CGAffineTransformConcat(trans, CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y));
            }
            else
            {
                trans = CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y);
            }
        }
    }
    
    return trans;
    
}
- (CGAffineTransform) transformOnlyXYFromRect:(CGRect)transRect;
{
    CGAffineTransform trans = _transform;
    
    PackPotionOption *effect = self;
    
    if(!CGRectEqualToRect(transRect, MysticDefaultTransformRect))
    {
        if(transRect.origin.x || transRect.origin.y)
        {
            if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
            {
                trans = CGAffineTransformConcat(trans, CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y));
            }
            else
            {
                trans = CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y);
            }
        }
    }
    
    return trans;
    
}
- (CGAffineTransform) transformFromRect:(CGRect)transRect;
{
    CGAffineTransform trans = _transform;
    
    PackPotionOption *effect = self;
    
    
    if(effect.flipHorizontal)
    {
        
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(-1,1));
        }
        else
        {
            trans = CGAffineTransformMakeScale(-1,1);
        }
        
    }
    
    if(effect.flipVertical)
    {
        
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(1,-1));
        }
        else
        {
            trans = CGAffineTransformMakeScale(1,-1);
        }
        
    }
    
    if(effect.rotation != kDefaultRotation)
    {
        
        CGFloat angle = normalizedDegreesToRadians(effect.rotation);
        if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
        {
            trans = CGAffineTransformConcat(trans, CGAffineTransformMakeRotation(angle));
        }
        else
        {
            trans = CGAffineTransformMakeRotation(angle);
        }
        
    }
    if(!CGRectEqualToRect(transRect, MysticDefaultTransformRect))
    {
        if(transRect.origin.x || transRect.origin.y)
        {
            
            
            if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
            {
                trans = CGAffineTransformConcat(trans, CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y));
            }
            else
            {
                trans = CGAffineTransformMakeTranslation(transRect.origin.x, transRect.origin.y);
            }
        }
        if((transRect.size.height && transRect.size.height != MysticDefaultTransformRect.size.height) ||
           (transRect.size.width && transRect.size.width != MysticDefaultTransformRect.size.width))
        {
            if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity))
            {
                trans = CGAffineTransformConcat(trans, CGAffineTransformMakeScale(transRect.size.width, transRect.size.height));
            }
            else
            {
                trans = CGAffineTransformMakeScale(transRect.size.width, transRect.size.height);
            }
            
        }
    }
    
    return trans;
    
}

- (CGAffineTransform) rotateTransform;
{
    CGAffineTransform trans = _rotateTransform;
    if(!CGAffineTransformEqualToTransform(trans, CGAffineTransformIdentity)) return trans;
    if(self.rotation != kDefaultRotation)
    {
        CGFloat angle = normalizedDegreesToRadians(self.rotation);
        if(!CGAffineTransformIsIdentity(trans)) trans = CGAffineTransformConcat(trans, CGAffineTransformMakeRotation(angle));
        else trans = CGAffineTransformMakeRotation(angle);
    }
    return trans;
}



- (float) wearAndTear;
{
    if(self.wearAndTearValue == MYSTIC_WEAR_DEFAULT)
    {
        float contrastRange = kContrastMax - kContrast;
        float contrastDistance = self.contrast - kContrast;
        float cPer = contrastDistance/contrastRange;
        
        if(self.brightness < kBrightness)
        {
            cPer = cPer*-1;
        }
        return cPer;
    }
    
    return self.wearAndTearValue;
    
}

- (void) setWearAndTear:(float)wearAndTear;
{
    self.wearAndTearValue = wearAndTear;
    if(wearAndTear > MYSTIC_WEAR_DEFAULT)
    {
        float contrastRange = kContrastMax - kContrast;
        float brightnessRange = (kBrightness - kBrightnessMin) * .5;
        
        self.contrast = kContrast + (contrastRange * wearAndTear);
        self.brightness = kBrightness - (brightnessRange *wearAndTear);
    }
    else if(wearAndTear < MYSTIC_WEAR_DEFAULT)
    {
        float wearAndTear_per = wearAndTear * -1;
        float brightnessRange = (kBrightness - kBrightnessMin) * .75;
        self.brightness = kBrightness - (brightnessRange * wearAndTear_per);
        
        float contrastRange = kContrastMax - kContrast;
        self.contrast = kContrast + (contrastRange * wearAndTear_per);
        
    }
    else
    {
        self.brightness = kBrightness;
        self.contrast = kContrast;
    }
}

#pragma mark - Adjustments

- (NSDictionary *) allAdjustments;
{
    NSMutableDictionary *ads = [NSMutableDictionary dictionaryWithDictionary:self.renderedAdjustments ? self.renderedAdjustments : @{}];
    NSMutableArray *keys = [NSMutableArray arrayWithArray:ads[@"keys"]];
    
    NSDictionary *_ads = self.adjustments;
    if(_ads && [_ads objectForKey:@"keys"])
    {
        for (NSString *k in (NSArray *)_ads[@"keys"]) {
            if(![(NSArray *)ads[@"keys"] containsString:k])
            {
                [keys addObject:k];
                [ads setObject:[_ads objectForKey:k] forKey:k];
            }
        }
    }
    
    [ads setObject:keys forKey:@"keys"];
    
    return [NSDictionary dictionaryWithObjects:ads.allValues forKeys:ads.allKeys];
    
}
- (NSDictionary *) adjustments;
{
    NSMutableDictionary *ads = [NSMutableDictionary dictionary];
    NSMutableArray *keys = [NSMutableArray array];
    
    if([self hasAdjusted:MysticSettingIntensity])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingIntensity]];
        [ads setObject:@(self.intensity) forKey:[NSString stringWithFormat:@"%d", MysticSettingIntensity]];
        
    }
    NSArray *settings = @[@(MysticSettingToon),@(MysticSettingHalfTone),@(MysticSettingPosterize), @(MysticSettingPixellate), @(MysticSettingBlur), @(MysticSettingBlurZoom), @(MysticSettingBlurCircle),@(MysticSettingBlurMotion),@(MysticSettingBlurGaussian),@(MysticSettingDistortPinch),@(MysticSettingDistortSwirl),@(MysticSettingDistortBuldge),@(MysticSettingDistortStretch),@(MysticSettingDistortGlassSphere),@(MysticSettingSketchFilter), ];
    for (NSNumber *setting in settings) {
        if([self hasAdjusted:setting.integerValue])
        {
            [keys addObject:setting.intString];
            [ads setObject:[self valueForType:setting.integerValue] forKey:setting.intString];
        }
    }
    
    if([self hasAdjusted:MysticSettingGrain])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingGrain]];
        [ads setObject:[self valueForType:MysticSettingGrain] forKey:[NSString stringWithFormat:@"%d", MysticSettingGrain]];
        
    }
    if([self hasAdjusted:MysticSettingInvert])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingInvert]];
        [ads setObject:@(self.inverted) forKey:[NSString stringWithFormat:@"%d", MysticSettingInvert]];
        
    }
    if([self hasAdjusted:MysticSettingAutoEnhance])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingAutoEnhance]];
        [ads setObject:@(self.autoEnhance) forKey:[NSString stringWithFormat:@"%d", MysticSettingAutoEnhance]];
        
    }
    if([self hasAdjusted:MysticSettingBlending])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingBlending]];
        [ads setObject:@(self.adjustedBlendingType) forKey:[NSString stringWithFormat:@"%d", MysticSettingBlending]];
        
    }
    if([self hasAdjusted:MysticSettingLayerEffect])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingLayerEffect]];
        [ads setObject:@(layerEffect) forKey:[NSString stringWithFormat:@"%d", MysticSettingLayerEffect]];
        
    }
    if([self hasAdjusted:MysticSettingBackgroundColor])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingBackgroundColor]];
        if(self.backgroundColor) [ads setObject:self.backgroundColor forKey:[NSString stringWithFormat:@"%d", MysticSettingBackgroundColor]];
        
    }
    if([self hasAdjusted:MysticSettingHighlightIntensity])
    {
        [ads setObject:[NSNumber numberWithFloat:self.highlightIntensity] forKey:[NSString stringWithFormat:@"%d", MysticSettingHighlightIntensity]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHighlightIntensity]];
        if(self.highlightTintColor)
        {
            [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHighlightTintColor]];
            if(self.highlightTintColor) [ads setObject:self.highlightTintColor forKey:[NSString stringWithFormat:@"%d", MysticSettingHighlightTintColor]];
        }
    }
    if([self hasAdjusted:MysticSettingShadowIntensity])
    {
        [ads setObject:[NSNumber numberWithFloat:self.shadowIntensity] forKey:[NSString stringWithFormat:@"%d", MysticSettingShadowIntensity]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingShadowIntensity]];
        if(self.shadowTintColor)
        {
            [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingShadowTintColor]];
            if(self.shadowTintColor) [ads setObject:self.shadowTintColor forKey:[NSString stringWithFormat:@"%d", MysticSettingShadowTintColor]];
        }
    }
    if([self hasAdjusted:MysticSettingForegroundColor] && self.foregroundColor)
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingForegroundColor]];
        if(self.foregroundColor) [ads setObject:self.foregroundColor forKey:[NSString stringWithFormat:@"%d", MysticSettingForegroundColor]];
        
    }
    if([self hasAdjusted:MysticSettingColorBalance])
    {
        NSArray *rgbArray = @[[NSNumber numberWithFloat:self.rgb.one], [NSNumber numberWithFloat:self.rgb.two], [NSNumber numberWithFloat:self.rgb.three]];
        [ads setObject:rgbArray forKey:[NSString stringWithFormat:@"%d", MysticSettingColorBalance]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingColorBalance]];
    }
    
    
    if([self hasAdjusted:MysticSettingHSBHue])
    {
        [ads setObject:[NSNumber numberWithFloat:self.hsb.hue] forKey:[NSString stringWithFormat:@"%d", MysticSettingHSBHue]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHSBHue]];
    }
    
    if([self hasAdjusted:MysticSettingHSBSaturation])
    {
        [ads setObject:[NSNumber numberWithFloat:self.hsb.saturation] forKey:[NSString stringWithFormat:@"%d", MysticSettingHSBSaturation]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHSBSaturation]];
    }
    
    if([self hasAdjusted:MysticSettingHSBBrightness])
    {
        [ads setObject:[NSNumber numberWithFloat:self.hsb.brightness] forKey:[NSString stringWithFormat:@"%d", MysticSettingHSBBrightness]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHSBBrightness]];
    }
    
    if([self hasAdjusted:MysticSettingSkin])
    {
        [ads setObject:[NSNumber numberWithFloat:self.skinToneAdjust] forKey:[NSString stringWithFormat:@"%d", MysticSettingSkin]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingSkin]];
    }
    if([self hasAdjusted:MysticSettingSkinHue])
    {
        MysticObjectType t = MysticSettingSkinHue;
        [ads setObject:[NSNumber numberWithFloat:self.skinHue] forKey:[NSString stringWithFormat:@"%d", t]];
        [keys addObject:[NSString stringWithFormat:@"%d", t]];
    }
    if([self hasAdjusted:MysticSettingSkinHueThreshold])
    {
        MysticObjectType t = MysticSettingSkinHueThreshold;
        [ads setObject:[NSNumber numberWithFloat:self.skinHueThreshold] forKey:[NSString stringWithFormat:@"%d", t]];
        [keys addObject:[NSString stringWithFormat:@"%d", t]];
    }
    if([self hasAdjusted:MysticSettingSkinMaxHueShift])
    {
        MysticObjectType t = MysticSettingSkinMaxHueShift;
        [ads setObject:[NSNumber numberWithFloat:self.skinHueMaxShift] forKey:[NSString stringWithFormat:@"%d", t]];
        [keys addObject:[NSString stringWithFormat:@"%d", t]];
    }
    if([self hasAdjusted:MysticSettingSkinMaxSaturationShift])
    {
        MysticObjectType t = MysticSettingSkinMaxSaturationShift;
        [ads setObject:[NSNumber numberWithFloat:self.skinMaxSaturation] forKey:[NSString stringWithFormat:@"%d", t]];
        [keys addObject:[NSString stringWithFormat:@"%d", t]];
    }
    if([self hasAdjusted:MysticSettingSkinUpperSkinToneColor])
    {
        MysticObjectType t = MysticSettingSkinUpperSkinToneColor;
        [ads setObject:[NSNumber numberWithInt:self.skinUpperTone] forKey:[NSString stringWithFormat:@"%d", t]];
        [keys addObject:[NSString stringWithFormat:@"%d", t]];
    }
    
    if([self hasAdjusted:MysticSettingSaturation])
    {
        [ads setObject:[NSNumber numberWithFloat:self.saturation] forKey:[NSString stringWithFormat:@"%d", MysticSettingSaturation]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingSaturation]];
        
    }
    if([self hasAdjusted:MysticSettingVibrance])
    {
        [ads setObject:[NSNumber numberWithFloat:self.vibrance] forKey:[NSString stringWithFormat:@"%d", MysticSettingVibrance]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingVibrance]];
    }
    
    if([self hasAdjusted:MysticSettingBrightness])
    {
        [ads setObject:[NSNumber numberWithFloat:self.brightness] forKey:[NSString stringWithFormat:@"%d", MysticSettingBrightness]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingBrightness]];
    }
    if([self hasAdjusted:MysticSettingGamma])
    {
        [ads setObject:[NSNumber numberWithFloat:self.gamma] forKey:[NSString stringWithFormat:@"%d", MysticSettingGamma]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingGamma]];
    }
    
    if([self hasAdjusted:MysticSettingExposure])
    {
        [ads setObject:[NSNumber numberWithFloat:self.exposure] forKey:[NSString stringWithFormat:@"%d", MysticSettingExposure]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingExposure]];
    }
    if([self hasAdjusted:MysticSettingVignette])
    {
        NSDictionary *vignette = @{@"start":@(self.vignetteStart),@"end":@(self.vignetteEnd),@"center":[NSValue valueWithCGPoint:self.vignetteCenter],@"color":self.vignetteColor ? self.vignetteColor : [NSNull null]};
        [ads setObject:vignette forKey:[NSString stringWithFormat:@"%d", MysticSettingVignette]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingVignette]];
    }
    if([self hasAdjusted:MysticSettingUnsharpMask])
    {
        [ads setObject:[NSNumber numberWithFloat:self.unsharpMask] forKey:[NSString stringWithFormat:@"%d", MysticSettingUnsharpMask]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingUnsharpMask]];
    }
    if([self hasAdjusted:MysticSettingTemperature])
    {
        [ads setObject:[NSNumber numberWithFloat:self.temperature] forKey:[NSString stringWithFormat:@"%d", MysticSettingTemperature]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingTemperature]];
    }
    
    if([self hasAdjusted:MysticSettingTiltShift])
    {
        [ads setObject:[NSNumber numberWithFloat:self.tiltShift] forKey:[NSString stringWithFormat:@"%d", MysticSettingTiltShift]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingTiltShift]];
    }
    if([self hasAdjusted:MysticSettingHaze])
    {
        [ads setObject:[NSNumber numberWithFloat:self.haze] forKey:[NSString stringWithFormat:@"%d", MysticSettingHaze]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHaze]];
    }
    if([self hasAdjusted:MysticSettingHazeSlope])
    {
        [ads setObject:[NSNumber numberWithFloat:self.hazeSlope] forKey:[NSString stringWithFormat:@"%d", MysticSettingHazeSlope]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingHazeSlope]];
    }
    if([self hasAdjusted:MysticSettingContrast])
    {
        [ads setObject:[NSNumber numberWithFloat:self.contrast] forKey:[NSString stringWithFormat:@"%d", MysticSettingContrast]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingContrast]];
    }
    if([self hasAdjusted:MysticSettingSharpness])
    {
        [ads setObject:[NSNumber numberWithFloat:self.sharpness] forKey:[NSString stringWithFormat:@"%d", MysticSettingSharpness]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingSharpness]];
    }
    if([self hasAdjusted:MysticSettingShadows] || [self hasAdjusted:MysticSettingHighlights])
    {
        [ads setObject:[NSNumber numberWithFloat:self.shadows] forKey:[NSString stringWithFormat:@"%d", MysticSettingShadows]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingShadows]];
    }
    if([self hasAdjusted:MysticSettingAdjustColor])
    {
        [ads setObject:self.adjustColorsFinal forKey:[NSString stringWithFormat:@"%d", MysticSettingAdjustColor]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingAdjustColor]];
    }
    if([self hasAdjusted:MysticSettingTransform])
    {
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingTransform]];
        
        
        [ads setObject:[NSValue valueWithCGRect:self.transformRect] forKey:[NSString stringWithFormat:@"%d", MysticSettingTransform]];
        
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingAdjustTransformRect]];
        [ads setObject:[NSValue valueWithCGRect:self.adjustedRect] forKey:[NSString stringWithFormat:@"%d", MysticSettingAdjustTransformRect]];
        
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingTransformAdjusted]];
        [ads setObject:[NSValue valueWithCGRect:self.transformRectNormal] forKey:[NSString stringWithFormat:@"%d", MysticSettingTransformAdjusted]];
        
    }
    
    
    
    if([self hasAdjusted:MysticSettingLevels])
    {
        NSDictionary *value = [self valueForType:MysticSettingLevels];
        
        [ads setObject:value forKey:[NSString stringWithFormat:@"%d", MysticSettingLevels]];
        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingLevels]];
    }
    //    if([self hasAdjusted:MysticSettingAlpha])
    //    {
    //        [ads setObject:[NSNumber numberWithFloat:self.alpha] forKey:[NSString stringWithFormat:@"%d", MysticSettingAlpha]];
    //        [keys addObject:[NSString stringWithFormat:@"%d", MysticSettingAlpha]];
    //    }
    [ads setObject:[NSArray arrayWithArray:keys] forKey:@"keys"];
    return [NSDictionary dictionaryWithObjects:ads.allValues forKeys:ads.allKeys];
}

- (NSDictionary *) adjustmentsAndRefreshingAdjustments;
{
    NSMutableDictionary *__adjustments = [NSMutableDictionary dictionaryWithDictionary:self.adjustments];
    switch (self.refreshState) {
        case MysticSettingNone:
        case MysticObjectTypeUnknown: break;
        default:
        {
            if(![self hasAdjusted:self.refreshState])
            {
                NSMutableArray *keys = [NSMutableArray arrayWithArray:[__adjustments objectForKey:@"keys"]];
                NSMutableDictionary *ads = [NSMutableDictionary dictionaryWithDictionary:__adjustments];
                id value = [self valueForType:self.refreshState];
                if(value) [ads setObject:value forKey:[NSString stringWithFormat:@"%d", self.refreshState]];
                [keys addObject:[NSString stringWithFormat:@"%d", self.refreshState]];
                if(keys) [ads setObject:keys forKey:@"keys"];
                __adjustments = ads;
//                DLogRender(@"adding refresh state to adjustments: %@", __adjustments);
                
            }
            break;
        }
    }
    return __adjustments;
}

- (BOOL) hasRenderedAdjustment:(MysticObjectType)setting;
{
    NSDictionary *unrendered = self.unRenderedAdjustments;
    if(unrendered.count)
    {
        for (NSNumber *k in unrendered[@"keys"]) {
            if([k intValue] == setting) return NO;
        }
    }
    return YES;
}
- (BOOL) hasAdjusted:(MysticObjectType)type;
{
    BOOL hasAdjusted = [self hasAdjustedSetting:type];
 
    return hasAdjusted;
}
- (BOOL) hasAdjustedSetting:(MysticObjectType)type;
{
    
    switch (type) {
        case MysticSettingInvert: return self.inverted;
        case MysticSettingGrain: return self.grainAlpha != 0;
        case MysticSettingAdjustColor: return self.adjustColors > 0 && self.adjustColors.count > 0;
        case MysticSettingShadowTint: return self.shadowTintColor != nil && self.shadowIntensity != 0;
        case MysticSettingHighlightTint: return self.highlightTintColor != nil && self.highlightIntensity != 0;
        case MysticSettingHighlightIntensity: return self.highlightIntensity != 0;
        case MysticSettingShadowIntensity: return self.shadowIntensity != 0;
        case MysticSettingShadowTintColor: return self.shadowTintColor != nil;
        

        case MysticSettingHighlightTintColor: return self.highlightTintColor != nil;
        case MysticSettingAutoEnhance: return self.autoEnhance != NO;
        case MysticSettingLayerEffect: return self.layerEffect != MysticLayerEffectNone;
        case MysticSettingBackgroundColor:
            return self.backgroundColor && ![self.backgroundColor isEqualToColor:[[UIColor blackColor] colorWithAlphaComponent:1]] && ![self.backgroundColor isEqualToColor:UIColor.clearColor];
        case MysticSettingForegroundColor: {
            UIColor *foredefault = [[UIColor whiteColor] colorWithAlphaComponent:1];
            if(self.layerEffect != MysticLayerEffectNone)
            {
                switch (self.layerEffect) {
                    case MysticLayerEffectInverted:
                    {
                        switch (self.normalBlendingType) {
                            case MysticFilterTypeBlendMaskMultiply:
                            case MysticFilterTypeBlendMaskMultiplyNoFill:
                            case MysticFilterTypeBlendMultiply:
                            {
                                foredefault = [[UIColor blackColor] colorWithAlphaComponent:1];
                                break;
                            }
                            case MysticFilterTypeBlendMaskScreen:
                            case MysticFilterTypeBlendMaskScreenNoFill:
                            case MysticFilterTypeBlendScreen:
                            {
                                foredefault = [[UIColor whiteColor] colorWithAlphaComponent:1];
                                break;
                            }
                            default:
                            {
                                break;
                            }
                        }
                        
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            return ![self.foregroundColor isEqualToColor:foredefault];
        }
        case MysticSettingBrightness: return self.brightness != kBrightness;
        case MysticSettingSkin: return self.skinToneAdjust != kMysticSkin;
        case MysticSettingSkinHue: return self.skinHue != kMysticSkinHue;
        case MysticSettingSkinHueThreshold: return self.skinHueThreshold != kMysticSkinHueThreshold;
        case MysticSettingSkinMaxHueShift: return self.skinHueMaxShift != kMysticSkinMaxHueShift;
        case MysticSettingSkinMaxSaturationShift: return self.skinMaxSaturation != kMysticSkinMaxSaturationShift;
        case MysticSettingSkinUpperSkinToneColor: return self.skinUpperTone != kMysticSkinUpperSkinToneColor;
        case MysticSettingVibrance: return self.vibrance != 0;
        case MysticSettingGamma: return self.gamma != kGamma;
        case MysticSettingExposure: return self.exposure != kExposure;
        case MysticSettingColorBalance: return (self.rgb.one != 1.0f || self.rgb.two != 1.0f || self.rgb.three != 1.0f);
        case MysticSettingColorBalanceRed: return (self.rgb.one != 1.0f);
        case MysticSettingColorBalanceGreen: return (self.rgb.two != 1.0f);
        case MysticSettingColorBalanceBlue: return (self.rgb.three != 1.0f);
            
        case MysticSettingVignette: return self.vignetteColor.alpha > 0 && ( self.vignetteEnd != self.vignetteStart || !CGPointIsUnknown(self.vignetteCenter));
        case MysticSettingVignetteBlending: return self.vignetteBlendingType != MysticFilterTypeBlendNormal;
        case MysticSettingVignetteColorAlpha: return self.vignetteColor && self.vignetteColor.alpha > 0;
        case MysticSettingUnsharpMask: return self.unsharpMask != kUnsharpMask;
        case MysticSettingTemperature: return self.temperature != kTemperature || self.tint != kTint;
        case MysticSettingLevels:
        {
            return (self.blackLevels != kLevelsMin || self.whiteLevels != kLevelsMax || self.midLevels != kLevelsMin + ((kLevelsMax - kLevelsMin)/2))
            || (self.blackLevelsRed != kLevelsMin || self.whiteLevelsRed != kLevelsMax || self.midLevelsRed != kLevelsMin + ((kLevelsMax - kLevelsMin)/2))
            || (self.blackLevelsGreen != kLevelsMin || self.whiteLevelsGreen != kLevelsMax || self.midLevelsGreen != kLevelsMin + ((kLevelsMax - kLevelsMin)/2))
            || (self.blackLevelsBlue != kLevelsMin || self.whiteLevelsBlue != kLevelsMax || self.midLevelsBlue != kLevelsMin + ((kLevelsMax - kLevelsMin)/2))
            || (self.minBlackLevel != 0.f || self.maxWhiteLevel != 1.0f)
            || (self.minBlackLevelRed != 0.f || self.maxWhiteLevelRed != 1.0f)
            || (self.minBlackLevelGreen != 0.f || self.maxWhiteLevelGreen != 1.0f)
            || (self.minBlackLevelBlue != 0.f || self.maxWhiteLevelBlue != 1.0f);
        }
        case MysticSettingLevelsRed: return (self.blackLevelsRed != kLevelsMin || self.whiteLevelsRed != kLevelsMax || self.midLevelsRed != kLevelsMin + ((kLevelsMax - kLevelsMin)/2)) || (self.minBlackLevelRed != 0.f || self.maxWhiteLevelRed != 1.0f);
        case MysticSettingLevelsGreen: return (self.blackLevelsGreen != kLevelsMin || self.whiteLevelsGreen != kLevelsMax || self.midLevelsGreen != kLevelsMin + ((kLevelsMax - kLevelsMin)/2)) || (self.minBlackLevelGreen != 0.f || self.maxWhiteLevelGreen != 1.0f);
        case MysticSettingLevelsBlue: return (self.blackLevelsBlue != kLevelsMin || self.whiteLevelsBlue != kLevelsMax || self.midLevelsBlue != kLevelsMin + ((kLevelsMax - kLevelsMin)/2)) || (self.minBlackLevelBlue != 0.f || self.maxWhiteLevelBlue != 1.0f);
        case MysticSettingLevelsRGB: return (self.blackLevels != kLevelsMin || self.whiteLevels != kLevelsMax || self.midLevels != kLevelsMin + ((kLevelsMax - kLevelsMin)/2)) || (self.minBlackLevel != 0.f || self.maxWhiteLevel != 1.0f);
            
        case MysticSettingHaze: return self.haze != kHaze;
        case MysticSettingHazeSlope: return self.hazeSlopeValue != MYSTIC_FLOAT_UNKNOWN && self.hazeSlope != kHazeSlope;
        case MysticSettingSaturation: return self.saturation != kSaturation;
        case MysticSettingTiltShift:
        {
            return _tiltShiftTop != MYSTIC_FLOAT_UNKNOWN || _tiltShiftBottom != MYSTIC_FLOAT_UNKNOWN || _tiltShiftBlurSizeInPixels != MYSTIC_FLOAT_UNKNOWN || _tiltShiftFallOff != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingToon:
        {
            return _toonThreshold != MYSTIC_FLOAT_UNKNOWN || _toonLevels != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingPosterize:
        {
            return _posterizeLevels!=NSNotFound;
        }
        case MysticSettingHalfTone:
        {
            return _halftonePixelWidth != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingPixellate:
        {
            return _pixellatePixelWidth != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingSketchFilter:
        {
            return _sketchWidth != MYSTIC_FLOAT_UNKNOWN || _sketchHeight != MYSTIC_FLOAT_UNKNOWN || _sketchStrength != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingDistortGlassSphere:
        {
            return _sphereRadius != MYSTIC_FLOAT_UNKNOWN || _sphereRefractiveIndex != MYSTIC_FLOAT_UNKNOWN || !CGPointEqual(_sphereCenter, (CGPoint){.5,.5});
        }
        case MysticSettingDistortPinch:
        {
            return _pinchRadius != MYSTIC_FLOAT_UNKNOWN || _pinchScale != MYSTIC_FLOAT_UNKNOWN || !CGPointEqual(_pinchCenter, (CGPoint){.5,.5});
        }
        case MysticSettingDistortStretch:
        {
            return !CGPointEqual(_stretchCenter, (CGPoint){.5,.5});
        }
        case MysticSettingDistortBuldge:
        {
            return !CGPointEqual(_buldgeCenter, (CGPoint){.5,.5}) || _buldgeRadius != MYSTIC_FLOAT_UNKNOWN || _buldgeScale != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingDistortSwirl:
        {
            return _swirlAngle != MYSTIC_FLOAT_UNKNOWN || _swirlRadius != MYSTIC_FLOAT_UNKNOWN || !CGPointEqual(_swirlCenter, (CGPoint){.5,.5});
        }
        case MysticSettingBlurCircle:
        {
            return _blurCircleRadius != MYSTIC_FLOAT_UNKNOWN || _blurCircleAspectRatio != MYSTIC_FLOAT_UNKNOWN || _blurCircleExcludeSize != MYSTIC_FLOAT_UNKNOWN || _blurCircleExcludeRadius != MYSTIC_FLOAT_UNKNOWN || !CGPointEqual(_blurCirclePoint, (CGPoint){.5,.5});
        }
        case MysticSettingBlurZoom:
        {
            return _blurZoomSize != MYSTIC_FLOAT_UNKNOWN || !CGPointEqual(_blurZoomCenter, (CGPoint){.5,.5});
        }
        case MysticSettingBlurMotion:
        {
            return _blurMotionSize != MYSTIC_FLOAT_UNKNOWN || _blurMotionAngle != MYSTIC_FLOAT_UNKNOWN;
        }
        case MysticSettingBlur:
        {
            return _blurRadius != MYSTIC_FLOAT_UNKNOWN || _blurRadiusFractionWidth != MYSTIC_FLOAT_UNKNOWN || _blurRadiusFractionHeight != MYSTIC_FLOAT_UNKNOWN;
        }
            
        case MysticSettingContrast: return self.contrast != kContrast;
        case MysticSettingSharpness: return self.sharpness != kSharpness;
        case MysticSettingShadows: return self.shadows != kShadows;
        case MysticSettingHighlights: return self.highlights != kHighlights;
        case MysticSettingAlpha: return self.alpha != 1.0f;
        case MysticSettingHSBHue: return MysticHSBDefault.hue != self.hsb.hue;
        case MysticSettingHSBSaturation: return MysticHSBDefault.saturation != self.hsb.saturation;
        case MysticSettingHSBBrightness: return MysticHSBDefault.brightness != self.hsb.brightness;
        case MysticSettingMask:
        case MysticSettingMaskLayer: return self.hasMaskImage;
        case MysticSettingColor:
        case MysticSettingColorAndIntensity: return [self hasUserSelectedColorOfOptionType:MysticOptionColorTypeForeground];
        case MysticSettingIntensity: return self.intensity != 1;
        case MysticSettingTransformAdjusted:
        case MysticSettingTransformOriginal:
        case MysticSettingAdjustTransformRect: return NO;
        case MysticSettingTransform: return !(CGRectEqualToRect(self.transformRect, self.originalTransformRect) || CGRectEqualToRect(self.transformRect, MysticDefaultTransformRect)) || self.flipHorizontal || self.flipVertical;
        case MysticSettingBlending: return [self respondsToSelector:@selector(blendingMode)] && (self.blendingMode || (self.adjustedBlendingType != MysticFilterTypeUnknown ));
        default: return NO;
    }
    return NO;
}

- (void) undoLastAdjustment;
{
    [self undoAdjustment:self.refreshState];
}
- (void) undoAdjustment:(MysticObjectType)adjustmentType;
{
    NSArray *types = @[@(adjustmentType)];
    switch (adjustmentType) {
        case MysticSettingHighlights:
        case MysticSettingHighlightIntensity:
            types = @[@(MysticSettingHighlights), @(MysticSettingHighlightIntensity), @(MysticSettingHighlightTintColor)];
            break;
        case MysticSettingShadows:
        case MysticSettingShadowIntensity:
            types = @[@(MysticSettingShadows), @(MysticSettingShadowIntensity), @(MysticSettingShadowTintColor)];
            break;
        case MysticSettingVignette:
            
            [self reset:adjustmentType];
            [self setValue:nil forSetting:adjustmentType];

            [self setTempInfo:nil key:MysticString(adjustmentType)];

            return;
        default:
            break;
    }
    if(adjustmentType > MysticSettingImageProcessing)
    {
        [self reset:adjustmentType];
        [self setValue:nil forSetting:adjustmentType];
        [self setTempInfo:nil key:MysticString(adjustmentType)];
        return;
    }
    for (NSNumber *type in types) {
        id key = MysticString([type intValue]);
        id value = [self tempValueForKey:key];
        if (value && key) {
            
            [self setValue:value forSetting:[type intValue]];
            [self setTempInfo:nil key:key];
        }
        else {
 
            [self reset:[type intValue]]; }
    }
}
- (void) applyAdjustments:(NSDictionary *)theAdjustments;
{
    
    for (id settingKey in (NSArray *)theAdjustments[@"keys"]) [self setValue:[theAdjustments objectForKey:settingKey] forSetting:[settingKey integerValue]];
}

- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption;
{
    [self applyAdjustmentsFrom:otherOption setting:otherOption.setting];
}
- (void) applyAdjustmentsFrom:(PackPotionOption *)otherOption setting:(MysticObjectType)setting;
{
    
    switch (otherOption.type)
    {
        case MysticObjectTypeColor:
        {
            PackPotionOptionColor *colorOption = (id)otherOption;
            switch (setting) {
                case MysticSettingBackground:
                case MysticSettingBackgroundColor: [self setColorType:colorOption.optionType color:colorOption.color]; break;
                case MysticSettingVignette: self.vignetteColor = colorOption.color; break;
                default: self.colorOption = (PackPotionOptionColor *)otherOption; break;
            }
            break;
        }
        default: break;
    }
    
}


- (void) applyPreviousAdjustmentsFrom:(PackPotionOption *)otherOption;
{
    
}


- (BOOL) reset:(MysticObjectType)adjustmentType;
{
    [self removeAdjustOrder:adjustmentType];
    BOOL didReset = [self hasAdjusted:adjustmentType];
    if(didReset)
    {
        self.hasChanged = YES;
        switch (adjustmentType)
        {
            case MysticSettingDistortStretch:
                self.stretchCenter = (CGPoint){0.5,0.5};
                break;
            case MysticSettingDistortPinch:
                self.pinchCenter = (CGPoint){0.5,0.5};
                self.pinchScale = MYSTIC_FLOAT_UNKNOWN;
                self.pinchRadius = MYSTIC_FLOAT_UNKNOWN;
                break;
            case MysticSettingDistortSwirl:
                self.swirlCenter = (CGPoint){0.5,0.5};
                self.swirlAngle = MYSTIC_FLOAT_UNKNOWN;
                self.swirlRadius = MYSTIC_FLOAT_UNKNOWN;

                break;
            case MysticSettingDistortBuldge:
                self.buldgeCenter = (CGPoint){0.5,0.5};
                self.buldgeRadius = MYSTIC_FLOAT_UNKNOWN;
                self.buldgeScale = MYSTIC_FLOAT_UNKNOWN;

                break;
            case MysticSettingDistortGlassSphere:
                self.sphereCenter = (CGPoint){0.5,0.5};
                self.sphereRadius = MYSTIC_FLOAT_UNKNOWN;
                break;
            case MysticSettingBlur:
            case MysticSettingBlurGaussian:
                self.blurPasses = NSNotFound;
                self.blurRadius = MYSTIC_FLOAT_UNKNOWN;
                break;
            case MysticSettingBlurZoom:
                self.blurZoomSize = MYSTIC_FLOAT_UNKNOWN;
                self.blurZoomCenter = (CGPoint){0.5,0.5};
                break;
            case MysticSettingBlurCircle:
                self.blurCirclePoint = (CGPoint){0.5,0.5};
                self.blurCircleRadius =MYSTIC_FLOAT_UNKNOWN;
                self.blurCircleAspectRatio =MYSTIC_FLOAT_UNKNOWN;
                self.blurCircleExcludeSize =MYSTIC_FLOAT_UNKNOWN;
                self.blurCircleExcludeRadius =MYSTIC_FLOAT_UNKNOWN;

                break;
            case MysticSettingBlurMotion:
                self.blurMotionSize =MYSTIC_FLOAT_UNKNOWN;
                self.blurMotionAngle =MYSTIC_FLOAT_UNKNOWN;

                break;
            case MysticSettingHalfTone:
                self.halftoneShadow = nil;
                self.halftoneHighlight = nil;
                self.halftonePixelWidth = MYSTIC_FLOAT_UNKNOWN;
                break;
            case MysticSettingPixellate:
                self.pixellatePixelWidth = MYSTIC_FLOAT_UNKNOWN;
                break;
            case MysticSettingPosterize:
                self.posterizeLevels = NSNotFound;
                break;
            case MysticSettingSketchFilter:
                self.sketchWidth = MYSTIC_FLOAT_UNKNOWN;
                self.sketchHeight = MYSTIC_FLOAT_UNKNOWN;
                self.sketchShadow = nil;
                self.sketchHighlight = nil;
                self.sketchStrength = MYSTIC_FLOAT_UNKNOWN;
                
                break;
            case MysticSettingToon:
                self.toonWidth = MYSTIC_FLOAT_UNKNOWN;
                self.toonHeight = MYSTIC_FLOAT_UNKNOWN;
                self.toonLevels = MYSTIC_FLOAT_UNKNOWN;
                self.toonThreshold = MYSTIC_FLOAT_UNKNOWN;

                break;
            case MysticSettingGrain: {
                self.grainColor = nil;
                self.grainAlpha = 0;
                self.grainTime = 1;
                self.grainThreshold = 0.3;
                break;
            }
            case MysticSettingAdjustColor: self.adjustColors=nil; break;
            case MysticSettingShadowIntensity: self.shadowIntensity = 0; break;
            case MysticSettingHighlightIntensity: self.highlightIntensity = 0; break;
            case MysticSettingHighlightTintColor: self.highlightTintColor = nil; break;
            case MysticSettingShadowTintColor: self.shadowTintColor = nil; break;
                
            case MysticSettingMask: self.maskImage = nil; break;
            case MysticSettingAutoEnhance:
            {
                self.autoEnhance = NO;
                break;
            }
            case MysticSettingHSB:
            {
                self.hsb = MysticHSBDefault;
                break;
            }
            case MysticSettingHSBHue:
            {
                MysticHSB d = MysticHSBDefault;
                self.hsb = MysticHSBMake(d.hue, self.hsb.saturation, self.hsb.brightness);
                break;
            }
            case MysticSettingHSBSaturation:
            {
                MysticHSB d = MysticHSBDefault;
                self.hsb = MysticHSBMake(self.hsb.hue, d.saturation, self.hsb.brightness);
                break;
            }
            case MysticSettingHSBBrightness:
            {
                MysticHSB d = MysticHSBDefault;
                self.hsb = MysticHSBMake(self.hsb.hue, self.hsb.saturation, d.brightness);
                break;
            }
            case MysticSettingBrightness:
            {
                self.brightness = kBrightness;
                break;
            }
            case MysticSettingSkin: self.skinToneAdjust = kMysticSkin; break;
            case MysticSettingSkinHue: self.skinHue = kMysticSkinHue; break;
            case MysticSettingSkinHueThreshold: self.skinHueThreshold = kMysticSkinHueThreshold; break;
            case MysticSettingSkinMaxHueShift: self.skinHueMaxShift = kMysticSkinMaxHueShift; break;
            case MysticSettingSkinMaxSaturationShift: self.skinMaxSaturation = kMysticSkinMaxSaturationShift; break;
            case MysticSettingSkinUpperSkinToneColor: self.skinUpperTone = kMysticSkin; break;
                
                
            case MysticSettingVibrance:
            {
                self.vibrance = 1.2;
                break;
            }
            case MysticSettingGamma:
            {
                self.gamma = kGamma;
                break;
            }
            case MysticSettingExposure:
            {
                self.exposure = kExposure;
                break;
            }
            case MysticSettingColorBalance:
            {
                self.rgb = (GPUVector3){1.0f,1.0f,1.0f};
                break;
            }
            case MysticSettingColorBalanceRed:
            {
                self.rgb = (GPUVector3){1.0f,self.rgb.two,self.rgb.three};
                break;
            }
            case MysticSettingColorBalanceBlue:
            {
                self.rgb = (GPUVector3){self.rgb.one,self.rgb.two,1.0f};
                break;
            }
            case MysticSettingColorBalanceGreen:
            {
                self.rgb = (GPUVector3){self.rgb.one,1.0f,self.rgb.three};
                break;
            }
            case MysticSettingVignette:
            {
                self.vignetteStart = kVignetteStart;
                self.vignetteEnd = kVignetteEnd;
                self.vignetteCenter = CGPointUnknown;
                self.vignetteColor = nil;
                self.vignetteBlendingType = MysticFilterTypeBlendNormal;
                break;
            }
            case MysticSettingUnsharpMask:
            {
                self.unsharpMask = kUnsharpMask;
                self.unsharpBlurRadius = MYSTIC_FLOAT_UNKNOWN;
                break;
            }
            case MysticSettingTemperature:
            {
                self.temperature = kTemperature;
                self.tint = kTint;
                break;
            }
            case MysticSettingCamLayerSetup:
            case MysticSettingLevels:
            {
                self.blackLevels = kLevelsMin;
                self.whiteLevels = kLevelsMax;
                self.midLevels = kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
                break;
            }
            case MysticSettingHaze:
            {
                self.haze = kHaze;
                break;
            }
            case MysticSettingHazeSlope:
            {
                _hazeSlope = MYSTIC_FLOAT_UNKNOWN;
                break;
            }
            case MysticSettingSaturation:
            {
                self.saturation = kSaturation;
                break;
            }
            case MysticSettingTiltShift:
            {
                self.tiltShift = MYSTIC_FLOAT_UNKNOWN;
                self.tiltShiftTop = MYSTIC_FLOAT_UNKNOWN;
                self.tiltShiftBottom = MYSTIC_FLOAT_UNKNOWN;
                self.tiltShiftFallOff = MYSTIC_FLOAT_UNKNOWN;
                self.tiltShiftBlurSizeInPixels = MYSTIC_FLOAT_UNKNOWN;
                break;
            }
            case MysticSettingContrast:
            {
                self.contrast = kContrast;
                break;
            }
            case MysticSettingSharpness:
            {
                self.sharpness = kSharpness;
                break;
            }
            case MysticSettingShadows:
            {
                self.shadows = kShadows;
                break;
            }
            case MysticSettingHighlights:
            {
                self.highlights = kHighlights;
                break;
            }
            case MysticSettingAlpha:
            {
                self.alpha = 1.0f;
                break;
            }
            case MysticSettingBlending:
            {
                break;
            }
            default:
            {
                return NO;
            }
        }
    }
    return didReset;
}
- (BOOL) hasAdjustments
{
    if(
       self.autoEnhance != NO ||
       self.brightness != kBrightness ||
       self.skinToneAdjust != kMysticSkin ||
       self.skinHue != kMysticSkinHue ||
       self.skinHueThreshold != kMysticSkinHueThreshold ||
       self.skinHueMaxShift != kMysticSkinMaxHueShift ||
       self.skinMaxSaturation != kMysticSkinMaxSaturationShift ||
       self.skinUpperTone != kMysticSkinUpperSkinToneColor ||
       self.highlightIntensity != 0 ||
       self.shadowIntensity != 0 ||
       self.shadowTintColor != nil ||
       self.highlightTintColor != nil ||
       
       self.vibrance != 0 ||
       self.temperature != kTemperature ||
       self.tint != kTint ||
       self.tiltShift != kTiltShift ||
       self.gamma != kGamma ||
       self.exposure != kExposure ||
       self.contrast != kContrast ||
       self.saturation != kSaturation ||
       self.highlights != kHighlights ||
       self.shadows != kShadows ||
       self.sharpness != kSharpness ||
       self.haze != kHaze ||
       self.hazeSlopeValue != MYSTIC_FLOAT_UNKNOWN ||
       self.hazeSlope != kHazeSlope ||
       self.blackLevels != kLevelsMin ||
       self.whiteLevels != kLevelsMax ||
       !MysticHSBEqualToHSB(self.hsb, MysticHSBDefault) ||
       self.unsharpMask != kUnsharpMask ||
       (self.rgb.one != 1.0f || self.rgb.two != 1.0f || self.rgb.three != 1.0f) ||
       ((self.vignetteStart != kVignetteStart && self.vignetteEnd != kVignetteStart) || !CGPointIsUnknown(self.vignetteCenter))
       
       
       )
    {
        return YES;
    }
    return NO;
}
- (NSInteger) numberOfAdjustments;
{
    return self.adjustments.count - 1;
}
- (void) resetAdjustments;
{
    [self resetTransform];
    [self setDefaultSettings];
    [self resetAdjustOrder];
    self.hasChanged = NO;
    //    [super setHasRendered:NO];
    
}
- (void) setDefaultSettings;
{
    _autoEnhance = NO;
    _wearAndTearValue = MYSTIC_WEAR_DEFAULT;
    _flipVertical = NO;
    _flipHorizontal = NO;
    _flipTextureHorizontal = NO;
    _flipTextureVertical = NO;
    _applySunshine = NO;
    _brightness = kBrightness;
    _skinToneAdjust = kMysticSkin;
    _skinHue = kMysticSkinHue;
    _skinHueMaxShift = kMysticSkinMaxHueShift;
    _skinHueThreshold = kMysticSkinHueThreshold;
    _skinMaxSaturation = kMysticSkinMaxSaturationShift;
    _skinUpperTone = kMysticSkinUpperSkinToneColor;
    self.grainColor = nil;
    self.grainAlpha = 0;
    self.grainThreshold = 0.3;
    self.grainTime = 1;
    _shadowIntensity = 0;
    _highlightIntensity = 0;
    if(_shadowTintColor) [_shadowTintColor release], _shadowTintColor = nil;
    if(_highlightTintColor) [_highlightTintColor release], _highlightTintColor = nil;
    self.adjustColors=nil;
    _vibrance = 0;
    _temperature = kTemperature;
    _tint = kTint;
    _tiltShift = kTiltShift;
    _gamma = kGamma;
    _exposure = kExposure;
    _shadows = kShadows;
    _highlights = kHighlights;
    _sharpness = kSharpness;
    _contrast = kContrast;
    _unsharpMask = kUnsharpMask;
    _saturation = kSaturation;
    _haze = kHaze;
    _hazeSlope = MYSTIC_FLOAT_UNKNOWN;
    _vignetteStart = kVignetteStart;
    _vignetteEnd = _vignetteStart;
    _vignetteColor = nil;
    _vignetteCenter = CGPointUnknown;
    _blackLevels = kLevelsMin;
    _whiteLevels = kLevelsMax;
    _midLevels = kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
    _maxWhiteLevel = 1.0f;
    _minBlackLevel = 0.0f;
    
    _blackLevelsRed = _blackLevels;
    _whiteLevelsRed = _whiteLevels;
    _midLevelsRed = _midLevels;
    _maxWhiteLevelRed = _maxWhiteLevel;
    _minBlackLevelRed = _minBlackLevel;
    
    _blackLevelsBlue = _blackLevels;
    _whiteLevelsBlue = _whiteLevels;
    _midLevelsBlue = _midLevels;
    _maxWhiteLevelBlue = _maxWhiteLevel;
    _minBlackLevelBlue = _minBlackLevel;
    
    _blackLevelsGreen = _blackLevels;
    _whiteLevelsGreen = _whiteLevels;
    _midLevelsGreen = _midLevels;
    _maxWhiteLevelGreen = _maxWhiteLevel;
    _minBlackLevelGreen = _minBlackLevel;
    
    _sphereRadius = MYSTIC_FLOAT_UNKNOWN;
    _sphereRefractiveIndex=MYSTIC_FLOAT_UNKNOWN;
    _pixellatePixelWidth=MYSTIC_FLOAT_UNKNOWN;
    _halftonePixelWidth=MYSTIC_FLOAT_UNKNOWN;
    _sketchStrength=MYSTIC_FLOAT_UNKNOWN;
    _sketchHeight=MYSTIC_FLOAT_UNKNOWN;
    _sketchWidth=MYSTIC_FLOAT_UNKNOWN;
    _toonWidth=MYSTIC_FLOAT_UNKNOWN;
    _toonHeight=MYSTIC_FLOAT_UNKNOWN;
    _toonLevels=MYSTIC_FLOAT_UNKNOWN;
    _toonThreshold=MYSTIC_FLOAT_UNKNOWN;
    _buldgeRadius=MYSTIC_FLOAT_UNKNOWN;
    _buldgeScale=MYSTIC_FLOAT_UNKNOWN;

    _swirlRadius=MYSTIC_FLOAT_UNKNOWN;
    _swirlAngle=MYSTIC_FLOAT_UNKNOWN;
    _pinchRadius=MYSTIC_FLOAT_UNKNOWN;
    _pinchScale=MYSTIC_FLOAT_UNKNOWN;
    _tiltShiftFallOff=MYSTIC_FLOAT_UNKNOWN;
    _tiltShiftBlurSizeInPixels=MYSTIC_FLOAT_UNKNOWN;
    _tiltShiftBottom=MYSTIC_FLOAT_UNKNOWN;
    _tiltShiftTop=MYSTIC_FLOAT_UNKNOWN;
    _unsharpBlurRadius=MYSTIC_FLOAT_UNKNOWN;
    _blurCircleRadius=MYSTIC_FLOAT_UNKNOWN;
    _blurCircleExcludeRadius=MYSTIC_FLOAT_UNKNOWN;
    _blurCircleExcludeSize=MYSTIC_FLOAT_UNKNOWN;
    _blurCircleAspectRatio=MYSTIC_FLOAT_UNKNOWN;
    _blurZoomSize=MYSTIC_FLOAT_UNKNOWN;
    _blurMotionAngle=MYSTIC_FLOAT_UNKNOWN;
    _blurMotionSize=MYSTIC_FLOAT_UNKNOWN;
    _blurRadius=MYSTIC_FLOAT_UNKNOWN;
    _blurRadiusFractionWidth=MYSTIC_FLOAT_UNKNOWN;
    _blurRadiusFractionHeight=MYSTIC_FLOAT_UNKNOWN;
    _blurPasses=NSNotFound;
    _posterizeLevels=NSNotFound;

    _sphereCenter = (CGPoint){0.5,0.5};
    _stretchCenter = (CGPoint){0.5,0.5};
    _pinchCenter = (CGPoint){0.5,0.5};
    _buldgeCenter = (CGPoint){0.5,0.5};
    _swirlCenter = (CGPoint){0.5,0.5};
    _blurZoomCenter = (CGPoint){0.5,0.5};
    _blurCirclePoint = (CGPoint){0.5,0.5};
    
    
    
    self.maskBrush = MysticBrushDefault;
    _intensity = 1;
    _rgb = (GPUVector3){1.0f,1.0f,1.0f};
    _hsb = MysticHSBDefault;
    [self resetBlending];
    self.colorTypes = [NSMutableDictionary dictionary];
    
    
}
- (id) valueForType:(MysticObjectType)type;
{
    NSValue *val = nil;
    switch (type) {
        case MysticSettingSketchFilter: return @{@"sketchWidth":@(self.sketchWidth),@"sketchHeight":@(self.sketchHeight),@"sketchStrength":@(self.sketchStrength),@"sketchHighlight":self.sketchHighlight ? self.sketchHighlight:[NSNull null],@"sketchShadow":self.sketchShadow ? self.sketchShadow:[NSNull null],};
        case MysticSettingHalfTone: return @{@"halftonePixelWidth":@(self.halftonePixelWidth),@"halftoneHighlight":self.halftoneHighlight ? self.halftoneHighlight:[NSNull null],@"halftoneShadow":self.halftoneShadow ? self.halftoneShadow:[NSNull null],};
        case MysticSettingPosterize: return @{@"posterizeLevels":@(self.posterizeLevels)};
        case MysticSettingPixellate: return @{@"pixellatePixelWidth":@(self.pixellatePixelWidth)};
        case MysticSettingToon: return @{@"toonWidth":@(self.toonWidth),@"toonHeight":@(self.toonHeight),@"toonThreshold":@(self.toonThreshold),@"toonLevels":@(self.toonLevels)};
        case MysticSettingBlur: return @{@"blurRadiusFractionWidth":@(self.blurRadiusFractionWidth),@"blurRadiusFractionHeight":@(self.blurRadiusFractionHeight),@"blurRadius":@(self.blurRadius),@"blurPasses":@(self.blurPasses)};
        case MysticSettingBlurGaussian: return @{};
        case MysticSettingBlurMotion: return @{@"blurMotionSize":@(self.blurMotionSize),@"blurMotionAngle":@(self.blurMotionAngle)};
        case MysticSettingBlurCircle: return @{@"blurCircleRadius":@(self.blurCircleRadius),@"blurCircleExcludeRadius":@(self.blurCircleExcludeRadius),@"blurCircleExcludeSize":@(self.blurCircleExcludeSize),@"blurCircleAspectRatio":@(self.blurCircleAspectRatio),@"blurCirclePoint":[NSValue valueWithCGPoint:self.blurCirclePoint]};
        case MysticSettingBlurZoom: return @{@"blurZoomSize":@(self.blurZoomSize),@"blurZoomCenter":[NSValue valueWithCGPoint:self.blurZoomCenter]};
        case MysticSettingDistortGlassSphere: return @{@"sphereRadius":@(self.sphereRadius),@"sphereRefractiveIndex":@(self.sphereRefractiveIndex),@"sphereCenter":[NSValue valueWithCGPoint:self.sphereCenter],};
        case MysticSettingDistortStretch: return @{@"stretchCenter":[NSValue valueWithCGPoint:self.stretchCenter]};
        case MysticSettingDistortBuldge: return @{@"buldgeCenter":[NSValue valueWithCGPoint:self.buldgeCenter],@"buldgeRadius":@(self.buldgeRadius),@"buldgeScale":@(self.buldgeScale)};
        case MysticSettingDistortSwirl: return @{@"sphereRadius":@(self.sphereRadius),@"sphereRefractiveIndex":@(self.sphereRefractiveIndex),@"swirlCenter":[NSValue valueWithCGPoint:self.swirlCenter]};
        case MysticSettingDistortPinch: return @{@"pinchRadius":@(self.pinchRadius),@"pinchScale":@(self.pinchScale)};

        case MysticSettingGrain: return @{@"time":@(self.grainTime),@"color":self.grainColor ? self.grainColor:[NSNull null], @"threshold":@(self.grainThreshold),@"alpha":@(self.grainAlpha)};
        case MysticSettingVignetteBlending: return @(self.vignetteBlendingType);
        case MysticSettingAdjustColor: return self.adjustColors ? self.adjustColors : @[];
        case MysticSettingAutoEnhance: return @(self.autoEnhance);
        case MysticSettingInvert: return @(self.inverted);

        case MysticSettingLayerEffect: return @(self.layerEffect);
        case MysticSettingBackgroundColor: return ![self.backgroundColor isEqualToColor:[[UIColor blackColor] colorWithAlphaComponent:1]] ? self.backgroundColor : nil;
        case MysticSettingForegroundColor: return ![self.foregroundColor isEqualToColor:[[UIColor whiteColor] colorWithAlphaComponent:1]] ? self.foregroundColor : nil;
        case MysticSettingHighlightIntensity: return @(self.highlightIntensity);
        case MysticSettingShadowIntensity: return @(self.shadowIntensity);
        case MysticSettingShadowTintColor: return self.shadowTintColor;
        case MysticSettingHighlightTintColor: return self.highlightTintColor;
        case MysticSettingBrightness: return @(self.brightness);
        case MysticSettingSkin: return @(self.skinToneAdjust);
        case MysticSettingSkinHue: return @(self.skinHue);
        case MysticSettingSkinMaxSaturationShift: return @(self.skinMaxSaturation);
        case MysticSettingSkinHueThreshold: return @(self.skinHueThreshold);
        case MysticSettingSkinMaxHueShift: return @(self.skinHueMaxShift);
        case MysticSettingSkinUpperSkinToneColor: return @(self.skinUpperTone);
        case MysticSettingVibrance: return @(self.vibrance);
        case MysticSettingGamma: return @(self.gamma);
        case MysticSettingExposure: return @(self.exposure);
        case MysticSettingColorBalance: return @[@(self.rgb.one), @(self.rgb.two), @(self.rgb.three)];
        case MysticSettingVignette: return @{@"start":@(self.vignetteStart),@"end":@(self.vignetteEnd),@"center":[NSValue valueWithCGPoint:self.vignetteCenter],@"color":self.vignetteColor ? self.vignetteColor : [NSNull null]};
        case MysticSettingUnsharpMask: return @(self.unsharpMask);
        case MysticSettingTemperature: return @[@(self.temperature), @(self.tint)];
        case MysticSettingCamLayerSetup:
        case MysticSettingLevels: {
            NSMutableDictionary *d = [NSMutableDictionary dictionary];
            float kLevelsMid = kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
            if(self.whiteLevels != kLevelsMax) [d setObject:@(self.whiteLevels) forKey:@"whiteLevels"];
            if(self.blackLevels != kLevelsMin) [d setObject:@(self.blackLevels) forKey:@"blackLevels"];
            if(self.midLevels != kLevelsMid) [d setObject:@(self.midLevels) forKey:@"midLevels"];
            if(self.minBlackLevel != 0.f) [d setObject:@(self.minBlackLevel) forKey:@"minBlackLevel"];
            if(self.maxWhiteLevel != 1.f) [d setObject:@(self.maxWhiteLevel) forKey:@"maxWhiteLevel"];
            if(self.whiteLevelsRed != kLevelsMax && self.whiteLevelsRed != self.whiteLevels) [d setObject:@(self.whiteLevelsRed) forKey:@"whiteLevelsRed"];
            if(self.blackLevelsRed != kLevelsMin && self.blackLevelsRed != self.blackLevels) [d setObject:@(self.blackLevelsRed) forKey:@"blackLevelsRed"];
            if(self.midLevelsRed != kLevelsMid && self.midLevelsRed != self.midLevels) [d setObject:@(self.midLevelsRed) forKey:@"midLevelsRed"];
            if(self.minBlackLevelRed != 0.f && self.minBlackLevelRed != self.minBlackLevel) [d setObject:@(self.minBlackLevelRed) forKey:@"minBlackLevelRed"];
            if(self.maxWhiteLevelRed != 1.f && self.maxWhiteLevelRed != self.maxWhiteLevel) [d setObject:@(self.maxWhiteLevelRed) forKey:@"maxWhiteLevelRed"];
            if(self.whiteLevelsGreen != kLevelsMax && self.whiteLevelsGreen != self.whiteLevels) [d setObject:@(self.whiteLevelsGreen) forKey:@"whiteLevelsGreen"];
            if(self.blackLevelsGreen != kLevelsMin && self.blackLevelsGreen != self.blackLevels) [d setObject:@(self.blackLevelsGreen) forKey:@"blackLevelsGreen"];
            if(self.midLevelsGreen != kLevelsMid && self.midLevelsGreen != self.midLevels) [d setObject:@(self.midLevelsGreen) forKey:@"midLevelsGreen"];
            if(self.minBlackLevelGreen != 0.f && self.minBlackLevelGreen != self.minBlackLevel) [d setObject:@(self.minBlackLevelGreen) forKey:@"minBlackLevelGreen"];
            if(self.maxWhiteLevelGreen != 1.f && self.maxWhiteLevelGreen != self.maxWhiteLevel) [d setObject:@(self.maxWhiteLevelGreen) forKey:@"maxWhiteLevelGreen"];
            if(self.whiteLevelsBlue != kLevelsMax && self.whiteLevelsBlue != self.whiteLevels) [d setObject:@(self.whiteLevelsBlue) forKey:@"whiteLevelsBlue"];
            if(self.blackLevelsBlue != kLevelsMin && self.blackLevelsBlue != self.blackLevels) [d setObject:@(self.blackLevelsBlue) forKey:@"blackLevelsBlue"];
            if(self.midLevelsBlue != kLevelsMid && self.midLevelsBlue != self.midLevels) [d setObject:@(self.midLevelsBlue) forKey:@"midLevelsBlue"];
            if(self.minBlackLevelBlue != 0.f && self.minBlackLevelBlue != self.minBlackLevel) [d setObject:@(self.minBlackLevelBlue) forKey:@"minBlackLevelBlue"];
            if(self.maxWhiteLevelBlue != 1.f && self.maxWhiteLevelBlue != self.maxWhiteLevel) [d setObject:@(self.maxWhiteLevelBlue) forKey:@"maxWhiteLevelBlue"];
            return [NSDictionary dictionaryWithObjects:d.allValues forKeys:d.allKeys];
        }
        case MysticSettingHaze: return @(self.haze);
        case MysticSettingHazeSlope: return @(self.hazeSlope);
        case MysticSettingSaturation: return @(self.saturation);
        case MysticSettingTiltShift: return @(self.tiltShift);
        case MysticSettingContrast: return @(self.contrast);
        case MysticSettingSharpness: return @(self.sharpness);
        case MysticSettingShadows: return @(self.shadows);
        case MysticSettingHighlights: return @(self.highlights);
        case MysticSettingAlpha: return @(self.alpha);
        case MysticSettingHSBHue: return @(MysticHSBDefault.hue);
        case MysticSettingHSBSaturation: return @(MysticHSBDefault.saturation);
        case MysticSettingHSBBrightness: return @(MysticHSBDefault.brightness);
        case MysticSettingColor:
        case MysticSettingColorAndIntensity:
            return [self respondsToSelector:@selector(colorOption)] && [(PackPotionOptionFont *)self colorOption] ? [(PackPotionOptionFont *)self colorOption].color : self.foregroundColor;
        case MysticSettingIntensity: return @(self.intensity);
        case MysticSettingTransform: return [NSValue valueWithCGRect:self.transformRect];
        case MysticSettingTransformOriginal: return [NSValue valueWithCGRect:self.originalTransformRect];
        case MysticSettingAdjustTransformRect: return [NSValue valueWithCGRect:self.adjustedRect];
        case MysticSettingTransformAdjusted: return [NSValue valueWithCGRect:self.transformRectNormal];
        case MysticSettingBlending: return ([self respondsToSelector:@selector(blendingMode)] && (self.blendingMode || (self.adjustedBlendingType != MysticFilterTypeUnknown ))) ?
            @(self.blendingType) : @NO;
        case MysticSettingMaskLayer:
        case MysticSettingMask: return self.hasMaskImage ? self.maskImagePath : [NSNull null];
        default: break;
    }
    return val;
}
- (void) setValue:(id)value forSetting:(MysticObjectType)adjustmentType;
{
    self.hasChanged = YES;
    switch (adjustmentType)
    {
//        case MysticSettingSketchFilter: return @{@"sketchWidth":@(self.sketchWidth),@"sketchHeight":@(self.sketchHeight),@"sketchStrength":@(self.sketchStrength)};
//        case MysticSettingHalfTone: return @{@"halftonePixelWidth":@(self.halftonePixelWidth)};
//        case MysticSettingPosterize: return @{@"posterizeLevels":@(self.posterizeLevels)};
//        case MysticSettingPixellate: return @{@"pixellatePixelWidth":@(self.pixellatePixelWidth)};
//        case MysticSettingToon: return @{@"toonWidth":@(self.toonWidth),@"toonHeight":@(self.toonHeight),@"toonThreshold":@(self.toonThreshold),@"toonLevels":@(self.toonLevels)};
//        case MysticSettingBlur: return @{@"blurRadiusFractionWidth":@(self.blurRadiusFractionWidth),@"blurRadiusFractionHeight":@(self.blurRadiusFractionHeight),@"blurRadius":@(self.blurRadius),@"blurPasses":@(self.blurPasses)};
//        case MysticSettingBlurGaussian: return @{};
//        case MysticSettingBlurMotion: return @{@"blurMotionSize":@(self.blurMotionSize),@"blurMotionAngle":@(self.blurMotionAngle)};
//        case MysticSettingBlurCircle: return @{@"blurCircleRadius":@(self.blurCircleRadius),@"blurCircleExcludeRadius":@(self.blurCircleExcludeRadius),@"blurCircleExcludeSize":@(self.blurCircleExcludeSize),@"blurCircleAspectRatio":@(self.blurCircleAspectRatio),@"blurCirclePoint":[NSValue valueWithCGPoint:self.blurCirclePoint]};
//        case MysticSettingBlurZoom: return @{@"blurZoomSize":@(self.blurZoomSize),@"blurZoomCenter":[NSValue valueWithCGPoint:self.blurZoomCenter]};
//        case MysticSettingDistortGlassSphere: return @{@"sphereRadius":@(self.sphereRadius),@"sphereRefractiveIndex":@(self.sphereRefractiveIndex),@"sphereCenter":[NSValue valueWithCGPoint:self.sphereCenter],};
//        case MysticSettingDistortStretch: return @{@"stretchCenter":[NSValue valueWithCGPoint:self.stretchCenter]};
//        case MysticSettingDistortBuldge: return @{@"buldgeCenter":[NSValue valueWithCGPoint:self.buldgeCenter],@"buldgeRadius":@(self.buldgeRadius),@"buldgeScale":@(self.buldgeScale)};
//        case MysticSettingDistortSwirl: return @{@"sphereRadius":@(self.sphereRadius),@"sphereRefractiveIndex":@(self.sphereRefractiveIndex),@"swirlCenter":[NSValue valueWithCGPoint:self.swirlCenter]};
//        case MysticSettingDistortPinch: return @{@"pinchRadius":@(self.pinchRadius),@"pinchScale":@(self.pinchScale)};
            

        case MysticSettingDistortStretch:
            self.stretchCenter = [value[@"stretchCenter"] CGPointValue];
            break;
        case MysticSettingDistortPinch:
            self.pinchCenter = [value[@"pinchCenter"] CGPointValue];
            self.pinchScale = [value[@"pinchScale"] floatValue];
            self.pinchRadius = [value[@"pinchRadius"] floatValue];
            break;
        case MysticSettingDistortSwirl:
            self.swirlCenter = [value[@"swirlCenter"] CGPointValue];
            self.swirlAngle = [value[@"swirlAngle"] floatValue];
            self.swirlRadius = [value[@"swirlRadius"] floatValue];
            
            break;
        case MysticSettingDistortBuldge:
            self.buldgeCenter = [value[@"buldgeCenter"] CGPointValue];
            self.buldgeRadius = [value[@"buldgeRadius"] floatValue];
            self.buldgeScale = [value[@"buldgeScale"] floatValue];
            
            break;
        case MysticSettingDistortGlassSphere:
            self.sphereCenter = [value[@"sphereCenter"] CGPointValue];
            self.sphereRadius = [value[@"sphereRadius"] floatValue];
            break;
        case MysticSettingBlur:
        case MysticSettingBlurGaussian:
            self.blurPasses = [value[@"blurPasses"] integerValue];
            self.blurRadius = [value[@"blurRadius"] floatValue];
            break;
        case MysticSettingBlurZoom:
            self.blurZoomSize = [value[@"blurZoomSize"] floatValue];
            self.blurZoomCenter = [value[@"blurZoomCenter"] CGPointValue];
            break;
        case MysticSettingBlurCircle:
            self.blurCirclePoint = [value[@"blurCirclePoint"] CGPointValue];
            self.blurCircleRadius =[value[@"blurCircleRadius"] floatValue];
            self.blurCircleAspectRatio =[value[@"blurCircleAspectRatio"] floatValue];
            self.blurCircleExcludeSize =[value[@"blurCircleExcludeSize"] floatValue];
            self.blurCircleExcludeRadius =[value[@"blurCircleExcludeRadius"] floatValue];
            
            break;
        case MysticSettingBlurMotion:
            self.blurMotionSize =[value[@"blurMotionSize"] floatValue];
            self.blurMotionAngle =[value[@"blurMotionAngle"] floatValue];
            
            break;
        case MysticSettingHalfTone:
            if(value[@"halftoneShadow"] && !isNull(value[@"halftoneShadow"]))  self.halftoneShadow = value[@"halftoneShadow"];
            if(value[@"halftoneHighlight"] && !isNull(value[@"halftoneHighlight"])) self.halftoneHighlight = value[@"halftoneHighlight"];
            
            
            self.halftonePixelWidth = [value[@"halftonePixelWidth"] floatValue];
            break;
        case MysticSettingPixellate:
            self.pixellatePixelWidth = [value[@"pixellatePixelWidth"] floatValue];
            break;
        case MysticSettingPosterize:
            self.posterizeLevels = [value[@"posterizeLevels"] integerValue];
            break;
        case MysticSettingSketchFilter:
            self.sketchWidth = [value[@"sketchWidth"] floatValue];
            self.sketchHeight = [value[@"sketchHeight"] floatValue];
            if(value[@"sketchShadow"] && !isNull(value[@"sketchShadow"]))  self.sketchShadow = value[@"sketchShadow"];
            if(value[@"sketchHighlight"] && !isNull(value[@"sketchHighlight"])) self.sketchHighlight = value[@"sketchHighlight"];
            
            self.sketchStrength = [value[@"sketchStrength"] floatValue];
            
            break;
        case MysticSettingToon:
            self.toonWidth = [value[@"toonWidth"] floatValue];
            self.toonHeight = [value[@"toonHeight"] floatValue];
            self.toonLevels = [value[@"toonLevels"] floatValue];
            self.toonThreshold = [value[@"toonThreshold"] floatValue];
            
            break;
            
            
        case MysticSettingGrain: {
            NSDictionary *grain = value;
            self.grainAlpha = [grain[@"alpha"] floatValue];
            self.grainTime = [grain[@"time"] floatValue];
            self.grainThreshold = [grain[@"threshold"] floatValue];
            if(grain[@"color"] && !isNull(grain[@"color"])) self.grainColor = grain[@"color"];


            break;
        }
        case MysticSettingAdjustColor: self.adjustColors=value; break;
        case MysticSettingShadowTintColor: {
            if([value isKindOfClass:[NSString class]]) value = [UIColor string:value];
            self.shadowTintColor = isNull(value) ? nil : value; break;
        }
        case MysticSettingHighlightTintColor: {
            if([value isKindOfClass:[NSString class]]) value = [UIColor string:value];
            self.highlightTintColor = isNull(value) ? nil : value; break;
        }
        case MysticSettingHighlightIntensity: self.highlightIntensity = [value floatValue]; break;
        case MysticSettingShadowIntensity: self.shadowIntensity = [value floatValue]; break;
        case MysticSettingAutoEnhance: self.autoEnhance = [value boolValue]; break;
        case MysticSettingInvert: self.inverted = [value boolValue]; break;
        case MysticSettingLayerEffect: self.layerEffect = [value integerValue]; break;
        case MysticSettingBackgroundColor:
        {
            if([value isKindOfClass:[NSString class]]) value = [UIColor string:value];
            self.backgroundColor = value;
            break;
        }
        case MysticSettingForegroundColor:
        {
            
            if([value isKindOfClass:[NSString class]])
            {
                value = [UIColor string:value];
                
            }
            
            
            self.foregroundColor = value;
            break;
        }
            
        case MysticSettingTransform:
        {
            if([value isKindOfClass:[NSString class]])
            {
                NSRange r = [value rangeOfString:@"{{"];
                value = [value substringFromIndex:r.location];
                
            }
            self.transformRect = [value isKindOfClass:[NSString class]] ? CGRectFromString(value) : [value CGRectValue];
            break;
        }
        case MysticSettingTransformOriginal:
        {
            if([value isKindOfClass:[NSString class]])
            {
                NSRange r = [value rangeOfString:@"{{"];
                value = [value substringFromIndex:r.location];
                
            }
            self.originalTransformRect = [value isKindOfClass:[NSString class]] ? CGRectFromString(value) : [value CGRectValue];
            break;
        }
            //        case MysticSettingHSB:
            //        {
            //            self.hsb = MysticHSBDefault;
            //            break;
            //        }
        case MysticSettingHSBHue:
        {
            float d = value ? [(NSNumber *)value floatValue] : MysticHSBDefault.hue;
            self.hsb = MysticHSBMake(d, self.hsb.saturation, self.hsb.brightness);
            break;
        }
        case MysticSettingHSBSaturation:
        {
            float d = value ? [(NSNumber *)value floatValue] : MysticHSBDefault.saturation;
            self.hsb = MysticHSBMake(self.hsb.hue, d, self.hsb.brightness);
            break;
        }
        case MysticSettingHSBBrightness:
        {
            
            float d = value ? [(NSNumber *)value floatValue] : MysticHSBDefault.brightness;
            self.hsb = MysticHSBMake(self.hsb.hue, self.hsb.saturation, d);
            break;
        }
        case MysticSettingBrightness:
        {
            
            self.brightness = value ? [(NSNumber *)value floatValue] : kBrightness;
            break;
        }
        case MysticSettingSkin: self.skinToneAdjust = value ? [(NSNumber *)value floatValue] : kMysticSkin; break;
        case MysticSettingSkinUpperSkinToneColor: self.skinUpperTone = value ? [(NSNumber *)value intValue] : kMysticSkinUpperSkinToneColor; break;
        case MysticSettingSkinMaxHueShift: self.skinHueMaxShift = value ? [(NSNumber *)value floatValue] : kMysticSkinMaxHueShift; break;
        case MysticSettingSkinHueThreshold: self.skinHueThreshold = value ? [(NSNumber *)value floatValue] : kMysticSkinHueThreshold; break;
        case MysticSettingSkinMaxSaturationShift: self.skinMaxSaturation = value ? [(NSNumber *)value floatValue] : kMysticSkinMaxSaturationShift; break;
        case MysticSettingSkinHue: self.skinHue = value ? [(NSNumber *)value floatValue] : kMysticSkinHue; break;
            
            
            
            
            
        case MysticSettingVibrance:
        {
            
            self.vibrance = value ? [(NSNumber *)value floatValue] : 1.2;
            break;
        }
        case MysticSettingGamma:
        {
            self.gamma = value ? [(NSNumber *)value floatValue] : kGamma;
            break;
        }
        case MysticSettingExposure:
        {
            self.exposure = value ? [(NSNumber *)value floatValue] : kExposure;
            break;
        }
        case MysticSettingColorBalance:
        {
            self.rgb = (GPUVector3){1.0f,1.0f,1.0f};
            break;
        }
        case MysticSettingColorBalanceRed:
        {
            self.rgb = (GPUVector3){value ? [(NSNumber *)value floatValue] : 1.0f,self.rgb.two,self.rgb.three};
            break;
        }
        case MysticSettingColorBalanceBlue:
        {
            self.rgb = (GPUVector3){self.rgb.one,self.rgb.two,value ? [(NSNumber *)value floatValue] : 1.0f};
            break;
        }
        case MysticSettingColorBalanceGreen:
        {
            self.rgb = (GPUVector3){self.rgb.one,value ? [(NSNumber *)value floatValue] : 1.0f,self.rgb.three};
            break;
        }
        case MysticSettingVignette:
        {
            if([value isKindOfClass:[NSNumber class]])
            {
                self.vignetteValue = value ? [(NSNumber *)value floatValue] : kVignette;
            }
            else if([value isKindOfClass:[NSDictionary class]])
            {
                if(value[@"start"]) self.vignetteStart = [value[@"start"] floatValue];
                if(value[@"end"]) self.vignetteEnd = [value[@"end"] floatValue];
                if(value[@"center"]) self.vignetteCenter = [value[@"center"] CGPointValue];
                if(value[@"color"] && !isNull(value[@"color"]))
                    self.vignetteColor = [value[@"color"] isKindOfClass:[UIColor class]] ? value[@"color"] : [value[@"color"] isKindOfClass:[NSString class]] ? [UIColor string:value[@"color"]] : nil;
            }
            else if([value isKindOfClass:[UIColor class]])
            {
                self.vignetteColor = (id)value;
            }
            else if([value isKindOfClass:[NSString class]])
            {
                self.vignetteColor = [UIColor string:(id)value];
            }
            else  if(value == nil)
            {
                self.vignetteColor = nil;
                self.vignetteStart = kVignetteStart;
                self.vignetteEnd = kVignetteEnd;
                self.vignetteBlendingType = MysticFilterTypeBlendNormal;
                self.vignetteCenter = CGPointUnknown;
            }
            break;
        }
        case MysticSettingUnsharpMask:
        {
            if(!value || (value && [value isKindOfClass:[NSNumber class]]))
            {
                self.unsharpMask = value && [value isKindOfClass:[NSNumber class]] ? [(NSNumber *)value floatValue] :  kUnsharpMask;
            }
            break;
        }
        case MysticSettingTemperature:
        {
            if(!value || (value && [value isKindOfClass:[NSNumber class]]))
            {
                self.temperature = value && [value isKindOfClass:[NSNumber class]] ? [(NSNumber *)value floatValue] : kTemperature;
            }
            //            self.tint = kTint;
            break;
        }
        case MysticSettingCamLayerSetup:
        case MysticSettingLevels:
        {
            self.blackLevels = kLevelsMin;
            self.whiteLevels = kLevelsMax;
            self.midLevels = kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
            
            NSDictionary *levels = value;
            NSString *k = @"blackLevels";
            self.blackLevels = [levels objectForKey:k] ? [levels[k] floatValue] : kLevelsMin;
            k = @"whiteLevels";
            self.whiteLevels = [levels objectForKey:k] ? [levels[k] floatValue] : kLevelsMax;
            k = @"midLevels";
            self.midLevels = [levels objectForKey:k] ? [levels[k] floatValue] : kLevelsMin + ((kLevelsMax - kLevelsMin)/2);
            
            k = @"maxWhiteLevel";
            self.maxWhiteLevel = [levels objectForKey:k] ? [levels[k] floatValue] : 1.0f;
            k = @"minBlackLevel";
            self.minBlackLevel = [levels objectForKey:k] ? [levels[k] floatValue] : 0.f;
            
            k = @"blackLevelsRed";
            self.blackLevelsRed = [levels objectForKey:k] ? [levels[k] floatValue] : self.blackLevels;
            k = @"whiteLevelsRed";
            self.whiteLevelsRed = [levels objectForKey:k] ? [levels[k] floatValue] : self.whiteLevels;
            k = @"midLevelsRed";
            self.midLevelsRed = [levels objectForKey:k] ? [levels[k] floatValue] : self.midLevels;
            
            k = @"blackLevelsGreen";
            self.blackLevelsGreen = [levels objectForKey:k] ? [levels[k] floatValue] : self.blackLevels;
            k = @"whiteLevelsGreen";
            self.whiteLevelsGreen = [levels objectForKey:k] ? [levels[k] floatValue] : self.whiteLevels;
            k = @"midLevelsGreen";
            self.midLevelsGreen = [levels objectForKey:k] ? [levels[k] floatValue] : self.midLevels;
            
            k = @"blackLevelsBlue";
            self.blackLevelsBlue = [levels objectForKey:k] ? [levels[k] floatValue] : self.blackLevels;
            k = @"whiteLevelsBlue";
            self.whiteLevelsBlue = [levels objectForKey:k] ? [levels[k] floatValue] : self.whiteLevels;
            k = @"midLevelsBlue";
            self.midLevels = [levels objectForKey:k] ? [levels[k] floatValue] : self.midLevels;
            
            
            k = @"maxWhiteLevelRed";
            self.maxWhiteLevelRed = [levels objectForKey:k] ? [levels[k] floatValue] : self.maxWhiteLevel;
            k = @"minBlackLevelRed";
            self.minBlackLevelRed = [levels objectForKey:k] ? [levels[k] floatValue] : self.minBlackLevel;
            
            k = @"maxWhiteLevelGreen";
            self.maxWhiteLevelGreen = [levels objectForKey:k] ? [levels[k] floatValue] : self.maxWhiteLevel;
            k = @"minBlackLevelGreen";
            self.minBlackLevelGreen = [levels objectForKey:k] ? [levels[k] floatValue] : self.minBlackLevel;
            
            k = @"maxWhiteLevelBlue";
            self.maxWhiteLevelBlue = [levels objectForKey:k] ? [levels[k] floatValue] : self.maxWhiteLevel;
            k = @"minBlackLevelBlue";
            self.minBlackLevelBlue = [levels objectForKey:k] ? [levels[k] floatValue] : self.minBlackLevel;
            
            
            break;
        }
        case MysticSettingHaze:
        {
            self.haze = value ? [(NSNumber *)value floatValue] : kHaze;
            break;
        }
        case MysticSettingHazeSlope:
        {
            self.hazeSlope = value ? [(NSNumber *)value floatValue] : kHazeSlope;
            break;
        }
        case MysticSettingSaturation:
        {
            self.saturation = value ? [(NSNumber *)value floatValue] : kSaturation;
            break;
        }
        case MysticSettingTiltShift:
        {
            self.tiltShift = value ? [(NSNumber *)value floatValue] : kTiltShift;
            break;
        }
        case MysticSettingContrast:
        {
            self.contrast = value ? [(NSNumber *)value floatValue] :  kContrast;
            break;
        }
        case MysticSettingSharpness:
        {
            self.sharpness = value ? [(NSNumber *)value floatValue] :  kSharpness;
            break;
        }
        case MysticSettingShadows:
        {
            self.shadows = value ? [(NSNumber *)value floatValue] : kShadows;
            break;
        }
        case MysticSettingHighlights:
        {
            self.highlights = value ? [(NSNumber *)value floatValue] : kHighlights;
            break;
        }
        case MysticSettingIntensity:
        {
            self.intensity = value ? [(NSNumber *)value floatValue] : 1.0f;
            break;
        }
        case MysticSettingAlpha:
        {
            self.alpha = value ? [(NSNumber *)value floatValue] : 1.0f;
            break;
        }
        case MysticSettingBlending:
        {
            if(value) [self setBlendingType:[(NSNumber *)value integerValue]];
            break;
        }
            
        default:
        {
            
        }
    }
}
- (NSString *) renderedAdjustmentsDescription;
{
    return [self adjustmentsDescription:self.renderedAdjustments];
}
- (NSString *) adjustmentsDescription;
{
    return [self adjustmentsDescription:self.adjustments];
}
- (NSString *) allAdjustmentsDescription;
{
    return [self adjustmentsDescription:self.allAdjustments];
}
- (NSString *) unrenderedAdjustmentsDescription;
{
    return [self adjustmentsDescription:self.unRenderedAdjustments];
}
- (NSString *) adjustmentsDescription:(id)adjv;
{
    NSMutableString *s = [NSMutableString stringWithString:@"\n\n"];
    if([adjv isKindOfClass:[NSArray class]])
    {
        for (NSNumber *k in (NSArray *)adjv) [s appendFormat:@"%@, ", MyString([k intValue])];
        return s;
    }
    NSDictionary *adj = adjv;
    if(!adj || adj.count < 2) return adj.description;
    int longest = 0;
    int longest2 = 0;
    for (NSString *k in (NSArray *)[adj objectForKey:@"keys"]) {
        longest = MAX(longest, MyString([k intValue]).length);
        int l = [NSString stringWithFormat:@"%@", [adj objectForKey:k]].length;
        longest2 = MAX(longest2, l);
    }
    for (NSString *k in (NSArray *)[adj objectForKey:@"keys"]) {
        [s appendFormat:@"\t\t%@  %@  %@ \n",
         [[NSString stringWithFormat:@"%@:", MyString([k intValue])] stringByPaddingToLength:longest+4 withString:@" " startingAtIndex:0],
         [[NSString stringWithFormat:@"%@", [adj objectForKey:k]] stringByPaddingToLength:longest2+3 withString:@" " startingAtIndex:0],
         [NSString stringWithFormat:@"(%@)", AdjustmentStateToString([self adjustmentState:[k intValue]])]
         ];
    }
    return s;
    
}
- (BOOL) hasUnRenderedAdjustments;
{
    return self.unRenderedAdjustments.count > 1;
}
- (MysticAdjustmentState) adjustmentState:(MysticObjectType)type;
{
    BOOL adjusted = [self hasAdjusted:type];
    
    if(!self.renderedAdjustments) return adjusted ? MysticAdjustmentStateUnrendered : MysticAdjustmentStateNotAdjusted;
    
    
    switch (type) {
        case MysticSettingTransformAdjusted:
        case MysticSettingTransformOriginal:
        case MysticSettingAdjustTransformRect: return MysticAdjustmentStateNotAdjusted;
        default: break;
    }
    
    id renderedValue = [self.renderedAdjustments objectForKey:[NSString stringWithFormat:@"%d", type]];
    if(!adjusted && renderedValue) return MysticAdjustmentStateRendered;
    
    BOOL hasit = NO;
    id currentValue = nil;
    if(renderedValue)
    {
        currentValue = [self valueForType:type];
        if([currentValue isKindOfClass:[NSNumber class]])
        {
            int i = 0;
            
            return ([currentValue floatValue] == [renderedValue floatValue]) ? MysticAdjustmentStateRendered : MysticAdjustmentStateUnrendered;
            
        }
        else if(type == MysticSettingAdjustColor)
        {
            if(self.adjustColorsFinal.count) return MysticAdjustmentStateUnrendered;
        }
        else if([currentValue isKindOfClass:[NSArray class]])
        {
            hasit = YES;
            if([(NSArray *)currentValue count] != [(NSArray *)renderedValue count]) hasit = NO;
            else
            {
                for (int i = 0; i < [(NSArray *)currentValue count]; i++) {
                    id cValue = [(NSArray *)currentValue objectAtIndex:i];
                    id rValue = [(NSArray *)renderedValue objectAtIndex:i];
                    if([cValue floatValue] != [rValue floatValue]) { hasit = NO; break; }
                }
            }
        }
        else if([currentValue isKindOfClass:[NSDictionary class]])
        {
            hasit = YES;
            NSDictionary *cd = currentValue;
            NSDictionary *rd = renderedValue;
            if(cd.count != rd.count) hasit = NO;
            else
            {
                for (NSString *k in cd.allKeys) {
                    id cv = [cd objectForKey:k];
                    id rv = [rd objectForKey:k];
//                    if([cv floatValue] != [rv floatValue]) { hasit = NO; break; }
                    if(![cv isEqualToValue:rv]) { hasit = NO; break; }

                    
                }
            }
        }
        else if([currentValue isKindOfClass:[UIColor class]])
        {
            hasit = (BOOL)[(UIColor *)currentValue isEqualToColor:renderedValue];
        }
        else if([currentValue isKindOfClass:[NSValue class]])
        {
            CGRect cr = [currentValue CGRectValue];
            CGRect rr = [renderedValue CGRectValue];
            hasit = (BOOL)CGRectEqualToRect(cr, rr);
        }
    }
//    DLogDebug(@"adjustment state: %@  hasit: %@ adjusted: %@", MysticObjectTypeToString(type), MBOOL(hasit),MBOOL(adjusted));
    return hasit  ? MysticAdjustmentStateRendered : (adjusted ? MysticAdjustmentStateUnrendered : MysticAdjustmentStateNotAdjusted);
}
- (void) setAdjustmentsToRendered;
{
    [self setAdjustmentsToRendered:self.adjustments];
}
- (void) setAdjustmentsToRendered:(NSDictionary *)theAdjustments;
{
    theAdjustments = theAdjustments ? theAdjustments : self.adjustments;

    if(self.adjustColors.count)
    {
        NSMutableArray *ncs = [NSMutableArray arrayWithArray:self.adjustColors];
        
        for (NSDictionary *color in self.adjustColors) {
            NSMutableDictionary *c = [NSMutableDictionary dictionaryWithDictionary:color];
            [c setObject:@YES forKey:@"rendered"];
            [ncs replaceObjectAtIndex:[ncs indexOfObject:color] withObject:c];
        }
        self.adjustColors = ncs;
    }
    
    if(!self.renderedAdjustments)
    {
        self.renderedAdjustments = [NSMutableDictionary dictionaryWithDictionary:theAdjustments];
    }
    else
    {
        NSMutableArray *keys = [NSMutableArray arrayWithArray:self.renderedAdjustments[@"keys"]];
        for (NSString *k in theAdjustments[@"keys"]) {
            if(![keys containsObject:k]) [keys addObject:k];
            [self.renderedAdjustments setObject:theAdjustments[k] forKey:k];
        }
    }

    
}

- (NSDictionary *) unRenderedAdjustments;
{
    NSDictionary *adj = self.adjustments;
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableDictionary *nadj = [NSMutableDictionary dictionary];
    for (NSString *k in adj[@"keys"]) {
        if([self adjustmentState:[k intValue]] == MysticAdjustmentStateUnrendered)
        {
            [nadj setObject:adj[k] forKey:k];
            [keys addObject:k];
        }
    }
    [nadj setObject:[NSArray arrayWithArray:keys] forKey:@"keys"];
    return [NSDictionary dictionaryWithObjects:nadj.allValues forKeys:nadj.allKeys];
    
}
- (NSArray *) filterIgnoredAdjustmentsFrom:(NSArray *)adjs;
{
    if(!self.ignoreUnadjustedAdjustments) return adjs;
    NSMutableArray *atypesOrder = [NSMutableArray arrayWithArray:adjs];
    for (id k in adjs) {
        if([self hasAdjusted:[k integerValue]] || [self isRefreshingAdjustment:[k integerValue]]) continue;
        [atypesOrder removeObject:k];
    }
    return atypesOrder;
}
- (NSArray *) orderedAvailableAdjustmentTypes;
{
    NSArray *atypes = self.availableAdjustmentTypes;
//    NSMutableArray *at = [NSMutableArray arrayWithArray:atypes];
//    NSMutableArray *at2 = [NSMutableArray arrayWithArray:atypes];
    NSMutableArray *atypesOrder = [NSMutableArray array];
    for (id asettingKey in self.adjustOrder) {
        if(![atypes containsObject:asettingKey]) continue;
        [atypesOrder addObject:asettingKey];
    }
    return [self filterIgnoredAdjustmentsFrom:atypesOrder];
}
- (NSArray *) orderedAvailablePostAdjustmentTypes;
{
    NSArray *atypes = self.availablePostAdjustmentTypes;
//    NSMutableArray *at = [NSMutableArray arrayWithArray:atypes];
//    NSMutableArray *at2 = [NSMutableArray arrayWithArray:atypes];
    NSMutableArray *atypesOrder = [NSMutableArray array];
    for (id asettingKey in self.adjustOrder) {
        if(![atypes containsObject:asettingKey]) continue;
        [atypesOrder addObject:asettingKey];
    }
    return [self filterIgnoredAdjustmentsFrom:atypesOrder];
}
- (NSArray *) orderedAvailablePreAdjustmentTypes;
{
    NSArray *atypes = self.availablePreAdjustmentTypes;
//    NSMutableArray *at = [NSMutableArray arrayWithArray:atypes];
//    NSMutableArray *at2 = [NSMutableArray arrayWithArray:atypes];
    NSMutableArray *atypesOrder = [NSMutableArray array];
    for (id asettingKey in self.adjustOrder) {
        if(![atypes containsObject:asettingKey]) continue;
        [atypesOrder addObject:asettingKey];
    }
    return [self filterIgnoredAdjustmentsFrom:atypesOrder];
    
}
- (NSArray *) availableAdjustmentTypes;
{
    NSMutableArray *a = [NSMutableArray arrayWithArray:self.availablePreAdjustmentTypes];
    [a addObjectsFromArray:self.availablePostAdjustmentTypes];
    return a;
}
- (NSArray *) availablePreAdjustmentTypes;
{
    switch (self.type) {
        case MysticObjectTypeCustom:
        case MysticObjectTypeImage: return @[
                                             @(MysticSettingVibrance),
                                             @(MysticSettingExposure),
                                             @(MysticSettingHaze),
                                             @(MysticSettingShadowsHighlights),
                                             @(MysticSettingTemperature),
                                             @(MysticSettingBrightness),
                                             @(MysticSettingContrast),
                                             @(MysticSettingColorBalance),
                                             @(MysticSettingSaturation),
                                             @(MysticSettingGamma),
                                             @(MysticSettingLevels),
                                             @(MysticSettingSkin),
                                             ];
        case MysticObjectTypeFilter:
        case MysticObjectTypeSpecial: return @[];
        case MysticObjectTypeSetting:
            return @[@(MysticSettingVibrance),
                     @(MysticSettingExposure),
                     @(MysticSettingHaze),
                     @(MysticSettingShadows),
                     @(MysticSettingHighlights),
                     @(MysticSettingShadowsHighlights),
                     @(MysticSettingTemperature),
                     @(MysticSettingBrightness),
                     @(MysticSettingContrast),
                     @(MysticSettingColorBalance),
                     @(MysticSettingSaturation),
                     @(MysticSettingGamma),
                     @(MysticSettingLevels),
                     @(MysticSettingSkin),
                     @(MysticSettingHighlightIntensity),
                     @(MysticSettingShadowIntensity),
                     @(MysticSettingVignette),
                     @(MysticSettingAdjustColor),
                     @(MysticSettingGrain),

                     ];
            break;
            
        case MysticObjectTypeFrame: if(self.blendingType == MysticFilterTypeMask) return @[]; break;
        default: break;
    }
    return @[
             @(MysticSettingBrightness),
             @(MysticSettingContrast),
             @(MysticSettingLevels),
             @(MysticSettingHSBHue),
             @(MysticSettingVibrance),
             @(MysticSettingExposure),
             @(MysticSettingHaze),
             @(MysticSettingShadowsHighlights),
             @(MysticSettingTemperature),
             @(MysticSettingColorBalance),
             @(MysticSettingSaturation),
             @(MysticSettingGamma),
             @(MysticSettingSkin),
             
             ];
}
- (NSArray *) availablePostAdjustmentTypes;
{
    switch (self.type) {
        case MysticObjectTypeFilter:
        case MysticObjectTypeSpecial:
            return @[];
            
        case MysticObjectTypeSetting:
            return @[];
            break;
        case MysticObjectTypeFrame:
        {
            if(self.blendingType == MysticFilterTypeMask) return @[@(MysticSettingSaturation),
                                                                   @(MysticSettingBrightness),
                                                                   ];
            break;
        }
        default: break;
    }
    return @[];
}
- (BOOL) hasPreAdjustments; { return self.availablePreAdjustmentTypes.count > 0; }
- (BOOL) hasPostAdjustments; { return self.availablePostAdjustmentTypes.count > 0; }

- (void) setRefreshState:(MysticObjectType)refreshStateValue;
{
    MysticObjectType refreshState = [self refreshStateForState:refreshStateValue];
    
//    DLog(@"set refresh state: %@ -> %@", MysticObjectTypeToString(refreshStateValue), MysticObjectTypeToString(refreshState));
//    int i = 0;
//    
    
    if(self.refreshState == refreshState) return;
    [super setRefreshState:refreshState];
    [self setRefreshAdjustments:@(refreshState)];
    [self setTempInfo:[self valueForType:refreshState] key:MysticString(refreshState)];
    switch (refreshState) {
        case MysticSettingHighlightIntensity:
            if(self.highlightTintColor) [self setTempInfo:self.highlightTintColor key:MysticString(MysticSettingHighlightTintColor)];
            break;
        case MysticSettingShadowIntensity:
            if(self.shadowTintColor) [self setTempInfo:self.shadowTintColor key:MysticString(MysticSettingShadowTintColor)];
            break;
        default: break;
    }
}
- (NSArray *) refreshingAdjustments;
{
    return _refreshingAdjustmentsDict.allKeys;
}
- (void) setRefreshAdjustments:(id)value;
{
    if(!value) { [_refreshingAdjustmentsDict release],_refreshingAdjustmentsDict=nil; return; }
    NSArray *values = [value isKindOfClass:[NSArray class]] ? value : [NSArray arrayWithObject:value];
    if(!_refreshingAdjustmentsDict) _refreshingAdjustmentsDict = [[NSMutableDictionary alloc] init];
    else [_refreshingAdjustmentsDict removeAllObjects];
    
    for (id a in values) {
        if([a integerValue] == MysticSettingNone) continue;
#ifdef DEBUG
        if([a integerValue] == MysticSettingTest) continue;
#endif
        id v = [self valueForType:[a integerValue]];
        if(!v) { DLogError(@"No value for type: %@ %d", MysticObjectTypeToString([a intValue]), [a intValue]); continue; }
        [_refreshingAdjustmentsDict setObject:v forKey:[NSString stringWithFormat:@"%d", [a intValue]]]; }
}
- (void) addRefreshAdjustments:(id)value;
{
    if(!value) return;
    NSArray *values = [value isKindOfClass:[NSArray class]] ? value : [NSArray arrayWithObject:value];
    if(!_refreshingAdjustmentsDict) _refreshingAdjustmentsDict = [[NSMutableDictionary alloc] init];
    for (id a in values) [_refreshingAdjustmentsDict setObject:[self valueForType:[a integerValue]] forKey:a];
}
- (void) removeRefreshAdjustments:(id)value;
{
    if(!value || !_refreshingAdjustmentsDict) return;
    NSArray *values = [value isKindOfClass:[NSArray class]] ? value : [NSArray arrayWithObject:value];
    for (id k in values) [_refreshingAdjustmentsDict removeObjectForKey:[NSString stringWithFormat:@"%d", [k intValue]]];
}
- (BOOL) isRefreshingAdjustment:(MysticObjectType)value;
{
    if(self.refreshState == value) return YES;
    switch(value)
    {
        case MysticSettingHighlightTint:
        case MysticSettingShadowTint:
        case MysticSettingShadowTintColor:
        case MysticSettingHighlightTintColor:
        case MysticSettingHighlightIntensity:
        case MysticSettingShadowsHighlights:
        case MysticSettingShadowIntensity:
        case MysticSettingShadows:
        case MysticSettingHighlights:
        {
            switch (self.refreshState) {
                case MysticSettingHighlightTint:
                case MysticSettingShadowTint:
                case MysticSettingShadowTintColor:
                case MysticSettingHighlightTintColor:
                case MysticSettingHighlightIntensity:
                case MysticSettingShadowsHighlights:
                case MysticSettingShadowIntensity:
                case MysticSettingShadows:
                case MysticSettingHighlights: return YES;
                default: break;
            }
        }
        default: break;
    }
    return [_refreshingAdjustmentsDict objectForKey:[NSString stringWithFormat:@"%d", value]] != nil;
}
- (UIColor *) halftoneShadow; { return _halftoneShadow==nil ? UIColor.blackColor : _halftoneShadow; }
- (UIColor *) halftoneHighlight; { return _halftoneHighlight==nil ? UIColor.whiteColor : _halftoneHighlight; }
- (UIColor *) sketchShadow; { return _sketchShadow==nil ? UIColor.blackColor : _sketchShadow; }
- (UIColor *) sketchHighlight; { return _sketchHighlight==nil ? UIColor.whiteColor : _sketchHighlight; }

- (CGFloat) sphereRadius; { return _sphereRadius==MYSTIC_FLOAT_UNKNOWN ? ksphereRadius : _sphereRadius; }
- (CGFloat) sphereRefractiveIndex; { return _sphereRefractiveIndex==MYSTIC_FLOAT_UNKNOWN ? ksphereRefractiveIndex : _sphereRefractiveIndex; }
- (CGFloat) pixellatePixelWidth; { return _pixellatePixelWidth==MYSTIC_FLOAT_UNKNOWN ? kpixellatePixelWidth : _pixellatePixelWidth; }

- (CGFloat) halftonePixelWidth; { return _halftonePixelWidth==MYSTIC_FLOAT_UNKNOWN ? khalftonePixelWidth : _halftonePixelWidth; }
- (CGFloat) sketchStrength; { return _sketchStrength==MYSTIC_FLOAT_UNKNOWN ? ksketchStrength : _sketchStrength; }
- (CGFloat) sketchHeight; { return _sketchHeight==MYSTIC_FLOAT_UNKNOWN ? ksketchHeight : _sketchHeight; }
- (CGFloat) sketchWidth; { return _sketchWidth==MYSTIC_FLOAT_UNKNOWN ? ksketchWidth : _sketchWidth; }
- (CGFloat) toonThreshold; { return _toonThreshold==MYSTIC_FLOAT_UNKNOWN ? ktoonThreshold : _toonThreshold; }
- (CGFloat) buldgeRadius; { return _buldgeRadius==MYSTIC_FLOAT_UNKNOWN ? kbuldgeRadius : _buldgeRadius; }
- (CGFloat) buldgeScale; { return _buldgeScale==MYSTIC_FLOAT_UNKNOWN ? kbuldgeScale : _buldgeScale; }

- (CGFloat) toonLevels; { return _toonLevels==MYSTIC_FLOAT_UNKNOWN ? ktoonLevels : _toonLevels; }
- (CGFloat) toonHeight; { return _toonHeight==MYSTIC_FLOAT_UNKNOWN ? ktoonHeight : _toonHeight; }
- (CGFloat) toonWidth; { return _toonWidth==MYSTIC_FLOAT_UNKNOWN ? ktoonWidth : _toonWidth; }
- (CGFloat) swirlRadius; { return _swirlRadius==MYSTIC_FLOAT_UNKNOWN ? kswirlRadius : _swirlRadius; }
- (CGFloat) swirlAngle; { return _swirlAngle==MYSTIC_FLOAT_UNKNOWN ? kswirlAngle : _swirlAngle; }
- (NSInteger) posterizeLevels; { return _posterizeLevels==NSNotFound ? kposterizeLevels : _posterizeLevels; }
- (NSInteger) blurPasses; { return _blurPasses==NSNotFound ? kblurPasses : _blurPasses; }

- (CGFloat) pinchRadius; { return _pinchRadius==MYSTIC_FLOAT_UNKNOWN ? kpinchRadius : _pinchRadius; }
- (CGFloat) pinchScale; { return _pinchScale==MYSTIC_FLOAT_UNKNOWN ? kpinchScale : _pinchScale; }
- (CGFloat) tiltShiftBlurSizeInPixels; { return _tiltShiftBlurSizeInPixels==MYSTIC_FLOAT_UNKNOWN ? ktiltShiftBlurSizeInPixels : _tiltShiftBlurSizeInPixels; }
- (CGFloat) tiltShiftFallOff; { return _tiltShiftFallOff==MYSTIC_FLOAT_UNKNOWN ? ktiltShiftFallOff : _tiltShiftFallOff; }
- (CGFloat) tiltShiftBottom; { return _tiltShiftBottom==MYSTIC_FLOAT_UNKNOWN ? ktiltShiftBottom : _tiltShiftBottom; }
- (CGFloat) tiltShiftTop; { return _tiltShiftTop==MYSTIC_FLOAT_UNKNOWN ? ktiltShiftTop : _tiltShiftTop; }
- (CGFloat) unsharpBlurRadius; { return _unsharpBlurRadius==MYSTIC_FLOAT_UNKNOWN ? kunsharpBlurRadius : _unsharpBlurRadius; }
- (CGFloat) blurCircleAspectRatio; { return _blurCircleAspectRatio==MYSTIC_FLOAT_UNKNOWN ? kblurCircleAspectRatio : _blurCircleAspectRatio; }
- (CGFloat) blurCircleRadius; { return _blurCircleRadius==MYSTIC_FLOAT_UNKNOWN ? kblurCircleRadius : _blurCircleRadius; }
- (CGFloat) blurCircleExcludeSize; { return _blurCircleExcludeSize==MYSTIC_FLOAT_UNKNOWN ? kblurCircleExcludeSize : _blurCircleExcludeSize; }
- (CGFloat) blurCircleExcludeRadius; { return _blurCircleExcludeRadius==MYSTIC_FLOAT_UNKNOWN ? kblurCircleExcludeRadius : _blurCircleExcludeRadius; }
- (CGFloat) blurZoomSize; { return _blurZoomSize==MYSTIC_FLOAT_UNKNOWN ? kblurZoomSize : _blurZoomSize; }
- (CGFloat) blurMotionSize; { return _blurMotionSize==MYSTIC_FLOAT_UNKNOWN ? kblurMotionSize : _blurMotionSize; }
- (CGFloat) blurMotionAngle; { return _blurMotionAngle==MYSTIC_FLOAT_UNKNOWN ? kblurMotionAngle : _blurMotionAngle; }
- (CGFloat) blurRadius; { return _blurRadius==MYSTIC_FLOAT_UNKNOWN ? kblurRadius : _blurRadius; }
- (CGFloat) blurRadiusFractionWidth; { return _blurRadiusFractionWidth==MYSTIC_FLOAT_UNKNOWN ? kblurRadiusFractionWidth : _blurRadiusFractionWidth; }
- (CGFloat) blurRadiusFractionHeight; { return _blurRadiusFractionHeight==MYSTIC_FLOAT_UNKNOWN ? kblurRadiusFractionHeight : _blurRadiusFractionHeight; }


- (BOOL) isRefreshingAdjustments:(id)value;
{
    if(!value || !_refreshingAdjustmentsDict) return NO;
    NSArray *values = [value isKindOfClass:[NSArray class]] ? value : [NSArray arrayWithObject:value];
    if(values.count == 1 && [values.firstObject integerValue] == self.refreshState) return YES;
    if(values.count == 0) return NO;
    for (id k in values) if(![self isRefreshingAdjustment:(MysticObjectType)[k integerValue]]) return NO;
    return YES;
}

#pragma mark - Has Rendered
- (BOOL) hasRendered;
{
    if([super hasRendered] && [self hasUnRenderedAdjustments]) return NO;
    return [super hasRendered];
}
- (void) setHasRendered:(BOOL)hasRendered;
{
    BOOL beforeValue = [super hasRendered];
    [super setHasRendered:hasRendered];
    if(hasRendered && !beforeValue)
    {
        NSDictionary *adj = [NSDictionary dictionaryWithDictionary:self.adjustments];
        [self setAdjustmentsToRendered];
        [self resetAdjustments];
    }
}


#pragma mark - Vignette
- (UIColor *) vignetteColor;
{
    return _vignetteColor ? _vignetteColor : [UIColor.blackColor alpha:0];
}
- (void) setVignetteValue:(float)value;
{
    CGFloat start = value > 0.5 ? 0.5 - ((value-0.5)*(0.5)) : kVignetteStart;
    CGFloat end = 1.0- (value *(0.3));
    if(value == 0)
    {
        start = 1.0;
        end = 1.0;
    }
    BOOL refreshImage = !(self.vignetteStart == start && self.vignetteEnd == end);
    
    if(refreshImage) {
        self.vignetteStart = start;
        self.vignetteEnd = end;
    }
    
    _vignetteValue = value;
}
- (BOOL) hasCustomShader;
{
    return self.attributes & MysticAttrShader && (isM(self.info[@"shader"]));
}

- (id) customShaderString;
{
    return self.hasCustomShader ? self.info[@"shader"] : nil;
}

- (NSDictionary *) customShader;
{
    id shd = self.customShaderString;
    if([shd isKindOfClass:[NSString class]]) return @{@"line": shd};
    else if([shd isKindOfClass:[NSDictionary class]]) return shd;
    return nil;
}



#pragma mark - Blending

- (void) setBlended:(BOOL)value;
{
    _blended = value;
    __userBlended = value ? 1 : 0;
}
- (BOOL) isBlended;
{
    return (__userBlended != NSNotFound && self.blended) || self.presetBlending ? YES : NO;
}

- (MysticFilterType) normalBlendingType;
{
    if(self.blendingModeStr)
    {
        MysticFilterType rfilterType = MysticFilterTypeFromString(self.blendingModeStr);
        return rfilterType;
    }
    
    if(self.hasAlphaChannel)
    {
        
        if(self.hasAlphaMask)
        {
            
            return MysticFilterTypeBlendAlphaMask;
        }
        
        return MysticFilterTypeBlendAlpha;
        
    }
    return MysticFilterTypeBlendNormal;
}

- (NSString *) blendingModeStr;
{
    return [self.info objectForKey:@"blend"];
    
}

- (void) setBlendingType:(MysticFilterType)value;
{
    _blendingType = value;
    __blendingMode = value;
}
- (MysticFilterType) adjustedBlendingType;
{
    if(_blendingType != MysticFilterTypeUnknown) return _blendingType;
    if(__blendingMode != MysticFilterTypeUnknown) return __blendingMode;
    return MysticFilterTypeUnknown;
}
- (MysticFilterType) blendingType;
{
    if(_blendingType != MysticFilterTypeUnknown) return _blendingType;
    if(__blendingMode != MysticFilterTypeUnknown) return __blendingMode;
    return MysticFilterTypeFromString(self.blending);
}
- (void) resetBlending;
{
    _blendingType = MysticFilterTypeUnknown;
    __blendingMode = MysticFilterTypeUnknown;
    self.blendingMode = nil;
}
- (NSString *) blending;
{
    NSString *resultMode = self.blendingMode ? self.blendingMode : self.blendingModeStr;
    
    if(self.inverted)
    {
        MysticFilterType rfilterType = MysticFilterTypeFromString(resultMode);
        
        switch (rfilterType) {
            case MysticFilterTypeBlendScreen:
                resultMode = @"multiply";
                break;
            case MysticFilterTypeBlendMultiply:
                resultMode = @"screen";
                break;
                
            default: break;
        }
    }
    
    return resultMode;
    
}

- (void) setBlending:(NSString *)value;
{
    self.blendingMode = value;
}

- (NSArray *) blendingModeOptions;
{
    NSArray *controlObjs = [Mystic core].blendingModes;
    for (PackPotionOptionBlend *o in controlObjs)
    {
        o.targetOption = self;
    }
    
    NSMutableArray *controls = [NSMutableArray array];
    
    switch (self.refreshState) {
        case MysticSettingVignetteBlending:
            
            break;
            
        default:
            break;
    }
    if(self.allowNormalBlending)
    {
        NSDictionary *_noInfo = @{@"name": self.normalBlendingTitle, @"blend":[NSNumber numberWithInteger:self.normalBlendingType]};
        PackPotionOptionBlend *noBlendOption = (PackPotionOptionBlend *)[PackPotionOptionBlend optionWithName:self.normalBlendingTitle info:_noInfo];
        noBlendOption.targetOption = self;
        noBlendOption.isDefaultChoice = YES;
        [controls addObject:noBlendOption];
    }
    
    if(self.allowNoBlending)
    {
        NSDictionary *_noInfo = @{@"name": @"None", @"blend":[NSNumber numberWithInteger:MysticFilterTypeBlendNormal]};
        PackPotionOptionBlend *noBlendOption = (PackPotionOptionBlend *)[PackPotionOptionBlend optionWithName:@"None" info:_noInfo];
        noBlendOption.targetOption = self;
        [controls addObject:noBlendOption];
    }
    
    
    
    
    [controls addObjectsFromArray:controlObjs];
    return controls;
}
- (BOOL) hasGrain; { return [self hasAdjusted:MysticSettingGrain]; }
- (BOOL) smoothing;
{
    return _smoothing;
}

- (BOOL) shouldInvert;
{
    BOOL i = self.inverted;
    MysticFilterType rfilterType = MysticFilterTypeFromString(self.blending);
    switch (rfilterType) {
        case MysticFilterTypeBlendCutout:
        {
            MysticFilterType rfilterType2 = MysticFilterTypeFromString(self.blendingModeStr);
            switch (rfilterType2) {
                case MysticFilterTypeBlendScreen:
                    i = !i;
                    break;
                    
                default: break;
            }
            
            break;
        }
        case MysticFilterTypeBlendAdd:
            
            //i = !i;
            break;
            
        case MysticFilterTypeMask:
            i = NO;
            break;
            
        default: break;
    }
    return i;
}

- (PackPotionOption *) activeOption;
{
    //    if(self.targetOption) return self.targetOption;
    
    return [[MysticOptions current] activeOption:self];
}

- (UIColor *) chromaColor;
{
    return _chromaColor ? _chromaColor : [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
}
- (float) hsbHue;
{
    return self.hsb.hue;
}
- (float) hsbBrightness;
{
    return self.hsb.brightness;
}
- (float) hsbSaturation;
{
    return self.hsb.saturation;
}
- (float) hazeSlopeValue;
{
    return _hazeSlope;
}
- (float) hazeSlope;
{
    if(_hazeSlope == MYSTIC_FLOAT_UNKNOWN) return self.haze*-1;
    return _hazeSlope;
}
- (float) intensity;
{
    return _intensity == 1234567.0f ? self.presetIntensity : _intensity;
}
- (float) midLevelsValue;
{
    
    float db = (self.midLevels - self.blackLevels)/(self.whiteLevels - self.blackLevels);
    float d = self.blackLevels + ((self.whiteLevels - self.blackLevels) * db);
    
    float d2 = (MAX(0, d - 0.5))/0.5;
    float d3 = (0.5 - (MIN(0.5, d)))/0.5;
    float d4 = 1;
    if(d >= 0.5)
    {
        self.midLevelsValueFixed = d2;
        d4 = 1.0 - (1.0 * d2);
    }
    else
    {
        self.midLevelsValueFixed = d3;
        d4 = [MysticUI easeInCubicStep:(999*d3) start:1.0 end:8.99 totalSteps:999] + 0;
    }
    return d4;
}
- (float) midLevelsValueGreen;
{
    
    float db = (self.midLevelsGreen - self.blackLevelsGreen)/(self.whiteLevelsGreen - self.blackLevelsGreen);
    float d = self.blackLevelsGreen + ((self.whiteLevelsGreen - self.blackLevelsGreen) * db);
    
    float d2 = (MAX(0, d - 0.5))/0.5;
    float d3 = (0.5 - (MIN(0.5, d)))/0.5;
    float d4 = 1;
    if(d >= 0.5)
    {
        d4 = 1.0 - (1.0 * d2);
    }
    else
    {
        
        self.midLevelsValueFixed = d3;
        d4 = [MysticUI easeInCubicStep:(999*d3) start:1.0 end:8.99 totalSteps:999] + 0;
        
        
    }
    return d4;
}
- (float) midLevelsValueBlue;
{
    
    float db = (self.midLevelsBlue - self.blackLevelsBlue)/(self.whiteLevelsBlue - self.blackLevelsBlue);
    float d = self.blackLevelsBlue + ((self.whiteLevelsBlue - self.blackLevelsBlue) * db);
    
    float d2 = (MAX(0, d - 0.5))/0.5;
    float d3 = (0.5 - (MIN(0.5, d)))/0.5;
    float d4 = 1;
    if(d >= 0.5)
    {
        d4 = 1.0 - (1.0 * d2);
    }
    else
    {
        self.midLevelsValueFixed = d3;
        d4 = [MysticUI easeInCubicStep:(999*d3) start:1.0 end:8.99 totalSteps:999] + 0;
    }
    return d4;
}

- (float) midLevelsValueRed;
{
    
    float db = (self.midLevelsRed - self.blackLevelsRed)/(self.whiteLevelsRed - self.blackLevelsRed);
    float d = self.blackLevelsRed + ((self.whiteLevelsRed - self.blackLevelsRed) * db);
    
    float d2 = (MAX(0, d - 0.5))/0.5;
    float d3 = (0.5 - (MIN(0.5, d)))/0.5;
    float d4 = 1;
    if(d >= 0.5)
    {
        d4 = 1.0 - (1.0 * d2);
    }
    else
    {
        self.midLevelsValueFixed = d3;
        d4 = [MysticUI easeInCubicStep:(999*d3) start:1.0 end:8.99 totalSteps:999] + 0;
    }
    return d4;
}
- (NSInteger) shaderIndex;
{
    if(self.shaderIndexPath.stackIndex != -1) return self.shaderIndexPath.stackIndex;
    return [super shaderIndex];
}




- (BOOL) allowColorReplacement;
{
    MysticFilterType nt = self.normalBlendingType;
    switch (nt) {
        case MysticFilterTypeBlendMaskScreen:
        case MysticFilterTypeBlendMaskScreenNoFill:
        case MysticFilterTypeBlendMaskMultiply:
        case MysticFilterTypeBlendMaskMultiplyNoFill: return YES;
        default: break;
    }
    return NO;
    
}
- (void) removeOption;
{
    
}
- (id) setUserChoice;
{
    return [self setUserChoice:YES finished:nil];
}
- (id) setUserChoice:(BOOL)force finished:(MysticBlock)finished;
{
    
    if(!self.isRenderableOption) return self;
    self.level = [self setUserChoiceLevel];
    self.hasChanged = YES;
    self.shouldRender = YES;
    if([MysticOptions current])
    {
        PackPotionOption *lastOption = [[MysticOptions current] lastPickedOptionOfType:self.type];
        if(lastOption && self.shouldApplyAdjustmentsFromSimilarOption) [self applyPreviousAdjustmentsFrom:lastOption];
        [[MysticOptions current] pick:self];
    }
    [super setUserChoice];

    self.blendingMode = nil;
    [[MysticOptions current] optionsOrderedByLevel];

    return self;
    
}

- (NSInteger) setUserChoiceLevel;
{
    NSInteger returnLevel = MysticLayerLevelAuto;
    if(![MysticUser user].liveState)
    {
        NSInteger blendedLevel = NSNotFound;
        NSInteger paddedLevel = NSNotFound;
        NSInteger ___nextLevel = [MysticOptions current] ? [[MysticOptions current] nextLevel:self] : NSNotFound;
        NSInteger __nextLevel = ___nextLevel == NSNotFound ? MysticLayerLevelAuto : ___nextLevel;
        NSInteger __aLvl = __nextLevel == MysticLayerLevelAuto ? self.smartLevel : __nextLevel;
        
        
        PackPotionOption *option = [[MysticOptions current] similarOption:self];
        if(!MysticObjectHasAutoLayer(self))
        {
            
            NSInteger optionLevel = MysticLayerLevelAuto;
            if(self.optionSlotKey && option.optionSlotKey && [option.optionSlotKey isEqualToString:self.optionSlotKey])
            {
                return option.level;
            }
            else
            {
                optionLevel = option.level +1;
            }
            NSInteger _returnLevel = __nextLevel;
            NSInteger _r = _returnLevel;
            
            _returnLevel = _returnLevel <= 0 || _returnLevel == MysticLayerLevelAuto ? [MysticOptions current].count + 1 : _returnLevel;
            _r = _returnLevel;
            _returnLevel = [MysticOptions current].count + 1;
            _returnLevel = MAX([[MysticOptions current] highestLevel] +1,_returnLevel);
            
            return _returnLevel;
            
        }
        else returnLevel = self.autoLayerLevel;
        
        
    }
    
        DLogError(@"set user choice: %@:%@ level: %d", MysticString(self.type), self.name, (int)returnLevel);
    
    return returnLevel;
}
- (NSInteger) autoLayerLevel;
{
    NSInteger returnLevel = MysticLayerLevelAuto;
    if(![MysticUser user].liveState)
    {
        NSInteger blendedLevel = NSNotFound;
        NSInteger paddedLevel = NSNotFound;
        NSInteger ___nextLevel = [MysticOptions current] ? [[MysticOptions current] nextLevel:self] : NSNotFound;
        NSInteger __nextLevel = ___nextLevel == NSNotFound ? MysticLayerLevelAuto : ___nextLevel;
        NSInteger __aLvl = __nextLevel == MysticLayerLevelAuto ? self.smartLevel : __nextLevel;
        
        
        PackPotionOption *option = [[MysticOptions current] similarOption:self];
        //        if(option && ![option isEqual:self])
        //        {
        //            __aLvl = option.level;
        //
        //        }
        //        else
        //        {
        
        if(self.levelRules & MysticLayerLevelRuleTop)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelTop : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelTop ? MysticLayerLevelTop : __nextLevel;
            
            paddedLevel = MAX(__nextLevel, MysticLayerLevelTop);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelTop);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            //                LevelLog(@"MysticLayerLevelRuleTop: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
            
        }
        else if(self.levelRules & MysticLayerLevelRuleStaysHighest)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelStaysHighest : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelStaysHighest ? MysticLayerLevelStaysHighest : __nextLevel;
            
            paddedLevel = MAX(__nextLevel, MysticLayerLevelStaysHighest);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelStaysHighest);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            LevelLog(@"MysticLayerLevelRuleStaysHighest: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
            
        }
        else if(self.levelRules & MysticLayerLevelRuleStaysBelowHighest)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelStaysBelowHighest : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelStaysBelowHighest ? MysticLayerLevelStaysBelowHighest : __nextLevel;
            paddedLevel = MAX(__nextLevel, MysticLayerLevelStaysBelowHighest);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelStaysBelowHighest);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            LevelLog(@"MysticLayerLevelStaysBelowHighest: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
            
        }
        else if(self.levelRules & MysticLayerLevelRuleAlwaysHighestUnlessMoved)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelHighestUnlessMoved : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelHighestUnlessMoved ? MysticLayerLevelHighestUnlessMoved : __nextLevel;
            paddedLevel = MAX(__nextLevel, MysticLayerLevelHighestUnlessMoved);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelHighestUnlessMoved);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            LevelLog(@"MysticLayerLevelRuleAlwaysHighestUnlessMoved: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
            
        }
        else if(self.levelRules & MysticLayerLevelRuleAlwaysHighest)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelHighest : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelHighest ? MysticLayerLevelHighest : __nextLevel;
            paddedLevel = MAX(__nextLevel, MysticLayerLevelHighest);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelHighest);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            LevelLog(@"MysticLayerLevelRuleAlwaysHighest: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
            
        }
        else if(self.levelRules & MysticLayerLevelRuleAlwaysOnTop)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelAlwaysTop : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelHighest ? MysticLayerLevelAlwaysTop : __nextLevel;
            
            paddedLevel = MIN(__nextLevel, MysticLayerLevelAlwaysTop);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelAlwaysTop);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            
            LevelLog(@"MysticLayerLevelRuleAlwaysOnTop: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
        }
        else if(self.levelRules & MysticLayerLevelRuleAlwaysHighestBelowTop)
        {
            blendedLevel  = __nextLevel == MysticLayerLevelAuto || __nextLevel == NSNotFound ? MysticLayerLevelAlwaysTop : __nextLevel;
            __nextLevel = __nextLevel >= MysticLayerLevelAboveSettings ? MysticLayerLevelAboveSettings+1 : __nextLevel;
            
            paddedLevel = MIN(__nextLevel, MysticLayerLevelAboveSettings);
            blendedLevel = MIN(blendedLevel, MysticLayerLevelAboveSettings);
            
            __aLvl = MAX(blendedLevel, paddedLevel);
            
            LevelLog(@"MysticLayerLevelRuleAlwaysOnTop: %@: Blended: %d  |  Next: %d  |  Padded: %d  | Auto: %d", MyString(self.type), blendedLevel, __nextLevel, paddedLevel, __aLvl);
            
        }
        else
        {
            
            if(self.levelRules & MysticLayerLevelRuleAlwaysAbovePic)
            {
                blendedLevel = __aLvl > MysticLayerLevelImage ? __aLvl : MysticLayerLevelImage + 1;
                __aLvl = MAX(blendedLevel, __aLvl);
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -1);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysAbovePic: %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
            }
            if(self.levelRules & MysticLayerLevelRuleAlwaysBelowBlended)
            {
                NSInteger blendedLevel = NSIntegerMax;
                for (PackPotionOption *o in [MysticOptions current]) {
                    if(o.blended)
                    {
                        blendedLevel = MIN(o.level, blendedLevel);
                    }
                }
                
                __aLvl = (blendedLevel == NSIntegerMin) ? MysticLayerLevelAboveImage : blendedLevel - 1;
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -1);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysBelowBlended: %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
                
            }
            if(self.levelRules & MysticLayerLevelRuleAlwaysAboveBlended)
            {
                NSInteger blendedLevel = NSIntegerMin;
                for (PackPotionOption *o in [MysticOptions current]) {
                    if(o.blended)
                    {
                        blendedLevel = MAX(o.level, blendedLevel);
                    }
                }
                __aLvl = (blendedLevel == NSIntegerMin) ? MysticLayerLevelAboveImage : blendedLevel + 1;
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -1);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysAboveBlended:  %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
            }
            if(self.levelRules & MysticLayerLevelRuleAlwaysAboveSettings)
            {
                NSInteger blendedLevel = NSIntegerMin;
                for (PackPotionOption *o in [MysticOptions current]) {
                    if(o.type == MysticObjectTypeSetting)
                    {
                        blendedLevel = MAX(o.level, blendedLevel);
                    }
                }
                __aLvl = (blendedLevel == NSIntegerMin) ? MysticLayerLevelAboveSettings : blendedLevel + 1;
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -1);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysAboveSettings:  %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
                
            }
            if(self.levelRules & MysticLayerLevelRuleAlwaysBelowTop)
            {
                
                NSInteger blendedLevel = NSIntegerMax;
                for (PackPotionOption *o in [MysticOptions current]) {
                    if(o.levelRules & MysticLayerLevelRuleAlwaysOnTop || o.levelRules & MysticLayerLevelRuleAlwaysHighest || o.levelRules & MysticLayerLevelRuleAlwaysHighestBelowTop)
                    {
                        blendedLevel = MIN(o.level, blendedLevel);
                    }
                }
                
                __aLvl = (blendedLevel == NSIntegerMax) ? __aLvl : blendedLevel - 2;
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -2);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysBelowTop:  %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
            }
            if(self.levelRules & MysticLayerLevelRuleAlwaysHighestBelowTop)
            {
                
                NSInteger blendedLevel = NSIntegerMax;
                for (PackPotionOption *o in [MysticOptions current]) {
                    if(o.levelRules & MysticLayerLevelRuleAlwaysOnTop || o.levelRules & MysticLayerLevelRuleAlwaysHighest)
                    {
                        blendedLevel = MIN(o.level, blendedLevel);
                    }
                }
                
                __aLvl = (blendedLevel == NSIntegerMax) ? __aLvl : blendedLevel - 1;
                __aLvl = MIN(__aLvl, MysticLayerLevelAlwaysTop -1);
                
                LevelLog(@"next level MysticLayerLevelRuleAlwaysHighestBelowTop:  %@: %d -> %d", MyString(self.type), blendedLevel, __aLvl);
                
            }
        }
        //        }
        returnLevel = __aLvl == NSNotFound  ? MysticLayerLevelAuto : __aLvl;
        
    }
    
    return returnLevel;
}

- (NSString *) backgroundColorVec4Str;
{
    return [NSString stringWithFormat:@"vec4(%2.1f, %2.1f, %2.1f, %2.1f)", self.backgroundColor.red, self.backgroundColor.green, self.backgroundColor.blue, self.backgroundColor.alpha];
}
- (UIColor *) maskBackgroundColor;
{
    return self.backgroundColor;
}
- (UIColor *) backgroundColor
{
    UIColor *c = _backgroundColor ? _backgroundColor :  [self color:MysticOptionColorTypeBackground];
    if(!c && [self.info objectForKey:@"background-color"])
    {
        c = [UIColor string:[self.info objectForKey:@"background-color"]];
    }
    
    
    if(!c) return nil;
    return !self.inverted ? c : [c invertedColor];
}

- (UIColor *) transformBackgroundColor;
{
    return self.backgroundColor;
}

- (UIColor *) realBackgroundColor
{
    if(self.layerImageType == MysticImageTypePNG) return [UIColor clearColor];
    UIColor *c = _backgroundColor;
    if(!c && [self.info objectForKey:@"background-color"])
    {
        c = [UIColor string:[self.info objectForKey:@"background-color"]];
    }
    if(!c) return nil;
    return c;
}

- (UIColor *) originalForegroundColor;
{
    if(self.layerImageType == MysticImageTypePNG) return [UIColor clearColor];
    UIColor *c = _foregroundColor;
    if(!c && [self.info objectForKey:@"color"])
    {
        c = [UIColor string:[self.info objectForKey:@"color"]];
    }
    if(!c) return nil;
    return c;
}

- (UIColor *) foregroundColorNonInverted;
{
    UIColor *c = _foregroundColor ? _foregroundColor : [self color:MysticOptionColorTypeForeground];
    if(!c && [self.info objectForKey:@"color"])
    {
        c = [UIColor string:[self.info objectForKey:@"color"]];
    }
    
    if(!c) return nil;
    return c;
}

- (UIColor *) foregroundColor
{
    UIColor *c = _foregroundColor ? _foregroundColor : [self color:MysticOptionColorTypeForeground];
    if(!c && [self.info objectForKey:@"color"])
    {
        c = [UIColor string:[self.info objectForKey:@"color"]];
    }
    
    if(!c) return nil;
    return !self.inverted ? c : [c invertedColor];
}

- (MysticColorType) foregroundColorType;
{
    return [self colorType:MysticOptionColorTypeForeground];
}
- (MysticColorType) backgroundColorType;
{
    return [self colorType:MysticOptionColorTypeBackground];
}
- (void) setBackgroundColorType:(MysticColorType)newvalue;
{
    [self setColorType:MysticOptionColorTypeBackground color:@(newvalue)];
}
- (void) setForegroundColorType:(MysticColorType)newvalue;
{
    [self setColorType:MysticOptionColorTypeForeground color:@(newvalue)];
}
- (UIColor *) color:(MysticOptionColorType)ctype;
{
    switch (ctype) {
        case MysticOptionColorTypeForeground:
            if(_foregroundColor) return _foregroundColor;
            break;
        case MysticOptionColorTypeBackground:
            if(_backgroundColor) return _backgroundColor;
            break;
        default:break;
    }
    NSInteger t = NSNotFound;
    NSNumber *cvalue = [self.colorTypes objectForKey:[NSString stringWithFormat:@"%d", ctype]];
    if(cvalue) return [MysticColor colorWithType:(MysticColorType)[cvalue integerValue]];
    if(t == NSNotFound && [self.info objectForKey:@"color"] && ctype == MysticOptionColorTypeForeground)
        return [UIColor string:[self.info objectForKey:@"color"]];
    return nil;
}
- (BOOL) hasUserSelectedColorOfOptionType:(MysticOptionColorType)ctype;
{
    switch (ctype) {
        case MysticOptionColorTypeForeground:
            
            if(_foregroundColor) return YES;
            break;
        case MysticOptionColorTypeBackground:
            if(_backgroundColor) return YES;
            break;
            
        default: break;
    }
    
    MysticColorType c = [self colorTypeValue:ctype];
    BOOL autoC = (c == MysticColorTypeAuto || c == MysticColorTypeUnknown) ? YES : NO;
    
    return !autoC;
}
- (BOOL) hasForegroundColor;
{
    if(_foregroundColor) return YES;
    return NO;
}
- (MysticColorType) colorType:(MysticOptionColorType)ctype;
{
    return [self colorTypeValue:ctype];
}
- (MysticColorType) colorTypeValue:(MysticOptionColorType)ctype;
{
    NSNumber *cvalue = [self.colorTypes objectForKey:[NSString stringWithFormat:@"%d", ctype]];
    if(cvalue)
    {
        return [cvalue integerValue];
    }
    return MysticColorTypeAuto;
}
- (void) setColorType:(MysticOptionColorType)optType color:(id)color;
{
    
    switch (optType) {
        case MysticOptionColorTypeBackground:
            if(_backgroundColor) [_backgroundColor release], _backgroundColor=nil;
            if([color isKindOfClass:[UIColor class]]) _backgroundColor = [color retain];
            break;
        case MysticOptionColorTypeForeground:
            
            if(_foregroundColor) [_foregroundColor release], _foregroundColor=nil;
            if([color isKindOfClass:[UIColor class]]) _foregroundColor = [color retain];
            
            break;
        case MysticOptionColorTypeChromaKey:
            if(_chromaColor) [_chromaColor release], _chromaColor=nil;
            if([color isKindOfClass:[UIColor class]]) _chromaColor = [color retain];
            
            break;
        default: break;
    }
    
    
    NSString *colorTypeKey = [NSString stringWithFormat:@"%d", optType];
    if([color isKindOfClass:[NSNumber class]])
    {
        MysticColorType colorType = (MysticColorType)[color integerValue];
        switch (colorType)
        {
            case MysticColorTypeAuto:
            {
                [self.colorTypes removeObjectForKey:colorTypeKey];
                break;
            }
            default:
            {
                [self.colorTypes setObject:color forKey:colorTypeKey];
                break;
            }
        }
    }
    self.hasChanged = YES;
    if([MysticOptions current].filters.filter) [self setupFilter:[MysticOptions current].filters.filter];
    
}

- (void) setIsTransforming:(BOOL)value;
{
    if(_isTransforming && !value)
    {
        [super setRefreshState:MysticObjectTypeUnknown];
        [self setRefreshAdjustments:nil];
    }
    _isTransforming = value;
    self.hasChanged = value;
}
- (void) setIsPreviewOption:(BOOL)isPreviewOption
{
    _isPreviewOption = isPreviewOption;
    
}
- (void) setIgnoreRender:(BOOL)ignoreRender
{
    _ignoreRender = ignoreRender;
    PackPotionOption *_confirmedOption = [UserPotion confirmedOptionForType:self.type] ;
    if(_confirmedOption && _confirmedOption != self && [self.optionSlotKey isEqualToString:_confirmedOption.optionSlotKey])
    {
        _confirmedOption.ignoreRender = ignoreRender;
    };
    
    
    
}

- (void) confirmCancel;
{
    [super confirmCancel];
    
    BOOL success ;
    NSError *error;
    @try
    {
        
        if(self.resourcePaths)
        {
            for (NSString *filePathKey in [self.resourcePaths allKeys]) {
                NSString *p = [self.resourcePaths objectForKey:filePathKey];
                [[NSFileManager defaultManager] removeItemAtPath:p error:&error];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR - MysticConfigManager (clearConfigFiles): %@", [error description]);
        success = NO;
    }
    
    
    NSInteger l = [[MysticCacheImage layerCache] removeImagesForOption:self];
    
    self.ignoreRender = YES;
}
- (NSString *)folderName;
{
    return [self.info objectForKey:@"folder"];
}

- (NSString *)messageLink;
{
    return [self.info objectForKey:@"message_link"];
}

- (NSString *)tweet;
{
    return [self.info objectForKey:@"twitter"];
}

- (NSString *)emailSubject;
{
    return [self.info objectForKey:@"email_subject"];
}

- (NSString *)emailTo;
{
    return [self.info objectForKey:@"email_to"];
}

- (NSString *)emailCC;
{
    return [self.info objectForKey:@"email_cc"];
}

- (NSString *)emailBCC;
{
    return [self.info objectForKey:@"email_bcc"];
}

- (NSString *)emailMessage;
{
    return [self.info objectForKey:@"email_message"];
}

- (NSString *)pinterest;
{
    return [self.info objectForKey:@"pinterest"];
}

- (BOOL)isHTMLEmail;
{
    return [[self.info objectForKey:@"email_html"] boolValue];
}


- (NSString *)facebook;
{
    return [self.info objectForKey:@"facebook"];
}

- (BOOL) hasFlip;
{
    return self.flipVertical || self.flipHorizontal;
}

- (BOOL) belongsToPack:(MysticPack *)pack;
{
    return pack ? [self hasTag:pack.name] : NO;
}
- (BOOL)hasTag:(NSString *)tag;
{
    if(self.cancelsEffect) return YES;
    if(![self.info objectForKey:@"tags"] || ![[self.info objectForKey:@"tags"] isKindOfClass:[NSDictionary class]] || ![[[self.info objectForKey:@"tags"] allValues] count]) return NO;
    NSDictionary *tags = [self.info objectForKey:@"tags"];
    return [tags objectForKey:tag] ? YES : NO;
}



- (void) layerImage:(MysticBlockImage)layerImageFinished;
{
    
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.imageURLString] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if(!finished) return;
        
        if(layerImageFinished)
        {
            layerImageFinished(image);
        }
    }];
}
- (BOOL) hasTextureCoordinate;
{
    switch (self.blendingType) {
        case MysticFilterTypeLookup: return NO;
        default: break;
    }
    return YES;
}
- (UIEdgeInsets) stretchingInsets;
{
    UIEdgeInsets i = UIEdgeInsetsZero;
    NSString *si = [self.info objectForKey:@"stretch_insets"];
    if(si)
    {
        
        NSArray *sia = [si componentsSeparatedByString:@","];
        
        CGFloat top = [[sia objectAtIndex:1] floatValue];
        CGFloat left = [[sia objectAtIndex:0] floatValue];
        CGFloat width = [[sia objectAtIndex:2] floatValue];
        CGFloat height = [[sia objectAtIndex:3] floatValue];
        
        if(top == 0 && left == 0 && width == 0 && height == 0)
        {
            return i;
        }
        
        i = UIEdgeInsetsMake(top, left, 1.0-(top + height), 1.0 - (left + width));
        
        
    }
    return i;
}
- (BOOL) hasAlphaChannel;
{
    MysticImageType __imageType = self.layerImageType;
    BOOL useAlpha = __imageType == MysticImageTypePNG || __imageType == MysticImageTypeJPNG;
    return useAlpha;
}

- (UIImage *) cachedImageForName:(NSString *)cachedTag size:(CGSize)renderSize level:(NSInteger)level type:(MysticImageType)imageType cacheType:(MysticCacheType)cacheType;
{
    
    NSDictionary *theOpts = @{
                              
                              MysticCacheImageKeyKeyTag: cachedTag,
                              MysticCacheImageKeyKeyType: @(imageType),
                              MysticCacheImageKeyKeyCache: @(cacheType),
                              MysticCacheImageKeyKeyOption: self,
                              MysticCacheImageKeyKeyPrefix: [MysticObjectTypeKey(self.type) stringByAppendingString:@"__"],
                              };
    
    return [[MysticCacheImage layerCache] imageForOptions:[MysticCacheImageKey options:theOpts]];
    
    
}
- (void) setAdjustedRect:(CGRect)adjustedRect;
{
    _adjustedRect = adjustedRect;
    if(!self.hasSetAdjustmentTransformRect) self.hasSetAdjustmentTransformRect = YES;
}

- (int) saveCachedImages:(MysticBlock)finished;
{
    return [[MysticCacheImage layerCache] saveImagesForOption:self finished:finished];
    
}

- (UIImage *) imageForSize:(CGSize)renderSize download:(BOOL)shouldDownload;
{
    MysticRenderOptions s=MysticRenderOptionsAuto;
    if(CGSizeGreater(renderSize, self.layerImageSize)) s=MysticRenderOptionsOriginal;
    if(s & MysticRenderOptionsAuto  && CGSizeGreater(renderSize, [UserPotion potion].previewSize)) s=MysticRenderOptionsSource;
    if(s & MysticRenderOptionsAuto && CGSizeGreater(renderSize, (CGSize){250, 250})) s=MysticRenderOptionsPreview;
    if(s & MysticRenderOptionsAuto) s=MysticRenderOptionsThumb;
    return [self imageForSettings:s size:renderSize];
}
#pragma mark - Stretch Mode
- (void) setStretchModeSetting:(MysticObjectType)sm;
{
    switch (sm) {
        case MysticSettingStretchAspectFit: self.stretchMode = MysticStretchModeAspectFit; break;
        case MysticSettingStretchAspectFill: self.stretchMode = MysticStretchModeAspectFill; break;
        case MysticSettingStretchFill: self.stretchMode = MysticStretchModeFill; break;
        case MysticSettingStretchNone: self.stretchMode = MysticStretchModeNone; break;
        case MysticSettingStretch:
        default: self.stretchMode = MysticStretchModeAuto; break;
    }
    self.originalTransformRect = MysticDefaultTransformRect;
    CGRect b = self.transformRectInitial;
    CGRect n = b;
    CGRect t = self.transformRect;
    switch (self.stretchMode) {
        case MysticStretchModeAspectFit:
            n = [MysticUI normalize:self.layerImageSize bounds:[MysticOptions current].size mode:self.stretchMode]; break;
        case MysticStretchModeAspectFill:
            n = [MysticUI normalize:self.layerImageSize bounds:[MysticOptions current].size mode:self.stretchMode]; break;
        case MysticStretchModeNone:
            n = CGRectNormal(CGRectSize(self.layerImageSize),CGRectSize([MysticEffectsManager size:MysticRenderOptionsBiggest])); break;
        case MysticStretchModeFill:
        default: break;
    }
    if(CGRectEqual(n,b)) return;
    BOOL c = !CGRectEqual(self.adjustedRect,n)||!self.hasSetAdjustmentTransformRect;
    self.adjustedRect = n;
    if(!(c|| CGRectEqual(b, MysticDefaultTransformRect) || CGRectEqual(t, MysticDefaultTransformRect))) return;
    if(CGRectEqual(t, MysticDefaultTransformRect)) self.originalTransformRect = n;
    else self.originalTransformRect = CGRectWH(t,CGRectW(t)*CGRectW(n),CGRectH(t)*CGRectH(n));
}
- (MysticObjectType) stretchModeSetting;
{
    switch (self.stretchMode) {
        case MysticStretchModeFill: return MysticSettingStretchFill;
        case MysticStretchModeNone: return MysticSettingStretchNone;
        case MysticStretchModeAspectFit: return MysticSettingStretchAspectFit;
        case MysticStretchModeAspectFill: return MysticSettingStretchAspectFill;
        default: break;
    }
    return MysticSettingStretch;
}
- (MysticStretchMode) stretchMode;
{
    if(_stretchMode != MysticStretchModeAuto) return _stretchMode;
    _stretchMode = [self.info objectForKey:@"stretch_mode"] ? [[self.info objectForKey:@"stretch_mode"] integerValue] : MysticStretchModeAuto;
    switch (_stretchMode) {
        case MysticStretchModeAuto: _stretchMode = !self.stretchLayerImage ? MysticStretchModeAspectFit : MysticStretchModeFill; break;
        default: break;
    }
    return _stretchMode;
}

#pragma mark - Image
- (BOOL) resizeLayerImage; { return YES; }
- (BOOL) forceReizeLayerImage; { return _forceReizeLayerImage ? YES : NO; }
- (MysticImageLayer *) image:(MysticOptions *)effects;
{
    MysticImageLayer *image;
    @autoreleasepool {
        image = [self imageForSettings:effects.settings size:effects.size];
        if(!image)
        {
            MysticFilterLayer *recoveredLayer;
            if(self.layer && self.layer.image) image = (id)self.layer.image;
            else if(!self.layer && self.owner)
            {
                recoveredLayer = [[MysticOptions current].filters layerForOption:self];
                image = recoveredLayer ? (id)recoveredLayer.image : nil;
                DLogError(@"Option: %@: \"%@\" @(image:) Image not found in cached layer | %@", MyString(self.type), self.name,  image ? @"Recovered" : @"Unable to recover");
                if(image) self.weakOwner = [MysticOptions current];
            }
            else if(!self.owner)
            {
                recoveredLayer = [[MysticOptions current].filters layerForOption:self];
                image = recoveredLayer ? (id)recoveredLayer.image : nil;
                DLogError(@"Image not found in because no owner | %@", image ? @"Recovered" : @"Unable to recover");
            }
        }
        [image retain];
    }
    return [image autorelease];
}
- (MysticImageLayer *) imageForSettings:(MysticRenderOptions)settings  size:(CGSize)renderSize;
{
    @try {
        BOOL usingCache = NO;
        MysticImageLayer *image = [self layerImageForSettings:settings size:renderSize];
        if(image && !CGSizeIsZero(image.size))
        {
            if(self.resizeLayerImage || self.forceReizeLayerImage)
            {
                BOOL equalRatios = (image.size.width/image.size.height) == (renderSize.width/renderSize.height);
                CGRect before = self.transformRect;
                CGRect normal = before;
                if(CGRectIsUnknown(_transformRectInitial)) _transformRectInitial=before;
                BOOL shouldAdjust = NO;
                if(!equalRatios || self.forceReizeLayerImage)
                {
                    MysticImageLayer *newimage = nil;
                    MysticStretchMode strech = self.stretchMode;
                    switch (strech) {
                        case MysticStretchModeAspectFit:
                        {
                            newimage = image;
                            normal = [MysticUI normalize:image.size bounds:renderSize mode:strech];
                            shouldAdjust = YES;
                            break;
                        }
                        case MysticStretchModeAspectFill:
                        {
                            newimage = image;
                            normal = [MysticUI normalize:image.size bounds:renderSize mode:strech];
                            shouldAdjust = YES;
                            break;
                        }
                        case MysticStretchModeFill:
                        {
                            if(usingCache) break;
                            UIGraphicsBeginImageContextWithOptions(renderSize, !self.hasAlphaChannel, 1);
                            [image drawInRect:[MysticUI rectWithSize:renderSize]];
                            newimage = (id)[MysticImageLayer imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage];
                            UIGraphicsEndImageContext();
                            break;
                        }
                        case MysticStretchModeNone: newimage = nil; break;
                        default:
                        {
                            if(usingCache) break;
                            UIImage *_newimage = [MysticImageLayer image:image size:renderSize backgroundColor:self.realBackgroundColor mode:strech];
                            newimage = (id)[MysticImageLayer imageWithCGImage:_newimage.CGImage];
                            break;
                        }
                    }
                    if(shouldAdjust)
                    {
                        BOOL hasAdjusted = self.hasSetAdjustmentTransformRect;
                        BOOL changed = !CGRectEqualToRect(self.adjustedRect, normal);
                        self.adjustedRect = normal;
                        if(!hasAdjusted || changed || CGRectEqualToRect(before, MysticDefaultTransformRect))
                        {
                            if(!hasAdjusted || CGRectEqualToRect(self.transformRect, MysticDefaultTransformRect))
                            {
                                if(CGRectEqualToRect(self.transformRect, MysticDefaultTransformRect)) self.originalTransformRect = normal;
                                else
                                {
                                    CGRect nt = self.transformRect;
                                    nt.size.width = nt.size.width*normal.size.width;
                                    nt.size.height = nt.size.height*normal.size.height;
                                    self.originalTransformRect = nt;
                                }
                            }
                        }
                    }
                    image = newimage ? newimage : image;
                }
            }
            self.readyForRender = YES;
        }
        else [MysticLog error:@"LayerImage" info:@{@"image":image ? s(CGSizeImage(image)) : @"No image",
                                                   @"type": MysticObjectTypeTitleParent(self.type, MysticObjectTypeUnknown),
                                                   @"layer": self.tag}];

        return image;
    }
    @catch (NSException *exception) {
        DLogError(@"Layer Image Error:  %@", exception.reason);
        return nil;
    }
    return nil;
}



- (MysticImageLayer *) layerImageForSize:(CGSize)renderSize;
{
    return [self layerImageForSize:renderSize allowDownload:NO];
}
- (MysticImageLayer *) layerImageForSize:(CGSize)renderSize allowDownload:(BOOL)allowDownload;
{
    MysticRenderOptions renderSettings = MysticRenderOptionsAuto;
    CGSize previewSize = [UserPotion potion].previewSize;
    CGSize thumbSize = CGSizeMake(250, 250);
    if(renderSize.width > self.layerImageSize.width || renderSize.height > self.layerImageSize.height)
        renderSettings = MysticRenderOptionsOriginal;
    if(renderSettings & MysticRenderOptionsAuto  && (renderSize.width > previewSize.width || renderSize.height > previewSize.height))
        renderSettings = MysticRenderOptionsSource;
    if(renderSettings & MysticRenderOptionsAuto && (renderSize.width > thumbSize.width || renderSize.height > thumbSize.height))
        renderSettings = MysticRenderOptionsPreview;
    if(renderSettings & MysticRenderOptionsAuto) renderSettings = MysticRenderOptionsThumb;
    return [self layerImageForSettings:renderSettings size:renderSize];
}
- (void) layerImageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize finished:(MysticBlockImage)finishedImageBlock;
{
    if(finishedImageBlock)
    {
        __unsafe_unretained __block PackPotionOption *weakSelf = self;
        __unsafe_unretained __block MysticBlockImage _finished = Block_copy(finishedImageBlock);
        mdispatch_default(^{
            MysticImageLayer *img = [weakSelf layerImageForSettings:settings size:renderSize];
            mdispatch(^{ _finished(img); Block_release(_finished); });
        });
    }
}
- (MysticImageLayer *) layerImageForSettings:(MysticRenderOptions)settings size:(CGSize)renderSize;
{
    MysticImageType __imageType = self.layerImageType;
    BOOL useAlpha = self.hasAlphaChannel;
    //        BOOL debug = [self isKindOfClass:[PackPotionOptionView class]];
    MysticImageLayer *returnImage=nil;
    //        NSString *settingsTypeStr = [MysticOptions renderImageTypeString:settings];
    //        NSString *cachedTag = [NSString stringWithFormat:@"layerSource%@-%@", settingsTypeStr, [self uniqueTag:@[@"tag", @"stretchingInsets", @"layerEffect"]]];
    //
    //        MysticCacheImageKey *imageOptions = [MysticCacheImageKey options:@{
    //                                                                         @"option": self,
    //                                                                         @"tag": cachedTag,
    //                                                                         @"type": @(__imageType),
    //                                                                         @"level": [NSNumber numberWithInt:MYSTIC_LAYER_CACHED_LEVEL],
    //                                                                         @"cache": @(MysticCacheTypeLayer),
    //                                                                         @"name": @"layerSource",
    //                                                                         @"saveToDisk": @YES,
    //                                                                         }];
    ////        returnImage = (id)[[MysticCacheImage layerCache] imageForOptions:imageOptions];
    //        returnImage = nil;
    //        if(returnImage) {
    //
    //            if(!self.readyForRender) self.readyForRender = YES;
    //            return returnImage;
    //        }
    
    
    NSString *downloadURL = [self downloadUrlForSettings:settings];
    CGSize layerImageSize = CGSizeZero;
    if(downloadURL)
    {
        UIImage *_returnImage = [[MysticCache layerCache] cacheImageNamed:downloadURL];
        returnImage = (id)[MysticImageLayer imageWithImage:_returnImage];
        if(returnImage) layerImageSize = [MysticImageLayer sizeInPixels:returnImage];
        else [self addDownload:downloadURL key:[@"layerImg-" stringByAppendingString:self.tag]];
    }
    
    UIImage *alphaImage = nil;
    if(!returnImage)
    {
        if(!downloadURL && self.hasSourceImage) returnImage = [self sourceImage];
        if(self.hasAlphaMask)
        {
            alphaImage = self.info[@"mask"] ? [UIImage imageNamed:self.info[@"mask"]] : nil;
            alphaImage = alphaImage ? alphaImage : [[MysticCache layerCache] cacheImageNamed:self.alphaMaskImageURLString];
            if(!alphaImage) [self addDownload:self.alphaMaskImageURLString key:[@"alphaMask-" stringByAppendingString:self.tag]];
        }
        if(!returnImage) return nil;
    }
    layerImageSize = CGSizeImage(returnImage);
    
    
    if(self.hasAlphaMask)
    {
        
        //            NSString *alphaTag = [@"alphaMask-" stringByAppendingString:self.tag];
        //            MysticCacheImageKey *theMaskOptions = [MysticCacheImageKey options:@{
        //                                                                               @"tag": alphaTag,
        //                                                                               @"type": @(imageOptions.type),
        //                                                                               @"level": [NSNumber numberWithInteger:MYSTIC_LAYER_MASK_LEVEL],
        //                                                                               @"option": self,
        //                                                                               @"cache": @(MysticCacheTypeLayer),
        //                                                                               @"name": @"alphaMask",
        //                                                                               @"saveToDisk": @YES,
        //                                                                               }];
        //            MysticImageLayer *alphaMaskedImageCache = (id)[[MysticCacheImage layerCache] imageForOptions:theMaskOptions];
        ////            alphaMaskedImageCache = nil;
        //            if(!alphaMaskedImageCache)
        //            {
        
        MysticImageLayer *alphaBlendMaskImage = (id)[MysticImageLayer imageWithImage:alphaImage ? alphaImage : self.alphaMaskImage];
        //                DLog(@"mask image:  %@", ILogStr(alphaBlendMaskImage));
        //                if(!alphaBlendMaskImage && self.alphaMaskImageURLString)
        //                {
        //                    ErrorLog(@"Forced to download the alpha mask the raw way");
        //                    NSURL *myUrl2 = [NSURL URLWithString:self.alphaMaskImageURLString];
        //                    NSData *myData2 = [NSData dataWithContentsOfURL:myUrl2];
        //                    MysticImageLayer *returnAlphaMaskImage = (id)[MysticImageLayer imageWithData:myData2];
        //                    if(returnAlphaMaskImage)
        //                    {
        //                        NSString *layerImageCacheKey2 = [MysticCache.layerManager cacheKeyForURL:[NSURL URLWithString:self.alphaMaskImageURLString]];
        //                        [MysticCache.layerCache storeImage:returnAlphaMaskImage imageData:myData2 forKey:layerImageCacheKey2 toDisk:YES];
        //                        alphaBlendMaskImage = returnAlphaMaskImage;
        //                    }
        //                }
        
        
        if(alphaBlendMaskImage)
        {
            // redraw alphaMaskImage to match the returnImage size
            
            CGFloat sourceImageRatio = returnImage.size.width/returnImage.size.height;
            CGFloat maskImageRatio = alphaBlendMaskImage.size.width/alphaBlendMaskImage.size.height;
            
            BOOL ratiosMatch = sourceImageRatio == maskImageRatio || fabsf((float)(sourceImageRatio-maskImageRatio)) < 0.03 ? YES : NO;
            
            if(!CGSizeEqualToSize(alphaBlendMaskImage.size, returnImage.size) & ratiosMatch)
            {
                
                UIGraphicsBeginImageContext(returnImage.size);
                [alphaBlendMaskImage drawInRect:CGRectMake(0, 0, returnImage.size.width, returnImage.size.height)];
                alphaBlendMaskImage = (id)[MysticImageLayer imageWithImage:UIGraphicsGetImageFromCurrentImageContext()];
                UIGraphicsEndImageContext();
            }
            else if(!ratiosMatch && !CGSizeEqualToSize(alphaBlendMaskImage.size, returnImage.size))
            {
                ErrorLog(@"PackPotionOption ERROR: Mask Image & Layer Image Ratios dont match, and they arent the same size... possibly need to implement stretching insets on mask image");
            }
            
            
            switch (self.normalBlendingType) {
                case MysticFilterTypeBlendAlphaMaskFillBg:
                {
                    returnImage = (id)[MysticImageLayer imageWithImage:[MysticImageLayer maskedImage:returnImage mask:alphaBlendMaskImage size:layerImageSize]];
                    break;
                }
                    
                default:
                {
                    returnImage = (id)[MysticImageLayer imageWithImage:[MysticImageLayer maskedImage:returnImage mask:alphaBlendMaskImage size:layerImageSize]];
                    break;
                }
            }
            //                    [MysticCacheImage addImage:returnImage options:theMaskOptions];
        }
        //            }
        //            else returnImage = alphaMaskedImageCache;
        
    }
    
    
    if(returnImage && !UIEdgeInsetsEqualToEdgeInsets(self.stretchingInsets, UIEdgeInsetsZero))
    {
        CGFloat renderImageRatio = renderSize.width/renderSize.height;
        CGFloat layerImageRatio = layerImageSize.width/layerImageSize.height;
        BOOL ratiosMatch = renderImageRatio == layerImageRatio || fabsf((float)(renderImageRatio-layerImageRatio)) < 0.01 ? YES : NO;
        if(!CGSizeEqualToSize(renderSize, layerImageSize) && !ratiosMatch)
        {
            UIEdgeInsets si = UIEdgeInsetsIntegralFromNormalizedInsetsSize(self.stretchingInsets, layerImageSize);
            UIEdgeInsets si2 = UIEdgeInsetsIntegralFromNormalizedInsetsSize(self.stretchingInsets, renderSize);
            UIEdgeInsets si3 = si2;
            CGFloat vertRatio = si2.top/si.top;
            CGFloat horizRatio = si2.right/si.right;
            CGFloat resizeRatio = MIN(vertRatio, horizRatio);
            resizeRatio = resizeRatio == 1 ? MAX(vertRatio, horizRatio) : resizeRatio;
            CGSize newLayerImageSize = CGSizeMake(layerImageSize.width * resizeRatio, layerImageSize.height * resizeRatio);
            if(resizeRatio != 1 && !CGSizeIsZero(newLayerImageSize))
            {
                CGRect resizedLayerRect = [MysticUI rectWithSize:newLayerImageSize];
                resizedLayerRect = CGRectIntegral(resizedLayerRect);
                UIGraphicsBeginImageContextWithOptions(resizedLayerRect.size, !useAlpha, 1);
                [returnImage drawInRect:resizedLayerRect];
                returnImage = [MysticImageLayer imageWithImage:UIGraphicsGetImageFromCurrentImageContext()];
                UIGraphicsEndImageContext();
                si3 = UIEdgeInsetsIntegralFromNormalizedInsetsSize(self.stretchingInsets, resizedLayerRect.size);
            }
            returnImage = [MysticImageLayer imageWithImage:[returnImage resizableImageWithCapInsets:si3 resizingMode:self.fillMode]];
            UIGraphicsBeginImageContextWithOptions(renderSize, !useAlpha, 1);
            [returnImage drawInRect:[MysticUI rectWithSize:renderSize]];
            returnImage = [MysticImageLayer imageWithImage:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
    }
    if(!self.readyForRender) {  self.readyForRender = YES; }
    self.layerImageSize = returnImage ? [MysticImage sizeInPixels:returnImage] : CGSizeZero;
    return returnImage;
}
- (MysticImageLayer *) sourceImage;
{
    id img = (id)[MysticImageLayer image:[self sourceImageInput] size:MysticSizeOriginal color:nil contentMode:UIViewContentModeScaleToFill];
    return img ? img : [super sourceImage];
}
- (id) sourceImageInput;
{
    if(self.originalLayerImagePath) { return [UIImage imageWithContentsOfFile:self.originalLayerImagePath]; }
    if(self.layerImagePath) { return [UIImage imageWithContentsOfFile:self.layerImagePath]; }
    id img = [super sourceImageInput];
    if(!img && self.imageName) img = [UIImage imageNamed:self.imageName];
    return img;
}
- (BOOL) hasSourceImage;
{
    BOOL h = [super hasSourceImage];
    if(!h && self.imageName && [UIImage imageNamed:self.imageName]) return YES;
    return h ? h : (self.layerImagePath || self.originalLayerImagePath);
}

- (NSString *) layerImagePath;
{
    if(_layerImagePath) return _layerImagePath;
    return self.info[@"image_path"];
}
- (NSString *) imageNameExtension;
{
    NSString *imageName = self.info[@"image"];
    NSString *ext = nil;
    if(!imageName) imageName = [self.imageURLString lastPathComponent];
    NSArray *comps = [imageName componentsSeparatedByString:@"."];
    if(imageName) ext = comps.count > 1 ? [[comps lastObject] lowercaseString] :nil;
    return ext;
}
- (NSString *) imageExtension;
{
    NSString *ext = [self imageNameExtension];
    if(!ext)
    {
        switch (self.layerImageType) {
            case MysticImageTypeJPNG: return @"jpng";
            case MysticImageTypePNG: return @"png";
            default: break;
        }
    }
    return ext ? ext : @"jpg";
}
- (MysticImageType) layerImageType;
{
    MysticImageType itype = MysticImageTypeJPG;
    switch(self.blendingType)
    {
        case MysticFilterTypeBlendAlpha:
        case MysticFilterTypeBlendAlphaMask:
        case MysticFilterTypeBlendAlphaMaskFillBg:
        case MysticFilterTypeBlendAlphaMix: itype = MysticImageTypePNG; break;
        default: break;
    }
    NSString *ext = [self imageNameExtension];
    if(ext && (itype == MysticImageTypeJPG || itype == MysticImageTypePNG))
    {
        if([ext isEqualToString:@"png"]) itype = MysticImageTypePNG;
        else if([ext isEqualToString:@"jpng"]) itype = MysticImageTypeJPNG;
        
    }
    return itype;
}

- (NSString *) imageName;
{
    if(self.layerImageType == MysticImageTypeJPNG)
    {
        NSString *n = self.info[@"image"] ? self.info[@"image"] : self.info[@"original"];
        if(n) return n;
    }
    if(self.info[@"image"]) return [[self.info[@"image"] componentsSeparatedByString:@"."] firstObject];
    if(self.info[@"original"]) return [[self.info[@"original"] componentsSeparatedByString:@"."] firstObject];
    return nil;
}
- (void) prepareForSettings:(MysticRenderOptions)settings;
{
    if([self isPreparedForSettings:settings]) return;
    UIImage *returnImage = nil;
    NSString *downloadURL = [self downloadUrlForSettings:settings];
    if(downloadURL)
    {
        returnImage = [[MysticCache layerCache] cacheImageNamed:downloadURL];
        if(!returnImage)
        {
            [self addDownload:downloadURL key:[@"layerImg-" stringByAppendingString:self.tag]];
        }
    }
    
    if(!returnImage)
    {
        if(self.hasAlphaMask)
        {
            UIImage *alphaImage = self.info[@"mask"] ? [UIImage imageNamed:self.info[@"mask"]] : nil;
            alphaImage = alphaImage ? alphaImage : [[MysticCache layerCache] cacheImageNamed:self.alphaMaskImageURLString];
            if(!alphaImage)
            {
                [self addDownload:self.alphaMaskImageURLString key:[@"alphaMask-" stringByAppendingString:self.tag]];
            }
        }
    }
    
    if(!self.numberOfDownloads) [self setReadyForRender:YES andUpdateObservers:NO];
    
    [super prepareForSettings:settings];
}
- (BOOL) useSourceImageForPreview; { return YES; }
- (NSString *) downloadUrlForSettings:(MysticRenderOptions)settings;
{
    NSString *downloadURL = nil;
    if(settings & MysticRenderOptionsOriginal)
    {
        downloadURL = self.originalImageURLString;
        if(self.info[@"original"] /*&& [UIImage imageNamed:self.info[@"original"]] */) downloadURL = nil;
        
    }
    else if(settings & MysticRenderOptionsSource)
    {
        downloadURL = self.imageURLString;
        if(self.info[@"image"] /*&& [UIImage imageNamed:self.info[@"image"]]*/) downloadURL = nil;
    }
    else if(settings & MysticRenderOptionsPreview)
    {
        downloadURL = self.useSourceImageForPreview ? self.imageURLString : self.previewURLString;
        if(self.info[@"preview"] /*&& [UIImage imageNamed:self.info[@"preview"]]*/) downloadURL = nil;
        if(self.info[@"image"] /*&& [UIImage imageNamed:self.info[@"image"]]*/) downloadURL = nil;
        
    }
    else if(settings & MysticRenderOptionsThumb)
    {
        downloadURL = self.thumbURLString;
        if(self.info[@"thumb"] /*&& [UIImage imageNamed:self.info[@"thumb"]]*/) downloadURL = nil;
        if(self.info[@"preview"] /*&& [UIImage imageNamed:self.info[@"preview"]]*/) downloadURL = nil;
        if(self.info[@"image"] /*&& [UIImage imageNamed:self.info[@"image"]]*/) downloadURL = nil;
    }
    return downloadURL;
}

- (NSInteger) moveUp;
{
    self.level++;
    return self.level;
}

- (NSInteger) moveDown;
{
    self.level--;
    return self.level;
}
- (BOOL) allowNormalBlending;
{
    if(self.hasAlphaMask) return YES;
    return (!self.allowNoBlending || (self.allowNoBlending && self.normalBlendingType != MysticFilterTypeBlendNormal));
    //    return [super allowNormalBlending];
}
- (BOOL) hasAlphaMask;
{
    return [self.info objectForKey:@"alphaMask"] != nil;
}
- (UIImageResizingMode) fillMode;
{
    NSInteger _fillMode = [self.info objectForKey:@"fill_mode"] ? [[self.info objectForKey:@"fill_mode"] integerValue] : UIImageResizingModeStretch;
    switch (_fillMode) {
        case 1: return UIImageResizingModeTile;
        default: return UIImageResizingModeStretch;
    }
    return _fillMode;
}


- (NSString *) layerImageKeyForSize:(CGSize)renderSize;
{
    CGSize previewSize = [UserPotion potion].previewSize;
    CGSize thumbSize = CGSizeMake(250, 250);
    NSString *returnImage = nil;
    if(renderSize.width > self.layerImageSize.width || renderSize.height > self.layerImageSize.height) return @"original";
    if(!returnImage && (renderSize.width > previewSize.width || renderSize.height > previewSize.height)) returnImage = @"image";
    if(!returnImage && (renderSize.width > thumbSize.width || renderSize.height > thumbSize.height)) returnImage = @"preview";
    return returnImage ? returnImage : @"thumb";
}

- (void) prepareControlForReuse:(EffectControl *)control;
{
    control.imageView = nil;
    //    control.imageView.image = nil;
    //    control.imageView.highlightedImage = nil;
    //    control.imageView.highlighted = NO;
    //    control.imageView.alpha = 1;
    control.backgroundView.backgroundColor = [MysticColor colorWithType:MysticColorTypeControlInactive];
}

- (UIImage *) layerOriginalImage;
{
    if(self.originalLayerImagePath)
        return [UIImage imageWithContentsOfFile:self.originalLayerImagePath];
    return self.layerImage;
}
- (UIImage *) customLayerImage;
{
    if(self.originalLayerImagePath) return [UIImage imageWithContentsOfFile:self.originalLayerImagePath];
    if(self.layerImagePath) return [UIImage imageWithContentsOfFile:self.layerImagePath];
    return [super sourceImageInput];
}
- (void) setCustomLayerImage:(UIImage *)layerImage;
{
    [self setCustomLayerImage:layerImage complete:nil];
}
- (void) setCustomLayerImage:(UIImage *)image complete:(MysticBlock)complete;
{
    if(!image) {
        
        if(self.layerImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.layerImagePath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.layerImagePath error:&error];
        }
        if(self.originalLayerImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.originalLayerImagePath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.originalLayerImagePath error:&error];
        }
        self.layerImagePath = nil; self.originalLayerImagePath=nil;
        if(complete) complete();
        return;
    }
    
    __unsafe_unretained __block PackPotionOption *weakSelf = [self retain];
    __unsafe_unretained __block PackPotionOption *weakSelf2 = [self retain];
    
    __unsafe_unretained __block MysticBlock __complete = complete ? Block_copy(complete) : nil;
    
    self.originalImageSize = [MysticImage sizeInPixels:image];
    CGRect previewSize = CGRectIntegral(CGRectz([MysticUI aspectFit:CGRectSize(self.originalImageSize) bounds:CGRectSize([UserPotion potion].previewSize)]));
    self.previewImageSize = previewSize.size;
    mdispatch_default(^{
        @autoreleasepool {
            if(self.layerImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.layerImagePath])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:self.layerImagePath error:&error];
            }
            if(self.originalLayerImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.originalLayerImagePath])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:self.originalLayerImagePath error:&error];
            }
            self.layerImagePath=nil;
            self.originalLayerImagePath=nil;
            [UserPotionManager setImage:image layerLevel:0 tag:[NSString stringWithFormat:@"%@-layer-%@-%@",[UserPotion potion].uniqueTag, weakSelf.tag, weakSelf.uniqueTag] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
                weakSelf.originalLayerImagePath = string;
                [weakSelf release];
            }];
            UIGraphicsBeginImageContextWithOptions(previewSize.size, NO, 1);
            [image drawInRect:previewSize];
            UIImage* newResizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [UserPotionManager setImage:newResizedImage layerLevel:kPhotoLayerLevel+1 tag:[NSString stringWithFormat:@"%@-layer-preview-%@-%@",[UserPotion potion].tag, weakSelf2.tag, weakSelf2.uniqueTag] type:MysticImageTypeJPG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
                weakSelf2.layerImagePath = string;
                if(__complete) { __complete(); Block_release(__complete); }
                [weakSelf2 release];
            }];
            self.hasChanged = YES;
        }
    });
}

- (UIImage *) layerImage;
{
    if(self.layerImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.layerImagePath])
        return [UIImage imageWithContentsOfFile:self.layerImagePath];
    if(!self.imageURLString) return nil;
    NSString *cacheKey = [MysticCache.layerManager cacheKeyForURL:[NSURL URLWithString:self.imageURLString]];
    return [MysticCache.layerCache imageFromDiskCacheForKey:cacheKey];
}
- (BOOL) hasOverlaysToRender;
{
    if(!self.hasImage && !self.blended) return YES;
    return NO;
}
- (UIImage *) render:(MysticOptions *)effects background:(UIImage *)bgImage;
{
    return bgImage;
}
- (UIImage *) icon;
{
    if(_iconImg) return _iconImg;
    UIImage *img = self.thumbnail ? self.thumbnail : self.layerThumbImage;
    //    UIImage *img = self.thumbnail ? self.thumbnail : nil;
    
    return img ? img : [super icon];
}
- (void) setThumbnail:(UIImage *)thumbnail;
{
    if(_thumbnail) [_thumbnail release], _thumbnail=nil;
    if(thumbnail)
    {
        _thumbnail = [thumbnail retain];
        self.hasProcessedThumbnail = YES;
    }
    else
    {
        self.hasProcessedThumbnail = NO;
    }
}
- (NSString *) thumbnailImagePath;
{
    if(_thumbnailImagePath) return _thumbnailImagePath;
    return self.info[@"thumb_path"];
}
- (UIImage *) thumbnail;
{
    if(_thumbnail) return _thumbnail;
    NSString *thumb = self.info[@"thumb"];
    if(thumb)
    {
        UIImage *img = [UIImage imageNamed:thumb];
        if(img) return img;
    }
    if(self.thumbnailImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailImagePath])
    {
        return [UIImage imageWithContentsOfFile:self.thumbnailImagePath];
    }
    return nil;
}
- (UIImage *) layerPreviewImage;
{
    if(self.previewImagePath)
        return [UIImage imageWithContentsOfFile:self.previewImagePath];
    if(!self.previewURLString) return nil;
    NSString *layerImageCacheKey = [MysticCache.layerManager cacheKeyForURL:[NSURL URLWithString:self.previewURLString]];
    UIImage *img = [MysticCache.layerCache imageFromDiskCacheForKey:layerImageCacheKey];
    return img;
}

- (UIImage *) layerThumbImage;
{
    if(!self.thumbURLString) return nil;
    NSString *layerImageCacheKey = [MysticCache.uiManager cacheKeyForURL:[NSURL URLWithString:self.thumbURLString]];
    
    return [MysticCache.uiCache imageFromDiskCacheForKey:layerImageCacheKey];
    
}

- (UIImage *) alphaMaskImage;
{
    NSString *as = self.alphaMaskImageURLString;
    if(!as) return nil;
    NSString *layerImageCacheKey = [MysticCache.layerManager cacheKeyForURL:[NSURL URLWithString:as]];
    
    
    return [MysticCache.layerCache imageFromDiskCacheForKey:layerImageCacheKey];
    
}

- (NSString *) alphaMaskImageURLString;
{
    return [self.info objectForKey:@"alphaMask"];
}


- (CGBlendMode) CGBlendMode;
{
    return CGBlendModeFromMysticFilterType(self.blendingType);
}


- (BOOL) hasCustomLayerEffects; { return NO; }

- (id) customLayerEffect:(MysticLayerEffect)layerEffectType;
{
    return nil;
}



- (NSArray *) adjustmentsTypesMatching:(MysticFilterOption)filterOption toString:(BOOL)toString;
{
    
    NSDictionary *__adjustments = self.adjustments;
    if(!__adjustments || ![__adjustments objectForKey:@"keys"]) return nil;
    
    NSArray *theTypes = [self filterTypesMatchingOptions:filterOption];
    
    if(!toString) return theTypes;
    
    NSMutableArray *tts = [NSMutableArray array];
    for (NSNumber *key in theTypes)
    {
        MysticObjectType setting = [key integerValue];
        
        [tts addObject:MyString(setting)];
        
        
    }
    return tts;
    
}



+ (PackPotionOption *) optionWithType:(MysticObjectType)optionType info:(NSDictionary *)info;
{
    Class optionClass = [PackPotionOption class];
    
    
    switch (optionType) {
        case MysticObjectTypeCamLayer:
            optionClass = [PackPotionOptionCamLayer class];
            break;
        case MysticObjectTypeLight:
            optionClass = [PackPotionOptionLight class];
            break;
        case MysticObjectTypeText:
            optionClass = [PackPotionOptionText class];
            break;
        case MysticObjectTypeTexture:
            optionClass = [PackPotionOptionTexture class];
            
            break;
        case MysticObjectTypeFrame:
            optionClass = [PackPotionOptionFrame class];
            
            break;
        case MysticObjectTypeMask:
            optionClass = [PackPotionOptionMask class];
            
            break;
        case MysticObjectTypeBadge:
            optionClass = [PackPotionOptionBadge class];
            
            break;
        case MysticObjectTypeFilter:
            optionClass = [PackPotionOptionFilter class];
            
            break;
        case MysticObjectTypeTextColor:
        case MysticObjectTypeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeBadgeColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeFrameBackgroundColor:
            optionClass = [PackPotionOptionColor class];
            break;
        case MysticObjectTypeTextPack:
        case MysticObjectTypePack:
            optionClass = [MysticTextPack class];
            break;
            
        default: break;
    }
    
    return (PackPotionOption *)[optionClass optionWithName:[info objectForKey:@"name"] info:info];
}

- (void) addResourcePath:(NSString *)path name:(NSString *)resourceName;
{
    if(!self.resourcePaths) self.resourcePaths = [NSMutableDictionary dictionary];
    [self.resourcePaths setObject:path forKey:resourceName];
}

- (NSString *) controlImageNamePath;
{
    switch (self.type) {
        case MysticObjectTypeBadge:
        case MysticObjectTypeFilter:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticObjectTypePotion: return nil;
        default: break;
    }
    return [super controlImageNamePath];
}
- (BOOL) hasMapImage;
{
    return _hasSavedMapImage || (self.mapImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.mapImagePath]);
}
- (UIImage *)mapImage;
{
    if(!self.mapImagePath) return nil;
    return [[NSFileManager defaultManager] fileExistsAtPath:self.mapImagePath] ? [[[UIImage alloc] initWithContentsOfFile:self.mapImagePath] autorelease] : nil;
}

- (void) setMapImage:(UIImage *)image;
{
    [self setMapImage:image complete:nil];
}
- (void) setMapImage:(UIImage *)image complete:(MysticBlock)complete;
{
    if(!image) { self.mapImagePath = nil; _hasSavedMapImage=NO; return; }
    __unsafe_unretained __block PackPotionOption *weakSelf = [self retain];
    __unsafe_unretained __block MysticBlock __complete = complete ? Block_copy(complete) : nil;
    _hasSavedMapImage = YES;
    mdispatch_high(^{
        @autoreleasepool {
            if(self.mapImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.mapImagePath])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:self.mapImagePath error:&error];
                if(error) DLogError(@"Set Mask Image Error deleting previous mask: %ld", (long)error.code);
            }
            [UserPotionManager setImage:image layerLevel:kPhotoLayerLevel tag:[NSString stringWithFormat:@"%@-%@-%@-map%d", [UserPotion potion].uniqueTag, weakSelf.optionSlotKey, weakSelf.tag, (int)mapImageCount] type:MysticImageTypePNG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
                weakSelf.mapImagePath = string;
                weakSelf.hasSavedMapImage=YES;
                if(__complete) { __complete(); Block_release(__complete); }
                [weakSelf release];
            }];
            mapImageCount++;
        }
    });
}


- (BOOL) hasMaskImage;
{
    return _hasSavedMaskImage || (self.maskImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.maskImagePath]);
}
- (UIImage *)maskImage;
{
    if(!self.maskImagePath) return nil;
    return [[NSFileManager defaultManager] fileExistsAtPath:self.maskImagePath] ? [[[UIImage alloc] initWithContentsOfFile:self.maskImagePath] autorelease] : nil;
}

- (void) setMaskImage:(UIImage *)image;
{
    [self setMaskImage:image complete:nil];
}
- (void) setMaskImage:(UIImage *)image complete:(MysticBlock)complete;
{
    if(!image) { self.maskImagePath = nil; _hasSavedMaskImage=NO; return; }
    __unsafe_unretained __block PackPotionOption *weakSelf = [self retain];
    __unsafe_unretained __block MysticBlock __complete = complete ? Block_copy(complete) : nil;
    _hasSavedMaskImage = YES;
    mdispatch_high(^{
        @autoreleasepool {
            if(self.maskImagePath && [[NSFileManager defaultManager] fileExistsAtPath:self.maskImagePath])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:self.maskImagePath error:&error];
                if(error) DLogError(@"Set Mask Image Error deleting previous mask: %ld", (long)error.code);
            }
            [UserPotionManager setImage:image layerLevel:kPhotoLayerLevel tag:[NSString stringWithFormat:@"%@-%@-%@-mask", [UserPotion potion].uniqueTag, weakSelf.optionSlotKey, weakSelf.tag] type:MysticImageTypePNG cacheType:MysticCacheTypeProject finishedPath:^(NSString *string) {
                weakSelf.maskImagePath = string;
                weakSelf.hasSavedMaskImage=YES;
                if(__complete) { __complete(); Block_release(__complete); }
                [weakSelf release];
            }];
        }
    });
}

#pragma mark - Adjust Color
- (NSDictionary *) lastAdjustColorInfo;
{
    if(!self.adjustColors || self.adjustColors.count<1) return nil;
    return self.adjustColors.lastObject;
}
- (UIColor *) lastAdjustColor;
{
    NSDictionary *c = self.lastAdjustColorInfo;
    return c ? isNullOr(c[@"source"]) : nil;
}
- (void) removeAdjustColors;
{
    self.adjustColors=nil;
}
- (BOOL) removeAdjustColorAtIndex:(NSInteger)i;
{
    if(!isIndexOf(i,self.adjustColors)) return NO;
    [self.adjustColors removeObjectAtIndex:i];
    return YES;
}
- (NSInteger) lastAdjustColorIndex;
{
    if(!self.adjustColors || self.adjustColors.count<1) return NSNotFound;
    NSDictionary *c = self.lastAdjustColorInfo;
    return c ? [c[@"index"] integerValue] : NSNotFound;
}
- (NSDictionary *) adjustColorAtIndex:(NSInteger)i;
{
    if(!isIndexOf(i,self.adjustColors)) return nil;
    return [self.adjustColors objectAtIndex:i];
}
- (UIColor *) adjustedColorAtIndex:(NSInteger)i;
{
    if(!isIndexOf(i,self.adjustColors)) return nil;
    return isNullOr([[self.adjustColors objectAtIndex:i] objectForKey:@"color"]);
}
- (CGFloat) adjustColorIntensityAtIndex:(NSInteger)i;
{
    if(!isIndexOf(i,self.adjustColors)) return 1;
    return [[[self.adjustColors objectAtIndex:i] objectForKey:@"intensity"] floatValue];
}

- (NSInteger) indexOfAdjustColor:(UIColor *)color;
{
    if(!color || !self.adjustColors || self.adjustColors.count<1) return NSNotFound;
    for (NSDictionary *c in self.adjustColors) {
        if([color isEqualToColor:c[@"source"]]) return [c[@"index"] integerValue];
    }
    return NSNotFound;
}
- (NSArray *) adjustColorsFinal;
{
    return [self adjustColorsFinal:NO];
}
- (NSArray *) adjustColorsRender;
{
    return [self adjustColorsFinal:NO];
}
- (NSArray *) adjustColorsFinal:(BOOL)removeEqualColors;
{
    NSMutableArray *newAdjusts = [NSMutableArray arrayWithArray:self.adjustColors];
    NSInteger b = newAdjusts ? newAdjusts.count : -1;
    NSMutableString *s  =[NSMutableString stringWithString:@""];
    if(newAdjusts && newAdjusts.count>0)
    {
        NSMutableArray *aas = [NSMutableArray arrayWithArray:newAdjusts];
        for (NSDictionary*ac in aas) {
            UIColor *c = isNullOr(ac[@"source"]);
            UIColor *c2 = isNullOr(ac[@"color"]);
            BOOL r = [ac[@"rendered"] boolValue];
            float a = [ac[@"intensity"] floatValue];
            BOOL pu = CGPointIsUnknown([ac[@"point"] CGPointValue]);
            if(pu) [s appendString:@"point unknown  "];
            if(a==0) [s appendString:@"alpha 0  "];
            if(!c) [s appendString:@"no source  "];
            if(!c2) [s appendString:@"no color  "];
            if(removeEqualColors && [[c alpha:1] isEqualToColor:[c2 alpha:1]]) [s appendString:@"source & color are EQUAL"];
            if(r || !c2 || !c || a==0 || pu || (removeEqualColors && [[c alpha:1] isEqualToColor:[c2 alpha:1]]))
            {
                [newAdjusts removeObject:ac];
            }
        }
        NSInteger i = 0;
        [aas removeAllObjects];
        [aas addObjectsFromArray:newAdjusts];
        for (NSDictionary*ac in aas) {
            if([ac[@"index"] integerValue]!=i)
            {
                NSMutableDictionary *nac = [NSMutableDictionary dictionaryWithDictionary:ac];
                [nac setObject:@(i) forKey:@"index"];
                [newAdjusts replaceObjectAtIndex:i withObject:nac];
            }
            i++;
        }
    }
//    DLog(@"final adjusts:  %ld -> %ld    %@", b, newAdjusts.count, s && s.length ? ColorWrap([s prefix:@"( " suffix:@" )"],COLOR_RED) : @"");
    lastFinalAdjustCount=newAdjusts.count;
    return newAdjusts;
}
- (void) finalizeAdjustColors;
{
    NSInteger b = self.adjustColors ? self.adjustColors.count : -1;
    self.adjustColors = [NSMutableArray arrayWithArray:[self adjustColorsFinal:YES]];
}
- (NSString *) printAdjustColors:(NSString *)prefix;
{
    
    NSArray * adc = self.adjustColorsFinal;
    
    
    NSMutableString *s = [NSMutableString stringWithString:@""];
    int i = 1;
    for (NSDictionary *ac in adc) {
        
        UIColor *source = ac[@"source"];
        UIColor *color = ac[@"color"];
        MysticThreshold threshold = ThresholdWithArray(ac[@"threshold"]);
        CGFloat intensity = [ac[@"intensity"] floatValue];
        [s appendFormat:@"\n    #%d:   %@ %@  %2.1f   threshold: %@", i-1, ColorStr(source), ColorStr(color), intensity, MysticThresholdStr(threshold)];
        i++;
    }
    NSString *str = s && s.length ? [@"Color Adjustments:\n" stringByAppendingString:s] : @"No color adjustments";
    str = [str prefix:prefix];
    return str;

}
- (MysticAdjustColorInfo) adjustColor:(UIColor *)c toColor:(UIColor *)c2 intensity:(float)a point:(CGPoint)p1 threshold:(MysticThreshold)threshold index:(NSInteger)i;
{
    if(!c && !c2) { DLogError(@"adjust color ERROR: no colors"); return (MysticAdjustColorInfo){i==NSNotFound ? self.adjustColors.count-1 : i,NO}; }
    if(!self.adjustColors) self.adjustColors = [NSMutableArray array];
    NSDictionary *o = @{@"source":c ? c : [NSNull null],
                          @"point":[NSValue valueWithCGPoint:p1],
                          @"threshold": NSArrayWithThreshold(threshold),
                          @"color":c2 ? c2 : [NSNull null],
                            @"rendered":@NO,

                          @"intensity":@(MAX(0,MIN(1,isnan(a)?1:a))),
                          @"index":@(i==NSNotFound?self.adjustColors.count:i),
                          };
//    DLog(@"%ld:   %2.1f%%   %@ %@   (%@  |  %@)      %@       %@", i,MAX(0,MIN(1,isnan(a)?1:a)), ColorStr(c), ColorStr(c2), MysticRGBStr(c.rgb,-1),MysticRGBStr(c2.rgb,-1),   MysticRGBStr(threshold, 4), i!=NSNotFound && i<self.adjustColors.count && i>=0 ? ColorWrap(@"replace", COLOR_DULL) : @"");
    self.hasChanged=YES;
    self.hasRendered=NO;
    if(i!=NSNotFound && i<self.adjustColors.count && i>=0) {
//        NSDictionary *oo = [self.adjustColors objectAtIndex:i];
//        BOOL isSame = NO;
//        if([o[@"source"] isEqualToColor:oo[@"source"]]
//           && [o[@"color"] isEqualToColor:oo[@"color"]]
//           && RGBIsEqual(RGBWithArray(o[@"threshold"]), RGBWithArray(oo[@"threshold"]))
//           && [o[@"intensity"] floatValue] == [oo[@"intensity"] floatValue]) isSame=YES;
        [self.adjustColors replaceObjectAtIndex:i withObject:o];
//        return (MysticAdjustColorInfo){i,NO};

        return (MysticAdjustColorInfo){i,lastFinalAdjustCount!=[self adjustColorsFinal:YES].count};
    }
    
    [self.adjustColors addObject:o];
//    DLog(@"added adjust color: %@", o);
    return (MysticAdjustColorInfo){[self.adjustColors indexOfObject:o],YES};
    
}
- (NSArray *) adjustColorsSourceColors;
{
    NSMutableArray *adjusts = [NSMutableArray array];
    for (NSDictionary *c in self.adjustColorsFinal) {
        [adjusts addObject:[c objectForKey:@"source"]];
    }
    
    return adjusts;
}
#pragma mark - Update Filters



- (void) setupFilter:(MysticImageFilter *)imageFilter;
{
    if(self.ignoreActualRender) return;
    imageFilter = imageFilter ? imageFilter : [MysticOptions current].filters.filter;
    [super setupFilter:imageFilter];
    [imageFilter setIntensity:_intensity index:self.shaderIndex option:self];
    [imageFilter setBrightness:_brightness index:self.shaderIndex option:self];
    [imageFilter setVibrance:_vibrance index:self.shaderIndex option:self];
    [imageFilter setSaturation:_saturation index:self.shaderIndex option:self];
    [imageFilter setGamma:_gamma index:self.shaderIndex option:self];
    [imageFilter setExposure:_exposure index:self.shaderIndex option:self];
    [imageFilter setContrast:_contrast index:self.shaderIndex option:self];
    [imageFilter setRedLevelMin:self.blackLevelsRed mid:self.midLevelsValueRed max:self.whiteLevelsRed minOut:self.minBlackLevelRed maxOut:self.maxWhiteLevelRed index:self.shaderIndex option:self];
    [imageFilter setBlueLevelMin:self.blackLevelsBlue mid:self.midLevelsValueBlue max:self.whiteLevelsBlue minOut:self.minBlackLevelBlue maxOut:self.maxWhiteLevelBlue index:self.shaderIndex option:self];
    [imageFilter setGreenLevelMin:self.blackLevelsGreen mid:self.midLevelsValueGreen max:self.whiteLevelsGreen minOut:self.minBlackLevelGreen maxOut:self.maxWhiteLevelGreen index:self.shaderIndex option:self];
    [imageFilter setColorBalance:self.rgb index:self.shaderIndex option:self];
    [imageFilter setTemp:kTemperatureValueMin + (kTemperatureValueMax - kTemperatureValueMin)*(_temperature/kTemperatureMax) tint:_tint index:self.shaderIndex option:self];
    [imageFilter setBackgroundColor:self.backgroundColor index:self.shaderIndex option:self];
    [imageFilter setMaskBackgroundColor:self.maskBackgroundColor index:self.shaderIndex option:self];
    if([self hasAdjusted:MysticSettingHSBHue] || [self hasAdjusted:MysticSettingHSB]) [imageFilter setHSB:self.hsb intensity:1 index:self.shaderIndex option:self];
    if(self.canReplaceColor) { [imageFilter setForegroundColor:self.foregroundColor index:self.shaderIndex option:self]; }
    if(!isnan(self.mapBrightest) && !isnan(self.mapDarkest)) [imageFilter setBrightest:self.mapBrightest darkest:self.mapDarkest option:self];
}
- (BOOL) updateAllFilters;
{
    return [self updateFiltersMatching:MysticFilterOptionAll];
}
- (BOOL) updateFiltersMatching:(MysticFilterOption)filterOption;
{
    NSArray *lAdjustments = [self filterTypesMatchingOptions:filterOption];
    BOOL needsReload = NO;
    for (NSNumber *a in lAdjustments) if([self updateFilters:[a integerValue]] && !needsReload) needsReload = YES;
    return needsReload;
}
- (BOOL) updateFilters:(MysticObjectType)settingType;
{
    GPUImageOutput<GPUImageInput> *filter;
    BOOL needsReload = YES;
    switch (settingType)
    {
        case MysticSettingTransform:
        {
            GPUImageTransformFilter *effectFilter = [self filter:MysticLayerKeyTransform];
            needsReload = NO;
            if(effectFilter)
            {
                needsReload = NO;
                effectFilter.affineTransform = self.transform;
                effectFilter.ignoreAspectRatio = self.hasSetAdjustmentTransformRect;
                
                if(self.canFillTransformBackgroundColor)
                {
                    CGFloat transAlpha = !self.backgroundColor || [self.backgroundColor isEqualToColor:UIColor.clearColor] ? 0 : self.backgroundColor.alpha;
                    [effectFilter setBackgroundColorRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue alpha:transAlpha];
                }
                
                if(self.layer.textures.count)
                {
                    for (NSDictionary *texture in self.layer.textures) {
                        GPUImageTransformFilter *transform = texture[@"transform"];
                        transform.affineTransform = self.transformTextureOnlyXY;
                        transform.ignoreAspectRatio = self.hasSetAdjustmentTransformRect;
                    }
                }
            }
            break;
        }
        case MysticSettingTiltShift:
        {
            GPUImageTiltShiftFilter *effectFilter = [self filter:MysticLayerKeySettingTiltShift];
            if(effectFilter)
            {
                needsReload = NO;
                CGFloat midpoint = self.tiltShift;
                [effectFilter setTopFocusLevel:midpoint + kTiltShiftTopOffset];
                [effectFilter setBottomFocusLevel:midpoint + kTiltShiftBottomOffset];
                [effectFilter setFocusFallOffRate:kTiltShiftFallOffRate];
            }
            break;
        }
        case MysticSettingSharpness:
        {
            GPUImageSharpenFilter *effectFilter = [self filter:MysticLayerKeySettingSharpness ];
            if(effectFilter)
            {
                needsReload = NO;
                effectFilter.sharpness = self.sharpness;
            }
            break;
        }
            
        case MysticSettingUnsharpMask:
        {
            GPUImageUnsharpMaskFilter *effectFilter = [self filter:MysticLayerKeySettingUnsharpmask];
            if(effectFilter)
            {
                needsReload = NO;
                effectFilter.intensity = self.unsharpMask;
            }
            break;
        }
        default: needsReload = NO; break;
    }
    return needsReload;
}


- (GPUImageOutput<GPUImageInput> *) addFilters:(GPUImageOutput<GPUImageInput> *)input layer:(MysticFilterLayer *)layer effects:(MysticOptions *)options context:(NSDictionary *)context;
{
    MysticFilterOption contextOption = !context || ![context objectForKey:@"options"] ? MysticFilterOptionAll : [[context objectForKey:@"options"] integerValue];
    if(self.layerEffect != MysticLayerEffectInverted && self.inverted)
    {
        if(self.canInvertTexture) {
            GPUImageOutput<GPUImageInput> *invertFilter = [layer filterForKey:@"inverted"];
            BOOL createdLayerInvert = invertFilter == nil;

            if(!invertFilter)
            {
                invertFilter = [(GPUImageColorInvertFilter *)[[GPUImageColorInvertFilter alloc] init] autorelease];
            }
            else
            {
                [invertFilter removeAllTargets];
            }
            if(invertFilter && [invertFilter isKindOfClass:[GPUImageFilter class]])
            {
                [input addTarget:invertFilter];
                input = invertFilter;
                if(createdLayerInvert && invertFilter) [layer addFilter:invertFilter forKey:@"inverted"];
            }
        }
    }
    
    if(self.layerEffect>MysticLayerEffectNone)
    {
        NSString *layerEffectKey = @"layerEffect";
        GPUImageOutput<GPUImageInput> *effectFilter = [layer filterForKey:layerEffectKey];
        BOOL createdLayerEffect = effectFilter == nil;
        if(!effectFilter && !self.hasCustomLayerEffects)
        {
            effectFilter = [self customLayerEffect:self.layerEffect];
            if(!effectFilter)
            {
                
                switch (self.layerEffect) {
                    case MysticLayerEffectInverted:
                    {
                        if(self.canInvertTexture) effectFilter = [(GPUImageColorInvertFilter *)[[GPUImageColorInvertFilter alloc] init] autorelease];
                        break;
                    }
                    case MysticLayerEffectDesaturate:
                    {
                        effectFilter = [(GPUImageGrayscaleFilter *)[[GPUImageGrayscaleFilter alloc] init] autorelease];
                        break;
                    }
                    case MysticLayerEffectOne:
                    {
                        effectFilter = [(GPUImageSepiaFilter *)[[GPUImageSepiaFilter alloc] init] autorelease];
                        break;
                    }
                    case MysticLayerEffectTwo:
                    {
                        effectFilter = [(GPUImageRGBFilter *)[[GPUImageRGBFilter alloc] init] autorelease];
                        [(GPUImageRGBFilter *)effectFilter setRed:MYSTIC_LAYER_EFFECT_RGB_RED];
                        break;
                    }
                    case MysticLayerEffectThree:
                    {
                        effectFilter = [(GPUImageRGBFilter *)[[GPUImageRGBFilter alloc] init] autorelease];
                        [(GPUImageRGBFilter *)effectFilter setGreen:MYSTIC_LAYER_EFFECT_RGB_GREEN];
                        break;
                    }
                    case MysticLayerEffectFour:
                    {
                        effectFilter = [(GPUImageRGBFilter *)[[GPUImageRGBFilter alloc] init] autorelease];
                        [(GPUImageRGBFilter *)effectFilter setBlue:MYSTIC_LAYER_EFFECT_RGB_BLUE];
                        break;
                    }
                    case MysticLayerEffectRandom:
                    {
                        effectFilter = [[[GPUImageColorMatrixFilter alloc] init] autorelease];
                        [(GPUImageColorMatrixFilter *)effectFilter setIntensity:self.colorMatrixIntensity];
                        [(GPUImageColorMatrixFilter *)effectFilter setColorMatrix:self.colorMatrix];
                        break;
                    }
                    default: break;
                }
            }
        }
        else if(!effectFilter && self.hasCustomLayerEffects)
        {
            effectFilter = [self customLayerEffect:self.layerEffect];
            createdLayerEffect = effectFilter == nil;
        }
        else [effectFilter removeAllTargets];
        if(effectFilter && [effectFilter isKindOfClass:[GPUImageFilter class]])
        {
            [(GPUImageFilter *)effectFilter setBackgroundColorRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue alpha:self.backgroundColor.alpha];
            [input addTarget:effectFilter];
            input = effectFilter;
            if(createdLayerEffect && effectFilter) [layer addFilter:effectFilter forKey:layerEffectKey];
        }
    }
    
    input = [MysticRenderEngine adjustTarget:input effect:self layer:layer options:options context:context];
#ifdef MYSTIC_USE_TRANSFORMS
    
    if((contextOption & MysticFilterOptionTransformLayers || contextOption & MysticFilterOptionAll) && self.canTransform)
    {
        GPUImageTransformFilter *transformFilter = [layer filterForKey:MysticLayerKeyTransform];
        if(!transformFilter)
        {
            CGFloat transAlpha = 0;
            switch (self.normalBlendingType) {
                case MysticFilterTypeBlendAlphaMaskFillBg: transAlpha = 1; break;
                default: break;
            }
            transformFilter = [[[GPUImageTransformFilter alloc] init] autorelease];
            transformFilter.ignoreAspectRatio = self.hasSetAdjustmentTransformRect;
            if(self.canFillTransformBackgroundColor)
            {
                transAlpha = !self.backgroundColor || [self.backgroundColor isEqualToColor:UIColor.clearColor] ? 0 : self.backgroundColor.alpha;
                [transformFilter setBackgroundColorRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue alpha:transAlpha];
            }
            if(layer && transformFilter) [layer addFilter:transformFilter forKey:MysticLayerKeyTransform];
        }
        else [transformFilter removeAllTargets];
        
        if(transformFilter)
        {
            if(self.canFillTransformBackgroundColor)
            {
                CGFloat transAlpha = !self.backgroundColor || [self.backgroundColor isEqualToColor:UIColor.clearColor] ? 0 : self.backgroundColor.alpha;
                [transformFilter setBackgroundColorRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue alpha:transAlpha];
            }
            transformFilter.affineTransform = self.transform;
            [input addTarget:transformFilter];
            input = transformFilter;
            for (NSDictionary *texture in self.layer.textures.allValues) {
                GPUImageTransformFilter *transform = texture[@"transform"];
                transform.affineTransform = self.transformTextureXY;
            }
        }
        self.transformFilter = nil;
    }
#endif
    return [super addFilters:input layer:layer effects:options context:context];
}

- (NSInteger) numberOfFiltersMatchingOptions:(MysticFilterOption)filterOption;
{
    return [self filterTypesMatchingOptions:filterOption].count;
}
- (NSArray *) filterTypesMatchingOptions:(MysticFilterOption)filterOption;
{
    NSMutableArray *__filterTypes = [NSMutableArray array];
    NSMutableDictionary *__adjustments = [NSMutableDictionary dictionaryWithDictionary:self.adjustments];
    if(filterOption & MysticFilterOptionBeforeLayers)
    {
        if(self.refreshState > MysticSettingImageProcessing)
        {
            __adjustments = [NSMutableDictionary dictionaryWithDictionary:self.adjustmentsAndRefreshingAdjustments];

        }
        
    }
    
    if((__adjustments && ![(NSDictionary *)[__adjustments objectForKey:@"keys"] count] ) || !__adjustments) return __filterTypes;
//    DLog(@"filter types: refresh state: %@", MysticObjectTypeToString(self.refreshState));
    
    for (NSString *key in [__adjustments objectForKey:@"keys"])
    {
        MysticObjectType setting = [key integerValue];
        BOOL initLayer = YES;
        if(filterOption & MysticFilterOptionBeforeLayers)
        {
            initLayer = setting > MysticSettingImageProcessing;
//            switch (setting) {
////                case MysticSettingVignette:
//                case MysticSettingTiltShift:
//                case MysticSettingSharpness:
//                case MysticSettingUnsharpMask: break;
//                default: initLayer = NO; break;
//            }
        }
        else if(filterOption & MysticFilterOptionAfterLayers)
        {
            initLayer = NO;
            
//            switch (setting) {
//                case MysticSettingTiltShift:
//                case MysticSettingSharpness:
//                case MysticSettingUnsharpMask: initLayer = NO; break;
//                case MysticSettingVignette:
//                case MysticSettingTransform: initLayer = NO; break;
//                default: initLayer = NO; break;
//            }
        }
        else if(filterOption & MysticFilterOptionTransformLayers)
        {
            switch (setting) {
                case MysticSettingTransform: initLayer = YES; break;
                default: initLayer = NO; break;
            }
        }
        
        if(initLayer) [__filterTypes addObject:@(setting)];
    }
//    if(__filterTypes.count)
//    {
//        DLog(@"filter types for: %@",self);
//        for (NSNumber *setting in __filterTypes) {
//            DLog(@"\t %d: %@", (int)[setting integerValue], MysticObjectTypeToString([setting integerValue]));
//        }
//    }
//    if(filterOption & MysticFilterOptionBeforeLayers)
//    {
//        DLog(@"filter types for before: %d %@",MysticSettingTiltShift, __filterTypes);
//    }
    return __filterTypes;
}
- (NSString *) description;
{
    return self.debugDescription;
}
- (NSString *) debugDescription;
{
    return [NSString stringWithFormat:@"%@ %@ <%@ %p>%@  %@",
            [MyString(self.type) stringByPaddingToLength:10 withString:@" " startingAtIndex:0],
            [[self.shortName prefix:@"('" suffix:@"')"] stringByPaddingToLength:24 withString:@" " startingAtIndex:0],
            [NSStringFromClass(self.class) stringByPaddingToLength:30 withString:@" " startingAtIndex:0],
            self,
            self.optionSlotKey ? [@"  slot: " stringByAppendingString:self.optionSlotKey] : @"",
            self.tag];
}


@end



//
//  MysticLayerPanelBaseView.m
//  Mystic
//
//  Created by Me on 2/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerPanelBaseView.h"
#import "Mystic.h"
#import "MysticController.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "MysticPanelObject.h"
#import "CKRadialMenu.h"


@implementation MysticLayerPanelBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (MysticPanelType) sectionTypeForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;
{
    switch(setting)
    {
        case MysticSettingBlending:
            return MysticPanelTypeBlend;
            
        case MysticSettingColor:
            return MysticPanelTypeColor;
            
        case MysticSettingColorAndIntensity:
            return MysticPanelTypeColorAndIntensity;
            
        case MysticSettingIntensity:
        case MysticSettingSaturation:
        case MysticSettingBrightness:
        case MysticSettingSkin:
        case MysticSettingSkinUpperSkinToneColor:
        case MysticSettingSkinMaxSaturationShift:
        case MysticSettingSkinMaxHueShift:
        case MysticSettingSkinHueThreshold:
        case MysticSettingSkinHue:
        case MysticSettingContrast:
        case MysticSettingHSB:
        case MysticSettingHSBHue:
        case MysticSettingHSBBrightness:
        case MysticSettingHSBSaturation:
        case MysticSettingGamma:
        case MysticSettingExposure:
        case MysticSettingLevels:
        case MysticSettingHighlights:
        case MysticSettingShadows:
        case MysticSettingTemperature:
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceRed:
        case MysticSettingAlpha:
        case MysticSettingVignette:
        case MysticSettingTiltShift:
        case MysticSettingSharpness:
        case MysticSettingRGB:
        case MysticSettingHaze:
        case MysticSettingUnsharpMask:
        case MysticSettingWearAndTear:
            return MysticPanelTypeAdjust;
            
        default: break;
    }
    return MysticPanelTypeUnknown;
}

+ (NSInteger) activeTabForOption:(PackPotionOption *)option;
{
    MysticObjectType type = option ? option.type : MysticObjectTypeUnknown;
    if(!option) type = MysticTypeForSetting([MysticController controller].currentSetting, nil);
    
    
    switch (type) {
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        case MysticSettingBadge: return 1;
        case MysticObjectTypeLight: return 2;
        case MysticObjectTypeTexture: return 2;
        case MysticObjectTypeColorOverlay: return 2;
        default: break;
    }
    return 0;
}
+ (NSArray *) tabsForOption:(PackPotionOption *)option;
{
    return [[self class] tabsForOption:option type:option.type];
}
+ (NSArray *) tabsForOption:(PackPotionOption *)option type:(MysticObjectType)objectType;
{
    switch (objectType) {
        case MysticObjectTypeSketch:
            return @[
                     @{@"type": @(MysticSettingColorAndIntensity), @"panel": @(MysticPanelTypeColorAndIntensity)},
                     @{@"type": @(MysticSettingSketchBrush),@"panel": @(MysticPanelTypeUnknown),@"selected":@YES},
                     @{@"type": @(MysticSettingSketchEraser),@"panel": @(MysticPanelTypeUnknown)},
                     @{@"type": @(MysticSettingSketchLayers),@"panel": @(MysticPanelTypeUnknown)},
                     @{@"type": @(MysticSettingSketchSettings),@"panel": @(MysticPanelTypeUnknown)},
                     ];
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        case MysticObjectTypeBadge:
        case MysticSettingBadge:
            return @[
                     @{@"type": @(MysticSettingIntensity), @"panel": @(MysticPanelTypeIntensity)},
                     @{@"type": @(MysticSettingColorAndIntensity), @"panel": @(MysticPanelTypeColorAndIntensity)},
                     @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                     @{@"type": @(MysticSettingBackground),@"panel": @(MysticPanelTypeColorAndIntensity)},
//#ifdef DEBUG
                     @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     
                     ];
        case MysticObjectTypeTexture:
            return @[
                     @{@"type": @(MysticSettingHSBHue),@"panel": @(MysticPanelTypeHue)},
                     @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                     @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                     @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                     @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                     @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                     @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},
                     @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

                     ];
        case MysticObjectTypeLight:
            return @[
                     @{@"type": @(MysticSettingHSBHue),@"panel": @(MysticPanelTypeHue)},
                     @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                     @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                     @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                     @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                     @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                     @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},
                     @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

                     ];
        case MysticObjectTypeFrame:
        {

            if(!option.allowColorReplacement)
            {
                return @[
                         @{@"type": @(MysticSettingHSBHue),@"panel": @(MysticPanelTypeHue)},
                         @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                         @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                         @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                         @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                         @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                         @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},
                         @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                         @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                         @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                         @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

                         ];
                
            }
            else
            {
                return option.blendingType == MysticFilterTypeMask ?
                    @[@{@"type": @(MysticSettingColorAndIntensity),@"panel": @(MysticPanelTypeColorAndIntensity)},
                      @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                      @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                      @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                      @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                      @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                      @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                      @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                      @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},


                      ] :
                    @[@{@"type": @(MysticSettingColorAndIntensity),@"panel": @(MysticPanelTypeColorAndIntensity)},
                      @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                      @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                      @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                      @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                      @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                      @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},
                      @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                      @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                      @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                      @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

                      ];
            }
            
        }
        case MysticObjectTypeImage:
        case MysticObjectTypeCamLayer:
            return @[@{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                     @{@"type": @(MysticSettingIntensity), @"panel": @(MysticPanelTypeIntensity)},
//#ifdef DEBUG
                     @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                     @{@"type": @(MysticSettingVibrance),@"panel": @(MysticPanelTypeVibrance)},
                     @{@"type": @(MysticSettingTemperature),@"panel": @(MysticPanelTypeTone)},
                     @{@"type": @(MysticSettingSkin),@"panel": @(MysticPanelTypeSkin)},
                     @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                     @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},
                     @{@"type": @(MysticSettingHaze),@"panel": @(MysticPanelTypeHaze)},
                     @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                     @{@"type": @(MysticSettingGamma),@"panel": @(MysticPanelTypeGamma)},
                     @{@"type": @(MysticSettingExposure),@"panel": @(MysticPanelTypeExposure)},
                     @{@"type": @(MysticSettingLevels),@"panel": @(MysticPanelTypeLevels)},
                     @{@"type": @(MysticSettingColorBalance),@"panel": @(MysticPanelTypeColorBalance)},
                     @{@"type": @(MysticSettingShadows),@"panel": @(MysticPanelTypeShadows)},
                     @{@"type": @(MysticSettingHighlights),@"panel": @(MysticPanelTypeHighlights)},
                     @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFit),@(MysticSettingStretchAspectFill),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

                     ];
            
        case MysticObjectTypeSetting:
                    return
                    @[
                    @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeContrast)},

//            return @[@{@"type": @(MysticSettingVibrance),@"panel": @(MysticPanelTypeVibrance)},
                     @{@"type": @(MysticSettingTemperature),@"panel": @(MysticPanelTypeTone)},
                     @{@"type": @(MysticSettingVignette),@"panel": @(MysticPanelTypeVignette)},
//#ifdef DEBUG
//                     @{@"type": @(MysticSettingAdjustColor),@"panel": @(MysticPanelTypeAdjustColor)},
//#endif
//#ifdef DEBUG
//                     @{@"type": @(MysticSettingGrain),@"panel": @(MysticPanelTypeGrain)},
//#endif

                     @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeBrightness)},
                     @{@"type": @(MysticSettingHaze),@"panel": @(MysticPanelTypeHaze)},
                     @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSaturation)},
                     @{@"type": @(MysticSettingSkin),@"panel": @(MysticPanelTypeSkin)},

                     @{@"type": @(MysticSettingGamma),@"panel": @(MysticPanelTypeGamma)},
                     @{@"type": @(MysticSettingExposure),@"panel": @(MysticPanelTypeExposure)},
                     @{@"type": @(MysticSettingLevels),@"panel": @(MysticPanelTypeLevels)},
                     @{@"type": @(MysticSettingColorBalance),@"panel": @(MysticPanelTypeColorBalance)},
                     @{@"type": @(MysticSettingShadows),@"panel": @(MysticPanelTypeShadows)},
                     @{@"type": @(MysticSettingHighlights),@"panel": @(MysticPanelTypeHighlights)},
//                     @{@"type": @(MysticSettingUnsharpMask),@"panel": @(MysticPanelTypeUnsharpMask)},
//                     @{@"type": @(MysticSettingSharpness),@"panel": @(MysticPanelTypeSharpness)},
//                     @{@"type": @(MysticSettingTiltShift),@"panel": @(MysticPanelTypeTiltShift)},
//                     
//                     @{@"type": @(MysticSettingBlur),@"panel": @(MysticPanelTypeBlur)},
//                     @{@"type": @(MysticSettingBlurCircle),@"panel": @(MysticPanelTypeBlurCircle)},
//                     @{@"type": @(MysticSettingBlurZoom),@"panel": @(MysticPanelTypeBlurZoom)},
//                     @{@"type": @(MysticSettingBlurMotion),@"panel": @(MysticPanelTypeBlurMotion)},
//                     @{@"type": @(MysticSettingSketchFilter),@"panel": @(MysticPanelTypeSketchFilter)},
//                     @{@"type": @(MysticSettingDistortBuldge),@"panel": @(MysticPanelTypeDistortBuldge)},
//                     @{@"type": @(MysticSettingDistortPinch),@"panel": @(MysticPanelTypeDistortPinch)},
//                     @{@"type": @(MysticSettingDistortStretch),@"panel": @(MysticPanelTypeDistortStretch)},
//                     @{@"type": @(MysticSettingDistortGlassSphere),@"panel": @(MysticPanelTypeDistortGlassSphere)},
//                     @{@"type": @(MysticSettingDistortSwirl),@"panel": @(MysticPanelTypeDistortSwirl)},
//                     @{@"type": @(MysticSettingHalfTone),@"panel": @(MysticPanelTypeHalftone)},
//                     @{@"type": @(MysticSettingPosterize),@"panel": @(MysticPanelTypePosterize)},
//                     @{@"type": @(MysticSettingPixellate),@"panel": @(MysticPanelTypePixellate)},
//                     @{@"type": @(MysticSettingToon),@"panel": @(MysticPanelTypeToon)},
            

//#ifdef DEBUG
//                     @{@"type": @(MysticSettingTest),@"panel": @(MysticPanelTypeTest)},
//#endif


//                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
//                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     ];
        case MysticObjectTypeColorOverlay:
            return @[@{@"type": @(MysticSettingHSBHue),@"panel": @(MysticPanelTypeSlider)},
                     @{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSlider)},
                     @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeSlider)},
//#ifdef DEBUG
                     @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
                     @{@"type": @(MysticSettingBlending),@"panel": @(MysticPanelTypeBlend)},
                     @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeSlider)},
                     @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeSlider)},
                     @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
                     @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
                     ];
        default: break;
    }
    return @[@{@"type": @(MysticSettingSaturation),@"panel": @(MysticPanelTypeSlider)},
             @{@"type": @(MysticSettingIntensity),@"panel": @(MysticPanelTypeSlider)},
//#ifdef DEBUG
             @{@"type": @(MysticSettingMaskLayer),@"panel": @(MysticPanelTypeMask)},
//#endif
             @{@"type": @(MysticSettingBrightness),@"panel": @(MysticPanelTypeSlider)},
             @{@"type": @(MysticSettingContrast),@"panel": @(MysticPanelTypeSlider)},
             @{@"type": @(MysticSettingColorBalance),@"panel": @(MysticPanelTypeSlider)},
             @{@"type": @(MysticSettingShadows),@"panel": @(MysticPanelTypeShadows)},
             @{@"type": @(MysticSettingHighlights),@"panel": @(MysticPanelTypeHighlights)},
             @{@"type": @(option.stretchModeSetting), @"panel": @(MysticPanelTypeStretch),  @"states":@[@(MysticSettingStretchAspectFill),@(MysticSettingStretchAspectFit),@(MysticSettingStretchNone),@(MysticSettingStretchFill)]},
             @{@"type": @(MysticSettingFlipHorizontal),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipHorizontalRightColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipHorizontal?@YES:@NO},
             @{@"type": @(MysticSettingFlipVertical),@"panel": @(MysticPanelTypeFlip),@"iconSelected":@(MysticIconTypeToolFlipVerticalBottomColor),  @"canUnselect":@NO, @"toggleSelected":@YES, @"selected":option.flipVertical?@YES:@NO},
             @{@"type": @(MysticSettingInvert),@"panel": @(MysticPanelTypeInvert),@"toggleSelected":@YES, @"selected":option.inverted?@YES:@NO,@"canUnselect":@NO},

             ];
}
+ (NSArray *) sectionsForOption:(PackPotionOption *)option;
{
    NSMutableArray *sections = [NSMutableArray array];
    switch (option.type) {
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        case MysticSettingBadge:
        {
            [sections addObjectsFromArray:@[
                                            @{@"title": @"Color", @"panel": @(MysticPanelTypeColorAndIntensity)},
                                            @{@"title": @"Blend",@"panel": @(MysticPanelTypeBlend)},
                                            @{@"title": @"More",@"padding": @(MYSTIC_UI_SEGMENT_WIDTH_PADDING_LAST),@"panel": @(MysticPanelTypeMore)},
                                            ]];
            break;
        }
        case MysticObjectTypeFrame:
        {
            NSDictionary *firstOption = option && option.allowColorReplacement ?
            @{
              @"title": @"Color",
              @"panel": @(MysticPanelTypeColorAndIntensity)
              }
            : @{
                @"title": @"Adjust",
                @"panel": @(MysticPanelTypeAdjust)
                };
            
            
            
            [sections addObjectsFromArray:@[
                                            
                                            
                                            firstOption,
                                            @{@"title": @"Blend",@"panel": @(MysticPanelTypeBlend)},
                                            @{
                                                @"title": @"More",
                                                @"padding": @(MYSTIC_UI_SEGMENT_WIDTH_PADDING_LAST),
                                                @"panel": @(MysticPanelTypeMore)
                                                },
                                            ]];
            break;
        }
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
        {
            [sections addObjectsFromArray:@[
                                            @{
                                                @"title": @"Adjust",
                                                @"panel": @(MysticPanelTypeAdjust)
                                                },
                                            @{
                                                @"title": @"Blend",
                                                @"panel": @(MysticPanelTypeBlend)
                                                },
                                            
                                            @{
                                                @"title": @"More",
                                                @"padding": @(MYSTIC_UI_SEGMENT_WIDTH_PADDING_LAST),
                                                @"panel": @(MysticPanelTypeMore)
                                                },
                                            ]];
            break;
        }
        default: break;
    }
    return sections;
}
- (void) updateWithTargetOption:(PackPotionOption *)option;
{
    
}


+ (NSArray *) toolbarItemsForSection:(MysticPanelObject *)section type:(MysticObjectType)objectType target:(id)target toolbar:(MysticLayerToolbar *)toolbar;
{
    
    
    MysticObjectType lastLoadedPackType = objectType;
    MysticIconType cancelIconType = MysticIconTypeToolBarX;
    CGSize cancelIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM);
    NSString *labelTitle = nil;
    BOOL labelEnabled = YES;
    BOOL useToggler = NO;
    BOOL useTogglerAndLabel = NO;
    id targetCancel = target;
    id targetConfirm = target;
    id targetLabel = target;
    BOOL buttonsHidden = NO;
    
    switch (objectType) {
            
        case MysticObjectTypeSpecial:
        case MysticObjectTypePotion:
        {
            NSString *labelTitle;
            buttonsHidden = YES;
            switch (objectType) {
                case MysticObjectTypeSpecial:
                    buttonsHidden = NO;
                    labelTitle = [MysticObjectTypeTitleParent(objectType, MysticObjectTypeUnknown) uppercaseString];
                    break;
                    
                default:
                    labelTitle = @"";
                    break;
            }
            CGFloat toolWidth = 56.0f;
            CGFloat paddingWidth = MYSTIC_UI_TOOLBAR_MARGIN;
            CGRect packLabelFrame = CGRectMake(0, 0, [MysticUI size].width-(toolWidth*2) - (paddingWidth*6), toolbar.frame.size.height);
            
            
            MysticToolbarTitleButton *packLabel = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:nil action:nil];
            packLabel.frame = packLabelFrame;
            packLabel.textColor = [UIColor color:MysticColorTypeMenuText];
            packLabel.backgroundColor = [UIColor clearColor];
            packLabel.tag = MysticUITypeLabel;
            packLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            packLabel.toolType = MysticToolTypeBrowsePacks;
            packLabel.objectType = lastLoadedPackType;
            packLabel.enabled = NO;

            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:labelTitle];
            [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
            [attrStr setTextColor:[UIColor color:MysticColorTypeMenuText]];
            [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
            
            NSRange strRange = NSMakeRange(0, [labelTitle length]);
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [attrStr addAttribute:NSParagraphStyleAttributeName
                            value:style
                            range:strRange];
            
            [style release];
            
            
            
            [packLabel setAttributedTitle:attrStr forState:UIControlStateNormal];
            [packLabel setAttributedTitle:attrStr forState:UIControlStateHighlighted];
            [packLabel setAttributedTitle:attrStr forState:UIControlStateSelected];
            
            
            packLabel.textAlignment = NSTextAlignmentCenter;
            
            CGSize lSize = [labelTitle sizeWithFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE] constrainedToSize:(CGSize)packLabel.bounds.size];
            CGRect attrBounds = CGRectSize(lSize);
            CGRect borderFrame = (CGRect){0,0, ceilf(attrBounds.size.width) + MYSTIC_UI_LABEL_BTN_PADDING_X*4, MYSTIC_UI_LABEL_BTN_HEIGHT};
            borderFrame = MysticPositionRect(borderFrame, packLabel.bounds, MysticPositionCenter);
            UIView *packLabelBorder = [[[UIView alloc] initWithFrame:borderFrame] autorelease];
            packLabelBorder.layer.cornerRadius = MYSTIC_UI_LABEL_BTN_BORDER_RADIUS;
            packLabelBorder.layer.borderColor = [[UIColor hex:@"5f544e"] colorWithAlphaComponent:0.7].CGColor;
            packLabelBorder.layer.borderWidth = MYSTIC_UI_LABEL_BTN_BORDER;
            packLabelBorder.userInteractionEnabled = NO;
            packLabelBorder.tag = MysticViewTypeBorderButton;
            packLabelBorder.hidden = YES;
            [packLabel addSubview:packLabelBorder];
            packLabel.ready=YES;
            
            return @[
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     
                     
                     @{@"toolType": @(MysticToolTypeCancel),
                       @"target": target,
                       @"hidden": @(buttonsHidden),
                       @"action": @"toolBarCanceledOption:",
                       @"iconType":@(MysticIconTypeToolBarX),
                       @"color":@(MysticColorTypeMenuIconCancel),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM)],
                       @"width":@(toolbar.frame.size.height+10),
                       @"objectType":@(objectType)},
                     
                     
                     @(MysticToolTypeFlexible),
                     @{@"toolType":@(MysticToolTypeCustom), @"view": packLabel, @"width":@(packLabelFrame.size.width)},
                     @(MysticToolTypeFlexible),
                     
                     @{
                         @"toolType": @(MysticToolTypeConfirm),
                         @"iconType":@(MysticIconTypeToolBarConfirm),
                         @"hidden": @(buttonsHidden),
                         @"color":@(MysticColorTypeMenuIconConfirm),
                         @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                         @"target": target,
                         @"action": @"toolBarConfirmedOption:",
                         @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM)],
                         @"width":@(toolbar.bounds.size.height+10),
                         @"objectType":@(objectType),
                         },
                     
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     ];
        }
        case MysticSettingVibrance:
        case MysticSettingSkin:
        case MysticSettingColor:
        case MysticSettingColorAndIntensity:
        case MysticSettingIntensity:
        case MysticSettingBlending:
        case MysticSettingSaturation:
        case MysticSettingExposure:
        case MysticSettingGamma:
        case MysticSettingTemperature:
        case MysticSettingWearAndTear:
        case MysticSettingBrightness:
        case MysticSettingContrast:
        case MysticSettingHaze:
        case MysticSettingBackground:
        case MysticSettingBackgroundColor:
        case MysticSettingFalseColor:
        case MysticSettingShadows:
        case MysticSettingHighlights:
        case MysticSettingHSBSaturation:
        case MysticSettingHSBBrightness:
        case MysticSettingHSBHue:
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceRed:
        case MysticSettingSharpness:
        case MysticSettingTiltShift:
        case MysticSettingUnsharpMask:
        case MysticSettingVignette:
        case MysticSettingVignetteBlending:
        case MysticSettingLevels:
        case MysticSettingMaskLayer:
        case MysticSettingMaskBrush:
        case MysticSettingMaskEmpty:
        case MysticSettingMaskErase:
        case MysticSettingMaskFill:
        case MysticSettingBlurCircle:
        case MysticSettingBlur:
        case MysticSettingBlurZoom:
        case MysticSettingBlurMotion:
        case MysticSettingBlurGaussian:
        case MysticSettingDistortPinch:
        case MysticSettingDistortSwirl:
        case MysticSettingDistortBuldge:
        case MysticSettingDistortStretch:
        case MysticSettingDistortGlassSphere:
        case MysticSettingToon:
        case MysticSettingPosterize:
        case MysticSettingPixellate:
        case MysticSettingHalfTone:
        case MysticSettingSketchFilter:


        {
            CGFloat toolWidth = 56.0f;
            CGFloat paddingWidth = MYSTIC_UI_TOOLBAR_MARGIN;
            CGRect packLabelFrame = CGRectMake(0, 0, [MysticUI size].width-(toolWidth*2) - (paddingWidth*6), toolbar.frame.size.height);
            NSString *labelTitle = nil;
            
            NSInteger activeTab = section.activeTab == NSNotFound ? 0 : section.activeTab;
            MysticTabBar *tabBar = [(MysticPanelContentView *)section.panel.contentView viewWithClass:[MysticTabBar class]];
            
            MysticTabButton *tabButton = tabBar ? [tabBar tabAtIndex:activeTab] : nil;
            if(tabButton) labelTitle = MysticObjectTypeTitleParent(tabButton.type, MysticObjectTypeUnknown);
            if(!labelTitle) labelTitle = MysticObjectTypeTitleParent(objectType, MysticObjectTypeUnknown);
            labelTitle = [labelTitle uppercaseString];
            
            MysticToolbarTitleButton *packLabel = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:nil action:nil];
            packLabel.frame = packLabelFrame;
            packLabel.textColor = [UIColor color:MysticColorTypeMenuText];
            packLabel.backgroundColor = [UIColor clearColor];
            packLabel.tag = MysticUITypeLabel;
            packLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            packLabel.toolType = MysticToolTypeBrowsePacks;
            packLabel.objectType = lastLoadedPackType;

            packLabel.enabled = NO;
            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:labelTitle];
            [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
            [attrStr setTextColor:[UIColor color:MysticColorTypeMenuText]];
            [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
            [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByTruncatingTail];
            
            NSRange strRange = NSMakeRange(0, [labelTitle length]);
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [attrStr addAttribute:NSParagraphStyleAttributeName
                            value:style
                            range:strRange];
            
            [style release];
            [packLabel setAttributedTitle:attrStr forState:UIControlStateNormal];
            [packLabel setAttributedTitle:attrStr forState:UIControlStateHighlighted];
            [packLabel setAttributedTitle:attrStr forState:UIControlStateSelected];
            CGSize lSize = [labelTitle sizeWithFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE] constrainedToSize:(CGSize)packLabel.bounds.size];
            CGRect attrBounds = CGRectSize(lSize);
            
            CGRect borderFrame = (CGRect){0,0, ceilf(attrBounds.size.width) + MYSTIC_UI_LABEL_BTN_PADDING_X*4, MYSTIC_UI_LABEL_BTN_HEIGHT};
            borderFrame = MysticPositionRect(borderFrame, packLabel.bounds, MysticPositionCenter);
            UIView *packLabelBorder = [[[UIView alloc] initWithFrame:borderFrame] autorelease];
            
            
            packLabelBorder.layer.cornerRadius = MYSTIC_UI_LABEL_BTN_BORDER_RADIUS;
            packLabelBorder.layer.borderColor = [[UIColor hex:@"5f544e"] colorWithAlphaComponent:0.7].CGColor;
            packLabelBorder.layer.borderWidth = MYSTIC_UI_LABEL_BTN_BORDER;
            packLabelBorder.userInteractionEnabled = NO;
            packLabelBorder.tag = MysticViewTypeBorderButton;
            packLabelBorder.hidden = YES;
            [packLabel addSubview:packLabelBorder];
            packLabel.ready=YES;
            
            UIView *centerView = nil;
            switch (section.sectionType)
            {
                case MysticPanelTypeMask:
                {
                    packLabel.frame = CGRectWidth(packLabel.frame, 100);
                    UIView *sectionBar = [[UIView alloc] initWithFrame:(CGRect){0,0,350, 55}];
                    [sectionBar addSubview:packLabel];
                    
                    MysticLayerToolbar *newToolbar = [MysticLayerToolbar toolbarWithFrame:(CGRect){76,0, sectionBar.bounds.size.width-76,sectionBar.frame.size.height }];
                    newToolbar.backgroundColor = toolbar.backgroundColor;
                    CGSize iconSize = CGSizeMake(20, 20);
                    [newToolbar useItems:@[
                                           @{@"toolType": @(MysticToolTypeStatic),
                                             @"width":@(-18)},
                                           @{@"toolType": @(MysticToolTypeStatic),
                                             @"width":@(15)},
                                           
                                           @{@"toolType":@(MysticToolTypeMaskErase),@"target": newToolbar, @"iconType": @(MysticIconTypeMaskErase), @"width":@(toolbar.bounds.size.height),
                                             @"color":@(MysticColorTypeMenuIconCancel), @"colorSelected":@(MysticColorTypeMenuIconConfirm), @"canSelect": @YES, @"selected":@YES,
                                             @"iconSize": [NSValue valueWithCGSize:iconSize],},
                                           
                                           
                                           @{@"toolType": @(MysticToolTypeStatic), @"width":@(0)},
                                           
                                           
                                           @{@"toolType":@(MysticToolTypeMaskBrush),@"target": newToolbar, @"iconType": @(MysticIconTypeMaskBrush), @"width":@(toolbar.bounds.size.height),
                                             @"color":@(MysticColorTypeMenuIconCancel), @"colorSelected":@(MysticColorTypeMenuIconConfirm),@"canSelect": @YES,
                                             @"iconSize": [NSValue valueWithCGSize:iconSize],},
                                           
                                           @{@"toolType": @(MysticToolTypeStatic), @"width":@(0)},
                                           
                                           
                                           @{@"toolType":@(MysticToolTypeMaskFill),@"target": newToolbar, @"iconType": @(MysticIconTypeMaskFill), @"width":@(toolbar.bounds.size.height),
                                             @"color":@(MysticColorTypeMenuIconCancel), @"colorSelected":@(MysticColorTypeMenuIconConfirm), @"canSelect": @YES,
                                             @"iconSize": [NSValue valueWithCGSize:iconSize],},
                                           
                                           @{@"toolType": @(MysticToolTypeStatic), @"width":@(0)},
                                           
                                           
                                           @{@"toolType":@(MysticToolTypeMaskEmpty),@"target": newToolbar, @"iconType": @(MysticIconTypeMaskEmpty), @"width":@(toolbar.bounds.size.height),
                                             @"color":@(MysticColorTypeMenuIconCancel), @"colorSelected":@(MysticColorTypeMenuIconConfirm), @"canSelect": @YES,
                                             @"iconSize": [NSValue valueWithCGSize:iconSize],},
                                           
                                           
                                           
                                           @{@"toolType": @(MysticToolTypeStatic),
                                             @"width":@(-18)},
                                           ]];
                   
                    [sectionBar addSubview:newToolbar];
                    newToolbar.onChange = ^(MysticBarButton *sender, UIEvent *event, MysticLayerToolbar *toolbar)
                    {
                        
                        switch (sender.toolType) {
                            case MysticToolTypeMaskBrush:
                            {
                                [toolbar selectItem:sender];
                                [MysticController controller].sketchView.toolType = MysticSketchToolTypeMaskErase;
                                break;
                            }
                            case MysticToolTypeMaskErase:
                            {
                                [toolbar selectItem:sender];
                                [MysticController controller].sketchView.toolType = MysticSketchToolTypeMask;
                                break;
                            }
                            case MysticToolTypeMaskFill:
                            {
                                [[MysticController controller].sketchView fill];
                                [toolbar selectItem:[toolbar buttonForType:MysticToolTypeMaskBrush]];
                                [MysticController controller].sketchView.toolType = MysticSketchToolTypeMaskErase;
                                break;
                            }
                            case MysticToolTypeMaskEmpty:
                            {
                                [[MysticController controller].sketchView empty];
                                [toolbar selectItem:[toolbar buttonForType:MysticToolTypeMaskErase]];
                                [MysticController controller].sketchView.toolType = MysticSketchToolTypeMask;

                                break;
                            }
                            default:
                                break;
                        }
                    };
                    
                    
                    return @[
                             @{@"toolType": @(MysticToolTypeStatic),
                               @"width":@(-18)},
                             
                             @{@"toolType":@(MysticToolTypeCustom), @"view": sectionBar, @"width":@(sectionBar.frame.size.width)},
                             @(MysticToolTypeFlexible),
                             
                             @{
                                 @"toolType": @(MysticToolTypeConfirm),
                                 @"iconType":@(MysticIconTypeToolBarConfirm),
                                 @"hidden": @(buttonsHidden),
                                 @"color":@(MysticColorTypeMenuIconConfirm),
                                 @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                                 @"target": target,
                                 @"action": @"toolBarConfirmedOptionSetting:",
                                 @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM)],
                                 @"width":@(toolbar.bounds.size.height+10),
                                 @"objectType":@(objectType),
                                 },
                             
                             @{@"toolType": @(MysticToolTypeStatic),
                               @"width":@(-18)},
                             ];
                }
                default: break;
            }
            
            return @[
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     
                     
                     @{@"toolType": @(MysticToolTypeCancel),
                       @"target": target,
                       @"hidden": @(buttonsHidden),
                       
                       @"action": @"toolBarCanceledOptionSetting:",
                       @"iconType":@(MysticIconTypeToolBarX),
                       @"color":@(MysticColorTypeMenuIconCancel),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL)],
                       @"width":@(toolbar.frame.size.height+10),
                       @"objectType":@(objectType)},
                     
                     
                     @(MysticToolTypeFlexible),
                     @{@"toolType":@(MysticToolTypeCustom), @"view": packLabel, @"width":@(packLabelFrame.size.width)},
                     @(MysticToolTypeFlexible),
                     
                     @{
                         @"toolType": @(MysticToolTypeConfirm),
                         @"iconType":@(MysticIconTypeToolBarConfirm),
                         @"color":@(MysticColorTypeMenuIconConfirm),
                         @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                         @"hidden": @(buttonsHidden),
                         
                         @"target": target,
                         @"action": @"toolBarConfirmedOptionSetting:",
                         @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM)],
                         @"width":@(toolbar.bounds.size.height+10),
                         @"objectType":@(objectType),
                         },
                     
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     ];
            break;
        }
        case MysticObjectTypeSetting:
        case MysticObjectTypeFont:
        case MysticObjectTypeFontStyle:
        case MysticSettingChooseFont:
        case MysticSettingEditType:
        case MysticSettingEditFont:
        case MysticSettingType:
        case MysticSettingTypeNew:
        case MysticSettingShape:
        case MysticObjectTypeShape:
        {
            MysticButton *closeBtn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolHide) size:(CGSize){10, 6} color:[UIColor hex:@"d6d0bf"]] target:target sel:@selector(toolBarHide:)];
            closeBtn.backgroundColor = [UIColor hex:@"3f3834"];
            closeBtn.frame = (CGRect){0,kBottomToolBarHeight,[MysticUI screen].width, MYSTIC_UI_TOOLBAR_HIDE_HEIGHT};
            toolbar.swipeDownToClose = YES;
            return @[
                     @{@"toolType": @(MysticToolTypeStatic), @"width":@(-18)},
                     
                     @(MysticToolTypeFlexible),
                     @{@"toolType":@(MysticToolTypeCustom), @"view": closeBtn, @"width":@(closeBtn.frame.size.width), @"eventAdded":@YES},
                     @(MysticToolTypeFlexible),
                     
                     @{@"toolType": @(MysticToolTypeStatic), @"width":@(-18)},
                     ];
        }
        case MysticObjectTypeSketch:
        {
            NSString *targetCancelAction = @"toolBarCanceledSketchOption:";
            NSString *targetConfirmAction = @"toolBarConfirmedSketchOption:";
            return @[
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     
                     
                     @{@"toolType": @(MysticToolTypeCancel),
                       @"target": targetCancel,
                       @"action": targetCancelAction,
                       @"iconType":@(cancelIconType),
                       @"color":@(MysticColorTypeMenuIconCancel),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"contentMode": @(UIViewContentModeCenter),
                       @"iconSize": [NSValue valueWithCGSize:cancelIconSize],
                       @"width":@(toolbar.frame.size.height + 10),
                       @"objectType":@(MysticObjectTypeSketch)},
                     
                     
                     @(MysticToolTypeFlexible),
                     
                     
                     @{@"toolType": @(MysticToolTypeCustom),
                       @"target": target,
                       @"action": @"toolBarUndo:",
                       @"enabled":@NO,
                       @"iconType":@(MysticIconTypeSketchUndo),
                       @"color":@(MysticColorTypeMenuIconUndo),
                       @"colorDisabled":@(MysticColorTypeMenuIconUndoDisabled),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"contentMode": @(UIViewContentModeCenter),
                       @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_BRUSH_ICON_BOTTOMBAR, MYSTIC_BRUSH_ICON_BOTTOMBAR)],
                       @"width":@(MYSTIC_BRUSH_ICON_BOTTOMBAR + 10),
                       @"tag":@(MysticViewTypeUndo),
                       @"objectType":@(MysticObjectTypeSketch)},
                     
//                     @{@"toolType": @(MysticToolTypeStatic),
//                       @"width":@(10)},
                     
                     
                     @{@"toolType": @(MysticToolTypeCustom),
                       @"target": target,
                       @"action": @"toolBarRedo:",
                       @"enabled":@NO,
                       @"iconType":@(MysticIconTypeSketchRedo),
                       @"color":@(MysticColorTypeMenuIconRedo),
                       @"colorDisabled":@(MysticColorTypeMenuIconRedoDisabled),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"contentMode": @(UIViewContentModeCenter),
                       @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_BRUSH_ICON_BOTTOMBAR, MYSTIC_BRUSH_ICON_BOTTOMBAR)],
                       @"width":@(MYSTIC_BRUSH_ICON_BOTTOMBAR + 10),
                       @"tag":@(MysticViewTypeRedo),
                       @"objectType":@(MysticObjectTypeSketch)},
                     
                     
                     @(MysticToolTypeFlexible),
                     
                     @{
                         @"toolType": @(MysticToolTypeConfirm),
                         @"iconType":@(MysticIconTypeToolBarConfirm),
                         @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM_SKETCH, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM_SKETCH)],
                         @"color":@(MysticColorTypeMenuIconConfirm),
                         @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                         @"target": targetConfirm,
                         @"action": targetConfirmAction,
                         @"width":@(toolbar.bounds.size.height+10),
                         @"objectType":@(MysticObjectTypeSketch),
                         },
                     
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18),
                       @"objectType":@(lastLoadedPackType)},
                     ];

        }
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeLight:
        case MysticObjectTypeFrame:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFilter:
        default:
        {
            useToggler = YES;
            BOOL useRadial = YES;
            CGFloat toolWidth = 56.0f;
            CGFloat paddingWidth = MYSTIC_UI_TOOLBAR_MARGIN;
            CGRect packLabelFrame = CGRectMake(0, 0, [MysticUI size].width-(toolWidth*2) - (paddingWidth*6), toolbar.frame.size.height);
            BOOL labelCanSelect = NO;
            BOOL labelBorderHidden = NO;
            BOOL useLabel = NO;
            MysticPack *pack = section.pack ? section.pack : [MysticController controller].activePack;
            NSString *targetCancelAction = @"toolBarCanceledOption:";
            NSString *targetConfirmAction = @"toolBarConfirmedOption:";
            NSString *targetLabelAction = @"toolBarLabelTouched:";
            MysticToolType labelToolType = MysticToolTypeBrowsePacks;
            
            switch (section.sectionType)
            {
                case MysticPanelTypeOptionImageLayerSettings:
                    labelTitle = section.toolbarTitle ? section.toolbarTitle : @"EDIT PHOTO";
                    labelEnabled=NO;
                    break;
                case MysticPanelTypeMask:
                    labelTitle = @"Mask";
                    labelToolType = MysticToolTypeCustom;
                    labelEnabled = NO;
                    
                    break;
                case MysticPanelTypeOptionLayerSettings:
                    labelTitle = section.toolbarTitle ? section.toolbarTitle : [[MysticObjectTypeTitleParent(objectType, 0) stringByAppendingString:@" Tools"] uppercaseString];
                    targetCancelAction = @"toolBarCanceledOptionSetting:";
                    targetConfirmAction = @"toolBarConfirmedOptionSetting:";
                    labelToolType = MysticToolTypeCustom;
                    labelEnabled = NO;
                    break;
                case MysticPanelTypeOptionFilter:
                    useRadial = NO;
                    labelTitle = section.toolbarTitle ? section.toolbarTitle :  MysticObjectTypeTitleParent(MysticObjectTypeFilter, 0);
                    labelToolType = MysticToolTypeCustom;
                    labelEnabled = NO;
                    
                    break;
                case MysticPanelTypeOptionFilterSettings:
                    labelTitle = @"INTENSITY";
                    targetCancelAction = @"toolBarCanceledOptionSetting:";
                    targetConfirmAction = @"toolBarConfirmedOptionSetting:";
                    labelToolType = MysticToolTypeCustom;
                    labelEnabled = NO;
                    
                    break;
                case MysticPanelTypeOptionColorAdjust:
                    labelTitle = @"ADJUST";
                    targetCancelAction = @"toolBarResetOptionSetting:";
                    targetConfirmAction = @"toolBarConfirmedOptionSetting:";
                    labelToolType = MysticToolTypeCustom;
                    cancelIconType = MysticIconTypeReset;
                    cancelIconSize = (CGSize){23,23};
                    labelEnabled = NO;
                    
                    break;
                default:
                {
                    labelTitle = pack ? [pack.title uppercaseString] : [MysticObjectTypeTitleParent(objectType, 0) uppercaseString];
                    break;
                }
            }
            
            
            if(section.panelConfirmedBlock)
            {
                targetConfirm = section;
                targetConfirmAction = @"panelConfirmed:";
                
            }
            if(section.panelCancelledBlock)
            {
                targetCancel = section;
                targetCancelAction = @"panelCancelled:";
            }
            if(section.panelTouchedBlock)
            {
                targetLabel = section;
                targetLabelAction = @"panelTouched:";
                
            }
            
            switch (objectType) {
                case MysticObjectTypeColorOverlay:
                    labelEnabled = NO;
                    labelBorderHidden = YES;
                    useLabel = YES;
                    useToggler = NO;
                    break;
                case MysticObjectTypeBadge:
                    labelEnabled = NO;
                    labelBorderHidden = YES;
                    useLabel = NO;
                    useToggler = YES;
                    break;
                case MysticObjectTypeFilter:
                    useLabel = YES;
                    useToggler = NO;
                    labelBorderHidden = YES;
                    labelEnabled = NO;
                    break;
                    
                default:
                    useLabel = YES;
                    break;
            }
            useTogglerAndLabel = useLabel && useToggler;

            UIView *centerView = nil;
            if(useLabel && (!useToggler || useTogglerAndLabel))
            {
                MysticToolbarTitleButton *packLabel = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:nil action:nil];
                packLabel.frame = packLabelFrame;
                packLabel.canSelect = labelCanSelect;
                packLabel.backgroundColor = [UIColor clearColor];
                packLabel.tag = MysticUITypeLabel;
                packLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                packLabel.textAlignment = NSTextAlignmentCenter;
                packLabel.toolType = MysticToolTypeBrowsePacks;
                packLabel.objectType = lastLoadedPackType;
                packLabel.enabled = labelEnabled;
                packLabel.textColor = [UIColor color:MysticColorTypeMenuText];
                if(labelTitle)
                {
                    section.title = labelTitle;
                    section.toolbarTitle = labelTitle;
                    
                    
                    
                    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:labelTitle];
                    [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                    [attrStr addAttribute:NSForegroundColorAttributeName
                                    value:packLabel.textColor
                                    range:NSMakeRange(0, labelTitle.length)];
                    [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
                    [packLabel setAttributedTitle:attrStr forState:UIControlStateNormal];
                    
                    CGSize lSize = [labelTitle sizeWithFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE] constrainedToSize:(CGSize)packLabel.bounds.size];
                    CGRect attrBounds = CGRectSize(lSize);
                    
                    
                    attrBounds = CGRectIntegral(attrBounds);
                    
                    
                    
                    if(labelEnabled)
                    {
                        NSMutableAttributedString *attrStr2 = [NSMutableAttributedString attributedStringWithString:labelTitle];
                        [attrStr2 setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                        [attrStr2 setTextColor:[UIColor color:MysticColorTypeMenuText]];
                        [attrStr2 addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor color:MysticColorTypeMenuText]
                                         range:NSMakeRange(0, labelTitle.length)];
                        
                        [attrStr2 setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
                        
                        NSRange strRange = NSMakeRange(0, [labelTitle length]);
                        
                        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                        style.alignment = NSTextAlignmentCenter;
                        [attrStr2 addAttribute:NSParagraphStyleAttributeName
                                         value:style
                                         range:strRange];
                        
                        [style release];
                        
                        [packLabel setAttributedTitle:attrStr2 forState:UIControlStateNormal];
                        [packLabel setAttributedTitle:attrStr2 forState:UIControlStateHighlighted];
                        [packLabel setAttributedTitle:attrStr2 forState:UIControlStateSelected];
                    }
                    packLabel.ready=YES;
                    [packLabel updateState];
                    
                    
                }
                centerView = packLabel;
                
                
            }
            if(useToggler)
            {
                UIView *toggleCenterView = [[[MysticView alloc] initWithFrame:packLabelFrame] autorelease];
                toggleCenterView.tag = MysticViewTypeToggler + MysticViewTypePanel;
                CGSize togglerSize = CGSizeMake(32.f, 32.f);
                toggleCenterView.autoresizesSubviews = YES;
                UIView *tog = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, togglerSize.width+6, togglerSize.height+6)] autorelease];
                tog.backgroundColor = [UIColor hex:@"1b1b17"];
                tog.layer.cornerRadius = (togglerSize.width+8)*.5;
                tog.tag = MysticViewTypeToggler + MysticViewTypeSubView;
                tog.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
                
                CGPoint toggleCenter = (CGPoint){packLabelFrame.size.width/2, packLabelFrame.size.height/2};
                
                MysticToggleButton *toggler = [[[MysticToggleButton alloc] initWithFrame:CGRectMake(3, 3, togglerSize.width, togglerSize.height)] autorelease];
                toggler.animateImageDuration = 0.6;
                
                
                toggler.hitInsets = UIEdgeInsetsMake(12, 12, 12, 12);
                toggler.iconStyle = MysticIconTypeImage;
                toggler.iconColorType = MysticColorTypeUnknown;
                toggler.minToggleState = MysticLayerEffectNone;
                toggler.tag = MysticViewTypeToggler;
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect0) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectNone];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect1) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectInverted];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect2) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectDesaturate];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect3) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectOne];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect4) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectTwo];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect5) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectThree];
                [toggler setImage:[MysticImage image:@(MysticIconTypeEffect6) size:togglerSize color:@(MysticColorTypeUnknown)] forState:MysticLayerEffectFour];
                toggler.maxToggleState = MysticLayerEffectFour;
                toggler.toolType = MysticToolTypeVariant;
                toggler.hitInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                toggler.onToggle = ^(MysticToggleButton *toggleSender)
                {
                    BOOL isReset = toggleSender.previousToggleState != toggleSender.minToggleState && toggleSender.toggleState == toggleSender.minToggleState;
                    CGFloat d = (float)((float)MIN(toggleSender.toggleState, toggleSender.maxToggleState - 2)/(float)toggleSender.maxToggleState)*(isReset ? 1 : -1);
                    NSTimeInterval duration = isReset ? toggleSender.hasToggled ? 0.4 : 0.2 : 0.2;
//                    CGFloat scale = !isReset ? 1 : .7;
                    CGFloat scale = 1;

                    CGFloat rotateAmount = degreesToRadians((180.0/(float)toggleSender.numberOfToggleStates));
                    CGAffineTransform rotationTransform = CGAffineTransformScale(CGAffineTransformRotate(toggleSender.transform, rotateAmount), scale, scale);
                    toggleSender.transform = !isReset ? rotationTransform : CGAffineTransformScale(CGAffineTransformRotate(toggleSender.transform, (M_PI / 2.0)), scale, scale);
                    [MysticUIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        toggleSender.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        [target performSelector:@selector(toolBarLabelTouched:) withObject:toggleSender];
                        [toggleSender finishedOnToggle];
                    }];
                    
                };
                toggler.onToggleTarget = target;
                toggler.onToggleAction = @selector(toggleButtonToggled:);
                tog.center = toggleCenter;
                [tog addSubview:toggler];
                [toggleCenterView addSubview:tog];
                if(useToggler && !useTogglerAndLabel) centerView = toggleCenterView;
                else
                {
                    MysticBarButtonItem *toggleItem = [[MysticBarButtonItem alloc] initWithCustomView:toggleCenterView];
                    // added aytorelease does it work?
                    toolbar.titleToggleView = [toggleItem autorelease];
                    toolbar.titleToggleIndex = 3;
                }
            }
            
            
            
            
            return @[
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18)},
                     
                     
                     @{@"toolType": @(MysticToolTypeCancel),
                       @"target": targetCancel,
                       @"action": targetCancelAction,
                       @"iconType":@(cancelIconType),
                       @"hidden": @(buttonsHidden),
                       
                       @"color":@(MysticColorTypeMenuIconCancel),
                       @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                       @"contentMode": @(UIViewContentModeCenter),
                       @"iconSize": [NSValue valueWithCGSize:cancelIconSize],
                       @"width":@(toolbar.frame.size.height + 10),
                       @"objectType":@(lastLoadedPackType)},
                     
                     
                     @(MysticToolTypeFlexible),
                     
                     @{@"toolType":@(labelToolType),
                       @"view": centerView,
                       @"width":@(centerView.frame.size.width),
                       @"objectType":@(lastLoadedPackType),
                       @"target": targetLabel,
                       @"action": targetLabelAction,},
                     
                     
                     @(MysticToolTypeFlexible),
                     
                     @{
                         @"toolType": @(MysticToolTypeConfirm),
                         @"iconType":@(MysticIconTypeToolBarConfirm),
                         @"iconSize": [NSValue valueWithCGSize:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM)],
                         @"color":@(MysticColorTypeMenuIconConfirm),
                         @"colorHighlighted":@(MysticColorTypeMenuIconHighlighted),
                         @"hidden": @(buttonsHidden),
                         @"target": targetConfirm,
                         @"action": targetConfirmAction,
                         @"width":@(toolbar.bounds.size.height+10),
                         @"objectType":@(lastLoadedPackType),
                         },
                     
                     @{@"toolType": @(MysticToolTypeStatic),
                       @"width":@(-18),
                       @"objectType":@(lastLoadedPackType)},
                     ];
        }
            
    }
    return nil;
}

+ (void) resetToolbarForSection:(MysticPanelObject *)section target:(id)target toolbar:(MysticLayerToolbar *)toolbar;
{
    switch(section.setting)
    {
        case MysticSettingVignetteBlending:
            [toolbar replaceItemsWithInfo:[self toolbarItemsForSection:section type:MysticSettingVignetteBlending target:toolbar.delegate toolbar:toolbar] animated:NO];
            [toolbar setTitle:MysticObjectTypeTitleParent(section.setting, nil) animated:NO];
            return;
        case MysticSettingVignette:
            [toolbar replaceItemsWithInfo:[self toolbarItemsForSection:section type:MysticSettingVignette target:toolbar.delegate toolbar:toolbar] animated:NO];
            [toolbar setTitle:MysticObjectTypeTitleParent(section.setting, nil) animated:NO];
            return;
        default: break;
    }
    switch (section.optionType) {
        
        case MysticSettingVignetteBlending:
            [toolbar replaceItemsWithInfo:[self toolbarItemsForSection:section type:MysticSettingVignetteBlending target:toolbar.delegate toolbar:toolbar] animated:NO];
            break;
        case MysticSettingVignette:
            [toolbar replaceItemsWithInfo:[self toolbarItemsForSection:section type:MysticSettingVignette target:toolbar.delegate toolbar:toolbar] animated:NO];
            break;
        case MysticObjectTypeShape:
        case MysticSettingShape:
        case MysticObjectTypeFont:
        case MysticObjectTypeSetting:
            break;
        
        
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeLight:
        case MysticObjectTypeFrame:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFilter:
        default:
        {
//            MysticView *centerView = [toolbar itemWithTag:MysticViewTypeToggler + MysticViewTypePanel];
//            
//            if(centerView)
//            {
//                UIView *subCenterView = [centerView viewWithTag:MysticViewTypeToggler + MysticViewTypeSubView];
//                if(subCenterView)
//                {
//                    MysticToggleButton *toggler = (id)[subCenterView viewWithTag:MysticViewTypeToggler];
//                    if(toggler)
//                    {
//                        [toggler reset];
//                        if(section.targetOption) toggler.toggleState = [(PackPotionOption *)section.targetOption layerEffect];
//                    }
//                }
//            }
            break;
        }
    }
}



@end

//
//  MysticIcon.m
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticIcon.h"
#import <QuartzCore/QuartzCore.h>
#import "MysticColor.h"

#define PADDING 4.f

CGPoint MyPoint(CGSize size, CGSize oldSize, CGPoint oldPoint)
{
    if(CGSizeEqualToSize(size, oldSize)) return oldPoint;
    CGPoint newPoint = oldPoint;
    newPoint.x = (oldPoint.x * size.width)/oldSize.width;
    newPoint.y = (oldPoint.y *size.height)/oldSize.height;
    return newPoint;
}

@implementation MysticIcon

@synthesize color=_color, customImage=_customImage, padding=_padding;

+ (MysticIconType) iconTypeForObjectType:(MysticObjectType)objectType;
{
    switch (objectType) {
#ifdef DEBUG
        case MysticSettingTest: return MysticIconTypeTest;
#endif
        case MysticSettingBlur: return MysticIconTypeBlur;
        case MysticSettingBlurCircle: return MysticIconTypeBlurCircle;
        case MysticSettingBlurZoom: return MysticIconTypeBlurZoom;
        case MysticSettingBlurGaussian: return MysticIconTypeBlurGaussian;
        case MysticSettingBlurMotion: return MysticIconTypeBlurMotion;
        case MysticSettingHalfTone: return MysticIconTypeHalfTone;
        case MysticSettingSketchFilter: return MysticIconTypeSketchFilter;
        case MysticSettingPosterize: return MysticIconTypePosterize;
        case MysticSettingDistortBuldge: return MysticIconTypeDistortBuldge;
        case MysticSettingDistortPinch: return MysticIconTypeDistortPinch;
        case MysticSettingDistortStretch: return MysticIconTypeDistortStretch;
        case MysticSettingDistortGlassSphere: return MysticIconTypeDistortGlassSphere;
        case MysticSettingDistortSwirl: return MysticIconTypeDistortSwirl;
        case MysticSettingPixellate: return MysticIconTypePixellate;
        case MysticSettingToon: return MysticIconTypeToon;
            
        case MysticSettingInvert: return MysticIconTypeInvert;
        case MysticSettingSketchBrush: return MysticIconTypeSketchBrush;
        case MysticSettingSketchEraser: return MysticIconTypeSketchEraser;
        case MysticSettingSketchLayers: return MysticIconTypeSketchLayers;
        case MysticSettingSketchSettings: return MysticIconTypeSketchSettings;
//        case MysticSettingSketch: return MysticIconTypeSketch;

        case MysticSettingAdjustColor: return MysticIconTypeAdjustColor;
        case MysticSettingStretch: return MysticIconTypeStretch;
        case MysticSettingStretchNone: return MysticIconTypeStretchNone;
        case MysticSettingStretchAspectFit: return MysticIconTypeStretchAspectFit;
        case MysticSettingStretchAspectFill: return MysticIconTypeStretchAspectFill;
        case MysticSettingStretchFill: return MysticIconTypeStretchFill;
        case MysticSettingFlipHorizontal: return MysticIconTypeFlipHorizontal;
        case MysticSettingFlipVertical: return MysticIconTypeFlipVertical;
        case MysticSettingMaskLayer: return MysticIconTypeMaskLayer;
        case MysticSettingMaskBrush: return MysticIconTypeMaskBrush;
        case MysticSettingMaskEmpty: return MysticIconTypeMaskEmpty;
        case MysticSettingMaskFill: return MysticIconTypeMaskFill;
        case MysticSettingMaskShape: return MysticIconTypeMaskShape;
        case MysticObjectTypeLayerShape: return MysticIconTypeShape;
        case MysticSettingNewProject: return MysticIconTypeNewProject;
        case MysticObjectTypeColorOverlay: return MysticIconTypeColorOverlay;
        case MysticSettingBackground: return MysticIconTypeBackground;
        case MysticSettingAddLayer: return MysticIconTypeAdd;
        case MysticObjectTypeShape: return MysticIconTypeSymbols;
        case MysticObjectTypeBadge: return MysticIconTypeSymbols;
        case MysticObjectTypeFrame: return MysticIconTypeFrame;
        case MysticSettingFilter: return MysticIconTypeSettingFilter;
        case MysticObjectTypeLight: return MysticIconTypeLight;
        case MysticSettingMenu: return MysticIconTypeTabMenu;
        case MysticSettingLayers: return MysticIconTypeLayers;
        case MysticSettingOptions: return MysticIconTypeOptions;
        case MysticSettingShare: return MysticIconTypeTabShare;
        case MysticObjectTypeColor: return MysticIconTypeColors;
        case MysticSettingFalseColor: return MysticIconTypeArrowSmallDown;
        case MysticObjectTypeDesign:
        case MysticObjectTypeText: return MysticIconTypeText;
        case MysticObjectTypeTexture: return MysticIconTypeTexture;
        case MysticObjectTypeSetting: return MysticIconTypeTune;
        case MysticObjectTypeSketch: return MysticIconTypeScribble;
        case MysticSettingVibrance: return MysticIconTypeVibrance;
        case MysticSettingSkin:
        case MysticSettingSkinHue:
        case MysticSettingSkinHueThreshold:
        case MysticSettingSkinMaxHueShift:
        case MysticSettingSkinMaxSaturationShift:
        case MysticSettingSkinUpperSkinToneColor: return MysticIconTypeSkin;
        case MysticObjectTypeImage:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeCustom: return MysticIconTypePhotoLayer;
        case MysticSettingAutoEnhance: return MysticIconTypeWand;
        case MysticSettingBlending:
        case MysticObjectTypeBlend: return MysticIconTypeBlend;
        case MysticObjectTypeFont: return MysticIconTypeFont;
        case MysticObjectTypeFilter: return MysticIconTypeFilter;
        case MysticObjectTypePotion: return MysticIconTypePotion;
        case MysticObjectTypeSpecial: return MysticIconTypeSpecial;
        case MysticObjectTypeMask: return MysticIconTypeMask;
        case MysticSettingSaturation:
        case MysticSettingHSBSaturation: return MysticIconTypeSaturation;
        case MysticSettingBrightness:
        case MysticSettingHSBBrightness: return MysticIconTypeBrightness;
        case MysticSettingVignette: return MysticIconTypeVignette;
        case MysticSettingColor:
        case MysticSettingChooseColor:
        case MysticSettingColorAndIntensity:
        case MysticSettingChooseColorAndIntensity: return MysticIconTypeColor;
        case MysticSettingHSBHue: return MysticIconTypeHue;
        case MysticSettingTemperature: return MysticIconTypeTone;
        case MysticSettingShadows: return MysticIconTypeShadows ;
        case MysticSettingHighlights: return MysticIconTypeHighlights;
        case MysticSettingShadowsHighlights: return MysticIconTypeShadowsHighlights;
        case MysticSettingIntensity: return MysticIconTypeIntensity;
        case MysticSettingColorBalance: return MysticIconTypeRGB;
        case MysticSettingContrast: return MysticIconTypeContrast;            
        case MysticSettingWearAndTear: return MysticIconTypeWearAndTear;
        case MysticSettingGamma: return MysticIconTypeGamma;
        case MysticSettingExposure: return MysticIconTypeExposure;
        case MysticSettingHaze: return MysticIconTypeHaze;            
        case MysticSettingFill: return MysticIconTypeFill;
        case MysticSettingSharpness: return MysticIconTypeSharpness;
        case MysticSettingTiltShift: return MysticIconTypeTiltShift;
        case MysticSettingUnsharpMask: return MysticIconTypeUnsharpMask;
        case MysticSettingLevels: return MysticIconTypeLevels;
        case MysticSettingGrain: return MysticIconTypeGrain;
        default: break;
    }
    return MysticIconTypeUnknown;
}

+ (BOOL) hasCustomColor:(id)iconTypeOrFilename;
{
    NSString *iname = [iconTypeOrFilename isKindOfClass:[NSString class]] ? iconTypeOrFilename : nil;

    if([iconTypeOrFilename isKindOfClass:[NSNumber class]])
    {
        MysticIconType iconType = [iconTypeOrFilename isKindOfClass:[NSNumber class]] ? [iconTypeOrFilename integerValue] : MysticIconTypeUnknown;
        iname = [[self class] name:iconType];
    }
    return iname && [iname hasSuffix:@"-color"] ? YES : NO;
}
+ (NSString *) name:(MysticIconType)iconType;
{
    return [[self class] name:iconType state:UIControlStateNormal];
}
+ (NSString *) name:(MysticIconType)iconType state:(UIControlState)state;
{
    
    NSString *name = nil;
    switch (iconType)
    {
        case MysticIconTypeBlur: name=@"shape-icon-blur2"; break;
        case MysticIconTypeBlurCircle: name=@"shape-icon-focus2"; break;
        case MysticIconTypeBlurZoom: name=@"shape-icon-zoom2"; break;
        case MysticIconTypeBlurGaussian: name=@"shape-icon-blur"; break;
        case MysticIconTypeBlurMotion: name=@"shape-icon-motion"; break;
        case MysticIconTypeDistortBuldge: name=@"shape-icon-buldge"; break;
        case MysticIconTypeDistortPinch: name=@"shape-icon-pinch"; break;
        case MysticIconTypeDistortStretch: name=@"shape-icon-stretch"; break;
        case MysticIconTypeDistortGlassSphere: name=@"shape-icon-sphere"; break;
        case MysticIconTypeDistortSwirl: name=@"shape-icon-swirl"; break;
        case MysticIconTypeHalfTone: name=@"shape-icon-halftone"; break;
        case MysticIconTypePixellate: name=@"shape-icon-pixellate"; break;
        case MysticIconTypePosterize: name=@"shape-icon-posterize"; break;
        case MysticIconTypeToon: name=@"shape-icon-toon"; break;
        case MysticIconTypeSketchFilter: name=@"shape-icon-sketchy"; break;

            
        case MysticIconTypeGrain: name=@"shape-icon-fill"; break;
        case MysticIconTypeSettingsSubmitBug: name = @"shape-settings-bug"; break;
        case MysticIconTypeSettingsRestorePurchases: name = @"shape-settings-restore"; break;
        case MysticIconTypeSettingsAccessories: name = @"shape-settings-accessories"; break;
        case MysticIconTypeSettingsEmptyCache: name = @"shape-settings-empty"; break;
        case MysticIconTypeSettingsPhotoQuality: name = @"shape-settings-photo-quality"; break;
        case MysticIconTypeSettingsShowTips: name = @"shape-settings-tips"; break;
        case MysticIconTypeSettingsAboutMystic: name = @"shape-settings-about"; break;
        case MysticIconTypeSettingsKeepPrivate: name = @"shape-settings-privacy"; break;
        case MysticIconTypeCompare: name = @"shape-icon-compare"; break;
        case MysticIconTypeTiltShift: name = @"shape-icon-tilt"; break;
        case MysticIconTypeSketchHide: name = @"shape-icon-brush-hide"; break;
        case MysticIconTypeSketchVisible: name = @"shape-icon-sketch-visible"; break;
        case MysticIconTypeSketchHidden: name = @"shape-icon-sketch-hidden"; break;
        case MysticIconTypeSketchLock: name = @"shape-icon-sketch-lock"; break;
        case MysticIconTypeSketchUnlock: name = @"shape-icon-sketch-unlock"; break;
        case MysticIconTypeSketchBlend: name = @"shape-icon-sketch-blend"; break;
        case MysticIconTypeMergeDown: name = @"shape-icon-layers-merge"; break;
        case MysticIconTypeSketchBrushAdd: name = @"shape-icon-brush-add"; break;
        case MysticIconTypeSketchBrushDelete: name = @"shape-icon-brush-x"; break;
        case MysticIconTypeSketchBrushEdit: name = @"shape-icon-brush-edit"; break;
        case MysticIconTypeSketchBrushBack: name = @"shape-icon-brush-back"; break;
        case MysticIconTypeSketchBrushDuplicate: name = @"shape-icon-brush-duplicate"; break;
        case MysticIconTypeSketchSettings: name = @"shape-icon-more"; break;
        case MysticIconTypeSketchLayers: name = @"shape-icon-sketch-layers"; break;
        case MysticIconTypeSketchBrush: name = @"shape-icon-sketch-brush"; break;
        case MysticIconTypeSketchEraser: name = @"shape-icon-sketch-eraser"; break;
        case MysticIconTypeSketchUndo: name = @"shape-icon-sketch-undo"; break;
        case MysticIconTypeSketchRedo: name = @"shape-icon-sketch-redo"; break;
        case MysticIconTypeBluetooth: name = @"shape-icon-sketch-bluetooth"; break;
        case MysticIconTypeStretchFill:
        case MysticIconTypeStretch: name = @"shape-icon-stretch-color"; break;
        case MysticIconTypeStretchAspectFill: name = @"shape-icon-stretch-aspectfill-color"; break;
        case MysticIconTypeStretchAspectFit: name = @"shape-icon-stretch-aspectfit-color"; break;
        case MysticIconTypeStretchNone: name = @"shape-icon-stretch-none-color"; break;
        case MysticIconTypeFlipVertical: name = @"shape-icon-flip-top-color"; break;
        case MysticIconTypeFlipHorizontal: name = @"shape-icon-flip-left-color"; break;
        case MysticIconTypeAlignToSelection: name = @"shape-icon-grid"; break;
        case MysticIconTypeAlignToArtboard: name = @"shape-icon-box-arrows"; break;
        case MysticIconTypeAlignToKeyObject: name = @"shape-icon-align"; break;
        case MysticIconTypeNewProject: name = @"shape-icon-cam-party"; break;
        case MysticIconTypePhotoLibrary: name = @"shape-settings-photo-quality"; break;
        case MysticIconTypeToolDuplicate: name = @"shape-icon-add-square"; break;
        case MysticIconTypeDuplicate: name = @"shape-icon-clone"; break;
        case MysticIconTypeToolKeyboard: name = @"shape-icon-keyboard"; break;
        case MysticIconTypeAdjustColor: name = @"shape-icon-dropper"; break;
        case MysticIconTypeToolFontColor:
        case MysticIconTypeToolColor:
        case MysticIconTypeColor: name = @"shape-icon-color-wheel-color"; break;
        case MysticIconTypeToolFont: name = @"shape-icon-type-font"; break;
        case MysticIconTypeToolFontEffect: name = @"shape-icon-type-fx"; break;
        case MysticIconTypeToolTrash: name = @"shape-icon-trash"; break;
        case MysticIconTypeToolMove: name = @"shape-icon-move"; break;
        case MysticIconTypeDragger:
        case MysticIconTypeAccessoryDrag: name = @"shape-icon-drag"; break;
        case MysticIconTypePointerLeft: name = @"shape-icon-point-left"; break;
        case MysticIconTypePointerRight: name = @"shape-icon-point-right"; break;
        case MysticIconTypeSkinnyX: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeSkinnyMenu: name = @"shape-icon-tool-skinny-menu"; break;
        case MysticIconTypeToolContent:
        case MysticIconTypeToolSquaresGrid: name = @"shape-icon-squares"; break;
        case MysticIconTypeLayerPosition: name = @"shape-icon-align-nb-vertical-group-color"; break;
        case MysticIconTypeLayerEffects: name = @"shape-icon-blend-color"; break;
        case MysticIconTypeMaskFill: name = @"shape-icon-mask-fill"; break;
        case MysticIconTypeMaskEmpty: name = @"shape-icon-mask-empty"; break;
        case MysticIconTypeMaskBrush: name = @"shape-icon-mask-brush"; break;
        case MysticIconTypeMaskErase: name = @"shape-icon-mask-erase"; break;
        case MysticIconTypeMaskLayer: name = @"shape-icon-mask-layer"; break;
        case MysticIconTypeTips: name = @"shape-icon-tips"; break;
        case MysticIconTypeMiniSlider: name = @"shape-icon-layer-tune-accessory-color"; break;
        case MysticIconTypeShareTwitter:            
        case MysticIconTypeLayers: name = @"shape-icon-layers-color"; break;            
        case MysticIconTypeCameraPlus: name = @"shape-icon-cam-plus"; break;
        case MysticIconTypePhotoLayer: name = @"shape-icon-photo"; break;
        case MysticIconTypeLibrary: name = @"shape-icon-library"; break;            
        case MysticIconTypeCameraInfo: name = @"shape-icon-camera-info"; break;
        case MysticIconTypeShutter: name = @"shape-icon-shutter"; break; 
        case MysticIconTypeShareLink: name = @"shape-icon-link"; break;         
        case MysticIconTypeSymbols: name = @"shape-icon-symbol"; break;
        case MysticIconTypeMenuJournal: name = @"shape-icon-journal"; break; 
        case MysticIconTypeMenuCommunity:
        case MysticIconTypeMenuHeart: name = @"shape-icon-heart"; break;
        case MysticIconTypeMenuSearch: name = @"shape-icon-search"; break;
        case MysticIconTypeClear: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeBlendOverlay: name = @"shape-icon-check-thin"; break;
        case MysticIconTypeToolBarX: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeToolBarList: name = @"shape-icon-list-123"; break;
        case MysticIconTypeToolBarFavorites: name = @"shape-icon-heart"; break;
        case MysticIconTypeToolBarRecents: name = @"shape-icon-history"; break;
        case MysticIconTypeToolBarEquals: name = @"shape-icon-menu"; break;
#ifdef DEBUG
        case MysticIconTypeTest: name = @"shape-icon-menu"; break;
#endif
        case MysticIconTypeToolBarX2: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeToolBarAll: name = @"shape-icon-squares"; break;
        case MysticIconTypeToolX: name = @"shape-icon-x-thin"; break;            
        case MysticIconTypeToolRotateRight: name = @"shape-icon-rotate-right"; break;
        case MysticIconTypeToolRotateLeft: name = @"shape-icon-rotate-left"; break;            
        case MysticIconTypeCogBorder: name = @"shape-icon-settings"; break;
        case MysticIconTypeToolHide: name = @"shape-icon-hide"; break;
        case MysticIconTypeToolDown: name = @"shape-icon-move-down"; break;
        case MysticIconTypeToolUpCenter: name = @"shape-icon-add"; break;
        case MysticIconTypeToolDownCenter: name = @"shape-icon-minus"; break;
        case MysticIconTypeToolUp: name = @"shape-icon-move-up"; break;
        case MysticIconTypeToolLeft: name = @"shape-icon-move-left"; break;
        case MysticIconTypeToolRight: name = @"shape-icon-move-right"; break;
        case MysticIconTypeToolLeftCenter: name = @"shape-icon-move-left"; break;
        case MysticIconTypeToolRightCenter: name = @"shape-icon-move-right"; break;
        case MysticIconTypeToolPlus: name = @"shape-icon-add"; break;
        case MysticIconTypeToolMinus: name = @"shape-icon-minus"; break;
        case MysticIconTypeShuffle: name = @"shape-icon-shuffle"; break;
        case MysticIconTypeToolHome: name = @"shape-icon-home"; break; 
        case MysticIconTypeToolFlipHorizontal: name = @"shape-icon-flip-left"; break;
        case MysticIconTypeToolFlipVertical: name = @"shape-icon-flip-top"; break; 
        case MysticIconTypeToolFlipHorizontalRight: name = @"shape-icon-flip-right"; break;
        case MysticIconTypeToolFlipVerticalBottom: name = @"shape-icon-flip-btm"; break; 
        case MysticIconTypeToolFlipHorizontalColor: name = @"shape-icon-flip-left-color"; break;
        case MysticIconTypeToolFlipVerticalColor: name = @"shape-icon-flip-top-color"; break; 
        case MysticIconTypeToolFlipHorizontalRightColor: name = @"shape-icon-flip-right-color"; break;
        case MysticIconTypeToolFlipVerticalBottomColor: name = @"shape-icon-flip-btm-color"; break;            
        case MysticIconTypeLineHeight: name = @"shape-icon-type-lineheight"; break;
        case MysticIconTypeLineHeightMinus: name = @"shape-icon-down-minus"; break;
        case MysticIconTypeLineHeightPlus: name = @"shape-icon-up-plus"; break; 
        case MysticIconTypeIntensity: name = @"shape-icon-intensity"; break; 
        case MysticIconTypeUnsharpMask: name = @"shape-icon-sharpen"; break; 
        case MysticIconTypeSharpness: name = @"shape-icon-triangle"; break;
        case MysticIconTypeFill: name = @"shape-icon-fill"; break;
        case MysticIconTypeHaze: name = @"shape-icon-haze"; break;            
        case MysticIconTypeWearAndTear: name = @"shape-icon-grain"; break;            
        case MysticIconTypeBackgroundColor: name = @"shape-icon-color-wheel-color"; break;
        case MysticIconTypeHue: name = @"shape-icon-hue-color"; break; 
        case MysticIconTypeExposure: name = @"shape-icon-exposure"; break; 
        case MysticIconTypeGamma: name = @"shape-icon-gamma";break;
        case MysticIconTypeContrast: name = @"shape-icon-contrast"; break; 
        case MysticIconTypeShadowsHighlights: name = @"shape-icon-highlights"; break;
        case MysticIconTypeShadows: name = @"shape-icon-shadow"; break; 
        case MysticIconTypeHighlights: name = @"shape-icon-highlights"; break; 
        case MysticIconTypeTone: name = @"shape-icon-tone-color"; break;
        case MysticIconTypeVignette: name = @"shape-icon-vignette"; break;
        case MysticIconTypeSettingFilter:
        case MysticIconTypeRGB:
        case MysticIconTypeColorBalance: name = @"shape-icon-rgb-color"; break; 
        case MysticIconTypeLevels: name = @"shape-icon-levels"; break; 
        case MysticIconTypeBrightness: name = @"shape-icon-brightness"; break;
        case MysticIconTypeSaturation: name = @"shape-icon-saturation-color"; break;
        case MysticIconTypeAccessoryRight:
        case MysticIconTypeAccessory: name = @"shape-icon-accessory"; break;
        case MysticIconTypeAccessoryUp: name = @"shape-icon-accessory-up"; break;
        case MysticIconTypeAccessoryDown: name = @"shape-icon-accessory-down"; break;
        case MysticIconTypeAccessoryLeft: name = @"shape-icon-accessory-left"; break;
        case MysticIconTypeRevealDown: name = @"shape-icon-hide"; break;
        case MysticIconTypeArrowSmallDown:
        case MysticIconTypeArrowDown: name = @"shape-icon-arrow-small-down"; break;
        case MysticIconTypeArrowSmallUp:
        case MysticIconTypeArrowUp: name = @"shape-icon-arrow-small-up"; break;
        case MysticIconTypeArrowSmallRight:
        case MysticIconTypeArrowRight: name = @"shape-icon-arrow-small-right"; break;
        case MysticIconTypeArrowSmallLeft:
        case MysticIconTypeArrowLeft: name = @"shape-icon-arrow-small-left"; break;
        case MysticIconTypeUserProfilePictureCircle:
        case MysticIconTypeUserProfilePicture:
        case MysticIconTypeUserProfilePictureCircleBorder: name = @"shape-icon-account"; break;
        case MysticIconTypeKnobClosed:
        case MysticIconTypeKnob:
        case MysticIconTypeKnobOpen:
        case MysticIconTypeKnobWide:
        case MysticIconTypeKnobWideClosed:
        case MysticIconTypeKnobWideOpen: name = @"shape-icon-knob"; break;
        case MysticIconTypeKnobDisabled:
        case MysticIconTypeKnobDisabledClosed:
        case MysticIconTypeKnobBorder:
        case MysticIconTypeKnobBorderClosed:
        case MysticIconTypeKnobDisabledOpen:
        case MysticIconTypeKnobBorderOpen: name = @"shape-icon-knob-disabled"; break;
        case MysticIconTypePositionNone:
        case MysticIconTypePosition:
        case MysticIconTypePositionTopLeft:
        case MysticIconTypePositionTop:
        case MysticIconTypePositionTopRight:
        case MysticIconTypePositionLeft:
        case MysticIconTypePositionCenter:
        case MysticIconTypePositionRight:
        case MysticIconTypePositionBottomLeft:
        case MysticIconTypePositionBottom:
        case MysticIconTypePositionBottomRight: name = @"shape-icon-align"; break;
        case MysticIconTypeColors: name = @"shape-icon-color-dots"; break;
        case MysticIconTypeWriteOnCam: name = @"shape-icon-cam-scribble"; break;
        case MysticIconTypeFontAdd: name = @"shape-icon-type-add-color"; break;
        case MysticIconTypeFontStyle: name = @"shape-icon-type-style-color"; break;
        case MysticIconTypeFontSelect: name = @"shape-icon-type-select-color"; break;
        case MysticIconTypeFontEdit: name = @"shape-icon-type-edit-color"; break;
        case MysticIconTypeFontColor: name = @"shape-icon-color-wheel-color"; break;
        case MysticIconTypeFontMove: name = @"shape-icon-type-move-color"; break;
        case MysticIconTypeFontClone: name = @"shape-icon-type-clone-color"; break;
        case MysticIconTypeFontDelete: name = @"shape-icon-type-delete-color"; break; 
        case MysticIconTypeShapeAlign: name = @"shape-icon-align-left-group-color"; break;
        case MysticIconTypeShapeAdd: name = @"shape-icon-shape-add-color"; break;
        case MysticIconTypeShapeStyle: name = @"shape-icon-shape-style-color"; break;
        case MysticIconTypeShapeSelect: name = @"shape-icon-shape-resize-color"; break;
        case MysticIconTypeShapeEdit: name = @"shape-icon-shape-edit-color"; break;
        case MysticIconTypeShapeColor: name = @"shape-icon-color-wheel-color"; break;
        case MysticIconTypeShapeMove: name = @"shape-icon-shape-move-color"; break;
        case MysticIconTypeShapeRezize: name = @"shape-icon-shape-resize-color"; break;
        case MysticIconTypeShapeClone: name = @"shape-icon-shape-clone-color"; break;
        case MysticIconTypeShapeDelete: name = @"shape-icon-type-delete-color"; break;
        case MysticIconTypeFonts: name = @"shape-icon-type-font"; break;            
        case MysticIconTypeFontNormal: name = @"shape-icon-font-normal"; break; 
        case MysticIconTypeFontBold: name = @"shape-icon-font-bold"; break; 
        case MysticIconTypeFontItalic: name = @"shape-icon-font-italic"; break; 
        case MysticIconTypeFontBoldItalic: name = @"shape-icon-font-bold-italic"; break;            
        case MysticIconTypeFontLineHeight: name = @"shape-icon-type-lineheight"; break; 
        case MysticIconTypeFontBorder: name = @"shape-icon-type-border-color"; break;
        case MysticIconTypeAlignCenter: name = @"shape-icon-align-center"; break;
        case MysticIconTypeAlignLeft: name = @"shape-icon-align-left"; break;
        case MysticIconTypeAlignFill: name = @"shape-icon-align-fill"; break;
        case MysticIconTypeAlignRight: name = @"shape-icon-align-right"; break;            
        case MysticIconTypeCommunity:
        case MysticIconTypeLove:
        case MysticIconTypeHeart: name = @"shape-icon-heart"; break;
        case MysticIconTypeMenu: name = @"shape-icon-menu"; break;
        case MysticIconTypeFontSpacing: name = @"shape-icon-type-spacing"; break;
        case MysticIconTypeLayerResize: name = @"shape-icon-layer-move-color"; break;            
        case MysticIconTypeLayerX: name = @"shape-icon-layer-x-color"; break;
        case MysticIconTypeAlignGroupVertical: name = @"shape-icon-align-vertical-group-color"; break;
        case MysticIconTypeAlignGroupHorizontal: name = @"shape-icon-align-horizontal-group-color"; break;
        case MysticIconTypeAlignGroupLeft: name = @"shape-icon-align-left-group-color"; break;
        case MysticIconTypeAlignGroupRight: name = @"shape-icon-align-right-group-color"; break;
        case MysticIconTypeAlignGroupTop: name = @"shape-icon-align-top-group-color"; break;
        case MysticIconTypeAlignGroupBottom: name = @"shape-icon-align-bottom-group-color"; break;
        case MysticIconTypeAlignGroupVerticalNoBorder: name = @"shape-icon-align-nb-vertical-group-color"; break;
        case MysticIconTypeAlignGroupHorizontalNoBorder: name = @"shape-icon-align-nb-horizontal-group-color"; break;
        case MysticIconTypeAlignGroupLeftNoBorder: name = @"shape-icon-align-nb-left-group-color"; break;
        case MysticIconTypeAlignGroupRightNoBorder: name = @"shape-icon-align-nb-right-group-color"; break;
        case MysticIconTypeAlignGroupTopNoBorder: name = @"shape-icon-align-nb-top-group-color"; break;
        case MysticIconTypeAlignGroupBottomNoBorder: name = @"shape-icon-align-nb-bottom-group-color"; break; 
        case MysticIconTypeTabMenu: name = @"shape-icon-menu"; break;
        case MysticIconTypeDrawerNippleLeft: name = @"shape-icon-drawer-nipple-left"; break; 
        case MysticIconTypeDrawerNippleRight: name = @"shape-icon-drawer-nipple-right"; break; 
        case MysticIconTypeNippleRight: name = @"shape-icon-triangle-right"; break; 
        case MysticIconTypeNippleLeft: name = @"shape-icon-triangle-left"; break;
        case MysticIconTypeNippleTop: name = @"shape-icon-triangle-up"; break;
        case MysticIconTypeNippleBottom: name = @"shape-icon-triangle-down"; break;
        case MysticIconTypeNippleTopBorder: name = @"shape-icon-triangle-up-border-color"; break;
        case MysticIconTypeToolLayerSettings: name = @"shape-icon-layer-tune"; break;
        case MysticIconTypeToolCog:
        case MysticIconTypeSettings:
        case MysticIconTypeCog:
        case MysticIconTypeEditLayer:
        case MysticIconTypeShareSettings:
        case MysticIconTypeMenuSettings: name = @"shape-icon-settings"; break;
        case MysticIconTypeReset:
        case MysticIconTypeSettingReset:
        case MysticIconTypeRefresh: name = @"shape-icon-reset"; break;
        case MysticIconTypeOptions: name = @"shape-icon-save"; break;
        case MysticIconTypeVibrance: name = @"shape-icon-color-dots-color"; break;
        case MysticIconTypeSkin: name = @"shape-icon-skin"; break;
        case MysticIconTypeTune: name = @"shape-icon-tune"; break;
        case MysticIconTypeGrid: name = @"shape-icon-grid"; break;
        case MysticIconTypeGridVisible: name = @"shape-icon-grid-cross-color"; break;
        case MysticIconTypeBlend: name = @"shape-icon-blend-color"; break;
        case MysticIconTypeOpacity: name = @"shape-icon-intensity"; break;
        case MysticIconTypeSquares:
        case MysticIconTypeBrowse:
        case MysticIconTypeChoose:
        case MysticIconTypeCategories: name = @"shape-icon-squares"; break;
        case MysticIconTypeTweet: name = @"shape-share-twitter"; break;
        case MysticIconTypeShareIcon: name = @"shape-share-icon"; break;
        case MysticIconTypeShareCircleSave: name = @"shape-share-circle-save-color"; break; 
        case MysticIconTypeShareCircleTwitter: name = @"shape-share-circle-twitter-color"; break; 
        case MysticIconTypeShareCircleInstagram: name = @"shape-share-circle-instagram-color"; break;
        case MysticIconTypeShareCircleEmail: name = @"shape-share-circle-email-color"; break; 
        case MysticIconTypeShareCirclePinterest: name = @"shape-share-circle-pinterest-color"; break; 
        case MysticIconTypeShareCirclePostcard: name = @"shape-share-circle-postcard-color"; break; 
        case MysticIconTypeShareCircleCopy: name = @"shape-share-circle-copy-color"; break; 
        case MysticIconTypeShareCirclePotion: name = @"shape-share-circle-potion-color"; break; 
        case MysticIconTypeShareCircleLink: name = @"shape-share-circle-link-color"; break; 
        case MysticIconTypeShareCircleTribe: name = @"shape-share-circle-tribe-color"; break; 
        case MysticIconTypeShareCircleOther: name = @"shape-share-circle-more-color"; break; 
        case MysticIconTypeShareCircleFacebook: name = @"shape-share-circle-facebook-color"; break; 
        case MysticIconTypeShareFacebook:
        case MysticIconTypeFacebook: name = @"shape-share-facebook"; break;
        case MysticIconTypeShareEmail:
        case MysticIconTypeEmail: name = @"shape-share-email"; break;
        case MysticIconTypeSharePostcard:
        case MysticIconTypePostcard: name = @"shape-share-postcard"; break;
        case MysticIconTypeShareSave:
        case MysticIconTypeSave: name = @"shape-share-save"; break;
        case MysticIconTypeSharePinterest:
        case MysticIconTypePinterest: name = @"shape-share-pinterest"; break;
        case MysticIconTypeShareInstagram:
        case MysticIconTypeInstagram: name = @"shape-share-instagram"; break;
        case MysticIconTypeShareCopy: name = @"shape-share-copy"; break;
        case MysticIconTypeShareOther: name = @"shape-share-other"; break;
        case MysticIconTypeShareMysticTribe: name = @"shape-share-tribe"; break;
        case MysticIconTypeSharePotion: name = @"shape-share-potion"; break;
        case MysticIconTypeEffectNone:
        case MysticIconTypeEffect0: name = @"shape-icon-variant-fill-0"; break;
        case MysticIconTypeEffect1: name = @"shape-icon-variant-fill-1"; break;
        case MysticIconTypeEffect2: name = @"shape-icon-variant-fill-2"; break;
        case MysticIconTypeEffect3: name = @"shape-icon-variant-fill-3"; break;
        case MysticIconTypeEffect4: name = @"shape-icon-variant-fill-4"; break;
        case MysticIconTypeEffect5: name = @"shape-icon-variant-fill-5"; break;
        case MysticIconTypeEffect6: name = @"shape-icon-variant-fill-6"; break;
        case MysticIconTypeEffect7:
        case MysticIconTypeEffectRandom: name = @"shape-icon-variant-fill-7"; break;
        case MysticIconTypePen: name = @"shape-icon-pencil"; break;
        case MysticIconTypeScribble: name = @"shape-icon-scribble"; break;
        case MysticIconTypeMoveAndSize: name = @"shape-icon-move"; break;
        case MysticIconTypeToolShadowAndBorder: name = @"shape-icon-shape-shadow"; break;
        case MysticIconTypeLayerShadowAlpha: name = @"shape-icon-shape-shadow-alpha-color"; break;
        case MysticIconTypeLayerShadowBlur: name = @"shape-icon-shape-shadow-blur-color"; break;
        case MysticIconTypeLayerShadowColor: name = @"shape-icon-shape-shadow-hue-color"; break;
        case MysticIconTypeLayerBorderWidth: name = @"drawBorderWidthWithFrame:color:"; break;
        case MysticIconTypeLayerBorderAlpha: name = @"drawBorderAlphaFrame:color:"; break;
        case MysticIconTypeLayerBorderColor: name = @"drawBorderColorFrame:color:"; break; 
        case MysticIconTypeShape: name = @"shape-icon-rect-pointy-star"; break;
        case MysticIconTypeFrame: name = @"shape-icon-frame"; break;
        case MysticIconTypeBorderAlignMiddle: name = @"shape-icon-border-align-middle-color"; break; 
        case MysticIconTypeBorderAlignOutside: name = @"shape-icon-border-align-outside-color"; break; 
        case MysticIconTypeBorderAlignInside: name = @"shape-icon-border-align-inside-color"; break;
        case MysticIconTypeTexture: name = @"shape-icon-texture"; break;
        case MysticIconTypeLight: name = @"shape-icon-light"; break;
        case MysticIconTypePotion:
        case MysticIconTypePotionMode:
        case MysticIconTypeRecipe: name = @"shape-icon-potion"; break; 
        case MysticIconTypeType:
        case MysticIconTypeFont: name = @"shape-icon-type"; break;
        case MysticIconTypeFontShadow: name = @"shape-icon-type-shadow"; break;
        case MysticIconTypeFontDeselect: name = @"shape-icon-type-deselect-color"; break; 
        case MysticIconTypeCamera: name = @"shape-icon-cam-party"; break;
        case MysticIconTypeWand: name = @"shape-icon-wand"; break;
        case MysticIconTypeAdd: name = @"shape-icon-add-color"; break;
        case MysticIconTypePlus: name = @"shape-icon-tool-plus"; break;
            
            
        case MysticIconTypeFilter: name = @"shape-icon-potion"; break;

//        case MysticIconTypeFilter: name = @"shape-icon-colorfilter"; break;
        case MysticIconTypeBackground: name = @"shape-icon-background-color"; break;
        case MysticIconTypeMoreArtArrow: name = @"shape-icon-more-art-arrow"; break; 
        case MysticIconTypeColorOverlay: name = @"shape-icon-rainbow-color"; break;
        case MysticIconTypeFontAlign: name = @"shape-icon-align-center"; break;
        case MysticIconTypeControlSelected: name = @"shape-icon-control"; break;
        case MysticIconTypeShare: name = @"shape-share-clean"; break;
        case MysticIconTypeBack: name = @"shape-icon-back-left"; break;
        case MysticIconTypeForward: name = @"shape-icon-next"; break;
        case MysticIconTypeCheck:
        case MysticIconTypeConfirm:
        case MysticIconTypeToolBarConfirm: name = @"shape-icon-check-thin"; break;
        case MysticIconTypeCheckThick: name = @"shape-icon-check-thick"; break;
        case MysticIconTypeToolCircleCheckBorder:
        case MysticIconTypeToolCircleCheck:
        case MysticIconTypeToolCircleCheckNoBorder:
        case MysticIconTypeConfirmThick: name = @"shape-icon-check-thick"; break;
        case MysticIconTypeToolConfirm:
        case MysticIconTypeConfirmFat: name = @"shape-icon-check-fat"; break;
        case MysticIconTypeDesigns:
        case MysticIconTypeText: name = @"shape-icon-word-art-color"; break;
        case MysticIconTypeSearch: name = @"shape-icon-search"; break;
        case MysticIconTypeSize: name = @"shape-icon-grid"; break;
        case MysticIconTypeRotate: name = @"shape-icon-reset"; break;
        case MysticIconTypeCancel: name = @"shape-icon-none"; break;
        case MysticIconTypeAlert: name = @"shape-icon-alert"; break;
        case MysticIconTypeDelete:
        case MysticIconTypeRemove: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeX: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeXThick: name=@"shape-icon-type-x"; break;
        case MysticIconTypeCamLayer: name = @"shape-icon-cam-plus"; break;
        case MysticIconTypeClose: name = @"shape-icon-x-thin"; break;
        case MysticIconTypeInfo: name = @"shape-icon-info"; break;
        case MysticIconTypeInvert: name = @"shape-icon-invert"; break;
        case MysticIconTypeQuestion:
        case MysticIconTypeHelp: name = @"shape-icon-help"; break;
        default: break;
    }
    if(state != UIControlStateNormal)
    {
        switch (state) {
            case UIControlStateSelected: { if([UIImage imageNamed:[name stringByAppendingString:@"-selected"]]) name = name ? [name stringByAppendingString:@"-selected"] : nil;     break; }
            case UIControlStateHighlighted: { if([UIImage imageNamed:[name stringByAppendingString:@"-highlighted"]])  name = name ? [name stringByAppendingString:@"-highlighted"] : nil;     break; }
            case UIControlStateDisabled: { if([UIImage imageNamed:[name stringByAppendingString:@"-disabled"]]) name = name ? [name stringByAppendingString:@"-disabled"] : nil;     break; }
            default: break;
        }
    }
    return name ? name : nil;
}
+ (MysticImageIcon *) iconForSetting:(MysticObjectType)setting color:(id)color;
{
    return [[self class] iconForType:[[self class] iconTypeForObjectType:setting] color:color ? color : @(MysticColorTypeAuto)];

}
+ (MysticImageIcon *) iconForSetting:(MysticObjectType)setting size:(CGSize)size color:(id)color ;
{
    return [[self class] iconForType:[[self class] iconTypeForObjectType:setting] size:size color:color ? color : @(MysticColorTypeAuto)];
}
+ (MysticImageIcon *) imageNamed:(NSString *)name colorType:(MysticColorType)colorType;
{
    UIColor *color = [MysticColor colorWithType:colorType];
    return [self imageNamed:name color:color];
}
+ (MysticImageIcon *) imageNamed:(NSString *)name color:(UIColor *)color;
{
    return (MysticImageIcon *)[MysticImageIcon image:name color:color];
}
+ (MysticImageIcon *) image:(UIImage *)img color:(UIColor *)color;
{
    if(!img) return nil;
    CGRect rect = CGRectMake(0, 0, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [MysticIcon draw:img color:color rect:rect context:context];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    newImage = [UIImage imageWithCGImage:newImage.CGImage scale:img.scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    return [MysticImageIcon imageWithImage:newImage];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color context:(CGContextRef)context;
{
    [self draw:img color:color rect:CGRectZero context:context];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
{
    [self draw:img color:color rect:rect bounds:rect context:context];
}

+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;
{
    [self draw:img color:color highlight:nil rect:rect bounds:bounds context:context];
}
+ (void) draw:(UIImage *)img color:(UIColor *)color highlight:(UIColor *)highlight rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;
{
    rect = CGRectIsZero(rect) ? CGRectMake(0, 0, img.size.width, img.size.height) : rect;
    CGSize scaleSize = [MysticUI scaleSize:rect.size bounds:bounds.size];
    CGRect r = CGRectSize(scaleSize);
    CGFloat scaleWidth = scaleSize.width/rect.size.width;
    CGFloat scaleHeight = scaleSize.height/rect.size.height;
    CGSize padding = CGSizeMake((rect.size.width-scaleSize.width)/2, (rect.size.height-scaleSize.height)/2);
    
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextTranslateCTM(context, padding.width*scaleWidth, bounds.size.height - (padding.height*scaleHeight));
    CGContextScaleCTM(context, scaleWidth, -scaleHeight);
    if(color.alpha > 0)
    {
        [color setFill];
        CGContextClipToMask(context, r, img.CGImage);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context,kCGPathFill);
        if(highlight && highlight.alpha > 0)
        {
            [highlight setFill]; CGContextAddRect(context, rect); CGContextDrawPath(context,kCGPathFill);
        }
    }
    else
    {
        [img drawInRect:[MysticUI rectWithSize:scaleSize]];
        if(highlight && highlight.alpha > 0)
        {
            [highlight setFill]; CGContextClipToMask(context, r, img.CGImage); CGContextAddRect(context, rect); CGContextDrawPath(context,kCGPathFill);
        }
    }
}

+ (MysticImageIcon *)roundedRect:(CGRect)rect color:(UIColor *)fillColor radius:(CGFloat)radius;
{
    rect.size = [MysticUI scaleSize:rect.size scale:0.0f];
    radius = radius*[Mystic scale];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    rect.origin = CGPointZero;

    CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
    
    fillColor = fillColor ? fillColor : [UIColor blackColor];
    [fillColor setFill];
	CGContextAddPath(context, retPath);
    
    CGContextFillPath(context);
    
    CGPathRelease(retPath);
    
    UIImage *_newImage = UIGraphicsGetImageFromCurrentImageContext();
    MysticImageIcon *newImage = [MysticImageIcon imageWithCGImage:_newImage.CGImage scale:[Mystic scale] orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    return newImage;
    
    
}



+ (MysticImageIcon *)roundedRect:(CGRect)rect color:(UIColor *)fillColor radii:(UIEdgeInsets)radii;
{
    rect.size = [MysticUI scaleSize:rect.size scale:0.0f];
    CGFloat scale = [Mystic scale];
    radii.top *= scale;
    radii.left *= scale;
    radii.right *= scale;
    radii.bottom *= scale;

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    rect.origin = CGPointZero;
    
    CGMutablePathRef retPath = CGPathCreateMutable();
    CGRect innerRect = UIEdgeInsetsInsetRect(rect, radii);
//	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radii.top);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radii.right);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radii.bottom);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radii.left);
    
	CGPathCloseSubpath(retPath);
    
    
    fillColor = fillColor ? fillColor : [UIColor blackColor];
    [fillColor setFill];
	CGContextAddPath(context, retPath);
    
    CGContextFillPath(context);
    
    CGPathRelease(retPath);
    
    UIImage *_newImage = UIGraphicsGetImageFromCurrentImageContext();
    MysticImageIcon *newImage = [MysticImageIcon imageWithCGImage:_newImage.CGImage scale:[Mystic scale] orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    return newImage;
    
    
}

+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option;
{
    return [self iconForOption:option type:MysticIconTypeNone color:[MysticColor colorForObject:option.type orColor:nil]];
}
+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option color:(UIColor *)color;
{
    return [self iconForOption:option type:MysticIconTypeNone color:color];
}
+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option type:(MysticIconType)iconType color:(UIColor *)color;
{
    iconType = iconType < 1 ? [MysticIcon iconTypeForObjectType:option.type] : iconType;
    
    return [self iconForType:iconType color:color];
}
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType;
{
    return [self iconForType:iconType color:nil];
}
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType color:(UIColor *)color image:(UIImage *)image;
{
    MysticImageIcon *icon = nil;

    if(image) icon = [[self class] image:image color:color];
    else
    {
        if(color && [[self class] hasCustomColor:@(iconType)] && [color isKindOfClass:[NSNumber class]] && MysticColorIsEmpty([(NSNumber *)color integerValue]))
        {
            
            color = (id)@(MysticColorTypeNone);
        }
        icon = [[self class] iconForType:iconType color:color];
    }
    return icon;
}
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType color:(UIColor *)color;
{
    return [[self class] iconForType:iconType size:CGSizeUnknown color:color];
}
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType size:(CGSize)size color:(UIColor *)color;
{
    return [[self class] iconForType:iconType size:size color:color backgroundColor:nil];

}
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType size:(CGSize)size color:(UIColor *)color backgroundColor:(id)bgColor;
{
    MysticImageIcon *icon = nil;
    NSString *name = [MysticIcon name:iconType];
    color = [MysticColor color:color];
    BOOL isBlack = [color isEqualToColor:[UIColor blackColor]];

    if(color && !isBlack)
    {
        icon = [MysticImageIcon image:name size:size color:color backgroundColor:bgColor];
    }
    else
    {
        icon = [MysticImageIcon image:name size:size color:isBlack ? nil : color backgroundColor:bgColor];
    }
    return icon;
}

+ (MysticImageIcon *) iconWithNumber:(int)number size:(CGSize)size color:(UIColor *)color textColor:(UIColor *)textColor;
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];

    
    CGSize circleSize = size;
    CGPoint circlePoint = CGPointMake(size.width/2, size.height/2);
    CGMutablePathRef activeCircle = CGPathCreateMutable();
    
    CGPathMoveToPoint(activeCircle, NULL, circlePoint.x, circlePoint.y);
    CGPathAddLineToPoint(activeCircle, NULL, circlePoint.x + (circleSize.width/2), circlePoint.y);
    CGPathAddArc(activeCircle, NULL, circlePoint.x, circlePoint.y, circleSize.width/2, -M_PI_2, M_PI_2*4, NO);
    
    
    CGPathCloseSubpath(activeCircle);
    
    
    CGContextAddPath(context, activeCircle);
    CGContextFillPath(context);
    CGPathRelease(activeCircle);
    
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    [textColor setFill];
    NSString *t = [NSString stringWithFormat:@"%d",number];
    UIFont *gothamFont = [MysticUI gothamBold:28];
    CGSize textSize = [t sizeWithFont:gothamFont];
    CGPoint textPoint = CGPointZero;
    textPoint.x = size.width/2 - textSize.width/2;
    textPoint.y = size.height/2 - textSize.height/2;
    [t drawAtPoint:textPoint
               withFont:gothamFont];
    
//    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
//
//    const char *str=[t UTF8String];
//    CGContextShowTextAtPoint(context,0.0,0.0,str,strlen(str));
    
    
    
    UIImage *circleImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return [MysticImageIcon imageWithImage:circleImg];
}


+ (CGPathRef) drawIconType:(MysticIconType)type color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
{
    CGSize size = rect.size;
    CGSize oldSize;
    color = !color ? [UIColor blackColor] : color;
    [color setFill];
    switch (type) {
        case MysticIconTypeBlend:
        {
            oldSize = CGSizeMake(18, 18); 
            UIBezierPath* path = [UIBezierPath bezierPath]; [path moveToPoint: MyPoint(size,oldSize,CGPointMake(6,10))]; [path addCurveToPoint: MyPoint(size,oldSize,CGPointMake(7,13)) controlPoint1: MyPoint(size,oldSize,CGPointMake(6,12)) controlPoint2: MyPoint(size,oldSize,CGPointMake(7,13))]; [path addCurveToPoint: MyPoint(size,oldSize,CGPointMake(13,7)) controlPoint1: MyPoint(size,oldSize,CGPointMake(11,13)) controlPoint2: MyPoint(size,oldSize,CGPointMake(13,10))]; [path addCurveToPoint: MyPoint(size,oldSize,CGPointMake(11,6)) controlPoint1: MyPoint(size,oldSize,CGPointMake(12,6)) controlPoint2: MyPoint(size,oldSize,CGPointMake(12,6))]; [path addCurveToPoint: MyPoint(size,oldSize,CGPointMake(6,10)) controlPoint1: MyPoint(size,oldSize,CGPointMake(8,6)) controlPoint2: MyPoint(size,oldSize,CGPointMake(6,8))]; [path fill]; 
            UIBezierPath* path1 = [UIBezierPath bezierPath]; [path1 moveToPoint: MyPoint(size,oldSize,CGPointMake(11,3))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(13,4)) controlPoint1: MyPoint(size,oldSize,CGPointMake(11,3)) controlPoint2: MyPoint(size,oldSize,CGPointMake(12,4))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(6,0)) controlPoint1: MyPoint(size,oldSize,CGPointMake(12,1)) controlPoint2: MyPoint(size,oldSize,CGPointMake(9,0))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(0,7)) controlPoint1: MyPoint(size,oldSize,CGPointMake(3,0)) controlPoint2: MyPoint(size,oldSize,CGPointMake(0,3))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(4,13)) controlPoint1: MyPoint(size,oldSize,CGPointMake(0,10)) controlPoint2: MyPoint(size,oldSize,CGPointMake(2,12))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(4,10)) controlPoint1: MyPoint(size,oldSize,CGPointMake(4,12)) controlPoint2: MyPoint(size,oldSize,CGPointMake(4,11))]; [path1 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(11,3)) controlPoint1: MyPoint(size,oldSize,CGPointMake(4,7)) controlPoint2: MyPoint(size,oldSize,CGPointMake(7,3))]; [path1 fill]; 
            UIBezierPath* path2 = [UIBezierPath bezierPath]; [path2 moveToPoint: MyPoint(size,oldSize,CGPointMake(13,4))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(13,7)) controlPoint1: MyPoint(size,oldSize,CGPointMake(13,5)) controlPoint2: MyPoint(size,oldSize,CGPointMake(13,6))]; [path2 addLineToPoint: MyPoint(size,oldSize,CGPointMake(13,7))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(15,10)) controlPoint1: MyPoint(size,oldSize,CGPointMake(14,7)) controlPoint2: MyPoint(size,oldSize,CGPointMake(15,9))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(11,15)) controlPoint1: MyPoint(size,oldSize,CGPointMake(15,13)) controlPoint2: MyPoint(size,oldSize,CGPointMake(13,15))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(7,13)) controlPoint1: MyPoint(size,oldSize,CGPointMake(9,15)) controlPoint2: MyPoint(size,oldSize,CGPointMake(8,14))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(6,14)) controlPoint1: MyPoint(size,oldSize,CGPointMake(7,14)) controlPoint2: MyPoint(size,oldSize,CGPointMake(7,14))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(4,13)) controlPoint1: MyPoint(size,oldSize,CGPointMake(6,14)) controlPoint2: MyPoint(size,oldSize,CGPointMake(5,13))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(11,18)) controlPoint1: MyPoint(size,oldSize,CGPointMake(5,16)) controlPoint2: MyPoint(size,oldSize,CGPointMake(8,18))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(18,10)) controlPoint1: MyPoint(size,oldSize,CGPointMake(14,18)) controlPoint2: MyPoint(size,oldSize,CGPointMake(18,14))]; [path2 addCurveToPoint: MyPoint(size,oldSize,CGPointMake(13,4)) controlPoint1: MyPoint(size,oldSize,CGPointMake(18,7)) controlPoint2: MyPoint(size,oldSize,CGPointMake(15,5))]; [path2 fill]; 
            CGContextAddPath(context, path.CGPath); CGContextAddPath(context, path1.CGPath); CGContextAddPath(context, path2.CGPath); break;
        }
        default: break;
    }
    return nil;
}
+ (MysticIcon *) customIconWithColor:(UIColor *)value type:(MysticIconType)theType size:(CGSize)theSize;
{
    MysticIcon *icon = [[MysticIcon alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height) color:value type:MysticIconTypeCustom];
    icon.customImage = [MysticIcon iconForType:theType color:value];
    return [icon autorelease];
}
+ (MysticIcon *) iconWithColor:(UIColor *)value type:(MysticIconType)theType size:(CGSize)theSize;
{
    MysticIcon *icon = [[MysticIcon alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height) color:value type:theType];
    [icon setNeedsDisplay];
    return [icon autorelease];
}

+ (MysticIcon *) indicatorWithColor:(UIColor *)value size:(CGSize)theSize;
{
    MysticIcon *icon = [[MysticIcon alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height) color:value type:MysticIconTypeAccessory];
    return [icon autorelease];
}
+ (MysticIcon *) indicatorWithColorType:(MysticColorType)value size:(CGSize)theSize;
{
    UIColor *c = [MysticColor colorWithType:value];
    return [self indicatorWithColor:c size:theSize];
}

- (void) dealloc;
{
    [_color release];
    [_customImage release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame color:(UIColor *)value type:(MysticIconType)theType;
{
    self = [super initWithFrame:frame];
    {
        if(self)
        {
            self.color = value; self.padding = PADDING; self.type = theType; self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}
- (void) setColor:(UIColor *)color;
{

    if(![color isKindOfClass:[UIColor class]]) color = [MysticColor color:color];
    _color = color;
}
//- (void) setColor:(UIColor *)c;
//{
//    BOOL d = _color == c;
//    _color = c;
//    if(d) [self setNeedsDisplay];
//}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.type) {
        case MysticIconTypeAccessory:
        {
            CGFloat indicatorWidth = self.frame.size.height * (13.0f/18.0f); CGContextSetStrokeColorWithColor(context, self.color.CGColor); CGContextSetLineWidth(context, MYSTIC_ICON_LINE_WIDTH); CGContextSetLineJoin(context, kCGLineJoinMiter); 
            CGContextMoveToPoint(context, self.padding, self.padding); CGContextAddLineToPoint(context, indicatorWidth - self.padding, self.frame.size.height/2); CGContextAddLineToPoint(context, self.padding, self.frame.size.height - self.padding); 
            CGContextStrokePath(context); break;
        }
        case MysticIconTypePlus:
        {
            CGSize size = rect.size; size.height = size.width; CGPoint p = CGPointZero; p.y = (rect.size.height - size.height)/2; 
            
            CGContextSetStrokeColorWithColor(context, self.color.CGColor); CGContextSetLineWidth(context, MYSTIC_ICON_LINE_WIDTH); CGContextSetLineJoin(context, kCGLineJoinMiter); 
            // draw vert line
            CGContextMoveToPoint(context, size.width/2, p.y); CGContextAddLineToPoint(context, size.width/2, p.y+size.height); 
            // draw horiz line
            CGContextMoveToPoint(context, 0, p.y + size.height/2); CGContextAddLineToPoint(context, size.width, p.y+size.height/2); 
            CGContextStrokePath(context); break;
        }
        case MysticIconTypeCustom:
        default:
        {
            if(self.customImage)
            {
//                CGContextRef context = UIGraphicsGetCurrentContext();     
                [self.customImage drawInRect:rect];     
                
            }
            break;
        }
    }
    
}




@end

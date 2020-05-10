//
//  MysticUtility.m
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticUtility.h"
#import "UIColor+Mystic.h"
#import "UIDevice+Machine.h"
#import "MysticDrawingContext.h"
#import "MysticAttrString.h"
#import "MysticScrollView.h"

void runBlock(MysticBlock block)
{
    if(block)
    {
        block();
        Block_release(block);
    }
}

void mdispatch(MysticBlock block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}
void mdispatch_high(MysticBlock block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}
void mdispatch_bg(MysticBlock block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}
void mdispatch_default(MysticBlock block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
void mdispatch_low(MysticBlock block)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}

CGRect UIViewRect(UIView *view, CGRect frame)
{
    view.frame = frame;
    return view.frame;
}
CGRect UIViewX(UIView *view, CGFloat x)
{
    CGRect frame = view.frame;
    frame.origin.x = x;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewY(UIView *view, CGFloat y)
{
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewXY(UIView *view, CGFloat x, CGFloat y)
{
    CGRect frame = view.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewWidth(UIView *view, CGFloat w)
{
    CGRect frame = view.frame;
    frame.size.width = w;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewHeight(UIView *view, CGFloat h)
{
    CGRect frame = view.frame;
    frame.size.height = h;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewSize(UIView *view, CGSize size)
{
    CGRect frame = view.frame;
    frame.size=size;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewPoint(UIView *view, CGPoint origin)
{
    CGRect frame = view.frame;
    frame.origin=origin;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewAddX(UIView *view, CGFloat x)
{
    CGRect frame = view.frame;
    frame.origin.x += x;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewAddY(UIView *view, CGFloat y)
{
    CGRect frame = view.frame;
    frame.origin.y += y;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewAddWidth(UIView *view, CGFloat w)
{
    CGRect frame = view.frame;
    frame.size.width += w;
    view.frame = frame;
    return view.frame;
}
CGRect UIViewAddHeight(UIView *view, CGFloat h)
{
    CGRect frame = view.frame;
    frame.size.height += h;
    view.frame = frame;
    return view.frame;
}



MysticShaderIndex MysticShaderIndexClean(MysticShaderIndex i)
{
    MysticShaderIndex index = i;
    index.count = MAX(0, index.count);
    index.previousIndex = MAX(0, index.previousIndex);
    return index;
}
MysticShaderIndex MysticShaderIndexFromArray(NSArray *a)
{
    MysticShaderIndex i = (MysticShaderIndex){1,0,0,0,0};
    for (NSInteger n =0; n<a.count; n++) {
        switch (n) {
            case 0:
                i.stackIndex = [a objectAtIndex:n];
                break;
            case 1:
                i.index = [a objectAtIndex:n];
                break;
            case 2:
                i.count = [a objectAtIndex:n];
                break;
            case 3:
                i.previousIndex = [a objectAtIndex:n];
                break;
            case 4:
                i.offset = [a objectAtIndex:n];
                break;
                
            default: break;
        }
    }
    return i;
}
NSArray *Border(id border)
{
    border = border ? border : @(1);
    if([border isKindOfClass:[NSString class]])
    {
        NSMutableArray *a = [NSMutableArray array];
        for (NSString *s in [(NSString *)border componentsSeparatedByString:@","])  [a addObject:@([s intValue])];
        border = a;
    }
    float b = [border isKindOfClass:[NSNumber class]] ? [border floatValue] : [border isKindOfClass:[NSArray class]] ? [[(NSArray *)border objectAtIndex:0] floatValue] : [border CGRectValue].origin.x;
    int iw = [border isKindOfClass:[NSArray class]] ? [(NSArray *)border count] > 2 ? 1 : 0 : 0;
    float w = [border isKindOfClass:[NSArray class]] ? [(NSNumber *)[(NSArray *)border objectAtIndex:iw] floatValue] : ![border isKindOfClass:[NSNumber class]] ? [border CGRectValue].size.width : [border floatValue];
    float h = [border isKindOfClass:[NSArray class]] ? [(NSNumber *)[(NSArray *)border lastObject] floatValue] : ![border isKindOfClass:[NSNumber class]] ? [border CGRectValue].size.height : 0;
    CGRect dashSize = [border isKindOfClass:[NSNumber class]] ? CGRectMake([border floatValue], 0, 0, 0) : [border isKindOfClass:[NSArray class]] ? (CGRect){b, 0, w, h} : [border CGRectValue];
    
    return dashSize.size.width==0 ? nil : [border isKindOfClass:[NSArray class]] ? [border subarrayWithRange:NSMakeRange(iw, [(NSArray *)border count] - iw)] : dashSize.size.width > 0 ? @[@(dashSize.size.width), @(dashSize.size.height)] : nil;
}
UIColor *C(MysticColorType color)
{
    return [UIColor color:color];
}
UIColor *CA(MysticColorType color, float a)
{
    return [[UIColor color:color] colorWithAlphaComponent:a];
}
UIColor *MyColorNotClear(id color)
{
    if(!color || isNull(color)) return nil;
    
    UIColor *c = color;
    if([c isKindOfClass:[NSNumber class]])
    {
        c = [UIColor color:[(NSNumber *)c integerValue]];
    }
    if([c isKindOfClass:[NSString class]])
    {
        c = [UIColor string:(id)c];
    }
    if(!c || c.alpha == 0) return nil;
    return c;
}
NSString *Red(NSString *str)
{
    return ColorWrap(str, COLOR_RED);
}
NSString *Blue(NSString *str)
{
    return ColorWrap(str, COLOR_BLUE);
}
NSString *Green(NSString *str)
{
    return ColorWrap(str, COLOR_GREEN_BRIGHT);
}
NSString *Purple(NSString *str)
{
    return ColorWrap(str, COLOR_PURPLE);
}
NSString *Pink(NSString *str)
{
    return ColorWrap(str, COLOR_PINK);
}
NSString *Magenta(NSString *str)
{
    return ColorWrap(str, [UIColor magentaColor]);
}
NSString *Cyan(NSString *str)
{
    return ColorWrap(str, [UIColor cyanColor]);
}
NSString *Yellow(NSString *str)
{
    return ColorWrap(str, COLOR_YELLOW);
}
NSString *ColorWrap(NSString *str, id color)
{
    if(!color) return str;
    UIColor *c = [MysticColor color:color];

    return [NSString stringWithFormat:@"$_FG:%d,%d,%d_$%@$_ENDFG", c.red255,c.green255,c.blue255, str];
}
NSString *ColorWrapf(NSString *str, float v, id color)
{
    return ColorWrap([NSString stringWithFormat:str ? str : @"%2.2f", v], color);
}
NSString *ColorWrapInt(NSString *str, int v, id color)
{
    return ColorWrap([NSString stringWithFormat:str ? str : @"%d", v], color);
}
NSString *ColorString(UIColor *c)
{
    if(c && [c isKindOfClass:[NSNumber class]])
    {
        c = [UIColor color:[(NSNumber *)c integerValue]];
    }
    if(!c) return @"nil";
    if(isNull(c)) return @"null";
    if([c isEqualToColor:[UIColor red]]) return @"Red";
    if([c isEqualToColor:[UIColor blueColor]]) return @"Blue";
    if([c isEqualToColor:[UIColor greenColor]]) return @"Green";
    if([c isEqualToColor:[UIColor blackColor]]) return @"Black";
    if([c isEqualToColor:[UIColor whiteColor]]) return @"White";
    
    
    return [NSString stringWithFormat:@"(%2.1f, %2.1f, %2.1f%@) %@", c.red, c.green, c.blue, c.alpha < 1 ? [NSString stringWithFormat:@" %2.2f", c.alpha] : @"", [c hexString]];
}
NSString *ColorToString(UIColor *c)
{
    return ColorString(c);
}
NSString *ColorStr(UIColor *c)
{
    return ColorStrSuffix(c, nil, 1);
}
NSString *ColorStrd(UIColor *c, int d)
{
    return ColorStrSuffix(c, nil, d);
}
NSString *ColorStrDotted(UIColor *c, int d)
{
    if(!c || isNull(c) || c.alpha == 0) return @"null";
    NSString *w = [@"$_D" repeat:d];
    return [NSString stringWithFormat:@"$_FG:%d,%d,%d_$%@$_ENDFG",
            c.red255,
            c.green255,
            c.blue255,
            w
            ];
}
NSString *ColorStrSuffix(UIColor *c, NSString *suffix, int d)
{
    if(!c || isNullOr(c)==nil) return ColorWrap(@"nil", COLOR_DOTS);
    if([c isEqualToColor:[UIColor blackColor]]) return ColorWrap(@"□", [UIColor grayColor]);
    
    NSString *w = [@"$_B" repeat:d];
    return [NSString stringWithFormat:@"$_FG:%d,%d,%d_$%@$_ENDFG%@",
            c.red255,
            c.green255,
            c.blue255,
            w,
            suffix ? [NSString stringWithFormat:@"  %@  ", suffix] : @""
            ];
}

NSString *MysticObjectTypeToString(MysticObjectType type)
{
    switch (type) {
        case MysticSettingBlur: return @"MysticSettingBlur";
        case MysticSettingBlurZoom: return @"MysticSettingBlurZoom";
        case MysticSettingBlurCircle: return @"MysticSettingBlurCircle";
        case MysticSettingBlurMotion: return @"MysticSettingBlurMotion";
        case MysticSettingBlurGaussian: return @"MysticSettingBlurGaussian";
        case MysticSettingDistortPinch: return @"MysticSettingDistortPinch";
        case MysticSettingDistortSwirl: return @"MysticSettingDistortSwirl";
        case MysticSettingDistortBuldge: return @"MysticSettingDistortBuldge";
        case MysticSettingDistortStretch: return @"MysticSettingDistortStretch";
        case MysticSettingDistortGlassSphere: return @"MysticSettingDistortGlassSphere";
        case MysticSettingToon: return @"MysticSettingToon";
        case MysticSettingPixellate: return @"MysticSettingPixellate";
        case MysticSettingPosterize: return @"MysticSettingPosterize";
        case MysticSettingSketchFilter: return @"MysticSettingSketchFilter";


            
        case MysticSettingInvert: return @"MysticSettingInvert";
        case MysticSettingGrain: return @"MysticSettingGrain";
        case MysticSettingSketchSettings: return @"MysticSettingSketchSettings";
        case MysticSettingSketchEraser: return @"MysticSettingSketchEraser";
        case MysticSettingSketchBrush: return @"MysticSettingSketchBrush";
        case MysticSettingSketchLayers: return @"MysticSettingSketchLayers";
        case MysticObjectTypeMulti: return @"MysticObjectTypeMulti";

        case MysticSettingFlipVertical: return @"MysticSettingFlipVertical";
        case MysticSettingFlipHorizontal: return @"MysticSettingFlipHorizontal";
        case MysticObjectTypeSketch: return @"MysticObjectTypeSketch";
        case MysticSettingAdjustColor: return @"MysticSettingAdjustColor";
        case MysticSettingVignetteBlending: return @"MysticSettingVignetteBlending";
        case MysticSettingStretch: return @"MysticSettingStretch";
        case MysticSettingStretchAspectFill: return @"MysticSettingStretchAspectFill";
        case MysticSettingStretchAspectFit: return @"MysticSettingStretchAspectFit";
        case MysticSettingStretchFill: return @"MysticSettingStretchFill";
        case MysticSettingStretchNone: return @"MysticSettingStretchNone";
        case MysticSettingVignetteColorAlpha: return @"MysticSettingVignetteColorAlpha";
        case MysticSettingHighlightTintColor: return @"MysticSettingHighlightTintColor";
        case MysticSettingHighlightIntensity: return @"MysticSettingHighlightIntensity";
        case MysticSettingShadowIntensity: return @"MysticSettingShadowIntensity";
        case MysticSettingShadowTintColor: return @"MysticSettingShadowTintColor";
        case MysticSettingAlignToArtboard: return @"MysticSettingAlignToArtboard";
        case MysticSettingAlignToSelection: return @"MysticSettingAlignToSelection";
        case MysticSettingAlignToKeyObject: return @"MysticSettingAlignToKeyObject";
        case MysticObjectTypeAll: return @"MysticObjectTypeAll";
        case MysticSettingAutoEnhance: return @"MysticSettingAutoEnhance";
        case MysticSettingBackground: return @"MysticSettingBackground";
        case MysticSettingNoneFromConfirm: return @"MysticSettingNoneFromConfirm";
        case MysticSettingNoneFromLoadProject: return @"MysticSettingNoneFromLoadProject";
        case MysticSettingNoneFromCancel: return @"MysticSettingNoneFromCancel";
        case MysticSettingNoneFromBack: return @"MysticSettingNoneFromBack";
        case MysticSettingCropSourceImage: return @"MysticSettingCropSourceImage";
        case MysticSettingUnsharpMask: return @"MysticSettingUnsharpMask";
        case MysticSettingLevels: return @"MysticSettingLevels";
        case MysticSettingCamLayerSetup: return @"MysticSettingCamLayerSetup";
        case MysticSettingCamLayer: return @"MysticSettingCamLayer";
        case MysticObjectTypeImage: return @"MysticObjectTypeImage";
        case MysticSettingCamLayerAlpha: return @"MysticSettingCamLayerAlpha";
        case MysticObjectTypeCamLayer: return @"MysticObjectTypeCamLayer";
        case MysticObjectTypePack: return @"MysticObjectTypePack";
        case MysticObjectTypeTextPack: return @"MysticObjectTypeTextPack";
        case MysticObjectTypeSpecial: return @"MysticObjectTypeSpecial";
        case MysticObjectTypeLightPack: return @"MysticObjectTypeLightPack";
        case MysticObjectTypeLayerShape: return @"MysticObjectTypeLayerShape";
        case MysticObjectTypeMixture: return @"MysticObjectTypeMixture";
        case MysticObjectTypeFramePack: return @"MysticObjectTypeFramePack";
        case MysticObjectTypeTexturePack: return @"MysticObjectTypeTexturePack";
        case MysticObjectTypeBadgePack: return @"MysticObjectTypeBadgePack";
        case MysticObjectTypeOption: return @"MysticObjectTypeOption";
        case MysticObjectTypePotion: return @"MysticObjectTypePotion";
        case MysticObjectTypeBadgeOverlay: return @"MysticObjectTypeBadgeOverlay";
        case MysticObjectTypeTextOverlay: return @"MysticObjectTypeTextOverlay";
        case MysticObjectTypeFilter: return @"MysticObjectTypeFilter";
        case MysticSettingLayers: return @"MysticSettingLayers";
        case MysticSettingOptions: return @"MysticSettingOptions";
        case MysticSettingMixtures: return @"MysticSettingMixtures";
        case MysticSettingPaint: return @"MysticSettingPaint";
        case MysticObjectTypeFilterAlpha: return @"MysticObjectTypeFilterAlpha";
        case MysticObjectTypeOverlay: return @"MysticObjectTypeOverlay";
        case MysticObjectTypeFrame: return @"MysticObjectTypeFrame";
        case MysticObjectTypeMask: return @"MysticObjectTypeMask";
        case MysticObjectTypeText: return @"MysticObjectTypeText";
        case MysticObjectTypeTexture: return @"MysticObjectTypeTexture";
        case MysticObjectTypeLight: return @"MysticObjectTypeLight";
        case MysticObjectTypeColor: return @"MysticObjectTypeColor";
        case MysticObjectTypeTextColor: return @"MysticObjectTypeTextColor";
        case MysticObjectTypeBadgeColor: return @"MysticObjectTypeBadgeColor";
        case MysticObjectTypeBlend: return @"MysticObjectTypeBlend";
        case MysticObjectTypeColorOverlay: return @"MysticObjectTypeColorOverlay";
        case MysticSettingTextColor: return @"MysticSettingTextColor";
        case MysticSettingCamLayerColor: return @"MysticSettingCamLayerColor";
        case MysticSettingBadgeColor: return MysticSettingBadgeColor;
        case MysticObjectTypeFrameBackgroundColor: return @"MysticObjectTypeFrameBackgroundColor";
        case MysticObjectTypeBadge: return @"MysticObjectTypeBadge";
        case MysticObjectTypeSetting: return @"MysticObjectTypeSetting";
        case MysticSettingNewProject: return @"MysticSettingNewProject";
        case MysticSettingBadge: return @"MysticSettingBadge";
        case MysticSettingAddLayer: return @"MysticSettingAddLayer";
        case MysticObjectTypeBlendedLayer: return @"MysticObjectTypeBlendedLayer";
        case MysticSettingText: return @"MysticSettingText";
        case MysticSettingIntensity: return @"MysticSettingIntensity";
        case MysticSettingFrame: return @"MysticSettingFrame";
        case MysticSettingMask: return @"MysticSettingMask";
        case MysticSettingTexture: return @"MysticSettingTexture";
        case MysticSettingTextureAlpha: return @"MysticSettingTextureAlpha";
        case MysticSettingLighting: return @"MysticSettingLighting";
        case MysticSettingColorAdjustAll: return @"MysticSettingColorAdjustAll";
        case MysticSettingColorAdjustAlpha: return @"MysticSettingColorAdjustAlpha";
        case MysticSettingColorAdjustBrightness: return @"MysticSettingColorAdjustBrightness";
        case MysticSettingColorAdjustSaturation: return @"MysticSettingColorAdjustSaturation";
        case MysticSettingColorOffsetHue: return @"MysticSettingColorOffsetHue";
        case MysticSettingColorAdjustHue: return @"MysticSettingColorAdjustHue";
        case MysticSettingColorAdjust: return @"MysticSettingColorAdjust";
        case MysticSettingLightingAlpha: return @"MysticSettingLightingAlpha";
        case MysticSettingFrameAlpha: return @"MysticSettingFrameAlpha";
        case MysticSettingTextAlpha: return @"MysticSettingTextAlpha";
        case MysticSettingColorBalance: return @"MysticSettingColorBalance";
        case MysticSettingColorBalanceRed: return @"MysticSettingColorBalanceRed";
        case MysticSettingColorBalanceGreen: return @"MysticSettingColorBalanceGreen";
        case MysticSettingColorBalanceBlue: return @"MysticSettingColorBalanceBlue";
        case MysticSettingFilterAlpha: return @"MysticSettingFilterAlpha";
        case MysticSettingChooseTextType: return @"MysticSettingChooseTextType";
        case MysticObjectTypeFont: return @"MysticObjectTypeFont";
        case MysticObjectTypeFontStyle: return @"MysticObjectTypeFontStyle";
        case MysticSettingFilter: return @"MysticSettingFilter";
        case MysticSettingBadgeAlpha: return @"MysticSettingBadgeAlpha";
        case MysticSettingChooseText: return @"MysticSettingChooseText";
        case MysticSettingCrop: return @"MysticSettingCrop";
        case MysticSettingTiltShift: return @"MysticSettingTiltShift";
        case MysticSettingHaze: return @"MysticSettingHaze";
        case MysticSettingHazeSlope: return @"MysticSettingHazeSlope";
        case MysticSettingChooseColor: return @"MysticSettingChooseColor";
        case MysticSettingChooseColorAndIntensity: return @"MysticSettingChooseColorAndIntensity";
        case MysticSettingColor: return @"MysticSettingColor";
        case MysticSettingColorAndIntensity: return @"MysticSettingColorAndIntensity";
        case MysticSettingChooseColorFilter: return @"MysticSettingChooseColorFilter";
        case MysticSettingBrightness: return @"MysticSettingBrightness";
        case MysticSettingWearAndTear: return @"MysticSettingWearAndTear";
        case MysticSettingContrast: return @"MysticSettingContrast";
        case MysticSettingEditType: return @"MysticSettingEditType";
        case MysticSettingEditText: return @"MysticSettingEditText";
        case MysticSettingEditTexture: return @"MysticSettingEditTexture";
        case MysticSettingEditFrame: return @"MysticSettingEditFrame";
        case MysticSettingEditFilter: return @"MysticSettingEditFilter";
        case MysticSettingEditLighting: return @"MysticSettingEditLighting";
        case MysticSettingEditPotion: return @"MysticSettingEditPotion";
        case MysticSettingEditFont: return @"MysticSettingEditFont";
        case MysticSettingType: return @"MysticSettingType";
        case MysticSettingTypeNew: return @"MysticSettingTypeNew";
        case MysticSettingInTransition: return @"MysticSettingInTransition";
        case MysticSettingSelectType: return @"MysticSettingSelectType";
        case MysticSettingSelectTypeInit: return @"MysticSettingSelectTypeInit";
        case MysticSettingTypeAlpha: return @"MysticSettingTypeAlpha";
        case MysticSettingGamma: return @"MysticSettingGamma";
        case MysticSettingExposure: return @"MysticSettingExposure";
        case MysticSettingHSB: return @"MysticSettingHSB";
        case MysticSettingHSBHue: return @"MysticSettingHSBHue";
        case MysticSettingHSBSaturation: return @"MysticSettingHSBSaturation";
        case MysticSettingHSBBrightness: return @"MysticSettingHSBBrightness";
        case MysticSettingVignette: return @"MysticSettingVignette";
        case MysticSettingTemperature: return @"MysticSettingTemperature";
        case MysticSettingSaturation: return @"MysticSettingSaturation";
        case MysticSettingTransform: return @"MysticSettingTransform";
        case MysticSettingRecipe: return @"MysticSettingRecipe";
        case MysticSettingOpenPhoto: return @"MysticSettingOpenPhoto";
        case MysticSettingTextTransform: return @"MysticSettingTextTransform";
        case MysticSettingBadgeTransform: return @"MysticSettingBadgeTransform";
        case MysticSettingFrameTransform: return @"MysticSettingFrameTransform";
        case MysticSettingMaskTransform: return @"MysticSettingMaskTransform";
        case MysticSettingShadows: return @"MysticSettingShadows";
        case MysticSettingAlpha: return @"MysticSettingAlpha";
        case MysticSettingHighlights: return @"MysticSettingHighlights";
        case MysticSettingSharpness: return @"MysticSettingSharpness";
        case MysticSettingNone: return @"MysticSettingNone";
        case MysticSettingUnLaunched: return @"MysticSettingUnLaunched";
        case MysticSettingDraw: return @"MysticSettingDraw";
        case MysticSettingLaunch: return @"MysticSettingLaunch";
        case MysticSettingDrawMask: return @"MysticSettingDrawMask";
        case MysticSettingMenu: return @"MysticSettingMenu";
        case MysticSettingPreview: return @"MysticSettingPreview";
        case MysticSettingShop: return @"MysticSettingShop";
        case MysticSettingFeedback: return @"MysticSettingFeedback";
        case MysticSettingShape: return @"MysticSettingShape";
        case MysticSettingPreferences: return @"MysticSettingPreferences";
        case MysticSettingSettings: return @"MysticSettingSettings";
        case MysticSettingSettingsLayer: return @"MysticSettingSettingsLayer";
        case MysticSettingBlending: return @"MysticSettingBlending";
        case MysticSettingAboutProject: return @"MysticSettingAboutProject";
        case MysticSettingStartProject: return @"MysticSettingStartProject";
        case MysticSettingRecipeProject: return @"MysticSettingRecipeProject";
        case MysticSettingAboutProjects: return @"MysticSettingAboutProjects";
        case MysticSettingRecipeProjects: return @"MysticSettingRecipeProjects";
        case MysticSettingShare: return @"MysticSettingShare";
        case MysticObjectTypeShape: return @"MysticObjectTypeShape";
        case MysticObjectTypeUnknown: return @"MysticObjectTypeUnknown";
#ifdef DEBUG
        case MysticSettingTest: return @"MysticSettingTest";
#endif
        case MysticSettingBackgroundColor: return @"MysticSettingBackgroundColor";
        case MysticSettingForegroundColor: return @"MysticSettingForegroundColor";
        case MysticSettingPotions: return @"MysticSettingPotions";
        case MysticSettingColorFilter: return @"MysticSettingColorFilter";
        case MysticSettingRGB: return @"MysticSettingRGB";
        case MysticSettingShadowsHighlights: return @"MysticSettingShadowsHighlights";
        case MysticSettingFill: return @"MysticSettingFill";
        case MysticSettingLayerEffect: return @"MysticSettingLayerEffect";
        case MysticSettingTransformAdjusted: return @"MysticSettingTransformAdjusted";
        case MysticSettingAdjustTransformRect: return @"MysticSettingAdjustTransformRect";
        case MysticSettingFontMove: return @"MysticSettingFontMove";
        case MysticSettingFontAdd: return @"MysticSettingFontAdd";
        case MysticSettingFontStyle: return @"MysticSettingFontStyle";
        case MysticSettingFontClone: return @"MysticSettingFontClone";
        case MysticSettingFontSelect: return @"MysticSettingFontSelect";
        case MysticSettingFontColor: return @"MysticSettingFontColor";
        case MysticSettingFontDelete: return @"MysticSettingFontDelete";
        case MysticSettingFontEdit: return @"MysticSettingFontEdit";
        case MysticSettingLayerBorder: return @"MysticSettingLayerBorder";
        case MysticSettingLayerShadow: return @"MysticSettingLayerShadow";
        case MysticSettingLayerColor: return @"MysticSettingLayerColor";
        case MysticSettingLayerContent: return @"MysticSettingLayerContent";
        case MysticSettingLayerPosition: return @"MysticSettingLayerPosition";
        case MysticSettingVibrance: return @"MysticSettingVibrance";
        case MysticSettingSkin: return @"MysticSettingSkin";
        case MysticSettingDesign: return @"MysticSettingDesign";
        case MysticSettingUnknown: return @"MysticSettingUnknown";
            
        default: break;
    }
    return [NSString stringWithFormat:@"(type string not found: %d)", (int) type];
}

uint64_t MysticGetFileSize(NSString *path, BOOL inMB)
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) return -1;
    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize] unsignedLongLongValue];
    
    return inMB ? ((fileSize/1024ll)/1024ll) : fileSize;
    
}


NSString * AdjustmentStateToString(MysticAdjustmentState state)
{
    switch (state) {
        case MysticAdjustmentStateUnrendered: return @"?";
        case MysticAdjustmentStateRendered: return @"r";
        case MysticAdjustmentStateNotAdjusted: return @"-";
        default: break;
    }
    return @"unknown";
}
NSString *MysticStrings(NSArray *types)
{
    NSMutableString *s = [NSMutableString string];
    for (NSNumber *t in types) {
        [s appendFormat:@"\n\t%d: %@", [t intValue], MysticString([t intValue])];
    }
    return s;
}

NSString *m(MysticObjectType type)
{
    return MysticObjectTypeToString(type);
}
NSString *MysticString(MysticObjectType type)
{
    return MysticObjectTypeToString(type);
}
NSString *MyString(MysticObjectType type)
{
    NSString *s = [MysticObjectTypeToString(type) stringByReplacingOccurrencesOfString:@"MysticSetting" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"MysticObjectType" withString:@""];
    return [s stringByReplacingOccurrencesOfString:@"Mystic" withString:@""];
}

MysticShareType MysticShareTypeForType(MysticIconType iconType)
{
    switch ((NSInteger)iconType) {
        case MysticIconTypeShareCircleSave:
        case MysticIconTypeShareSave:
        case MysticShareTypeSave:
            
            return MysticShareTypeSave;
        case MysticIconTypeShareCircleFacebook:
        case MysticIconTypeShareFacebook:
        case MysticShareTypeFacebook:
            return MysticShareTypeFacebook;
            
        case MysticIconTypeShareCircleTribe:
        case MysticIconTypeShareMysticTribe:
        case MysticShareTypeTribe:
            return MysticShareTypeTribe;
            
        case MysticIconTypeShareCircleEmail:
        case MysticIconTypeShareEmail:
        case MysticShareTypeEmail:
            return MysticShareTypeEmail;
            
        case MysticIconTypeShareCirclePinterest:
        case MysticIconTypeSharePinterest:
        case MysticShareTypePinterest:
            return MysticShareTypePinterest;
            
        case MysticIconTypeShareCircleTwitter:
        case MysticIconTypeShareTwitter:
        case MysticShareTypeTwitter:
            return MysticShareTypeTwitter;
            
        case MysticIconTypeShareCircleOther:
        case MysticIconTypeShareOther:
        case MysticShareTypeOther:
            return MysticShareTypeOther;
            
        case MysticIconTypeShareCircleCopy:
        case MysticIconTypeShareCopy:
        case MysticShareTypeCopy:
            return MysticShareTypeCopy;
            
        case MysticIconTypeShareCircleInstagram:
        case MysticIconTypeShareInstagram:
        case MysticShareTypeInstagram:
            return MysticShareTypeInstagram;
            
        case MysticIconTypeShareCircleLink:
        case MysticIconTypeShareLink:
        case MysticShareTypeLink:
            return MysticShareTypeLink;
            
        case MysticIconTypeShareCirclePostcard:
        case MysticIconTypeSharePostcard:
        case MysticShareTypePostcard:
            return MysticShareTypePostcard;
            
        case MysticIconTypeShareCirclePotion:
        case MysticIconTypeSharePotion:
        case MysticShareTypePotion:
            return MysticShareTypePotion;
            
            
        default: break;
    }
    return MysticShareTypeUnknown;
}


NSString *MysticColorTypeString(MysticColorType type)
{
    switch (type) {
        case MysticColorTypeAuto: return @"MysticColorTypeAuto";
            
        case MysticColorTypeBlack: return @"MysticColorTypeBlack";
        case MysticColorTypeWhite: return @"MysticColorTypeWhite";
        case MysticColorTypeKhaki: return @"MysticColorTypeKhaki";
        case MysticColorTypePink: return @"MysticColorTypePink";
        case MysticColorTypeRed: return @"MysticColorTypeRed";
        case MysticColorTypeBlue: return @"MysticColorTypeBlue";
        case MysticColorTypeYellow: return @"MysticColorTypeYellow";
        case MysticColorTypeGreen: return @"MysticColorTypeGreen";
        case MysticColorTypeGold: return @"MysticColorTypeGold";
        case MysticColorTypeBrown: return @"MysticColorTypeBrown";
        case MysticColorTypeBeige: return @"MysticColorTypeBeige";
        case MysticColorTypeBackgroundBrown: return @"MysticColorTypeBackgroundBrown";
        case MysticColorTypeBackgroundBlack: return @"MysticColorTypeBackgroundBlack";
        case MysticColorTypeBackgroundWhite: return @"MysticColorTypeBackgroundWhite";
        case MysticColorTypeBackgroundGray: return @"MysticColorTypeBackgroundGray";
        case MysticColorTypeClear: return @"MysticColorTypeClear";
        case MysticColorTypeChromaGreen: return @"MysticColorTypeChromaGreen";
        case MysticColorTypeChromaBlue: return @"MysticColorTypeChromaBlue";
            
        default: break;
            
    }
    return @"(color type not found)";
}
NSString * MysticIndexPathToString(NSIndexPath *i)
{
    return [NSString stringWithFormat:@"{%d, %d}", (int)i.section, (int)i.item];
}
UIImage *imageInClipboard()
{
    return [UIPasteboard generalPasteboard].image;
}
NSString *MysticObjectTypeTitle(MysticObjectType type)
{
    return MysticObjectTypeTitleParent(type, nil);
}
NSString *MysticObjectTypeTitleParent(MysticObjectType type, MysticObjectType lastType)
{
    if((int)lastType == -2)
    {
        switch (type) {
            case MysticObjectTypeBadge:
            case MysticObjectTypeText: break;
            default: return MyLocalStr(MysticObjectTypeKey(type));
        }
    }
    NSString *title = nil;
    switch (type) {
        case MysticSettingInvert: title=@"Invert"; break;
        case MysticSettingGrain: title=@"Grain"; break;
        case MysticSettingAdjustColor: title=@"Recolor"; break;
        case MysticSettingVignetteBlending: title=@"Vignette Blend"; break;
        case MysticSettingStretch:
        case MysticSettingStretchAspectFill:
        case MysticSettingStretchAspectFit:
        case MysticSettingStretchFill:
        case MysticSettingStretchNone: title = @"Stretch"; break;
        case MysticSettingFlipHorizontal: title = @"Flip"; break;
        case MysticSettingFlipVertical: title = @"Flip"; break;
        case MysticSettingHighlightIntensity: title = @"Highlight Intensity"; break;
        case MysticSettingShadowIntensity: title = @"Shadow Intensity"; break;
        case MysticSettingHighlightTintColor: title = @"Highlight Tint"; break;
        case MysticSettingShadowTintColor: title = @"Shadow Tint"; break;
        case MysticSettingSkin: title = @"Skin"; break;
        case MysticObjectTypeSketch: title=@"Sketch"; break;
        case MysticSettingSkinHue: title = @"Skin Color"; break;
        case MysticSettingSkinHueThreshold: title = @"Skin Color Threshold"; break;
        case MysticSettingSkinMaxHueShift: title = @"Skin Color Max"; break;
        case MysticSettingSkinMaxSaturationShift: title = @"Skin Saturation"; break;
        case MysticSettingSkinUpperSkinToneColor: title = @"Skin Tone"; break;
        case MysticSettingMaskShape: title = @"Shape"; break;
        case MysticSettingMaskBrush: title = @"Reveal"; break;
        case MysticSettingMaskErase: title = @"Hide"; break;
        case MysticSettingMaskFill: title = @"Fill"; break;
        case MysticSettingMaskEmpty: title = @"Empty"; break;
        case MysticSettingMaskLayer: title = @"Mask"; break;
        case MysticSettingVibrance: title = @"Vibrance"; break;
        case MysticSettingShapeAlign: title = @"Align"; break;
        case MysticObjectTypeLayerShape: title = @"Symbols"; break;
        case MysticSettingShapeStyle:
        case MysticSettingFontStyle: title = @"Font"; break;
        case MysticSettingShapeAdd:
        case MysticSettingFontAdd: title = @"New"; break;
        case MysticSettingShapeEdit:
        case MysticSettingFontEdit: title = @"Edit"; break;
        case MysticSettingShapeClone:
        case MysticSettingFontClone: title = @"Clone"; break;
        case MysticSettingShapeSelect:
        case MysticSettingFontSelect: title = @"Select"; break;
        case MysticSettingShapeDelete:
        case MysticSettingFontDelete: title = @"Delete"; break;
        case MysticSettingShapeColor:
        case MysticSettingFontColor: title = @"Color"; break;
        case MysticSettingShapeMove:
        case MysticSettingFontMove: title = @"Nudge"; break;
        case MysticSettingAddLayer: title = @"Create"; break;
        case MysticObjectTypeCustom:
        case MysticObjectTypeCamLayer: title = @"Photo"; break;
        case MysticSettingColorBalance: title = @"RGB"; break;
        case MysticSettingLayers: title = @"Layers"; break;
        case MysticSettingOptions: title = @"Save"; break;
        case MysticSettingMenu: title = @"Menu"; break;
        case MysticSettingShare: title = @"Share"; break;
        case MysticSettingBackground: title = @"Background"; break;
        case MysticSettingFill: title = @"Fill Effect"; break;
        case MysticObjectTypeSpecial: title = @"Magic"; break;
        case MysticSettingHSBBrightness: title=@"Light"; break;
        case MysticSettingColorAndIntensity:
        case MysticSettingChooseColor:
        case MysticSettingColor:
        case MysticSettingChooseColorAndIntensity: title = @"Color"; break;
        case MysticSettingHSBHue: title = @"Hue"; break;
#ifdef DEBUG
        case MysticSettingTest: title = @"Test"; break;
#endif
        case MysticSettingHSBSaturation:
        case MysticSettingSaturation: title = @"Saturate"; break;
        case MysticSettingAutoEnhance: title = @"Enhance"; break;
        case MysticSettingIntensity: title = @"Intensity"; break;
        case MysticObjectTypeMixture:
        case MysticSettingMixtures: title = @"Mixtures"; break;
        case MysticObjectTypeFont: title = @"Text"; break;
        case MysticObjectTypeFontStyle: title = @"Font Style"; break;
        case MysticObjectTypeShape: title = @"Symbol"; break;
        case MysticSettingCropSourceImage: title = @"Crop"; break;
        case MysticSettingUnsharpMask: title = @"Sharpen"; break;
        case MysticSettingLevels: title = @"Levels"; break;
        case MysticSettingCamLayerSetup: title = @"Adjust"; break;
        case MysticObjectTypePack: title = @"Pack"; break;
        case MysticObjectTypeTextPack: title = @"TextPack"; break;
        case MysticObjectTypeLightPack: title = @"LightPack"; break;
        case MysticObjectTypeFramePack: title = @"FramePack"; break;
        case MysticObjectTypeTexturePack: title = @"TexturePack"; break;
        case MysticObjectTypeBadgePack: title = @"BadgePack"; break;
        case MysticObjectTypeOption: title = @"Option"; break;
        case MysticObjectTypeMulti:
        case MysticObjectTypePotion: title = @"Potion"; break;
        case MysticObjectTypeBadgeOverlay: title = @"BadgeOverlay"; break;
        case MysticObjectTypeTextOverlay: title = @"TextOverlay"; break;
        case MysticObjectTypeFilter: title = @"Filter"; break;
        case MysticObjectTypeFilterAlpha: title = @"Intensity"; break;
        case MysticObjectTypeOverlay: title = @"Overlay"; break;
        case MysticObjectTypeFrame: title = @"Frame"; break;
        case MysticObjectTypeMask: title = @"Mask"; break;
        case MysticObjectTypeDesign:
        case MysticObjectTypeText: title = @"Word Art"; break;
        case MysticObjectTypeTexture: title = @"Art"; break;
        case MysticSettingNewProject: title = @"New"; break;
        case MysticObjectTypeLight: title = @"Light"; break;
        case MysticObjectTypeImage: title = @"Image"; break;
        case MysticObjectTypeColor: title = @"Colors"; break;
        case MysticObjectTypeTextColor: title = @"TextColor"; break;
        case MysticObjectTypeBadgeColor: title = @"BadgeColor"; break;
        case MysticObjectTypeFrameBackgroundColor: title = @"FrameBackgroundColor"; break;
        case MysticObjectTypeBadge: title = @"Symbols"; break;
        case MysticObjectTypeSetting: title = @"Tune"; break;
        case MysticSettingColorOverlay:
        case MysticObjectTypeColorOverlay: title = @"Colors"; break;
        case MysticSettingBadge: title = @"Symbols"; break;
        case MysticSettingChooseText:
        case MysticSettingText: title = @"Word Art"; break;
        case MysticSettingFrame: title = @"Frame"; break;
        case MysticSettingMask: title = @"Mask"; break;
        case MysticSettingTexture: title = @"Texture"; break;
        case MysticSettingTextureAlpha: title = @"Intensity"; break;
        case MysticSettingLighting: title = @"Light"; break;
        case MysticSettingLightingAlpha: title = @"Intensity"; break;
        case MysticSettingFrameAlpha: title = @"Intensity"; break;
        case MysticSettingTextAlpha: title = @"Intensity"; break;
        case MysticSettingFilterAlpha: title = @"Intensity"; break;
        case MysticSettingFilter: title = @"Potion"; break;
        case MysticSettingBadgeAlpha: title = @"Intensity"; break;
        case MysticSettingCrop: title = @"Crop"; break;
        case MysticSettingTiltShift: title = @"Tilt"; break;
        case MysticSettingHaze: title = @"Haze"; break;
        case MysticSettingHazeSlope: title = @"Slope"; break;
        case MysticSettingBrightness: title = @"Brightness"; break;
        case MysticSettingWearAndTear: title = @"Grain"; break;
        case MysticSettingBlur: title = @"Blur"; break;
        case MysticSettingBlurCircle: title = @"Focus"; break;
        case MysticSettingBlurZoom: title = @"Zoom"; break;
        case MysticSettingBlurGaussian: title = @"Gaussian"; break;
        case MysticSettingBlurMotion: title = @"Motion"; break;
        case MysticSettingHalfTone: title = @"Half Tone"; break;
        case MysticSettingSketchFilter: title = @"Sketchy"; break;
        case MysticSettingPosterize: title = @"Posterize"; break;
        case MysticSettingDistortBuldge: title = @"Buldge"; break;
        case MysticSettingDistortPinch: title = @"Pinch"; break;
        case MysticSettingDistortStretch: title = @"Stretch"; break;
        case MysticSettingDistortGlassSphere: title = @"Sphere"; break;
        case MysticSettingDistortSwirl: title = @"Swirl"; break;
        case MysticSettingPixellate: title = @"Pixellate"; break;
        case MysticSettingToon: title = @"Toon"; break;
        case MysticSettingContrast:
        {
            switch(lastType)
            {
                case MysticSettingCamLayer: title = @"Make Darker"; break;
                default: title = @"Contrast";  break;
            }
            break;
        }
        case MysticSettingGamma: title = @"Gamma"; break;
        case MysticSettingExposure:
            switch(lastType)
            {
                case MysticSettingCamLayer: title = @"Exposure";     break;
                default: title = @"Exposure";     break;
            }
            break; 
            
        case MysticSettingVignette: title = @"Vignette"; break;
        case MysticSettingTemperature: title = @"Tone"; break; 
        case MysticSettingTransform: title = @"Transform"; break;
        case MysticSettingTextTransform: title = @"TextTransform"; break;
        case MysticSettingBadgeTransform: title = @"BadgeTransform"; break;
        case MysticSettingFrameTransform: title = @"FrameTransform"; break;
        case MysticSettingMaskTransform: title = @"MaskTransform"; break;
        case MysticSettingShadows: title = @"Shadow"; break;
        case MysticSettingHighlights: title = @"Highlight"; break;
        case MysticSettingSharpness: title = @"Sharpen"; break;
        case MysticSettingNone: title = @""; break;
        case MysticSettingPreview: title = @"Preview"; break;
        case MysticSettingShop: title = @"Shop"; break;
        case MysticSettingFeedback: title = @"Feedback"; break;
        case MysticSettingPreferences: title = @"Preferences"; break;
        case MysticSettingSettings: title = @"Tune"; break;
        case MysticSettingBlending: title = @"Blend"; break;
        case MysticSettingCamLayerTakePhoto: title = @"New Layer"; break; 
        default: title = @""; break;
    }
    return title ? NSLocalizedString(title, nil) : nil;
}



MysticObjectType MysticTypeForSetting(MysticObjectType type, id optionObj)
{
    PackPotionOption *option = (PackPotionOption *)optionObj;
    switch (type)
    {
        case MysticObjectTypeSpecial:
            return MysticObjectTypeSpecial;
            
        case MysticObjectTypeShape:
        case MysticSettingShape:
            return MysticObjectTypeShape;
            
        case MysticSettingChooseColor:
        case MysticSettingEditColor:
        case MysticObjectTypeColor:
            return MysticObjectTypeColor;
            
        case MysticSettingColorOverlay:
        case MysticObjectTypeColorOverlay:
            return MysticObjectTypeColorOverlay;
            
        case MysticSettingEditBlending:
        case MysticObjectTypeBlend:
        case MysticSettingBlending:
            return MysticObjectTypeBlend;
            
        case MysticSettingEditCamLayer:
        case MysticSettingCamLayerAlpha:
        case MysticSettingCamLayerColor:
        case MysticSettingCamLayerSetup:
        case MysticSettingCamLayerTakePhoto:
        case MysticObjectTypeCamLayer:
        case MysticSettingCamLayer:
            return MysticObjectTypeCamLayer;
            
        case MysticSettingEditMask:
        case MysticSettingMaskTransform:
        case MysticObjectTypeMask:
        case MysticSettingMask:
            return MysticObjectTypeMask;
            
        case MysticSettingEditFont:
        case MysticSettingSelectType:
        case MysticSettingChooseFont:
        case MysticSettingChooseType:
        case MysticObjectTypeFont:
            return MysticObjectTypeFont;
            
        case MysticObjectTypeFontStyle:
            return MysticObjectTypeFontStyle;
            
        case MysticSettingEditColorFilter:
        case MysticSettingColorFilter:
        case MysticSettingChooseColorFilter:
        case MysticSettingEditFilter:
        case MysticSettingFilterAlpha:
        case MysticObjectTypeFilter:
        case MysticSettingFilter:
            return MysticObjectTypeFilter;
            
        case MysticSettingEditFrame:
        case MysticSettingFrameAlpha:
        case MysticSettingFrameColor:
        case MysticSettingFrameTransform:
        case MysticObjectTypeFrame:
        case MysticSettingFrame:
            return MysticObjectTypeFrame;
            
        case MysticSettingEditTexture:
        case MysticSettingTextureAlpha:
        case MysticObjectTypeTexture:
        case MysticSettingTexture:
            return MysticObjectTypeTexture;
            
        case MysticSettingTextAlpha:
        case MysticSettingTextColor:
        case MysticSettingTextTransform:
        case MysticSettingEditText:
        case MysticObjectTypeText:
        case MysticSettingText:
        case MysticSettingDesign:
        case MysticObjectTypeDesign:
        case MysticSettingEditDesign:
            return MysticObjectTypeText;
            
        case MysticSettingBadgeAlpha:
        case MysticSettingBadgeColor:
        case MysticSettingBadgeTransform:
        case MysticSettingEditBadge:
        case MysticObjectTypeBadge:
        case MysticSettingBadge:
            return MysticObjectTypeBadge;
            
        case MysticSettingLightingAlpha:
        case MysticSettingEditLighting:
        case MysticObjectTypeLight:
        case MysticSettingLighting:
            return MysticObjectTypeLight;
            
            
        case MysticObjectTypeMixture:
        case MysticSettingMixtures:
            return MysticObjectTypeMixture;
            
        case MysticObjectTypePotion:
        case MysticSettingPotions:
            return MysticObjectTypePotion;
            
        case MysticSettingEditSettings:
        case MysticSettingTemperature:
        case MysticSettingTiltShift:
        case MysticSettingSaturation:
        case MysticSettingVignette:
        case MysticSettingGamma:
        case MysticSettingContrast:
        case MysticSettingWearAndTear:
        case MysticSettingExposure:
        case MysticSettingHighlights:
        case MysticSettingShadows:
        case MysticSettingBrightness:
        case MysticSettingHaze:
        case MysticSettingHazeSlope:
        case MysticSettingSharpness:
        case MysticSettingLevels:
        case MysticSettingUnsharpMask:
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceBlue:
        case MysticObjectTypeSetting:
        case MysticSettingSettings:
            return option ? option.type : MysticObjectTypeSetting;
            
        case MysticSettingLayers:
        case MysticSettingOptions:
        case MysticObjectTypeAll:
            return MysticObjectTypeAll;
            
        default:
            return type;
    }
    return MysticObjectTypeUnknown;
}

BOOL usingIOS8 ()
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // Load resources for iOS 7.1 or earlier
        return NO;
    } else {
        // Load resources for iOS 7 or later
    }
    return YES;
}

BOOL usingIOS7 ()
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        return NO;
    } else {
        // Load resources for iOS 7 or later
    }
    return YES;
}
BOOL RGBIsEqual(MysticRGB r, MysticRGB g)
{
    return r.red==g.red && r.green==g.green&&r.blue==g.blue&&r.alpha==g.alpha;
}
BOOL MysticColorHSBIsEqual(MysticColorHSB r, MysticColorHSB g)
{
    return r.hue==g.hue&&r.saturation==g.saturation&&r.brightness==g.brightness&&r.alpha==g.alpha;
}
NSArray *NSArrayWithRGB(MysticRGB rgb)
{
    return [NSArray arrayWithObjects:@(rgb.red),@(rgb.green),@(rgb.blue),@(rgb.alpha), nil];
}
NSArray *NSArrayWithThreshold(MysticThreshold rgb)
{
    return [NSArray arrayWithObjects:@[@(rgb.range.min),@(rgb.range.mid),@(rgb.range.max)],@(rgb.threshold),@(rgb.smoothing),@(rgb.intensity), nil];
}
MysticThreshold ThresholdWithArray(NSArray *rgb)
{
    return (MysticThreshold){{[[rgb.firstObject firstObject] floatValue],[[rgb.firstObject objectAtIndex:1] floatValue], [[rgb.firstObject lastObject] floatValue]},[[rgb objectAtIndex:1] floatValue],[[rgb objectAtIndex:2] floatValue],[rgb.lastObject floatValue]};

}
MysticRGB RGBWithArray(NSArray *rgb)
{
    return (MysticRGB){[rgb.firstObject floatValue],[[rgb objectAtIndex:1] floatValue],[[rgb objectAtIndex:2] floatValue],[rgb.lastObject floatValue]};
}
BOOL MysticRGBisBlack(MysticRGB rgb)
{
    return rgb.red == 0 && rgb.green==0 && rgb.blue==0;
}
BOOL MysticRGBisWhite(MysticRGB rgb)
{
    return rgb.red == 1 && rgb.green==1 && rgb.blue==1;
}
float ColorMean(UIColor *avg, UIColor*max, UIColor*min)
{
    MysticRGB a = avg.rgb;
    MysticRGB mn = min.rgb;
    MysticRGB mx = max.rgb;
    mn.red+=mx.red;
    mn.green+=mx.green;
    mn.blue+=mx.blue;
    float m = mn.red+mn.green+mn.blue;
    float aa = a.red+a.green+a.blue;
    return aa/m;
}
MysticRGB RGBRed(MysticRGB rgb, float v)
{
    return (MysticRGB){v, rgb.green, rgb.blue, rgb.alpha};
}
MysticRGB RGBBlue(MysticRGB rgb, float v)
{
    return (MysticRGB){rgb.red, rgb.green, v, rgb.alpha};
}
MysticRGB RGBGreen(MysticRGB rgb, float v)
{
    return (MysticRGB){rgb.red, v, rgb.blue, rgb.alpha};
}
MysticRGB RGBAlpha(MysticRGB rgb, float v)
{
    return (MysticRGB){rgb.red, rgb.green, rgb.blue, v};
}
MysticHSBInt HSBInt(MysticColorHSB hsb)
{
    MysticHSBInt i = (MysticHSBInt){0,0.0,0.0};
    i.saturation=hsb.saturation;
    i.brightness=hsb.brightness;
    i.hue = [@(hsb.hue*360) intValue];
    return i;
}
NSString *MysticThresholdStr(MysticThreshold t)
{
    NSString *th = [NSString stringWithFormat:@"%2.2f", t.threshold];
    NSString *sm = [NSString stringWithFormat:@"%2.2f", t.smoothing];
    NSString *inten = [NSString stringWithFormat:@"%2.2f", t.intensity];
    
    return [NSString stringWithFormat:@"%2.2f - %2.2f - %2.2f  |  %@, %@, %@", t.range.min, t.range.mid, t.range.max, th, sm, inten];
}
NSString *MysticHSBStr(MysticColorHSB hsb)
{
    return MysticHSBStrh(hsb, -1);
}
NSString *ColorRGBStr(UIColor *c)
{
    float r1 = c.red;
    float g1 = c.green;
    float b1 = c.blue;
    NSString *r = [NSString stringWithFormat:@"%2.2f", r1];
    NSString *g = [NSString stringWithFormat:@"%2.2f", g1];
    NSString *b = [NSString stringWithFormat:@"%2.2f", b1];
    return [NSString stringWithFormat:@"%@, %@, %@", r, g, b];
}
NSString *RGBStr(float r1, float g1, float b1)
{
    NSString *r = [NSString stringWithFormat:@"%2.2f", r1];
    NSString *g = [NSString stringWithFormat:@"%2.2f", g1];
    NSString *b = [NSString stringWithFormat:@"%2.2f", b1];
    return [NSString stringWithFormat:@"%@, %@, %@", r, g, b];
}
NSString *MysticHSBStrh(MysticColorHSB hsb, int highlight)
{
    NSString *r = [NSString stringWithFormat:@"%2.2f", hsb.hue];
    NSString *g = [NSString stringWithFormat:@"%2.2f", hsb.saturation];
    NSString *b = [NSString stringWithFormat:@"%2.2f", hsb.brightness];
//    UIColor *c = [[UIColor colorWithHSBA:hsb] colorWithMinBrightness:0.1];
    if(highlight==2 || highlight==4) g = ColorWrap(g,COLOR_YELLOW);
    if(highlight==3 || highlight==4) b = ColorWrap(b,COLOR_PINK);
    if(highlight==1 || highlight==4) r = ColorWrap(r,COLOR_PURPLE);
    return [NSString stringWithFormat:@"%@, %@, %@", r, g, b];
}
NSString *MysticHSBColorStr(MysticColorHSB hsb, int highlight, UIColor *c)
{
    NSString *r = [NSString stringWithFormat:@"%2.2f", hsb.hue];
    NSString *g = [NSString stringWithFormat:@"%2.2f", hsb.saturation];
    NSString *b = [NSString stringWithFormat:@"%2.2f", hsb.brightness];
    //    UIColor *c = [[UIColor colorWithHSBA:hsb] colorWithMinBrightness:0.1];
    if(highlight==2 || highlight==4) g = ColorWrap(g,c ? c : [UIColor colorWithHSB:(MysticHSB){hsb.hue, hsb.saturation, 0.7}]);
    if(highlight==3 || highlight==4) b = ColorWrap(b,c ? c : [UIColor colorWithHSB:(MysticHSB){hsb.hue, hsb.saturation, hsb.brightness}]);
    if(highlight==1 || highlight==4) r = ColorWrap(r,c ? c : [UIColor colorWithHSB:(MysticHSB){hsb.hue, 1.0, 0.7}]);
    return [NSString stringWithFormat:@"%@, %@, %@", r, g, b];
}
NSString *MysticRGBStr(MysticRGB rgb)
{
    return MysticRGBStrh(rgb,-1);
}
NSString *MysticRGBStrh(MysticRGB rgb, int highlight)
{
    NSString *r = [NSString stringWithFormat:@"%2.2f", rgb.red];
    NSString *g = [NSString stringWithFormat:@"%2.2f", rgb.green];
    NSString *b = [NSString stringWithFormat:@"%2.2f", rgb.blue];
    NSString *a = [NSString stringWithFormat:@"%2.2f", rgb.alpha];
    
    if(highlight==2 || highlight==4) g = ColorWrap(g,COLOR_GREEN_BRIGHT);
    if(highlight==3 || highlight==4) b = ColorWrap(b,COLOR_BLUE);
    if(highlight==1 || highlight==4) r = ColorWrap(r,COLOR_RED);
    if(highlight==0 || highlight==4) a = ColorWrap(a,COLOR_PURPLE);
    
    return [NSString stringWithFormat:@"%@, %@, %@, %@", r, g, b, a];

}
NSString *MysticObjectTypeKey(MysticObjectType type)
{
    switch (type) {
        case MysticObjectTypeLayerShape: return @"items";
        case MysticObjectTypeSpecial: return @"specials";
        case MysticObjectTypeLight: return @"lights";
        case MysticObjectTypeText: return @"text";
        case MysticObjectTypeTexture: return @"textures";
            
        case MysticObjectTypeFrame: return @"frames";
        case MysticObjectTypeMask: return @"masks";
        case MysticObjectTypeBadge: return @"badges";
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter: return @"filters";
        case MysticObjectTypeColor: return @"colors";
        case MysticObjectTypeColorOverlay: return @"color_overlays";
            
        case MysticObjectTypePack: return @"packs";
            
        default: break;
    }
    return @"unknown";
}
MysticOptionTypes MysticOptionTypesWithArray(NSArray *typesArray)
{
    MysticOptionTypes types = MysticOptionTypeUnknown;
    for (NSNumber *n in typesArray) {
        types = types | MysticTypeToOptionTypes(((MysticObjectType)[n integerValue]));
    }
    return types;
}
MysticOptionTypes MysticObjectTypeToOptionTypes(MysticObjectType type)
{
    MysticOptionTypes types;
    
    switch (type) {
        case MysticObjectTypeFrame:
        case MysticObjectTypeFrameSettings:
            types = MysticOptionTypeFrame;
            break;
        case MysticObjectTypeLayerShape:
            
            types = MysticOptionTypeLayerShape;
            break;
        case MysticObjectTypeDesign:
        case MysticObjectTypeDesignSettings:
            
        case MysticObjectTypeText:
            types = MysticOptionTypeText;
            break;
        case MysticObjectTypeTexture:
        case MysticObjectTypeTextureSettings:
            
            types = MysticOptionTypeTexture;
            break;
        case MysticObjectTypePack:
            types = MysticOptionTypePack;
            break;
        case MysticObjectTypeFilter:
            
            types = MysticOptionTypeFilter;
            break;
        case MysticObjectTypeSetting:
            types = MysticOptionTypeSetting;
            break;
        case MysticObjectTypeBadge:
        case MysticObjectTypeBadgeSettings:
            
            types = MysticOptionTypeBadge;
            break;
        case MysticObjectTypeFont:
            types = MysticOptionTypeFont;
            break;
        case MysticObjectTypeFontStyle:
            types = MysticOptionTypeFontStyle;
            break;
        case MysticObjectTypeShape:
            types = MysticOptionTypeShape;
            break;
        case MysticObjectTypeLayer:
            types = MysticOptionTypeLayer;
            break;
        case MysticObjectTypeAll:
            types = MysticOptionTypeAll;
            break;
        case MysticObjectTypeLight:
        case MysticObjectTypeLightSettings:
            
            types = MysticOptionTypeLight;
            break;
        case MysticObjectTypeRecipe:
            types = MysticOptionTypeRecipe;
            break;
        case MysticObjectTypeColorOverlay:
            types = MysticOptionTypeColorOverlay;
            break;
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeCamLayerSettings:
            types = MysticOptionTypeLayer;
            break;
            
        default:
            types = MysticOptionTypeUnknown;
            break;
    }
    
    return types;
}
MysticOptionTypes MysticTypeToOptionTypes(MysticOptionTypes type)
{
    MysticOptionTypes types = type;
    if(types < MysticOptionTypeAll)
    {
        NSInteger objType = (NSInteger)types;
        
        switch ((MysticObjectType)objType) {
            case MysticObjectTypeFrame:
            case MysticObjectTypeFrameSettings:
                types = MysticOptionTypeFrame;
                break;
            case MysticObjectTypeLayerShape:
                types = MysticOptionTypeLayerShape;
                break;
            case MysticObjectTypeDesign:
            case MysticObjectTypeText:
            case MysticObjectTypeDesignSettings:
                types = MysticOptionTypeText;
                break;
            case MysticObjectTypeTexture:
            case MysticObjectTypeTextureSettings:
                types = MysticOptionTypeTexture;
                break;
            case MysticObjectTypePack:
                types = MysticOptionTypePack;
                break;
            case MysticObjectTypeFilter:
                types = MysticOptionTypeFilter;
                break;
            case MysticObjectTypeSetting:
                types = MysticOptionTypeSetting;
                break;
            case MysticObjectTypeBadge:
            case MysticObjectTypeBadgeSettings:
                types = MysticOptionTypeBadge;
                break;
            case MysticObjectTypeFont:
                types = MysticOptionTypeFont;
                break;
            case MysticObjectTypeFontStyle:
                types = MysticOptionTypeFontStyle;
                break;
            case MysticObjectTypeShape:
                types = MysticOptionTypeShape;
                break;
            case MysticObjectTypeLayer:
                types = MysticOptionTypeLayer;
                break;
            case MysticObjectTypeAll:
                types = MysticOptionTypeAll;
                break;
            case MysticObjectTypeLight:
            case MysticObjectTypeLightSettings:
                types = MysticOptionTypeLight;
                break;
            case MysticObjectTypeRecipe:
                types = MysticOptionTypeRecipe;
                break;
            case MysticObjectTypeColorOverlay:
                types = MysticOptionTypeColorOverlay;
                break;
                
            default: break;
        }
    }
    return types;
}
MysticObjectType MysticOptionTypesToObjectType(MysticOptionTypes types)
{
    NSArray *t = MysticOptionTypesToObjectTypes(types);
    return t.count ? (MysticObjectType)[[t objectAtIndex:0] integerValue] : MysticObjectTypeUnknown;
}

NSArray *MysticOptionTypesToObjectTypeKeys(MysticOptionTypes types)
{
    return MysticOptionTypesToObjectTypesDictionary(types).allKeys;
}

MysticOptionTypes MysticOptionTypesClean(MysticOptionTypes types)
{
    types = !(types & MysticOptionTypeAllItems) ? types : types & ~MysticOptionTypeAllItems;
    types = !(types & MysticOptionTypeTopTenItems) ? types : types & ~MysticOptionTypeTopTenItems;
    types = !(types & MysticOptionTypeTopFortyItems) ? types : types & ~MysticOptionTypeTopFortyItems;
    types = !(types & MysticOptionTypeShowFeaturedPack) ? types : types & ~MysticOptionTypeShowFeaturedPack;
    types = !(types & MysticOptionTypeUseTypeTitle) ? types : types & ~MysticOptionTypeUseTypeTitle;
    types = !(types & MysticOptionTypeDataOnly) ? types : types & ~MysticOptionTypeDataOnly;
    
    
    return types;
}
NSArray *MysticOptionTypesToObjectTypes(MysticOptionTypes types)
{
    NSDictionary *t = MysticOptionTypesToObjectTypesDictionary(types);
    return t.allValues;
}
NSDictionary *MysticOptionTypesToObjectTypesDictionary(MysticOptionTypes optionTypes)
{
    NSMutableArray *type = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    MysticOptionTypes types = optionTypes;
    
    types = MysticOptionTypesClean(types);
    if(types & MysticOptionTypeLayer)
    {
        [type addObjectsFromArray:@[
                                    @(MysticObjectTypeTexture),
                                    @(MysticObjectTypeText),
                                    @(MysticObjectTypeFrame),
                                    @(MysticObjectTypeLight),
                                    @(MysticObjectTypeBadge),
                                    @(MysticObjectTypeFilter),
                                    @(MysticObjectTypeColorOverlay),
                                    ]];
    }
    else
    {
        if(types & MysticOptionTypePack)
        {
            [type addObject:@(MysticObjectTypePack)];
        }
        if(types & MysticOptionTypeText)
        {
            [type addObject:@(MysticObjectTypeText)];
            
        }
        if(types & MysticOptionTypeLayerPacks)
        {
            [type addObject:@(MysticObjectTypeLayerShape)];
            
        }
        if(types & MysticOptionTypeLayerShapePacks)
        {
            [type addObject:@(MysticObjectTypePack)];
            
        }
        if(types & MysticOptionTypeLight)
        {
            [type addObject:@(MysticObjectTypeLight)];
            
        }
        if(types & MysticOptionTypeTexture)
        {
            [type addObject:@(MysticObjectTypeTexture)];
            
        }
        if(types & MysticOptionTypeFrame)
        {
            [type addObject:@(MysticObjectTypeFrame)];
            
        }
        if(types & MysticOptionTypeFilter)
        {
            [type addObject:@(MysticObjectTypeFilter)];
            
        }
        if(types & MysticOptionTypeColorOverlay)
        {
            [type addObject:@(MysticObjectTypeColorOverlay)];
            
        }
        if(types & MysticOptionTypeFont)
        {
            [type addObject:@(MysticObjectTypeFont)];
            
        }
        if(types & MysticOptionTypeFontStyle)
        {
            [type addObject:@(MysticObjectTypeFontStyle)];
        }
        if(types & MysticOptionTypeBadge)
        {
            [type addObject:@(MysticObjectTypeBadge)];
        }
        if(types & MysticOptionTypeShape)
        {
            [type addObject:@(MysticObjectTypeShape)];
        }
        if(types & MysticOptionTypeSetting)
        {
            [type addObject:@(MysticObjectTypeSetting)];
        }
        if(types & MysticOptionTypeRecipe)
        {
            [type addObject:@(MysticObjectTypeRecipe)];
        }
        if(types & MysticOptionTypeLayerShape)
        {
            [type addObject:@(MysticObjectTypeLayerShape)];
        }
    }
    
    if(type.count)
    {
        for (NSNumber *typeObj in type) {
            id k = MysticObjectTypeKey([typeObj integerValue]);
            if(k) [keys addObject:k];
        }
    }
    
    NSDictionary *r =  keys.count == type.count && type.count ? [NSDictionary dictionaryWithObjects:type forKeys:keys] : [NSDictionary dictionaryWithObjects:type forKeys:type];
    
    
    
    return r;
}

BOOL MysticTypeSubTypeOf(MysticObjectType type, MysticObjectType parentType)
{
    switch (parentType) {
        case MysticObjectTypeBlendedLayer:
            switch (type) {
                case MysticObjectTypeImage:
                case MysticObjectTypeLight:
                case MysticObjectTypeText:
                case MysticObjectTypeTexture:
                case MysticObjectTypeFrame:
                case MysticObjectTypeBadge:
                case MysticObjectTypeColorOverlay:
                    
                    return YES;
                    break;
                    
                default: break;
            }
            break;
            
        default: break;
    }
    switch (type) {
        case MysticSettingReset:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalance:
        case MysticSettingChooseColorFilter:
        case MysticSettingColorFilter:
        case MysticObjectTypeSetting:
        case MysticSettingSettings:
        case MysticSettingVignette:
        case MysticSettingContrast:
        case MysticSettingWearAndTear:
        case MysticSettingBrightness:
        case MysticSettingTemperature:
        case MysticSettingSaturation:
        case MysticSettingTiltShift:
        case MysticSettingSharpness:
        case MysticSettingShadows:
        case MysticSettingHighlights:
        case MysticSettingExposure:
        case MysticSettingHaze:
        case MysticSettingHazeSlope:
        case MysticSettingBlending:
        case MysticSettingGamma:
        case MysticSettingLevels:
        case MysticSettingUnsharpMask:
        case MysticSettingHSB:
        case MysticSettingHSBHue:
        case MysticSettingHSBSaturation:
        case MysticSettingHSBBrightness:
        {
            if(parentType == MysticSettingSettings || parentType == MysticSettingCamLayer || parentType == MysticSettingCamLayerTakePhoto)
            {
                return YES;
            }
            break;
        }
        case MysticSettingAboutProject:
        case MysticSettingRecipe:
        case MysticSettingAboutProjects:
        case MysticSettingRecipeProject:
        case MysticSettingRecipeProjects:
        case MysticSettingOpenPhoto:
            return parentType == MysticSettingRecipe;
            
        case MysticSettingCamLayerSetup:
        case MysticSettingCamLayerAlpha:
            return parentType == MysticSettingCamLayer;
        case MysticSettingLightingAlpha:
            return parentType == MysticSettingLighting;
        case MysticSettingTextureAlpha:
            return parentType == MysticSettingTexture;
        case MysticSettingBadgeAlpha:
            return parentType == MysticSettingBadge;
        case MysticSettingFrameAlpha:
            return parentType == MysticSettingFrame;
        case MysticSettingTextAlpha:
            return parentType == MysticSettingText;
        case MysticSettingFilterAlpha:
            return parentType == MysticSettingFilter;
            
        default: break;
    }
    return NO;
}


MysticFilterType MysticFilterTypeFromString(NSString *_type)
{
    if(ismt(_type)) return MysticFilterTypeUnknown;
    _type = [_type lowercaseString];
    if([_type isEqualToString:@"unknown"]) return MysticFilterTypeUnknown;
    if([_type isEqualToString:@"maskscreen"]) return MysticFilterTypeBlendMaskScreen;
    if([_type isEqualToString:@"maskmultiply"]) return MysticFilterTypeBlendMaskMultiply;
    if([_type isEqualToString:@"maskscreennofill"]) return MysticFilterTypeBlendMaskScreenNoFill;
    if([_type isEqualToString:@"maskmultiplynofill"]) return MysticFilterTypeBlendMaskMultiplyNoFill;
    
    if([_type isEqualToString:@"mysticfilter1"]) return MysticFilterTypeMysticFilter1;
    if([_type isEqualToString:@"lookup"]) return MysticFilterTypeLookup;
    if([_type isEqualToString:@"rotate"]) return MysticFilterTypeRotate;
    if([_type isEqualToString:@"dropwhite"]) return MysticFilterTypeDropWhite;
    if([_type isEqualToString:@"dropblack"]) return MysticFilterTypeDropBlack;
    if([_type isEqualToString:@"dropgreen"]) return MysticFilterTypeDropGreen;
    if([_type isEqualToString:@"chromakeyblend"]) return MysticFilterTypeBlendChromaKey;
    if([_type isEqualToString:@"chromakey"]) return MysticFilterTypeChromaKey;
    if([_type isEqualToString:@"greenmask"]) return MysticFilterTypeGreenMask;
    if([_type isEqualToString:@"transform"]) return MysticFilterTypeTransform;
    if([_type isEqualToString:@"saturation"]) return MysticFilterTypeSaturation;
    if([_type isEqualToString:@"exposure"]) return MysticFilterTypeExposure;
    if([_type isEqualToString:@"gamma"]) return MysticFilterTypeGamma;
    if([_type isEqualToString:@"brightness"]) return MysticFilterTypeBrightness;
    if([_type isEqualToString:@"contrast"]) return MysticFilterTypeContrast;
    if([_type isEqualToString:@"colormatrix"]) return MysticFilterTypeColorMatrix;
    if([_type isEqualToString:@"rgb"]) return MysticFilterTypeRGB;
    if([_type isEqualToString:@"hue"]) return MysticFilterTypeHue;
    if([_type isEqualToString:@"tonecurve"]) return MysticFilterTypeToneCurve;
    if([_type isEqualToString:@"highlightshadow"]) return MysticFilterTypeHighlightShadow;
    if([_type isEqualToString:@"amatorka"]) return MysticFilterTypeAmatorka;
    if([_type isEqualToString:@"missetikate"]) return MysticFilterTypeMissEtikate;
    if([_type isEqualToString:@"softelegance"]) return MysticFilterTypeSoftElegance;
    if([_type isEqualToString:@"colorinvert"]) return MysticFilterTypeColorInvert;
    if([_type isEqualToString:@"grayscale"]) return MysticFilterTypeGrayscale;
    if([_type isEqualToString:@"monochrome"]) return MysticFilterTypeMonochrome;
    if([_type isEqualToString:@"sepia"]) return MysticFilterTypeSepia;
    if([_type isEqualToString:@"opacity"]) return MysticFilterTypeOpacity;
    if([_type isEqualToString:@"luminance"]) return MysticFilterTypeLuminance;
    if([_type isEqualToString:@"luminosity"]) return MysticFilterTypeLuminosity;
    if([_type isEqualToString:@"multiply"]) return MysticFilterTypeBlendMultiply;
    if([_type isEqualToString:@"overlay"]) return MysticFilterTypeBlendOverlay;
    if([_type isEqualToString:@"screen"]) return MysticFilterTypeBlendScreen;
    if([_type isEqualToString:@"darken"]) return MysticFilterTypeBlendDarken;
    if([_type isEqualToString:@"lighten"]) return MysticFilterTypeBlendLighten;
    if([_type isEqualToString:@"colorburn"]) return MysticFilterTypeBlendColorBurn;
    if([_type isEqualToString:@"softlight"]) return MysticFilterTypeBlendSoftlight;
    if([_type isEqualToString:@"alpha"]) return MysticFilterTypeBlendAlpha;
    if([_type isEqualToString:@"alphamix"]) return MysticFilterTypeBlendAlphaMix;
    if([_type isEqualToString:@"mix"]) return MysticFilterTypeBlendMix;

    if([_type isEqualToString:@"alphadebug"]) return MysticFilterTypeBlendAlphaDebug;
    if([_type isEqualToString:@"alphaover"]) return MysticFilterTypeBlendAlphaOver;
    if([_type isEqualToString:@"colordodge"]) return MysticFilterTypeBlendColorDodge;
    if([_type isEqualToString:@"color"]) return MysticFilterTypeBlendColor;
    if([_type isEqualToString:@"crop"]) return MysticFilterTypeCrop;
    if([_type isEqualToString:@"vignette"]) return MysticFilterTypeVignette;
    if([_type isEqualToString:@"normal"]) return MysticFilterTypeBlendNormal;
    if([_type isEqualToString:@"mask"]) return MysticFilterTypeMask;
    if([_type isEqualToString:@"unsharpmask"]) return MysticFilterTypeUnsharpMask;
    if([_type isEqualToString:@"sharpen"]) return MysticFilterTypeSharpen;
    if([_type isEqualToString:@"dissolve"]) return MysticFilterTypeBlendDissolve;
    if([_type isEqualToString:@"pyramid"]) return MysticFilterTypePyramid;
    if([_type isEqualToString:@"whitebalance"]) return MysticFilterTypeWhiteBalance;
    if([_type isEqualToString:@"add"]) return MysticFilterTypeBlendAdd;
    if([_type isEqualToString:@"subtract"]) return MysticFilterTypeBlendSubtract;
    if([_type isEqualToString:@"linearburn"]) return MysticFilterTypeBlendLinearBurn;
    if([_type isEqualToString:@"hueblend"]) return MysticFilterTypeBlendHue;
    if([_type isEqualToString:@"lumblend"]) return MysticFilterTypeBlendLuminosity;
    if([_type isEqualToString:@"saturationblend"]) return MysticFilterTypeBlendSaturation;
    if([_type isEqualToString:@"divide"]) return MysticFilterTypeBlendDivide;
    if([_type isEqualToString:@"difference"]) return MysticFilterTypeBlendDifference;
    if([_type isEqualToString:@"exclusion"]) return MysticFilterTypeBlendExclusion;
    if([_type isEqualToString:@"hardlight"]) return MysticFilterTypeBlendHardlight;
    if([_type isEqualToString:@"cutout"]) return MysticFilterTypeBlendCutout;
    if([_type isEqualToString:@"alphamask"]) return MysticFilterTypeBlendAlphaMask;
    if([_type isEqualToString:@"alphamaskfillbg"]) return MysticFilterTypeBlendAlphaMaskFillBg;
    
    
    return MysticFilterTypeUnknown;
}


CGBlendMode CGBlendModeFromMysticFilterType(MysticFilterType _type)
{
    switch (_type) {
        case MysticFilterTypeBlendAuto:
            return kCGBlendModeNormal;
            
            
            
        case MysticFilterTypeBlendAlphaMask:
            return kCGBlendModeNormal;
            
        case MysticFilterTypeBlendExclusion:
            return kCGBlendModeExclusion;
            
        case MysticFilterTypeBlendDifference:
            return kCGBlendModeDifference;
            
        case MysticFilterTypeBlendDivide:
            return kCGBlendModeDifference;
            
        case MysticFilterTypeBlendSaturation:
            return kCGBlendModeSaturation;
            
        case MysticFilterTypeBlendLuminosity:
            return kCGBlendModeLuminosity;
            
        case MysticFilterTypeBlendHue:
            return kCGBlendModeHue;
            
        case MysticFilterTypeBlendLinearBurn:
            return kCGBlendModeDestinationOut;
            
        case MysticFilterTypeBlendSubtract:
            return kCGBlendModeDestinationOut;
            
        case MysticFilterTypeBlendAdd:
            return kCGBlendModeDestinationIn;
            
            
            //        case MysticFilterTypeBlendNormal:
            //            return kCGBlendModeNormal;
            
        case MysticFilterTypeBlendColor:
            return kCGBlendModeColor;
            
        case MysticFilterTypeBlendColorDodge:
            return kCGBlendModeColorDodge;
            
            
            
        case MysticFilterTypeBlendHardlight:
            return kCGBlendModeHardLight;
            
        case MysticFilterTypeBlendSoftlight:
            return kCGBlendModeSoftLight;
            
        case MysticFilterTypeBlendColorBurn:
            return kCGBlendModeColorBurn;
            
        case MysticFilterTypeBlendLighten:
            return kCGBlendModeLighten;
            
        case MysticFilterTypeBlendDarken:
            return kCGBlendModeDarken;
            
        case MysticFilterTypeBlendNormal:
        case MysticFilterTypeBlendAlphaMix:
        case MysticFilterTypeDropBlack:
        case MysticFilterTypeBlendAlpha:
        case MysticFilterTypeBlendScreen:
        case MysticFilterTypeBlendMaskScreen:
        case MysticFilterTypeBlendMaskScreenNoFill:
            
            return kCGBlendModeScreen;
        case MysticFilterTypeBlendAlphaOver:
        case MysticFilterTypeBlendAlphaDebug:
            return kCGBlendModeNormal;
            
        case MysticFilterTypeBlendOverlay:
            return kCGBlendModeOverlay;
            
        case MysticFilterTypeDropWhite:
        case MysticFilterTypeBlendMaskMultiply:
        case MysticFilterTypeBlendMaskMultiplyNoFill:
            
        case MysticFilterTypeBlendMultiply:
            return kCGBlendModeMultiply;
            
            
            
        default: break;
    }
    return kCGBlendModeNormal;
}
NSString *MysticLayerEffectNotifyString(MysticLayerEffect _type)
{
    NSString *str = @"";
    switch (_type) {
        case MysticLayerEffectDesaturate:
            str = @"Black & White";
            break;
        case MysticLayerEffectInverted:
            str = @"Inverted";
            break;
        case MysticLayerEffectOne:
            str = @"Sepia";
            break;
        case MysticLayerEffectTwo:
            str = @"Less Red";
            break;
        case MysticLayerEffectThree:
            str = @"Less Green";
            break;
        case MysticLayerEffectFour:
            str = @"Less Blue";
            break;
        case MysticLayerEffectNone:
            str = @"No Effect";
            break;
        case MysticLayerEffectRandom:
            str = @"Random";
            break;
        default: break;
    }
    return NSLocalizedString(str, nil);
}
NSString *MysticLayerEffectStr(MysticLayerEffect _type)
{
    NSString *str = @"";
    switch (_type) {
        case MysticLayerEffectDesaturate:
            str = @"MysticLayerEffectDesaturate";
            break;
        case MysticLayerEffectInverted:
            str = @"MysticLayerEffectInverted";
            break;
        case MysticLayerEffectOne:
            str = @"MysticLayerEffectOne";
            break;
        case MysticLayerEffectTwo:
            str = @"MysticLayerEffectTwo";
            break;
        case MysticLayerEffectThree:
            str = @"MysticLayerEffectThree";
            break;
        case MysticLayerEffectFour:
            str = @"MysticLayerEffectFour";
            break;
        case MysticLayerEffectNone:
            str = @"MysticLayerEffectNone";
            break;
        case MysticLayerEffectRandom:
            str = @"MysticLayerEffectRandom";
            break;
        default: break;
    }
    return NSLocalizedString(str, nil);
}
NSString *MysticFilterTypeToString(MysticFilterType _type)
{
    switch (_type) {
        case MysticFilterTypeBlendMaskShowBlack: return @"maskblack";
        case MysticFilterTypeUnknown: return @"unknown";
        case MysticFilterTypeBlendAuto: return @"auto";
        case MysticFilterTypeBlendMaskScreen: return @"maskscreen";
        case MysticFilterTypeBlendMaskMultiply: return @"maskmultiply";
        case MysticFilterTypeBlendMaskScreenNoFill: return @"maskscreennofill";
        case MysticFilterTypeBlendMaskMultiplyNoFill: return @"maskmultiplynofill";
            
        case MysticFilterTypeMysticFilter1: return @"mysticfilter1";
            
        case MysticFilterTypeToneCurve: return @"tonecurve";
        case MysticFilterTypeHue: return @"hue";
        case MysticFilterTypeRGB: return @"rgb";
        case MysticFilterTypeColorMatrix: return @"colormatrix";
        case MysticFilterTypeContrast: return @"contrast";
        case MysticFilterTypeBrightness: return @"brightness";
        case MysticFilterTypeGamma: return @"gamma";
        case MysticFilterTypeExposure: return @"exposure";
        case MysticFilterTypeSaturation: return @"saturation";
        case MysticFilterTypeTransform: return @"transform";
        case MysticFilterTypeGreenMask: return @"greenmask";
        case MysticFilterTypeChromaKey: return @"chromakey";
        case MysticFilterTypeBlendChromaKey: return @"chromakeyblend";
        case MysticFilterTypeDropGreen: return @"dropgreen";
        case MysticFilterTypeDropBlack: return @"dropblack";
        case MysticFilterTypeDropWhite: return @"dropwhite";
        case MysticFilterTypeRotate: return @"rotate";
        case MysticFilterTypeLookup: return @"lookup";
        case MysticFilterTypeBlendAlphaMask: return @"alphamask";
        case MysticFilterTypeBlendAlphaMaskFillBg: return @"alphamaskfillbg";
        case MysticFilterTypeBlendCutout: return @"cutout";
        case MysticFilterTypeBlendExclusion: return @"exclusion";
        case MysticFilterTypeBlendDifference: return @"difference";
        case MysticFilterTypeBlendDivide: return @"divide";
        case MysticFilterTypeBlendSaturation: return @"saturationblend";
        case MysticFilterTypeBlendLuminosity: return @"lumblend";
        case MysticFilterTypeBlendHue: return @"hueblend";
        case MysticFilterTypeBlendLinearBurn: return @"linearburn";
        case MysticFilterTypeBlendSubtract: return @"subtract";
        case MysticFilterTypeBlendAdd: return @"add";
        case MysticFilterTypeWhiteBalance: return @"whitebalance";
        case MysticFilterTypePyramid: return @"pyramid";
        case MysticFilterTypeBlendDissolve: return @"dissolve";
        case MysticFilterTypeSharpen: return @"sharpen";
        case MysticFilterTypeUnsharpMask: return @"unsharpmask";
        case MysticFilterTypeMask: return @"mask";
        case MysticFilterTypeBlendNormal: return @"normal";
        case MysticFilterTypeVignette: return @"vignette";
        case MysticFilterTypeCrop: return @"crop";
        case MysticFilterTypeBlendColor: return @"color";
        case MysticFilterTypeBlendColorDodge: return @"colordodge";
        case MysticFilterTypeBlendAlphaMix: return @"alphamix";
        case MysticFilterTypeBlendMix: return @"mix";
        case MysticFilterTypeBlendAlphaDebug: return @"alphadebug";
        case MysticFilterTypeBlendAlphaOver: return @"alphaover";
        case MysticFilterTypeBlendAlpha: return @"alpha";
        case MysticFilterTypeBlendHardlight: return @"hardlight";
        case MysticFilterTypeBlendSoftlight: return @"softlight";
        case MysticFilterTypeBlendColorBurn: return @"colorburn";
        case MysticFilterTypeBlendLighten: return @"lighten";
        case MysticFilterTypeBlendDarken: return @"darken";
        case MysticFilterTypeBlendScreen: return @"screen";
        case MysticFilterTypeBlendOverlay: return @"overlay";
        case MysticFilterTypeBlendMultiply: return @"multiply";
        case MysticFilterTypeLuminosity: return @"luminosity";
        case MysticFilterTypeLuminance: return @"luminance";
        case MysticFilterTypeOpacity: return @"opacity";
        case MysticFilterTypeSepia: return @"sepia";
        case MysticFilterTypeMonochrome: return @"monochrome";
        case MysticFilterTypeGrayscale: return @"grayscale";
        case MysticFilterTypeColorInvert: return @"colorinvert";
        case MysticFilterTypeSoftElegance: return @"softelegance";
        case MysticFilterTypeMissEtikate: return @"missetikate";
        case MysticFilterTypeAmatorka: return @"amatorka";
        case MysticFilterTypeHighlightShadow: return @"highlightshadow";
        default: break;
    }
    return [NSString stringWithFormat:@"not found (filter: %@)", @(_type)];
    
}

BOOL MysticTypeHasPack(MysticObjectType type)
{
    switch (type) {
        case MysticObjectTypePotion:
        case MysticObjectTypeColorOverlay:
        case MysticObjectTypeFilter:
        case MysticObjectTypeSpecial:
        case MysticObjectTypeBlend:
        case MysticObjectTypeColor:
        case MysticObjectTypeBackground:
        case MysticObjectTypeCustom:
        case MysticObjectTypeFont:
        case MysticObjectTypeFontStyle:
        case MysticObjectTypeGradient:
        case MysticObjectTypePack:
        case MysticObjectTypeSetting:
        case MysticObjectTypeShape:
        case MysticObjectTypeSourceSetting:
        case MysticObjectTypeSketch:
            
            return NO;
            
            
        default: break;
    }
    return YES;
}

NSString *MysticAdjustmentsToString(NSDictionary *adjustments)
{
    NSMutableDictionary *a = [NSMutableDictionary dictionary];
    for (id k in [adjustments objectForKey:@"keys"]) {
        NSString *nk = nil;
        MysticObjectType kt = [k integerValue];
        
        nk = MysticString(kt);
        [a setObject:[adjustments objectForKey:k] forKey:nk];
    }
    return [a description];
}
MysticObjectType MysticSettingForObjectType(MysticObjectType objectType)
{
    MysticObjectType nextSetting = MysticSettingUnknown;
    
    switch (objectType) {
        case MysticObjectTypeSpecial:
        {
            nextSetting = MysticObjectTypeSpecial;
            break;
        }
        case MysticObjectTypePotion:
        {
            nextSetting = MysticSettingPotions;
            break;
        }
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        {
            nextSetting = MysticSettingText;
            break;
        }
        case MysticObjectTypeSetting:
        {
            nextSetting = MysticSettingSettings;
            break;
        }
        case MysticObjectTypeFont:
        {
            nextSetting = MysticSettingType;
            break;
        }
        case MysticObjectTypeFilter:
        {
            nextSetting = MysticSettingFilter;
            break;
        }
        case MysticObjectTypeFrame:
        {
            nextSetting = MysticSettingFrame;
            break;
        }
        case MysticObjectTypeTexture:
        {
            nextSetting = MysticSettingTexture;
            break;
        }
        case MysticObjectTypeLight:
        {
            nextSetting = MysticSettingLighting;
            break;
        }
        case MysticObjectTypeBadge:
        {
            nextSetting = MysticSettingBadge;
            break;
        }
        case MysticObjectTypeShape:
        {
            nextSetting = MysticSettingShape;
            break;
        }
        case MysticSettingMixtures:
        {
            nextSetting = MysticSettingMixtures;
            break;
        }
        default:
            nextSetting = objectType;
            break;
    }
    return nextSetting;
}

id MysticSubviewOfClass(UIView *view, Class viewClass)
{
    for (UIView *subview in view.subviews) {
        if([subview isKindOfClass:viewClass]) return subview;
    }
    return nil;
}
BOOL CGRectGreater(CGRect r, CGRect bounds)
{
    return CGSizeGreater(r.size, bounds.size);
}
BOOL CGRectLess(CGRect r, CGRect bounds)
{
    return CGSizeLess(r.size, bounds.size);
}
BOOL CGSizeGreater(CGSize size1, CGSize size2)
{
    return size1.width > size2.width || size1.height > size2.height;
}
BOOL CGSizeLess(CGSize size1, CGSize size2)
{
    return size1.width < size2.width || size1.height < size2.height;
}
CGSize CGSizeImage(UIImage *source)
{
    CGSize imgSize = CGSizeMake(CGImageGetWidth(source.CGImage), CGImageGetHeight(source.CGImage));
    return imgSize;
}
CGSize CGSizeMin(CGSize size1, CGSize size2)
{
    return CGSizeLess(size1, size2) ? size1 : size2;
}
CGSize CGSizeAdd(CGSize size, CGFloat w, CGFloat h)
{
    CGSize s = CGSizeZero;
    s.height=h+size.height;
    s.width=w+size.width;
    return s;
}

CGSize CGSizeMax(CGSize size1, CGSize size2)
{
    return CGSizeLess(size1, size2) ? size2 : size1;
}
CGFloat CGRectH(CGRect rect)
{
    return rect.size.height;
}
CGFloat CGRectW(CGRect rect)
{
    return rect.size.width;
}
CGRect CGRectInsetBy(CGRect rect, CGFloat value)
{
    return CGRectInset(rect, value, value);
}

CGRect CGRectMin(CGRect r, CGRect r2)
{
    return CGSizeLess(r.size, r2.size) ? r : r2;
}
CGRect CGRectMax(CGRect r, CGRect r2)
{
    return CGSizeGreater(r.size, r2.size) ? r : r2;
}
CGFloat CGRectRatio(CGRect rect)
{
    return CGSizeRatioOf(rect.size);
}


CGSize CGSizeMakeAtLeast(CGSize size1, CGSize size2)
{
    CGSize size = CGSizeZero;
    size.width = MAX(size1.width, size2.width);
    size.height = MAX(size1.height, size2.height);
    return size;
}

CGSize CGSizeMakeAtMost(CGSize size1, CGSize size2)
{
    CGSize size = CGSizeZero;
    size.width = MIN(size1.width, size2.width);
    size.height = MIN(size1.height, size2.height);
    return size;
}



NSString *NSStringFromCGScale(CGScale r)
{
    return [NSString stringWithFormat:@"%2.2fx {%2.2f ✕ %2.2f} [Ratio: %2.2f] [Matching: %2.2f]", r.scale, r.width, r.height, r.sizes.first.ratio, r.equalScale];
}
CGScale CGScaleMin(CGScale scale)
{
    CGScale s = scale;
    s.scale = MIN(s.width, s.height);
    s.width = s.scale;
    s.height = s.scale;
    return CGScaleMakeScale(s);
    
}
CGScale CGScaleMax(CGScale scale)
{
    CGScale s = scale;
    s.scale = MAX(s.width, s.height);
    s.width = s.scale;
    s.height = s.scale;
    return CGScaleMakeScale(s);
    
}
CGScale CGScaleScale(CGScale value, CGScale scale)
{
    CGScale v = CGScaleEqual;
    value = CGScaleMakeScale(value);
    v.width = value.width*scale.width;
    v.height = value.height*scale.height;
    
    v = CGScaleMakeScale(v);
    v.scale = value.scale*scale.scale;
    return v;
}
CGScale CGScaleOfRectsMax(CGRect rect, CGRect rect2)
{
    return CGScaleMax(CGScaleOfSizes(rect.size, rect2.size));
    
}
CGScale CGScaleOfRectsMin(CGRect rect, CGRect rect2)
{
    return CGScaleMin(CGScaleOfSizes(rect.size, rect2.size));
    
}
CGScale CGScaleOfRects(CGRect rect, CGRect rect2)
{
    return CGScaleOfSizes(rect.size, rect2.size);
}
CGScale CGScaleOfViews(UIView *view, UIView *view2)
{
    return CGScaleOfSizes(view.frame.size, view2.frame.size);
}
CGScale CGScaleOfSizes(CGSize size1, CGSize size2)
{
    CGScale r = CGScaleEqual;
    r.width = size1.width/size2.width;
    r.height = size1.height/size2.height;
    r.sizes = CGSizesMake(size1, size2);
    r.scale = r.type == MysticSizeTypeWidth ? r.width : r.height;
    r.inverse = 1/r.scale;
    r.equalScale = CGSizeLess(size1, size2) ? r.inverse : r.scale;
    r.size = (CGSize){r.width,r.height};
    r.inverseSize = (CGSize){1/r.width,1/r.height};
    r.equalSize = (CGSize){r.equalScale,r.equalScale};
    
    return CGScaleMakeScale(r);
}
BOOL CGScaleEqualToScale(CGScale scale, CGScale scale2)
{
    return scale.width == scale2.width
    && scale.height == scale2.height
    && scale.scale == scale2.scale;
}

BOOL CGScaleIsUnknown(CGScale scale)
{
    return CGScaleEqualToScale(scale, CGScaleUnknown);
}

BOOL CGScaleIsZero(CGScale scale)
{
    return CGScaleEqualToScale(scale, CGScaleZero);
}
CGScale CGScaleInverseSize(CGSize size)
{
    return CGScaleInverse(CGScaleWithSize(size));
}
CGScale CGScaleInverse(CGScale scale)
{
    CGScale s = scale;
    s.inverse = scale.scale;
    s.scale = scale.inverse;
    s.size = scale.inverseSize;
    s.inverseSize = scale.size;
    s.width = scale.inverseSize.width;
    s.height = scale.inverseSize.height;
    s.equalScale = scale.equalScale == scale.inverse ? scale.scale : scale.inverse;
    s.equalSize = (CGSize){s.equalScale, s.equalScale};
    return CGScaleMakeScale(s);
}
CGScale CGScaleMakeScale(CGScale scale)
{
    CGScale s = scale;
    s.scale = s.width < 0 || s.height < 0 ? MIN(s.width, s.height) : s.width > s.height ? s.width : s.height;
    
    s.size.width = s.width;
    s.size.height = s.height;
    s.inverse = 1/s.scale;
    s.inverseSize = (CGSize){1/s.width,1/s.height};
    if(s.width > s.height)
    {
        s.ratio = s.height/s.width;
        s.ratioType = MysticSizeTypeWidth;
    }
    else
    {
        s.ratio = s.width/s.height;
        s.ratioType = MysticSizeTypeHeight;
    }
    s.x = s.width;
    s.y = s.height;
    s.min = MIN(s.width, s.height);
    s.max = MAX(s.width, s.height);

    s.equalScale = s.scale;
    s.equalSize = (CGSize){s.scale, s.scale};
    
    return s;
}

CGScale CGScaleWith(CGFloat scale)
{
    CGScale s = CGScaleZero;
    s.width = scale;
    s.height = scale;
    s.scale = scale;
    s.inverse = 1/scale;
    s.inverseSize = (CGSize){1/s.width, 1/s.height};
    return CGScaleMakeScale(s);
}

CGScale CGScaleWithSize(CGSize scaleSize)
{
    CGScale s = CGScaleZero;
    s.width = scaleSize.width;
    s.height = scaleSize.height;
    return CGScaleMakeScale(s);
    
}

CGScale CGScaleFromTransform(CGAffineTransform transform)
{
    return CGScaleWithSize((CGSize){transform.a, transform.d});
}

NSString * MysticCollectionRangeToString(MysticCollectionRange range)
{
    if(MysticCollectionRangeIsUnknown(range)) return @"MysticCollectionRange: unknown";
    if(MysticCollectionRangeIsZero(range)) return @"MysticCollectionRange: zero";
    
    return [NSString stringWithFormat:@"MysticCollectionRange: {%d, %d} -> {%d, %d} = %d items", (int)range.firstSection, (int)range.firstItem, (int)range.lastSection, (int)range.lastItem, (int)range.count];
}

MysticCollectionRange MysticCollectionRangeMakeWithIndexPaths(NSArray *indexPaths)
{
    MysticCollectionRange collectionRange = indexPaths ? MysticCollectionRangeZero : MysticCollectionRangeUnknown;
    if(indexPaths.count)
    {
        NSIndexPath *firstIndexPath = [indexPaths objectAtIndex:0];
        NSIndexPath *lastIndexPath = [indexPaths lastObject];
        
        collectionRange = (MysticCollectionRange){firstIndexPath.section, firstIndexPath.item, lastIndexPath.section, lastIndexPath.item, indexPaths.count};
    }
    return collectionRange;
}

MysticCollectionRange MysticCollectionRangeMakeWithCollectionView(UICollectionView *collectionView)
{
    return MysticCollectionRangeMakeWithIndexPaths(collectionView.indexPathsForVisibleItems);
}

BOOL MysticCollectionRangeEqual(MysticCollectionRange range, MysticCollectionRange range2)
{
    if(range.firstSection != range2.firstSection
       || range.firstItem != range2.firstItem
       || range.lastSection != range2.lastSection
       || range.lastItem != range2.lastItem
       || range.count != range2.count)
    {
        return NO;
    }
    return YES;
}
BOOL MysticCollectionRangeIsZero(MysticCollectionRange range)
{
    return MysticCollectionRangeEqual(range, MysticCollectionRangeZero);
}
BOOL MysticCollectionRangeIsUnknown(MysticCollectionRange range)
{
    return MysticCollectionRangeEqual(range, MysticCollectionRangeUnknown);
}
CGSize CGSizeSquareHeight(CGSize size)
{
    size.width = size.height;
    return size;
}
CGSize CGSizeSquareWidth(CGSize size)
{
    size.height = size.width;
    return size;
}
CGSize CGSizeSquareSmall(CGSize size)
{
    
    return size.height < size.width ? CGSizeSquareHeight(size) : CGSizeSquareWidth(size);
}
CGSize CGSizeSquare(CGSize size)
{
    return size.height > size.width ? CGSizeSquareHeight(size) : CGSizeSquareWidth(size);
    
}
CGSize CGSizeSquareBig(CGSize size)
{
    
    return size.height > size.width ? CGSizeSquareHeight(size) : CGSizeSquareWidth(size);
}

NSString *LayerPanelState(MysticLayerPanelState state)
{
    switch (state) {
        case MysticLayerPanelStateOpening: return @"MysticLayerPanelStateOpening";
            
        case MysticLayerPanelStateOpen: return @"MysticLayerPanelStateOpen";
            
        case MysticLayerPanelStateClosed: return @"MysticLayerPanelStateClosed";
            
        case MysticLayerPanelStateHidden: return @"MysticLayerPanelStateHidden";
            
        case MysticLayerPanelStateInit: return @"MysticLayerPanelStateInit";
        case MysticLayerPanelStateUnInit: return @"MysticLayerPanelStateUnInit";
        default: break;
    }
    return @"MysticLayerPanelStateUnknown";
    
}
MysticTextAlignment textAlignment(NSInteger a)
{
    switch (a) {
        case NSTextAlignmentCenter:
            return MysticTextAlignmentCenter;
        case NSTextAlignmentLeft :
            return MysticTextAlignmentLeft;
        case NSTextAlignmentRight:
            return MysticTextAlignmentRight;
            
        case NSTextAlignmentJustified:
            return MysticTextAlignmentJustified;
            
        default: break;
    }
    return (MysticTextAlignment)a;
}
BOOL isValidAlignment(NSInteger a)
{
    BOOL isAlignment = NO;
    switch (a) {
        case MysticTextAlignmentCenter:
        case NSTextAlignmentCenter:
            isAlignment = YES;
            break;
        case MysticTextAlignmentLeft:
        case NSTextAlignmentLeft:
            isAlignment = YES;
            break;
        case MysticTextAlignmentRight:
        case NSTextAlignmentRight:
            isAlignment = YES;
            break;
        case MysticTextAlignmentJustified:
        case NSTextAlignmentJustified:
            isAlignment = YES;
            break;
//        case NSTextAlignmentNatural:
//            isAlignment = YES;
//            break;
        default:
            break;
    }
    return isAlignment;
}
NSString * textAlignmentString(NSInteger a)
{
    switch (a) {
        case MysticTextAlignmentCenter:
        case NSTextAlignmentCenter: return @"center";
        case MysticTextAlignmentLeft:
        case NSTextAlignmentLeft : return @"left";
        case MysticTextAlignmentRight:
        case NSTextAlignmentRight: return @"right";
            
        case MysticTextAlignmentJustified:
        case NSTextAlignmentJustified:
            
            return @"justified";
            
        case MysticTextAlignmentFill: return @"fill";
            
        case MysticTextAlignmentJustifiedRight: return @"right justified";
            
            
        default: break;
    }
    return [NSString stringWithFormat:@"unknown (%d)", (int)a];
}

NSTextAlignment textAlignmentValue(NSInteger a)
{
    switch (a) {
        case MysticTextAlignmentCenter:
            return NSTextAlignmentCenter;
        case  MysticTextAlignmentLeft:
            return NSTextAlignmentLeft;
        case MysticTextAlignmentRight:
            return NSTextAlignmentRight;
        case MysticTextAlignmentJustified:
            return NSTextAlignmentJustified;
            
        default:
            
            break;
    }
    return a;
}

UIFont *MysticFontBold(UIFont *font)
{
    //    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    //    NSLog(@"plain font: %@", font.fontName); // “HelveticaNeue”
    
    UIFont *boldFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:font.pointSize];
    return boldFont;
    
}
UIFont *MysticFontItalic(UIFont *font)
{
    UIFont *italicFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
    return italicFont;
}
UIFont *MysticFontBoldItalic(UIFont *font)
{
    UIFont *boldItalicFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:font.pointSize];
    return boldItalicFont;
}
UIFont *MysticFontRegular(UIFont *font) {    return [UIFont fontWithName:font.familyName size:font.pointSize]; }
BOOL isNotFoundOrAuto(NSInteger i) {    return i == NSNotFound || i == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX; }

NSString *sc(CGScale scale) { return scd(scale, 2); }
NSString *scs(CGScale scale)
{
    int depth = 2;
    if(CGScaleEqualToScale(scale, CGScaleEqual)) return @"CGScaleEqual";
    if(CGScaleEqualToScale(scale, CGScaleUnknown)) return @"CGScaleUnknown";
    NSString *strFormatW = scale.width == CGFLOAT_MAX ? @"MAX" : scale.width == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatH = scale.height == CGFLOAT_MAX ? @"MAX" : scale.height == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatWi = scale.inverseSize.width == CGFLOAT_MAX ? @"MAX" : scale.inverseSize.width == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatHi = scale.inverseSize.height == CGFLOAT_MAX ? @"MAX" : scale.inverseSize.height == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormat = nil;
    if(scale.width==scale.height)
    {
        strFormat = [NSString stringWithFormat:@"%%2.%df", (int)depth];
        
    }
    else
    {
        strFormat =[NSString stringWithFormat:@"%@ ✕ %@", strFormatW, strFormatH];
    }
    return [NSString stringWithFormat:strFormat, scale.scale, scale.width, scale.height, scale.inverseSize.width, scale.inverseSize.height];
}
NSString *scd(CGScale scale, int depth)
{
    if(CGScaleEqualToScale(scale, CGScaleEqual)) return @"CGScaleEqual";
    if(CGScaleEqualToScale(scale, CGScaleUnknown)) return @"CGScaleUnknown";
    NSString *strFormatW = scale.width == CGFLOAT_MAX ? @"MAX" : scale.width == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatH = scale.height == CGFLOAT_MAX ? @"MAX" : scale.height == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatWi = scale.inverseSize.width == CGFLOAT_MAX ? @"MAX" : scale.inverseSize.width == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatHi = scale.inverseSize.height == CGFLOAT_MAX ? @"MAX" : scale.inverseSize.height == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormat = [NSString stringWithFormat:@"%%2.%df |  %@ ✕ %@  (inv: %@ ✕ %@)", (int)depth, strFormatW, strFormatH, strFormatWi, strFormatHi];
    return [NSString stringWithFormat:strFormat, scale.scale, scale.width, scale.height, scale.inverseSize.width, scale.inverseSize.height];
}
NSString *subviewsShadowStr(UIView *view, NSMutableString *s, int depth)
{
    if(view.hidden) return @"";
    s = s ? s : [NSMutableString stringWithString:@""];
    [s appendFormat:@"\n%@ %@  Shadow: %2.2f", [@"\t" repeat:depth], view.class, view.layer.shadowRadius];
    for (UIView *sub in view.subviews) {
        subviewsShadowStr(sub, s, depth+1);
    }
    return s;
}
CGRect CGRectNoNaN(CGRect rect)
{
    CGRect r = rect;
    if(isnan(r.origin.x)) r.origin.x = 0;
    if(isnan(r.origin.y)) r.origin.y = 0;
    if(isnan(r.size.height)) r.size.height = isnan(r.size.width) ? r.size.width : 0;
    if(isnan(r.size.width)) r.size.width = isnan(r.size.height) ? r.size.height : 0;
    return r;
    
}
BOOL CGRectIsNaN(CGRect rect)
{
    return CGPointIsNaN(rect.origin) || CGSizeIsNaN(rect.size);
}
BOOL CGPointIsNaN(CGPoint point)
{
    return isnan(point.x) || isnan(point.y);
}
BOOL CGSizeIsNaN(CGSize size)
{
    return isnan(size.width) || isnan(size.height);
}
CGFloat radianToDegrees(CGFloat radians)
{
    return radians * (180 / M_PI);
}
CGFloat degreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees*180) / 180.0f;
}
NSString *trans(CGAffineTransform t)
{
    return transd(t, 2);
}

NSString *transd(CGAffineTransform t, int d)
{
    if(CGAffineTransformIsUnknown(t)) return @"CGAffineTransformUnknown";
    if(CGAffineTransformIsIdentity(t)) return @"CGAffineTransformIdentity";
    NSString *str0 = [@"0" repeat:d];
    if(d <= 0) return [[[[NSString stringWithFormat:[NSString format:@"[ %%1.%df, %%1.%df, %%1.%df, %%1.%df, %%1.%df, %%1.%df ]", d, d, d, d, d, d], t.a, t.b, t.c, t.d, t.tx, t.ty ] replace:[@"0." suffix:str0] with:@"0"] replace:@"0." with:@"."] remove:[@"." suffix:str0]];
    NSString *ns = nil;
    NSString *ps = nil;
    NSString *rs = nil;
    if(!isZeroOrOne(t.a) || !isZeroOrOne(t.d))
    {
        if(fabs(t.a - t.d) < 0.03) ns = [NSString format:[NSString format:@"%%1.%dfx", d], t.a];
        else ns = [NSString format:[NSString format:@"%%1.%df ✕ %%1.%dfx", d, d], t.a, t.d];
    }
    if(!isZeroOrOne(t.tx) || !isZeroOrOne(t.ty))
    {
        ps = [NSString format:[NSString format:@"%%1.%df,%%1.%df", 1, 1], t.tx, t.ty];
    }
    if(!isZeroOrOne(t.b) || !isZeroOrOne(t.c))
    {
        if(fabs(t.b + t.c) < 0.03) rs = [NSString format:[NSString format:@"%%1.%df°", d], radianToDegrees(t.b)];
        else rs = [NSString format:[NSString format:@"%%1.%df°/%%1.%df°", d, d],  radianToDegrees(t.b),  radianToDegrees(t.c)];
    }
    ns = [NSString stringWithFormat:@"%@%@%@",
          !ns ? @"" : ns,
          !ps ? @"" : ns ? [ps prefix:@"   "] : ps,
          !rs ? @"" : ns||ps ? [rs prefix:@"   "] : rs];
    
    NSString *s = [[[ns replace:[@"0." suffix:str0] with:@"0"] replace:@"0." with:@"."] remove:[@"." suffix:str0]];
    return s.length ? s : NSStringFromCGAffineTransform(t);
}
BOOL CGAffineTransformIsUnknown(CGAffineTransform transform)
{
    return CGAffineTransformEqualToTransform(transform, CGAffineTransformUnknown);
}
BOOL CGAffineTransformIsIdentityOrUnknown(CGAffineTransform transform)
{
    return CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity) || CGAffineTransformEqualToTransform(transform, CGAffineTransformUnknown);
}
BOOL CGAffineTransformEqualsIdentity(CGAffineTransform transform)
{
    return CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity);
}

BOOL CGAffineTransformHasRotation(CGAffineTransform transform)
{
    return CGAffineTransformIsIdentityOrUnknown(transform) ? NO : !isZeroOrOne(transform.b) || !isZeroOrOne(transform.c);
}
BOOL CGAffineTransformHasTranslate(CGAffineTransform transform)
{
    return CGAffineTransformIsIdentityOrUnknown(transform) ? NO : transform.tx!=0 || transform.ty!=0;
}
BOOL CGAffineTransformHasScale(CGAffineTransform transform)
{
    return CGAffineTransformIsIdentityOrUnknown(transform) ? NO : !isZeroOrOne(transform.a) || !isZeroOrOne(transform.d);
}

CGAffineTransform CGAffineTransformConcatRotate(CGAffineTransform transform, CGAffineTransform rotate)
{
    CGAffineTransform t = transform;
    t.b = rotate.b;
    t.c = rotate.c;
    return t;
}
CGAffineTransform CGAffineTransformConcatScale(CGAffineTransform transform, CGAffineTransform scale)
{
    CGAffineTransform t = transform;
    t.a = scale.a;
    t.d = scale.d;
    return t;
}
CGAffineTransform CGAffineTransformConcatTranslate(CGAffineTransform transform, CGAffineTransform move)
{
    CGAffineTransform t = transform;
    t.tx = move.tx;
    t.ty = move.ty;
    return t;
}
CGAffineTransform CGAffineTransformTranslateReset(CGAffineTransform transform)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    t.a = transform.a;
    t.b = transform.b;
    t.c = transform.c;
    t.d = transform.d;
    t.tx = 0;
    t.ty = 0;
    return t;
}
CGAffineTransform CGAffineTransformRotateReset(CGAffineTransform transform)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    CGFloat radians = atan2f(t.b, t.a);
//    CGFloat degrees = radians * (180 / M_PI);
    t = CGAffineTransformRotate(t, -radians);
    return t;
}
CGAffineTransform CGAffineTransformScaleReset(CGAffineTransform transform)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    t.b = transform.b;
    t.ty = transform.ty;
    t.tx = transform.tx;
    t.c = transform.c;
    t.a = 0;
    t.d = 0;
    return t;
}
CGAffineTransform CGAffineTransformRotateAdd(CGAffineTransform transform, float r)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    t.a = transform.a;
    t.b = r;
    t.c = r;
    t.d = transform.d;
    t.tx = transform.tx;
    t.ty = transform.ty;
    return t;
    
}
CGAffineTransform CGAffineTransformMove(CGAffineTransform transform, CGPoint move)
{
    CGAffineTransform t = CGAffineTransformIdentity;
    t.a = transform.a;
    t.b = transform.b;
    t.c = transform.c;
    t.d = transform.d;
    t.tx = move.x;
    t.ty = move.y;
    return t;
    
}
CGAffineTransform CGAffineTransformScaleOf(CGAffineTransform transform)
{
    CGAffineTransform i = CGAffineTransformIdentity;
    i.a = transform.a;
    i.d = transform.d;
    return i;
}
CGAffineTransform CGAffineTransformRotateOf(CGAffineTransform transform)
{
    CGAffineTransform i = CGAffineTransformIdentity;
    i.b = transform.b;
    i.c = transform.c;
    return i;
}
CGAffineTransform CGAffineTransformTranslateOf(CGAffineTransform transform)
{
    CGAffineTransform i = CGAffineTransformIdentity;
    i.tx = transform.tx;
    i.ty = transform.ty;
    return i;
}

CGAffineTransform CGAffineTransformPoint(CGAffineTransform transform, CGPoint offset)
{
    return CGAffineTransformTranslate(transform, offset.x, offset.y);
}

CGAffineTransform CGAffineTransformScaleSize(CGAffineTransform transform, CGSize size)
{
    return CGAffineTransformScale(transform, size.width, size.height);
}
CGAffineTransform CGScaleTransformMake(CGScale scale)
{
    return CGAffineTransformMakeScale(scale.width, scale.height);
}
CGAffineTransform CGScaleInverseTransform(CGAffineTransform transform, CGScale scale)
{
    return CGScaleIsEqual(scale) ? transform : CGAffineTransformScale(transform, scale.inverse, scale.inverse);
}
CGAffineTransform CGScaleTransform(CGAffineTransform transform, CGScale scale)
{
    return CGScaleIsEqual(scale) ? transform : CGAffineTransformScale(transform, scale.width, scale.height);
}
CGAffineTransform CGScaleEqualTransform(CGAffineTransform transform, CGScale scale)
{
    return CGScaleIsEqual(scale) ? transform : CGAffineTransformScale(transform, scale.equalSize.width, scale.equalSize.height);
}
CGAffineTransform CGTransformSize(CGSize size)
{
    return CGAffineTransformMakeScale(size.width, size.height);
}
BOOL isZeroOrNotFound(NSInteger n)
{
    return n == 0 || n == NSNotFound;
}
BOOL isZeroOrOne(float n)
{
    return n == 0 || n == 1;
}
BOOL CGSizeEqual(CGSize s, CGSize s2)
{
    return CGSizeEqualToSize(s, s2);
}
NSArray *rw(CGRectMinMaxWithin m)
{
    return @[@"original", s(m.frameOriginal.size),
             @"min", [[s(m.frameMin.size) suffix:@"  "] append:b(m.min)],
             @"max", [[s(m.frameMax.size) suffix:@"  "] append:b(m.max)],
             @" ",
             @"frame", [[s(m.frame.size) suffix:@"  "] append:b(m.changed)],];
}

NSString *FLogStr(CGRect frame)
{
    if( CGRectEqualToRect(frame, CGRectUnknown)) return @"CGRectUnknown";
    if( CGRectEqualToRect(frame, CGRectZero)) return @"CGRectZero";
    if( CGRectEqualToRect(frame, CGRectInfinite)) return @"CGRectInfinite";
    return [[p(frame.origin) remove:@".0"] stringByAppendingFormat:@"  %@", SLogStr(frame.size)];
}
NSString *fs(CGRect frame)
{
    return SLogStr(frame.size);
}
NSString *fspad(CGRect frame)
{
    return [SLogStr(frame.size) pad:15];
}
NSString *fp(CGRect frame)
{
    return PLogStr(frame.origin);
}
NSString *f(CGRect frame)
{
    return FLogStr(frame);
}
NSString *s(CGSize size)
{
    return SLogStr(size);
}
NSString *p(CGPoint p)
{
    return PLogStr(p);
}
NSString *fpad(CGRect frame)
{
    return fpadd(frame,(NSUInteger)27);
}
NSString *fpadd(CGRect frame, NSUInteger l)
{
    if( CGRectEqualToRect(frame, CGRectUnknown)) return [@"CGRectUnknown" pad:l];
    if( CGRectEqualToRect(frame, CGRectZero)) return [@"CGRectZero"  pad:l];
    if( CGRectEqualToRect(frame, CGRectInfinite)) return [@"CGRectInfinite" pad:l];
    NSString *p = [[PLogStr(frame.origin) remove:@".0"] replace:@"-0,0" with:@"0,0"];
    NSString *s = [SLogStr(frame.size) remove:@".0"];
    NSUInteger ps = p.length+s.length;
    int r = MAX(1,ps >= l ? 4 : l-ps) + ([p hasPrefix:@"-"] ? 1 : 0);
    return [NSString stringWithFormat:@"%@%@%@", p, [@" " repeat:r], s];
}

NSString *FLogStrd(CGRect frame, int depth)
{
    NSString *strFormat = [NSString stringWithFormat:@"%%2.%df, %%2.%df | %%2.%df ✕ %%2.%df", depth, depth, depth, depth];
    frame = [MysticUser getf:Mk_SCALE] > 0 ? CGRectScale(frame, [MysticUser getf:Mk_SCALE]) : frame;
    return CGRectEqualToRect(frame, CGRectInfinite) ? @"CGRectInfinite" : [NSString stringWithFormat:strFormat, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
}
UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets ins, UIEdgeInsets add)
{
    UIEdgeInsets i = UIEdgeInsetsCopy(ins);
    i.top+=add.top;
    i.bottom+=add.bottom;
    i.left+=add.left;
    i.right+=add.right;
    return i;
}
UIEdgeInsets UIEdgeInsetsMinus(UIEdgeInsets ins, UIEdgeInsets add)
{
    UIEdgeInsets i = UIEdgeInsetsCopy(ins);
    i.top-=add.top;
    i.bottom-=add.bottom;
    i.left-=add.left;
    i.right-=add.right;
    return i;
}
UIEdgeInsets UIEdgeInsetsTop(UIEdgeInsets ins, CGFloat top)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.top = top;
    return insets;
}
UIEdgeInsets UIEdgeInsetsBottom(UIEdgeInsets ins, CGFloat bottom)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.bottom = bottom;
    return insets;
}
UIEdgeInsets UIEdgeInsetsLeft(UIEdgeInsets ins, CGFloat left)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.left = left;
    return insets;
}
UIEdgeInsets UIEdgeInsetsRight(UIEdgeInsets ins, CGFloat right)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.right = right;
    return insets;
}
UIEdgeInsets UIEdgeInsetsLeftRight(UIEdgeInsets ins, CGFloat left, CGFloat right)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.left = left;
    insets.right = right;
    return insets;
}
UIEdgeInsets UIEdgeInsetsTopBottom(UIEdgeInsets ins, CGFloat top, CGFloat bottom)
{
    UIEdgeInsets insets = UIEdgeInsetsCopy(ins);
    insets.bottom = bottom;
    insets.top = top;
    return insets;
}
UIEdgeInsets UIEdgeInsetsScaleBy(UIEdgeInsets ins, CGFloat scale)
{
    if(scale == 1) return ins;
    CGScale s = CGScaleEqual;
    s.scale = scale;
    s.width = scale;
    s.height = scale;
    return UIEdgeInsetsScale(ins, s);
}
NSString *ins(UIEdgeInsets insets)
{
    insets = [MysticUser getf:Mk_SCALE] > 0 ? UIEdgeInsetsScaleBy(insets, [MysticUser getf:Mk_SCALE]) : insets;
    return [NSString stringWithFormat:@"%1.1f, %@, %1.1f, %@", insets.top, ColorWrapf(@"%1.1f", insets.left, COLOR_GREEN), insets.bottom, ColorWrapf(@"%1.1f", insets.right, COLOR_GREEN)];
}
NSString *EdgeLogStr(UIEdgeInsets insets)
{
    insets = [MysticUser getf:Mk_SCALE] > 0 ? UIEdgeInsetsScaleBy(insets, [MysticUser getf:Mk_SCALE]) : insets;
    return [NSString stringWithFormat:@"top: %2.2f  |  left: %2.2f  |  bottom: %2.2f  |  right: %2.2f", insets.top, insets.left, insets.bottom, insets.right];
}

NSString *SLogStr(CGSize size)
{
    return SLogStrd(size, 1);
}

NSString *SLogStrd(CGSize size, int depth)
{
    if(CGSizeIsUnknown(size)) return @"CGSizeUnknown";
    NSString *strFormatW = size.width == CGFLOAT_MAX ? @"MAX" : size.width == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    NSString *strFormatH = size.height == CGFLOAT_MAX ? @"MAX" : size.height == CGFLOAT_MIN ? @"MIN" : [NSString stringWithFormat:@"%%2.%df", depth];
    size = [MysticUser getf:Mk_SCALE] > 0 ? CGSizeScale(size, [MysticUser getf:Mk_SCALE]) : size;
    NSString *strFormat = [NSString stringWithFormat:@"%@x%@", strFormatW, strFormatH];
    strFormat = [NSString stringWithFormat:strFormat,  size.width, size.height];
    return depth <= 0 ? strFormat : [strFormat stringByReplacingOccurrencesOfString:[NSString format:@".%@", [@"0" repeat:depth]] withString:@""];
}

NSString *PLogStr(CGPoint origin)
{
    origin = [MysticUser getf:Mk_SCALE] > 0 ? CGPointScale(origin, [MysticUser getf:Mk_SCALE]) : origin;
    return [NSString stringWithFormat:@"%2.1f,%2.1f",  origin.x, origin.y];
}

NSString *PLogStrd(CGPoint origin, int depth)
{
    NSString *strFormat = [NSString stringWithFormat:@"%%2.%df,%%2.%df", depth, depth];
    origin = [MysticUser getf:Mk_SCALE] > 0 ? CGPointScale(origin, [MysticUser getf:Mk_SCALE]) : origin;
    return [NSString stringWithFormat:strFormat,  origin.x, origin.y];
}

NSString *ImageOrientationToString (UIImageOrientation imageOrientation)
{
    NSString *orientation;
    switch (imageOrientation) {
            
        case UIImageOrientationUp:
            orientation = @"up";
            break;
        case UIImageOrientationLeft:
            orientation = @"left";
            break;
        case UIImageOrientationRight:
            orientation = @"right";
            break;
        case UIImageOrientationDown:
            orientation = @"down";
            break;
        case UIImageOrientationDownMirrored:
            orientation = @"down-mirrored";
            break;
        case UIImageOrientationUpMirrored:
            orientation = @"up-mirrored";
            break;
        case UIImageOrientationLeftMirrored:
            orientation = @"left-mirrored";
            break;
        case UIImageOrientationRightMirrored:
            orientation = @"right-mirrored";
            break;
            
        default:
            orientation = @"unknown";
            break;
    }
    return orientation;
}

NSString * ILogStr(UIImage *img)
{
    if(!img)
    {
        return [NSString stringWithFormat:@"No Image"];
    }
    if(![img isKindOfClass:[UIImage class]])
    {
        return [NSString stringWithFormat:@"ILogStr: Obj is not an image: (%@) %@", [img class], img];
    }
    NSString *cstr = NSStringFromClass([img class]);
    if([cstr isEqualToString:@"UIImage"])
    {
        cstr = @"";
    }
    else
    {
        cstr = [cstr stringByAppendingString:@": "];
    }
    NSString *scaledSize = img.scale > 1 ? [NSString stringWithFormat:@"  (@%1.0fx %2.1zux%2.1zu px) ",  img.scale, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage)] : @"";
    return [NSString stringWithFormat:@"<%@%p>   %2.0f ✕ %2.0f%@%@",cstr, img, img.size.width, img.size.height, scaledSize, img.imageOrientation == UIImageOrientationUp ? @"" : [@"  |  Orientation: " stringByAppendingString:ImageOrientationToString(img.imageOrientation)]];
}

void ILog(NSString *name, UIImage *img)
{
    if(!img)
    {
        DLog(@"%@ | No Image Found", name);
        return;
    }
    DLog(@"%@ | %@", name, ILogStr(img));
}
NSString * NSStringFromMysticDirection(MysticDirection d)
{
    NSMutableArray *strs = [NSMutableArray array];
    if(d & MysticDirectionUp)
    {
        [strs addObject:@"Up"];
    }
    if(d & MysticDirectionLeft)
    {
        [strs addObject:@"Left"];
    }
    
    
    if(d & MysticDirectionDown)
    {
        [strs addObject:@"Down"];
        
    }
    if(d & MysticDirectionRight)
    {
        [strs addObject:@"Right"];
        
    }
    
    if(d & MysticDirectionNone)
    {
        [strs addObject:@"None"];
    }
    if(d & MysticDirectionUnknown)
    {
        [strs addObject:@"Unknown"];
        
    }
    
    return [[strs componentsJoinedByString:@"|"] stringByPaddingToLength:31 withString:@" " startingAtIndex:0];
}
BOOL MysticDirectionIsHorizontal(MysticDirection d, BOOL ignoreDiag)
{
    if((d & MysticDirectionRight || d & MysticDirectionLeft) && (ignoreDiag || (!ignoreDiag && (d & MysticDirectionUp || d & MysticDirectionDown))))
    {
        return YES;
    }
    return NO;
}
BOOL MysticDirectionIsVertical(MysticDirection d, BOOL ignoreDiag)
{
    if((d & MysticDirectionUp || d & MysticDirectionDown) && (ignoreDiag || (!ignoreDiag && (d & MysticDirectionLeft || d & MysticDirectionRight))))
    {
        return YES;
    }
    return NO;
}
BOOL MysticDirectionIsDiagnal(MysticDirection d)
{
    if(d & MysticDirectionLeft && (d & MysticDirectionUp || d & MysticDirectionDown)) return YES;
    if(d & MysticDirectionRight && (d & MysticDirectionUp || d & MysticDirectionDown)) return YES;
    return NO;
}
MysticDirection MysticDirectionFrom(CGPoint p1, CGPoint p2)
{
    return MysticDirectionFromThreshold(p1, p2, 0.4f);
}
MysticDirection MysticDirectionFromThreshold(CGPoint p1, CGPoint p2, CGFloat threshold)
{
    CGPoint d = CGPointDiff(p1, p2);
    return MysticDirectionOfThreshold(d, threshold);
}
MysticDirection MysticDirectionOf(CGPoint p1)
{
    return MysticDirectionOfThreshold(p1, 0.4f);
}

MysticDirection MysticDirectionOfThreshold(CGPoint p1, CGFloat threshold)
{
    MysticDirection d = MysticDirectionNone;
    CGPoint p1a = p1;
    p1a.x = ABS(p1.x);
    p1a.y = ABS(p1.y);
    if(p1a.x > threshold)
    {
        d |= p1.x>0 ? MysticDirectionRight : MysticDirectionLeft;
        d = d & ~MysticDirectionNone;
    }
    if(p1a.y > threshold)
    {
        d |= p1.y<0 ? MysticDirectionUp : MysticDirectionDown;
        d = d & ~MysticDirectionNone;
    }
    return d;
}
MysticKeyboardInfo MysticKeyboardNotification(NSNotification *notification)
{
    CGRect f = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect f2 = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval t = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve c = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions o = UIViewAnimationOptionCurveLinear;
    switch (c) {
        case UIViewAnimationCurveEaseIn: o = UIViewAnimationOptionCurveEaseIn; break;
        case UIViewAnimationCurveEaseInOut: o = UIViewAnimationOptionCurveEaseInOut; break;
        case UIViewAnimationCurveEaseOut: o = UIViewAnimationOptionCurveEaseOut; break;
        case UIViewAnimationCurveLinear: o = UIViewAnimationOptionCurveLinear; break;
            
        default: break;
    }
    return (MysticKeyboardInfo){f,f2,t,c,o};
}
CGRect CGRectContainer(CGRect r)
{
    if(CGPointIsZero(r.origin)) return r;
    CGRect r2 = CGRectz(r);
    r2.size.height+=fabs(r.origin.y)*2;
    r2.size.width+=fabs(r.origin.x)*2;
    return r2;
    
}
CGRect CGRectPoint(CGPoint p)
{
    CGRect r = CGRectZero;
    r.origin = p;
    return r;
}
CGRect CGRectPointAddY(CGPoint p, CGFloat y)
{
    CGRect r = CGRectZero;
    r.origin = p;
    r.origin.y += y;
    return r;
}
CGRect CGRectPointAddX(CGPoint p, CGFloat x)
{
    CGRect r = CGRectZero;
    r.origin = p;
    r.origin.x += x;
    return r;
}
CGRect CGRectPointAddXY(CGPoint p, CGFloat x, CGFloat y)
{
    CGRect r = CGRectZero;
    r.origin = p;
    r.origin.x += x;
    r.origin.y += y;
    return r;
}
CGRectMinMaxWithin CGRectWithin(CGRect r, CGRect min, CGRect max)
{
    BOOL s = CGRectLess(r, min);
    BOOL g = CGRectGreater(r, max);
    return (CGRectMinMaxWithin){s ? CGRectFit(r, min) : g ? CGRectFit(r, max) : r, s,g, min,max, r, s || g};
}
CGRect CGRectWithCenter(CGRect rect, CGPoint c)
{
    CGRect r = rect;
    r.origin.x = c.x - r.size.width/2;
    r.origin.y = c.y - r.size.height/2;
    return r;
}
CGRect CGRectWithPointAndSize(CGPoint p, CGSize s)
{
    CGRect newRect = CGRectZero;
    newRect.origin = p;
    newRect.size = s;
    return newRect;
}
UIEdgeInsets UIEdgeInsetsCopy(UIEdgeInsets insets)
{
    return UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}
UIEdgeInsets UIEdgeInsetsMakeFrom(CGFloat p)
{
    UIEdgeInsets i = UIEdgeInsetsMake(p,p,p,p);
    return i;
}
CGFloat CGPointDistanceFrom(CGPoint point1, CGPoint point2)
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return (CGFloat)sqrt((xDist * xDist) + (yDist * yDist));
}
CGPoint CGPointOfNormal(CGPoint n, CGSize s)
{
    return (CGPoint){n.x*s.width,n.y*s.height};
}
CGPoint CGPointNormal(CGPoint p, CGRect rect)
{
    return (CGPoint){p.x/rect.size.width,p.y/rect.size.height};
}
CGPoint CGPointInverse(CGPoint p)
{
    CGPoint p2 = CGPointZero;
    p2.x = -p.x;
    p2.y = -p.y;
    return p2;
}
CGRect CGPointDiffRect(CGPoint c1, CGPoint c2)
{
    CGRect z = CGRectZero;

    CGPoint diff = CGPointDiffABS(c1,c2);
    z.origin.x = MIN(c1.x,c2.x);
    z.origin.y = MIN(c1.y,c2.y);
    z.size.width = diff.x;
    z.size.height = diff.y;
    return z;
}
CGPoint CGPointDiff(CGPoint point1, CGPoint point2)
{
    CGFloat xDist = (point1.x - point2.x);
    CGFloat yDist = (point1.y - point2.y);
    return CGPointMake(xDist, yDist);
}

CGPoint CGPointDiffABS(CGPoint point1, CGPoint point2)
{
    CGPoint p = CGPointDiff(point1, point2);
    p.x = ABS(p.x);
    p.y = ABS(p.y);
    return p;
}
CGPoint CGPointXY(CGPoint p, CGFloat x, CGFloat y)
{
    return (CGPoint){x, y};
}
CGPoint CGPointX(CGPoint p, CGFloat x)
{
    return (CGPoint){x, p.y};
}
CGPoint CGPointY(CGPoint p, CGFloat y)
{
    return (CGPoint){p.x, y};
}
CGPoint CGPointAdd(CGPoint point1, CGPoint point2)
{
    CGFloat xDist = (point1.x + point2.x);
    CGFloat yDist = (point1.y + point2.y);
    return CGPointMake(xDist, yDist);
}
CGPoint CGPointAddY(CGPoint point1, CGFloat y)
{
    return CGPointMake(point1.x, point1.y + y);
}
CGPoint CGPointAddX(CGPoint point1, CGFloat x)
{
    return CGPointMake(point1.x+x, point1.y);
}
CGPoint CGPointAddXY(CGPoint point1, CGFloat x, CGFloat y)
{
    return CGPointMake(point1.x+x, point1.y+y);
}
CGRect CGRectInsets(CGRect rect, CGFloat i)
{
    return CGRectInset(rect, i, i);
}
CGRect CGRectSubtractXY(CGRect rect, CGFloat x, CGFloat y)
{
    CGRect n = rect;
    n.origin.x -= x;
    n.origin.y -= y;
    return n;
}
CGRect CGRectAddX(CGRect rect, CGFloat x)
{
    return CGRectAddXY(rect, x, 0);
}
CGRect CGRectAddY(CGRect rect, CGFloat y)
{
    return CGRectAddXY(rect, 0, y);
}
CGRect CGRectAddXY(CGRect rect, CGFloat x, CGFloat y)
{
    CGRect n = rect;
    n.origin.x += x;
    n.origin.y += y;
    return n;
}


CGRect CGRectz(CGRect rect)
{
    CGRect n = rect;
    n.origin = CGPointZero;
    return n;
}
CGRect CGRectXY(CGRect rect, CGFloat x, CGFloat y)
{
    CGRect n = rect;
    n.origin.x = x;
    n.origin.y = y;
    return n;
}
CGRect CGRectX(CGRect rect, CGFloat x)
{
    CGRect n = rect;
    n.origin.x = x;
    return n;
}
CGRect CGRectY(CGRect rect, CGFloat y)
{
    CGRect n = rect;
    n.origin.y = y;
    return n;
}
CGRect CGRectXYH(CGRect rect, CGFloat x, CGFloat y, CGFloat h)
{
    CGRect n = rect;
    n.origin.y = y;
    n.origin.x = x;
    n.size.height = h;
    return n;
}
CGRect CGRectXYWH(CGRect rect, CGFloat x, CGFloat y, CGFloat w, CGFloat h)
{
    CGRect n = rect;
    n.origin.y = y;
    n.origin.x = x;
    n.size.height = h;
    n.size.width = w;
    return n;
}
CGRect CGRectXWH(CGRect rect, CGFloat x, CGFloat w, CGFloat h)
{
    CGRect n = rect;
    n.origin.x = x;
    n.size.height = h;
    n.size.width = w;
    return n;
}
CGRect CGRectXW(CGRect rect, CGFloat x, CGFloat w)
{
    CGRect n = rect;
    n.origin.x = x;
    n.size.width = w;
    return n;
}
CGRect CGRectXH(CGRect rect, CGFloat x, CGFloat h)
{
    CGRect n = rect;
    n.origin.x = x;
    n.size.height = h;
    return n;
}
CGRect CGRectWH(CGRect rect, CGFloat w, CGFloat h)
{
    CGRect n = rect;
    n.size.height = h;
    n.size.width = w;
    return n;
}
CGRect CGRectYWH(CGRect rect, CGFloat y, CGFloat w, CGFloat h)
{
    CGRect n = rect;
    n.origin.y = y;
    n.size.height = h;
    n.size.width = w;
    return n;
}
CGRect CGRectYW(CGRect rect, CGFloat y, CGFloat w)
{
    CGRect n = rect;
    n.origin.y = y;
    n.size.width = w;
    return n;
}
CGRect CGRectYH(CGRect rect, CGFloat y, CGFloat h)
{
    CGRect n = rect;
    n.origin.y = y;
    n.size.height = h;
    return n;
}
CGRect CGRectXYW(CGRect rect, CGFloat x, CGFloat y, CGFloat w)
{
    CGRect n = rect;
    n.origin.y = y;
    n.origin.x = x;
    n.size.width = w;
    return n;
}

CGRect CGRectAddXYWH(CGRect rect, CGFloat x, CGFloat y, CGFloat w, CGFloat h)
{
    CGRect n = rect;
    n.origin.y += y;
    n.origin.x += x;
    n.size.height += h;
    n.size.width += w;
    return n;
}
CGRect CGRectAddXWH(CGRect rect, CGFloat x, CGFloat w, CGFloat h)
{
    return CGRectAddXYWH(rect, x, 0, w, h);
}
CGRect CGRectAddXW(CGRect rect, CGFloat x, CGFloat w)
{
    return CGRectAddXYWH(rect, x, 0, w, 0);
}
CGRect CGRectAddXH(CGRect rect, CGFloat x, CGFloat h)
{
    return CGRectAddXYWH(rect, x, 0, 0, h);
}
CGRect CGRectAddWH(CGRect rect, CGFloat w, CGFloat h)
{
    return CGRectAddXYWH(rect, 0, 0, w, h);
}
CGRect CGRectAddYWH(CGRect rect, CGFloat y, CGFloat w, CGFloat h)
{
    return CGRectAddXYWH(rect, 0, y, w, h);
}
CGRect CGRectAddYW(CGRect rect, CGFloat y, CGFloat w)
{
    return CGRectAddXYWH(rect, 0, y, w, 0);
}
CGRect CGRectAddYH(CGRect rect, CGFloat y, CGFloat h)
{
    return CGRectAddXYWH(rect, 0, y, 0, h);
}
CGRect CGRectAddXYW(CGRect rect, CGFloat x, CGFloat y, CGFloat w)
{
    return CGRectAddXYWH(rect, x, y, w, 0);
}


CGRect CGRectWidth(CGRect rect, CGFloat w)
{
    CGRect n = rect;
    n.size.width = w;
    return n;
}
CGRect CGRectHeight(CGRect rect, CGFloat h)
{
    CGRect n = rect;
    n.size.height = h;
    return n;
}

CGRect CGRectMove(CGRect rect, CGPoint offset)
{
    CGRect newRect = rect;
    newRect.origin.x += offset.x;
    newRect.origin.y += offset.y;
    return newRect;
}
CGRect CGRectWidthHeight(CGRect rect, CGFloat w, CGFloat h)
{
    CGRect r = rect;
    r.size = (CGSize){w,h};
    return r;
}
CGRect CGRectSizeXY(CGSize s, CGFloat x, CGFloat y)
{
    CGRect r = CGRectZero;
    r.size = s;
    r.origin.x = x;
    r.origin.y = y;
    return r;
}
CGRect CGRectAlignOffset(CGRect rect, CGRect bounds, MysticAlignType alignType, CGPoint offset)
{
    CGRect newRect = CGRectAlign(rect, bounds, alignType);
    newRect.origin.x += offset.x;
    newRect.origin.y += offset.y;
    return newRect;
}
CGRect CGRectMakeWithPointSize(CGPoint point, CGSize size)
{
    return CGRectMake(point.x, point.y, size.width, size.height);
}
CGRect CGRectS(CGRect r, CGSize size)
{
    CGRect newRect = r;
    newRect.size = size;
    return newRect;
}
CGRect CGRectSize(CGSize size)
{
    CGRect newRect = CGRectMake(0, 0, size.width, size.height);
    return newRect;
}
CGRect CGRectNormal(CGRect r, CGRect r1)
{
    CGRect n = CGRectMake(0,0,1,1);
    n.size = CGSizeNormal(r.size, r1.size);
    n.origin = (CGPoint){r.origin.x/r1.size.width,r.origin.y/r1.size.height};
    return n;
}
CGSize CGSizeNormal(CGSize s, CGSize rect)
{
    return (CGSize){s.width/rect.width,s.height/rect.height};
}
CGSize CGSizeFromMaxPoint(CGPoint p)
{
    return (CGSize){p.x > p.y ? p.x : 0, p.y >= p.x ? p.y : 0};
}
CGSize CGSizeWithHeight(CGSize size, CGFloat h)
{
    CGSize s = size;
    s.height = h;
    return s;
}
CGSize CGSizeWithWidth(CGSize size, CGFloat w)
{
    CGSize s = size;
    s.width = w;
    return s;
}

CGSize CGSizeIntegral(CGSize size)
{
    CGRect newRect = CGRectSize(size);
    newRect = CGRectIntegral(newRect);
    
    return newRect.size;
}

CGPoint CGPointIntegral(CGPoint point)
{
    CGRect newRect = CGRectZero;
    newRect.origin = point;
    newRect = CGRectIntegral(newRect);
    
    return newRect.origin;
}

CGRect CGRectAlign(CGRect rect, CGRect bounds, MysticAlignType alignType)
{
    CGRect newRect = rect;
    switch (alignType) {
        case MysticAlignTypeBottom:
            newRect.origin.y = bounds.size.height - rect.size.height;
            newRect.origin.x = bounds.size.width/2 - rect.size.width/2;
            break;
            
        default:
            newRect = MysticPositionRect(rect, bounds, MysticPositionFromAlignment(alignType));
            break;
    }
    return newRect;
}
NSString * MysticPositionStr(MysticPosition position)
{
    NSString *str = MysticPositionToString(position);
    return [str stringByReplacingOccurrencesOfString:@"MysticPosition" withString:@""];
}
NSString * MysticPositionToString(MysticPosition position)
{
    switch (position) {
        case MysticPositionVerticalDivisions: return @"MysticPositionVerticalDivisions";
        case MysticPositionMiddle: return @"MysticPositionMiddle";
        case MysticPositionOutside: return @"MysticPositionOutside";
        case MysticPositionInside: return @"MysticPositionInside";
            
        case MysticPositionLeftOnly: return @"MysticPositionLeftOnly";
        case MysticPositionRightOnly: return @"MysticPositionRightOnly";
        case MysticPositionTopOnly: return @"MysticPositionTopOnly";
        case MysticPositionBottomOnly: return @"MysticPositionBottomOnly";
        case MysticPositionCenterOnly: return @"MysticPositionCenterOnly";
        case MysticPositionCenterVerticalOnly: return @"MysticPositionCenterVerticalOnly";
        case MysticPositionLeft: return @"MysticPositionLeft";
        case MysticPositionRight: return @"MysticPositionRight";
        case MysticPositionTop: return @"MysticPositionTop";
        case MysticPositionThirdsHorizontal: return @"MysticPositionThirdsHorizontal";
        case MysticPositionTopRight: return @"MysticPositionTopRight";
        case MysticPositionTopLeft: return @"MysticPositionTopLeft";
        case MysticPositionHorizontalDivisions: return @"MysticPositionHorizontalDivisions";
        case MysticPositionRightTopAligned: return @"MysticPositionRightTopAligned";
        case MysticPositionRightTop: return @"MysticPositionRightTop";
        case MysticPositionRightBottomAligned: return @"MysticPositionRightBottomAligned";
        case MysticPositionRightBottom: return @"MysticPositionRightBottom";
            
        case MysticPositionLeftBottom: return @"MysticPositionLeftBottom";
        case MysticPositionLeftTop: return @"MysticPositionLeftTop";
        case MysticPositionLeftTopAligned: return @"MysticPositionLeftTopAligned";
        case MysticPositionLeftBottomAligned: return @"MysticPositionLeftBottomAligned";
        case MysticPositionBottom: return @"MysticPositionBottom";
        case MysticPositionBottomLeft: return @"MysticPositionBottomLeft";
        case MysticPositionBottomRight: return @"MysticPositionBottomRight";
        case MysticPositionCenter: return @"MysticPositionCenter";
        case MysticPositionCenterVertical: return @"MysticPositionCenterVertical";
        default: break;
    }
    return @"MysticPositionUnknown";
}
MysticPosition MysticPositionFromAlignment(MysticAlignPosition alignPos)
{
    switch (alignPos) {
        case MysticAlignPositionCenter:
            return MysticPositionCenter;
            
        case MysticAlignPositionLeft:
            return MysticPositionLeft;
            
        case MysticAlignPositionRight:
            return MysticPositionRight;
            
        case MysticAlignPositionTop:
            return MysticPositionTop;
            
        case MysticAlignPositionBottom:
            return MysticPositionBottom;
            
        case MysticAlignPositionTopLeft:
            return MysticPositionTopLeft;
            
        case MysticAlignPositionTopRight:
            return MysticPositionTopRight;
            
        case MysticAlignPositionBottomRight:
            return MysticPositionBottomRight;
            
        case MysticAlignPositionBottomLeft:
            return MysticPositionBottomLeft;
            
        default: break;
    }
    return MysticPositionUnknown;
}
CGRect MysticPositionRect(CGRect rect, CGRect bounds, MysticPosition position)
{
    return CGRectPosition(rect, bounds, position);
}
CGRect CGRectPosition(CGRect rect, CGRect bounds, MysticPosition position)
{
    return CGRectPositionOffset(rect, bounds, position, UIEdgeInsetsZero);
}
CGRect CGRectPositionOffset(CGRect rect, CGRect bounds, MysticPosition position, UIEdgeInsets inset)
{
    CGRect newrect = rect;
    bounds = UIEdgeInsetsInsetRect(bounds, inset);
    switch (position) {
        case MysticPositionTopLeft:
        {
            newrect.origin = CGPointZero;
            break;
        }
        case MysticPositionTop:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), 0);
            break;
        }
        case MysticPositionTopOnly:
        {
            newrect.origin = CGPointMake(rect.origin.x, 0);
            break;
        }
        case MysticPositionTopRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), 0);
            break;
        }
        case MysticPositionLeftTop:
        {
            newrect.origin = CGPointMake(0, (CGRectGetHeight(bounds)/4)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightTop:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/4)*1)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftTopAligned:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/3)*1)-(CGRectGetHeight(rect)/2)) ;
            break;
        }
        case MysticPositionRightTopAligned:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/3)*1)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeft:
        {
            newrect.origin = CGPointMake(0, (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionCenter:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionCenterVerticalOnly:
        {
            newrect.origin = CGPointMake(rect.origin.x, (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), (CGRectGetHeight(bounds)/2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftOnly:
        {
            newrect.origin = CGPointMake(0, rect.origin.y);
            break;
        }
        case MysticPositionCenterOnly:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), rect.origin.y);
            break;
        }
        case MysticPositionRightOnly:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), rect.origin.y);
            break;
        }
        case MysticPositionLeftBottom:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/4)*3)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightBottom:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/4)*3)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionLeftBottomAligned:
        {
            newrect.origin = CGPointMake(0, ((CGRectGetHeight(bounds)/3)*2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionRightBottomAligned:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), ((CGRectGetHeight(bounds)/3)*2)-(CGRectGetHeight(rect)/2));
            break;
        }
        case MysticPositionBottomLeft:
        {
            newrect.origin = CGPointMake(0, (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }
        case MysticPositionBottom:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds)/2)-(CGRectGetWidth(rect)/2), (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }
        case MysticPositionBottomOnly:
        {
            newrect.origin = CGPointMake(rect.origin.x, (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }
        case MysticPositionBottomRight:
        {
            newrect.origin = CGPointMake((CGRectGetWidth(bounds))-(CGRectGetWidth(rect)), (CGRectGetHeight(bounds))-(CGRectGetHeight(rect)));
            break;
        }
            
        default: break;
    }
    newrect.origin.x += bounds.origin.x;
    newrect.origin.y += bounds.origin.y;
    
    
    
    return newrect;
}
CGSize CGSizeDiffABS(CGSize s1, CGSize s2)
{
    CGRect r = CGRectDiffABS(CGRectSize(s1), CGRectSize(s2));
    return r.size;
}
CGSize CGSizeDiff(CGSize s1, CGSize s2)
{
    return (CGSize){s1.width - s2.width, s1.height-s2.height};
}

CGRect CGRectDiff(CGRect r1, CGRect r2)
{
    CGSize s1 = r1.size;
    CGSize s2 = r2.size;
    return (CGRect){r1.origin.x - r2.origin.x, r1.origin.y-r2.origin.y, s1.width - s2.width, s1.height-s2.height};
}

CGRect CGRectDiffABS(CGRect r1, CGRect r2)
{
    CGSize s1 = r1.size; CGSize s2 = r2.size;
    CGRect r = (CGRect){r1.origin.x - r2.origin.x, r1.origin.y-r2.origin.y, s1.width - s2.width, s1.height-s2.height};
    r.origin.x = ABS(r.origin.x);
    r.origin.y = ABS(r.origin.y);
    r.size.width = ABS(r.size.width);
    r.size.height = ABS(r.size.height);
    
    
    return r;
}
CGPoint CGPointScaleWithScale(CGPoint point, CGScale scale)
{
    CGPoint p = point;
    p.x *= scale.width;
    p.y *= scale.height;
    return p;
}
CGRect CGRectScaleWithScale(CGRect rect, CGScale scale)
{
    CGRect r = rect;
    r.size = CGSizeScaleWithScale(r.size, scale);
    r.origin = CGPointScaleWithScale(r.origin, scale);
    return r;
}
BOOL CGScaleIsUnknownEqualOrZero(CGScale scale)
{
    return CGScaleUnknownOrZero(scale) || CGScaleEqualToScale(scale, CGScaleEqual);
}
BOOL CGScaleIsEqual(CGScale scale)
{
    return CGScaleEqualToScale(scale, CGScaleEqual);
}
BOOL CGScaleUnknownOrZero(CGScale scale)
{
    return CGScaleIsUnknown(scale) || CGScaleIsZero(scale);
}
BOOL CGRectIsUnknownOrZero(CGRect rect)
{
    return CGRectEqualToRect(rect, CGRectUnknown) || CGRectEqualToRect(rect, CGRectZero);
}
BOOL CGRectIsUnknown(CGRect rect)
{
    return CGRectEqualToRect(rect, CGRectUnknown);
}
BOOL CGSizeIsUnknownOrZero(CGSize size)
{
    return CGSizeEqualToSize(size, CGSizeUnknown) || CGSizeEqualToSize(size, CGSizeZero);
}
BOOL CGSizeIsUnknown(CGSize size)
{
    return CGSizeEqualToSize(size, CGSizeUnknown);
}
BOOL CGRectUnknownOrZero(CGRect rect)
{
    return CGRectIsUnknown(rect) || CGRectIsZero(rect);
}

CGPoint CGPointWith(CGFloat n)
{
    return (CGPoint) {n,n};
}
UIEdgeInsets UIEdgeInsetsRescale(UIEdgeInsets ins, CGScale oldScale, CGScale scale)
{
    ins.bottom = (ins.bottom/oldScale.y) * scale.y;
    ins.top = (ins.top/oldScale.y) * scale.y;
    ins.left = (ins.left/oldScale.x) * scale.x;
    ins.right = (ins.right/oldScale.x) * scale.x;
    return ins;
}
UIEdgeInsets UIEdgeInsetsMakeWithSize(CGSize s)
{
    return UIEdgeInsetsMake(s.height, s.width, s.height , s.width);
    
}
UIEdgeInsets UIEdgeInsetsMakeWithPoint(CGPoint p)
{
    return UIEdgeInsetsMake(p.y, p.x, p.y , p.x);
}
UIEdgeInsets UIEdgeInsetsMakeWithXY(CGFloat x, CGFloat y)
{
    return UIEdgeInsetsMake(y, x, y , x);
}
UIEdgeInsets UIEdgeInsetsFromNormalizedInsetsSize(UIEdgeInsets normalInsets, CGSize size)
{
    UIEdgeInsets si = UIEdgeInsetsZero;
    
    si.top = normalInsets.top * size.height;
    si.bottom = normalInsets.bottom * size.height;
    si.left = normalInsets.left * size.width;
    si.right = normalInsets.right * size.width;
    
    return si;
}

UIEdgeInsets UIEdgeInsetsIntegralFromNormalizedInsetsSize(UIEdgeInsets normalInsets, CGSize size)
{
    UIEdgeInsets si = UIEdgeInsetsFromNormalizedInsetsSize(normalInsets, size);
    si.top = (int)si.top;
    si.left = (int)si.left;
    si.bottom = (int)si.bottom;
    si.right = (int)si.right;
    return si;
}
CGSize CGSizeMakeWithString(NSString *str)
{
    if(!str) return CGSizeZero;
    if(![str isKindOfClass:[NSString class]] && [str isKindOfClass:[NSValue class]]) return [(id)str CGSizeValue];
    if([str isEqualToString:@"unknown"]) return CGSizeUnknown;
    
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *c = [str componentsSeparatedByString:@"x"];
    CGSize size = CGSizeZero;
    if(c.count == 2)
    {
        size.width=[[c objectAtIndex:0] floatValue];
        size.height=[[c objectAtIndex:1] floatValue];
    }
    return size;
    
    
}
CGSize CGSizeMakeUnknown(CGSize size)
{
    CGSize newSize = size;
    BOOL useHeight = size.height >  size.width ? NO : YES;
    CGFloat widthOrHeight = useHeight ? size.height : size.width;
    newSize.height = useHeight ? widthOrHeight : MysticSizeUnknown.height;
    newSize.width = useHeight ? MysticSizeUnknown.width : widthOrHeight;
    return newSize;
}
CGSize CGSizeMakeUnknownWidth(CGSize size)
{
    CGSize newSize = size;
    newSize.width = MysticSizeUnknown.width;
    return newSize;
}
CGSize CGSizeMakeUnknownHeight(CGSize size)
{
    CGSize newSize = size;
    newSize.height = MysticSizeUnknown.height;
    return newSize;
}

CGSize CGSizeFilterUnknown(CGSize size)
{
    CGSize newSize = size;
    newSize.height = newSize.height == MysticSizeUnknown.height ? newSize.width : newSize.height;
    newSize.width = newSize.width == MysticSizeUnknown.width ? newSize.height : newSize.width;
    
    return newSize;
}
NSValue *CGSizeMakeValue(CGFloat width, CGFloat height)
{
    return [NSValue valueWithCGSize:CGSizeMake(width, height)];
}
NSValue *CGRectMakeValue(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    return [NSValue valueWithCGRect:CGRectMake(x, y, width, height)];
    
}
BOOL CGSizeIsWide(CGSize size)
{
    return size.width > size.height || size.width == size.height;
}
BOOL CGSizeIsTall(CGSize size)
{
    return size.height > size.width;
}
BOOL CGSizeEqualRatio(CGSize size1, CGSize size2)
{
    BOOL match = CGSizeEqualToSize(size1, size2);
    if(!match)
    {
        if(size1.width > size1.height)
        {
            match = size1.width/size1.height == size2.width/size2.height;
        }
        else
        {
            match = size1.height/size1.width == size2.height/size2.width;
        }
    }
    return match;
}
UIColor *ColorOfImageAtPoint(UIImage *image, CGPoint point)
{
    if(!image) return nil;
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
//    CGContextTranslateCTM(context,1,-1);
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}
BOOL MysticSizeHeightOnly(CGSize size)
{
    return size.width == MysticSizeUnknown.width;
}
BOOL MysticSizeWidthOnly(CGSize size)
{
    return size.height == MysticSizeUnknown.height;
}
BOOL MysticSizeHasUnknown(CGSize size)
{
    if(size.height == MysticSizeUnknown.height)
    {
        return YES;
    }
    if(size.width == MysticSizeUnknown.width)
    {
        return YES;
    }
    return NO;
}
NSString *b(BOOL val)
{
    return MBOOL(val);
}
NSString *MBOOL(BOOL val)
{
    return !val ? @"NO " : @"YES";

    
    //return !val ? @"$_FG:227,76,76_$NO $_ENDFG" : @"$_FG:117,178,21_$YES$_ENDFG";
}
NSString *MBOOLStr(BOOL val)
{
    return MBOOL(val);
}
NSString *MObj(id val)
{
    return val ? val : @"---";
}

id MNull(id val)
{
    return val ? val : [NSNull null];
}
UInt32 MysticInt(NSInteger type) {
    return (UInt32) type;
}
id MyObj(id obj)
{
    return obj && !isNull(obj) ? obj : nil;
}

id MyObjOr(id obj, id obj2)
{
    return obj && !isNull(obj) ? obj : obj2 && !isNull(obj2) ? obj2 : nil;
}

NSString *MMOpenSide(NSInteger side)
{
    id o = @"unknown";
    switch (side) {
        case 1:
            o = @"left";
            break;
        case 2:
            o = @"right";
            break;
        case 0:
            o = @"none";
            break;
        default: break;
    }
    return o;
}

NSString *NSStringFromMysticHSB(MysticHSB hsb)
{
    return [NSString stringWithFormat:@"{h: %2.2f, s: %2.2f, b: %2.2f}", hsb.hue, hsb.saturation, hsb.brightness];
}
MysticHSB MysticHSBFromArray(NSArray *hsbArray)
{
    MysticHSB newHSB = MysticHSBDefault;
    switch (hsbArray.count) {
        case 1:
        {
            newHSB.hue = [[hsbArray objectAtIndex:0] floatValue];
            break;
        }
        case 2:
        {
            newHSB.hue = [[hsbArray objectAtIndex:0] floatValue];
            newHSB.saturation = [[hsbArray objectAtIndex:1] floatValue];
            
            
            break;
        }
        case 3:
        {
            newHSB.hue = [[hsbArray objectAtIndex:0] floatValue];
            newHSB.saturation = [[hsbArray objectAtIndex:1] floatValue];
            newHSB.brightness = [[hsbArray objectAtIndex:2] floatValue];
            
            
            break;
        }
            
        default: break;
    }
    return newHSB;
}
MysticHSB MysticHSBMake(CGFloat hue, CGFloat saturation, CGFloat brightness)
{
    MysticHSB newHSB = {hue, saturation, brightness};
    return newHSB;
}
BOOL MysticHSBEqualToHSB(MysticHSB hsb1, MysticHSB hsb2)
{
    if(hsb1.brightness != hsb2.brightness) return NO;
    if(hsb1.hue != hsb2.hue) return NO;
    if(hsb1.saturation != hsb2.saturation) return NO;
    
    
    return YES;
}
BOOL MysticTypeEqualsType(MysticObjectType type1, MysticObjectType type2)
{
    if(type1 == type2) return YES;
    if(type1 == MysticObjectTypeMixture && (type2 == MysticObjectTypeTexture || type2 == MysticObjectTypeLight))
    {
        return YES;
    }
    if(type2 == MysticObjectTypeMixture && (type1 == MysticObjectTypeTexture || type1 == MysticObjectTypeLight))
    {
        return YES;
    }
    switch (type1) {
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        {
            if(type2 == MysticObjectTypeAll) return YES;
            break;
        }
            
        default: break;
    }
    return NO;
}
MysticToolType MysticTransformTypeToToolType(MysticToolsTransformType type)
{
    switch (type) {
        case MysticToolsTransformLeft:
        {
            return MysticToolTypePanLeft;
        }
        case MysticToolsTransformRight:
        {
            return MysticToolTypePanRight;
        }
        case MysticToolsTransformUp:
        {
            return MysticToolTypeMoveUp;
        }
        case MysticToolsTransformDown:
        {
            return MysticToolTypeMoveDown;
        }
        case MysticToolsTransformFlipLandscape:
        {
            return MysticToolTypeFlipHorizontal;
        }
        case MysticToolsTransformFlipPortrait:
        {
            return MysticToolTypeFlipVertical;
        }
        case MysticToolsTransformPlus:
        {
            return MysticToolTypeSizeBigger;
        }
        case MysticToolsTransformMinus:
        {
            return MysticToolTypeSizeSmaller;
        }
        case MysticToolsTransformRotateLeft:
        {
            return MysticToolTypeRotateLeft;
        }
        case MysticToolsTransformRotateRight:
        {
            return MysticToolTypeRotateRight;
        }
        case MysticToolsTransformRotateClockwise:
        {
            return MysticToolTypeRotateClockwise;
        }
        case MysticToolsTransformRotateCounterClockwise:
        {
            return MysticToolTypeRotateCounterClockwise;
        }
        default: break;
    }
    return MysticToolTypeUnknown;
}
void MyLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    
    NSString *formattedString = [[NSString alloc] initWithFormat: format
                                                       arguments: args];
    va_end(args);
    
    formattedString = [[NSString stringWithFormat:@"%@\n", [formattedString autorelease]] retain];
    [[NSFileHandle fileHandleWithStandardOutput]
     writeData: [formattedString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
    [formattedString release];
    
}
NSString * viewGesturesString(UIView *view, BOOL showAll)
{
    
    NSMutableString *ss = [NSMutableString string];
    for (id r in view.gestureRecognizers) {
        if(!showAll && [NSStringFromClass([r class]) hasPrefix:@"UIScroll"]) continue;
        [ss appendFormat:@"%@, ", [r class]];
    }
    [ss replaceOccurrencesOfString:@"Gesture" withString:@"" options:nil range:NSMakeRange(0, ss.length)];
    [ss replaceOccurrencesOfString:@"UI" withString:@"" options:nil range:NSMakeRange(0, ss.length)];
    [ss replaceOccurrencesOfString:@"Recognizer" withString:@"" options:nil range:NSMakeRange(0, ss.length)];
    return ss;
}

NSString *MysticCacheTypeToString(MysticCacheType type)
{
    switch (type) {
        case MysticCacheTypeLayer: return @"MysticCacheTypeLayer";
        case MysticCacheTypeImage: return @"MysticCacheTypeImage";
        case MysticCacheTypeProject: return @"MysticCacheTypeProject";
        case MysticCacheTypeNone: return @"MysticCacheTypeNone";
        case MysticCacheTypeMemory: return @"MysticCacheTypeMemory";
        case MysticCacheTypeDisk: return @"MysticCacheTypeDisk";
        case MysticCacheTypeMemoryOrDisk: return @"MysticCacheTypeMemoryOrDisk";
        default: break;
    }
    return @"MysticCacheType - unknown?";
}
static int slsubviewPrefixLength = 5;

//int VLogDotsLength(int d, int t, int extra) { return (MAX(1,d+1)*12) - (MAX(d, 0)*6)  - (t-d<=0 ? 1:(d+1)) + extra - (t-d>0?slsubviewPrefixLength:0); }
int VLogDotsLength(int d, int t, int extra) { return (MAX(1,d+1)*12) - (MAX(d, 0)*6)  - (t-d<=0 ? 1:(d+1)) + extra; }


NSString *VLLogViewStr(UIView *view, int d, int t, int extra, int pl, NSArray *subviews)
{
    int e = extra;
    int rectExtra = 0;
    int n =  VLogDotsLength(d,t,extra);
    NSString *rectSpace = @" ";
    NSString *rectPre = @"";
    NSMutableString *str = [NSMutableString string];
    CALayer *lyr = view.layer.sublayers.count && ![[view.layer.sublayers lastObject] isKindOfClass:[CALayer class]] && extra != 5 ? view.layer.sublayers.lastObject :  view.layer;
    NSString *lrect = fpad(lyr.frame);
    lrect = [[[lrect replace:@"," with:@", "] replace:@"x" with:@" ✕ "]  replace:@"0, 0" with:@"0,0 "];
    lrect = !(CGSizeMaxWH(CGSizeDiff(lyr.frame.size, lyr.bounds.size)) > 0.5) ? lrect : [[NSString format:@"%@ (%@)", lrect, s(lyr.bounds.size)] remove:@".0"];
    lrect = [lrect replace:@"CGRectZero" with:ColorWrap(@"CGRectZero", COLOR_DULL)];
    lrect = [lrect replace:@"CGRectUnknown" with:ColorWrap(@"CGRectUnknown", COLOR_RED)];
    lrect = [lrect replace:@"CGRectInfinite" with:ColorWrap(@"CGRectInfinite", COLOR_BLUE)];
    
    NSString *mlrect = !view.layer.mask || extra > 0 ? nil : fpad(view.layer.mask.frame);
    mlrect = !mlrect ? nil : [[[mlrect replace:@"," with:@", "] replace:@"x" with:@" ✕ "] replace:@"0, 0" with:@"0,0 "];
    
    
    
    CGRect viewRect = CGRectIsZero(view.originalFrame) ? (view.frame) :  (view.originalFrame);
    NSString *rect = fpad(viewRect) ;
    if(view.superview && t-d>0 && CGRectEqual(viewRect, CGRectz(view.superview.originalFrame)))
    {
        rect = [[rect replace:@"," with:@", "] replace:@"x" with:@" ✕ "];
        rect = [rect replace:@"0, 0" with:@"0,0 "];
        rect = ColorWrap(rect, [(UIColor *)[MysticColor color:COLOR_DOTS] darker:0.2]);
    }
    else
    {
        NSString *zeros = [NSString format:@"0%@0", ColorWrap(@", ", @"E39C38")];
        
        rect = [rect replace:@"," with:ColorWrap(@", ", @"E39C38")];
        rect = [rect replace:@"x" with:ColorWrap(@" ✕ ", @"E39C38")];
        rect = [rect replace:zeros with:[NSString format:@"0%@0 ", ColorWrap(@",", @"E39C38")]];
    }
    
    
    if([rect hasPrefix:@"-"]) rectSpace = @".";
    if(CGSizeMaxWH(CGSizeDiff(view.frame.size, view.bounds.size))>0.3) rectPre=[ColorWrap([[s(view.bounds.size) remove:@".0"] replace:@"x" with:@" ✕ "], COLOR_DOTS) stringByAppendingFormat:@" %@", rectPre.lengthVisible ? [rectPre prefix:@" "] : @""];
    
    if(!CGAffineTransformIsIdentity(view.transform)) rectPre = [NSString format:@"%@%@", rectPre.lengthVisible ? [rectPre suffix:@" "] : @"", ColorWrap(trans(view.transform), COLOR_BLUE)];
    
    
    
    
    BOOL colorBg = NO;
    UIColor *color = view.layer.borderWidth > 0 ? [UIColor colorWithCGColor:view.layer.borderColor] : lyr.borderWidth > 0 ? [UIColor colorWithCGColor:lyr.borderColor] : nil;
    color = color ? color : [lyr isKindOfClass:[CAShapeLayer class]] && [(CAShapeLayer *)lyr strokeColor] ?
    [UIColor colorWithCGColor:[(CAShapeLayer *)lyr strokeColor]] : nil;
    if(!color)
    {
        color = [lyr isKindOfClass:[CAShapeLayer class]] && [(CAShapeLayer *)lyr fillColor] ? [UIColor colorWithCGColor:[(CAShapeLayer *)lyr fillColor]] : [UIColor colorWithCGColor:lyr.backgroundColor];
        colorBg = color!=nil;
    }
    color = color && color == UIColor.clearColor ? nil : color;
    NSString *pColor = view.hidden&&e!=5 ? (id)COLOR_RED:nil;
    if(view.isFirstResponder) pColor = pColor ? pColor : COLOR_GREEN_BRIGHT;
    UIColor *bgColor = [MysticColor color:COLOR_BG];
    UIColor *viewColor = pColor ? [MysticColor color:pColor] : [MysticColor color:(id)color];
    UIColor *colorDarker = (!mlrect||!pl) || (extra >0||!pl||extra==99) ? nil : viewColor ? [viewColor darker:0.2] : nil;
    colorDarker = colorDarker && [colorDarker isDarkerThan:bgColor] ? [colorDarker lighterThan:bgColor] : colorDarker;
    
    UIColor *_color = [color isEqualToColor:UIColor.clearColor] ? nil : [MysticColor color:color];
    color = color && _color && [_color isDarkerThan:bgColor] ? [_color lighterThan:bgColor] : _color;
    
    NSString *s = extra > 0 ? @" " : @".";
    int c = color ? lyr.borderWidth || view.layer.borderWidth ? 1 : 2 : 0;
    BOOL dotted = [lyr isKindOfClass:[CAShapeLayer class]] && [(CAShapeLayer *)lyr lineDashPattern];
    NSString *cStr = color && colorBg ? ColorWrap([@"█" repeat:c], color) : (color ? dotted ? ColorWrap([@"▪" repeat:c], color) : ColorWrap([@"■" repeat:c], color) : nil);
    NSString *info = nil;
    NSString *other = nil;
    
    if(view.hidden) info = [NSString format:@"%@$_ENDFG$_FG:%@_$✕$_ENDFG$_FG:" COLOR_DOTS "_$", info ? [info suffix:@" "]: @"", (id)COLOR_RED];
    if(view.alpha < 1) info = [[NSString format:@"%@$_FG:" COLOR_PURPLE "_$α %1.1f$_ENDFG$_FG:" COLOR_DOTS "_$", info ? [info suffix:@" "] : @"", view.alpha] remove:@".0"];
    if([view isKindOfClass:[UILabel class]])
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , [(UILabel *)view attributedText] ? [(UILabel *)view attributedText].string : [(UILabel *)view text] ? [(UILabel *)view text] : @""];
    }
    else if([view isKindOfClass:[UIButton class]] && [(UIButton *)view titleLabel])
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , [[(UIButton *)view titleLabel] attributedText] ? [[(UIButton *)view titleLabel] attributedText].string : [[(UIButton *)view titleLabel] text] ? [[(UIButton *)view titleLabel] text] : @""];
    }
    else if([view isKindOfClass:[UIImageView class]])
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , [(UIImageView *)view image] ? [NSString format:@"@%1.0fx %@", [(UIImageView *)view image].scale, SLogStr([(UIImageView *)view image].size)] : @"No Image"];
    }
    else if([view isKindOfClass:[UIScrollView class]])
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , [NSString format:@"%@", SLogStr([(UIScrollView *)view contentSize])]];
    }
    else if([view respondsToSelector:@selector(info)])
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , [view performSelector:@selector(info)]];
    }
    else if([view respondsToSelector:@selector(viewInfo)])
    {
        NSString *vinfo = [view performSelector:@selector(viewInfo)];
        if(vinfo && vinfo.length) info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" , vinfo];
    }
    if(view.gestureRecognizers.count > 0)
    {
        info =  [NSString format:@"%@%@", info ? [info suffix:@" "] : @"" ,viewGesturesString(view, NO)];
    }
    if(view.layer.shadowRadius > 0 && view.layer.shadowRadius != 3.00)
    {
        info =  [NSString format:@"%@Shadow %2.2f", info ? [info suffix:@" "] : @"" , view.layer.shadowRadius];
    }
    if(view.userInteractionEnabled)
    {
        info =  [NSString format:@"%@%@%@", info ? [info suffix:@" "] : @"" ,     @"^", view.multipleTouchEnabled ? @"^" : @""];
    }
    if(subviews.count && (view.clipsToBounds || lyr.masksToBounds))
    {
        rect = [NSString format:@"%@%@%@", rectPre.lengthVisible>0 ? @" " : @"", ColorWrap(@"◘  ", COLOR_GREEN_BRIGHT), rect];
        rectSpace = @" ";
    }
    else if(!(extra >0||!pl) && (view.superview.clipsToBounds || view.superview.layer.masksToBounds))
    {
        rect = [NSString format:@"%@%@%@", rectPre.lengthVisible>0 ? @" " : @"", ColorWrap(@"╰─ ", COLOR_GREEN_BRIGHT), rect];
        rectSpace = @".";
    }
    
    
    int ol = other&&other.length ? (int)other.length : 0;
    int il = info&&info.length ? (int)info.length:0;
    n-=ol>1?(int)other.length+(il?1:0):0;
    NSString *pClass = [view respondsToSelector:@selector(classString)] ? [view performSelector:@selector(classString)] : NSStringFromClass([view class]);
    if(view.isFirstResponder) {
        pClass = [pClass stringByAppendingString:@"*"];
    }
    
    int c2 = (cStr && !cStr.isEmpty ? c+1 : 0);
    NSString *clStr = !pl ? [pClass stringByAppendingFormat:@"  $_FG:" COLOR_DOTS "_$%@%@", il ? [info suffix:@" "] : @"", ol > 1 ? il ? [other prefix:@" "] : other : @""] : nil;
    clStr = !pl?clStr: [pClass stringByAppendingFormat:@"  $_FG:" COLOR_DOTS "_$%@%@", il ? [info suffix:@" "] : @"", ol > 1 ? il ? [other prefix:@" "] : other : @""];
    clStr = [clStr replace:pClass with:ColorWrap(pClass, pColor)];
    int mllc = 0;
    NSString *lc = [NSStringFromClass(lyr.class) equals:@"CALayer"] ? @"Layer" : NSStringFromClass(lyr.class);
    lc = [lc equals:@"Layer"] ? lc : [lc pad:20];
    mllc = lc.length-4;
    NSString *lcf = nil;
    n-=c2;
    if(CGRectEqualOrZero(lyr.frame, view.frame) && ([lc equals:@"Layer"] || [lc hasPrefix:@"_"])) extra = view.subviews.count ? 1 : 99;
    NSString *mc = nil;
    NSString *mfs = lyr.mask && [lyr.mask respondsToSelector:@selector(path)] && [(CAShapeLayer*)lyr.mask path] ? [fpadd(PathRect([UIBezierPath bezierPathWithCGPath:[(CAShapeLayer*)lyr.mask path]]), 18) replace:@"x" with:@" ✕ "] : nil;
    NSString *lfs = [lyr respondsToSelector:@selector(path)] && [(CAShapeLayer*)lyr path] ? [fpadd(PathRect([UIBezierPath bezierPathWithCGPath:[(CAShapeLayer*)lyr path]]), 18) replace:@"x" with:@" ✕ "] : nil;
    if(lfs) lcf = [NSString format:@"  %@%@", [mfs hasPrefix:@"-"] && ![lfs hasPrefix:@"-"] ? @" " : @"", lfs];
    if(mfs) mc = [NSString format:@" %@%@",  [lfs hasPrefix:@"-"] && ![mfs hasPrefix:@"-"] ? @" " : @"", mfs];
    
    NSString *pfx = [[@" " repeat:slsubviewPrefixLength] repeat:t-d];
    int r = !pl ? MIN(130,MAX(80,t*14)) : pl-rectSpace.lengthVisible-(c2+clStr.lengthVisible+rect.lengthVisible + (!rectPre.length ? 0 : rectPre.lengthVisible+1) + (t-d<=0?0:(int)pfx.length)+(t-d>0?5:0));
    r+=rectExtra;
    int ml=!pl?0:pl-(c2+8+(mllc>0?mllc+1:0)+mlrect.lengthVisible+(mc?mc.lengthVisible:0)+(t-d>0?(int)pfx.length:0)+(t-d>0?5:0));
    int ll=!pl?0:pl-(c2+8+lc.lengthVisible+lcf.lengthVisible+lrect.lengthVisible+(t-d<=0?0:(int)pfx.length)+(5*(t-d>0?1:0)))+([lc equals:@"Layer"]?1:4);
    BOOL hasLayer = !(extra >0||!pl||extra==99) && ![view isKindOfClass:[MysticRectView class]] && !view.ignoreLayerDebug;
    BOOL hasMask = (!(!mlrect||!pl)) && ![view isKindOfClass:[MysticRectView class]] && hasLayer;
    
    [str appendFormat:@"%@%@%@%@$_ENDFG%@%@%@%@%@",
     !cStr || cStr.isEmpty ? @"" : [cStr suffix:@" "],
     clStr,
     [s repeat:r],
     rectSpace,
     // END COLOR_DOTS
     rectPre.length ? [rectPre suffix:@" "] : @"",
     [rect suffix:@"    "],
     hasLayer || hasMask ? [NSString stringWithFormat:@"\n   %@", ColorWrap(@"╷", colorDarker ? colorDarker : hasMask ? COLOR_PINK : COLOR_DOTS)] : @"",
     !hasMask ? @"" : [NSString format:@"\n   %@%@$_ENDFG %@ %@%@%@",
                       ColorWrap([@"─╴ Mask" prefix:hasMask ? @"⎬" : @"╰"], colorDarker ? colorDarker : COLOR_PINK),
                       mllc>0 ? [@" " repeat:mllc+1] : @" ",
                       mc ? ColorWrap(mc, colorDarker?colorDarker:COLOR_DOTS) : @"",
                       ColorWrap([s repeat:ml+([mlrect hasPrefix:@"-"] ?1:0)], COLOR_DOTS),
                       [mlrect hasPrefix:@"-"] ? @"" : @" ",
                       ColorWrap(mlrect, colorDarker ? colorDarker : COLOR_DOTS)],
     
     !hasLayer ? (extra==99 ? @"\n" : @"") : [NSString format:@"\n   %@ %@%@%@%@\n",
                                              ColorWrap([NSString format:@"╰─╴ %@", lc], colorDarker?colorDarker:COLOR_DOTS),
                                              lcf?ColorWrap([lcf suffix:@" "], colorDarker?colorDarker:COLOR_DOTS):@"",
                                              ColorWrap([s repeat:ll+([lrect hasPrefix:@"-"]?1:0)], COLOR_DOTS),
                                              [lrect hasPrefix:@"-"]?@"":@" ",
                                              ColorWrap(lrect, colorDarker?colorDarker:COLOR_DOTS)]
     ];
    return str;
}
NSString *MysticScrollDirectionStr(MysticScrollDirection d)
{
    switch (d) {
        case MysticScrollDirectionUp: return ColorWrap(@"Up   ", COLOR_GREEN_BRIGHT);
        case MysticScrollDirectionDown: return ColorWrap(@"Down ", COLOR_RED);
        case MysticScrollDirectionLeft: return @"Left ";
        case MysticScrollDirectionRight: return @"Right";
        case MysticScrollDirectionNone: return ColorWrap(@"None ", COLOR_DULL);

            
        default:
            break;
    }
    return ColorWrap(@" --- ", COLOR_DULL);
}
CGPoint MCenterOfRect(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static BOOL isRunningOnPhone = YES;
BOOL runningOnPhone()
{
    static BOOL isPhone;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        isRunningOnPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YES : NO;
    });
    
    return isRunningOnPhone;
}
NSString *UIControlStateStr(UIControlState s)
{
    switch (s) {
        case UIControlStateSelected: return @"UIControlStateSelected";
        case UIControlStateNormal: return @"UIControlStateNormal";
        case UIControlStateDisabled: return @"UIControlStateDisabled";
        case UIControlStateHighlighted: return @"UIControlStateHighlighted";
        case UIControlStateApplication: return @"UIControlStateApplication";
        case UIControlStateFocused: return @"UIControlStateFocused";
        case UIControlStateReserved: return @"UIControlStateReserved";
        default:
            break;
    }
    return @"UIControlState-Unknown";
}
void PrintView(NSString *name, UIView *view)
{
    ALLog(name, @[@"view", VLLogStr(view)]);
}
NSString *MysticPrintSubLayersOf(UIView *pview, BOOL showDesc, NSString *prefix, int depth, int d, int totalDepth, int maxDepth, int pl)
{
    id v1 = nil;
    NSArray *subviews = [pview isKindOfClass:[NSArray class]] ? (id)pview : pview.subviews;
    if([pview isKindOfClass:[NSArray class]])
    {
        if(![(NSArray *)pview lastObject]) return @"";
        pview = [(UIView *)[(NSArray *)pview lastObject] superview];
    }
    if([pview isKindOfClass:[MysticScrollView class]] && subviews.count >= 2)
    {
        subviews = [pview.subviewsSorted subarrayWithRange:NSMakeRange(0, 2)];
        v1=subviews[0];
    }
    else if([pview isKindOfClass:[UIControl class]]) {
        subviews = pview.subviews;
    }
    
    prefix = prefix ? prefix : [[[@" " repeat:slsubviewPrefixLength] repeat:d+1] stringByAppendingString:@""];
    NSMutableString *str = [NSMutableString stringWithFormat:@""];
    pl = pl ? pl : 0;
    if(showDesc)
    {
        NSString *q = [VLLogViewStr(pview, totalDepth, maxDepth, 5, pl, subviews) replace:@"\n" with:[NSString stringWithFormat:@"\n%@  ", d == 0 ? @"" : prefix]];
        pl = q.firstLine.lengthVisible-5-4;
        [str appendFormat:@"%@\n$_FG:" COLOR_BLOCK "_$%@$_ENDFG\n   ", q, [@"─" repeat:pl+5]];
    }
    int i = 1;
    for (UIView *subview in subviews)
    {
        NSArray *subSubviews = subview.subviews;
        if([subview isKindOfClass:[MysticScrollView class]] && subSubviews.count >= 2)
        {
            subSubviews = [subview.subviewsSorted subarrayWithRange:NSMakeRange(0, 2)];
        }
        else if(/* DISABLES CODE */ (NO) && [subview isKindOfClass:[UIControl class]]) subSubviews = @[];
        
        NSString *vlstr = VLLogViewStr(subview, totalDepth, maxDepth, 0, pl, subSubviews);
        int tidx = slsubviewPrefixLength-2;
        int idxSpc = tidx;
        if([vlstr hasPrefix:@"{3}"]) idxSpc = 0;
        else if([vlstr hasPrefix:@"{2}"]) idxSpc = 1;
        else if([vlstr hasPrefix:@"{1}"]) idxSpc = 2;
        vlstr = idxSpc==tidx ? vlstr : [vlstr substringFromIndex:3];
        NSString *vstr = [vlstr replace:@"\n" with:[NSString format:@"\n%@  ", d == 0 ? @"" : prefix]];
        [str appendFormat:@"\n%@%@$_FG:" COLOR_DULL "_$%d$_ENDFG%@%@",
         i > 1 && [(UIView *)[pview.subviews objectAtIndex:i-2] subviews].count > 0 ? @"   \n" : @"",
         d == 0 ? @"" : prefix,
         i,
         [@" " repeat:tidx + (i < 10 ? 1 : 0)+(i>99?-1:0)],
         vstr];
        if(subview.layer.sublayers.count && (depth<0||d<=depth))
            [str appendString:MysticPrintSubLayersOf((id)subSubviews, NO, nil, depth, d+1, totalDepth-1, maxDepth,pl)];
        i++;
    }
    if(v1) [str appendFormat:@"\n%@$_FG:" COLOR_DULL "_$3 $_ENDFG%@%@$_FG:" COLOR_DOTS "_$ %d total ...$_ENDFG",  d == 0 ? @"" : [@"     " repeat:d+1], [@" " repeat:(4 - [@((int)subviews.count) stringValue].length)], [v1 class], (int)MAX(0, pview.subviews.count)];
    return str;
}
NSString *VLLogStr(UIView *view)
{
    if(!view) return @"VLLogStr: there is no view";
    return MysticPrintLayersOf(view, -1);
}
NSString *VLogStr(UIView *view)
{
    if(!view) return @"VLogStr: there is no view";
    return MysticPrintViewsOf(view, -1);
}
void VLog(UIView *view)
{
    if(!view) DLogError(@"VLog: there is no view");
    DLog(@"%@", BgLogStr(VLogStr(view)));
}
void VLLog(UIView *view)
{
    if(!view) DLogError(@"VLog: there is no view");
    DLog(@"%@", BgLogStr(VLLogStr(view)));
}


void VLogf(NSString *format, UIView *view)
{
    if(!view) DLogError(@"VLogf: there is no view");
    format = format ? format : [NSString stringWithFormat:@"%@ <%p>: %%@", [view class], view];
    format = !format ? @"%@" : [format suffix:@"\n\n%@"];
//    DLog(format, VLLogStr(view));
    DLog(format, BgLogStr(VLLogStr(view)));
}
void VLogd(NSString *format, UIView *view, int depth)
{
    if(!view) DLogError(@"VLogd: there is no view");
    format = format ? format : [NSString stringWithFormat:@"%@ <%p>: %%@", [view class], view];
    DLog(format, BgLogStr(VLogStrd(view, depth)));
}
NSString *MysticPrintViewsOf(UIView *pview, int depth)
{
    int m = VTotalDepth(pview, -1, 0);
    return [MysticPrintSubviewsOf(pview, YES, nil, depth, 0, m,m) deleteSuffix:@"\n"];
}
NSString *MysticPrintLayersOf(UIView *pview, int depth)
{
    int m = VLTotalDepth(pview, -1, 0);
    return [MysticPrintSubLayersOf(pview, YES, nil, depth, 0, m,m,0) deleteSuffix:@"\n"];
}
NSString *VLogStrd(UIView *view, int depth) { return MysticPrintViewsOf(view, depth); }
NSString *VLogViewStr(UIView *view, int d, int t, int extra) { return VLLogViewStr(view, d, t, extra, 0, view.subviews); }




NSString *MysticPrintSubviewsOf(UIView *pview, BOOL showDesc, NSString *prefix, int depth, int d, int totalDepth, int maxDepth)
{
    return MysticPrintSubLayersOf(pview, showDesc, prefix, depth, d, totalDepth, maxDepth, 0);
}

int VTotalDepth(UIView *view, int maxDepth, int d)
{
    if(view.subviews.count > 0)
    {
        d = 1;
        int max = 0;
        for (UIView *sub in view.subviews) {
            max = MAX(max, VLTotalDepth(sub, maxDepth, 0));
        }
        d+= max;
    }
    return maxDepth > 0 ? MIN(maxDepth,d) : d;
}
int VLTotalDepth(UIView *view, int maxDepth, int d)
{
    if(view.subviews.count > 0)
    {
        d = 1;
        int max = 0;
        for (UIView *sub in view.subviews) {
            max = MAX(max, VLTotalDepth(sub, maxDepth, 0));
        }
        d+= max;
    }
    return maxDepth > 0 ? MIN(maxDepth,d) : d;
}


static NSString *indentStr = @"    ";
static NSString *tab = @"   ";
static NSString *gutter = @"     ";
NSString * _BgLogStr(NSString *str, BOOL wrapLines, int l)
{
    int a = MIN(350, MAX(20, l) + 4) + indentStr.length;
    int e= a + (int)indentStr.length;
    
    NSMutableString *s = [[NSMutableString stringWithString:str] retain];
    if([str containsString:@"\n"])
    {
        NSMutableString *s2 = [[NSMutableString alloc] initWithString:@""];
        NSArray *lines = [s componentsSeparatedByString:@"\n"];
        int i = 1;
        int x = 0;
        NSMutableArray *ar = [NSMutableArray array];
        UIColor *bgColor = [MysticColor color:COLOR_BG];
        for (NSString *line in lines)
        {
            BOOL hasBG = [line hasPrefix:kBG];
            BOOL hasBGd = [line hasPrefix:kBGd];
            BOOL hasBGb = [line hasPrefix:kBGb];
            BOOL hasBGk = [line hasPrefix:kBGk];
            
            BOOL changedBgFromBlack = (!bgColor && (hasBG || hasBGb || hasBGd));
            if(changedBgFromBlack) bgColor = [MysticColor color:COLOR_BG];
            
            
            if(hasBG) line = ColorWrap([@"▅" repeat:e],bgColor);
            if(hasBGb) line = ColorWrap([@"▅" repeat:e],[bgColor lighter:0.24]);
            if(hasBGd) line = ColorWrap([@"▅" repeat:e],[bgColor darker:0.24]);
            if(hasBGk) line = ColorWrap([@"▅" repeat:e],[UIColor blackColor]);
            
            if(changedBgFromBlack) bgColor = nil;
            
            if(line.length > 0 && ![line isEqualToString:@" "])
            {
                
                line = [line stringByReplacingOccurrencesOfString:@"\t" withString:tab];
                NSString *l2 = line.cleanString;
                x = MAX(x, (int)l2.length);
                [ar addObject:@{@"string": line, @"length": @(l2.length), @"line": @(i), @"bg": bgColor?bgColor:[UIColor blackColor]}];
            }
            else if([line isEqualToString:@" "]) [ar addObject:@{@"string": line, @"length": @(1), @"line": @(i), @"bg": bgColor?bgColor:[UIColor blackColor]}];
            
            if(hasBG || (changedBgFromBlack && (hasBGd || hasBGb))) bgColor = [MysticColor color:COLOR_BG];
            if(hasBGd) bgColor = [bgColor darker:0.24];
            if(hasBGb) bgColor = [bgColor lighter:0.24];
            if(hasBGk) bgColor = nil;
            
            i++;
        }
        
        for (NSDictionary *o in ar)
        {
            NSString *newLine = [o[@"string"] stringByAppendingString:[@" " repeat:(x - [o[@"length"] intValue])]];
            UIColor *bgColor = o[@"bg"];
            [s2 appendFormat:(@"\n" XCODE_COLORS_ESCAPE  @"%@%@" XCODE_COLORS_RESET_BG), bgColor.bgString,  wrapLines ? [newLine wrap:gutter] : newLine];
        }
        
        UIColor *firstBgColor = [[ar objectAtIndex:0] objectForKey:@"bg"];
        UIColor *lastBgColor = [[ar lastObject] objectForKey:@"bg"];
        
        NSString *spaceStr = [@" " repeat:x+(wrapLines ? gutter.length*2 : 0)];
        [s autorelease];
        s = [[NSMutableString stringWithFormat:XCODE_COLORS_ESCAPE  @"%@%@" XCODE_COLORS_RESET_BG @"\n" XCODE_COLORS_ESCAPE  @"%@%@" XCODE_COLORS_RESET_BG @"%@\n" XCODE_COLORS_ESCAPE @"%@%@" XCODE_COLORS_RESET_BG @"\n"  XCODE_COLORS_ESCAPE @"%@%@" XCODE_COLORS_RESET_BG, firstBgColor.bgString, spaceStr, firstBgColor.bgString, spaceStr, [s2 autorelease], lastBgColor.bgString, spaceStr,lastBgColor.bgString,spaceStr] retain];
    }
    
#ifndef MYSTIC_LOG_COLORS
    return [[s autorelease] wrap:@"#blank"];
#else
    return [[[s autorelease] stringByReplacingOccurrencesOfString:@"bg0,0,0;" withString:@""] wrap:@"\n\n"];
    

#endif
}
NSString * BgLogStr(NSString *str)
{
    return _BgLogStr(str, YES, -1);
}



NSMutableString *LineStrf(NSMutableString *s, int longestLine, int longestKey)
{
    NSString *d = indentStr;
    longestLine = MAX(20, longestLine) + 4;
    NSString *k = [@" " repeat:longestKey];
    int a = MIN(350, longestLine) + indentStr.length;
    int b = a;
    int c = a - (longestKey+2) ;
    int e= a + (int)d.length;
    NSString *f = nil;
    if([s containsString:kBGPrefix])
    {
        
        
        [s replaceOccurrencesOfString:kBGk withString:[@"\n" suffix:kBGk] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
        
        [s replaceOccurrencesOfString:kBGd withString:[@"\n" suffix:kBGd] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
        [s replaceOccurrencesOfString:kBGb withString:[@"\n" suffix:kBGb] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
        [s replaceOccurrencesOfString:kBG withString:[@"\n" suffix:kBG] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
        
        
    }
    
    f = (@"\n%@%@  " XCODE_COLORS_ESCAPE LINE_COLOR @"%@\n" XCODE_COLORS_RESET_FG);
    [s replaceOccurrencesOfString:@"#:#BLOCK#" withString:[NSString stringWithFormat:f,d,k,[@"█" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#DLINE#" withString:[NSString stringWithFormat:f,d,k,[@"=" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#LINE#" withString:[NSString stringWithFormat:f,d,k,[@"─" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#THIN#" withString:[NSString stringWithFormat:f,d,k,[@"-" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#THICK#" withString:[NSString stringWithFormat:f,d,k,[@"█" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#THICKER#" withString:[NSString stringWithFormat:f,d,k,[@"█" repeat:c/2]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#DOTS#" withString:[NSString stringWithFormat:f,d,k,[@"∙" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#:#STAR#" withString:[NSString stringWithFormat:f,d,k,[@"x" repeat:c]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    
    f = (@"\n%@" XCODE_COLORS_ESCAPE LINE_COLOR @"%@" XCODE_COLORS_RESET_FG @"\n"); b+=2;
    [s replaceOccurrencesOfString:@"#|#BLOCK#" withString:[NSString stringWithFormat:f,d,[@"█" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#DLINE#" withString:[NSString stringWithFormat:f,d,[@"=" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#LINE#" withString:[NSString stringWithFormat:f,d,[@"─" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#THIN#" withString:[NSString stringWithFormat:f,d,[@"-" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#THICK#" withString:[NSString stringWithFormat:f,d,[@"█" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#THICKER#" withString:[NSString stringWithFormat:f,d,[@"█" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#DOTS#" withString:[NSString stringWithFormat:f,d,[@"∙" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|#STAR#" withString:[NSString stringWithFormat:f,d,[@"x" repeat:b]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    
    f = (@"\n" XCODE_COLORS_ESCAPE LINE_COLOR @"%@" XCODE_COLORS_RESET_FG);
    [s replaceOccurrencesOfString:@"#BLOCK#" withString:[NSString stringWithFormat:f,[@"█" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#DLINE#" withString:[NSString stringWithFormat:f,[@"=" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#LINE#" withString:[NSString stringWithFormat:f,[@"─" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#THIN#" withString:[NSString stringWithFormat:f,[@"-" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#THICK#" withString:[NSString stringWithFormat:f,[@"█" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#THICKER#" withString:[NSString stringWithFormat:f,[@"█" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#DOTS#" withString:[NSString stringWithFormat:f,[@"∙" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#STAR#" withString:[NSString stringWithFormat:f,[@"x" repeat:e]] options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    [s replaceOccurrencesOfString:@"#|" withString:d options:NSCaseInsensitiveSearch range:NSMakeRange(0,s.length)];
    return s;
}
uint64_t getFreeDiskspace(BOOL inMB) {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    
    return inMB ? ((totalFreeSpace/1024ll)/1024ll) : totalFreeSpace;
}
NSString * LLogStr(id __objs)
{
    return LLogStrDebug(__objs, YES, NO);
}
NSString * LLogStrDebug(id __objs, BOOL wrap, BOOL debug)
{
#ifdef DEBUG
    NSArray *_mobjs = __objs;
    NSString *d = wrap ? indentStr : @"";
    int longestKey = 0;
    if([__objs isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray *newObjs = [NSMutableArray array];
        NSArray *aKeys = [(NSDictionary *)__objs allKeys];
        NSArray *sortedKeys = [aKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (id k in sortedKeys)
        {
            [newObjs addObject:k];
            [newObjs addObject:[(NSDictionary *)__objs objectForKey:k]];
        }
        _mobjs = newObjs;
    }
    else if(![__objs isKindOfClass:[NSArray class]])
    {
        _mobjs = [NSArray arrayWithObjects:@"^", __objs, nil];
    }
    NSMutableArray *a = [NSMutableArray array];
    for (int i = 0; i<_mobjs.count; i++) {
        MLogObj *o = [_mobjs objectAtIndex:i];
        BOOL hasNext = _mobjs.count > i+1;
        
        if([o isKindOfClass:[MLogObj class]])
        {
            [a addObject:o.key?[o.key equals:@""] ? @"^":o.key:kNullKey];
            if(o.value) [a addObject:o.value];
            continue;
        }
        else if(![o isKindOfClass:[NSNumber class]] && ![o isKindOfClass:[NSValue class]])
        {
            if(![o isKindOfClass:[NSString class]] || [(NSString *)o containsString:@"\n"])
            {
                if(!(a.lastObject && [a.lastObject isKindOfClass:[NSString class]] && [(NSString *)a.lastObject lengthVisible] < 40))
                {
                    [a addObject:kNullKey];
                }
            }
            
        }
        [a addObject:o];
    }
    
    NSMutableArray *objs = [NSMutableArray arrayWithArray:a];
    for (int i = 0; i<objs.count; i++) {
        id key = [objs objectAtIndex:i];
        BOOL hasNext = objs.count > i+1;
        id value = hasNext ? [objs objectAtIndex:i+1] : nil;
        if(hasNext && [value isKindOfClass:[NSArray class]])
        {
            NSArray *values = [value retain];
            if(values.count > 0 && [[values objectAtIndex:0] isKindOfClass:[NSString class]])
            {
                NSString *ls = LLogStrDebug(values, NO, debug);
                if(ls) [objs replaceObjectAtIndex:i+1 withObject:[[ls trim:@"\n"] append:@"\n"]];
            }
            [values release];
        }
    }
    NSMutableArray *_objs = [NSMutableArray array];
    for (int i = 0; i < objs.count; i++)
    {
        id key = [objs objectAtIndex:i];
        if(debug) DLog(@"\t Key: %@", [key isKindOfClass:[NSString class]]? key : [key class]);
        BOOL hasNextIndex = objs.count > i+1;
        NSString *sKey = nil;
        if([key isKindOfClass:[NSString class]])
        {
            sKey = [key replace:@" " with:@""];
            sKey = [sKey replace:@"|" with:@""];
            sKey = [sKey replace:@":" with:@""];
        }
        NSString *kPre = nil;
        NSString *kSuf = nil;
        NSString *_kPre = nil;
        NSString *_kSuf = nil;
        if(sKey && sKey.length < 6 && sKey.length > 0)
        {
            NSRange sKr = [key rangeOfString:sKey];
            if(sKr.location != NSNotFound)
            {
                if(sKr.location > 0) _kPre = [key substringWithRange:NSMakeRange(0, sKr.location)];
                if([(NSString *)key length] > sKr.location + sKr.length) _kSuf = [key substringWithRange:NSMakeRange(sKr.location+sKr.length, [(NSString *)key length] - (sKr.location+sKr.length))];
                if(_kPre && _kPre.length > 0)
                {
                    NSMutableString *kPres = [NSMutableString stringWithString:@""];
                    for (int x = 0; x < _kPre.length; x++) {
                        NSRange kRan = NSMakeRange(x, 1);
                        NSString *kc = [_kPre substringWithRange:kRan];
                        if(kc && [kc equals:@" "]) [kPres appendString:@"\n \n"];
                        if(kc && [kc equals:@"|"]) [kPres appendString:@"#|"];
                        if(kc && [kc equals:@":"]) [kPres appendString:@"#:"];
                    }
                    if(kPres.length > 0) kPre = [NSString stringWithString:kPres];
                }
                
                if(_kSuf && _kSuf.length > 0)
                {
                    NSMutableString *kSufs = [NSMutableString string];
                    for (int x = 0; x < _kSuf.length; x++) {
                        NSRange kRan = NSMakeRange(x, 1);
                        NSString *kc = [_kSuf substringWithRange:kRan];
                        if(kc && [kc equals:@" "]) [kSufs appendString:@"\n \n"];
                        if(kc && [kc equals:@"|"]) [kSufs appendString:@"#|"];
                    }
                    if(kSufs.length > 0) kSuf = [NSString stringWithString:kSufs];
                }
            }
        }
        if(debug) DLog(@"\t\t Key format: %@", [key isKindOfClass:[NSString class]]? key : [key class]);
        
        kPre = kPre ? kPre : @"";
        kSuf = kSuf ? kSuf : @"";
        if([key isKindOfClass:[NSString class]] && [key isEqualToString:@" "])
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
        }
        else if([key isKindOfClass:[NSString class]] && [key isEqualToString:@"#end"]) break;
        else if([key isKindOfClass:[NSString class]] && [key isEqualToString:@"  "])
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
        }
        else if([key isKindOfClass:[NSString class]] && [key isEqualToString:SKP]) i++;
        else if([key isKindOfClass:[NSString class]] && [key isEqualToString:@"   "])
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
        }
        else if(sKey && ([sKey isEqualToString:kBGk]))
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:kBGk];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            
        }
        else if(sKey && ([sKey isEqualToString:kBGd]))
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:kBGd];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            
        }
        else if(sKey && ([sKey isEqualToString:kBGb]))
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:kBGb];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            
        }
        else if(sKey && ([sKey isEqualToString:kBG]))
        {
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:kBG];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            [_objs addObject:SKP];
            [_objs addObject:@" "];
            
        }
        else if(sKey && ([sKey isEqualToString:mkLBlockSpaceNone]))
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#BLOCK#%@", kPre, kSuf]];
        }
        else if(sKey && ([sKey isEqualToString:mkLineMedSpaceNone]))
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#THICK#%@", kPre, kSuf]];
        }
        else if(sKey && ([sKey isEqualToString:mkLineFatSpaceNone]))
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#THICKER#%@", kPre, kSuf]];
        }
        else if(sKey && ([sKey isEqualToString:mkLineSpaceNone]))
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#LINE#%@", kPre, kSuf]];
        }
        else if(sKey && ([sKey isEqualToString:mkLineThinSpaceNone]))
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#THIN#%@", kPre, kSuf]];
        }
        else if(sKey && [sKey isEqualToString:mkLDotsSpaceNone])
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#DOTS#%@", kPre, kSuf]];
        }
        else if(sKey && [sKey isEqualToString:mkLStarSpaceNone])
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#STAR#%@", kPre, kSuf]];
        }
        else if(sKey && [sKey isEqualToString:mkLDoubleSpaceNone])
        {
            [_objs addObject:SKP];
            [_objs addObject:[NSString stringWithFormat:@"%@#DLINE#%@", kPre, kSuf]];
        }
        else
        {
            id value = hasNextIndex ? [objs objectAtIndex:i+1] : nil;
            id newKey = key;
            NSString *keyStrLen = newKey;
            if([newKey isKindOfClass:[NSString class]] && !isZeroOrNotFound([newKey rangeOfString:@"%"].length))
            {
                NSString *k = newKey;
                NSRange r = [k rangeOfString:@"%"];
                NSString *keyFormat = [k substringFromIndex:r.location];
                newKey = [k substringToIndex:r.location];
                if([value isKindOfClass:[NSNumber class]])
                {
                    if([keyFormat rangeOfString:@"%@"].length != 0)
                    {
                        value = [NSString stringWithFormat:keyFormat, value];
                    }
                    else if([keyFormat rangeOfString:@"%d"].length != 0)
                    {
                        value = [NSString stringWithFormat:keyFormat, [value integerValue]];
                    }
                    else if([keyFormat rangeOfString:@"f"].length != 0)
                    {
                        value = [NSString stringWithFormat:keyFormat, [value floatValue]];
                    }
                }
                keyStrLen = newKey;
            }
            if([keyStrLen isKindOfClass:[NSString class]] && [keyStrLen hasSuffix:@";"])
            {
                NSInteger hashStart = [keyStrLen rangeOfString:@"#" options:NSBackwardsSearch].location;
                NSInteger hashEnd = [keyStrLen rangeOfString:@";" options:NSBackwardsSearch].location;
                keyStrLen = hashStart!=NSNotFound && hashEnd!=NSNotFound ? [keyStrLen substringToIndex:hashStart] : keyStrLen;
            }
            if([keyStrLen isKindOfClass:[NSString class]] && [keyStrLen hasPrefix:@"#"])
            {
                NSInteger hashEnd = [keyStrLen rangeOfString:@";"].location;
                keyStrLen = [keyStrLen substringFromIndex:hashEnd!=NSNotFound ? hashEnd+1:1];
            }
            
            if([newKey isKindOfClass:[NSString class]]) newKey = [newKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([keyStrLen isKindOfClass:[NSString class]]) keyStrLen = [keyStrLen stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([keyStrLen isKindOfClass:[NSString class]] && ([keyStrLen equals:@"^"] || [keyStrLen equals:kNullKey])) keyStrLen = @"";
            
            [_objs addObject:newKey];
            [_objs addObject:value ? value : @""];
            if([keyStrLen isKindOfClass:[NSString class]]) longestKey = MAX(longestKey, [(NSString *)keyStrLen length]);
            i++;
        }
    }
    longestKey += 4;
    NSMutableString *s = [[NSMutableString stringWithString:@""] retain];
    NSString *longestTxt = nil;
    NSArray *lineBrks = nil;
    int longestLine = 20;
    int longestLineNum = -1;
    int lineNum = 1;
    for (int i = 0; i < _objs.count; i++)
    {
        id key = [_objs objectAtIndex:i];
        BOOL hasNextIndex = _objs.count > i+1;
        id value = hasNextIndex ? [_objs objectAtIndex:i+1] : nil;
        if(debug) DLog(@"\t Key/value: %@", [key isKindOfClass:[NSString class]]? key : [key class]);
        if([key isKindOfClass:[NSString class]] && [key isEqualToString:SKP])
        {
            NSString *firstValue = @"\n";
            if(value && [value isKindOfClass:[NSString class]] && [value isEqualToString:@""])
            {
                value = nil;
            }
            else  if(value && [value isKindOfClass:[NSString class]] && [value isEqualToString:@" "])
            {
                firstValue = @"\n";
                value = nil;
            }
            else if(value && [value isKindOfClass:[NSString class]] && [value hasPrefix:kBGPrefix])
            {
                firstValue = @"\n";
            }
            
            else if(value)
            {
                firstValue = @"";
            }
            [s appendFormat:@"%@%@", firstValue,  value ? value : @" "];
        }
        else if(![value isKindOfClass:[NSString class]] || ![value isEqualToString:SKP])
        {
            BOOL keyIsNull = [key isKindOfClass:[NSString class]] && [key equals:kNullKey];
            if(value && [value isKindOfClass:[UIView class]]) value = VLLogStr(value);
            else if(([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) || (![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSNumber class]])) value = [value description];
            
            if(value && [value isKindOfClass:[NSString class]] && [value length] && [value containsString:@"\n"])
            {
                value = [value replace:@"\n" with:[NSString format:@"\n%@%@%@", indentStr,keyIsNull?@"": [@" " pad:longestKey use:@" "], keyIsNull ? @"" : @"  "]];
            }
            
            NSString *keyFormat = nil;
            if([key isKindOfClass:[NSString class]] && ![key equals:kNullKey])
            {
                UIColor *hashColor = nil;
                NSString *hash = nil;
                NSString *trimmedKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([trimmedKey hasSuffix:@";"])
                {
                    NSInteger hashStart = [key rangeOfString:@"#" options:NSBackwardsSearch].location;
                    NSInteger hashEnd = [key rangeOfString:@";" options:NSBackwardsSearch].location;
                    NSRange hashRange = NSMakeRange(hashStart, hashEnd-hashStart+1);
                    if(hashStart!=NSNotFound && hashEnd!=NSNotFound && hashEnd-hashStart>1)
                    {
                        hash = [key substringWithRange:hashRange];
                        hashColor = [UIColor string:[hash substringToIndex:hash.length-1]];
                        if(hashColor && [value isKindOfClass:[NSString class]] && [value length])
                        {
                            value = ColorWrap(value, hashColor);
                        }
                    }
                    key = !hash ? key : [[(NSString *)key stringByReplacingCharactersInRange:hashRange withString:@""] suffix:[@" " repeat:hash.length]];
                }
                if([key hasPrefix:@"#"])
                {
                    NSInteger hashEnd = [key rangeOfString:@";"].location;
                    NSRange hashRange = NSMakeRange(NSNotFound, 0);
                    if(hashEnd!=NSNotFound && hashEnd>1)
                    {
                        hash = [key substringToIndex:hashEnd+1];
                        hashRange = NSMakeRange(0, hashEnd+1);
                        hashColor = [UIColor string:[key substringToIndex:hashEnd]];
                    }
                    key = !hash ? key : [[(NSString *)key stringByReplacingCharactersInRange:hashRange withString:@""] suffix:[@" " repeat:hash.length]];
                    keyFormat = !hash || !hashColor ? keyFormat : ColorWrap(key, hashColor);
                }
            }
            key = [key isKindOfClass:[NSString class]] && [key equals:@"^"] ? [@" " repeat:longestKey] :
            value && (([value isKindOfClass:[NSString class]] && [value length]) || ![value isKindOfClass:[NSString class]]) ? [key isKindOfClass:[NSString class]] && ![key equals:kNullKey] ? [key pad:longestKey use:@" "] : key : key;
            
            keyFormat = keyFormat ? keyFormat : [key isKindOfClass:[NSString class]] && [key equals:kNullKey] ? @"" : [NSString format:XCODE_COLORS_ESCAPE LOG_KEY_COLOR @"%@" XCODE_COLORS_RESET_FG, key];
            if((!value || [value length] <= 0) && [keyFormat containsString:@"\n"])
            {
                keyFormat = [[[keyFormat replace:@"\n" with:[NSString format:@"\n  %@", d]] trimSuffix:@"\n"] prefix:@"  "];
            }
            
            NSString *keyValStr = [NSString format:(@"%@" XCODE_COLORS_ESCAPE LOG_VALUE_COLOR "%@%@%@" XCODE_COLORS_RESET_FG), keyFormat,[keyFormat equals:@""] ? @"":@"  ",  value ? value : @"", d];
            NSString *kv2 = [NSString format:@"%@%@%@%@", keyFormat,[keyFormat equals:@""] ? @"":@"  ", value ? value : @"", indentStr];
            if([kv2 containsString:@"\n"])
            {
                lineBrks = [kv2 componentsSeparatedByString:@"\n"];
                for (NSString *brk in lineBrks)
                {
                    kv2 = [brk.cleanString replace:@"\t" with:tab];
                    longestLine = MAX(longestLine, (int)(kv2.length - d.length));
                    if(kv2.length==longestLine) { longestTxt = kv2; longestLineNum = lineNum; }
                }
            }
            else
            {
                kv2 = [kv2.cleanString replace:@"\t" with:tab];
                longestLine = MAX(longestLine, (int)kv2.length);
                if(kv2.length == longestLine) { longestTxt = kv2; longestLineNum = lineNum; }
            }
            [s appendFormat:@"\n%@%@", d, keyValStr];
        }
        i++;
        lineNum++;
    }
    s = LineStrf(s, longestLine, longestKey);
    return wrap ? _BgLogStr([s autorelease], NO, longestLine) : [s autorelease];
#else
    return nil;
#endif
}
void ALLogDebug(NSString *format, id objs)
{
    NSString *l = LLogStrDebug(objs, YES, YES);
    NSString *tabStr = [NSString stringWithFormat:(XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR @"%@" XCODE_COLORS_RESET_BG), [@" " repeat:(format.length + (indentStr.length*2))]];
    format = [NSString stringWithFormat:@"%@\n" XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE LOG_HEADER_FG_COLOR XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR "%@%@%@" XCODE_COLORS_RESET_BG XCODE_COLORS_RESET_FG  @"\n%@", tabStr, indentStr, [format uppercaseString], indentStr,  tabStr];
    DLog(@"%@", [NSString stringWithFormat:@"%@ \n%@\n\n", format, l]);
}
NSString *ALLogStrf(NSString *format, id objs)
{
    NSString *l = LLogStr(objs);
    NSString *tabStr = [NSString stringWithFormat:(XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR @"%@" XCODE_COLORS_RESET_BG), [@" " repeat:(format.length + (indentStr.length*2))]];
    format = [NSString stringWithFormat:@"%@\n" XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE LOG_HEADER_FG_COLOR XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR "%@%@%@" XCODE_COLORS_RESET_BG XCODE_COLORS_RESET_FG  @"\n%@", tabStr, indentStr, [format uppercaseString], indentStr,  tabStr];
    return [NSString stringWithFormat:@"%@ \n%@\n\n", format, l];
}

NSString *ALLogStr(id objs) {
    NSString *l = LLogStr(objs);
    return [NSString stringWithFormat:@"%@", l];
}
void ALLog(NSString *format, NSArray *objs) {
    
#ifdef DEBUG
    @try {
        NSString *l = LLogStr(objs);
        NSString *tabStr = [NSString stringWithFormat:(XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR @"%@" XCODE_COLORS_RESET_BG), [@" " repeat:(format.lengthVisible + (indentStr.length*2))]];
        format = [NSString stringWithFormat:@"%@\n" XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE LOG_HEADER_FG_COLOR XCODE_COLORS_ESCAPE LOG_HEADER_BG_COLOR "%@%@%@" XCODE_COLORS_RESET_BG XCODE_COLORS_RESET_FG  @"\n%@", tabStr, indentStr, [format uppercaseString], indentStr,  tabStr];
        DLog( @"%@" @"%@%@", format, [l hasPrefix:@"\n"] ? @"" : @"\n", l);
    }
    @catch (NSException *exception) {
        @try {
            DLogError(@"There was an error with ALLog:  %@", exception.reason);
            NSString *l = LLogStrDebug(objs, YES, YES);
        }
        @catch (NSException *exception2)
        {
            
        }
    }
    
#endif
}


BOOL isnanOrZero(float n) { return isnan(n) ? YES : n == 0 ? YES : NO; }
float MysticMatrix4x4Sum(MysticMatrix4x4 matrix)
{
    float sum = matrix.one.one + matrix.one.two + matrix.one.three + matrix.one.four +
    matrix.two.one + matrix.two.two + matrix.two.three + matrix.two.four +
    matrix.three.one + matrix.three.two + matrix.three.three + matrix.three.four +
    matrix.four.one + matrix.four.two + matrix.four.three + matrix.four.four;
    return sum;
}


static void dumpAllFonts() {
    for (NSString *familyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"%@", fontName);
        }
    }
}
#import <dlfcn.h>

// includer for font




NSUInteger loadFonts( )
{
    NSUInteger newFontCount = 0;
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.GraphicsServices"];
    const char *frameworkPath = [[frameworkBundle executablePath] UTF8String];
    
    if (frameworkPath)
    {
        void *graphicsServices = dlopen(frameworkPath, RTLD_NOLOAD | RTLD_LAZY);
        
        if (graphicsServices)
        {
            BOOL (*GSFontAddFromFile)(const char *) = dlsym(graphicsServices, "GSFontAddFromFile");
            
            if (GSFontAddFromFile)
            {
                
                BOOL verizon = NO;
                
                //                NSLog(@"%@",[[UIDevice currentDevice] machine]);
                
                if ([[[UIDevice currentDevice] machine] rangeOfString:@"iPhone3,3"].location != NSNotFound) {
                    verizon = YES;
                }
                
                for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:@"Fonts"])
                {
                    if ([fontFile rangeOfString:@"_"].location != NSNotFound && verizon) {
                        newFontCount += GSFontAddFromFile([fontFile UTF8String]);
                    }
                    
                    if ([fontFile rangeOfString:@"-"].location != NSNotFound && !verizon) {
                        newFontCount += GSFontAddFromFile([fontFile UTF8String]);
                    }
                    
                }
                
                for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"otf" inDirectory:@"Fonts"])
                {
                    if ([fontFile rangeOfString:@"_"].location != NSNotFound && verizon) {
                        newFontCount += GSFontAddFromFile([fontFile UTF8String]);
                    }
                    
                    if ([fontFile rangeOfString:@"-"].location != NSNotFound && !verizon) {
                        newFontCount += GSFontAddFromFile([fontFile UTF8String]);
                    }
                    
                }
                
            }
        }
        
    }
    
    
    
    return newFontCount;
}
BOOL MysticShaderIndexEqualToIndex(MysticShaderIndex index1, MysticShaderIndex index2)
{
    return (index1.stackIndex == index2.stackIndex
            && index1.index == index2.index
            && index1.previousIndex == index2.previousIndex
            && index1.count == index2.count
            && index1.offset == index2.offset);
    
}
BOOL MysticShaderIndexIsUnknown(MysticShaderIndex index)
{
    return MysticShaderIndexEqualToIndex(index, MysticShaderIndexUnknown);
}
MysticShaderIndex MysticShaderIndexWith(MysticShaderIndex index)
{
    return (MysticShaderIndex){index.stackIndex,index.index,index.count,index.previousIndex,index.offset};
}
MysticShaderIndex MysticShaderIndexWithStackIndex(MysticShaderIndex index, NSInteger i)
{
    return (MysticShaderIndex){i,index.index,index.count,index.previousIndex,index.offset};
}
MysticShaderIndex MysticShaderIndexWithIndex(MysticShaderIndex index, NSInteger i)
{
    return (MysticShaderIndex){index.stackIndex,i,index.count,index.previousIndex,index.offset};
}

CGPoint snapToPoint(CGRect frame, CGRect bounds, MysticSnapPosition positions, CGFloat paddingOffset)
{
    CGPoint p2 = frame.origin;
    CGPoint center = CGPointMake(frame.size.width/2 + frame.origin.x, frame.size.height/2 + frame.origin.y);
    CGPoint boundsCenter = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    BOOL snapped = NO;
    if(positions & MysticSnapPositionAll || positions & MysticSnapPositionCenters || positions & MysticSnapPositionCenter)
    {
        
        CGRect boundsCenterRect = CGRectMake(boundsCenter.x - paddingOffset, boundsCenter.y - paddingOffset, paddingOffset*2, paddingOffset*2);
        if(CGRectContainsPoint(boundsCenterRect, center))
        {
            snapped = YES;
            p2 = CGPointMake(boundsCenter.x - (frame.size.width/2), boundsCenter.y - (frame.size.height/2));
        }
        
    }
    
    if(!snapped)
    {
        if(positions & MysticSnapPositionAll || positions & MysticSnapPositionCenters || positions & MysticSnapPositionCenterHorizontal)
        {
            CGRect snapRect = CGRectMake(0, boundsCenter.y - paddingOffset, bounds.size.width, paddingOffset*2);
            if(CGRectContainsPoint(snapRect, center))
            {
                p2.y = boundsCenter.y - frame.size.height/2;
                center.y = boundsCenter.y;
            }
        }
        
        if(positions & MysticSnapPositionAll || positions & MysticSnapPositionCenters || positions & MysticSnapPositionCenterVertical)
        {
            CGRect snapRect = CGRectMake(boundsCenter.x - paddingOffset, 0, paddingOffset*2, bounds.size.height);
            if(CGRectContainsPoint(snapRect, center))
            {
                p2.x = boundsCenter.x - frame.size.width/2;
                center.x = boundsCenter.x;
            }
        }
        
        if(positions & MysticSnapPositionAll || positions & MysticSnapPositionBounds)
        {
            if(p2.x > -paddingOffset && p2.x < paddingOffset)
            {
                p2.x = 0;
            }
            else if(p2.x + frame.size.width > bounds.size.width-paddingOffset && p2.x + frame.size.width < bounds.size.width+paddingOffset)
            {
                
                p2.x = bounds.size.width- frame.size.width;
            }
            //
            if(p2.y > -paddingOffset && p2.y < paddingOffset)
            {
                p2.y = 0;
            }
            else if(p2.y + frame.size.height > bounds.size.height-paddingOffset && p2.y + frame.size.height < bounds.size.height+paddingOffset)
            {
                p2.y = bounds.size.height- frame.size.height;
            }
            //
            
            //
            
            
        }
    }
    
    return p2;
}
void MBord(id view)
{
    MBorder(view, nil, 1);
}
void MBorder(id v, id color, CGFloat borderWidth)
{
    if(!v) return;
    NSArray *vs = [v isKindOfClass:[NSArray class]] ? v : @[v];
    UIColor *color2 = color ? [MysticColor color:color] : (borderWidth > 0 ? [UIColor red] : nil);
    for (UIView *view in vs) {
        view.layer.borderColor = borderWidth > 0 && color2 ? color2.CGColor : nil;
        view.layer.borderWidth = borderWidth;
    }
    
}
BOOL MysticObjectHasAutoLayer (id opt)
{
    PackPotionOption *option = opt;
    if(!option) return NO;
    //    if([option respondsToSelector:@selector(usesAutoLayer)]) return [option usesAutoLayer];
    switch (option.type) {
        case MysticObjectTypeFont:
        case MysticObjectTypeShape:
            //        case MysticObjectTypeSetting:
            //        case MysticObjectTypeSourceSetting:
        {
            return NO;
        }
        default: break;
    }
    return NO;
}
NSInteger MysticBuildNumber()
{
    NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    
    if(build)
    {
        return (NSInteger)[build integerValue];
    }
    return 0;
    
}
BOOL MysticBrushIsDefault(MysticBrush brush)
{
    return MysticBrushEquals(brush, MysticBrushDefault);
}

BOOL MysticBrushEquals(MysticBrush brush, MysticBrush brush2)
{
    return brush.feather!=brush2.feather||brush.size!=brush2.size||brush2.opacity!=brush.opacity||brush.type!=brush2.type;
}
BOOL CGPointIsZero(CGPoint point)
{
    return CGPointEqualToPoint(point, CGPointZero);
}
BOOL CGRectIsTall(CGRect rect)
{
    return CGSizeIsTall(rect.size);
}
BOOL CGRectIsWide(CGRect rect)
{
    return CGSizeIsWide(rect.size);
}
BOOL CGRectIsZero(CGRect rect)
{
    return CGRectEqualToRect(rect, CGRectZero);
}
BOOL CGSizeIsZero(CGSize size)
{
    return CGSizeEqualToSize(size, CGSizeZero);
}

float CGSizeBiggestPercentDifference(CGSize s1, CGSize s2)
{
    CGFloat lw = MIN(s1.width, s2.width);
    CGFloat hw = lw == s1.width ? s2.width : s1.width;
    CGFloat lh = MIN(s1.height, s2.height);
    CGFloat hh = lw == s1.height ? s2.height : s1.height;
    return MIN(lw/hw,lh/hh);
}

CGSize CGSizePercentDifference(CGSize s1, CGSize s2)
{
    CGFloat lw = MIN(s1.width, s2.width);
    CGFloat hw = lw == s1.width ? s2.width : s1.width;
    CGFloat lh = MIN(s1.height, s2.height);
    CGFloat hh = lw == s1.height ? s2.height : s1.height;
    return CGSizeMake(lw/hw,lh/hh);
}

float CGSizeSmallestPercentDifference(CGSize s1, CGSize s2)
{
    CGFloat lw = MIN(s1.width, s2.width);
    CGFloat hw = lw == s1.width ? s2.width : s1.width;
    CGFloat lh = MIN(s1.height, s2.height);
    CGFloat hh = lw == s1.height ? s2.height : s1.height;
    return MAX(lw/hw,lh/hh);
}

NSString *DOCS_PATH(NSString *filename)
{
    NSURL *dirURL = (NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [dirURL URLByAppendingPathComponent:filename].absoluteString;
}
NSString *MysticContentModeToString(UIViewContentMode cmode)
{
    NSString *cModeString = @"---";
    switch (cmode) {
        case UIViewContentModeScaleAspectFill:
            cModeString = @"UIViewContentModeScaleAspectFill";
            break;
        case UIViewContentModeCenter:
            cModeString = @"UIViewContentModeCenter";
            break;
        case UIViewContentModeScaleAspectFit:
            cModeString = @"UIViewContentModeScaleAspectFit";
            break;
        case UIViewContentModeTop:
            cModeString = @"UIViewContentModeTop";
            break;
        case UIViewContentModeTopLeft:
            cModeString = @"UIViewContentModeTopLeft";
            break;
        case UIViewContentModeTopRight:
            cModeString = @"UIViewContentModeTopRight";
            break;
        case UIViewContentModeRight:
            cModeString = @"UIViewContentModeRight";
            break;
        case UIViewContentModeLeft:
            cModeString = @"UIViewContentModeLeft";
            break;
        case UIViewContentModeScaleToFill:
            cModeString = @"UIViewContentModeScaleToFill";
            break;
        case UIViewContentModeBottom:
            cModeString = @"UIViewContentModeBottom";
            break;
        case UIViewContentModeBottomLeft:
            cModeString = @"UIViewContentModeBottomLeft";
            break;
        case UIViewContentModeBottomRight:
            cModeString = @"UIViewContentModeBottomRight";
            break;
        case UIViewContentModeRedraw:
            cModeString = @"UIViewContentModeRedraw";
            break;
            
        default: break;
    }
    
    return cModeString;
}
CGRect SetBounds(UIView *view, CGRect bounds, CGPoint center)
{
    if(!CGRectUnknownOrZero(bounds) && !CGRectEqual(bounds, view.bounds)) view.bounds = CGRectz(bounds);
    if(!CGPointIsUnknown(center) && !CGPointEqual(center, view.center)) view.center = center;
    return view.frame;
}
UIEdgeInsets UIEdgeInsetsRectDiff(CGRect r, CGRect r2)
{
    return UIEdgeInsetsMakeWithSize(CGSizeScale(CGRectDiff(r, r2).size, 0.5));
}
UIEdgeInsets UIEdgeInsetsInverse(UIEdgeInsets insets)
{
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}
UIEdgeInsets UIEdgeInsetsScale(UIEdgeInsets ins, CGScale scale)
{
    if(CGScaleIsEqual(scale)) return ins;
    UIEdgeInsets i = UIEdgeInsetsCopy(ins);
    i.top *= scale.height;
    i.bottom *= scale.height;
    i.left *= scale.width;
    i.right *= scale.height;
    return i;
}
CGRect UIEdgeInsetsOffsetRect(CGRect frame, UIEdgeInsets insets)
{
    return UIEdgeInsetsInsetRect(frame, UIEdgeInsetsInverse(insets));
}
CGPoint CGPointMidPoint(CGPoint p1,CGPoint p2)
{
    return CGPointMake ((p1.x + p2.x) * 0.5,(p1.y + p2.y) * 0.5);
}
CGPoint CGPointMid(CGRect r)
{
    return (CGPoint){r.size.width/2 + r.origin.x,r.size.height/2+r.origin.y};
    
}
CGPoint CGPointCenter(CGRect r)
{
    return (CGPoint){r.size.width/2,r.size.height/2};
}
BOOL CGPointUnknownOrZero(CGPoint p)
{
    return CGPointEqualToPoint(p, CGPointUnknown) || CGPointEqualToPoint(p, CGPointZero);
}
BOOL CGPointIsUnknown(CGPoint p)
{
    return CGPointEqualToPoint(p, CGPointUnknown);
}
BOOL CGPointEqual(CGPoint p, CGPoint p2)
{
    return CGPointEqualToPoint(p, p2);
}
BOOL CGRectSizeEqual(CGRect r, CGRect r2)
{
    return CGSizeEqualToSize(r.size, r2.size);
}
BOOL CGRectEqual(CGRect r, CGRect r2)
{
    return CGRectEqualToRect(r, r2);
}
BOOL CGRectEqualOrZero(CGRect r, CGRect r2)
{
    return CGRectEqual(r, r2) || CGRectIsZero(r) || CGRectIsZero(r2);
}
CGRect PathRect(UIBezierPath *p)
{
    return PathBoundingBox(p);
}
CGRect CGRectInt(CGRect r)
{
    return CGRectIntegral(r);
}
CGRect InsetRect(CGRect r, UIEdgeInsets i)
{
    return UIEdgeInsetsInsetRect(r, i);
}
CGRect CGRectTransform(CGRect rect, CGAffineTransform t)
{
    return CGRectApplyAffineTransform(rect, t);
}
CGRect CGRectSizeInset(CGRect rect, CGFloat x, CGFloat y)
{
    CGRect r = CGRectInset(rect, x, y);
    r.origin = rect.origin;
    return r;
}
CGRect CGRectCenterAround(CGRect rect, CGRect bounds)
{
    CGPoint c = (CGPoint){bounds.origin.x + (bounds.size.width/2), bounds.origin.y + (bounds.size.height/2)};
    return CGRectWithCenter(rect, c);
}

CGRect CGRectCenter(CGRect rect, CGRect bounds)
{
    return CGRectWithContentMode(rect, bounds, UIViewContentModeCenter);
}
CGRect CGRectWithContentMode(CGRect rect, CGRect bounds, UIViewContentMode contentMode)
{
    CGRect newRect = rect;
    switch (contentMode) {
        case UIViewContentModeBottom:
        {
            break;
        }
        case UIViewContentModeBottomLeft:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionBottomLeft);
            break;
        }
        case UIViewContentModeBottomRight:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionBottomRight);
            break;
        }
        case UIViewContentModeCenter:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionCenter);
            break;
        }
        case UIViewContentModeLeft:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionLeft);
            break;
        }
        case UIViewContentModeRight:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionRight);
            break;
        }
        case UIViewContentModeTop:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionTop);
            break;
        }
        case UIViewContentModeTopLeft:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionTopLeft);
            break;
        }
        case UIViewContentModeTopRight:
        {
            newRect = MysticPositionRect(rect, bounds, MysticPositionTopRight);
            break;
        }
        case UIViewContentModeScaleAspectFill:
        {
            newRect = CGRectAspectFill(rect, bounds);
            break;
        }
        case UIViewContentModeScaleAspectFit:
        {
            newRect = CGRectFit(rect, bounds);
            break;
        }
        case UIViewContentModeScaleToFill:
        {
            newRect = bounds;
            
            
            
            break;
        }
            
        default: break;
    }
    return newRect;
}

//CGRect CGRectAspectFill(CGRect rect, CGRect bounds)
//{
//    CGRect newRect = rect;
//    if(bounds.size.width > bounds.size.height)
//    {
//        if(rect.size.width > rect.size.height)
//        {
//            newRect.size.height = bounds.size.height;
//            newRect.size.width = rect.size.width * (bounds.size.height/rect.size.height);
//        }
//        else
//        {
//            newRect.size.width = bounds.size.width;
//            newRect.size.height = rect.size.height * (bounds.size.width/rect.size.width);
//        }
//    }
//    else
//    {
//        if(rect.size.width > rect.size.height)
//        {
//            newRect.size.height = bounds.size.height;
//            newRect.size.width = rect.size.width * (bounds.size.height/rect.size.height);
//        }
//        else
//        {
//            newRect.size.width = bounds.size.width;
//            newRect.size.height = rect.size.height * (bounds.size.width/rect.size.width);
//        }
//    }
//    
//    newRect = MysticPositionRect(newRect, bounds, MysticPositionCenter);
//    return newRect;
//}
BOOL isIndexOf(NSInteger i, NSArray *v)
{
    return !(!v || v.count<1 || i==NSNotFound||i>=v.count||i<0);
}
NSString *ExceptionString(NSException *exception)
{
    NSMutableString *s = [NSMutableString stringWithString:exception.reason];
    [s appendFormat:@"\n%@", CallBackStackString(exception)];
    return s;
}
NSString *CallBackStackString(NSException *exception)
{
    NSMutableString *c = [NSMutableString string];
    for (NSString *s in exception.callStackSymbols) [c appendFormat:@"     %@\n",s];
    return (NSString *)c;
}
CGRect CGRectAspectFill(CGRect rect, CGRect bounds)
{
    CGRect newRect = rect;
    if(bounds.size.width > bounds.size.height)
    {
        if(rect.size.width > rect.size.height)
        {
            newRect.size.height = bounds.size.height;
            newRect.size.width = rect.size.width * (newRect.size.height/rect.size.height);
//            newRect.size.width = rect.size.width * (bounds.size.height/rect.size.height);
            
            
        }
        else
        {
            newRect.size.width = bounds.size.width;
            newRect.size.height = rect.size.height * (newRect.size.width/rect.size.width);

//            newRect.size.height = rect.size.height * (bounds.size.width/rect.size.width);
            
        }
        
        
    }
    else
    {
        if(rect.size.width > rect.size.height)
        {
            newRect.size.height = bounds.size.height;
            newRect.size.width = rect.size.width * (newRect.size.height/rect.size.height);
//            newRect.size.width = rect.size.width * (bounds.size.height/rect.size.height);
        }
        else
        {
            newRect.size.width = bounds.size.width;
            newRect.size.height = rect.size.height * (newRect.size.width/rect.size.width);
//            newRect.size.height = rect.size.height * (bounds.size.width/rect.size.width);
        }
    }
    if(newRect.size.width < bounds.size.width)
    {
        CGRect newr = newRect;
        newr.size.width = bounds.size.width;
        newr.size.height = (newr.size.width * rect.size.height)/rect.size.width;
        newRect = newr;
    }
    else if(newRect.size.height < bounds.size.height)
    {
        CGRect newr = newRect;
        newr.size.height = bounds.size.height;
        newr.size.width = (newr.size.height * rect.size.width)/rect.size.height;
        newRect = newr;
    }
    return MysticPositionRect(newRect, bounds, MysticPositionCenter);
}
float floatRoundedDown(float n, int decimals)
{
    if(decimals < 1) return floorf(n);
    float power = 1.f;
    
    while (decimals > 0) {
        power = power *10.f;
        decimals-=1;
        
    }
    return floorf(n * power) / power;
}
float floatRoundedUp(float n, int decimals)
{
    if(decimals < 1) return ceilf(n);
    float power = 1.f;
    
    while (decimals > 0) {
        power = power *10.f;
        decimals-=1;
        
    }
    return ceilf(n * power) / power;
}
float floatToNearest(float n, int decimals)
{
    if(decimals < 1) return n;
    float power = 1.f;
    
    while (decimals > 0) {
        power = power *10.f;
        decimals-=1;
    }
    return floorf(n * power + 0.5f) / power;
}
CGFloat CGSizeMaxWH(CGSize size)
{
    return MAX(size.width, size.height);
}
CGFloat CGSizeMinWH(CGSize size)
{
    return MIN(size.width, size.height);
}
CGSize CGSizeScaleDown(CGSize size, float scale)
{
    CGSize newsize = size;
    scale = scale == 0.0f ? [Mystic scale] : scale;
    
    if(scale != 1)
    {
        newsize.width = size.width/scale;
        newsize.height = size.height/scale;
    }
    
    return newsize;
}
CGSize CGSizeConstrain(CGSize size, CGSize maxSize)
{
    if(!CGSizeGreater(size, maxSize)) return size;
    CGSize newSize = maxSize;
    if(size.width < size.height)
    {
        newSize.height = maxSize.height;
        newSize.width = (maxSize.height*size.width)/size.height;
    }
    else
    {
        newSize.width = maxSize.width;
        newSize.height = (maxSize.width*size.height)/size.width;
    }
    return newSize;
}
CGSize CGSizeScaleWithSize(CGSize size, CGSize scale)
{
    CGSize s = size;
    s.width *= scale.width;
    s.height *= scale.height;
    return s;
}
CGSize CGSizeScaleWithScale(CGSize size, CGScale scale)
{
    return CGSizeScaleWithSize(size, scale.size);
}
CGSize CGSizeInverseScaleWithSize(CGSize size, CGSize scale)
{
    CGSize s = size;
    s.width = 1/scale.width;
    s.height = 1/scale.height;
    return s;
}
CGSizeRatio CGSizeRatioMake(CGSize size)
{
    CGSizeRatio r = {0,0,0,MysticSizeTypeNone};
    r.width = size.width;
    r.height = size.height;
    r.ratio = CGSizeRatioOf(size);
    r.type = size.width > size.width ? MysticSizeTypeWidth : MysticSizeTypeHeight;
    return r;
}
CGSizes CGSizesMake(CGSize size1, CGSize size2)
{
    CGSizes s;
    s.first = CGSizeRatioMake(size1);
    s.second = CGSizeRatioMake(size2);
    BOOL lt = CGSizeLess(size1, size2);
    s.big = lt ? s.second : s.first;
    s.small = lt ? s.first : s.second;
    return s;
}

CGSize CGAffineTransformToSize(CGAffineTransform trans)
{
    return (CGSize){trans.a, trans.d};
}
BOOL CGSizeEqualToSizeEnough(CGSize s1, CGSize s2)
{
    s1.height = floatRoundedDown(s1.height, 2);
    s1.width = floatRoundedDown(s1.width, 2);
    s2.height = floatRoundedDown(s2.height, 2);
    s2.width = floatRoundedDown(s2.width, 2);
    return CGSizeEqualToSize(s1, s2);
}
CGRectRect CGRectsMatchSize(CGRect frame1, CGRect frame2)
{
    CGRect rect1 = frame1;
    CGRect rect2 = frame2;
    
    if(CGSizeGreater(rect1.size, rect2.size))
    {
        rect2.size = CGSizeScaleToSize(rect1.size, rect2.size);
    }
    else
    {
        rect1.size = CGSizeScaleToSize(rect2.size, rect1.size);
    }
    return (CGRectRect){.frame1=rect1,.frame2=rect2,.scale=CGScaleOfRects(rect2, rect1), .originalFrame1=frame1,.originalFrame2=frame2};
}
CGRect CGRectScaleDivide(CGRect rect, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGRect r = CGRectZero;
    r.origin.x = rect.origin.x;
    r.origin.y = rect.origin.y;
    r.size.width = rect.size.width/scale;
    r.size.height = rect.size.height/scale;
    return r;
}
CGRect CGRectScale(CGRect rect, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGRect r = CGRectZero;
    r.origin.x = rect.origin.x * scale;
    r.origin.y = rect.origin.y*scale;
    r.size.width = rect.size.width*scale;
    r.size.height = rect.size.height*scale;
    return r;
}
CGRect CGRectInverseScale(CGRect rect, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGRect r = CGRectZero;
    r.origin.x = rect.origin.x / scale;
    r.origin.y = rect.origin.y/scale;
    r.size.width = rect.size.width/scale;
    r.size.height = rect.size.height/scale;
    return r;
}
CGSize CGSizeScale(CGSize size, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGSize s = CGSizeZero;
    
    s.width = size.width*scale;
    s.height = size.height*scale;
    return s;
}
CGSize CGSizeInverseScale(CGSize size, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGSize s = CGSizeZero;
    
    s.width = size.width/scale;
    s.height = size.height/scale;
    return s;
}
CGFloat CGPointAngleFromCenter(CGPoint startingPoint,CGPoint endingPoint, CGPoint center)
{
    CGPoint originPoint = CGPointDiff(endingPoint, startingPoint);
    float bearingRadians = atan2f(originPoint.y-center.y, originPoint.x-center.x); // get bearing in radians
    return bearingRadians;
}
CGFloat CGPointAngle(CGPoint startingPoint,CGPoint endingPoint)
{
    CGPoint originPoint = CGPointDiff(endingPoint, startingPoint);
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    return bearingRadians;
    //    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    //    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    //    return RadiansFromDegrees(bearingDegrees);
}

CGPoint CGPointScale(CGPoint point, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGPoint s = point;
    
    s.x = s.x*scale;
    s.y = s.y*scale;
    return s;
}
CGPoint CGPointInverseScale(CGPoint point, CGFloat scale)
{
    scale = scale == 0 ? [Mystic scale] : scale;
    CGPoint s = point;
    
    s.x = s.x/scale;
    s.y = s.y/scale;
    return s;
}
CGRect CGRectFitSquare(CGRect fit, CGRect bounds)
{
    return CGRectFit(fit, CGRectSize(CGSizeSquare(bounds.size)));
}
CGRect CGRectUnfit(CGRect rect)
{
    CGRect unfit = rect;
    
    unfit.origin = CGPointZero;
    if(rect.origin.y != 0 && fabs(rect.origin.y) > 0.5)
    {
        unfit.size.width = rect.size.height;
        unfit.size.height = (unfit.size.width*rect.size.height)/rect.size.width;
        unfit.size.width = rect.size.width;
    }
    else if(rect.origin.x != 0 && fabs(rect.origin.x) > 0.5)
    {
        unfit.size.height = rect.size.width;
        unfit.size.width = unfit.size.height*rect.size.width/rect.size.height;
        unfit.size.height = rect.size.height;
        
    }
    
    return unfit;
}
CGRect CGRectFit(CGRect rect, CGRect bounds)
{
    CGFloat originalAspectRatio = rect.size.width / rect.size.height;
    CGFloat maxAspectRatio = bounds.size.width / bounds.size.height;
    CGRect newRect = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    if (originalAspectRatio > maxAspectRatio) {
        newRect.size.height = bounds.size.width * (rect.size.height / rect.size.width);
        newRect.origin.y += (bounds.size.height - newRect.size.height) / 2.0;
    } else {
        newRect.size.width = bounds.size.height * originalAspectRatio;
        newRect.origin.x += (bounds.size.width - newRect.size.width) / 2.0;
    }
    return newRect;
}
//CGSize _SizeScaleByFactor(CGSize aSize, CGFloat factor)
//{
//    return CGSizeMake(aSize.width * factor, aSize.height * factor);
//}
//CGRect _RectAroundCenter(CGPoint center, CGSize size)
//{
//    CGFloat halfWidth = size.width / 2.0f;
//    CGFloat halfHeight = size.height / 2.0f;
//
//    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
//}
//CGFloat _AspectScaleFit(CGSize sourceSize, CGRect destRect)
//{
//    CGSize destSize = destRect.size;
//    CGFloat scaleW = destSize.width / sourceSize.width;
//    CGFloat scaleH = destSize.height / sourceSize.height;
//    return fmin(scaleW, scaleH);
//}
//
//CGRect CGRectFit(CGRect sourceRect, CGRect destinationRect)
//{
//    CGFloat aspect = _AspectScaleFit(sourceRect.size, destinationRect);
//    CGSize targetSize = _SizeScaleByFactor(sourceRect.size, aspect);
//    return _RectAroundCenter(RectGetCenter(destinationRect), targetSize);
//}




BOOL MysticColorIsEmpty(MysticColorType color)
{
    switch (color) {
        case MysticColorTypeNone:
        case MysticColorTypeUnknown:
            return YES;
            
            
        default: break;
    }
    return NO;
}

CGRect MysticTranslateRectFromAnchor(MysticPosition anchor, CGRect oldBounds, CGRect bounds, CGRect rect)
{
    if(CGRectEqualToRect(oldBounds, bounds)) return rect;
    CGRect newrect = rect;
    
    if(anchor & MysticPositionBottom)
    {
        CGFloat dy = oldBounds.size.height - rect.origin.y;
        CGFloat ny = bounds.size.height - dy;
        newrect.origin.y = ny;
    }
    
    return newrect;
}

id Mor(id obj, id obj2)
{
    return obj ? obj : obj2;
}

id Mord(id obj, id obj2, id def)
{
    return obj ? obj : (obj2 ? obj2 : def);
}

NSDictionary * MysticAttributedStringThatFits(CGSize targetSize, MysticAttrString *attrStr, MysticDrawingContext **_context)
{
    MysticDrawingContext *context = *_context;
    CGSize minimumRatio = context.minimumRatio;
    MysticSizeOptions options = context.sizeOptions;
    NSDictionary *outInfo = nil;
    CGSize textSize = attrStr.size;
    CGSize textSize2 = [attrStr.string sizeWithAttributes:[attrStr attributesAtIndex:0 effectiveRange:NULL]];
    CGSize p = CGSizePercentDifference(targetSize, textSize);
    NSDictionary *attr = [attrStr attributesAtIndex:0 effectiveRange:NULL];
    NSString *attrText = attrStr.string;
    UIFont *attrFont = [attr objectForKey:NSFontAttributeName];
    
    CGFloat fontSize = attrFont.pointSize;
    CGFloat fontSizeStart = fontSize;
    CGSize finalFontScaleFactor = CGSizeZero;
    //    CGSize startFontScaleFactor = CGSizeZero;
    
    MysticAttrString *attrStrScaled = attrStr;
    CGSize scaledTargetSize = targetSize;
    CGSize scaledMaxTargetSize = context && !CGSizeIsZero(context.maxTargetSize) ? context.maxTargetSize : CGSizeZero;
    BOOL maxHeight = scaledTargetSize.height == CGFLOAT_MAX;
    BOOL maxWidth = scaledTargetSize.width == CGFLOAT_MAX;
    
    if(context.targetScale != 1)
    {
        scaledTargetSize = CGSizeScale(scaledTargetSize, context.targetScale);
        scaledMaxTargetSize = CGSizeScale(scaledMaxTargetSize, context.targetScale);
        
        attrStrScaled = [MysticAttrString string:attrStr];
        [attrStrScaled scaleFactor:context.fontScaleFactor target:scaledTargetSize];
    }
    
    scaledTargetSize.height = maxHeight ? CGFLOAT_MAX : scaledTargetSize.height;
    scaledTargetSize.width = maxWidth ? CGFLOAT_MAX : scaledTargetSize.width;
    
    
    if(context.adjustContentSizeToFit && (p.width < minimumRatio.width || p.height < minimumRatio.height))
    {
        CGSize initialSize = [attrText sizeWithAttributes:attr];
        
        NSMutableDictionary *_info = [NSMutableDictionary dictionaryWithDictionary:@{@"ratio": [NSValue valueWithCGSize:p],
                                                                                     @"string": MNull(attrStr),
                                                                                     @"attributes": MNull(attr),
                                                                                     @"size": [NSValue valueWithCGSize:initialSize],
                                                                                     
                                                                                     }];
        
        NSMutableDictionary *attr2 = [NSMutableDictionary dictionary];
        [attr2 addEntriesFromDictionary:attr];
        if(!attrFont) return _info;
        
        int w = 0;
        if(options & MysticSizeOptionNone || (options & MysticSizeOptionMatchHeight && options & MysticSizeOptionMatchWidth))
        {
            w = 0;
        }
        else if(options & MysticSizeOptionMatchGreatest)
        {
            w = p.width > p.height ? 1 : 2;
        }
        else if(options & MysticSizeOptionMatchLeast)
        {
            w = p.width < p.height ? 1 : 2;
        }
        else if(options & MysticSizeOptionMatchWidth)
        {
            w = 1;
        }
        else if(options & MysticSizeOptionMatchHeight)
        {
            w = 2;
        }
        
        CGFloat ts = w == 1 ? targetSize.width : targetSize.height;
        
        int b = 0;
        
        BOOL greater = w == 1 ? initialSize.height > targetSize.height : initialSize.width > targetSize.width;
        BOOL less = w == 1 ? initialSize.height < targetSize.height : initialSize.width < targetSize.width;
        BOOL resize = (greater && fontSize > 0) || less;
        
        NSMutableDictionary *info = nil;
        if(resize && w != 0)
        {
            info = [NSMutableDictionary dictionaryWithDictionary:@{@"ratio": [NSValue valueWithCGSize:p],
                                                                   @"string": MNull(attrStr),
                                                                   @"attributes": MNull(attr),
                                                                   @"size": [NSValue valueWithCGSize:initialSize],
                                                                   }];
            
            CGFloat fontSizeStop = fontSize;
            CGSize startSize = initialSize;
            CGFloat fontChange = ABS( context.fontSizePointFactor == 0 ? context.fontSizeScaleFactor * fontSizeStart : context.fontSizePointFactor);
            fontChange = fontChange > 0 ? fontChange : 0.5;
            CGFloat ns = w == 1 ? startSize.width : startSize.height;
            
            //            startFontScaleFactor.width = fontSizeStart/(w == 1 ? startSize.width : startSize.height);
            //            startFontScaleFactor.height = fontSizeStart/(w == 1 ? startSize.height : startSize.width);
            //
            
            if(context.autoScaleFont)
            {
                b = 3;
                CGFloat diff = w==1 ? startSize.width/targetSize.width : startSize.height/targetSize.height;
                
                NSMutableDictionary *guessAttr = [NSMutableDictionary dictionary];
                [guessAttr addEntriesFromDictionary:attr2];
                
                CGFloat fontGuess = (fontSizeStart * ts)/ ns;
                
                
                
                
                
                [guessAttr setObject:[attrFont fontWithSize:fontGuess] forKey:NSFontAttributeName];
                CGSize guessSize  = [attrText sizeWithAttributes:guessAttr];
                
                fontSize = fontGuess;
                initialSize = guessSize;
                CGFloat is = w == 1 ? initialSize.width : initialSize.height;
                CGFloat is2 = w == 1 ? initialSize.height : initialSize.width;
                attr2 = guessAttr;
                
                
                finalFontScaleFactor.width = fontGuess/(w == 1 ? initialSize.width : initialSize.height);
                finalFontScaleFactor.height = fontGuess/(w == 1 ? initialSize.height : initialSize.width);
                
                
                [info setObject:MNull(attr2) forKey:@"attributes"];
                [info setObject:[NSValue valueWithCGSize:initialSize] forKey:@"size"];
                
                
            }
            else
            {
                if(greater)
                {
                    b = 1;
                    while ( greater && fontSize > 0) {
                        fontSize -= fontChange;
                        fontSizeStop = fontSize;
                        [attr2 setObject:[attrFont fontWithSize:fontSize] forKey:NSFontAttributeName];
                        initialSize = [attrText sizeWithAttributes:attr2];
                        greater = w == 2 ? initialSize.height > targetSize.height : initialSize.width > targetSize.width;
                    }
                    fontSize = fontSize+fontChange;
                    
                    [attr2 setObject:[attrFont fontWithSize:fontSize] forKey:NSFontAttributeName];
                    [info setObject:MNull(attr2) forKey:@"attributes"];
                    [info setObject:[NSValue valueWithCGSize:initialSize] forKey:@"size"];
                }
                else
                {
                    b = 2;
                    while ( less) {
                        fontSize += fontChange;
                        fontSizeStop = fontSize;
                        [attr2 setObject:[attrFont fontWithSize:fontSize] forKey:NSFontAttributeName];
                        initialSize = [attrText sizeWithAttributes:attr2];
                        less = w == 2 ? initialSize.height < targetSize.height : initialSize.width < targetSize.width;
                    }
                    fontSize = fontSize-fontChange;
                    [attr2 setObject:[attrFont fontWithSize:fontSize] forKey:NSFontAttributeName];
                    
                    [info setObject:MNull(attr2) forKey:@"attributes"];
                    [info setObject:[NSValue valueWithCGSize:initialSize] forKey:@"size"];
                    
                }
            }
            
            
            MysticAttrString *newStr = [MysticAttrString attributedStringWithString:attrText];
            NSRange r = NSMakeRange(0, attrText.length);
            for (id key in attr2.allKeys) {
                [newStr addAttribute:key value:[attr2 objectForKey:key] range:r];
            }
            [info setObject:newStr forKey:@"string"];
            finalFontScaleFactor.width = fontSize/(w == 1 ? initialSize.width : initialSize.height);
            finalFontScaleFactor.height = fontSize/(w == 1 ? initialSize.height : initialSize.width);
            
        }
        
        
        switch (b)
        {
            case 1:
            {
                if(b!=1) break;
                if((w == 1 && initialSize.width < targetSize.width) || initialSize.height < targetSize.height)
                {
                    outInfo = info;
                    break;
                }
            }
            case 2:
            {
                if(b!=2) break;
                if((w == 1 && initialSize.width > targetSize.width) || initialSize.height > targetSize.height)
                {
                    outInfo = info;
                    break;
                }
            }
            case 3:
            {
                if(b!=3) break;
                outInfo = info;
                break;
            }
            default:
            {
                outInfo = _info;
                break;
            }
        }
    }
    else
    {
        
        
        fontSize = attrStrScaled.fontSize;
        CGSize firstTargetSize = CGSizeCeil((CGSize){scaledTargetSize.width, CGFLOAT_MAX});
        context.targetSize = firstTargetSize;
        CGSize finalSize = [attrStrScaled boundingRectWithSize:firstTargetSize options:NSStringDrawingUsesLineFragmentOrigin context:context].size;
        CGSize finalSize2 = [attrStr boundingRectWithSize:firstTargetSize options:NSStringDrawingUsesLineFragmentOrigin context:context].size;
        
        CGSize newMaxTargetSize = CGSizeCeil((CGSize){scaledMaxTargetSize.width, CGFLOAT_MAX});
        
        
        if(context.adjustTargetSize && !CGSizeIsZero(scaledMaxTargetSize) && !CGSizeEqualToSize(firstTargetSize, newMaxTargetSize) && (scaledTargetSize.height == CGFLOAT_MAX || finalSize.height >= (scaledTargetSize.height)))
        {
            MysticDrawingContext *newContext = [MysticDrawingContext context];
            newContext.minimumScaleFactor = 1;
            CGSize os = newContext.targetSize;
            newContext.targetSize = newMaxTargetSize;
            CGSize newFinalSize = [attrStrScaled boundingRectWithSize:newMaxTargetSize options:NSStringDrawingUsesLineFragmentOrigin context:newContext].size;
            finalSize = CGSizeIsZero(newFinalSize) ? finalSize : newFinalSize;
        }
        
        
        
        finalFontScaleFactor.width = fontSize/finalSize.width;
        finalFontScaleFactor.height = fontSize/finalSize.height;
        
        if(context && context.targetScale != 1)
        {
            finalSize = CGSizeInverseScale(finalSize, context.targetScale);
            fontSize = attrStr.fontSize;
        }
        
        outInfo = @{@"ratio": [NSValue valueWithCGSize:(CGSize){1,1}],
                    @"string": MNull(attrStr),
                    @"attributes": MNull(attr),
                    @"size": [NSValue valueWithCGSize:finalSize],
                    };
    }
    
    if(outInfo)
    {
        context.totalSize = outInfo[@"size"] ? [outInfo[@"size"] CGSizeValue] : CGSizeZero;
        context.attributedString = outInfo[@"string"];
        context.attributes = outInfo[@"attributes"];
        context.fontSize = fontSize;
        context.targetSize = targetSize;
        context.fontSizeStart = fontSizeStart;
        context.fontScaleFactor = finalFontScaleFactor;
    }
    return outInfo;
    
    
    
    
}
CGRect CGRectMakeAroundCenter(CGPoint c, CGPoint radius)
{
    CGRect r = CGRectZero;
    r.origin.x = c.x - radius.x;
    r.origin.y = c.y - radius.x;
    r.size.height = radius.x *2;
    r.size.width = radius.y *2;
    return r;
}
CGSize CGSizeCeil(CGSize size)
{
    CGSize s = size;
    s.height = ceilf(s.height);
    s.width = ceilf(s.width);
    return s;
}
CGSize CGSizeFloor(CGSize size)
{
    CGSize s = size;
    s.height = floorf(s.height);
    s.width = floorf(s.width);
    return s;
}
CGRect CGRectSizeCeil(CGRect r)
{
    r.size = CGSizeCeil(r.size);
    return r;
}
CGRect CGRectSizeFloor(CGRect r)
{
    r.size = CGSizeFloor(r.size);
    return r;
}
CGSize CGSizeScaleToSize(CGSize size1, CGSize size2)
{
    CGSize size = size2;
    if(size1.width>size1.height)
    {
        size.width = size1.width;
        size.height = size1.width*size2.height/size2.width;
    }
    else
    {
        size.height = size1.height;
        size.width = size1.height*size2.width/size2.height;
    }
    return size;
}
CGFloat CGRectAtan2(CGRect frame, CGPoint center)
{
    frame = CGRectAroundCenter(frame, center);
    return  atan2(frame.origin.y+frame.size.height - center.y, frame.origin.x+frame.size.width - center.x);
    
}
CGRect CGRectAroundCenter(CGRect rect, CGPoint c)
{
    return (CGRect){c.x-(CGRectW(rect)/2),c.y-(CGRectH(rect)/2),CGRectW(rect),CGRectH(rect)};
}
CGRect CGRectApplyRatio(CGRect rect, CGFloat ratio)
{
    if(CGRectIsTall(rect))
    {
        rect.size.width=rect.size.height*ratio;
    }
    else
    {
        rect.size.height=rect.size.width*ratio;
    }
    return rect;
}
CGFloat CGSizeRatioOf(CGSize fs)
{
    return fs.width < fs.height ? fs.width/fs.height : fs.height/fs.width;
}
CGSize CGSizeApplyRatio(CGSize size, CGSize fs)
{
    CGFloat r = CGSizeRatioOf(fs);
    int w = fs.width > fs.height ? 1 : 2;
    size.width *= w == 1 ? 1 : r;
    size.height *= w == 1 ? r : 1;
    return size;
}

BOOL isMBOOL(id v)
{
    NSNumber * isSuccessNumber = (NSNumber *)v;
    if([isSuccessNumber boolValue] == YES)
    {
        // this is the YES case
        return YES;
    }
    return NO;
}
id isNullOr(id obj)
{
    return obj==nil || [obj isKindOfClass:[NSNull class]] ? nil : obj;
}
BOOL isNull(id obj)
{
    return obj==nil || [obj isKindOfClass:[NSNull class]] ? YES : NO;
}
BOOL isMEmpty(id obj)
{
    return obj==nil || [obj isKindOfClass:[NSNull class]] ? YES : NO;
}
BOOL ismt(id obj)
{
    return !isM(obj);
}
BOOL isM(id obj)
{
    if(isMEmpty(obj)) return NO;
    if([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@""]) return NO;
    return YES;
}
NSString *MyLocalStr(NSString *str) {
    
    return NSLocalizedString(str, nil);
}
void ELog(NSString *name, UIEdgeInsets insets)
{
    DLog(@"%@ | %@", name, EdgeLogStr(insets));
}
void FLog(NSString *name, CGRect frame) {
    
    DLog(@"%@ | %2.2f, %2.2f | %2.2f ✕ %2.2f", name, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

void SLog(NSString *name, CGSize size)
{
    DLog(@"%@ | %2.2f ✕ %2.2f", name, size.width, size.height);
}

void PLog(NSString *name, CGPoint origin)
{
    DLog(@"%@ | %2.4f, %2.4f", name, origin.x, origin.y);
}


void NoLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    format = [@"\n-----------------------------------------\n" stringByAppendingString:[format stringByAppendingString:@"\n\n"]];
    NSString *formattedString = [[NSString alloc] initWithFormat: format
                                                       arguments: args];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput]
     writeData: [formattedString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
    [formattedString release];
}
MFRange MFRangeMakeWithCenterLength(float _location, float _length, float _center) {
    MFRange range;
    range.location = _location;
    range.length = _length;
    range.centerLength = _center;
    
    range.center = range.location + ((range.length - range.location)*range.centerLength);
    
    return range;
}
MFRange MFRangeMakeWithCenter(float _location, float _length, float _center) {
    MFRange range;
    range.location = _location;
    range.length = _length;
    range.center = _center;
    range.centerLength = range.center/(range.length - range.location);
    return range;
}

MFRange MFRangeMake(float _location, float _length) {
    
    return MFRangeMakeWithCenterLength(_location, _length, 0.5);
}
MysticHSB MysticHSBHue(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    hsb.hue = MIN(1.0,MAX(0.0,v));
    return hsb;
}
MysticHSB MysticHSBSaturation(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    hsb.saturation = MIN(1.0,MAX(0.0,v));
    return hsb;
}
MysticHSB MysticHSBBrightness(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    hsb.brightness = MIN(1.0,MAX(0.0,v));
    return hsb;
}

MysticHSB MysticHSBAddHue(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    float x = hsb.hue;
    hsb.hue = x + v < 0.0 ? 1.0 - fabsf(x + v) : x + v > 1.0 ? x+v-1.0 : x+v;
    return hsb;
}
MysticHSB MysticHSBAddSaturation(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    float x = hsb.saturation;
    hsb.saturation = x + v < 0.0 ? 1.0 - fabsf(x + v) : x + v > 1.0 ? x+v-1.0 : x+v;
    return hsb;
}
MysticHSB MysticHSBAddBrightness(MysticHSB h, float v)
{
    MysticHSB hsb = (MysticHSB){h.hue, h.saturation, h.brightness};
    float x = hsb.brightness;
    hsb.brightness = x + v < 0.0 ? 1.0 - fabsf(x + v) : x + v > 1.0 ? x+v-1.0 : x+v;
    return hsb;
}

void MysticWaitQueue(NSTimeInterval delay, MysticBlock block, dispatch_queue_t queue)
{
    if(!block) return;
    if(delay <= 0) return block();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), queue, block);
}


void MysticWait(NSTimeInterval delay, MysticBlock block)
{
    if(!block) return;
    if(delay <= 0) return block();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}
BOOL CGSizeIsEqualThreshold(CGSize size1, CGSize size2, float threshold)
{
    float d = fabs(size1.width/size2.width);
    return (1.0 - d > threshold || 1.0 - fabs(size1.width/size2.width) > threshold) ? NO : YES;
}
BOOL CGSizeHeightIsEqualThreshold(CGSize size1, CGSize size2, float threshold)
{
    float d = fabs(size1.height/size2.height);
    return (1.0 - d > threshold) ? NO : YES;
}
BOOL CGSizeWidthIsEqualThreshold(CGSize size1, CGSize size2, float threshold)
{
    float d = fabs(size1.height/size2.height);
    return (1.0 - d > threshold) ? NO : YES;
}
MLogObj * SPCif(BOOL cond, NSString *key, id value)
{
    return LOR(!cond,key,value,@" ",nil);
}
MLogObj * SKPif(BOOL cond, NSString *key, id value)
{
    return LOR(!cond,key,value,SKP,@"");
}

MLogObj * LOR(BOOL cond, NSString *key, id value, NSString *key2, id value2)
{
    return [MLogObj key:cond?key:key2 value:cond?value:value2];
}
CGFloat rotationDegrees(CGAffineTransform nt)
{
    CGFloat radians = atan2f(nt.b, nt.a);
    CGFloat degrees = radians * (180 / M_PI);
    return degrees;
}
CGFloat rotationRadians(CGAffineTransform nt)
{
    return atan2f(nt.b, nt.a);
}
CGAffineTransform snapRotation(CGAffineTransform t)
{
    CGAffineTransform nt = t;
    CGFloat radians = atan2f(nt.b, nt.a);
    CGFloat degrees = radians * (180 / M_PI);
    CGFloat deg = fabs(degrees);
    BOOL snap1 = NO;
    BOOL snap2 = NO;
    BOOL snap3 = NO;
    BOOL snap32 = NO;
    BOOL snap4 = NO;
    if(degrees > -1 && degrees < 1) { snap1=YES; nt = CGAffineTransformIdentity; }
    if(!snap1 && deg <  91 && deg > 89) { snap2 = YES; nt = CGAffineTransformMakeRotation(90.0/(180 / M_PI) * (degrees < 0 ? -1 : 1)); }
//    if(!snap1 && !snap2 && deg < 46 && deg > 44) { snap3 = YES; nt = CGAffineTransformMakeRotation(45.0/(180 / M_PI) * (degrees < 0 ? -1 : 1));}
//    if(!snap1 && !snap2 && !snap3 && deg < 136 && deg > 134) { snap32 = YES; nt = CGAffineTransformMakeRotation(135.0/(180 / M_PI) * (degrees < 0 ? -1 : 1)); }
    if(!snap1 && !snap2 && degrees < -179 && degrees > -181) { snap4 = YES; nt = CGAffineTransformMakeRotation(-180/(180 / M_PI)); }
    return nt;
}
CGAffineTransform snapRotation45and90(CGAffineTransform t)
{
    CGAffineTransform nt = t;
    CGFloat radians = atan2f(nt.b, nt.a);
    CGFloat degrees = radians * (180 / M_PI);
    CGFloat deg = fabs(degrees);
    BOOL snap1 = NO;
    BOOL snap2 = NO;
    BOOL snap3 = NO;
    BOOL snap32 = NO;
    BOOL snap4 = NO;
    if(degrees > -1 && degrees < 1) { snap1=YES; nt = CGAffineTransformIdentity; }
    if(!snap1 && deg <  91 && deg > 89) { snap2 = YES; nt = CGAffineTransformMakeRotation(90.0/(180 / M_PI) * (degrees < 0 ? -1 : 1)); }
    if(!snap1 && !snap2 && deg < 46 && deg > 44) { snap3 = YES; nt = CGAffineTransformMakeRotation(45.0/(180 / M_PI) * (degrees < 0 ? -1 : 1));}
    if(!snap1 && !snap2 && !snap3 && deg < 136 && deg > 134) { snap32 = YES; nt = CGAffineTransformMakeRotation(135.0/(180 / M_PI) * (degrees < 0 ? -1 : 1)); }
    if(!snap1 && !snap2 && !snap3 && !snap32 && degrees < -179 && degrees > -181) { snap4 = YES; nt = CGAffineTransformMakeRotation(-180/(180 / M_PI)); }
    return nt;
}
NSString *UIGestureRecognizerStateStr(UIGestureRecognizerState state)
{
    switch (state) {
        case UIGestureRecognizerStateBegan:     return @"UIGestureRecognizerStateBegan    ";
        case UIGestureRecognizerStateEnded:     return @"UIGestureRecognizerStateEnded    ";
        case UIGestureRecognizerStateCancelled: return @"UIGestureRecognizerStateCancelled";
        case UIGestureRecognizerStateFailed:    return @"UIGestureRecognizerStateFailed   ";
        case UIGestureRecognizerStateChanged:   return @"UIGestureRecognizerStateChanged  ";
        case UIGestureRecognizerStatePossible:  return @"UIGestureRecognizerStatePossible ";
        default: break;
    }
                                                return @"UIGestureRecognizerState Unknown?";
}

void rgbToHSV(float rgb[3], float hsv[3])
{
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    //float *h = hsv[0], *s = hsv[1], *v = hsv[2];
    
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    hsv[2] = max;               // v
    delta = max - min;
    if( max != 0 )
        hsv[1] = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        hsv[1] = 0;
        hsv[0] = -1;
        return;
    }
    if( r == max )
        hsv[0] = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        hsv[0] = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        hsv[0] = 4 + ( r - g ) / delta; // between magenta & cyan
    hsv[0] *= 60;               // degrees
    if( hsv[0] < 0 )
        hsv[0] += 360;
    hsv[0] /= 360.0;
}

void hsvToRGB(float hsv[3], float rgb[3])
{
    float C = hsv[2] * hsv[1];
    float HS = hsv[0] * 6.0;
    float X = C * (1.0 - fabs(fmodf(HS, 2.0) - 1.0));
    
    if (HS >= 0 && HS < 1)
    {
        rgb[0] = C;
        rgb[1] = X;
        rgb[2] = 0;
    }
    else if (HS >= 1 && HS < 2)
    {
        rgb[0] = X;
        rgb[1] = C;
        rgb[2] = 0;
    }
    else if (HS >= 2 && HS < 3)
    {
        rgb[0] = 0;
        rgb[1] = C;
        rgb[2] = X;
    }
    else if (HS >= 3 && HS < 4)
    {
        rgb[0] = 0;
        rgb[1] = X;
        rgb[2] = C;
    }
    else if (HS >= 4 && HS < 5)
    {
        rgb[0] = X;
        rgb[1] = 0;
        rgb[2] = C;
    }
    else if (HS >= 5 && HS < 6)
    {
        rgb[0] = C;
        rgb[1] = 0;
        rgb[2] = X;
    }
    else {
        rgb[0] = 0.0;
        rgb[1] = 0.0;
        rgb[2] = 0.0;
    }
    
    
    float m = hsv[2] - C;
    rgb[0] += m;
    rgb[1] += m;
    rgb[2] += m;
}


@implementation MLogObj


- (void) dealloc;
{
    [super dealloc];
    [_key release];
    [_value release];
}

+ (instancetype) key:(NSString *)key value:(id)value;
{
    MLogObj *obj = [[[self class] alloc] init];
    obj.key = key;
    obj.value = value;
    return [obj autorelease];
}

@end

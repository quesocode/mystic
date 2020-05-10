//
//  MysticSliderBlocks.m
//  Mystic
//
//  Created by Me on 3/23/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticSliderBlocks.h"
#import "MysticSlider.h"
#import "MysticLevelsSlider.h"
#import "PackPotionOption.h"
#import "MysticOptions.h"
#import "MysticFilterManager.h"
#import "MysticImageFilter.h"
#import "UserPotion.h"

@implementation MysticSliderBlocks

+ (MysticSliderBlock) blockForSliderChange:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;
{
    switch (setting)
    {
#ifdef DEBUG
        case MysticSettingTest:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                
                GPUImageSharpenFilter *filter = [slider.testFilters objectForKey:@"sharpen"];
                if(filter) filter.sharpness = slider.value;
                GPUImagePicture *source = [slider.testFilters objectForKey:@"source"];
                if(source) [source processImage];
            };
        }
#endif
        case MysticSettingSharpness:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.sharpness = slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageSharpenFilter *filter = [layer filterForKey:MysticLayerKeySettingSharpness];
                if(filter) filter.sharpness = slider.value;
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingUnsharpMask:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.unsharpMask = slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageUnsharpMaskFilter *filter = [layer filterForKey:MysticLayerKeySettingUnsharpmask];
                if(filter)
                {
                    filter.intensity = slider.value;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingTiltShift:
        {
            return nil;
        }
        case MysticSettingVibrance:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.vibrance = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setVibrance:slider.targetOption.vibrance index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingVignetteColorAlpha:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                UIColor *c = slider.targetOption.vignetteColor ? slider.targetOption.vignetteColor : [UIColor blackColor];
                slider.targetOption.vignetteColor =  [c alpha:slider.value];
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setVignette:slider.targetOption.vignetteCenter color:slider.targetOption.vignetteColor start:slider.targetOption.vignetteStart end:slider.targetOption.vignetteEnd option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingHighlightIntensity:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.highlightIntensity = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setHighlightIntensity:slider.value tint:slider.targetOption.highlightTintColor index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingShadowIntensity:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.shadowIntensity = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setShadowIntensity:slider.value tint:slider.targetOption.shadowTintColor index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingSaturation:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.saturation = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSaturation:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingIntensity:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.intensity = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setIntensity:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingBrightness:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.brightness = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setBrightness:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingContrast:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.contrast = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setContrast:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingHaze:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.haze = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setHaze:slider.value slope:slider.targetOption.hazeSlope index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingGamma:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.gamma = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setGamma:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingGrain:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.grainAlpha = slider.value;
                slider.targetOption.hasChanged = YES;
//                slider.targetOption.grainTime = (CGFloat)((double)arc4random() / ARC4RANDOM_MAX);
                [[MysticOptions current].filters.filter setGrainTime:slider.targetOption.grainTime alpha:slider.targetOption.grainAlpha threshold:slider.targetOption.grainThreshold color:slider.targetOption.grainColor?slider.targetOption.grainColor:UIColor.blackColor option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
//                DLog(@"grain: %@", [slider.targetOption valueForType:MysticSettingGrain]);
            };
        }
        case MysticSettingHSB:
        case MysticSettingHSBHue:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                MysticHSB newHsb = slider.targetOption.hsb;
                newHsb.hue = slider.value;
                slider.targetOption.hsb = newHsb;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setHSB:newHsb intensity:1 index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingExposure:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.exposure = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setExposure:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingHighlights:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.highlights = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setShadow:slider.targetOption.shadows highlight:slider.value index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingShadows:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.shadows = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setShadow:slider.value highlight:slider.targetOption.highlights index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingTemperature:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                float tempRange = kTemperatureValueMax - kTemperatureValueMin;
                float newTempP = slider.value/kTemperatureMax;
                float rangeVal = tempRange*newTempP;
                float newTemp = kTemperatureValueMin + rangeVal;
                slider.targetOption.temperature = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setTemp:newTemp tint:slider.targetOption.tint index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingLevels:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                switch (slider.colorState) {
                    case MysticSliderStateRed:
                    {
                        slider.targetOption.whiteLevelsRed = slider.upperValue;
                        slider.targetOption.blackLevelsRed = slider.lowerValue;
                        slider.targetOption.midLevelsRed = slider.midValue;
                        break;
                    }
                    case MysticSliderStateGreen:
                    {
                        slider.targetOption.whiteLevelsGreen = slider.upperValue;
                        slider.targetOption.blackLevelsGreen = slider.lowerValue;
                        slider.targetOption.midLevelsGreen = slider.midValue;
                        break;
                    }
                    case MysticSliderStateBlue:
                    {
                        slider.targetOption.whiteLevelsBlue = slider.upperValue;
                        slider.targetOption.blackLevelsBlue = slider.lowerValue;
                        slider.targetOption.midLevelsBlue = slider.midValue;
                        break;
                    }
                        
                    default:
                    {
                        slider.targetOption.whiteLevels = slider.upperValue;
                        slider.targetOption.blackLevels = slider.lowerValue;
                        slider.targetOption.midLevels = slider.midValue;
                        break;
                    }
                }
                
                slider.targetOption.hasChanged = YES;
                if(slider.colorState == MysticSliderStateRGB || slider.colorState == MysticSliderStateRed)
                {
                    [[MysticOptions current].filters.filter setRedLevelMin:slider.targetOption.blackLevelsRed mid:slider.targetOption.midLevelsValueRed max:slider.targetOption.whiteLevelsRed minOut:slider.targetOption.minBlackLevelRed maxOut:slider.targetOption.maxWhiteLevelRed index:slider.targetOption.shaderIndex option:slider.targetOption];
                }
                if(slider.colorState == MysticSliderStateRGB || slider.colorState == MysticSliderStateGreen)
                {
                    [[MysticOptions current].filters.filter setGreenLevelMin:slider.targetOption.blackLevelsGreen mid:slider.targetOption.midLevelsValueGreen max:slider.targetOption.whiteLevelsGreen minOut:slider.targetOption.minBlackLevelGreen maxOut:slider.targetOption.maxWhiteLevelGreen index:slider.targetOption.shaderIndex option:slider.targetOption];
                }
                if(slider.colorState == MysticSliderStateRGB || slider.colorState == MysticSliderStateBlue)
                {
                    [[MysticOptions current].filters.filter setBlueLevelMin:slider.targetOption.blackLevelsBlue mid:slider.targetOption.midLevelsValueBlue max:slider.targetOption.whiteLevelsBlue minOut:slider.targetOption.minBlackLevelBlue maxOut:slider.targetOption.maxWhiteLevelBlue index:slider.targetOption.shaderIndex option:slider.targetOption];
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingSkin:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {                
                slider.targetOption.skinToneAdjust = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSkin:slider.targetOption.skinToneAdjust hue:slider.targetOption.skinHue hueThreshold:slider.targetOption.skinHueThreshold maxHueShift:slider.targetOption.skinHueMaxShift maxSaturation:slider.targetOption.skinMaxSaturation upperTone:slider.targetOption.skinUpperTone index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
            

        }
        case MysticSettingSkinHue:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                slider.targetOption.skinHue = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSkin:slider.targetOption.skinToneAdjust hue:slider.targetOption.skinHue hueThreshold:slider.targetOption.skinHueThreshold maxHueShift:slider.targetOption.skinHueMaxShift maxSaturation:slider.targetOption.skinMaxSaturation upperTone:slider.targetOption.skinUpperTone index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
            

        }
        case MysticSettingSkinHueThreshold:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                slider.targetOption.skinHueThreshold = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSkin:slider.targetOption.skinToneAdjust hue:slider.targetOption.skinHue hueThreshold:slider.targetOption.skinHueThreshold maxHueShift:slider.targetOption.skinHueMaxShift maxSaturation:slider.targetOption.skinMaxSaturation upperTone:slider.targetOption.skinUpperTone index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
            

        }
        case MysticSettingSkinMaxHueShift:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                slider.targetOption.skinHueMaxShift = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSkin:slider.targetOption.skinToneAdjust hue:slider.targetOption.skinHue hueThreshold:slider.targetOption.skinHueThreshold maxHueShift:slider.targetOption.skinHueMaxShift maxSaturation:slider.targetOption.skinMaxSaturation upperTone:slider.targetOption.skinUpperTone index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
            

        }
        case MysticSettingSkinMaxSaturationShift:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                slider.targetOption.skinMaxSaturation = slider.value;
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setSkin:slider.targetOption.skinToneAdjust hue:slider.targetOption.skinHue hueThreshold:slider.targetOption.skinHueThreshold maxHueShift:slider.targetOption.skinHueMaxShift maxSaturation:slider.targetOption.skinMaxSaturation upperTone:slider.targetOption.skinUpperTone index:slider.targetOption.shaderIndex option:slider.targetOption];
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
            

        }
        
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalanceGreen:
        {
            return (MysticSliderBlock) ^( MysticLevelsSlider *slider)
            {
                switch (slider.colorState) {
                    case MysticSliderStateGreen: slider.targetOption.rgb = (GPUVector3) { slider.targetOption.rgb.one, slider.value, slider.targetOption.rgb.three}; break;
                    case MysticSliderStateBlue: slider.targetOption.rgb = (GPUVector3) {slider.targetOption.rgb.one, slider.targetOption.rgb.two, slider.value}; break;
                    default: slider.targetOption.rgb = (GPUVector3) {slider.value, slider.targetOption.rgb.two, slider.targetOption.rgb.three}; break;
                }
                slider.targetOption.hasChanged = YES;
                [[MysticOptions current].filters.filter setColorBalance:slider.targetOption.rgb index:slider.targetOption.shaderIndex option:slider.targetOption];                
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }        
        default: break;
    }
    return nil;
}


+ (MysticSliderBlock) blockForSliderFinish:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;
{
    switch (setting) {
        case MysticSettingSaturation:
            
            return nil;
        case MysticSettingTiltShift:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.tiltShiftBlurSizeInPixels = slider.value;
                slider.targetOption.tiltShift = slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageTiltShiftFilter *filter = [layer filterForKey:MysticLayerKeySettingTiltShift];
                if(filter)
                {
                    filter.blurRadiusInPixels = slider.value* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingToon:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.toonThreshold = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageSmoothToonFilter *filter = [layer filterForKey:MysticLayerKeySettingToon];
                if(filter)
                {
                    filter.threshold = slider.value* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;
                    filter.blurRadiusInPixels = filter.blurRadiusInPixels* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;

                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingPixellate:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.pixellatePixelWidth = slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImagePixellateFilter *filter = [layer filterForKey:MysticLayerKeySettingPixellate];

                if(filter)
                {
                    filter.fractionalWidthOfAPixel = slider.value;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingHalfTone:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.halftonePixelWidth = slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageHalftoneFilter *filter = [layer filterForKey:MysticLayerKeySettingHalftone];

                if(filter)
                {
                    filter.fractionalWidthOfAPixel = slider.value;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingPosterize:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.posterizeLevels=(int)ceil(slider.value);
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImagePosterizeFilter *filter = [layer filterForKey:MysticLayerKeySettingPosterize];
                
                if(filter)
                {
                    filter.colorLevels = slider.targetOption.posterizeLevels;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingSketchFilter:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.sketchStrength=slider.value;
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageSketchFilter *filter = [layer filterForKey:MysticLayerKeySettingSketchFilter];
                
                if(filter)
                {
                    filter.edgeStrength = slider.targetOption.sketchStrength;
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingBlurCircle:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.blurCircleRadius = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageGaussianSelectiveBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurCircle];
//                DLog(@"blur circle filter: %2.3f", slider.value);
                
                if(filter)
                {
                    filter.blurRadiusInPixels = slider.value* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;
                    filter.excludeCircleRadius = slider.targetOption.blurCircleExcludeRadius;
                    filter.excludeBlurSize = slider.targetOption.blurCircleExcludeSize;
                    filter.excludeCirclePoint = slider.targetOption.blurCirclePoint;
                    filter.aspectRatio = slider.targetOption.blurCircleAspectRatio;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingBlurZoom:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
//                slider.targetOption.blurZoomSize = slider.value* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;
                slider.targetOption.blurZoomSize = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageZoomBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurZoom];
                //                DLog(@"blur circle filter: %2.3f", slider.value);
                
                if(filter)
                {
                    filter.blurSize = slider.value;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingBlurMotion:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.blurMotionSize = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageMotionBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurMotion];
                //                DLog(@"blur circle filter: %2.3f", slider.value);
                
                if(filter)
                {
                    filter.blurSize = slider.value* CGScaleOfSizes([MysticOptions current].size,[UserPotion potion].previewSize).scale;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingBlur:
        case MysticSettingBlurGaussian:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.blurRadius = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageGaussianBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlur];
                //                DLog(@"blur circle filter: %2.3f", slider.value);
                
                if(filter)
                {
                    filter.blurRadiusInPixels = slider.value;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingDistortPinch:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.pinchScale = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImagePinchDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortPinch];
                if(filter) filter.scale = slider.value;
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingDistortSwirl:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.swirlRadius = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageSwirlFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortSwirl];
                
                if(filter)
                {
                    filter.radius = slider.value;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingDistortBuldge:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.buldgeRadius = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageBulgeDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortBuldge];
                
                if(filter)
                {
                    filter.radius = slider.value;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        case MysticSettingDistortGlassSphere:
        {
            return (MysticSliderBlock) ^( MysticSlider *slider)
            {
                slider.targetOption.sphereRadius = slider.value;
                
                slider.targetOption.hasChanged = YES;
                MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:slider.targetOption];
                GPUImageGlassSphereFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortGlassSphere];
                
                if(filter)
                {
                    filter.radius = slider.value;
                    
                    
                }
                [slider.imageViewDelegate performSelector:slider.refreshAction withObject:slider];
            };
        }
        default: break;
    }
    return nil;
}
+ (MysticSliderBlock) blockForSliderStill:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;
{
    switch (setting) {
        case MysticSettingSaturation:
            
            break;
            
        default: break;
    }
    return nil;
}


@end

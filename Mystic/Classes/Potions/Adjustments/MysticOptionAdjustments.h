//
//  MysticOptionAdjustments.h
//  Mystic
//
//  Created by Me on 5/1/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "GPUImage.h"

@interface MysticOptionAdjustments : NSObject

@property (nonatomic, assign) BOOL anchorTopLeft, ignoreAspectRatio,  presetSunshine, presetBlending, presetInvert, inverted, blended, stretchLayerImage, applySunshine, flipHorizontal, flipVertical, desaturate, smoothing, showBg;

@property (nonatomic, assign) float colorMatrixIntensity, brightness, gamma, exposure, highlights, shadows, sharpness, contrast, vignetteStart, vignetteEnd, saturation, vignetteValue, tiltShift, rotation, alpha, haze, blackLevels, midLevels, whiteLevels, unsharpMask, presetIntensity, intensity, smoothingSensitivity, sensitivity, tint, temperature;

@property (nonatomic, readonly) float hsbHue, hsbBrightness, hsbSaturation;
@property (nonatomic, assign) MysticHSB hsb;
@property (nonatomic, assign) GPUVector3 rgb;
@property (nonatomic, assign) CGRect transformRect, cropRect, adjustedRect;
@property (nonatomic, assign) id owner;

@end

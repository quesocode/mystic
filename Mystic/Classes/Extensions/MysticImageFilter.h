//
//  MysticImageFilter.h
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "GPUImage.h"
#import "MysticShaderConstants.h"
#import "Mystic.h"

@class PackPotionOption, MysticOptions;

@interface MysticImageFilter : GPUImageFilter
{
    
    dispatch_semaphore_t imageUpdateSemaphore;
    
    GLint vignetteCenterUniform, vignetteColorUniform, vignetteStartUniform, vignetteEndUniform;
    
    CGPoint vignetteCenter;
    GPUVector4 vignetteColor;
    CGFloat vignetteStart;
    CGFloat vignetteEnd;
    
    CGFloat skinToneAdjust1;
    CGFloat skinToneAdjust2;
    CGFloat skinToneAdjust3;
    
    CGFloat skinHue1;
    CGFloat skinHue2;
    CGFloat skinHue3;

    
    CGFloat skinHueThreshold1;
    CGFloat skinHueThreshold2;
    CGFloat skinHueThreshold3;
    
    CGFloat skinMaxHueShift1;
    CGFloat skinMaxHueShift2;
    CGFloat skinMaxHueShift3;

    CGFloat skinMaxSaturationShift1;
    CGFloat skinMaxSaturationShift2;
    CGFloat skinMaxSaturationShift3;

    int skinUpperSkinToneColor1;
    int skinUpperSkinToneColor2;
    int skinUpperSkinToneColor3;
    
    CGFloat grainAlpha;
    CGFloat grainTime;
    CGFloat grainThreshold;
    GLint grainAlphaUniform;
    GLint grainTimeUniform;
    GLint grainThresholdUniform;
    GLint grainColorUniform;
    GPUVector4 grainColor;

    
    GLint skinToneAdjustUniform1;
    GLint skinHueUniform1;
    GLint skinHueThresholdUniform1;
    GLint skinMaxHueShiftUniform1;
    GLint skinMaxSaturationShiftUniform1;
    GLint skinUpperSkinToneColorUniform1;
    
    GLint skinToneAdjustUniform2;
    GLint skinHueUniform2;
    GLint skinHueThresholdUniform2;
    GLint skinMaxHueShiftUniform2;
    GLint skinMaxSaturationShiftUniform2;
    GLint skinUpperSkinToneColorUniform2;
    
    GLint skinToneAdjustUniform3;
    GLint skinHueUniform3;
    GLint skinHueThresholdUniform3;
    GLint skinMaxHueShiftUniform3;
    GLint skinMaxSaturationShiftUniform3;
    GLint skinUpperSkinToneColorUniform3;
    
    GLint intensityUniform1;
    GLint intensityUniform2;
    GLint intensityUniform3;
    GLint intensityUniform4;
    GLint intensityUniform5;
    GLint intensityUniform6;
    GLint intensityUniform7;
    GLint intensityUniform8;
    
    CGFloat brightest1;
    GLint brightestUniform1;
    CGFloat darkest1;
    GLint darkestUniform1;
    
    
    CGFloat brightness1;
    CGFloat brightness2;
    CGFloat brightness3;
    CGFloat brightness4;
    CGFloat brightness5;
    CGFloat brightness6;
    CGFloat brightness7;
    CGFloat brightness8;
    
    GLint brightnessUniform1;
    GLint brightnessUniform2;
    GLint brightnessUniform3;
    GLint brightnessUniform4;
    GLint brightnessUniform5;
    GLint brightnessUniform6;
    GLint brightnessUniform7;
    GLint brightnessUniform8;
    
    
    CGFloat vibrance1;
    CGFloat vibrance2;
    CGFloat vibrance3;
    CGFloat vibrance4;
    CGFloat vibrance5;
    CGFloat vibrance6;
    CGFloat vibrance7;
    CGFloat vibrance8;
    
    GLint vibranceUniform1;
    GLint vibranceUniform2;
    GLint vibranceUniform3;
    GLint vibranceUniform4;
    GLint vibranceUniform5;
    GLint vibranceUniform6;
    GLint vibranceUniform7;
    GLint vibranceUniform8;
    
    
    CGFloat saturation1;
    CGFloat saturation2;
    CGFloat saturation3;
    CGFloat saturation4;
    CGFloat saturation5;
    CGFloat saturation6;
    CGFloat saturation7;
    CGFloat saturation8;
    
    GLint saturationUniform1;
    GLint saturationUniform2;
    GLint saturationUniform3;
    GLint saturationUniform4;
    GLint saturationUniform5;
    GLint saturationUniform6;
    GLint saturationUniform7;
    GLint saturationUniform8;
    
    
    GLint shadowTintUniform1;
    GLint shadowTintUniform2;
    GLint shadowTintUniform3;
    
    
    GPUVector4 shadowTint1;
    GPUVector4 shadowTint2;
    GPUVector4 shadowTint3;
    
    GLint highlightTintUniform1;
    GLint highlightTintUniform2;
    GLint highlightTintUniform3;
    
    
    GPUVector4 highlightTint1;
    GPUVector4 highlightTint2;
    GPUVector4 highlightTint3;
    
    CGFloat highlightIntensity1;
    CGFloat highlightIntensity2;
    CGFloat highlightIntensity3;
    
    GLint highlightIntensityUniform1;
    GLint highlightIntensityUniform2;
    GLint highlightIntensityUniform3;
    
    CGFloat shadowIntensity1;
    CGFloat shadowIntensity2;
    CGFloat shadowIntensity3;
    CGFloat shadowIntensity4;
    CGFloat shadowIntensity5;
    
    GLint shadowIntensityUniform1;
    GLint shadowIntensityUniform2;
    GLint shadowIntensityUniform3;
    GLint shadowIntensityUniform4;
    GLint shadowIntensityUniform5;
    
    
    
    CGFloat contrast1;
    CGFloat contrast2;
    CGFloat contrast3;
    CGFloat contrast4;
    CGFloat contrast5;
    CGFloat contrast6;
    CGFloat contrast7;
    CGFloat contrast8;
    
    GLint contrastUniform1;
    GLint contrastUniform2;
    GLint contrastUniform3;
    GLint contrastUniform4;
    GLint contrastUniform5;
    GLint contrastUniform6;
    GLint contrastUniform7;
    GLint contrastUniform8;
    
    
    
    CGFloat exposure1;
    CGFloat exposure2;
    CGFloat exposure3;
    CGFloat exposure4;
    CGFloat exposure5;
    CGFloat exposure6;
    CGFloat exposure7;
    CGFloat exposure8;
    
    GLint exposureUniform1;
    GLint exposureUniform2;
    GLint exposureUniform3;
    GLint exposureUniform4;
    GLint exposureUniform5;
    GLint exposureUniform6;
    GLint exposureUniform7;
    GLint exposureUniform8;
    
    
    CGFloat gamma1;
    CGFloat gamma2;
    CGFloat gamma3;
    CGFloat gamma4;
    CGFloat gamma5;
    CGFloat gamma6;
    CGFloat gamma7;
    CGFloat gamma8;
    
    GLint gammaUniform1;
    GLint gammaUniform2;
    GLint gammaUniform3;
    GLint gammaUniform4;
    GLint gammaUniform5;
    GLint gammaUniform6;
    GLint gammaUniform7;
    GLint gammaUniform8;
    
    
    
    
    GLint foregroundColorUniform1;
    GLint foregroundColorUniform2;
    GLint foregroundColorUniform3;
    GLint foregroundColorUniform4;
    GLint foregroundColorUniform5;
    GLint foregroundColorUniform6;
    GLint foregroundColorUniform7;
    GLint foregroundColorUniform8;
    
    GPUVector4 foregroundColor1;
    GPUVector4 foregroundColor2;
    GPUVector4 foregroundColor3;
    GPUVector4 foregroundColor4;
    GPUVector4 foregroundColor5;
    GPUVector4 foregroundColor6;
    GPUVector4 foregroundColor7;
    GPUVector4 foregroundColor8;
    
    
    
    
    
    
    GLint maskBackgroundColorUniform1;
    GLint maskBackgroundColorUniform2;
    GLint maskBackgroundColorUniform3;
    GLint maskBackgroundColorUniform4;
    GLint maskBackgroundColorUniform5;
    GLint maskBackgroundColorUniform6;
    GLint maskBackgroundColorUniform7;
    GLint maskBackgroundColorUniform8;
    
    GPUVector4 maskBackgroundColor1;
    GPUVector4 maskBackgroundColor2;
    GPUVector4 maskBackgroundColor3;
    GPUVector4 maskBackgroundColor4;
    GPUVector4 maskBackgroundColor5;
    GPUVector4 maskBackgroundColor6;
    GPUVector4 maskBackgroundColor7;
    GPUVector4 maskBackgroundColor8;
    
    
    
    GLint backgroundColorUniform1;
    GLint backgroundColorUniform2;
    GLint backgroundColorUniform3;
    GLint backgroundColorUniform4;
    GLint backgroundColorUniform5;
    GLint backgroundColorUniform6;
    GLint backgroundColorUniform7;
    GLint backgroundColorUniform8;
    
    GPUVector4 backgroundColor1;
    GPUVector4 backgroundColor2;
    GPUVector4 backgroundColor3;
    GPUVector4 backgroundColor4;
    GPUVector4 backgroundColor5;
    GPUVector4 backgroundColor6;
    GPUVector4 backgroundColor7;
    GPUVector4 backgroundColor8;
    
    GLint falseDarkUniform1;
    GLint falseDarkUniform2;
    GLint falseDarkUniform3;
    GLint falseDarkUniform4;
    GLint falseDarkUniform5;
    GLint falseDarkUniform6;
    GLint falseDarkUniform7;
    GLint falseDarkUniform8;
    
    GPUVector4 falseDark1;
    GPUVector4 falseDark2;
    GPUVector4 falseDark3;
    GPUVector4 falseDark4;
    GPUVector4 falseDark5;
    GPUVector4 falseDark6;
    GPUVector4 falseDark7;
    GPUVector4 falseDark8;
    
    
    
    GLint falseLightUniform1;
    GLint falseLightUniform2;
    GLint falseLightUniform3;
    GLint falseLightUniform4;
    GLint falseLightUniform5;
    GLint falseLightUniform6;
    GLint falseLightUniform7;
    GLint falseLightUniform8;
    
    GPUVector4 falseLight1;
    GPUVector4 falseLight2;
    GPUVector4 falseLight3;
    GPUVector4 falseLight4;
    GPUVector4 falseLight5;
    GPUVector4 falseLight6;
    GPUVector4 falseLight7;
    GPUVector4 falseLight8;
    
    
    
    GLint adjustColorUniform1;
    GLint adjustColorUniform2;
    GLint adjustColorUniform3;
    GLint adjustColorUniform4;
    GLint adjustColorUniform5;
    GLint adjustColorUniform6;
    GLint adjustColorUniform7;
    GLint adjustColorUniform8;
    
    GPUVector4 adjustColor1;
    GPUVector4 adjustColor2;
    GPUVector4 adjustColor3;
    GPUVector4 adjustColor4;
    GPUVector4 adjustColor5;
    GPUVector4 adjustColor6;
    GPUVector4 adjustColor7;
    GPUVector4 adjustColor8;
    
    
    GLint adjustedColorUniform1;
    GLint adjustedColorUniform2;
    GLint adjustedColorUniform3;
    GLint adjustedColorUniform4;
    GLint adjustedColorUniform5;
    GLint adjustedColorUniform6;
    GLint adjustedColorUniform7;
    GLint adjustedColorUniform8;
    
    
    
    GPUVector3 adjustThreshold1;
    GPUVector3 adjustThreshold2;
    GPUVector3 adjustThreshold3;
    GPUVector3 adjustThreshold4;
    GPUVector3 adjustThreshold5;
    GPUVector3 adjustThreshold6;
    GPUVector3 adjustThreshold7;
    GPUVector3 adjustThreshold8;
    
    GPUVector3 adjustRange1;
    GPUVector3 adjustRange2;
    GPUVector3 adjustRange3;
    GPUVector3 adjustRange4;
    GPUVector3 adjustRange5;
    GPUVector3 adjustRange6;
    GPUVector3 adjustRange7;
    GPUVector3 adjustRange8;
    
    GLint adjustedRangeUniform1;
    GLint adjustedRangeUniform2;
    GLint adjustedRangeUniform3;
    GLint adjustedRangeUniform4;
    GLint adjustedRangeUniform5;
    GLint adjustedRangeUniform6;
    GLint adjustedRangeUniform7;
    GLint adjustedRangeUniform8;
    
    
    GLint adjustedThresholdUniform1;
    GLint adjustedThresholdUniform2;
    GLint adjustedThresholdUniform3;
    GLint adjustedThresholdUniform4;
    GLint adjustedThresholdUniform5;
    GLint adjustedThresholdUniform6;
    GLint adjustedThresholdUniform7;
    GLint adjustedThresholdUniform8;
    
    
    GPUVector4 adjustedColor1;
    GPUVector4 adjustedColor2;
    GPUVector4 adjustedColor3;
    GPUVector4 adjustedColor4;
    GPUVector4 adjustedColor5;
    GPUVector4 adjustedColor6;
    GPUVector4 adjustedColor7;
    GPUVector4 adjustedColor8;
    
    CGFloat fullScale;
    GLint fullScaleUniform;
    
    CGFloat haze1;
    CGFloat haze2;
    CGFloat haze3;
    CGFloat haze4;
    CGFloat haze5;
    CGFloat haze6;
    CGFloat haze7;
    CGFloat haze8;
    
    GLint hazeUniform1;
    GLint hazeUniform2;
    GLint hazeUniform3;
    GLint hazeUniform4;
    GLint hazeUniform5;
    GLint hazeUniform6;
    GLint hazeUniform7;
    GLint hazeUniform8;
    
    
    CGFloat slope1;
    CGFloat slope2;
    CGFloat slope3;
    CGFloat slope4;
    CGFloat slope5;
    CGFloat slope6;
    CGFloat slope7;
    CGFloat slope8;
    
    GLint slopeUniform1;
    GLint slopeUniform2;
    GLint slopeUniform3;
    GLint slopeUniform4;
    GLint slopeUniform5;
    GLint slopeUniform6;
    GLint slopeUniform7;
    GLint slopeUniform8;
    
    
    CGFloat temp1;
    CGFloat temp2;
    CGFloat temp3;
    CGFloat temp4;
    CGFloat temp5;
    CGFloat temp6;
    CGFloat temp7;
    CGFloat temp8;
    
    GLint tempUniform1;
    GLint tempUniform2;
    GLint tempUniform3;
    GLint tempUniform4;
    GLint tempUniform5;
    GLint tempUniform6;
    GLint tempUniform7;
    GLint tempUniform8;
    
    
    CGFloat tempTint1;
    CGFloat tempTint2;
    CGFloat tempTint3;
    CGFloat tempTint4;
    CGFloat tempTint5;
    CGFloat tempTint6;
    CGFloat tempTint7;
    CGFloat tempTint8;
    
    GLint tempTintUniform1;
    GLint tempTintUniform2;
    GLint tempTintUniform3;
    GLint tempTintUniform4;
    GLint tempTintUniform5;
    GLint tempTintUniform6;
    GLint tempTintUniform7;
    GLint tempTintUniform8;
    
    
    
    CGFloat shadow1;
    CGFloat shadow2;
    CGFloat shadow3;
    CGFloat shadow4;
    CGFloat shadow5;
    CGFloat shadow6;
    CGFloat shadow7;
    CGFloat shadow8;
    
    GLint shadowUniform1;
    GLint shadowUniform2;
    GLint shadowUniform3;
    GLint shadowUniform4;
    GLint shadowUniform5;
    GLint shadowUniform6;
    GLint shadowUniform7;
    GLint shadowUniform8;
    
    
    CGFloat highlight1;
    CGFloat highlight2;
    CGFloat highlight3;
    CGFloat highlight4;
    CGFloat highlight5;
    CGFloat highlight6;
    CGFloat highlight7;
    CGFloat highlight8;
    
    GLint highlightUniform1;
    GLint highlightUniform2;
    GLint highlightUniform3;
    GLint highlightUniform4;
    GLint highlightUniform5;
    GLint highlightUniform6;
    GLint highlightUniform7;
    GLint highlightUniform8;
    
    

    GLint lvlminUniform1;
    GLint lvlminUniform2;
    GLint lvlminUniform3;

    
    GLint lvlmidUniform1;
    GLint lvlmidUniform2;
    GLint lvlmidUniform3;

    
    GLint lvlmaxUniform1;
    GLint lvlmaxUniform2;
    GLint lvlmaxUniform3;

    
    GLint lvlminoUniform1;
    GLint lvlminoUniform2;
    GLint lvlminoUniform3;

    
    GLint lvlmaxoUniform1;
    GLint lvlmaxoUniform2;
    GLint lvlmaxoUniform3;

    GPUVector3 lvlmin1, lvlmid1, lvlmax1, lvlmino1, lvlmaxo1;
    GPUVector3 lvlmin2, lvlmid2, lvlmax2, lvlmino2, lvlmaxo2;
    GPUVector3 lvlmin3, lvlmid3, lvlmax3, lvlmino3, lvlmaxo3;

    GPUVector3 rgb1, rgb2, rgb3;
    
    


    GLint rgbUniform1;
    GLint rgbUniform2;
    GLint rgbUniform3;
    
    GPUVector3 hsb1, hsb2, hsb3;
    GLint hsbUniform1;
    GLint hsbUniform2;
    GLint hsbUniform3;
    
    GLint hsbIntensityUniform1;
    GLint hsbIntensityUniform2;
    GLint hsbIntensityUniform3;
    
}

@property(readwrite, nonatomic) GPUMatrix4x4 mhsb1,mhsb2,mhsb3;
@property(assign, nonatomic) CGFloat fullScale;
@property(readwrite, nonatomic) CGFloat intensity1;
@property(readwrite, nonatomic) CGFloat intensity2;
@property(readwrite, nonatomic) CGFloat intensity3;
@property(readwrite, nonatomic) CGFloat intensity4;
@property(readwrite, nonatomic) CGFloat intensity5;
@property(readwrite, nonatomic) CGFloat intensity6;
@property(readwrite, nonatomic) CGFloat intensity7;
@property(readwrite, nonatomic) CGFloat intensity8;
@property(nonatomic, assign) BOOL firstTextureRequiresUpdate, secondTextureRequiresUpdate, thirdTextureRequiresUpdate, fourthTextureRequiresUpdate, fifthTextureRequiresUpdate, sixthTextureRequiresUpdate, seventhTextureRequiresUpdate, eigthTextureRequiresUpdate;
- (void) setFullScale:(CGFloat)scale;
- (void) setAdjustColors:(PackPotionOption *)option index:(NSInteger)index;
- (void) setVignette:(CGPoint)center color:(UIColor *)color start:(CGFloat)start end:(CGFloat)end option:(PackPotionOption *)option;
- (void) textureCheckedIn:(NSInteger)textureIndex;
- (void) resetAllFrameChecks;
- (void) applyUniformsFrom:(MysticOptions *)options;
- (void) setIntensity:(CGFloat)value index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setForegroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setBackgroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setMaskBackgroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setBrightness:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setSaturation:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setContrast:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setExposure:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setHaze:(float)value slope:(float)value2 index:(NSInteger)index option:(PackPotionOption *)option;


- (void) setGamma:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setShadow:(float)value highlight:(float)value2 index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setGrainTime:(CGFloat)time alpha:(CGFloat)alpha threshold:(CGFloat)threshold color:(UIColor *)color option:(PackPotionOption *)option;

- (void) setTemp:(float)value tint:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setBrightest:(float)value darkest:(float)darkest option:(PackPotionOption *)option;

- (void) setLevelMin:(float)min mid:(float)mid max:(float)max index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setRedLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setGreenLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setBlueLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setColorBalance:(GPUVector3)rgb index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setHSB:(MysticHSB)hsb intensity:(CGFloat)intensity index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setVibrance:(float)value index:(NSInteger)index option:(PackPotionOption *)option;

- (void) setSkin:(CGFloat)value hue:(CGFloat)value2 hueThreshold:(CGFloat)value3 maxHueShift:(CGFloat)value4 maxSaturation:(CGFloat)value5 upperTone:(CGFloat)value6 index:(int)index option:(PackPotionOption *)option;

- (void) setHighlightIntensity:(CGFloat)value tint:(UIColor *)tint index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setShadowIntensity:(CGFloat)value tint:(UIColor *)tint index:(NSInteger)index option:(PackPotionOption *)option;
- (void) setFalseDark:(UIColor *)dark light:(UIColor *)light index:(NSInteger)index option:(PackPotionOption *)option;
- (void) disableUnknown;
- (void) disableFrameCheck:(int)frameNum;
- (void) disableAll;
- (void) disableAllExcept:(int)f;
- (BOOL) updateFrame:(MysticBlock)completion;


@end

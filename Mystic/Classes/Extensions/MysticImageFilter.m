//
//  MysticImageFilter.m
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticImageFilter.h"
//#import "MysticShaderDefinitions.h"

@implementation MysticImageFilter {
    float matrixhsb1[4][4];
    float matrixhsb2[4][4];
    float matrixhsb3[4][4];

}


@synthesize
fullScale=fullScale,
intensity1=_intensity1,
intensity2=_intensity2,
intensity3=_intensity3,
intensity4=_intensity4,
intensity5=_intensity5,
intensity6=_intensity6,
intensity7=_intensity7,
intensity8=_intensity8;

- (void) dealloc;
{
    [self removeOutputFramebuffer];
#if !OS_OBJECT_USE_OBJC
    if (imageUpdateSemaphore != NULL)
    {
        dispatch_release(imageUpdateSemaphore);
    }
#endif
}
- (void) removeOutputFramebuffer;
{
    [super removeOutputFramebuffer];
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    [self setupUniforms];
    return self;
}
- (id) initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    [self setupUniforms];
    return self;
}

- (void) setupUniforms;
{
    imageUpdateSemaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(imageUpdateSemaphore);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        
        
        
        grainTimeUniform = [filterProgram uniformIndex:@"grainTime"];
        grainAlphaUniform = [filterProgram uniformIndex:@"grainAlpha"];
        grainThresholdUniform = [filterProgram uniformIndex:@"grainThreshold"];
        grainColorUniform = [filterProgram uniformIndex:@"grainColor"];

        
        vignetteCenterUniform = [filterProgram uniformIndex:@"vignetteCenter"];
        vignetteColorUniform = [filterProgram uniformIndex:@"vignetteColor"];
        vignetteStartUniform = [filterProgram uniformIndex:@"vignetteStart"];
        vignetteEndUniform = [filterProgram uniformIndex:@"vignetteEnd"];

        brightestUniform1 = [filterProgram uniformIndex:@"brightest"];
        brightest1 = 1.0f;
        darkestUniform1 = [filterProgram uniformIndex:@"darkest"];
        darkest1 = 1.0f;
        
        intensityUniform1 = [filterProgram uniformIndex:@"intensityUniform1"];
        self.intensity1 = 1.0f;
        
        intensityUniform2 = [filterProgram uniformIndex:@"intensityUniform2"];
        self.intensity2 = 1.0f;
        
        intensityUniform3 = [filterProgram uniformIndex:@"intensityUniform3"];
        self.intensity3 = 1.0f;
        
        intensityUniform4 = [filterProgram uniformIndex:@"intensityUniform4"];
        self.intensity4 = 1.0f;
        
        intensityUniform5 = [filterProgram uniformIndex:@"intensityUniform5"];
        self.intensity5 = 1.0f;
        
        intensityUniform6 = [filterProgram uniformIndex:@"intensityUniform6"];
        self.intensity6 = 1.0f;
        
        intensityUniform7 = [filterProgram uniformIndex:@"intensityUniform7"];
        self.intensity7 = 1.0f;
        
        intensityUniform8 = [filterProgram uniformIndex:@"intensityUniform8"];
        self.intensity8 = 1.0f;
        
        maskBackgroundColorUniform1 = [filterProgram uniformIndex:@"maskBackgroundColorUniform1"];
        maskBackgroundColorUniform2 = [filterProgram uniformIndex:@"maskBackgroundColorUniform2"];
        maskBackgroundColorUniform3 = [filterProgram uniformIndex:@"maskBackgroundColorUniform3"];
        maskBackgroundColorUniform4 = [filterProgram uniformIndex:@"maskBackgroundColorUniform4"];
        maskBackgroundColorUniform5 = [filterProgram uniformIndex:@"maskBackgroundColorUniform5"];
        maskBackgroundColorUniform6 = [filterProgram uniformIndex:@"maskBackgroundColorUniform6"];
        maskBackgroundColorUniform7 = [filterProgram uniformIndex:@"maskBackgroundColorUniform7"];
        maskBackgroundColorUniform8 = [filterProgram uniformIndex:@"maskBackgroundColorUniform8"];
        
        adjustColorUniform1 = [filterProgram uniformIndex:@"adjustColor1"];
        adjustedColorUniform1 = [filterProgram uniformIndex:@"adjustedColor1"];
        adjustColorUniform2 = [filterProgram uniformIndex:@"adjustColor2"];
        adjustedColorUniform2 = [filterProgram uniformIndex:@"adjustedColor2"];
        adjustColorUniform3 = [filterProgram uniformIndex:@"adjustColor3"];
        adjustedColorUniform3 = [filterProgram uniformIndex:@"adjustedColor3"];
        adjustColorUniform4 = [filterProgram uniformIndex:@"adjustColor4"];
        adjustedColorUniform4 = [filterProgram uniformIndex:@"adjustedColor4"];
        adjustColorUniform5 = [filterProgram uniformIndex:@"adjustColor5"];
        adjustedColorUniform5 = [filterProgram uniformIndex:@"adjustedColor5"];
        adjustColorUniform6 = [filterProgram uniformIndex:@"adjustColor6"];
        adjustedColorUniform6 = [filterProgram uniformIndex:@"adjustedColor6"];
        adjustColorUniform7 = [filterProgram uniformIndex:@"adjustColor7"];
        adjustedColorUniform7 = [filterProgram uniformIndex:@"adjustedColor7"];
        adjustColorUniform8 = [filterProgram uniformIndex:@"adjustColor8"];
        adjustedColorUniform8 = [filterProgram uniformIndex:@"adjustedColor8"];
        adjustedThresholdUniform1 = [filterProgram uniformIndex:@"adjustThreshold1"];
        adjustedThresholdUniform2 = [filterProgram uniformIndex:@"adjustThreshold2"];
        adjustedThresholdUniform3 = [filterProgram uniformIndex:@"adjustThreshold3"];
        adjustedThresholdUniform4 = [filterProgram uniformIndex:@"adjustThreshold4"];
        adjustedThresholdUniform5 = [filterProgram uniformIndex:@"adjustThreshold5"];
        adjustedThresholdUniform6 = [filterProgram uniformIndex:@"adjustThreshold6"];
        adjustedThresholdUniform7 = [filterProgram uniformIndex:@"adjustThreshold7"];
        adjustedThresholdUniform8 = [filterProgram uniformIndex:@"adjustThreshold8"];
        
        adjustedRangeUniform1 = [filterProgram uniformIndex:@"adjustRange1"];
        adjustedRangeUniform2 = [filterProgram uniformIndex:@"adjustRange2"];
        adjustedRangeUniform3 = [filterProgram uniformIndex:@"adjustRange3"];
        adjustedRangeUniform4 = [filterProgram uniformIndex:@"adjustRange4"];
        adjustedRangeUniform5 = [filterProgram uniformIndex:@"adjustRange5"];
        adjustedRangeUniform6 = [filterProgram uniformIndex:@"adjustRange6"];
        adjustedRangeUniform7 = [filterProgram uniformIndex:@"adjustRange7"];
        adjustedRangeUniform8 = [filterProgram uniformIndex:@"adjustRange8"];

        
        
        
        skinToneAdjustUniform1 = [filterProgram uniformIndex:@"skinToneAdjust1"];
        skinHueUniform1 = [filterProgram uniformIndex:@"skinHue1"];
        skinHueThresholdUniform1 = [filterProgram uniformIndex:@"skinHueThreshold1"];
        skinMaxHueShiftUniform1 = [filterProgram uniformIndex:@"skinMaxHueShift1"];
        skinMaxSaturationShiftUniform1 = [filterProgram uniformIndex:@"skinMaxSaturationShift1"];
        skinUpperSkinToneColorUniform1 = [filterProgram uniformIndex:@"skinUpperSkinToneColor1"];
        
        skinToneAdjustUniform2 = [filterProgram uniformIndex:@"skinToneAdjust2"];
        skinHueUniform2 = [filterProgram uniformIndex:@"skinHue2"];
        skinHueThresholdUniform2 = [filterProgram uniformIndex:@"skinHueThreshold2"];
        skinMaxHueShiftUniform2 = [filterProgram uniformIndex:@"skinMaxHueShift2"];
        skinMaxSaturationShiftUniform2 = [filterProgram uniformIndex:@"skinMaxSaturationShift2"];
        skinUpperSkinToneColorUniform2 = [filterProgram uniformIndex:@"skinUpperSkinToneColor2"];
        
        skinToneAdjustUniform3 = [filterProgram uniformIndex:@"skinToneAdjust3"];
        skinHueUniform3 = [filterProgram uniformIndex:@"skinHue3"];
        skinHueThresholdUniform3 = [filterProgram uniformIndex:@"skinHueThreshold3"];
        skinMaxHueShiftUniform3 = [filterProgram uniformIndex:@"skinMaxHueShift3"];
        skinMaxSaturationShiftUniform3 = [filterProgram uniformIndex:@"skinMaxSaturationShift3"];
        skinUpperSkinToneColorUniform3 = [filterProgram uniformIndex:@"skinUpperSkinToneColor3"];
        
        highlightIntensityUniform1 = [filterProgram uniformIndex:@"highlightIntensity1"];
        highlightIntensityUniform2 = [filterProgram uniformIndex:@"highlightIntensity2"];
        highlightIntensityUniform3 = [filterProgram uniformIndex:@"highlightIntensity3"];
        
        shadowIntensityUniform1 = [filterProgram uniformIndex:@"shadowIntensity1"];
        shadowIntensityUniform2 = [filterProgram uniformIndex:@"shadowIntensity2"];
        shadowIntensityUniform3 = [filterProgram uniformIndex:@"shadowIntensity3"];
        
        highlightTintUniform1 = [filterProgram uniformIndex:@"highlightTint1"];
        highlightTintUniform2 = [filterProgram uniformIndex:@"highlightTint2"];
        highlightTintUniform3 = [filterProgram uniformIndex:@"highlightTint3"];
        
        shadowTintUniform1 = [filterProgram uniformIndex:@"shadowTint1"];
        shadowTintUniform2 = [filterProgram uniformIndex:@"shadowTint2"];
        shadowTintUniform3 = [filterProgram uniformIndex:@"shadowTint3"];
        
        
        foregroundColorUniform1 = [filterProgram uniformIndex:@"foregroundColorUniform1"];
        foregroundColorUniform2 = [filterProgram uniformIndex:@"foregroundColorUniform2"];
        foregroundColorUniform3 = [filterProgram uniformIndex:@"foregroundColorUniform3"];
        foregroundColorUniform4 = [filterProgram uniformIndex:@"foregroundColorUniform4"];
        foregroundColorUniform5 = [filterProgram uniformIndex:@"foregroundColorUniform5"];
        foregroundColorUniform6 = [filterProgram uniformIndex:@"foregroundColorUniform6"];
        foregroundColorUniform7 = [filterProgram uniformIndex:@"foregroundColorUniform7"];
        foregroundColorUniform8 = [filterProgram uniformIndex:@"foregroundColorUniform8"];
        
        
        backgroundColorUniform1 = [filterProgram uniformIndex:@"backgroundColorUniform1"];
        backgroundColorUniform2 = [filterProgram uniformIndex:@"backgroundColorUniform2"];
        backgroundColorUniform3 = [filterProgram uniformIndex:@"backgroundColorUniform3"];
        backgroundColorUniform4 = [filterProgram uniformIndex:@"backgroundColorUniform4"];
        backgroundColorUniform5 = [filterProgram uniformIndex:@"backgroundColorUniform5"];
        backgroundColorUniform6 = [filterProgram uniformIndex:@"backgroundColorUniform6"];
        backgroundColorUniform7 = [filterProgram uniformIndex:@"backgroundColorUniform7"];
        backgroundColorUniform8 = [filterProgram uniformIndex:@"backgroundColorUniform8"];
        
        
        brightnessUniform1 = [filterProgram uniformIndex:@"brightness1"];
        brightnessUniform2 = [filterProgram uniformIndex:@"brightness2"];
        brightnessUniform3 = [filterProgram uniformIndex:@"brightness3"];
        brightnessUniform4 = [filterProgram uniformIndex:@"brightness4"];
        brightnessUniform5 = [filterProgram uniformIndex:@"brightness5"];
        brightnessUniform6 = [filterProgram uniformIndex:@"brightness6"];
        brightnessUniform7 = [filterProgram uniformIndex:@"brightness7"];
        brightnessUniform8 = [filterProgram uniformIndex:@"brightness8"];
        
        
        vibranceUniform1 = [filterProgram uniformIndex:@"vibrance1"];
        vibranceUniform2 = [filterProgram uniformIndex:@"vibrance2"];
        vibranceUniform3 = [filterProgram uniformIndex:@"vibrance3"];
        vibranceUniform4 = [filterProgram uniformIndex:@"vibrance4"];
        vibranceUniform5 = [filterProgram uniformIndex:@"vibrance5"];
        vibranceUniform6 = [filterProgram uniformIndex:@"vibrance6"];
        vibranceUniform7 = [filterProgram uniformIndex:@"vibrance7"];
        vibranceUniform8 = [filterProgram uniformIndex:@"vibrance8"];
        
        
        saturationUniform1 = [filterProgram uniformIndex:@"saturation1"];
        saturationUniform2 = [filterProgram uniformIndex:@"saturation2"];
        saturationUniform3 = [filterProgram uniformIndex:@"saturation3"];
        saturationUniform4 = [filterProgram uniformIndex:@"saturation4"];
        saturationUniform5 = [filterProgram uniformIndex:@"saturation5"];
        saturationUniform6 = [filterProgram uniformIndex:@"saturation6"];
        saturationUniform7 = [filterProgram uniformIndex:@"saturation7"];
        saturationUniform8 = [filterProgram uniformIndex:@"saturation8"];
        
        
        
        gammaUniform1 = [filterProgram uniformIndex:@"gamma1"];
        gammaUniform2 = [filterProgram uniformIndex:@"gamma2"];
        gammaUniform3 = [filterProgram uniformIndex:@"gamma3"];
        gammaUniform4 = [filterProgram uniformIndex:@"gamma4"];
        gammaUniform5 = [filterProgram uniformIndex:@"gamma5"];
        gammaUniform6 = [filterProgram uniformIndex:@"gamma6"];
        gammaUniform7 = [filterProgram uniformIndex:@"gamma7"];
        gammaUniform8 = [filterProgram uniformIndex:@"gamma8"];
        
        
        hazeUniform1 = [filterProgram uniformIndex:@"haze1"];
        hazeUniform2 = [filterProgram uniformIndex:@"haze2"];
        hazeUniform3 = [filterProgram uniformIndex:@"haze3"];
        hazeUniform4 = [filterProgram uniformIndex:@"haze4"];
        hazeUniform5 = [filterProgram uniformIndex:@"haze5"];
        hazeUniform6 = [filterProgram uniformIndex:@"haze6"];
        hazeUniform7 = [filterProgram uniformIndex:@"haze7"];
        hazeUniform8 = [filterProgram uniformIndex:@"haze8"];
        
        
        slopeUniform1 = [filterProgram uniformIndex:@"slope1"];
        slopeUniform2 = [filterProgram uniformIndex:@"slope2"];
        slopeUniform3 = [filterProgram uniformIndex:@"slope3"];
        slopeUniform4 = [filterProgram uniformIndex:@"slope4"];
        slopeUniform5 = [filterProgram uniformIndex:@"slope5"];
        slopeUniform6 = [filterProgram uniformIndex:@"slope6"];
        slopeUniform7 = [filterProgram uniformIndex:@"slope7"];
        slopeUniform8 = [filterProgram uniformIndex:@"slope8"];
        
        
        highlightUniform1 = [filterProgram uniformIndex:@"highlight1"];
        highlightUniform2 = [filterProgram uniformIndex:@"highlight2"];
        highlightUniform3 = [filterProgram uniformIndex:@"highlight3"];
        highlightUniform4 = [filterProgram uniformIndex:@"highlight4"];
        highlightUniform5 = [filterProgram uniformIndex:@"highlight5"];
        highlightUniform6 = [filterProgram uniformIndex:@"highlight6"];
        highlightUniform7 = [filterProgram uniformIndex:@"highlight7"];
        highlightUniform8 = [filterProgram uniformIndex:@"highlight8"];
        
        
        
        shadowUniform1 = [filterProgram uniformIndex:@"shadow1"];
        shadowUniform2 = [filterProgram uniformIndex:@"shadow2"];
        shadowUniform3 = [filterProgram uniformIndex:@"shadow3"];
        shadowUniform4 = [filterProgram uniformIndex:@"shadow4"];
        shadowUniform5 = [filterProgram uniformIndex:@"shadow5"];
        shadowUniform6 = [filterProgram uniformIndex:@"shadow6"];
        shadowUniform7 = [filterProgram uniformIndex:@"shadow7"];
        shadowUniform8 = [filterProgram uniformIndex:@"shadow8"];
        
        
        tempUniform1 = [filterProgram uniformIndex:@"temp1"];
        tempUniform2 = [filterProgram uniformIndex:@"temp2"];
        tempUniform3 = [filterProgram uniformIndex:@"temp3"];
        tempUniform4 = [filterProgram uniformIndex:@"temp4"];
        tempUniform5 = [filterProgram uniformIndex:@"temp5"];
        tempUniform6 = [filterProgram uniformIndex:@"temp6"];
        tempUniform7 = [filterProgram uniformIndex:@"temp7"];
        tempUniform8 = [filterProgram uniformIndex:@"temp8"];
        
        
        tempTintUniform1 = [filterProgram uniformIndex:@"tempTint1"];
        tempTintUniform2 = [filterProgram uniformIndex:@"tempTint2"];
        tempTintUniform3 = [filterProgram uniformIndex:@"tempTint3"];
        tempTintUniform4 = [filterProgram uniformIndex:@"tempTint4"];
        tempTintUniform5 = [filterProgram uniformIndex:@"tempTint5"];
        tempTintUniform6 = [filterProgram uniformIndex:@"tempTint6"];
        tempTintUniform7 = [filterProgram uniformIndex:@"tempTint7"];
        tempTintUniform8 = [filterProgram uniformIndex:@"tempTint8"];
        
        
        exposureUniform1 = [filterProgram uniformIndex:@"exposure1"];
        exposureUniform2 = [filterProgram uniformIndex:@"exposure2"];
        exposureUniform3 = [filterProgram uniformIndex:@"exposure3"];
        exposureUniform4 = [filterProgram uniformIndex:@"exposure4"];
        exposureUniform5 = [filterProgram uniformIndex:@"exposure5"];
        exposureUniform6 = [filterProgram uniformIndex:@"exposure6"];
        exposureUniform7 = [filterProgram uniformIndex:@"exposure7"];
        exposureUniform8 = [filterProgram uniformIndex:@"exposure8"];
        
        
        contrastUniform1 = [filterProgram uniformIndex:@"contrast1"];
        contrastUniform2 = [filterProgram uniformIndex:@"contrast2"];
        contrastUniform3 = [filterProgram uniformIndex:@"contrast3"];
        contrastUniform4 = [filterProgram uniformIndex:@"contrast4"];
        contrastUniform5 = [filterProgram uniformIndex:@"contrast5"];
        contrastUniform6 = [filterProgram uniformIndex:@"contrast6"];
        contrastUniform7 = [filterProgram uniformIndex:@"contrast7"];
        contrastUniform8 = [filterProgram uniformIndex:@"contrast8"];
        
        
        lvlminUniform1 = [filterProgram uniformIndex:@"lvlmin1"];
        lvlminUniform2 = [filterProgram uniformIndex:@"lvlmin2"];
        lvlminUniform3 = [filterProgram uniformIndex:@"lvlmin3"];
        
        lvlmidUniform1 = [filterProgram uniformIndex:@"lvlmid1"];
        lvlmidUniform2 = [filterProgram uniformIndex:@"lvlmid2"];
        lvlmidUniform3 = [filterProgram uniformIndex:@"lvlmid3"];
        
        lvlmaxUniform1 = [filterProgram uniformIndex:@"lvlmax1"];
        lvlmaxUniform2 = [filterProgram uniformIndex:@"lvlmax2"];
        lvlmaxUniform3 = [filterProgram uniformIndex:@"lvlmax3"];
        
        lvlmaxoUniform1 = [filterProgram uniformIndex:@"lvlmaxo1"];
        lvlmaxoUniform2 = [filterProgram uniformIndex:@"lvlmaxo2"];
        lvlmaxoUniform3 = [filterProgram uniformIndex:@"lvlmaxo3"];
        
        lvlminoUniform1 = [filterProgram uniformIndex:@"lvlmino1"];
        lvlminoUniform2 = [filterProgram uniformIndex:@"lvlmino2"];
        lvlminoUniform3 = [filterProgram uniformIndex:@"lvlmino3"];
        
        
        rgbUniform1 = [filterProgram uniformIndex:@"colorbalance1"];
        rgbUniform2 = [filterProgram uniformIndex:@"colorbalance2"];
        rgbUniform3 = [filterProgram uniformIndex:@"colorbalance3"];
        
        hsbUniform1 = [filterProgram uniformIndex:@"hsb1"];
        hsbUniform2 = [filterProgram uniformIndex:@"hsb2"];
        hsbUniform3 = [filterProgram uniformIndex:@"hsb3"];
        
        hsbIntensityUniform1 = [filterProgram uniformIndex:@"hsbintensity1"];
        hsbIntensityUniform2 = [filterProgram uniformIndex:@"hsbintensity2"];
        hsbIntensityUniform3 = [filterProgram uniformIndex:@"hsbintensity3"];

        
        [self setFloat:1 forUniform:hsbIntensityUniform1 program:filterProgram];
        [self setFloat:1 forUniform:hsbIntensityUniform2 program:filterProgram];
        [self setFloat:1 forUniform:hsbIntensityUniform3 program:filterProgram];
        fullScaleUniform = [filterProgram uniformIndex:@"fullScale"];
        [self setFullScale:1];
        
        self.mhsb1 = (GPUMatrix4x4){
            {1.f, 0.f, 0.f, 0.f},
            {0.f, 1.f, 0.f, 0.f},
            {0.f, 0.f, 1.f, 0.f},
            {0.f, 0.f, 0.f, 1.f}
        };
        self.mhsb2 = (GPUMatrix4x4){
            {1.f, 0.f, 0.f, 0.f},
            {0.f, 1.f, 0.f, 0.f},
            {0.f, 0.f, 1.f, 0.f},
            {0.f, 0.f, 0.f, 1.f}
        };
        self.mhsb3 = (GPUMatrix4x4){
            {1.f, 0.f, 0.f, 0.f},
            {0.f, 1.f, 0.f, 0.f},
            {0.f, 0.f, 1.f, 0.f},
            {0.f, 0.f, 0.f, 1.f}
        };
        
        
        identmat(matrixhsb1);
        identmat(matrixhsb2);
        identmat(matrixhsb3);
        [self updateHSBMatrix];
        

        
        
    });
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
}
- (void) applyUniformsFrom:(MysticOptions *)options;
{
    for (PackPotionOption *option in options) {
        [option setupFilter:self];
    }
}
- (void) setVignette:(CGPoint)center color:(UIColor *)color start:(CGFloat)start end:(CGFloat)end option:(PackPotionOption *)option;
{
    color = color && isNullOr(color)!=nil ? color : [UIColor blackColor];
    vignetteCenter = (CGPoint){MAX(-2,MIN(2,center.x)),MAX(-2,MIN(2,center.y))};
    vignetteStart = MAX(0,MIN(1,start));
    vignetteEnd = MAX(0,MIN(1,end));
    vignetteColor = (GPUVector4){color.red, color.green, color.blue, color.alpha};
    
    [self setVec4:vignetteColor forUniform:vignetteColorUniform program:filterProgram];
    [self setFloat:vignetteStart forUniform:vignetteStartUniform program:filterProgram];
    [self setFloat:vignetteEnd forUniform:vignetteEndUniform program:filterProgram];
    [self setPoint:vignetteCenter forUniform:vignetteCenterUniform program:filterProgram];



}
- (void) setSkin:(CGFloat)value hue:(CGFloat)value2 hueThreshold:(CGFloat)value3 maxHueShift:(CGFloat)value4 maxSaturation:(CGFloat)value5 upperTone:(CGFloat)value6 index:(int)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1:
            skinToneAdjust1 = value;
            skinHue1 = value2;
            skinHueThreshold1 = value3;
            skinMaxHueShift1 = value4;
            skinMaxSaturationShift1 = value5;
            skinUpperSkinToneColor1 = value6;
            break;
        case 2:
            skinToneAdjust2 = value;
            skinHue2 = value2;
            skinHueThreshold2 = value3;
            skinMaxHueShift2 = value4;
            skinMaxSaturationShift2 = value5;
            skinUpperSkinToneColor2 = value6;
            break;
        case 3:
            skinToneAdjust3 = value;
            skinHue3 = value2;
            skinHueThreshold3 = value3;
            skinMaxHueShift3 = value4;
            skinMaxSaturationShift3 = value5;
            skinUpperSkinToneColor3 = value6;
            break;
            
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"skinToneAdjust%d", (int)index]];
    [self setFloat:value2 forUniformName:[NSString stringWithFormat:@"skinHue%d", (int)index]];
    [self setFloat:value3 forUniformName:[NSString stringWithFormat:@"skinHueThreshold%d", (int)index]];
    [self setFloat:value4 forUniformName:[NSString stringWithFormat:@"skinMaxHueShift%d", (int)index]];
    [self setFloat:value5 forUniformName:[NSString stringWithFormat:@"skinMaxSaturationShift%d", (int)index]];
    [self setInteger:value6 forUniformName:[NSString stringWithFormat:@"skinUpperSkinToneColor%d", (int)index]];

}
- (void) setFullScale:(CGFloat)scale;
{
    fullScale = scale;
    [self setFloat:scale forUniformName:@"fullScale"];
}
- (void) setLevelMin:(float)min mid:(float)mid max:(float)max index:(NSInteger)index option:(PackPotionOption *)option;
{
    [self setLevelMin:min mid:mid max:max minOut:0.0f maxOut:1.0f index:index option:option];
}
- (void) setLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
{
    [self setRedLevelMin:min mid:mid max:max minOut:mino maxOut:maxo index:index option:option];
    [self setGreenLevelMin:min mid:mid max:max minOut:mino maxOut:maxo index:index option:option];
    [self setBlueLevelMin:min mid:mid max:max minOut:mino maxOut:maxo index:index option:option];

}
- (void) setRedLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
{
    
    switch (index) {
        case 1:
        {
            lvlmin1.one = min;
            lvlmid1.one = mid;
            lvlmax1.one = max;
            lvlmino1.one = mino;
            lvlmaxo1.one = maxo;

            break;
        }
        case 2:
        {
            lvlmin2.one = min;
            lvlmid2.one = mid;
            lvlmax2.one = max;
            lvlmino2.one = mino;
            lvlmaxo2.one = maxo;
            break;
        }
        case 3:
        {
            lvlmin3.one = min;
            lvlmid3.one = mid;
            lvlmax3.one = max;
            lvlmino3.one = mino;
            lvlmaxo3.one = maxo;
            break;
        }
        default: break;
    }
    [self updateLevelUniforms:index];
}

- (void) setGreenLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
{
    
    switch (index) {
        case 1:
        {
            lvlmin1.two = min;
            lvlmid1.two = mid;
            lvlmax1.two = max;
            lvlmino1.two = mino;
            lvlmaxo1.two = maxo;
            
            break;
        }
        case 2:
        {
            lvlmin2.two = min;
            lvlmid2.two = mid;
            lvlmax2.two = max;
            lvlmino2.two = mino;
            lvlmaxo2.two = maxo;
            break;
        }
        case 3:
        {
            lvlmin3.two = min;
            lvlmid3.two = mid;
            lvlmax3.two = max;
            lvlmino3.two = mino;
            lvlmaxo3.two = maxo;
            break;
        }
        default: break;
    }
    [self updateLevelUniforms:index];
}
- (void) setAdjustColors:(PackPotionOption *)option index:(NSInteger)index;
{
    index = index == NSNotFound ? option.shaderIndex : index;
    int i = 1;
//    [option printAdjustColors:@"ImageFilter "];
    for (NSDictionary *d in option.adjustColors) {
        UIColor *source = d[@"source"];
        UIColor *color = d[@"color"];
        CGFloat intensity = [d[@"intensity"] floatValue];
        
        MysticThreshold threshold = ThresholdWithArray(d[@"threshold"]);
        if(isNullOr(source)==nil || isNullOr(color)==nil) continue;
        switch (i) {
            case 1:
                adjustColor1 = (GPUVector4){source.red,source.green,source.blue,intensity};
                [self setVec4:adjustColor1 forUniform:adjustColorUniform1 program:filterProgram];
                adjustedColor1 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:adjustedColor1 forUniform:adjustedColorUniform1 program:filterProgram];
                adjustThreshold1 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold1 forUniform:adjustedThresholdUniform1 program:filterProgram];
                adjustRange1 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange1 forUniform:adjustedRangeUniform1 program:filterProgram];
                break;
            case 2:
                  adjustColor2 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor2 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor2 forUniform:  adjustColorUniform2 program:filterProgram];
                [self setVec4:adjustedColor2 forUniform:adjustedColorUniform2 program:filterProgram];
                adjustThreshold2 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold2 forUniform:adjustedThresholdUniform2 program:filterProgram];
                adjustRange2 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange2 forUniform:adjustedRangeUniform2 program:filterProgram];
                break;
            case 3:
                  adjustColor3 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor3 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor3 forUniform:  adjustColorUniform3 program:filterProgram];
                [self setVec4:adjustedColor3 forUniform:adjustedColorUniform3 program:filterProgram];
                adjustThreshold3 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold3 forUniform:adjustedThresholdUniform3 program:filterProgram];
                adjustRange3 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange3 forUniform:adjustedRangeUniform3 program:filterProgram];
                break;
            case 4:
                adjustColor4 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor4 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor4 forUniform:  adjustColorUniform4 program:filterProgram];
                [self setVec4:adjustedColor4 forUniform:adjustedColorUniform4 program:filterProgram];
                adjustThreshold4 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold4 forUniform:adjustedThresholdUniform4 program:filterProgram];
                adjustRange4 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange4 forUniform:adjustedRangeUniform4 program:filterProgram];
                break;
            case 5:
                adjustColor5 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor5 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor5 forUniform:  adjustColorUniform5 program:filterProgram];
                [self setVec4:adjustedColor5 forUniform:adjustedColorUniform5 program:filterProgram];
                adjustThreshold5 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold5 forUniform:adjustedThresholdUniform5 program:filterProgram];
                adjustRange5 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange5 forUniform:adjustedRangeUniform5 program:filterProgram];
                break;
            case 6:
                adjustColor6 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor6 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor6 forUniform:  adjustColorUniform6 program:filterProgram];
                [self setVec4:adjustedColor6 forUniform:adjustedColorUniform6 program:filterProgram];
                adjustThreshold6 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold6 forUniform:adjustedThresholdUniform6 program:filterProgram];
                adjustRange6 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange6 forUniform:adjustedRangeUniform6 program:filterProgram];
                break;
            case 7:
                adjustColor7 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor7 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor7 forUniform:  adjustColorUniform7 program:filterProgram];
                [self setVec4:adjustedColor7 forUniform:adjustedColorUniform7 program:filterProgram];
                adjustThreshold7 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold7 forUniform:adjustedThresholdUniform7 program:filterProgram];
                adjustRange7 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange7 forUniform:adjustedRangeUniform7 program:filterProgram];
                break;
            case 8:
                  adjustColor8 = (GPUVector4){source.red,source.green,source.blue,intensity};
                adjustedColor8 = (GPUVector4){color.red,color.green,color.blue,intensity};
                [self setVec4:  adjustColor8 forUniform:  adjustColorUniform8 program:filterProgram];
                [self setVec4:adjustedColor8 forUniform:adjustedColorUniform8 program:filterProgram];
                adjustThreshold8 = (GPUVector3){threshold.threshold,threshold.smoothing,threshold.intensity};
                [self setVec3:adjustThreshold8 forUniform:adjustedThresholdUniform8 program:filterProgram];
                adjustRange8 = (GPUVector3){threshold.range.min,threshold.range.mid,threshold.range.max};
                [self setVec3:adjustRange8 forUniform:adjustedRangeUniform8 program:filterProgram];
                break;
            default:
                break;
        }
        i++;
    }
}
- (void) setBlueLevelMin:(float)min mid:(float)mid max:(float)max minOut:(float)mino maxOut:(float)maxo index:(NSInteger)index option:(PackPotionOption *)option;
{
    
    switch (index) {
        case 1:
        {
            lvlmin1.three = min;
            lvlmid1.three = mid;
            lvlmax1.three = max;
            lvlmino1.three = mino;
            lvlmaxo1.three = maxo;
            
            break;
        }
        case 2:
        {
            lvlmin2.three = min;
            lvlmid2.three = mid;
            lvlmax2.three = max;
            lvlmino2.three = mino;
            lvlmaxo2.three = maxo;
            break;
        }
        case 3:
        {
            lvlmin3.three = min;
            lvlmid3.three = mid;
            lvlmax3.three = max;
            lvlmino3.three = mino;
            lvlmaxo3.three = maxo;
            break;
        }
        default: break;
    }
    [self updateLevelUniforms:index];
}


- (void)updateLevelUniforms:(NSInteger)index {
    switch (index) {
        case 1:
        {
            [self setVec3:lvlmin1 forUniform:lvlminUniform1 program:filterProgram];
            [self setVec3:lvlmid1 forUniform:lvlmidUniform1 program:filterProgram];
            [self setVec3:lvlmax1 forUniform:lvlmaxUniform1 program:filterProgram];
            [self setVec3:lvlmino1 forUniform:lvlminoUniform1 program:filterProgram];
            [self setVec3:lvlmaxo1 forUniform:lvlmaxoUniform1 program:filterProgram];
            break;
        }
        case 2:
        {
            [self setVec3:lvlmin2 forUniform:lvlminUniform2 program:filterProgram];
            [self setVec3:lvlmid2 forUniform:lvlmidUniform2 program:filterProgram];
            [self setVec3:lvlmax2 forUniform:lvlmaxUniform2 program:filterProgram];
            [self setVec3:lvlmino2 forUniform:lvlminoUniform2 program:filterProgram];
            [self setVec3:lvlmaxo2 forUniform:lvlmaxoUniform2 program:filterProgram];
            break;
        }
        case 3:
        {
            [self setVec3:lvlmin3 forUniform:lvlminUniform3 program:filterProgram];
            [self setVec3:lvlmid3 forUniform:lvlmidUniform3 program:filterProgram];
            [self setVec3:lvlmax3 forUniform:lvlmaxUniform3 program:filterProgram];
            [self setVec3:lvlmino3 forUniform:lvlminoUniform3 program:filterProgram];
            [self setVec3:lvlmaxo3 forUniform:lvlmaxoUniform3 program:filterProgram];
            break;
        }
        default: break;
    }


}
- (void) setHSB:(MysticHSB)hsb intensity:(CGFloat)intensity index:(NSInteger)index option:(PackPotionOption *)option;
{
    intensity = MAX(0, intensity);
    intensity = MIN(1, intensity);
    
    [self resetHSB:index];
    switch (index) {
        case 1:
        {
            [self setFloat:intensity forUniform:hsbIntensityUniform1 program:filterProgram];
            huerotatemat(matrixhsb1, hsb.hue);
            saturatemat(matrixhsb1, hsb.saturation);
            cscalemat(matrixhsb1, hsb.brightness, hsb.brightness, hsb.brightness);
            [self updateHSBMatrix:1];
            break;
        }
        case 2:
        {
            [self setFloat:intensity forUniform:hsbIntensityUniform2 program:filterProgram];
            huerotatemat(matrixhsb2, hsb.hue);
            saturatemat(matrixhsb2, hsb.saturation);
            cscalemat(matrixhsb2, hsb.brightness, hsb.brightness, hsb.brightness);
            [self updateHSBMatrix:2];
            break;
        }
        case 3:
        {
            [self setFloat:intensity forUniform:hsbIntensityUniform3 program:filterProgram];
            huerotatemat(matrixhsb3, hsb.hue);
            saturatemat(matrixhsb3, hsb.saturation);
            cscalemat(matrixhsb3, hsb.brightness, hsb.brightness, hsb.brightness);
            [self updateHSBMatrix:3];
            break;
        }
        default: break;
    }
    
}
- (void) setColorBalance:(GPUVector3)rgb index:(NSInteger)index option:(PackPotionOption *)option;
{
    
    switch (index) {
        case 1:
        {
            rgb1 = rgb;
            [self setVec3:rgb1 forUniform:rgbUniform1 program:filterProgram];

            break;
        }
        case 2:
        {
            rgb2 = rgb;
            [self setVec3:rgb2 forUniform:rgbUniform2 program:filterProgram];

            break;
        }
        case 3:
        {
            rgb3 = rgb;
            [self setVec3:rgb3 forUniform:rgbUniform3 program:filterProgram];

            break;
        }
        default: break;
    }
}


- (void) setContrast:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: contrast1 = value; break; 
        case 2: contrast2 = value; break; 
        case 3: contrast3 = value; break; 
        case 4: contrast4 = value; break; 
        case 5: contrast5 = value; break; 
        case 6: contrast6 = value; break; 
        case 7: contrast7 = value; break; 
        case 8: contrast8 = value; break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"contrast%d", (int)index]];
}
- (void) setExposure:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: exposure1 = value; break; 
        case 2: exposure2 = value; break; 
        case 3: exposure3 = value; break; 
        case 4: exposure4 = value; break; 
        case 5: exposure5 = value; break; 
        case 6: exposure6 = value; break; 
        case 7: exposure7 = value; break; 
        case 8: exposure8 = value; break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"exposure%d", (int)index]];
}
- (void) setGamma:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: gamma1 = value; break; 
        case 2: gamma2 = value; break; 
        case 3: gamma3 = value; break; 
        case 4: gamma4 = value; break; 
        case 5: gamma5 = value; break; 
        case 6: gamma6 = value; break; 
        case 7: gamma7 = value; break; 
        case 8: gamma8 = value; break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"gamma%d", (int)index]];
}
- (void) setHaze:(float)value slope:(float)value2 index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: haze1 = value;
            slope1 = value2; break; 
        case 2: haze2 = value;
            slope2 = value2;
             break; 
        case 3: haze3 = value;
            slope3 = value2;
             break; 
        case 4: haze4 = value;
            slope4 = value2;
             break; 
        case 5: haze5 = value;
            slope5 = value2;
             break; 
        case 6: haze6 = value;
            slope6 = value2;
             break; 
        case 7: haze7 = value;
            slope7 = value2;
             break; 
        case 8: haze8 = value;
            slope8 = value2;
             break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"haze%d", (int)index]];
    [self setFloat:value2 forUniformName:[NSString stringWithFormat:@"slope%d", (int)index]];
    
}
- (void) setShadow:(float)value highlight:(float)value2 index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: shadow1 = value;
            highlight1 = value2; break; 
        case 2: shadow2 = value;
            highlight2 = value2;
             break; 
        case 3: shadow3 = value;
            highlight3 = value2;
             break; 
        case 4: shadow4 = value;
            highlight4 = value2;
             break; 
        case 5: shadow5 = value;
            highlight5 = value2;
             break; 
        case 6: shadow6 = value;
            highlight6 = value2;
             break; 
        case 7: shadow7 = value;
            highlight7 = value2;
             break; 
        case 8: shadow8 = value;
            highlight8 = value2;
             break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"shadow%d", (int)index]];
    [self setFloat:value2 forUniformName:[NSString stringWithFormat:@"highlight%d", (int)index]];
}
- (void) setTemp:(float)value tint:(float)value2 index:(NSInteger)index option:(PackPotionOption *)option;
{
    float newvalue = value < 5000 ? 0.0004 * (value-5000.0) : 0.00006 * (value-5000.0);
    float newvalue2 = value2 / 100.0;
    
    switch (index) {
        case 1: temp1 = value;
            tempTint1 = value2; break; 
        case 2: temp2 = value;
            tempTint2 = value2;
             break; 
        case 3: temp3 = value;
            tempTint3 = value2;
             break; 
        case 4: temp4 = value;
            tempTint4 = value2;
             break; 
        case 5: temp5 = value;
            tempTint5 = value2;
             break; 
        case 6: temp6 = value;
            tempTint6 = value2;
             break; 
        case 7: temp7 = value;
            tempTint7 = value2;
             break; 
        case 8: temp8 = value;
            tempTint8 = value2;
             break; 
        default: break;
    }
    [self setFloat:newvalue forUniformName:[NSString stringWithFormat:@"temp%d", (int)index]];
    [self setFloat:newvalue2 forUniformName:[NSString stringWithFormat:@"tempTint%d", (int)index]];
    
}
- (void) setFalseDark:(UIColor *)color light:(UIColor *)color2 index:(NSInteger)index option:(PackPotionOption *)option;
{
    if(isNullOr(color)==nil)return;
    if(isNullOr(color2)==nil)return;

    GPUVector4 acolor1 = {color.red, color.green, color.blue, color.alpha};
    GPUVector4 acolor2 = {color2.red, color2.green, color2.blue, color2.alpha};
    
    switch (index) {
        case 1:
            falseDark1 = acolor1;
            [self setVec4:falseDark1 forUniform:falseDarkUniform1 program:filterProgram];
            
            falseLight1 = acolor2;
            [self setVec4:falseLight1 forUniform:falseLightUniform1 program:filterProgram];
            
            break;
        case 2:
            falseDark2 = acolor1;
            [self setVec4:falseDark2 forUniform:falseDarkUniform2 program:filterProgram];
            
            falseLight2 = acolor2;
            [self setVec4:falseLight2 forUniform:falseLightUniform2 program:filterProgram];
            
            
            break;
        case 3:
            falseDark3 = acolor1;
            [self setVec4:falseDark3 forUniform:falseDarkUniform3 program:filterProgram];
            
            falseLight3 = acolor2;
            [self setVec4:falseLight3 forUniform:falseLightUniform3 program:filterProgram];
            break;
        case 4:
            falseDark4 = acolor1;
            [self setVec4:falseDark4 forUniform:falseDarkUniform4 program:filterProgram];
            
            falseLight4 = acolor2;
            [self setVec4:falseLight4 forUniform:falseLightUniform4 program:filterProgram];
            
            
            break;
        case 5:
            falseDark5 = acolor1;
            [self setVec4:falseDark5 forUniform:falseDarkUniform5 program:filterProgram];
            
            falseLight5 = acolor2;
            [self setVec4:falseLight5 forUniform:falseLightUniform5 program:filterProgram];
            break;
        case 6:
            falseDark6 = acolor1;
            [self setVec4:falseDark6 forUniform:falseDarkUniform6 program:filterProgram];
            
            falseLight6 = acolor2;
            [self setVec4:falseLight6 forUniform:falseLightUniform6 program:filterProgram];
            break;
        case 7:
            falseDark7 = acolor1;
            [self setVec4:falseDark7 forUniform:falseDarkUniform7 program:filterProgram];
            
            falseLight7 = acolor2;
            [self setVec4:falseLight7 forUniform:falseLightUniform7 program:filterProgram];
            break;
        case 8:
            falseDark8 = acolor1;
            [self setVec4:falseDark8 forUniform:falseDarkUniform8 program:filterProgram];
            
            falseLight8 = acolor2;
            [self setVec4:falseLight8 forUniform:falseLightUniform8 program:filterProgram];
            break;
        default:
            return;
            break;
    }
}
- (void) setSaturation:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: saturation1 = value; break;
        case 2: saturation2 = value; break; 
        case 3: saturation3 = value; break; 
        case 4: saturation4 = value; break; 
        case 5: saturation5 = value; break; 
        case 6: saturation6 = value; break; 
        case 7: saturation7 = value; break; 
        case 8: saturation8 = value; break; 
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"saturation%d", (int)index]];
}
- (void) setBrightest:(float)value darkest:(float)darkest option:(PackPotionOption *)option;
{
    brightest1 = value;
    darkest1 = darkest;
    [self setFloat:brightest1 forUniform:brightestUniform1 program:filterProgram];
    [self setFloat:darkest1 forUniform:darkestUniform1 program:filterProgram];

}
- (void) setBrightness:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: brightness1 = value; break;
        case 2: brightness2 = value; break;
        case 3: brightness3 = value; break;
        case 4: brightness4 = value; break;
        case 5: brightness5 = value; break;
        case 6: brightness6 = value; break;
        case 7: brightness7 = value; break;
        case 8: brightness8 = value; break;
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"brightness%d", (int)index]];
}
- (void) setHighlightIntensity:(CGFloat)value tint:(UIColor *)tint index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: highlightIntensity1=value;  break;
        case 2: highlightIntensity2=value; break;
        case 3: highlightIntensity3=value; break;
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"highlightIntensity%d", (int)index]];
    tint = tint ? tint : [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    GPUVector4 color = {tint.red, tint.green, tint.blue, tint.alpha};
    switch (index) {
        case 1:
            highlightTint1 = color;
            [self setVec4:highlightTint1 forUniform:highlightTintUniform1 program:filterProgram];
            
            break;
        case 2:
            highlightTint2 = color;
            [self setVec4:highlightTint2 forUniform:highlightTintUniform2 program:filterProgram];
            break;
        case 3:
            highlightTint3 = color;
            [self setVec4:highlightTint3 forUniform:highlightTintUniform3 program:filterProgram];
            break;
        default: break;
    }
}
- (void) setShadowIntensity:(CGFloat)value tint:(UIColor *)tint index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: shadowIntensity1=value;  break;
        case 2: shadowIntensity2=value; break;
        case 3: shadowIntensity3=value; break;
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"shadowIntensity%d", (int)index]];
    tint = tint ? tint : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    GPUVector4 color = {tint.red, tint.green, tint.blue, tint.alpha};
    switch (index) {
        case 1:
            shadowTint1 = color;
            [self setVec4:shadowTint1 forUniform:shadowTintUniform1 program:filterProgram];
            
            break;
        case 2:
            shadowTint2 = color;
            [self setVec4:shadowTint2 forUniform:shadowTintUniform2 program:filterProgram];
            break;
        case 3:
            shadowTint3 = color;
            [self setVec4:shadowTint3 forUniform:shadowTintUniform3 program:filterProgram];
            break;
        default: break;
    }
}
- (void) setGrainTime:(CGFloat)time alpha:(CGFloat)alpha threshold:(CGFloat)threshold color:(UIColor *)color option:(PackPotionOption *)option;
{
    [self setFloat:time forUniformName:@"grainTime"];
    [self setFloat:alpha forUniformName:@"grainAlpha"];
    [self setFloat:threshold forUniformName:@"grainThreshold"];
    GPUVector4 agrainColor = {color.red, color.green, color.blue, color.alpha};
    grainColor = agrainColor;
    grainTime = time;
    grainAlpha = alpha;
    grainThreshold = threshold;
    [self setVec4:agrainColor forUniform:grainColorUniform program:filterProgram];


}
- (void) setVibrance:(float)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1: vibrance1 = value; break;
        case 2: vibrance2 = value; break;
        case 3: vibrance3 = value; break;
        case 4: vibrance4 = value; break;
        case 5: vibrance5 = value; break;
        case 6: vibrance6 = value; break;
        case 7: vibrance7 = value; break;
        case 8: vibrance8 = value; break;
        default: break;
    }
    [self setFloat:value forUniformName:[NSString stringWithFormat:@"vibrance%d", (int)index]];
}
- (void) setForegroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;
{
    if(isNullOr(color)==nil)return;
    GPUVector4 foregroundColor = {color.red, color.green, color.blue, color.alpha};
    switch (index) {
        case 1:
            foregroundColor1 = foregroundColor;
            [self setVec4:foregroundColor1 forUniform:foregroundColorUniform1 program:filterProgram];
            
            break;
        case 2:
            foregroundColor2 = foregroundColor;
            [self setVec4:foregroundColor2 forUniform:foregroundColorUniform2 program:filterProgram];
            break;
        case 3:
            foregroundColor3 = foregroundColor;
            [self setVec4:foregroundColor3 forUniform:foregroundColorUniform3 program:filterProgram];
            break;
        case 4:
            foregroundColor4 = foregroundColor;
            [self setVec4:foregroundColor4 forUniform:foregroundColorUniform4 program:filterProgram];
            break;
        case 5:
            foregroundColor5 = foregroundColor;
            [self setVec4:foregroundColor5 forUniform:foregroundColorUniform5 program:filterProgram];
            break;
        case 6:
            foregroundColor6 = foregroundColor;
            [self setVec4:foregroundColor6 forUniform:foregroundColorUniform6 program:filterProgram];
            break;
        case 7:
            foregroundColor7 = foregroundColor;
            [self setVec4:foregroundColor7 forUniform:foregroundColorUniform7 program:filterProgram];
            break;
        case 8:
            foregroundColor8 = foregroundColor;
            [self setVec4:foregroundColor8 forUniform:foregroundColorUniform8 program:filterProgram];
            break;
        default:
            return;
            break;
    }
    
}

- (void) setBackgroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;
{
    if(isNullOr(color)==nil)return;
    GPUVector4 backgroundColor = {color.red, color.green, color.blue, color.alpha};
    //    GLint coloruniform = 0;
    switch (index) {
        case 1:
            //            //coloruniform = backgroundColorUniform1;
            backgroundColor1 = backgroundColor;
            [self setVec4:backgroundColor1 forUniform:backgroundColorUniform1 program:filterProgram];
            
            break;
        case 2:
            //coloruniform = backgroundColorUniform2;
            backgroundColor2 = backgroundColor;
            [self setVec4:backgroundColor2 forUniform:backgroundColorUniform2 program:filterProgram];
            break;
        case 3:
            //coloruniform = backgroundColorUniform3;
            backgroundColor3 = backgroundColor;
            [self setVec4:backgroundColor3 forUniform:backgroundColorUniform3 program:filterProgram];
            break;
        case 4:
            //coloruniform = backgroundColorUniform4;
            backgroundColor4 = backgroundColor;
            [self setVec4:backgroundColor4 forUniform:backgroundColorUniform4 program:filterProgram];
            break;
        case 5:
            //coloruniform = backgroundColorUniform5;
            backgroundColor5 = backgroundColor;
            [self setVec4:backgroundColor5 forUniform:backgroundColorUniform5 program:filterProgram];
            break;
        case 6:
            //coloruniform = backgroundColorUniform6;
            backgroundColor6 = backgroundColor;
            [self setVec4:backgroundColor6 forUniform:backgroundColorUniform6 program:filterProgram];
            break;
        case 7:
            //coloruniform = backgroundColorUniform7;
            backgroundColor7 = backgroundColor;
            [self setVec4:backgroundColor7 forUniform:backgroundColorUniform7 program:filterProgram];
            break;
        case 8:
            //coloruniform = backgroundColorUniform8;
            backgroundColor8 = backgroundColor;
            [self setVec4:backgroundColor8 forUniform:backgroundColorUniform8 program:filterProgram];
            break;
        default:
            return;
            break;
    }
    
}

- (void) setMaskBackgroundColor:(UIColor *)color index:(NSInteger)index option:(PackPotionOption *)option;
{
    if(isNullOr(color)==nil)return;
    GPUVector4 maskBackgroundColor = {color.red, color.green, color.blue, color.alpha};
    //    GLint coloruniform = 0;
    switch (index) {
        case 1:
            //coloruniform = maskBackgroundColorUniform1;
            maskBackgroundColor1 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor1 forUniform:maskBackgroundColorUniform1 program:filterProgram];
            
            break;
        case 2:
            //coloruniform = maskBackgroundColorUniform2;
            maskBackgroundColor2 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor2 forUniform:maskBackgroundColorUniform2 program:filterProgram];
            break;
        case 3:
            //coloruniform = maskBackgroundColorUniform3;
            maskBackgroundColor3 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor3 forUniform:maskBackgroundColorUniform3 program:filterProgram];
            break;
        case 4:
            //coloruniform = maskBackgroundColorUniform4;
            maskBackgroundColor4 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor4 forUniform:maskBackgroundColorUniform4 program:filterProgram];
            break;
        case 5:
            //coloruniform = maskBackgroundColorUniform5;
            maskBackgroundColor5 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor5 forUniform:maskBackgroundColorUniform5 program:filterProgram];
            break;
        case 6:
            //coloruniform = maskBackgroundColorUniform6;
            maskBackgroundColor6 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor6 forUniform:maskBackgroundColorUniform6 program:filterProgram];
            break;
        case 7:
            //coloruniform = maskBackgroundColorUniform7;
            maskBackgroundColor7 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor7 forUniform:maskBackgroundColorUniform7 program:filterProgram];
            break;
        case 8:
            //coloruniform = maskBackgroundColorUniform8;
            maskBackgroundColor8 = maskBackgroundColor;
            [self setVec4:maskBackgroundColor8 forUniform:maskBackgroundColorUniform8 program:filterProgram];
            break;
        default:
            return;
            break;
    }
    
}


- (void) setIntensity:(CGFloat)value index:(NSInteger)index option:(PackPotionOption *)option;
{
    switch (index) {
        case 1:
            [self setIntensity1:value];
            break;
        case 2:
            [self setIntensity2:value];
            break;
        case 3:
            [self setIntensity3:value];
            break;
        case 4:
            [self setIntensity4:value];
            break;
        case 5:
            [self setIntensity5:value];
            break;
        case 6:
            [self setIntensity6:value];
            break;
        case 7:
            [self setIntensity7:value];
            break;
        case 8:
            [self setIntensity8:value];
            break;
        default: break;
    }
}
- (void)setIntensity1:(CGFloat)newValue;
{
    _intensity1 = newValue;
    
    [self setFloat:_intensity1 forUniform:intensityUniform1 program:filterProgram];
}

- (void)setIntensity2:(CGFloat)newValue;
{
    _intensity2 = newValue;
    
    [self setFloat:_intensity2 forUniform:intensityUniform2 program:filterProgram];
}

- (void)setIntensity3:(CGFloat)newValue;
{
    _intensity3 = newValue;
    
    [self setFloat:_intensity3 forUniform:intensityUniform3 program:filterProgram];
}

- (void)setIntensity4:(CGFloat)newValue;
{
    _intensity4 = newValue;
    
    [self setFloat:_intensity4 forUniform:intensityUniform4 program:filterProgram];
}

- (void)setIntensity5:(CGFloat)newValue;
{
    _intensity5 = newValue;
    
    [self setFloat:_intensity5 forUniform:intensityUniform5 program:filterProgram];
}

- (void)setIntensity6:(CGFloat)newValue;
{
    _intensity6 = newValue;
    
    [self setFloat:_intensity6 forUniform:intensityUniform6 program:filterProgram];
}

- (void)setIntensity7:(CGFloat)newValue;
{
    _intensity7 = newValue;
    
    [self setFloat:_intensity7 forUniform:intensityUniform7 program:filterProgram];
}

- (void)setIntensity8:(CGFloat)newValue;
{
    _intensity8 = newValue;
    
    [self setFloat:_intensity8 forUniform:intensityUniform8 program:filterProgram];
}

- (void) textureCheckedIn:(NSInteger)textureIndex;
{
}
- (void) resetAllFrameChecks;
{
    
}
//
//- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
//{
//    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
//
//}
- (void) disableAll;
{
    [self disableAllExcept:0];
}
- (void) disableAllExcept:(int)f;
{
    if(f != 1) [self disableFrameCheck:1];
    if(f != 2) [self disableFrameCheck:2];
    if(f != 3) [self disableFrameCheck:3];
    if(f != 4) [self disableFrameCheck:4];
    if(f != 5) [self disableFrameCheck:5];
    if(f != 6) [self disableFrameCheck:6];
    if(f != 7) [self disableFrameCheck:7];
    if(f != 8) [self disableFrameCheck:8];
    
}
- (void) disableUnknown;
{
    
}
- (void) disableFrameCheck:(int)frameNum;
{
    SEL s = @selector(disableUnknown);
    NSString *selectorStr = @"disableUnknown";
    
    switch (frameNum) {
        case 1:
            s = @selector(disableFrameCheck1);
            
            break;
        case 2:
            s = @selector(disableFrameCheck2);
            
            break;
        case 3:
            s = @selector(disableFrameCheck3);
            
            break;
        case 4:
            s = @selector(disableFrameCheck4);
            
            break;
        case 5:
            s = @selector(disableFrameCheck5);
            
            break;
        case 6:
            s = @selector(disableFrameCheck6);
            
            break;
        case 7:
            s = @selector(disableFrameCheck7);
            
            break;
        case 8:
            s = @selector(disableFrameCheck8);
            
            break;
            
        default:
            s = @selector(disableUnknown);
            break;
    }
    if([self respondsToSelector:s])
    {
        [self performSelector:s];
    }
}

//
//- (void) useNextFrameForImageCapture;
//{
//    DDLogWarn(@"Running Use next frame for image capture: %@", self);
//    [super useNextFrameForImageCapture];
//}


- (BOOL) updateFrame:(MysticBlock)completion;
{
    DLog(@"refreshing frame");
    if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        DLog(@"dont update frame");
        return NO;
    }
    __unsafe_unretained __block MysticImageFilter *weakSelf = self;
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        [weakSelf newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        
        dispatch_semaphore_signal(imageUpdateSemaphore);
        
        if (completion != nil) {
            completion();
        }
    });
    return YES;
}

- (void)resetHSB;
{
    [self resetHSB:1];
    [self resetHSB:2];
    [self resetHSB:3];

}
- (void)resetHSB:(int)index {
    
    switch (index) {
        case 1: identmat(matrixhsb1); [self updateHSBMatrix:1]; break;
        case 2: identmat(matrixhsb2); [self updateHSBMatrix:2]; break;
        case 3: identmat(matrixhsb3); [self updateHSBMatrix:3]; break;
        default: break;
    }
    
}
- (void)updateHSBMatrix {
    [self updateHSBMatrix:1];
    [self updateHSBMatrix:2];
    [self updateHSBMatrix:3];

}
- (void)updateHSBMatrix:(int)index {

    switch (index) {
        case 1:
        {
            GPUMatrix4x4 gpuMatrix;
            gpuMatrix.one.one = matrixhsb1[0][0];
            gpuMatrix.one.two = matrixhsb1[1][0];
            gpuMatrix.one.three = matrixhsb1[2][0];
            gpuMatrix.one.four = matrixhsb1[3][0];
            gpuMatrix.two.one = matrixhsb1[0][1];
            gpuMatrix.two.two = matrixhsb1[1][1];
            gpuMatrix.two.three = matrixhsb1[2][1];
            gpuMatrix.two.four = matrixhsb1[3][1];
            gpuMatrix.three.one = matrixhsb1[0][2];
            gpuMatrix.three.two = matrixhsb1[1][2];
            gpuMatrix.three.three = matrixhsb1[2][2];
            gpuMatrix.three.four = matrixhsb1[3][2];
            gpuMatrix.four.one = matrixhsb1[0][3];
            gpuMatrix.four.two = matrixhsb1[1][3];
            gpuMatrix.four.three = matrixhsb1[2][3];
            gpuMatrix.four.four = matrixhsb1[3][3];
            self.mhsb1 = gpuMatrix;
            [self setMatrix4f:self.mhsb1 forUniform:hsbUniform1 program:filterProgram];
            break;
        }
        case 2:
        {
            GPUMatrix4x4 gpuMatrix2;
            gpuMatrix2.one.one = matrixhsb2[0][0];
            gpuMatrix2.one.two = matrixhsb2[1][0];
            gpuMatrix2.one.three = matrixhsb2[2][0];
            gpuMatrix2.one.four = matrixhsb2[3][0];
            gpuMatrix2.two.one = matrixhsb2[0][1];
            gpuMatrix2.two.two = matrixhsb2[1][1];
            gpuMatrix2.two.three = matrixhsb2[2][1];
            gpuMatrix2.two.four = matrixhsb2[3][1];
            gpuMatrix2.three.one = matrixhsb2[0][2];
            gpuMatrix2.three.two = matrixhsb2[1][2];
            gpuMatrix2.three.three = matrixhsb2[2][2];
            gpuMatrix2.three.four = matrixhsb2[3][2];
            gpuMatrix2.four.one = matrixhsb2[0][3];
            gpuMatrix2.four.two = matrixhsb2[1][3];
            gpuMatrix2.four.three = matrixhsb2[2][3];
            gpuMatrix2.four.four = matrixhsb2[3][3];
            self.mhsb2 = gpuMatrix2;
            [self setMatrix4f:self.mhsb2 forUniform:hsbUniform2 program:filterProgram];
            break;
        }
        case 3:
        {
            GPUMatrix4x4 gpuMatrix3;
            gpuMatrix3.one.one = matrixhsb3[0][0];
            gpuMatrix3.one.two = matrixhsb3[1][0];
            gpuMatrix3.one.three = matrixhsb3[2][0];
            gpuMatrix3.one.four = matrixhsb3[3][0];
            gpuMatrix3.two.one = matrixhsb3[0][1];
            gpuMatrix3.two.two = matrixhsb3[1][1];
            gpuMatrix3.two.three = matrixhsb3[2][1];
            gpuMatrix3.two.four = matrixhsb3[3][1];
            gpuMatrix3.three.one = matrixhsb3[0][2];
            gpuMatrix3.three.two = matrixhsb3[1][2];
            gpuMatrix3.three.three = matrixhsb3[2][2];
            gpuMatrix3.three.four = matrixhsb3[3][2];
            gpuMatrix3.four.one = matrixhsb3[0][3];
            gpuMatrix3.four.two = matrixhsb3[1][3];
            gpuMatrix3.four.three = matrixhsb3[2][3];
            gpuMatrix3.four.four = matrixhsb3[3][3];
            self.mhsb3 = gpuMatrix3;
            [self setMatrix4f:self.mhsb3 forUniform:hsbUniform3 program:filterProgram];
            break;
        }
        default: break;
    }
    
    
    
    
    
}


#pragma mark - Matrix algorithms

/* Matrix algorithms adapted from http://www.graficaobscura.com/matrix/index.html
 
 Note about luminance vector values below from that page:
 Where rwgt is 0.3086, gwgt is 0.6094, and bwgt is 0.0820. This is the luminance vector. Notice here that we do not use the standard NTSC weights of 0.299, 0.587, and 0.114. The NTSC weights are only applicable to RGB colors in a gamma 2.2 color space. For linear RGB colors the values above are better.
 */
//#define RLUM (0.3086f)
//#define GLUM (0.6094f)
//#define BLUM (0.0820f)

/* This is the vector value from the PDF specification, and may be closer to what Photoshop uses */
#define RLUM (0.3f)
#define GLUM (0.59f)
#define BLUM (0.11f)

/*
 *	matrixmult -
 *		multiply two matricies
 */
static void matrixmult(a,b,c)
float a[4][4], b[4][4], c[4][4];
{
    int x, y;
    float temp[4][4];
    
    for(y=0; y<4 ; y++)
        for(x=0 ; x<4 ; x++) {
            temp[y][x] = b[y][0] * a[0][x]
            + b[y][1] * a[1][x]
            + b[y][2] * a[2][x]
            + b[y][3] * a[3][x];
        }
    for(y=0; y<4; y++)
        for(x=0; x<4; x++)
            c[y][x] = temp[y][x];
}

/*
 *	identmat -
 *		make an identity matrix
 */
static void identmat(matrix)
float matrix[4][4];
{
    memset(matrix, 0, sizeof(float[4][4]));
    matrix[0][0] = 1.0f;
    matrix[1][1] = 1.0f;
    matrix[2][2] = 1.0f;
    matrix[3][3] = 1.0f;
}

/*
 *	xformpnt -
 *		transform a 3D point using a matrix
 */
static void xformpnt(matrix,x,y,z,tx,ty,tz)
float matrix[4][4];
float x,y,z;
float *tx,*ty,*tz;
{
    *tx = x*matrix[0][0] + y*matrix[1][0] + z*matrix[2][0] + matrix[3][0];
    *ty = x*matrix[0][1] + y*matrix[1][1] + z*matrix[2][1] + matrix[3][1];
    *tz = x*matrix[0][2] + y*matrix[1][2] + z*matrix[2][2] + matrix[3][2];
}

/*
 *	cscalemat -
 *		make a color scale marix
 */
static void cscalemat(mat,rscale,gscale,bscale)
float mat[4][4];
float rscale, gscale, bscale;
{
    float mmat[4][4];
    
    mmat[0][0] = rscale;
    mmat[0][1] = 0.0;
    mmat[0][2] = 0.0;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = 0.0;
    mmat[1][1] = gscale;
    mmat[1][2] = 0.0;
    mmat[1][3] = 0.0;
    
    
    mmat[2][0] = 0.0;
    mmat[2][1] = 0.0;
    mmat[2][2] = bscale;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	saturatemat -
 *		make a saturation marix
 */
static void saturatemat(mat,sat)
float mat[4][4];
float sat;
{
    float mmat[4][4];
    float a, b, c, d, e, f, g, h, i;
    float rwgt, gwgt, bwgt;
    
    rwgt = RLUM;
    gwgt = GLUM;
    bwgt = BLUM;
    
    a = (1.0-sat)*rwgt + sat;
    b = (1.0-sat)*rwgt;
    c = (1.0-sat)*rwgt;
    d = (1.0-sat)*gwgt;
    e = (1.0-sat)*gwgt + sat;
    f = (1.0-sat)*gwgt;
    g = (1.0-sat)*bwgt;
    h = (1.0-sat)*bwgt;
    i = (1.0-sat)*bwgt + sat;
    mmat[0][0] = a;
    mmat[0][1] = b;
    mmat[0][2] = c;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = d;
    mmat[1][1] = e;
    mmat[1][2] = f;
    mmat[1][3] = 0.0;
    
    mmat[2][0] = g;
    mmat[2][1] = h;
    mmat[2][2] = i;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	xrotate -
 *		rotate about the x (red) axis
 */
static void xrotatemat(mat,rs,rc)
float mat[4][4];
float rs, rc;
{
    float mmat[4][4];
    
    mmat[0][0] = 1.0;
    mmat[0][1] = 0.0;
    mmat[0][2] = 0.0;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = 0.0;
    mmat[1][1] = rc;
    mmat[1][2] = rs;
    mmat[1][3] = 0.0;
    
    mmat[2][0] = 0.0;
    mmat[2][1] = -rs;
    mmat[2][2] = rc;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	yrotate -
 *		rotate about the y (green) axis
 */
static void yrotatemat(mat,rs,rc)
float mat[4][4];
float rs, rc;
{
    float mmat[4][4];
    
    mmat[0][0] = rc;
    mmat[0][1] = 0.0;
    mmat[0][2] = -rs;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = 0.0;
    mmat[1][1] = 1.0;
    mmat[1][2] = 0.0;
    mmat[1][3] = 0.0;
    
    mmat[2][0] = rs;
    mmat[2][1] = 0.0;
    mmat[2][2] = rc;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	zrotate -
 *		rotate about the z (blue) axis
 */
static void zrotatemat(mat,rs,rc)
float mat[4][4];
float rs, rc;
{
    float mmat[4][4];
    
    mmat[0][0] = rc;
    mmat[0][1] = rs;
    mmat[0][2] = 0.0;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = -rs;
    mmat[1][1] = rc;
    mmat[1][2] = 0.0;
    mmat[1][3] = 0.0;
    
    mmat[2][0] = 0.0;
    mmat[2][1] = 0.0;
    mmat[2][2] = 1.0;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	zshear -
 *		shear z using x and y.
 */
static void zshearmat(mat,dx,dy)
float mat[4][4];
float dx, dy;
{
    float mmat[4][4];
    
    mmat[0][0] = 1.0;
    mmat[0][1] = 0.0;
    mmat[0][2] = dx;
    mmat[0][3] = 0.0;
    
    mmat[1][0] = 0.0;
    mmat[1][1] = 1.0;
    mmat[1][2] = dy;
    mmat[1][3] = 0.0;
    
    mmat[2][0] = 0.0;
    mmat[2][1] = 0.0;
    mmat[2][2] = 1.0;
    mmat[2][3] = 0.0;
    
    mmat[3][0] = 0.0;
    mmat[3][1] = 0.0;
    mmat[3][2] = 0.0;
    mmat[3][3] = 1.0;
    matrixmult(mmat,mat,mat);
}

/*
 *	simplehuerotatemat -
 *		simple hue rotation. This changes luminance
 */
//static void simplehuerotatemat(mat,rot)
//float mat[4][4];
//float rot;
//{
//    float mag;
//    float xrs, xrc;
//    float yrs, yrc;
//    float zrs, zrc;
//
//    /* rotate the grey vector into positive Z */
//    mag = sqrt(2.0);
//    xrs = 1.0/mag;
//    xrc = 1.0/mag;
//    xrotatemat(mat,xrs,xrc);
//
//    mag = sqrt(3.0);
//    yrs = -1.0/mag;
//    yrc = sqrt(2.0)/mag;
//    yrotatemat(mat,yrs,yrc);
//
//    /* rotate the hue */
//    zrs = sin(rot*M_PI/180.0);
//    zrc = cos(rot*M_PI/180.0);
//    zrotatemat(mat,zrs,zrc);
//
//    /* rotate the grey vector back into place */
//    yrotatemat(mat,-yrs,yrc);
//    xrotatemat(mat,-xrs,xrc);
//}

/*
 *	huerotatemat -
 *		rotate the hue, while maintaining luminance.
 */
static void huerotatemat(mat,rot)
float mat[4][4];
float rot;
{
    float mmat[4][4];
    float mag;
    float lx, ly, lz;
    float xrs, xrc;
    float yrs, yrc;
    float zrs, zrc;
    float zsx, zsy;
    
    identmat(mmat);
    
    /* rotate the grey vector into positive Z */
    mag = sqrt(2.0);
    xrs = 1.0/mag;
    xrc = 1.0/mag;
    xrotatemat(mmat,xrs,xrc);
    mag = sqrt(3.0);
    yrs = -1.0/mag;
    yrc = sqrt(2.0)/mag;
    yrotatemat(mmat,yrs,yrc);
    
    /* shear the space to make the luminance plane horizontal */
    xformpnt(mmat,RLUM,GLUM,BLUM,&lx,&ly,&lz);
    zsx = lx/lz;
    zsy = ly/lz;
    zshearmat(mmat,zsx,zsy);
    
    /* rotate the hue */
    zrs = sin(rot*M_PI/180.0);
    zrc = cos(rot*M_PI/180.0);
    zrotatemat(mmat,zrs,zrc);
    
    /* unshear the space to put the luminance plane back */
    zshearmat(mmat,-zsx,-zsy);
    
    /* rotate the grey vector back into place */
    yrotatemat(mmat,-yrs,yrc);
    xrotatemat(mmat,-xrs,xrc);
    
    matrixmult(mmat,mat,mat);
}

@end
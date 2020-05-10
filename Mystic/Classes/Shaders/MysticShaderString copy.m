//
//  MysticShaderString.m
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShaderString.h"
#import "UserPotion.h"
#import "UIColor+Mystic.h"

@implementation MysticShaderString


+ (NSString *) outputString:(NSString *)shaderStr;
{
    NSString *outStr = [shaderStr stringByReplacingOccurrencesOfString:@";" withString:@";\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"{" withString:@"\n{\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"}" withString:@"\n}\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"void main()" withString:@"\n\nvoid main()\n\n"];
    return outStr;
}
+ (NSDictionary *) shaderString;
{
    return [self shaderString:nil];
}
+ (NSDictionary *) shaderString:(MysticOptions *)effects;
{
    BOOL outputShaderStr = NO;
    NSString *shaderStr = @"";
    NSString *vertexStr = nil;
    NSMutableArray *shaderStrComponents = [NSMutableArray array];

    NSMutableArray *shaderStrFunctions = [NSMutableArray array];
    NSMutableArray *shaderStrBlendComponents = [NSMutableArray array];

    NSMutableDictionary *shaderStrBlendComponentsPrefixes = [NSMutableDictionary dictionary];
    NSMutableArray *shaderStrBlendComponentsPrefixValues = [NSMutableArray array];
    NSMutableArray *shaderStrBlendComponentsHeaders;
    NSMutableArray *uniforms = [NSMutableArray array];

    effects = effects ? effects : [UserPotion renderEffects];
    NSArray *sortedRenderableEffects = [effects sortedRenderOptions];

    NSInteger numberOfEffects = sortedRenderableEffects.count;
    NSInteger numberOfInputs = [MysticOptions numberOfShaders:sortedRenderableEffects];
    
    BOOL useWhiteColor = NO, useBlackColor = NO;
    if(numberOfEffects)
    {
        id value = @"mediump vec4 outColor; mediump vec4 inColor;";
        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
        {
            [shaderStrBlendComponentsPrefixValues addObject:value];
            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
        }
        
        MysticFilterType filterType;
        NSString *blendStr = nil;
        NSInteger effectIndex = 2;
        PackPotionOption *previousOption = nil;
        NSInteger x = 0;
        BOOL shouldInvert = NO;
        for (PackPotionOption *option in sortedRenderableEffects) {
            
            if(!option.hasShader || option.ignoreActualRender)
            {
                continue;
            };
            shaderStrBlendComponentsHeaders = [NSMutableArray array];
            [uniforms addObject:[NSString stringWithFormat:@"uniform lowp float intensityUniform%d;", effectIndex]];
            if(option.canReplaceColor)
            {
                [uniforms addObject:[NSString stringWithFormat:@"uniform mediump vec4 foregroundColorUniform%d;", effectIndex]];
            }
            [uniforms addObject:[NSString stringWithFormat:@"uniform mediump vec4 backgroundColorUniform%d;", effectIndex]];


            [shaderStrBlendComponentsHeaders addObject:@" previousOutputColor = outputColor; "];


            
            shouldInvert = option.shouldInvert;
            if(x+1 < numberOfEffects)
            {
                PackPotionOption *nextOption = (PackPotionOption *)[effects.options objectAtIndex:x+1];
                if(nextOption.blendingType == MysticFilterTypeBlendCutout)
                {
                    value = @"mediump vec4 cutoutOutputColor;";
                    if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                    {
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                    }
                    
                    [shaderStrBlendComponentsHeaders addObject:@" cutoutOutputColor = outputColor; "];
                }
            }
            else if(option.blendingType == MysticFilterTypeBlendCutout && numberOfEffects <= 1)
            {
                shouldInvert = NO;
                id value = @"mediump vec4 cutoutOutputColor;";
                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                {
                    [shaderStrBlendComponentsPrefixValues addObject:value];
                    [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                }
                
                [shaderStrBlendComponentsHeaders addObject:[NSString stringWithFormat:@" cutoutOutputColor = %@; ", option.backgroundColorVec4Str]];
            }
            
            
            /*
            if(option.type == MysticObjectTypeSetting)
            {
                //outputShaderStr = YES;
                numberOfInputs--;
                effectIndex--;
                blendStr = nil;
                NSDictionary *adjustments = option.adjustments;
                
                for (NSString *key in [adjustments objectForKey:@"keys"]) {
                    id value;
                    MysticObjectType setting = [key integerValue];
                    
                    [shaderStrBlendComponentsHeaders addObject:@" inColor = outputColor;"];
                    
                    switch (setting) {
                        case MysticSettingBrightness:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderBrightness, option.brightness];
                            break;
                        }
                        case MysticSettingGamma:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderGamma, option.gamma];
                            break;
                        }
                        case MysticSettingExposure:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderExposure, option.exposure];
                            break;
                        }
                        case MysticSettingVignette:
                        {
                            
                            value = @"lowp vec2 vignetteCenter; lowp vec3 vignetteColor; highp float vignetteStart; highp float vignetteEnd;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            
                            blendStr = [NSString stringWithFormat:MysticShaderVignette, 0.5f, 0.5f, 0.0f, 0.0f, 0.0f, option.vignetteStart, option.vignetteEnd];
                            
                            break;
                        }
                        case MysticSettingUnsharpMask:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderUnsharpMask, option.unsharpMask];
                            break;
                        }
                        case MysticSettingTemperature:
                        {
                            value = @"MysticSettingTemperature";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrFunctions addObject:@"const lowp vec3 warmFilter = vec3(0.93, 0.54, 0.0);"];
                                [shaderStrFunctions addObject:@"const mediump mat3 RGBtoYIQ = mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.322, 0.212, -0.523, 0.311);"];
                                [shaderStrFunctions addObject:@"const mediump mat3 YIQtoRGB = mat3(1.0, 0.956, 0.621, 1.0, -0.272, -0.647, 1.0, -1.105, 1.702);"];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            
                            
                            value = @"mediump vec3 yiq;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            value = @"lowp vec3 rgb;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            value = @"lowp vec3 processed;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            CGFloat _temperature = option.temperature;
                            
                            _temperature = _temperature < 5000 ? 0.0004 * (float)(_temperature-5000.0) : 0.00006 * (float)(_temperature-5000.0);
                            CGFloat _tint = (float)(option.tint) / 100.0;
                            
                            blendStr = [NSString stringWithFormat:MysticShaderTemperature, _tint, _temperature]; // tint
                            break;
                        }
                        case MysticSettingCamLayerSetup:
                        case MysticSettingLevels:
                        {

                            
                            value = @"lowp vec3 lvlmin;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            value = @"lowp vec3 lvlmid;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            value = @"lowp vec3 lvlmax;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            value = @"lowp vec3 lvlminOut;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            value = @"lowp vec3 lvlmaxOut;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            blendStr = [NSString stringWithFormat:MysticShaderLevels, option.blackLevels, option.midLevels, option.whiteLevels];
                            
                            break;
                        }
                        case MysticSettingHaze:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderHaze, option.haze*-1, option.haze];
                            break;
                        }
                        case MysticSettingColorBalance:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderColorBalance, option.rgb.one, option.rgb.two, option.rgb.three];
                            break;
                        }
                        case MysticSettingSaturation:
                        {
                            value = @"MysticSettingSaturation";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrFunctions addObject:@"const mediump vec3 satluminanceWeighting = vec3(0.2125, 0.7154, 0.0721);"];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            
                            value = @"lowp float satluminance;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            value = @"lowp vec3 satgreyScaleColor;";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrBlendComponentsPrefixValues addObject:value];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            blendStr = @"satluminance = dot(inColor.rgb, satluminanceWeighting); satgreyScaleColor = vec3(satluminance);";
                            blendStr = [blendStr stringByAppendingString:[NSString stringWithFormat:MysticShaderSaturation, option.saturation]];
                            break;
                        }
                        case MysticSettingTiltShift:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderTiltShift, option.tiltShift];
                            break;
                        }
                        case MysticSettingContrast:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderContrast, option.contrast];
                            break;
                        }
                        case MysticSettingSharpness:
                        {
                            blendStr = [NSString stringWithFormat:MysticShaderSharpness, option.sharpness];
                            break;
                        }
                        case MysticSettingHighlights:
                        case MysticSettingShadows:
                        {
                            value = @"MysticSettingShadows";
                            if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                            {
                                [shaderStrFunctions addObject:@"const mediump vec3 hsluminanceWeighting = vec3(0.3, 0.3, 0.3);"];
                                [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                            }
                            
                            
                            blendStr = [NSString stringWithFormat:MysticShaderShadows, option.shadows, option.highlights];
                            
                            
                            break;
                        }
                        
                
                        default:
                        {
                            break;
                        }
                    }
                    [shaderStrBlendComponents addObjectsFromArray:shaderStrBlendComponentsHeaders];
                    if(blendStr)
                    {
                        [shaderStrBlendComponents addObject:blendStr];
                        [shaderStrBlendComponents addObject:@" outputColor = outColor; "];
                    }
                    blendStr = nil;
                    shaderStrBlendComponentsHeaders = [NSMutableArray array];
                }
                
                [shaderStrBlendComponents addObject:MysticShaderControlOutput];
                
            }
            else
            {
             
             */
//                if(shouldInvert)
//                {
//                    [shaderStrBlendComponentsHeaders addObject:[NSString stringWithFormat:@" lowp vec4 invertedInputColor%d = vec4((1.0 - textureColor%d.rgb), textureColor%d.w); inputColor = invertedInputColor%d; ", effectIndex, effectIndex, effectIndex, effectIndex]];
//                }
//                else
//                {
//                    [shaderStrBlendComponentsHeaders addObject:[NSString stringWithFormat:@" inputColor = textureColor%d; ", effectIndex]];
//                }
                [shaderStrBlendComponentsHeaders addObject:[NSString stringWithFormat:@" inputColor = textureColor%d; ", effectIndex]];

                blendStr = nil;
                filterType = option.blendingType;
                
                
                
                NSDictionary *adjustments = option.adjustments;
                
                if(MYSTIC_SHADER_INLINE_ADJUSTMENTS > 0 && [adjustments count])
                {
                    
                    
                    
                    for (NSString *key in [adjustments objectForKey:@"keys"]) {
                        id value;
                        MysticObjectType setting = [key integerValue];
                        
                        
                        switch (setting) {
                            case MysticSettingBrightness:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderBrightness, option.brightness];
                                break;
                            }
                            case MysticSettingGamma:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderGamma, option.gamma];
                                break;
                            }
                            case MysticSettingExposure:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderExposure, option.exposure];
                                break;
                            }
                            case MysticSettingVignette:
                            {
                                
                                value = @"lowp vec2 vignetteCenter; lowp vec3 vignetteColor; highp float vignetteStart; highp float vignetteEnd;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                
                                blendStr = [NSString stringWithFormat:MysticShaderVignette, 0.5f, 0.5f, 0.0f, 0.0f, 0.0f, option.vignetteStart, option.vignetteEnd];
                                
                                break;
                            }
                            case MysticSettingUnsharpMask:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderUnsharpMask, option.unsharpMask];
                                break;
                            }
                            case MysticSettingTemperature:
                            {
                                value = @"MysticSettingTemperature";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrFunctions addObject:@"const lowp vec3 warmFilter = vec3(0.93, 0.54, 0.0);"];
                                    [shaderStrFunctions addObject:@"const mediump mat3 RGBtoYIQ = mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.322, 0.212, -0.523, 0.311);"];
                                    [shaderStrFunctions addObject:@"const mediump mat3 YIQtoRGB = mat3(1.0, 0.956, 0.621, 1.0, -0.272, -0.647, 1.0, -1.105, 1.702);"];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                
                                
                                value = @"mediump vec3 yiq;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                value = @"lowp vec3 rgb;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                value = @"lowp vec3 processed;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                CGFloat _temperature = option.temperature;
                                
                                _temperature = _temperature < 5000 ? 0.0004 * (float)(_temperature-5000.0) : 0.00006 * (float)(_temperature-5000.0);
                                CGFloat _tint = (float)(option.tint) / 100.0;
                                
                                blendStr = [NSString stringWithFormat:MysticShaderTemperature, _tint, _temperature]; // tint
                                break;
                            }
                            case MysticSettingCamLayerSetup:
                            case MysticSettingLevels:
                            {
                                
                                
                                value = @"lowp vec3 lvlmin;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                value = @"lowp vec3 lvlmid;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                value = @"lowp vec3 lvlmax;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                value = @"lowp vec3 lvlminOut;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                value = @"lowp vec3 lvlmaxOut;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                blendStr = [NSString stringWithFormat:MysticShaderLevels, option.blackLevels, option.midLevels, option.whiteLevels];
                                
                                break;
                            }
                            case MysticSettingHaze:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderHaze, option.haze*-1, option.haze];
                                break;
                            }
                            case MysticSettingColorBalance:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderColorBalance, option.rgb.one, option.rgb.two, option.rgb.three];
                                break;
                            }
                            case MysticSettingSaturation:
                            {
                                value = @"MysticSettingSaturation";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrFunctions addObject:@"const mediump vec3 satluminanceWeighting = vec3(0.2125, 0.7154, 0.0721);"];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                
                                value = @"lowp float satluminance;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                value = @"lowp vec3 satgreyScaleColor;";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrBlendComponentsPrefixValues addObject:value];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                blendStr = @"satluminance = dot(inColor.rgb, satluminanceWeighting); satgreyScaleColor = vec3(satluminance);";
                                blendStr = [blendStr stringByAppendingString:[NSString stringWithFormat:MysticShaderSaturation, option.saturation]];
                                break;
                            }
                            case MysticSettingTiltShift:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderTiltShift, option.tiltShift];
                                break;
                            }
                            case MysticSettingContrast:
                            {
                                blendStr = [NSString stringWithFormat:MysticShaderContrast, option.contrast];
                                break;
                            }
                            case MysticSettingSharpness:
                            {
//                                blendStr = [NSString stringWithFormat:MysticShaderSharpness, option.sharpness];
                                blendStr = nil;
                                break;
                            }
                            case MysticSettingHighlights:
                            case MysticSettingShadows:
                            {
                                value = @"MysticSettingShadows";
                                if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                                {
                                    [shaderStrFunctions addObject:@"const mediump vec3 hsluminanceWeighting = vec3(0.3, 0.3, 0.3);"];
                                    [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                                }
                                
                                
                                blendStr = [NSString stringWithFormat:MysticShaderShadows, option.shadows, option.highlights];
                                
                                
                                break;
                            }
                                
                                
                            default:
                            {
                                break;
                            }
                        }
                        [shaderStrBlendComponents addObjectsFromArray:shaderStrBlendComponentsHeaders];
                        if(blendStr)
                        {
                            [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// LAYER %d: %@ %@", effectIndex, MysticObjectTypeToString(option.type), MysticObjectTypeToString(setting)]];
                            
                            [shaderStrBlendComponents addObject:@" inColor = inputColor;"];
                            
                            [shaderStrBlendComponents addObject:blendStr];
                            
                            [shaderStrBlendComponents addObject:@" inputColor = outColor;"];
                            
//                            [shaderStrBlendComponents addObject:@" outputColor = outColor;"];
                            
                        }
                        blendStr = nil;
                        shaderStrBlendComponentsHeaders = [NSMutableArray array];
                    }
                    
                
                }
                
                
#pragma mark - BLENDING
                
                
                switch (filterType) {

    #pragma mark -
    #pragma mark - Blend Alpha
                    case MysticFilterTypeBlendAlphaMask:
                    case MysticFilterTypeBlendAlpha:
                    {
                        
                        if(!shouldInvert)
                        {
                            blendStr = SHADER_STRING(
                                                     if (inputColor.a == 0.0) {
                                                         outputColor = outputColor;
                                                     } else {
                                                         outputColor = vec4(mix(outputColor.rgb, inputColor.rgb / inputColor.a, inputColor.a), outputColor.a);
                                                         
                                                     }
                                                     );
                        }
                        else
                        {
                            blendStr = SHADER_STRING(
                                                     if (inputColor.a == 0.0) {
                                                         outputColor = outputColor;
                                                     } else {
                                                         outputColor = vec4(mix(outputColor.rgb, inputColor.rgb, inputColor.a), outputColor.a);
                                                         
                                                     }
                                                     );
                        }
                        
                                                 
                        
                        break;
                    }
                    case MysticFilterTypeBlendAlphaMix:
                    case MysticFilterTypeUnknown:
                    {
                        
                     
                        
                        if(!shouldInvert)
                        {
                            blendStr = SHADER_STRING(
                                                 
                                                 if (inputColor.a == 0.0) {
                                                     outputColor = outputColor;
                                                 } else {
                                                     outputColor = vec4(mix(outputColor.rgb, inputColor.rgb/ inputColor.a,
                                                                             %2.2f * inputColor.a), outputColor.a);
                                                 }
                                                 
                                                 
                                                 outputColor = mix(outputColor, inputColor, inputColor.a);
                                                 
                                                 
                                                 );
                        }
                        else
                        {
                            blendStr = SHADER_STRING(
                                                     
                                                     if (inputColor.a == 0.0) {
                                                         outputColor = outputColor;
                                                     } else {
                                                         outputColor = vec4(mix(outputColor.rgb, inputColor.rgb,
                                                                                %2.2f * inputColor.a), outputColor.a);
                                                     }
                                                     
                                                     
                                                     outputColor = mix(outputColor, inputColor, inputColor.a);
                                                     
                                                     
                                                     );
                        }
                        blendStr = [NSString stringWithFormat:blendStr, option.intensity];
                        break;
                    }
                    case MysticFilterTypeMask:
                    {
                        
                        
                        id value = @"mediump float newAlpha;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        value = @"mediump vec4 bgColor;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        blendStr = SHADER_STRING(
                                                 newAlpha = dot(inputColor.rgb, vec3(.33333334, .33333334, .33333334)) * inputColor.a;
                                                 
                                                 outputColor = vec4(outputColor.xyz, newAlpha);
                                                 bgColor = %@;
                                                 if (outputColor.a == 0.0) {
                                                     outputColor = bgColor;
                                                 } else {
                                                     outputColor = vec4(mix(bgColor.rgb, outputColor.rgb * outputColor.a,
                                                                            outputColor.a), 1.0);
                                                 }
                                                 
                                                 
                                                 );
                        
                        blendStr = [NSString stringWithFormat:blendStr, option.backgroundColorVec4Str];
                        break;
                    }
                    case MysticFilterTypeBlendCutout:
                    {
//                        outputShaderStr = YES;
                        id value = @"mediump float newAlpha;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        value = @"mediump vec4 bgColor;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        blendStr = SHADER_STRING(
                                                 
                                                 bgColor = %@;
                                                 outputColor = vec4(outputColor.rgb, inputColor.r);
                                                 
                                                 if (outputColor.a == 0.0) {
                                                     
                                                 } else {
                                                     outputColor = vec4(mix(cutoutOutputColor.rgb, outputColor.rgb, outputColor.a), 1.0);
                                                 }
                                                 
                                                 
                                                 );
                        blendStr = [NSString stringWithFormat:blendStr, [option.backgroundColor vec4Str]];
                        
                        break;
                    }
                    case MysticFilterTypeBlendLighten:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = max(outputColor, inputColor);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendDarken:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(min(inputColor.rgb * outputColor.a, outputColor.rgb * inputColor.a) + inputColor.rgb * (1.0 - outputColor.a) + outputColor.rgb * (1.0 - inputColor.a), 1.0);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendSoftlight:
                    {
                        blendStr = SHADER_STRING(
                                                 
                                                 outputColor = outputColor * (inputColor.a * (outputColor / outputColor.a) + (2.0 * inputColor * (1.0 - (outputColor / outputColor.a)))) + inputColor * (1.0 - outputColor.a) + outputColor * (1.0 - inputColor.a);
                                                 
                                                 );
                        
                        
                        break;
                    }
                    case MysticFilterTypeBlendScreen:
                    {
//                        
                        if(option.canReplaceColor)
                        {
                            blendStr = SHADER_STRING(
                                                     
                                                     
                                                     inputColor = vec4(mix(outputColor.rgb, foregroundColorUniform%d.rgb, inputColor.r), 1.0);
                                                     if(intensityUniform%d < 1.0)
                                                     {
                                                         outputColor = vec4(mix(outputColor.rgb, inputColor.rgb, intensityUniform%d), 1.0);
                                                     }
                                                     else
                                                     {
                                                         outputColor = inputColor;
                                                     }
                                                     
                                                     );

//                        
                            blendStr = [NSString stringWithFormat:blendStr, effectIndex, effectIndex, effectIndex];
                        }
                        else
                        {
                            blendStr = SHADER_STRING(
                                                     outputColor = whiteColor - ((whiteColor - inputColor) * (whiteColor - outputColor));
                                                     );
                            
                            
                            useWhiteColor = YES;
                        }
                        break;
                    }
                    case MysticFilterTypeBlendMultiply:
                    {
                        if(option.canReplaceColor)
                        {
                        
                            blendStr = SHADER_STRING(
                                                     
                                                     inputColor = vec4((1.0 - inputColor.rgb), inputColor.w);
                                                     inputColor = vec4(mix(outputColor.rgb, foregroundColorUniform%d.rgb, inputColor.r), 1.0);
                                                     if(intensityUniform%d < 1.0)
                                                     {
                                                         outputColor = vec4(mix(outputColor.rgb, inputColor.rgb, intensityUniform%d), 1.0);
                                                     }
                                                     else
                                                     {
                                                         outputColor = inputColor;
                                                     }

                                                     
                                                     );
                            
                            blendStr = [NSString stringWithFormat:blendStr, effectIndex, effectIndex, effectIndex];
                        }
                        else
                        {
                            blendStr = SHADER_STRING(
                                                 outputColor = inputColor * outputColor + inputColor * (1.0 - outputColor.a) + outputColor * (1.0 - inputColor.a);
                                                 );
                        }
                        
                        break;
                    }
                    case MysticFilterTypeBlendSubtract:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(outputColor.rgb - inputColor.rgb, outputColor.a);
                                                 );
                        
                        break;
                    }
                    case MysticFilterTypeBlendLinearBurn:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(clamp(outputColor.rgb + inputColor.rgb - vec3(1.0), vec3(0.0), vec3(1.0)), outputColor.a);
                                                 );
                        
                        break;
                    }
                    case MysticFilterTypeBlendAdd:
                    {
                        id value = @"mediump float radd;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float gadd;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float badd;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float aadd;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        blendStr = SHADER_STRING(
                                                 if (inputColor.r * outputColor.a + outputColor.r * inputColor.a >= inputColor.a * outputColor.a) {
                                                     radd = inputColor.a * outputColor.a + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 } else {
                                                     radd = inputColor.r + outputColor.r;
                                                 }
                                                 
                                                 if (inputColor.g * outputColor.a + outputColor.g * inputColor.a >= inputColor.a * outputColor.a) {
                                                     gadd = inputColor.a * outputColor.a + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 } else {
                                                     gadd = inputColor.g + outputColor.g;
                                                 }
                                                 
                                                 if (inputColor.b * outputColor.a + outputColor.b * inputColor.a >= inputColor.a * outputColor.a) {
                                                     badd = inputColor.a * outputColor.a + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 } else {
                                                     badd = inputColor.b + outputColor.b;
                                                 }
                                                 
                                                 aadd = inputColor.a + outputColor.a - inputColor.a * outputColor.a;
                                                 
                                                 outputColor = vec4(radd, gadd, badd, aadd);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendDivide:
                    {
                        id value = @"mediump float radiv;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float gadiv;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float badiv;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"mediump float adiv;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        
                        blendStr = SHADER_STRING(
                                                 
                                                 if (inputColor.a == 0.0 || ((outputColor.r / inputColor.r) > (outputColor.a / inputColor.a)))
                                                 radiv = inputColor.a * outputColor.a + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 else
                                                 radiv = (outputColor.r * inputColor.a * inputColor.a) / inputColor.r + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 
                                                 
                                                 if (inputColor.a == 0.0 || ((outputColor.g / inputColor.g) > (outputColor.a / inputColor.a)))
                                                 gadiv = inputColor.a * outputColor.a + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 else
                                                 gadiv = (outputColor.g * inputColor.a * inputColor.a) / inputColor.g + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 
                                                 
                                                 if (inputColor.a == 0.0 || ((outputColor.b / inputColor.b) > (outputColor.a / inputColor.a)))
                                                 badiv = inputColor.a * outputColor.a + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 else
                                                 badiv = (outputColor.b * inputColor.a * inputColor.a) / inputColor.b + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 
                                                 adiv = inputColor.a + outputColor.a - inputColor.a * outputColor.a;
                                                 
                                                 outputColor = vec4(radiv, gadiv, badiv, adiv);
                                                 );
                        
                        break;
                    }
                    case MysticFilterTypeBlendOverlay:
                    {
                        id value = @"mediump float ra;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        value = @"mediump float ga;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        value = @"mediump float ba;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        
                        blendStr = SHADER_STRING(
                                                 
                                                 
                                                 
                                                 if (2.0 * outputColor.r < outputColor.a) {
                                                     ra = 2.0 * inputColor.r * outputColor.r + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 } else {
                                                     ra = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.r) * (inputColor.a - inputColor.r) + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 if (2.0 * outputColor.g < outputColor.a) {
                                                     ga = 2.0 * inputColor.g * outputColor.g + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 } else {
                                                     ga = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.g) * (inputColor.a - inputColor.g) + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 if (2.0 * outputColor.b < outputColor.a) {
                                                     ba = 2.0 * inputColor.b * outputColor.b + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 } else {
                                                     ba = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.b) * (inputColor.a - inputColor.b) + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 outputColor = vec4(ra, ga, ba, 1.0);
                                                 
                                                 
                                                 );
                        
                        
                        
                        break;
                    }
                    case MysticFilterTypeBlendColorBurn:
                    {
                        useWhiteColor = YES;
                        blendStr = SHADER_STRING(
                                                 outputColor = whiteColor - (whiteColor - outputColor) / inputColor;
                                                 );
                        
                        break;
                    }
                    case MysticFilterTypeBlendColorDodge:
                    {
                        [shaderStrFunctions addObject:@"precision mediump float;"];
                        NSString *prefixStr = SHADER_STRING(
                                                            baseinputColorAlphaProduct = vec3(inputColor.a * outputColor.a);
                                                            );
                        id value = [shaderStrBlendComponentsPrefixes objectForKey:@"baseinputColorAlphaProduct"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"baseinputColorAlphaProduct"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        prefixStr = SHADER_STRING(
                                                  rightHandProduct = inputColor.rgb * (1.0 - outputColor.a) + outputColor.rgb * (1.0 - inputColor.a);
                                                  );
                        value = [shaderStrBlendComponentsPrefixes objectForKey:@"rightHandProduct"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"rightHandProduct"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        prefixStr = SHADER_STRING(
                                                  firstBlendColor = baseinputColorAlphaProduct + rightHandProduct;
                                                  );
                        value = [shaderStrBlendComponentsPrefixes objectForKey:@"firstBlendColor"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"firstBlendColor"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        prefixStr = SHADER_STRING(
                                                  inputColorRGB = clamp((inputColor.rgb / clamp(inputColor.a, 0.01, 1.0)) * step(0.0, inputColor.a), 0.0, 0.99);
                                                  );
                        value = [shaderStrBlendComponentsPrefixes objectForKey:@"inputColorRGB"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"inputColorRGB"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        prefixStr = SHADER_STRING(
                                                  secondBlendColor = (outputColor.rgb * inputColor.a) / (1.0 - inputColorRGB) + rightHandProduct;
                                                  );
                        value = [shaderStrBlendComponentsPrefixes objectForKey:@"secondBlendColor"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"secondBlendColor"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        prefixStr = SHADER_STRING(
                                                  colorChoice = step((inputColor.rgb * outputColor.a + outputColor.rgb * inputColor.a), baseinputColorAlphaProduct);
                                                  );
                        value = [shaderStrBlendComponentsPrefixes objectForKey:@"colorChoice"] ? prefixStr : [@" vec3 " stringByAppendingString:prefixStr];
                        [shaderStrBlendComponentsPrefixes setObject:value forKey:@"colorChoice"];
                        [shaderStrBlendComponentsPrefixValues addObject:value];
                        
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(mix(firstBlendColor, secondBlendColor, colorChoice), 1.0);
                                                 );
                        
                        
                        
                        break;
                    }
                    case MysticFilterTypeBlendDifference:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(abs(inputColor.rgb - outputColor.rgb), outputColor.a);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendDissolve:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = mix(textureColor, textureColor2, %2.2f);
                                                 );
                        blendStr = [NSString stringWithFormat:blendStr, option.intensity];
                        break;
                    }
                    case MysticFilterTypeBlendExclusion:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4((inputColor.rgb * outputColor.a + outputColor.rgb * inputColor.a - 2.0 * inputColor.rgb * outputColor.rgb) + inputColor.rgb * (1.0 - outputColor.a) + outputColor.rgb * (1.0 - inputColor.a), outputColor.a);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendHardlight:
                    {
                        id value = @"highp float rahl;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"highp float gahl;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"highp float bahl;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        blendStr = SHADER_STRING(
                                                 
                                                 if (2.0 * inputColor.r < inputColor.a) {
                                                     rahl = 2.0 * inputColor.r * outputColor.r + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 } else {
                                                     rahl = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.r) * (inputColor.a - inputColor.r) + inputColor.r * (1.0 - outputColor.a) + outputColor.r * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 if (2.0 * inputColor.g < inputColor.a) {
                                                     gahl = 2.0 * inputColor.g * outputColor.g + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 } else {
                                                     gahl = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.g) * (inputColor.a - inputColor.g) + inputColor.g * (1.0 - outputColor.a) + outputColor.g * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 if (2.0 * inputColor.b < inputColor.a) {
                                                     bahl = 2.0 * inputColor.b * outputColor.b + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 } else {
                                                     bahl = inputColor.a * outputColor.a - 2.0 * (outputColor.a - outputColor.b) * (inputColor.a - inputColor.b) + inputColor.b * (1.0 - outputColor.a) + outputColor.b * (1.0 - inputColor.a);
                                                 }
                                                 
                                                 outputColor = vec4(rahl, gahl, bahl, 1.0);
                                                 );
                        
                        break;
                    }
                    case MysticFilterTypeBlendColor:
                    {
                        
                        if(![shaderStrFunctions containsObject:MysticShaderLum]) [shaderStrFunctions addObject:MysticShaderLum];
                        if(![shaderStrFunctions containsObject:MysticShaderClipColor]) [shaderStrFunctions addObject:MysticShaderClipColor];
                        if(![shaderStrFunctions containsObject:MysticShaderSetLum]) [shaderStrFunctions addObject:MysticShaderSetLum];
                        
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(outputColor.rgb * (1.0 - inputColor.a) + setlum(inputColor.rgb, lum(outputColor.rgb)) * inputColor.a, outputColor.a);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendHue:
                    {
                        
                        if(![shaderStrFunctions containsObject:MysticShaderLum]) [shaderStrFunctions addObject:MysticShaderLum];
                        if(![shaderStrFunctions containsObject:MysticShaderClipColor]) [shaderStrFunctions addObject:MysticShaderClipColor];
                        if(![shaderStrFunctions containsObject:MysticShaderSetLum]) [shaderStrFunctions addObject:MysticShaderSetLum];
                        
                        if(![shaderStrFunctions containsObject:MysticShaderSat]) [shaderStrFunctions addObject:MysticShaderSat];
                        if(![shaderStrFunctions containsObject:MysticShaderMid]) [shaderStrFunctions addObject:MysticShaderMid];
                        if(![shaderStrFunctions containsObject:MysticShaderSetSat]) [shaderStrFunctions addObject:MysticShaderSetSat];
                        
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(outputColor.rgb * (1.0 - inputColor.a) + setlum(setsat(inputColor.rgb, sat(outputColor.rgb)), lum(outputColor.rgb)) * inputColor.a, outputColor.a);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendSaturation:
                    {
                        
                        if(![shaderStrFunctions containsObject:MysticShaderLum]) [shaderStrFunctions addObject:MysticShaderLum];
                        if(![shaderStrFunctions containsObject:MysticShaderClipColor]) [shaderStrFunctions addObject:MysticShaderClipColor];
                        if(![shaderStrFunctions containsObject:MysticShaderSetLum]) [shaderStrFunctions addObject:MysticShaderSetLum];
                        
                        if(![shaderStrFunctions containsObject:MysticShaderSat]) [shaderStrFunctions addObject:MysticShaderSat];
                        if(![shaderStrFunctions containsObject:MysticShaderMid]) [shaderStrFunctions addObject:MysticShaderMid];
                        if(![shaderStrFunctions containsObject:MysticShaderSetSat]) [shaderStrFunctions addObject:MysticShaderSetSat];
                        
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(outputColor.rgb * (1.0 - inputColor.a) + setlum(setsat(outputColor.rgb, sat(inputColor.rgb)), lum(outputColor.rgb)) * inputColor.a, outputColor.a);
                                                 );
                        break;
                    }
                    case MysticFilterTypeBlendLuminosity:
                    {
                        
                        if(![shaderStrFunctions containsObject:MysticShaderLum]) [shaderStrFunctions addObject:MysticShaderLum];
                        if(![shaderStrFunctions containsObject:MysticShaderClipColor]) [shaderStrFunctions addObject:MysticShaderClipColor];
                        if(![shaderStrFunctions containsObject:MysticShaderSetLum]) [shaderStrFunctions addObject:MysticShaderSetLum];
                        
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = vec4(outputColor.rgb * (1.0 - inputColor.a) + setlum(outputColor.rgb, lum(inputColor.rgb)) * inputColor.a, outputColor.a);
                                                 );
                        break;
                    }
                        
                    case MysticFilterTypeBlendChromaKey:
                    case MysticFilterTypeDropGreen:
                    
                    {
                        id value = @"mediump vec4 colorToReplace;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float maskY;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float maskCr;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float maskCb;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float Y;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float Cb;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float Cr;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        value = @"float blendValue;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
                        }
                        
                        
                        [shaderStrFunctions addObject:@"precision highp float;"];
                        blendStr = SHADER_STRING(
                                                 
                                                 colorToReplace = vec4(%2.2f, %2.2f, %2.2f, 1.0);
                                                 maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
                                                 maskCr = 0.7132 * (colorToReplace.r - maskY);
                                                 maskCb = 0.5647 * (colorToReplace.b - maskY);
                                                 
                                                 Y = 0.2989 * inputColor.r + 0.5866 * inputColor.g + 0.1145 * inputColor.b;
                                                 Cr = 0.7132 * (inputColor.r - Y);
                                                 Cb = 0.5647 * (inputColor.b - Y);
                                                 
                                                 
                                                 blendValue = 1.0 - smoothstep(%2.2f, %2.2f + %2.2f, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
                                                 outputColor = mix(inputColor, outputColor, blendValue);
                                                 );
                        
//                        blendStr = SHADER_STRING(
//                                                 
//                                                 colorToReplace = vec4(%2.2f, %2.2f, %2.2f, 1.0);
//                                                 maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
//                                                 maskCr = 0.7132 * (colorToReplace.r - maskY);
//                                                 maskCb = 0.5647 * (colorToReplace.b - maskY);
//                                                 
//                                                 Y = 0.2989 * outputColor.r + 0.5866 * outputColor.g + 0.1145 * outputColor.b;
//                                                 Cr = 0.7132 * (outputColor.r - Y);
//                                                 Cb = 0.5647 * (outputColor.b - Y);
//                                                 
//                                                 
//                                                 blendValue = 1.0 - smoothstep(%2.2f, %2.2f + %2.2f, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
//                                                 outputColor = mix(outputColor, inputColor, blendValue);
//                                                 );
                        UIColor *chromaColor = option.inverted ? [option.chromaColor invertedColor] : option.chromaColor;
                        blendStr = [NSString stringWithFormat:blendStr, chromaColor.red, chromaColor.green, chromaColor.blue, option.sensitivity, option.sensitivity, option.smoothingSensitivity];
                        
                        break;
                    }
                    
                    case MysticFilterTypeLookup:
                    {
                        
//                        outputShaderStr = YES;
                        id value = @"mediump float blueFColor;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        
                        value = @"mediump vec2 quad1;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"mediump vec2 quad2;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"highp vec2 texPos1;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"highp vec2 texPos2;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"mediump vec4 newColor1;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"mediump vec4 newColor2;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        value = @"mediump vec4 newColor;";
                        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
                        {
                            [shaderStrBlendComponentsPrefixValues addObject:value];
                            [shaderStrBlendComponentsPrefixes setObject:value forKey:value];
                        }
                        
                        
                        
                        
                        [shaderStrBlendComponents addObject:MysticShaderControlOutput];
                        
                        blendStr = SHADER_STRING(
                                                 
                                                 blueFColor = outputColor.b * 63.0;
                                                 
                                                 quad1.y = floor(floor(blueFColor) / 8.0);
                                                 quad1.x = floor(blueFColor) - (quad1.y * 8.0);
                                                 
                                                 quad2.y = floor(ceil(blueFColor) / 8.0);
                                                 quad2.x = ceil(blueFColor) - (quad2.y * 8.0);
                                                 
                                                 texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * outputColor.r);
                                                 texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * outputColor.g);
                                                 
                                                 texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * outputColor.r);
                                                 texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * outputColor.g);
                                                 
                                                 newColor1 = texture2D(inputImageTexture%d, texPos1);
                                                 newColor2 = texture2D(inputImageTexture%d, texPos2);
                                                 
                                                 newColor = mix(newColor1, newColor2, fract(blueFColor));
                                                 outputColor = vec4(newColor.rgb, outputColor.w);
                                                 
                                                 );
                        blendStr = [NSString stringWithFormat:blendStr, effectIndex, effectIndex];
                        break;
                    }
                    case MysticFilterTypeBlendNormal:
                    {
                        blendStr = SHADER_STRING(
                                                 outputColor = inputColor;
                                                 );
                        
                        break;
                    }
//                    case MysticFilterTypeUnknown:
                    default:
                    {
                   
                        
                        blendStr = SHADER_STRING(
                                                 outputColor = inputColor;
                                                 );
                        
                        break;
                    }
                }
            //}
            
            [shaderStrBlendComponents addObjectsFromArray:shaderStrBlendComponentsHeaders];
            
            if(blendStr)
            {
                [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// LAYER %d: %@ Blend: %@", effectIndex, MysticObjectTypeToString(option.type), option.blending]];
                
                [shaderStrBlendComponents addObject:blendStr];
            }
//            if(option.intensity < 1.0f && option.intensity >= 0)
//            {
                NSString *intensityUniform = [NSString stringWithFormat:@"intensityUniform%d", effectIndex];
                [shaderStrBlendComponents addObject:[NSString stringWithFormat:@" if(%@ < 1.0) { outputColor = mix(previousOutputColor, outputColor, %@); }", intensityUniform, intensityUniform]];
                
//            }
            option.shaderIndex = effectIndex;
            
            effectIndex++;
            x++;
        }
        
        [shaderStrFunctions addObject:MysticShaderHeader];
        
        [shaderStrComponents addObjectsFromArray:shaderStrFunctions];
        if(uniforms.count)
        {
//            outputShaderStr = YES;
            [shaderStrComponents addObjectsFromArray:uniforms];
        }

        switch (numberOfInputs) {
            case 1:
            {
//                [vertexStrComponents addObject:MysticVertexOne];
                
                [shaderStrComponents addObject:MysticShaderOne];
                 break;
             }
            case 2:
            {
//                [vertexStrComponents addObject:MysticVertexTwo];
                [shaderStrComponents addObject:MysticShaderTwo];
                     break;
                 }
             case 3:
             {
//                 [vertexStrComponents addObject:MysticVertexThree];
                 [shaderStrComponents addObject:MysticShaderThree];
                      break;
                  }
              case 4:
              {
//                  [vertexStrComponents addObject:MysticVertexFour];
                  [shaderStrComponents addObject:MysticShaderFour];
                       break;
                   }
               case 5:
               {
//                   [vertexStrComponents addObject:MysticVertexFive];
                   [shaderStrComponents addObject:MysticShaderFive];
                    break;
                }
                case 6:
                {
//                    [vertexStrComponents addObject:MysticVertexSix];
                    [shaderStrComponents addObject:MysticShaderSix];
                     break;
                 }
             case 7:
             {

//                 [vertexStrComponents addObject:MysticVertexSeven];
                 [shaderStrComponents addObject:MysticShaderSeven];
                  break;
              }
          case 8:
          {
//              [vertexStrComponents addObject:MysticVertexEight];
              [shaderStrComponents addObject:MysticShaderEight];
               break;
           }
                                                              
        default:

        break;
    }



//        if([vertexStrComponents count])
//        {
//            vertexStr = @"";
//            if([vertexStrTransforms count])
//            {
//                [vertexStrComponents addObjectsFromArray:vertexStrTransforms];
//            }
//            [vertexStrComponents addObject:@" } "];
//            
//            for (NSString *subStr in vertexStrComponents) {
//                vertexStr = [vertexStr stringByAppendingString:subStr];
//            }
//        }
    
    if([shaderStrComponents count])
    {
       if(useWhiteColor) [shaderStrComponents addObject:MysticShaderColorWhite];
       if(useBlackColor) [shaderStrComponents addObject:MysticShaderColorBlack];
       
       [shaderStrComponents addObjectsFromArray:shaderStrBlendComponentsPrefixValues];
       [shaderStrComponents addObjectsFromArray:shaderStrBlendComponents];
       
        [shaderStrComponents addObject:@" gl_FragColor = outputColor; }"];
      
       for (NSString *subStr in shaderStrComponents) {
           shaderStr = [shaderStr stringByAppendingString:@"\n"];
           shaderStr = [shaderStr stringByAppendingString:subStr];
       }
    }
    }

    if(outputShaderStr)
    {
        NSString *outStr = [MysticShaderString outputString:shaderStr];
        DLog(@"shader: \n\n\n%@\n\n\n", outStr);
    }
                                                                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                                                                    
//    NSArray *shaderParts = vertexStr ? [NSArray arrayWithObjects:shaderStr, vertexStr, nil] : [NSArray arrayWithObject:shaderStr];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:shaderStr forKey:@"shader"];
    
    if(vertexStr) [dict setObject:vertexStr forKey:@"vertex"];
    
//    if([customVertexUniforms count]) [dict setObject:customVertexUniforms forKey:@"vertexUniforms"];
//    if([customShaderUniforms count]) [dict setObject:customShaderUniforms forKey:@"shaderUniforms"];
    
    
    
    return dict;
    
//    return shaderParts;
}

                                                                                                                                                                                                                                                                                                                                                                   
@end

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
#import "MysticShaderStringSettings.h"
#import "MysticShaderStringOption.h"
#import "MysticShader.h"

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
    NSMutableArray *theMains = [NSMutableArray array];
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
        id value = @" mediump vec4 outColor; mediump vec4 inColor;";
        if(![shaderStrBlendComponentsPrefixes objectForKey:value])
        {
            [shaderStrBlendComponentsPrefixValues addObject:value];
            [shaderStrBlendComponentsPrefixes setObject:@"" forKey:value];
        }
        
        MysticFilterType filterType, originalFilterType;
        NSString *blendStr = nil;
        NSString *preBlendStr = nil;
        NSString *postBlendStr = nil;
        NSString *mainTemplate = nil;
        NSMutableArray *mainTemplates = [NSMutableArray arrayWithObject:[NSNull null]];
        NSInteger effectIndex = 2;
        NSInteger prevEffectIndex = 0;

        NSInteger stackIndex = 2;
        PackPotionOption *previousOption = nil;
        NSInteger x = 0;
        BOOL shouldInvert = NO;
        for (PackPotionOption *option in sortedRenderableEffects)
        {
            
            if(!option.hasShader || option.ignoreActualRender) continue;

            [mainTemplates addObject:[NSNull null]];
            shouldInvert = option.shouldInvert;
            blendStr = nil;
            preBlendStr = nil;
            postBlendStr=nil;
            filterType = option.blendingType;

            
            
#pragma mark - Setup Option Headers & Uniforms
            
            shaderStrBlendComponentsHeaders = [NSMutableArray array];
            
            if(option.hasInput)
            {
                [uniforms addObject:[NSString stringWithFormat:@"uniform lowp float intensityUniform%ld;", (long)effectIndex]];
                if(option.canReplaceColor)
                {
                    [uniforms addObject:[NSString stringWithFormat:@"uniform mediump vec4 foregroundColorUniform%ld;", (long)effectIndex]];
                }
                [uniforms addObject:[NSString stringWithFormat:@"uniform mediump vec4 backgroundColorUniform%ld;", (long)effectIndex]];
            }
            if(x > 0) [shaderStrBlendComponentsHeaders addObject:@" previousOutputColor = outputColor; "];


#pragma mark - Setup Cutout Blending Prefixes
            
            if(option.hasInput)
            {
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
                
                if(x > 0)
                {
                    [shaderStrBlendComponentsHeaders addObject:[NSString stringWithFormat:@" inputColor = textureColor%ld; ", (long)effectIndex]];
                }
            }

            

            BOOL skipBlend = NO;
            BOOL skipPost = NO;
            
            if(!option.hasInput || option.type == MysticObjectTypeSetting)
            {
                switch (option.type) {
                    case MysticObjectTypeSetting:
                    {
                        
                        [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//      SETTINGS %d: %@:  \n// --------------------------------------------------------\n", (int)stackIndex , MyString(option.type)]];
                        
                        //                outputShaderStr = YES;
                        
                        MysticShaderStringSettings *settingsShader = [MysticShaderStringSettings settingsShaderForOption:option controlOutput:YES];
                        [shaderStrFunctions addObjectsFromArray:settingsShader.functions];
                        [shaderStrBlendComponents addObjectsFromArray:settingsShader.components];
                        [shaderStrBlendComponentsPrefixes addEntriesFromDictionary:settingsShader.prefixes];
                        [shaderStrBlendComponentsPrefixValues addObjectsFromArray:settingsShader.prefixValues];
                        [uniforms addObjectsFromArray:settingsShader.uniforms];
                        
                        
                        [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//       END OF SETTINGS %d: %@\n// --------------------------------------------------------\n\n\n", (int)stackIndex , MysticObjectTypeToString(option.type)]];

                        break;
                    }
                        
                    default:
                    {
//                        outputShaderStr = YES;

                        [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//      SPECIAL LAYER %d: %@: \"%@\" \n//      Effect: %d \n// --------------------------------------------------------\n", (int)stackIndex , MyString(option.type), option.name, option.layerEffect - MysticLayerEffectNone]];
                        
                        MysticShaderStringOption *optShader = [MysticShaderStringOption shaderForOption:option controlOutput:NO index:(MysticShaderIndex){ stackIndex, effectIndex, x,  prevEffectIndex, -1}];
                        [shaderStrFunctions addObjectsFromArray:optShader.functions.allValues];
                        [shaderStrBlendComponents addObject:optShader.shader];
//                        [shaderStrBlendComponentsPrefixes addEntriesFromDictionary:optShader.prefixes];
                        [uniforms addObjectsFromArray:optShader.uniforms.allValues];
                        
                        [theMains addObject:[optShader compileMains]];
                        
                        if(isM(optShader.mainTemplate))
                        {

                            [mainTemplates replaceObjectAtIndex:mainTemplates.count-1 withObject:optShader.mainTemplate];
                        }
                        
                        
                        [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//       END OF SPECIAL LAYER %d: %@ |  %@\n// --------------------------------------------------------\n\n\n", (int)stackIndex , MysticObjectTypeToString(option.type), option.name]];


                        break;
                    }
                }
                
                
                skipBlend = YES;
                skipPost = YES;
                numberOfInputs--;
                effectIndex--;
                
            }
            else
            {
                
                if(!option.showBg)
                {
                    skipBlend = NO;
                    MysticFilterType normalFilterType = option.normalBlendingType;
                    
        
                    if(option.canReplaceColor)
                    {
                        if(filterType == MysticFilterTypeBlendNormal)
                        {
                            if(![shaderStrFunctions containsObject:MysticShaderColorW]) [shaderStrFunctions addObject:MysticShaderColorW];

                            skipPost = YES;
                            filterType = MysticFilterTypeBlendAlpha;
                            if(!shouldInvert)
                            {
                                skipPost = NO;

                                preBlendStr = SHADER_STRING(
                                                            
                                                            highp float upperLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float upperRightLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerRightLuminance = dot(inputColor.rgb, W);
                                                            
                                                            highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
                                                            
                                                            maskColor = vec4(luminosity, luminosity, luminosity, 1.0);
                                                            inputColor = vec4(foregroundColorUniform%d.rgb, luminosity);
                                                            
                                                            );
                                preBlendStr = [NSString stringWithFormat:preBlendStr, effectIndex];

                            }
                            else
                            {
                                preBlendStr = SHADER_STRING(
                                                            
                                                            highp float upperLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float upperRightLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerRightLuminance = dot(inputColor.rgb, W);
                                                            
                                                            highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
                                                            luminosity = 1.0 - luminosity;
                                                            maskColor = vec4(luminosity, luminosity, luminosity, 1.0);
                                                            
                                                            inputColor = vec4(foregroundColorUniform%d.rgb, luminosity);

                                                            
                                                            );
                                
                                
                                preBlendStr = [NSString stringWithFormat:preBlendStr, effectIndex];

                            }
                        }
                        else
                        {
            
                            
                            
//                        outputShaderStr = YES;
                            NSString *maskColorStr;
                            switch (normalFilterType) {
                                case MysticFilterTypeBlendMaskMultiply:
                                case MysticFilterTypeBlendMultiply:
                                {
                                    
                                    maskColorStr = SHADER_STRING(
                                                                 maskColor = vec4((1.0 - inputColor.rgb), inputColor.a);
                                                                 
                                                                 );
                                    
                                    
                                    break;
                                }
                                case MysticFilterTypeBlendMaskScreen:
                                default:
                                    
                                    
                                    maskColorStr = @" maskColor = inputColor; ";
                                    
                                    
                                    
                                    break;
                            }
                            
                            if(option.fillTransparency)
                            {
                                [uniforms addObject:[NSString stringWithFormat:@"uniform mediump vec4 maskBackgroundColorUniform%ld;", (long)effectIndex]];

                                NSString *fillStr = SHADER_STRING(
                                                                   maskColor = mix(maskColor, maskBackgroundColorUniform%d,  1.0 - inputColor.a);
                                                                   maskColor = vec4(maskColor.rgb, 1.0);
                                                                  
                                                                  );
                                
                                fillStr = [NSString stringWithFormat:fillStr, effectIndex];
                                
                                maskColorStr = [maskColorStr stringByAppendingString:fillStr];
                            }
                            
                            
                            
                            
                            preBlendStr = SHADER_STRING(
                                                        inputColor = foregroundColorUniform%d;
                                                        
                                                        );
                            
                            
                            
                            preBlendStr = [NSString stringWithFormat:preBlendStr, effectIndex];

                            preBlendStr = [NSString stringWithFormat:@" %@ %@", maskColorStr, preBlendStr];
                        }
                        
                        

                    }
                    else
                    {
                        if(filterType == MysticFilterTypeBlendNormal)
                        {
                            if(![shaderStrFunctions containsObject:MysticShaderColorW]) [shaderStrFunctions addObject:MysticShaderColorW];
                            
                            skipPost = YES;
                            filterType = MysticFilterTypeBlendAlpha;
                            if(!shouldInvert)
                            {
                                preBlendStr = SHADER_STRING(
                                                        
                                                            highp float upperLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float upperRightLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerRightLuminance = dot(inputColor.rgb, W);
                                                            
                                                            highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
                                                            
                                                        maskColor = vec4(luminosity, luminosity, luminosity, 1.0);
                                                        inputColor = vec4(inputColor.rgb, luminosity * inputColor.a);
                                                        
                                                        );
                            }
                            else
                            {
                                preBlendStr = SHADER_STRING(
                                                            
                                                            highp float upperLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float upperRightLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerLeftLuminance = dot(inputColor.rgb, W);
                                                            highp float lowerRightLuminance = dot(inputColor.rgb, W);
                                                            
                                                            highp float luminosity = 0.25 * (upperLeftLuminance + upperRightLuminance + lowerLeftLuminance + lowerRightLuminance);
                                                            luminosity = 1.0 - luminosity;
                                                            maskColor = vec4(luminosity, luminosity, luminosity, 1.0);
                                                            inputColor = vec4(inputColor.rgb, luminosity * inputColor.a);
                                                            
                                                            );
                            }
                        }
                        else if(filterType != MysticFilterTypeBlendAlpha && filterType != MysticFilterTypeBlendAlphaMix)
                        {
                            skipPost = YES;
                            preBlendStr = SHADER_STRING(
                                                        
                                                        
                                                        maskColor = inputColor;
                                                        
                                                        );
                        }
                        else
                        {
                            skipPost = YES;
                        }
                    }
                    
//                      This shows a faded green background for debug
//                    postBlendStr = SHADER_STRING(
//                                                 
//                                                 outputColor = mix(previousOutputColor, outputColor, maskColor.r*maskColor.a);
//                                                 
//                                                 mediump vec4 greenColor2 = vec4(0.0, 1.0, 0.0, 0.35);
//                                                 outputColor = mix(outputColor, greenColor2, (1.0 - maskColor.r)*maskColor.a*greenColor2.a);
//                                                 
//                                                 
//                                                 );

                    postBlendStr = SHADER_STRING(
                    
                            outputColor = mix(previousOutputColor, outputColor, maskColor.r*maskColor.a);
                           
                    );

                    NSString *fillBgStr = @"";
                    if(option.fillBackgroundColor)
                    {
                        fillBgStr = SHADER_STRING(
                                                  previousOutputColor = mix(previousOutputColor, backgroundColorUniform%d, backgroundColorUniform%d.a);
                                                  );
                        postBlendStr = [[NSString stringWithFormat:fillBgStr, effectIndex, effectIndex] stringByAppendingString:postBlendStr];
                        
                    }
                    
                }
                
                
                
                
                
                
                
                

#pragma mark - BLENDING
                switch (filterType)
                {
                        
                case MysticFilterTypeBlendTextureMap:
                {
                    blendStr = SHADER_STRING(
                                             if (inputColor.a == 0.0) {
                                                 outputColor = outputColor;
                                             } else {
                                                 outputColor = vec4(mix(outputColor.rgb, inputColor.rgb, inputColor.a), outputColor.a);
                                                 
                                             }
                                             );
                    break;
                }
                    
//                case MysticFilterTypeBlendMaskScreen:
                case MysticFilterTypeBlendScreen:
                {
                    //
                    blendStr = SHADER_STRING(
                                             outputColor = whiteColor - ((whiteColor - inputColor) * (whiteColor - outputColor));
                                             );
                    
                    
                    useWhiteColor = YES;
                    break;
                }
//                case MysticFilterTypeBlendMaskMultiply:
                case MysticFilterTypeBlendMultiply:
                {
                    blendStr = SHADER_STRING(
                                             outputColor = inputColor * outputColor + inputColor * (1.0 - outputColor.a) + outputColor * (1.0 - inputColor.a);
                                             );
                    
                    break;
                }
                    
                    
#pragma mark -
#pragma mark - Blend Alpha
                case MysticFilterTypeBlendAlphaMask:
                case MysticFilterTypeBlendAlphaMaskFillBg:
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

                default:
                {
               
                    
                    blendStr = SHADER_STRING(
                                             outputColor = inputColor;
                                             );
                    
                    break;
                }
            }
                
            }
            
            [shaderStrBlendComponents addObjectsFromArray:shaderStrBlendComponentsHeaders];
            
            if(blendStr)
            {
                [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//      LAYER %d: %@: \"%@\" \n//      Blend: %@ \n//      Effect: %d \n//      Inverted: %@\n// --------------------------------------------------------\n", (int)stackIndex , MyString(option.type), option.name, option.blending, option.layerEffect - MysticLayerEffectNone, MBOOL(option.inverted)]];
            }
            if(preBlendStr)
            {
                [shaderStrBlendComponents addObject:preBlendStr];

            }
            if(blendStr && !skipBlend)
            {
                [shaderStrBlendComponents addObject:blendStr];
            }
            if(postBlendStr && !skipPost)
            {
                [shaderStrBlendComponents addObject:postBlendStr];
                
            }
            
            
            if(option.hasInput)
            {
                [shaderStrBlendComponents addObject:[NSString stringWithFormat:@" if(intensityUniform%d < 1.0) { outputColor = mix(previousOutputColor, outputColor, intensityUniform%d); }", (int)effectIndex, (int)effectIndex]];
            }
            
            if(blendStr)
            {
                [shaderStrBlendComponents addObject:[NSString stringWithFormat:@"\n// --------------------------------------------------------\n//       END OF LAYER %d: %@ Blend: %@  |  %@\n// --------------------------------------------------------\n\n\n", (int)stackIndex , MysticObjectTypeToString(option.type), option.blending, option.name]];
            }
            
            prevEffectIndex = effectIndex <= 1 ? 0 : effectIndex;
            option.shaderIndex = effectIndex;
            effectIndex++;
            stackIndex++;
            x++;
        }
        
        
        
#pragma mark - Add Functions, Uniforms & Variable Definitions to Shader String
        
        [shaderStrFunctions addObject:MysticShaderHeader];
        [shaderStrComponents addObjectsFromArray:shaderStrFunctions];
        if(uniforms.count) [shaderStrComponents addObjectsFromArray:uniforms];


#pragma mark - Add Shader Structure String
        
        switch (numberOfInputs)
        {
            case 1: { [shaderStrComponents addObject:MysticShaderOneUniform]; break; }
            case 2: { [shaderStrComponents addObject:MysticShaderTwoUniform]; break; }
            case 3: { [shaderStrComponents addObject:MysticShaderThreeUniform]; break; }
            case 4: { [shaderStrComponents addObject:MysticShaderFourUniform]; break; }
            case 5: { [shaderStrComponents addObject:MysticShaderFiveUniform]; break; }
            case 6: { [shaderStrComponents addObject:MysticShaderSixUniform]; break; }
            case 7: { [shaderStrComponents addObject:MysticShaderSevenUniform]; break; }
            case 8: { [shaderStrComponents addObject:MysticShaderEightUniform]; break; }
            default: break;
        }
        
        [shaderStrComponents addObject:MysticShaderMain];
        
        
        if(theMains.count)
        {
            [shaderStrComponents addObjectsFromArray:theMains];
        }
        
        
        NSString *tpl = mainTemplate;
        NSString *ltpl = mainTemplate;
        
        for (id mo in mainTemplates) {
            
            if(![mo isKindOfClass:[NSNull class]] && [mo isKindOfClass:[NSString class]])
            {
                tpl = mo;
                break;
            }
        }
        ltpl = tpl;

        NSArray *mtt = [NSArray arrayWithArray:mainTemplates];
        int _m = 0;
        int mc = mainTemplates.count;
        for (_m=0; _m < mc; _m++) {
            
            id mo = [mainTemplates objectAtIndex:_m];
            
            
            if(![mo isKindOfClass:[NSNull class]] && [mo isKindOfClass:[NSString class]])
            {
                ltpl = ltpl && [mo isEqualToString:ltpl] ? nil : mo;
            }
            else if(ltpl != nil)
            {
                
                [mainTemplates replaceObjectAtIndex:_m withObject:ltpl];
            }
            
        }
        
        
        
        for (int n = 1; n<numberOfInputs+1; n++) {
            
            
            
            id atpl = mainTemplates.count > n ? [mainTemplates objectAtIndex:n] : nil;
            
            DLog(@"shader string template");
            NSString *mains = [MysticShader template:isMEmpty(atpl) ? nil : atpl index:(MysticShaderIndex){n, n, n-1, 0} process:YES];
            
            
            if(mains) [shaderStrComponents addObject:mains];
        }
        
        switch (numberOfInputs)
        {
            case 1: { [shaderStrComponents addObject:MysticShaderOne]; break; }
            case 2: { [shaderStrComponents addObject:MysticShaderTwo]; break; }
            case 3: { [shaderStrComponents addObject:MysticShaderThree]; break; }
            case 4: { [shaderStrComponents addObject:MysticShaderFour]; break; }
            case 5: { [shaderStrComponents addObject:MysticShaderFive]; break; }
            case 6: { [shaderStrComponents addObject:MysticShaderSix]; break; }
            case 7: { [shaderStrComponents addObject:MysticShaderSeven]; break; }
            case 8: { [shaderStrComponents addObject:MysticShaderEight]; break; }
            default: break;
        }

#pragma mark - Add Option Shader Strings & Footer
        
        if([shaderStrComponents count])
        {
           

            NSString *outColor = @"outputColor";
            int ei = effectIndex - 1;
            switch (ei) {

                default:
                {
                    if(useWhiteColor) [shaderStrComponents addObject:MysticShaderColorWhite];
                    if(useBlackColor) [shaderStrComponents addObject:MysticShaderColorBlack];
                    
                    [shaderStrComponents addObjectsFromArray:shaderStrBlendComponentsPrefixValues];
                    [shaderStrComponents addObjectsFromArray:shaderStrBlendComponents];
                    
                    
                    break;
                }
            }
            [shaderStrComponents addObject:[NSString stringWithFormat:@" gl_FragColor = %@; }", outColor]];

          
           for (NSString *subStr in shaderStrComponents) {
               shaderStr = [shaderStr stringByAppendingString:@"\n"];
               shaderStr = [shaderStr stringByAppendingString:subStr];
           }
        }
    }

    
                                                                                                                                                                                                                                                                                                                       
#pragma mark - Return
    
    if(outputShaderStr)
    {
        NSString *outStr = [MysticShaderString outputString:shaderStr];
        DLog(@"shader: \n\n\n%@\n\n\n", outStr);
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:shaderStr forKey:@"shader"];
    if(vertexStr) [dict setObject:vertexStr forKey:@"vertex"];
    return dict;
}

                                                                                                                                                                                                                                                                                                                                                                   
@end

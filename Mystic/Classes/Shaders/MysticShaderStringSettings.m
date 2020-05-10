//
//  MysticShaderStringSettings.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "PackPotionOption.h"
#import "MysticShaderStringSettings.h"
#import "MysticShaderConstants.h"

@implementation MysticShaderStringSettings

+ (id) settingsShaderForOption:(PackPotionOption *)option controlOutput:(BOOL)shouldControl;
{
    MysticShaderStringSettings *shader = [[[self class] alloc] init];
    shader.controlsOutput = shouldControl;
    [shader settingsShadersForOption:option];
    return [shader autorelease];
}

@synthesize functions=_functions, prefixes=_prefixes, components=_components, prefixValues=_prefixValues, uniforms=_uniforms, controlsOutput=_controlsOutput, headers=_headers;

- (void) dealloc;
{
    [_components release];
    [_headers release];
    [_prefixes release];
    [_uniforms release];
    [_prefixValues release];
    [_functions release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _controlsOutput = YES;
    }
    return self;
}
- (void) settingsShadersForOption:(PackPotionOption *)option;
{
    if(!option) return;
    self.components = [NSMutableArray array];
    self.headers = [NSMutableArray array];
    self.prefixValues = [NSMutableArray array];
    self.prefixes = [NSMutableDictionary dictionary];
    self.functions = [NSMutableArray array];
    self.uniforms = [NSMutableArray array];
    NSString *blendStr = nil;
    NSDictionary *adjustments = option.adjustments;
    NSMutableString *typeStr = [NSMutableString string];
    for (NSString *key in [adjustments objectForKey:@"keys"]) {
        id value;
        MysticObjectType setting = [key integerValue];
        [typeStr appendFormat:@"%@,  ",MysticString(setting)];
    }
//    ALLog(@"settings shaders for option", @[@"option", MyString(option.type),
//                                            @"adjustments", MObj(typeStr),
//                                            ]);
    
    
    for (NSString *key in [adjustments objectForKey:@"keys"]) {
        id value;
        MysticObjectType setting = [key integerValue];
        
        [self.headers addObject:@" inColor = outputColor;"];
        
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
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
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
                if(![self.prefixes objectForKey:value])
                {
                    [self.functions addObject:@"const lowp vec3 warmFilter = vec3(0.93, 0.54, 0.0);"];
                    [self.functions addObject:@"const mediump mat3 RGBtoYIQ = mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.322, 0.212, -0.523, 0.311);"];
                    [self.functions addObject:@"const mediump mat3 YIQtoRGB = mat3(1.0, 0.956, 0.621, 1.0, -0.272, -0.647, 1.0, -1.105, 1.702);"];
                    [self.prefixes setObject:value forKey:value];
                }
                
                
                
                value = @"mediump vec3 yiq;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                value = @"lowp vec3 rgb;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                value = @"lowp vec3 processed;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
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
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                
                value = @"lowp vec3 lvlmid;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                
                value = @"lowp vec3 lvlmax;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                
                value = @"lowp vec3 lvlminOut;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                
                value = @"lowp vec3 lvlmaxOut;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
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
                if(![self.prefixes objectForKey:value])
                {
                    [self.functions addObject:@"const mediump vec3 satluminanceWeighting = vec3(0.2125, 0.7154, 0.0721);"];
                    [self.prefixes setObject:value forKey:value];
                }
                
                
                value = @"lowp float satluminance;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
                }
                value = @"lowp vec3 satgreyScaleColor;";
                if(![self.prefixes objectForKey:value])
                {
                    [self.prefixValues addObject:value];
                    [self.prefixes setObject:value forKey:value];
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
                if(![self.prefixes objectForKey:value])
                {
                    [self.functions addObject:@"const mediump vec3 hsluminanceWeighting = vec3(0.3, 0.3, 0.3);"];
                    [self.prefixes setObject:value forKey:value];
                }
                
                
                blendStr = [NSString stringWithFormat:MysticShaderShadows, option.shadows, option.highlights];
                
                
                break;
            }
                
                
            default:
            {
                break;
            }
        }
        [self.components addObjectsFromArray:self.headers];
        if(blendStr)
        {
            [self.components addObject:blendStr];
            [self.components addObject:@" outputColor = outColor; "];
        }
        blendStr = nil;
        self.headers = [NSMutableArray array];
    }
    
   
    
    if(self.controlsOutput)
    {
        [self.components addObject:MysticShaderControlOutput];
    }
        
    
}
@end

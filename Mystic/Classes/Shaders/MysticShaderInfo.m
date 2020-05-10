//
//  MysticShaderInfo.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/20/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticShaderInfo.h"
#import "PackPotionOption.h"

static BOOL processTemplates = YES;

@implementation MysticShaderInfo

+ (void) processTemplates:(BOOL)process;
{
    
    processTemplates = process;
    
}
+ (id) info:(id)info forKey:(NSString *)keyPath;
{
    return [self info:info forKey:keyPath option:nil];
}
+ (id) info:(id)info forKey:(NSString *)keyPath option:(PackPotionOption *)option;
{
    MysticShaderInfo *obj = [self class].new;
    obj.key = keyPath;
    
    if(option && [keyPath isEqualToString:@"functions.adjustcolor"])
    {
        NSDictionary *d = info;
        obj.function = d[@"function"];
        obj.functions = [NSMutableArray arrayWithArray:[d[@"functions"] componentsSeparatedByString:@","]];
        NSMutableArray *keys = [NSMutableArray array];
        if(d[@"constants"] && [d[@"constants"] isKindOfClass:[NSString class]])
            [keys addObjectsFromArray:[d[@"constants"] componentsSeparatedByString:@","]];
        else if(d[@"constants"] && [d[@"constants"] isKindOfClass:[NSArray class]])
            [keys addObjectsFromArray:d[@"constants"]];
        obj.constants = [NSMutableArray array];
        if(keys && keys.count) [obj.constants addObjectsFromArray:keys];
        NSArray * adc = option.adjustColorsFinal;
        NSMutableString *prefix = [NSMutableString stringWithFormat:@"// adjust colors: %d\n", (int)(adc ? (int)adc.count : (int)-1)];
        NSMutableString *uniforms = [NSMutableString stringWithString:@""];
        NSString *prefixTemplate = d[@"prefix"];
        NSString *uniformsTemplate = d[@"uniforms"];
        int i = 1;
        
        for (NSDictionary *ac in adc) {
            UIColor *source = ac[@"source"];
            UIColor *color = ac[@"color"];
            MysticThreshold threshold = ThresholdWithArray(ac[@"threshold"]);
            CGFloat intensity = [ac[@"intensity"] floatValue];
            [prefix appendString:processTemplates ? [prefixTemplate stringByReplacingOccurrencesOfString:@"$c" withString:[NSString stringWithFormat:@"%d", i]] : prefixTemplate];
            [prefix appendString:@"\n"];
            [uniforms appendString:processTemplates ? [uniformsTemplate stringByReplacingOccurrencesOfString:@"$c" withString:[NSString stringWithFormat:@"%d", i]] : uniformsTemplate];
            [uniforms appendString:@"\n"];
            i++;
        }
        obj.prefix = prefix;
        obj.uniform = uniforms;
        return [obj autorelease];
    }
    if([info isKindOfClass:[NSString class]])
    {
        if([keyPath hasPrefix:@"functions"]) obj.function = info;
        else if([keyPath hasPrefix:@"blends"]) obj.blend = info;
    }
    else if([info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *d = info;
        obj.blend = d[@"blend"];
        obj.function = d[@"function"];
        obj.prefix = d[@"prefix"];
        obj.suffix = d[@"suffix"];
        obj.line = d[@"line"];
        
        NSMutableArray *keys = [NSMutableArray array];
        
        if(d[@"constants"] && [d[@"constants"] isKindOfClass:[NSString class]])
            [keys addObjectsFromArray:[d[@"constants"] componentsSeparatedByString:@","]];
        else if(d[@"constants"] && [d[@"constants"] isKindOfClass:[NSArray class]])
            [keys addObjectsFromArray:d[@"constants"]];
        
        
        obj.constants = [NSMutableArray array];
        
        if(keys && keys.count) [obj.constants addObjectsFromArray:keys];
        
        [keys removeAllObjects];
        
        if(d[@"uniforms"] && [d[@"uniforms"] isKindOfClass:[NSString class]])
            [keys addObjectsFromArray:[d[@"uniforms"] componentsSeparatedByString:@","]];
        else if(d[@"uniforms"] && [d[@"uniforms"] isKindOfClass:[NSArray class]])
            [keys addObjectsFromArray:d[@"uniforms"]];
        obj.uniforms = [NSMutableArray array];
        if(keys && keys.count) [obj.uniforms addObjectsFromArray:keys];
        [keys removeAllObjects];
        
        if(d[@"functions"] && [d[@"functions"] isKindOfClass:[NSString class]])
            [keys addObjectsFromArray:[d[@"functions"] componentsSeparatedByString:@","]];
        else if(d[@"functions"] && [d[@"functions"] isKindOfClass:[NSArray class]])
            [keys addObjectsFromArray:d[@"functions"]];
        obj.functions = [NSMutableArray array];
        if(keys && keys.count) [obj.functions addObjectsFromArray:keys];
    }
    if(option && [keyPath isEqualToString:@"functions.vignette"] && option.vignetteBlendingType!=MysticFilterTypeBlendNormal)
    {
        NSDictionary *d = info;
        obj.function = d[@"function-blend"];
        obj.blendFunction = [MysticShaderData blendKey:@(option.vignetteBlendingType)];
        obj.prefix = d[@"prefix-blend"];
        NSDictionary *blend = [MysticShaderData lookupBlend:obj.blendFunction];
        if(blend && [blend isKindOfClass:[NSDictionary class]] && blend[@"prefix"])
        {
            obj.prefix = [obj.prefix stringByAppendingFormat:@"\n%@", blend[@"prefix"]];
            obj.prefix = [obj.prefix stringByReplacingOccurrencesOfString:@"$inputColor" withString:@"v$i"];
        }
        if(blend && [blend isKindOfClass:[NSDictionary class]] && blend[@"functions"])
        {
            if([blend[@"functions"] isKindOfClass:[NSString class]])
                [obj.functions addObjectsFromArray:[blend[@"functions"] componentsSeparatedByString:@","]];
            else if([blend[@"functions"] isKindOfClass:[NSArray class]])
                [obj.functions addObjectsFromArray:blend[@"functions"]];
        }
        if(blend && [blend isKindOfClass:[NSDictionary class]] && blend[@"constants"])
        {
            if([blend[@"constants"] isKindOfClass:[NSString class]])
                [obj.constants addObjectsFromArray:[blend[@"constants"] componentsSeparatedByString:@","]];
            else if([blend[@"constants"] isKindOfClass:[NSArray class]])
                [obj.constants addObjectsFromArray:blend[@"constants"]];
        }
        if(blend && [blend isKindOfClass:[NSDictionary class]] && blend[@"uniforms"])
        {
            if([blend[@"uniforms"] isKindOfClass:[NSString class]])
                [obj.uniforms addObjectsFromArray:[blend[@"uniforms"] componentsSeparatedByString:@","]];
            else if([blend[@"uniforms"] isKindOfClass:[NSArray class]])
                [obj.uniforms addObjectsFromArray:blend[@"uniforms"]];
        }
        //        ALLog(@"vignette shader:", @[@"function", MObj(obj.function),
        //                                     @"functions", MObj(obj.functions),
        //                                     @"blend func", MObj(obj.blendFunction),
        //                                     @"prefix", MObj(obj.prefix)]);
        
    }
    return [obj autorelease];
}



- (void) dealloc;
{
    [_functions release];
    [_key release];
    [_constants release];
    [_uniforms release];
    [_blend release];
    [_function release];
    [_line release];
    [_prefix release];
    [_suffix release];
    [_header release];
    [_footer release];
    [super dealloc];
}
@end
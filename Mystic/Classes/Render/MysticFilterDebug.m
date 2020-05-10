//
//  MysticFilter.m
//  Mystic
//
//  Created by Me on 11/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticFilterDebug.h"
#import "MysticGPUImageView.h"

@implementation MysticFilterDebug



+ (NSString *) logTargets:(id)outputObj depth:(int)d;
{
    GPUImageOutput <GPUImageInput>*output = (GPUImageOutput <GPUImageInput>*)outputObj;
    BOOL hasTargets = [output respondsToSelector:@selector(targets)];
    NSString *s = [NSString stringWithFormat:@"Chain:      %@      <%p>    %@", [output debugDescription], output, hasTargets ? @"" : @" <-- Doesn't have targets"];
    if(!hasTargets || !output)
    {
        return [NSString stringWithFormat:@"Output: Error not output or targets for: %@", outputObj];
    }
    NSString *s2 = [MysticFilterDebug logSubTargets:output depth:d];
    return [s stringByAppendingString:s2];
}




+ (NSString *) logSubTargets:(GPUImageOutput <GPUImageInput>*)output depth:(int)d;
{
    if(!output) return @"no output";
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (GPUImageOutput <GPUImageInput> *outp in output.targets) {
        BOOL r = [outp respondsToSelector:@selector(shouldIgnoreUpdatesToThisTarget)];
        NSString *s = [NSString stringWithFormat:@"\n\t                  %@╰──▶   %@%@      <%p>",
                       [@"       " repeat:d],
                       [outp debugDescription],
                       r && outp.shouldIgnoreUpdatesToThisTarget ? @"  -IGNORED-" : @"",
                       outp];


        if([outp respondsToSelector:@selector(targets)])
        {
            NSString *s2 = [MysticFilterDebug logSubTargets:outp depth:d+1];
            s = [s stringByAppendingString:s2];
            
        }
        
        [str appendString:s];
        
    }
    return str;
}


+ (NSString *) debugDescription:(MysticFilterManager *)manager;
{
    if(!manager.filter && !manager.sourcePicture && !manager.allLayers.count)
    {
        NSMutableString *str = [NSMutableString stringWithFormat:@"FiltersManager #%d: <%p> (empty)", (int)manager.index, manager];
        return str;
        
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"FiltersManager #%d: <%p>\n[\n\n", (int)manager.index, manager];
    [str appendFormat:@"\t\tFilter:     %@\n", manager.filter];
    [str appendFormat:@"\t\tSource:     %@\n", manager.sourcePicture];
    
    if(manager.allLayers)
    {
        [str appendFormat:@"\t\tLayers: \n\t"];
        MysticFilterLayer *lastLayer = nil;
        id lastFilter = nil;
        for (MysticFilterLayer *layer in manager.allLayers) {
            [str appendFormat:@"%@", [self layerDebugDescription:layer prefix:@"\t\t            "]];
            
            for (id _filterKey in layer.filterKeys)
            {
                id _filter = [layer.filters objectForKey:_filterKey];
                if([_filter isKindOfClass:[GPUImageTransformFilter class]])
                {
                    lastLayer = layer;
                    lastFilter = _filter;
                }
            }

        }
        
        
        [str appendString:@"\n\n"];
        [str appendFormat:@"\n\t\t%@\n", manager.allLayers.count ? [MysticFilterDebug logTargets:manager.firstInput depth:0] : @"Output:     none"];

        
    }
    
    [str appendString:@"\n\n]"];
    return str;
}

+ (NSString *) layerDebugDescription:(MysticFilterLayer *)layer;
{
    return [self layerDebugDescription:layer prefix:nil];
}
+ (NSString *) layerDebugDescription:(MysticFilterLayer *)layer prefix:(NSString *)prefix;
{
    prefix = prefix ? prefix : @"";
    NSMutableString *str = [NSMutableString stringWithString:@""];
    NSString *arrowStr = @"╰──▶   ";

    [str appendFormat:@"\n%@%d.  %@: %@  |   Layer: %@ <%p>  |  Option: <%p>%@%@", prefix, (int)layer.index+1, MyString(layer.option.type), layer.option.shortName, layer.tag, layer, layer.option, layer.filters.count ? @"\n" : @"", prefix];
    int n = 1;
    NSString *newPrefix = arrowStr;
    for (id _filterKey in layer.filterKeys)
    {
        id _filter = [layer.filters objectForKey:_filterKey];
        NSString *_filterExtra = @"";
        if([_filter isKindOfClass:[GPUImageTransformFilter class]])
        {
            _filterExtra = FLogStr(layer.option.transformRect);
        }
        [str appendFormat:@"\n%@    %@%d.  %@ <%p>  %@", prefix, arrowStr, n, [_filter class], _filter, _filterExtra];
        n++;
    }
    [str appendFormat:@"%@", layer.filters.count ? [NSString stringWithFormat:@"\n%@\n", prefix] : @""];
    
    return str;
}



@end

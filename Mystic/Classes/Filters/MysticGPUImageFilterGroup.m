//
//  MysticGPUImageFilterGroup.m
//  Mystic
//
//  Created by Travis A. Weerts on 2/26/17.
//  Copyright © 2017 Blackpulp. All rights reserved.
//

#import "MysticGPUImageFilterGroup.h"

@implementation MysticGPUImageFilterGroup

- (void) removeAllFilters;
{
    [filters removeAllObjects];
}
- (NSArray *) allFilters;
{
    return filters;
}
- (NSString *) debugDescription;
{
    NSString *format = @"%@: (%@)";
    NSMutableString *filtersStr = [NSMutableString string];
    for (id filter in self.allFilters) {
        [filtersStr appendFormat:@"%@, ", [filter class]];
    }
    return [NSString stringWithFormat:format, [self class], filtersStr];
}

@end

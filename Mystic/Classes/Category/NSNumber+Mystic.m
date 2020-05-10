//
//  NSNumber+Mystic.m
//  Mystic
//
//  Created by Travis A. Weerts on 3/3/17.
//  Copyright © 2017 Blackpulp. All rights reserved.
//

#import "NSNumber+Mystic.h"

@implementation NSNumber (Mystic)

- (NSString *) intString;
{
    return [NSString stringWithFormat:@"%d", (int)self.integerValue];
}
@end

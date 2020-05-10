//
//  MysticPackPickerGridItem.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerGridItem.h"

@implementation MysticPackPickerGridItem

- (void) dealloc;
{
    [_option release];
    [_pack release];
    [super dealloc];
}
@end

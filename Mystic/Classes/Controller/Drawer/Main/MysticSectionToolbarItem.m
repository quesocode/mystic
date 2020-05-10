//
//  MysticSectionToolbarItem.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSectionToolbarItem.h"

@implementation MysticSectionToolbarItem

+ (MysticIconType) iconColor:(MysticIconType)iconType;
{
    return MysticColorTypeDrawerNavBarText;
}
+ (MysticIconType) iconColorHighlighted:(MysticIconType)iconType;
{
    return MysticColorTypeUnknown;
}
+ (MysticIconType) iconColorSelected:(MysticIconType)iconType;
{
    return MysticColorTypeUnknown;
}


@end

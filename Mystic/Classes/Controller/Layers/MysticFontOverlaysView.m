//
//  MysticFontOverlaysView.m
//  Mystic
//
//  Created by Me on 3/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontOverlaysView.h"
#import "MysticController.h"

@implementation MysticFontOverlaysView

+ (CGRect) maxLayerBounds;
{
    return CGRectInset(CGRectSize([MysticController controller].imageFrame.size), MYSTIC_LAYERS_BOUNDS_INSET, MYSTIC_LAYERS_BOUNDS_INSET);
}

- (NSInteger) tag;
{
    return MysticViewTypeLayersFonts;
}


@end

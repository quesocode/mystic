//
//  MysticShapesOverlaysView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticShapesOverlaysView.h"
#import "MysticController.h"

@implementation MysticShapesOverlaysView

+ (CGRect) maxLayerBounds;
{
    return CGRectInset(CGRectSize([MysticController controller].imageFrame.size), MYSTIC_LAYERS_BOUNDS_INSET, MYSTIC_LAYERS_BOUNDS_INSET);
}

- (NSInteger) tag;
{
    return MysticViewTypeLayersShapes;
}

@end

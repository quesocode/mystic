//
//  MysticLayerPanelBottomBarView.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerPanelBottomBarView.h"

@implementation MysticLayerPanelBottomBarView

- (void) commonInit;
{
//    [super commonInit];
//    self.showBorder = NO;
//    self.borderPosition = MysticPositionTop;
//    self.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
}
- (CGPoint) contentCenter;
{
    return self.center;
}
- (CGRect) contentBounds;
{
    return self.bounds;
}
- (MysticLayerToolbar *) toolbar;
{
    for (UIView *sub in self.subviews) {
        if([sub isKindOfClass:NSClassFromString(@"MysticLayerToolbar")])
        {
            return (id)sub;
        }
    }
    return nil;
}

@end

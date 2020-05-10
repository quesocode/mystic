//
//  WDCellSelectionView.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDCellSelectionView.h"

@implementation WDCellSelectionView

@synthesize startColor;
@synthesize endColor;

+ (Class) layerClass {
    return [CAGradientLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
//    
//    startColor = [UIColor colorWithRed:(206.0f / 255.0f) green:(216.0f / 255.0f) blue:(237.0f / 255.0f) alpha:1.0f];
//    endColor = [UIColor colorWithRed:(115.0f / 255.0f) green:(137.0f / 255.0f) blue:(179.0f / 255.0f) alpha:1.0f];
//    
//    [self rebuildGradient];
    self.backgroundColor = [UIColor colorWithRed:0.25 green:0.22 blue:0.20 alpha:1.00];
//    self.backgroundColor = [UIColor colorWithRed:0.15 green:0.14 blue:0.13 alpha:1.00];
    return self;
}

- (void) rebuildGradient
{    
    CAGradientLayer *layer = (CAGradientLayer *) self.layer;
    layer.colors = @[(id) startColor.CGColor, (id)(endColor.CGColor)];
}

- (void) setStartColor:(UIColor *)inStartColor
{
    startColor = inStartColor;
    [self rebuildGradient];
}

- (void) setEndColor:(UIColor *)inEndColor
{
    endColor = inEndColor;
    [self rebuildGradient];
}

@end

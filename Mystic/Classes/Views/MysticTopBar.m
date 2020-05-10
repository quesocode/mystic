//
//  MysticTopBar.m
//  Mystic
//
//  Created by travis weerts on 5/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTopBar.h"

@implementation MysticTopBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef patternImage;
    patternImage = [UIImage imageNamed:@"bg-header-corner.jpg"].CGImage;
    CGContextScaleCTM (context, 1, -1);
    CGRect newRect = rect;
    newRect.origin.y = -50;
    CGContextDrawImage(context, newRect, patternImage);
}

@end

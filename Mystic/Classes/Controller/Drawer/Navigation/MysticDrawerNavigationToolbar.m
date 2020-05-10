//
//  MysticDrawerNavigationToolbar.m
//  Mystic
//
//  Created by Me on 3/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticDrawerNavigationToolbar.h"

@implementation MysticDrawerNavigationToolbar

- (void) commonInit;
{
    [super commonInit];
    self.tintColor = [UIColor color:MysticColorTypeDrawerToolbar];
    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    self.translucent = NO;
}

- (CGSize) sizeThatFits:(CGSize)size;
{
    CGSize newSize = [super sizeThatFits:size];
    
    newSize.height = MYSTIC_UI_DRAWER_NAV_TOOLBAR_HEIGHT;
    return newSize;
}

- (void)drawRect:(CGRect)rect
{
    // do nothing in here
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 1);
    CGRect borderRect = CGRectMake(0, 0, rect.size.width, 1);
    
    CGContextMoveToPoint(context, borderRect.origin.x, rect.origin.y+0.5);
    CGContextAddLineToPoint(context, borderRect.size.width, rect.origin.y+0.5);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithType:MysticColorTypeDrawerBackgroundCellBorder] CGColor]);
    

    CGContextStrokePath(context);
    
    
    
    
  
}

@end

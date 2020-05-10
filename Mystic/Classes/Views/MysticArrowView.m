//
//  MysticArrowView.m
//  Mystic
//
//  Created by Me on 10/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticArrowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MysticArrowView

- (void) dealloc;
{
    [_arrowBorderColor release];
    [_arrowColor release];
    [super dealloc];
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(self.backgroundColor.alpha > 0)
    {
        [self.backgroundColor setFill];
        CGContextFillRect(context, rect);
        
    }
    CGPoint __borderOffset = CGPointEqualToPoint(self.borderOffset, CGPointUnknown) ? CGPointZero : self.borderOffset;
    CGFloat sx = 0;
    CGFloat sx2 = 0;
    
    CGFloat sy = 0;
    CGFloat syb = 0;
    
    CGFloat ih = self.borderInsets.top + self.borderInsets.bottom;
    CGFloat iw = self.borderInsets.left + self.borderInsets.right;
    
    if(self.arrowPosition & MysticPositionLeft)
    {
        CGContextMoveToPoint(context, self.borderInsets.left+ __borderOffset.x, rect.size.height/2);
        CGContextAddLineToPoint(context, rect.size.width - self.borderInsets.right- __borderOffset.x, self.borderInsets.top + __borderOffset.y);
        CGContextAddLineToPoint(context, rect.size.width - self.borderInsets.right- __borderOffset.x, rect.size.height - self.borderInsets.bottom - __borderOffset.y);
        CGContextAddLineToPoint(context, self.borderInsets.left+ __borderOffset.x, rect.size.height/2);
        if(self.arrowColor)
        {
            [self.arrowColor setFill];
            CGContextFillPath(context);
        }
        if(self.arrowBorderColor)
        {
            CGContextSetStrokeColorWithColor(context, [self.arrowBorderColor CGColor]);
            CGContextStrokePath(context);
        }
        
        
        
    }
    
    
}


@end

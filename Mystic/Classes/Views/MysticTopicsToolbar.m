//
//  MysticTopicsToolbar.m
//  Mystic
//
//  Created by travis weerts on 8/29/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTopicsToolbar.h"
#import "Mystic.h"

@implementation MysticTopicsToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.backgroundColor setFill];
    
    CGContextFillRect(context, rect);
    
    CGRect newRect = CGRectMake(0, rect.size.height-2.0f, rect.size.width, 2.0f);
    
    CGContextClipToRect(context, newRect);
    
    UIImage *coloredDots = [MysticIcon imageNamed:@"dottedTile.png" color:[UIColor hex:@"3c3431"]];
    CGContextDrawTiledImage(context, CGRectMake(0,0, 6, 2.0f), coloredDots.CGImage);
    
    
}


@end

//
//  MysticBarColorButton.m
//  Mystic
//
//  Created by Travis A. Weerts on 1/25/17.
//  Copyright © 2017 Blackpulp. All rights reserved.
//

#import "MysticBarColorButton.h"

@implementation MysticBarColorButton

- (void) commonInit;
{
    [super commonInit];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}

- (void) setFrame:(CGRect)frame;
{
    if(frame.size.width != frame.size.height)
    {
        frame.size.width = MIN(frame.size.height, frame.size.width);
        frame.size.height = frame.size.width;
    }
    [super setFrame:frame];
}
@end

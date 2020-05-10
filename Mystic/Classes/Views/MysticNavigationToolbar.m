//
//  MysticNavigationToolbar.m
//  Mystic
//
//  Created by travis weerts on 9/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticNavigationToolbar.h"

@implementation MysticNavigationToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  MysticActionSheet.m
//  Mystic
//
//  Created by Travis on 10/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticActionSheet.h"

@implementation MysticActionSheet

@synthesize indexPath=_indexPath;

- (void) dealloc;
{
    [_indexPath release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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

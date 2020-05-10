//
//  TitleBarButton.m
//  Mystic
//
//  Created by travis weerts on 1/18/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "TitleBarButton.h"

@implementation TitleBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    frame.origin.y = 0;
    [super setFrame:frame];
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

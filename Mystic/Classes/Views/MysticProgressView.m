//
//  MysticProgressView.m
//  Mystic
//
//  Created by Travis A. Weerts on 5/31/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticProgressView.h"

@implementation MysticProgressView

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    return [self commonInit];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    return [self commonInit];
}
- (id) commonInit;
{
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00];
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  MysticLayerCountButton.m
//  Mystic
//
//  Created by Me on 3/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticLayerCountButton.h"
#import "Mystic.h"
#import "MysticRoundView.h"

@interface MysticLayerCountButton ()
@property (nonatomic, assign) MysticRoundView *roundView;

@end
@implementation MysticLayerCountButton


- (void) commonInit;
{
    self.titleEdgeInsets = UIEdgeInsetsMake(-1, 0, 0, 0);
    
    self.roundView = [[[MysticRoundView alloc] initWithFrame:self.bounds] autorelease];
    self.roundView.borderWidth = 2;
    self.roundView.borderColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
    self.roundView.blur = YES;
    self.titleLabel.font = [MysticFont fontBold:10];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.72 alpha:1] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateHighlighted];
    [self setTitle:@"1" forState:UIControlStateNormal];
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.roundView.userInteractionEnabled=NO;
    [self addSubview:self.roundView];
    [self sendSubviewToBack:self.roundView];
    
}
- (void) resetColor;
{
    self.roundView.borderColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.19 alpha:1];
    [self setTitleColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.72 alpha:1] forState:UIControlStateNormal];

}
- (UIColor *) backgroundColor; { return self.roundView.backgroundColor; }
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    self.roundView.backgroundColor = backgroundColor;
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.roundView.bounds = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

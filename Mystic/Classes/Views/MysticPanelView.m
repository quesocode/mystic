//
//  MysticPanelView.m
//  Mystic
//
//  Created by travis weerts on 9/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticPanelView.h"
#import "MysticController.h"

@interface MysticPanelView ()
@property (nonatomic, retain) UIVisualEffectView *blurView;

@end
@implementation MysticPanelView

- (void) dealloc;
{
    [_blurView release];
    [_originalBackgroundColor release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    if(self.blurView && (!self.originalBackgroundColor || self.originalBackgroundColor == UIColor.clearColor))
    {
        self.originalBackgroundColor = backgroundColor;
        [super setBackgroundColor:[backgroundColor alpha:0.75]];
        return;
    }
    [super setBackgroundColor:backgroundColor];
}
- (void) setBlurBackground:(BOOL)blur;
{
    _blurBackground=blur;
    if(blur && !self.blurView)
    {
        if(!self.originalBackgroundColor) self.originalBackgroundColor = self.backgroundColor;
        self.blurView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
        self.blurView.frame = self.bounds;
        [self addSubview:self.blurView];
        [self sendSubviewToBack:self.blurView];
        self.backgroundColor = self.originalBackgroundColor;
    }
    else if(!blur && self.blurView)
    {
        [self.blurView removeFromSuperview];
        self.blurView = nil;
        self.backgroundColor = self.originalBackgroundColor;
        self.originalBackgroundColor = nil;
    }
    
    
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    [self.blurView sendToBack];
    CGRect nf = self.bounds;
    for (UIView *v in self.subviews) {
        nf.size.height = CGRectGetMaxY(v.frame);
    }
    nf = CGRectPosition(nf, self.bounds, MysticPositionBottom);
    self.blurView.frame = nf;
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

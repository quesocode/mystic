//
//  MysticBlurBackgroundView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticBlurBackgroundView.h"
#import "MysticCommon.h"

@interface MysticBlurBackgroundView ()

@end
@implementation MysticBlurBackgroundView

- (void) dealloc;
{
    [_blurView release];
    [_originalBackgroundColor release];
    [super dealloc];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    return [self commonInit];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    return [self commonInit];
}
- (instancetype) commonInit;
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    _backgroundColorAlpha = 0;
    self.opaque = NO;
    self.blurBackground = YES;
    return self;
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    if(self.blurView && (!self.originalBackgroundColor || self.originalBackgroundColor == UIColor.clearColor))
    {
        self.originalBackgroundColor = backgroundColor;
        [super setBackgroundColor:UIColor.clearColor];

        if(self.backgroundColorAlpha > 0) [super setBackgroundColor:[backgroundColor alpha:self.backgroundColorAlpha]];
        return;
    }
    [super setBackgroundColor:UIColor.clearColor];
}
- (void) setBlurBackground:(BOOL)blur;
{
    _blurBackground=blur;
    if(blur && !self.blurView)
    {
        if(!self.originalBackgroundColor) self.originalBackgroundColor = self.backgroundColor;
        self.blurView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
        self.blurView.frame = self.bounds;
        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.blurView.bounds = self.bounds;
}
//- (void) layoutSubviews;
//{
//    [super layoutSubviews];
//    [self.blurView sendToBack];
//    CGRect nf = self.bounds;
//    for (UIView *v in self.subviews) {
//        nf.size.height = CGRectGetMaxY(v.frame);
//    }
//    nf = CGRectPosition(nf, self.bounds, MysticPositionBottom);
//    self.blurView.frame = nf;
//}

@end

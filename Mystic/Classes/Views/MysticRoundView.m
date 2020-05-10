//
//  MysticRoundView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticRoundView.h"
#import "MysticCommon.h"

@interface MysticRoundView ()

@property (nonatomic, strong) UIView *border, *background;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end
@implementation MysticRoundView

@synthesize borderColor=_borderColor, borderWidth=_borderWidth;
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) [self setup];
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self) [self setup];
    return self;
}
- (void) setup;
{
    self.clipsToBounds = NO;
    _blur = NO;
    self.background = [[UIView alloc] initWithFrame:self.bounds];
    self.background.center = CGPointMid(self.bounds);
    self.background.clipsToBounds = YES;
    [self addSubview:self.background];
    self.border = [[UIView alloc] initWithFrame:CGRectInset( self.bounds, -1, -1)];
    self.border.center = CGPointMid(self.bounds);
    [self addSubview:self.border];
    self.border.layer.cornerRadius = CGRectGetHeight(self.border.bounds)/2;
    self.background.layer.cornerRadius = CGRectGetHeight(self.background.bounds)/2;
    self.borderWidth=2;
    [super setBackgroundColor:UIColor.clearColor];
}
- (UIColor *) borderColor; { return [UIColor colorWithCGColor:self.border.layer.borderColor]; }
- (void) setBorderColor:(UIColor *)borderColor;
{
    self.border.layer.borderColor = borderColor.CGColor;
}
- (void) setBorderWidth:(CGFloat)borderWidth;
{
    self.border.layer.borderWidth = floorf(borderWidth);
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    if(self.blurView && (!self.originalBackgroundColor || self.originalBackgroundColor == UIColor.clearColor))
   {
       self.originalBackgroundColor = backgroundColor;
       return;
   }
    self.background.backgroundColor = backgroundColor;
}
- (UIColor *) backgroundColor; { return self.background.backgroundColor; }
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    if(self.background)
    {
        self.background.bounds = self.bounds;
        self.background.layer.cornerRadius = CGRectGetHeight(self.background.bounds)/2;
        self.background.center = CGPointMid(self.bounds);

    }
    if(self.border)
    {
        self.border.bounds = CGRectInset( self.bounds, -1, -1);
        self.border.layer.cornerRadius = CGRectGetHeight(self.border.bounds)/2;
        self.border.center = CGPointMid(self.bounds);
        
    }
}
- (void) setBlur:(BOOL)blur;
{
    _blur=blur;
    if(blur && !self.blurView)
    {
        if(!self.originalBackgroundColor) self.originalBackgroundColor = self.backgroundColor;
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.blurView.frame = self.background.bounds;
        [self.background addSubview:self.blurView];
        self.background.backgroundColor = UIColor.clearColor;
    }
    else if(!blur && self.blurView)
    {
        [self.blurView removeFromSuperview];
        self.blurView = nil;
        self.backgroundColor = self.originalBackgroundColor;
        self.originalBackgroundColor = nil;
    }
}
@end

//
//  BottomToolbar.m
//  Mystic
//
//  Created by travis weerts on 1/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "BottomToolbar.h"
#import "MysticConstants.h"
#import "UIColor+Mystic.h"
#import "MysticColor.h"
#import "MysticController.h"

@interface BottomToolbar ()
{
    UIColor *_backgroundColor;
}
@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

@implementation BottomToolbar

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
//        [self commonInit];

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    _blurBackground = YES;
//    [super commonInit];
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.showBorder = NO;
    self.borderPosition = MysticPositionTop;
//    self.borderColor = [[UIColor red] colorWithAlphaComponent:1];
//    self.borderWidth = 2;
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    if(self.blurView && (!self.originalBackgroundColor || self.originalBackgroundColor == UIColor.clearColor))
    {
        self.originalBackgroundColor = backgroundColor;
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
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.blurView.frame = self.bounds;
        [self addSubview:self.blurView];
        [self sendSubviewToBack:self.blurView];
        self.backgroundColor = UIColor.clearColor;
    }
    else if(!blur && self.blurView)
    {
        [self.blurView removeFromSuperview];
        self.blurView = nil;
        self.backgroundColor = self.originalBackgroundColor;
        self.originalBackgroundColor = nil;
    }
    
    ALLog(@"view", @[@"view", VLLogStr([MysticController controller].view)]);
    
}

//- (void) setBackgroundColor:(UIColor *)backgroundColor;
//{
//    [_backgroundColor release], _backgroundColor=nil;
//    if(backgroundColor)
//    {
//        _backgroundColor = [backgroundColor retain];
//    }
//}
//- (UIColor *) backgroundColor;
//{
//    
//    return _backgroundColor ? _backgroundColor : [MysticColor colorWithType:MysticColorTypeBottomBar];
//}
//#ifdef SHOWTEXTURES
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    
//    [self.backgroundColor setFill];
//    
//    CGContextFillRect(context, rect);
//}
//#endif

@end

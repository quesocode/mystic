//
//  MysticIndicatorView.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticIndicatorView.h"
#import "MysticColor.h"

@implementation MysticIndicatorView

- (void) dealloc;
{
    [_lineColor release];
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        _lineHeight = 1.5;
        _duration = 0.25;
        _delay = 0;
        _insets = UIEdgeInsetsMake(8, 2, 7, 2);
        self.lineColor = [[UIColor hex:@"6B5F57"] colorWithAlphaComponent:0.5];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = NO;
        UIView *topView = [[UIView alloc] initWithFrame:(CGRect){self.insets.left,self.insets.top,frame.size.width - self.insets.left - self.insets.right, self.lineHeight}];
        topView.backgroundColor = self.lineColor;
        topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topView];
        
        UIView *btmView = [[UIView alloc] initWithFrame:(CGRect){self.insets.left,frame.size.height - self.lineHeight - self.insets.bottom, frame.size.width - self.insets.left - self.insets.right, self.lineHeight}];
        btmView.backgroundColor = self.lineColor;
        btmView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:btmView];
        
        self.bottomView = btmView;
        self.topView = topView;
        
        [btmView autorelease];
        [topView autorelease];
    }
    
    return self;
}

- (void) setLineColor:(UIColor *)lineColor;
{
    if(_lineColor)
    {
        [_lineColor release];
    }
    _lineColor = [lineColor retain];
    if(self.topView) self.topView.backgroundColor = _lineColor;
    if(self.bottomView) self.bottomView.backgroundColor = _lineColor;
}
- (void) setInsets:(UIEdgeInsets)insets;
{
    _insets = insets;
    if(self.topView) self.topView.frame = (CGRect){_insets.left,_insets.top,self.frame.size.width - _insets.left - _insets.right, self.lineHeight};
    if(self.bottomView) self.bottomView.frame = (CGRect){_insets.left,self.frame.size.height - self.lineHeight - _insets.bottom, self.frame.size.width - _insets.left - _insets.right, self.lineHeight};
}

- (void) animateToView:(UIView *)subview animated:(BOOL)animated complete:(MysticBlockBOOL)completion;
{
    if(animated)
    {
        [MysticUIView animateWithDuration:self.duration delay:self.delay options:UIViewAnimationCurveEaseOut animations:^{
            
            CGRect f = self.frame;
            f.origin.x = subview.frame.origin.x;
            f.size.width = subview.frame.size.width;
            self.frame = f;
            
        } completion:completion];
    }
    else
    {
        CGRect f = self.frame;
        f.origin.x = subview.frame.origin.x;
        f.size.width = subview.frame.size.width;
        self.frame = f;
    }
    
}

@end

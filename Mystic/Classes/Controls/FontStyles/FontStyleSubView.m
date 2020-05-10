//
//  FontStyleSubView.m
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "FontStyleSubView.h"

@implementation FontStyleSubView

@synthesize label=_label, backgroundView=_backgroundView;

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.autoresizesSubviews = YES;
        MysticFontStyleLabelView *label = [[MysticFontStyleLabelView alloc] initWithFrame:self.bounds];
        label.fdAutoFitMode = FDAutoFitModeContrainedFrame;
        label.numberOfLines=1;
        self.label = label;
    }
    return self;
}

- (void) commonInit;
{

}
- (void) setLabel:(MysticFontStyleLabelView *)label;
{
    label.frame = self.bounds;
    if(_label) { [_label removeFromSuperview];     [_label release]; _label = nil; }
    _label = [label retain];
    [self addSubview:label];
}

- (void) setBackgroundView:(MysticBorderView *)backgroundView;
{
    backgroundView.frame = self.bounds;
    if(_backgroundView) { [_backgroundView removeFromSuperview]; [_backgroundView release]; _backgroundView = nil; }
    _backgroundView = [backgroundView retain];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self insertSubview:_backgroundView belowSubview:self.label];

}

- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    if(!self.backgroundView)
    {
        MysticBorderView * b = [[MysticBorderView alloc] initWithFrame:self.bounds];
        b.showBorder = NO;
        b.backgroundColor = backgroundColor;
        self.backgroundView = b;
    }
    else
    {
        self.backgroundView.backgroundColor = backgroundColor;
    }
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.label.frame = self.bounds;
    
}

@end

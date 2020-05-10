//
//  MysticScrollHeaderView.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticScrollHeaderView.h"
#import "Mystic.h"
#import "MysticScrollView.h"
#import "MysticArrowView.h"


@interface MysticScrollHeaderView ()
{
    
}
@property (nonatomic, retain) MysticButton *browseButton;
@property (nonatomic, retain) MysticArrowView *arrow;
@property (nonatomic, assign) CGRect originalArrowFrame;

@end

@implementation MysticScrollHeaderView


+ (id) headerViewWithScrollView:(MysticScrollView *)scrollView;
{
    
    CGRect hFrame = CGRectZero;
    hFrame.size = scrollView.tileSize;
    hFrame.size.width = 50;
    hFrame.size.height -= scrollView.margin;
    hFrame.origin.y = scrollView.margin;
    return [self headerViewWithScrollView:scrollView frame:hFrame];
}
+ (id) headerViewWithScrollView:(MysticScrollView *)scrollView frame:(CGRect)hFrame;
{
    
    MysticScrollHeaderView *headerView = [[[self class] alloc] initWithFrame:hFrame];
    headerView.scrollView = scrollView;
    headerView.originalInsets = scrollView.contentInset;
    return [headerView autorelease];
}
- (void) dealloc;
{
    [self.browseButton removeFromSuperview];
    [super dealloc];
    _scrollView = nil;
    _delegate = nil;
    [_arrow release];
    [_browseButton release];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _visibleDelay = 5.0f;
        _visibleThreshold = 0.65f;
        _animateInDuration = 0.3f;
        _animateOutDuration = 0.3f;
        self.clipsToBounds = YES;
        CGSize bSize = CGSizeMake(50, 50);
        self.autoresizesSubviews = YES;
        self.backgroundColor = [MysticColor color:@(MysticColorTypePink)];
        self.browseButton = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeMoreArtArrow) size:(CGSize){16,18} color:@(MysticColorTypeMoreArtArrow)] target:self sel:@selector(browseButtonTouched:)];
//        self.browseButton.titleLabel.font = [MysticFont fontBold:13];
//        self.browseButton.titleLabel.numberOfLines = 0;
//        self.browseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self.browseButton setImage:[MysticImage image:@(MysticIconTypeToolBrowsePack) size:bSize color:[UIColor color:MysticColorTypePink]] forState:UIControlStateHighlighted];
//        [self.browseButton setImage:[self.browseButton imageForState:UIControlStateHighlighted] forState:UIControlStateSelected];
        
//        [self.browseButton setTitleColor:[UIColor color:MysticColorTypeBottomBarButtonTitle] forState:UIControlStateNormal];
//        [self.browseButton setTitleColor:[UIColor color:MysticColorTypeBottomBarButtonTitle] forState:UIControlStateHighlighted];
        self.browseButton.contentMode = UIViewContentModeCenter;
        [self.browseButton setBackgroundColor:self.backgroundColor forState:UIControlStateNormal];
        [self.browseButton setBackgroundColor:[self.backgroundColor darker:0.3] forState:UIControlStateHighlighted];
        
        CGRect bFrame = self.bounds;
        self.browseButton.frame = bFrame;
        self.browseButton.canSelect = YES;
        self.browseButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.browseButton.contentMode = UIViewContentModeCenter;
        [self addSubview:self.browseButton];
        self.originalFrame = frame;
        
        MysticArrowView *arrow = [[MysticArrowView alloc] initWithFrame:(CGRect){0,0,10.5,28}];
        arrow.contentMode = UIViewContentModeRedraw;
        arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        arrow.userInteractionEnabled = NO;
        arrow.arrowPosition = MysticPositionLeft;
        arrow.arrowColor = [UIColor hex:@"161614"];
        CGRect arrowFrame = CGRectAlign(arrow.frame, self.bounds, MysticAlignPositionRight);
        arrowFrame.origin.x += 2;
        arrow.frame = arrowFrame;
        arrow.bounds = CGRectIntegral(CGRectSize([MysticUI scaleSize:arrowFrame.size scale:2.5]));
        arrow.transform = CGAffineTransformMakeScale(1/2.5, 1/2.5);

        self.originalArrowFrame = arrowFrame;
        [arrow setNeedsDisplay];
       
        
        [self addSubview:arrow];
        self.arrow = [arrow autorelease];
        
        
    }
    return self;
}

- (void) browseButtonTouched:(id)sender;
{
    self.browseButton.selected = YES;
    [self.browseButton setNeedsDisplay];
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollHeader:didTouchItem:)])
    {
        [self.delegate scrollHeader:self didTouchItem:sender];
    }
}


- (void) updatePosition:(CGPoint)offset scrollView:(MysticScrollView *)scrollView;
{
    CGRect newFrame = self.frame;
    self.scrollView = scrollView;
    
    if(offset.x >= 0)
    {
        self.browseButton.selected = NO;
    }
    if(offset.x <= -(self.originalFrame.size.width + scrollView.margin))
    {
        newFrame.size.width = (offset.x*-1) - scrollView.margin;
        newFrame.origin.x = offset.x;
        float s = (1/2.5) * (newFrame.size.width/self.originalFrame.size.width);
        self.arrow.transform = CGAffineTransformMakeScale(s, s);
    }
    else
    {
        newFrame.size.width = self.originalFrame.size.width;
        newFrame.origin.x = - (self.originalFrame.size.width + scrollView.margin);
    }
    self.frame = newFrame;
}

- (void) removeFromSuperview;
{
    self.delegate = nil;
    [self.browseButton removeTarget:self action:@selector(browseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.scrollView = nil;
    [super removeFromSuperview];
}


@end

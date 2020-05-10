//
//  MysticPageControl.m
//  Mystic
//
//  Created by Me on 11/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MysticPageControl.h"

@implementation MysticPageControl

@synthesize
numberOfPages=_numberOfPages,
currentPage=_currentPage,
padding=_padding,
insets=_insets,
pageDotSize=_pageDotSize,
hidesOnEmpty=_hidesOnEmpty,
radius=_radius,
bgColor=_bgColor,
delegate=_delegate;

- (void) dealloc;
{
    _delegate = nil;
    [_bgColor release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        self.insets = _insets;
        [self setupView];

    }
    return self;
}
- (id)initWithNumberOfPages:(NSInteger)pageCount;
{
    self = [super init];
    if (self) {
        // Initialization code
        [self commonInit];
        self.numberOfPages = pageCount;
        CGRect newFrame = CGRectZero;
        newFrame.size = [self sizeForNumberOfPages:pageCount];
        self.frame = newFrame;
        [self setupView];
    }
    return self;
}
- (void) commonInit;
{
    _hidesOnEmpty = YES;
    _currentPage = 0;
    _numberOfPages = 0;
    _padding = 7.0f;
    CGFloat _inset = 5.0f;
    CGFloat _dot = 8.0f;

    _insets = UIEdgeInsetsMake(_inset + 1.0f,  _inset + 2.0f, _inset + 1.0f, _inset + 2.0f);
    _pageDotSize = CGSizeMake(_dot, _dot);
    UIColor *highlightColor = [UIColor whiteColor];
    UIColor *normalColor = [UIColor whiteColor];

    [self setTitleColor:normalColor forState:UIControlStateSelected];
    [self setTitleColor:[normalColor colorWithAlphaComponent:0.45f] forState:UIControlStateNormal];
    [self setTitleColor:highlightColor forState:UIControlStateApplication];
    [self setTitleColor:[highlightColor colorWithAlphaComponent:0.45f] forState:UIControlStateHighlighted];


    self.opaque = NO;
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    [self reset];
}
- (void) reset;
{
    _currentPage = 0;
    [self setNeedsDisplay];
}

- (void) setupView;
{
    
//    self.layer.borderColor = [UIColor blackColor].CGColor;
//    self.layer.borderWidth = 1.0f;
//    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.radius = self.frame.size.height/2.0f;
}
- (UIColor *) bgColor;
{
    if(self.superview && [self.superview respondsToSelector:@selector(currentBackgroundColor)])
    {
        UIColor *cColor = (UIColor *)[self.superview performSelector:@selector(currentBackgroundColor)];
        return cColor ? [[cColor darker:0.5] colorWithAlphaComponent:0.9] : cColor;
    
    }
    return _bgColor;
}
- (void) setBgColor:(UIColor *)bgColor;
{
    [_bgColor release], _bgColor = nil;
    if(bgColor)
    {
        _bgColor = [bgColor retain];
    }
    [self setNeedsDisplay];
}

- (void) setRadius:(CGFloat)radius;
{
    _radius = radius;
    self.layer.cornerRadius = _radius;
}
- (UIColor *) dotColorForPage:(NSInteger)page;
{
    UIControlState dotState = UIControlStateNormal;
    if(self.isSelected || self.isHighlighted)
    {
        dotState = page == self.currentPage ? UIControlStateApplication : UIControlStateHighlighted;
    }
    else
    {
        dotState = page == self.currentPage ? UIControlStateSelected : UIControlStateNormal;
    }
    UIColor *dotColor = [self titleColorForState:dotState];
    return dotColor ? dotColor : [self titleColorForState:UIControlStateNormal];
}
- (CGSize) sizeForNumberOfPages:(NSInteger)pageCount;
{
    self.radius = (self.insets.top + self.insets.bottom + self.pageDotSize.height)/2.0f;

    pageCount = MAX(1, pageCount);
    CGSize size = CGSizeZero;
    size.height = self.pageDotSize.height + self.insets.bottom + self.insets.top;
    size.width = (self.pageDotSize.width * pageCount) + (self.padding * (pageCount -1)) + self.insets.left + self.insets.right;
    size.width = MAX(self.radius*2, size.width);
    size.height = MAX(self.radius*2, size.height);

    return size;
}
- (void) setInsets:(UIEdgeInsets)insets;
{
    _insets = insets;
//    CGFloat dotHeight = self.frame.size.height - _insets.bottom - _insets.top;
//    _pageDotSize = CGSizeMake(dotHeight, dotHeight);
    [self setNeedsDisplay];
}

- (void) setNumberOfPages:(NSInteger)numberOfPages;
{
    BOOL changed = _numberOfPages != numberOfPages;
    _numberOfPages = numberOfPages;
    
    
    if(_hidesOnEmpty && _numberOfPages < 1)
    {
//        self.hidden = YES;
        self.alpha = 0.25f;
    }
    else
    {
        self.alpha = 1.0f;
        self.hidden = NO;
    }
    
    if(changed)
    {
        CGRect newBounds = self.bounds;
        newBounds.size = [self sizeForNumberOfPages:_numberOfPages];
        CGPoint oldCenter = self.center;
        self.bounds = newBounds;
        self.center = oldCenter;
        [self setNeedsDisplay];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pageControlDidChangePageCount:count:)])
    {
        [self.delegate pageControlDidChangePageCount:self count:_numberOfPages];
    }
    
}
- (void) setPadding:(CGFloat)padding;
{
    _padding = padding;
    [self setNeedsDisplay];
}

- (void) setCurrentPage:(NSInteger)currentPage;
{
    _currentPage = currentPage;
    [self setNeedsDisplay];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pageControlDidChangePage:page:)])
    {
        [self.delegate pageControlDidChangePage:self page:_currentPage];
    }
}
- (BOOL) isSelected;
{
    return self.superview && [self.superview respondsToSelector:@selector(isSelected)] ? [(UIControl *)self.superview isSelected] : [super isSelected];
}
- (BOOL) isHighlighted;
{
    return self.superview && [self.superview respondsToSelector:@selector(isHighlighted)] ? [(UIControl *)self.superview isHighlighted] : [super isHighlighted];
}
- (NSInteger) nextPage;
{
    if(_numberOfPages == 0) return NSNotFound;
    NSInteger page = _currentPage;
    page = page + 1 > _numberOfPages-1 ? 0 : page+1;
    return page;
}

- (NSInteger) previousPage;
{
    if(_numberOfPages == 0) return NSNotFound;

    NSInteger page = _currentPage;
    page = page - 1 < 0 ? MAX(0, _numberOfPages-1) : page-1;
    return page;
}

- (NSInteger) gotoNextPage;
{
    NSInteger page = self.nextPage;
    if(page != NSNotFound)
    {
        self.currentPage = page;
    }
    return page;
}
- (NSInteger) gotoPreviousPage;
{
    NSInteger page = self.previousPage;
    if(page != NSNotFound)
    {
        self.currentPage = page;
    }
    return page;
}
- (NSInteger) gotoFirstPage;
{
    return [self gotoPage:0];
}
- (NSInteger) gotoLastPage;
{
    return [self gotoPage:self.numberOfPages-1];
}
- (NSInteger) gotoPage:(NSInteger)pageNumber;
{
    NSInteger page = pageNumber;
    
    if(page != NSNotFound)
    {
        page = page > (_numberOfPages -1) ? _numberOfPages-1 : page;
        page = MAX(0,page);
        self.currentPage = page;
    }
    return page;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.radius = rect.size.height/2.0f;
    if(self.numberOfPages < 1) return;
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
    if(self.bgColor)
    {
        CGMutablePathRef retPath = CGPathCreateMutable();
        CGRect innerRect = CGRectInset(rect, self.radius*.5, self.radius*.5);
        CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
        CGFloat outside_right = rect.origin.x + rect.size.width;
        CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
        CGFloat outside_bottom = rect.origin.y + rect.size.height;
        CGFloat inside_top = innerRect.origin.y;
        CGFloat outside_top = rect.origin.y;
        CGFloat outside_left = rect.origin.x;
        
        CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
        CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
        CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, self.radius);
        CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
        CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, self.radius);
        CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
        CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, self.radius);
        CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
        CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, self.radius);
        
        UIColor *bgColor = self.bgColor;
        [bgColor setFill];
        
        
        CGPathCloseSubpath(retPath);
        CGContextAddPath(context, retPath);
        CGContextFillPath(context);
        CGPathRelease(retPath);
        
    }
    
    if(!self.numberOfPages) return;
    
    CGFloat dotSize = self.pageDotSize.width/2;
    CGFloat innerWidth = self.numberOfPages * self.pageDotSize.width + (self.padding * (self.numberOfPages-1));
    
    
    CGPoint dotPoint = CGPointMake((rect.size.width/2 - innerWidth/2)+dotSize, rect.size.height/2);
    
//    FLog(@"page control frame", rect);
//    DLog(@"innerWidth: %2.2f  |  dotSize: %2.1f  | padding: %2.1f  |  radius: %2.1f", innerWidth, self.pageDotSize.width, self.padding, self.radius);
//    PLog(@"start dot", dotPoint);

    
    for (int p = 0; p < self.numberOfPages; p++)
    {
        [[self dotColorForPage:p] setFill];
        CGMutablePathRef dot = CGPathCreateMutable();
        CGPathMoveToPoint(dot, NULL, dotPoint.x, dotPoint.y);
        CGPathAddLineToPoint(dot, NULL, dotPoint.x + dotSize, dotPoint.y);
        CGPathAddArc(dot, NULL, dotPoint.x, dotPoint.y, dotSize, -M_PI_2, M_PI_2*4, NO);
        CGPathCloseSubpath(dot);
        CGContextAddPath(context, dot);
        CGContextFillPath(context);
        CGPathRelease(dot);
        dotPoint.x += self.padding + self.pageDotSize.width;
    }
}


@end

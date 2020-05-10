//
//  MysticLayerContentView.m
//  Mystic
//
//  Created by Me on 12/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerContentView.h"
#import "Mystic.h"

@interface MysticLayerContentView ()

@property (nonatomic, assign) BOOL layoutFrameSet, initialized, frameIsSetForTheFirstTime;
@end
@implementation MysticLayerContentView
@synthesize scale=_scale, view=_view;

- (void) dealloc;
{
    _view = nil;
    [super dealloc];
}
- (id) deepCopyOf:(MysticLayerContentView *)view;
{
    _layoutFrameSet=view.layoutFrameSet;
    _frameIsSetForTheFirstTime=view.frameIsSetForTheFirstTime;
    _initialized=view.initialized;
    _ratio=view.ratio;
    _shouldScale=view.shouldScale;
    _scale=view.scale;
    self.layoutFrame=view.layoutFrame;
    self.contentBounds=view.contentBounds;
    _transformScale=view.transformScale;
    _minimumHeight=view.minimumHeight;
    _minimumHeight=view.minimumWidth;
    _adjustsAspectRatioOnResize=view.adjustsAspectRatioOnResize;
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    _ratio = CGFLOAT_MAX;
    _initialized = NO;
    _frameIsSetForTheFirstTime = NO;
    self = [super initWithFrame:frame];
    if(self)
    {
        _layoutFrameSet = NO;
        _shouldScale = YES;
        _targetSize = frame.size;
        _minimumWidth = 0;
        _minimumHeight = 0;
        _scale = 1;
        self.adjustsAspectRatioOnResize = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        _initialized = YES;
        _frameIsSetForTheFirstTime = YES;
        _layoutView = [[UIView alloc] initWithFrame:self.shouldScale ? CGRectScale(CGRectSize(frame.size), self.scale) : CGRectSize(frame.size)];
        self.layoutFrame = _layoutView.frame;
        _layoutView.clipsToBounds = NO;
        _layoutView.layer.masksToBounds = NO;
        _transformScale = CGScaleEqual;
        [self addSubview:_layoutView];
    }
    return self;
}
- (UIView *) view; {    return _view; }
- (void) setView:(UIView *)view;
{
    if(_view) [_view removeFromSuperview];
    [self.layoutView addSubview:view];
    _view = view;

}

- (void) scale:(CGFloat)newScale;
{
    if(!self.shouldScale) return;
    [self setNeedsLayout];
}
- (void) setScale:(CGFloat)scale;
{
    _scale = scale;
    [self layoutScaledSubviews];
}

- (CGRect) contentBounds;
{
    return CGRectSize(_layoutView.bounds.size);
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    [self layoutScaledSubviews];
}
- (void) layoutScaledSubviews;
{
    if(!(self.shouldScale && !_layoutFrameSet))
    {
        _layoutView.center = CGPointCenter(self.bounds); return;
    }
    _layoutView.frame = CGRectScale(CGRectSize(super.frame.size), self.scale);
    self.layoutFrame = _layoutView.frame;
    for (UIView *s in _layoutView.subviews) s.frame = CGRectSize(_layoutView.frame.size);
    CGScale scale = CGScaleOfRects(self.frame, _layoutView.frame);
    _layoutView.transform = CGScaleTransform(_layoutView.transform, scale);
    _layoutView.center = CGPointCenter(self.bounds);
    _layoutFrameSet = YES;
}
- (void) setNewFrame:(CGRect)frame;
{
    [self setNewFrame:frame layout:CGRectZero];
}
- (void) setNewFrame:(CGRect)frame layout:(CGRect)layout;
{
    _ratio = CGRectRatio(frame);
    self.transform = CGAffineTransformIdentity;
    _frameIsSetForTheFirstTime = NO;
    self.frame = frame;
    self.center = CGPointMid(frame);
    _layoutView.transform = CGAffineTransformIdentity;
    _layoutFrameSet = NO;
    if(!CGRectIsZero(layout))
    {
        _layoutView.frame = layout;
        self.layoutFrame = layout;
        for (UIView *s in _layoutView.subviews) s.frame = CGRectSize(layout.size);
        _layoutView.transform = CGScaleTransform(_layoutView.transform, CGScaleOfRects(self.frame, layout));
        _layoutView.center = CGPointCenter(self.frame);
        _layoutFrameSet = YES;
    }
    else [self layoutScaledSubviews];
}
- (void) setFrame:(CGRect)frame;
{
    _ratio = _ratio != CGFLOAT_MAX ? _ratio : CGRectRatio(frame);
    _ratio = CGRectRatio([self adjustedBounds:frame]);
    
    if (!CGSizeEqual(frame.size, self.frame.size))
    {
        if (_initialized && _frameIsSetForTheFirstTime)
        {
            _transformScale = CGScaleMin(CGScaleOfRects(frame, CGSizeIsZero(self.frame.size) ? self.bounds : self.frame));
            self.transform = CGScaleTransform(CGSizeIsZero(self.frame.size) ? CGAffineTransformIdentity : self.transform, _transformScale);
            self.center = CGPointMid(frame);
        }
        else
        {
            super.frame = frame;
            _frameIsSetForTheFirstTime = YES;
        }
    }
    // If only the position(origin) of the frame is changing, apply that by changing center property.
    else if (!CGPointEqual(frame.origin, self.frame.origin)) self.center = CGPointMid(frame);
    [self setNeedsLayout];
}


- (CGRect) originalFrame; { return super.frame; }
- (CGSize)targetSize;
{
    return CGRectScale(CGRectApplyAffineTransform(self.bounds, self.transform), self.scale).size;
}

- (CGRect) adjustedBounds:(CGRect)newBounds;
{
    if(self.adjustsAspectRatioOnResize) return newBounds;
    if(newBounds.size.width > newBounds.size.height)
    {
        newBounds.size.height = newBounds.size.width *_ratio;
        if(_minimumHeight > 0 && newBounds.size.height < _minimumHeight)
        {
            newBounds.size.height = _minimumHeight;
            newBounds.size.width = newBounds.size.height/_ratio;
        }
    }
    else
    {
        newBounds.size.width = newBounds.size.height *_ratio;
        if(_minimumWidth > 0 && newBounds.size.width < _minimumWidth)
        {
            newBounds.size.width = _minimumWidth;
            newBounds.size.height = newBounds.size.width/_ratio;
        }
    }
    return newBounds;
}


@end

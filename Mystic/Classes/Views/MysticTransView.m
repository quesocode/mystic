//
//  MysticTransView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/15/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticTransView.h"
#import "UIView+Mystic.h"

@implementation MysticContentViewBorder

@end
@implementation MysticContentViewFill

@end
@implementation MysticTransContentView
- (void) setBounds:(CGRect)bounds;
{
    [self setBounds:bounds layoutSubviews:NO];
}
- (void) setBounds:(CGRect)bounds layoutSubviews:(BOOL)l;
{
    CGScale scale = CGScaleOfRects(self.bounds, bounds);
    CGRect _b = self.bounds;
    [super setBounds:bounds];
    for (MysticPathView *v in self.subviews) {
        if(l && [v isKindOfClass:[MysticPathView class]]) [v updatedSuperview:bounds scale:scale previous:_b];
        if(!CGPointEqual(v.center, self.center)) v.center = self.center;
    }
}
@end
@implementation MysticContentViewMask

@end
@interface MysticTransView ()
{
    CGRect _previousFrame;
}
@end
@implementation MysticTransView

@synthesize drawView=_drawView, contentView=_contentView, imageView=_imageView, fillView=_fillView, borderView=_borderView;
- (void) dealloc;
{
    [super dealloc];
    _imageView = nil;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _previousFrame = frame;
        self.clipsToBounds = NO;
        self.opaque = NO;
        self.layer.masksToBounds = NO;
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        _shouldUpdateContent = NO;
    }
    return self;
}
- (void) resetContent;
{
    if(_imageView) { [_imageView removeFromSuperview]; _imageView = nil; }
    if(_fillView) { [_fillView removeFromSuperview]; _fillView = nil; }
    if(_borderView) { [_borderView removeFromSuperview]; _borderView = nil; }
    if(_contentView) { [_contentView removeFromSuperview]; _contentView = nil; }
    if(_drawView) { [_drawView removeFromSuperview]; _drawView = nil; }
}
- (UIView *) view;
{
    if(_contentView) return _contentView;
    if(_drawView) return _drawView;
    if(_imageView) return _imageView;
    return nil;
}
- (UIImageView *) imageView;
{
    if(!_imageView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectz(self.bounds)];
        [self addSubview:imageView];
        _imageView = [imageView autorelease];
        _imageView.clipsToBounds = self.clipsToBounds;
        _imageView.layer.masksToBounds = self.layer.masksToBounds;
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}
- (MysticContentViewFill *) fillView;
{
    if(!_fillView)
    {
        MysticContentViewFill *view = [[MysticContentViewFill alloc] initWithFrame:CGRectz(self.contentView.bounds)];
        [self.contentView addSubview:view];
        _fillView = [view autorelease];
        _fillView.tag = MysticViewTypeFill;
        _fillView.clipsToBounds = self.clipsToBounds;
        _fillView.layer.masksToBounds = self.layer.masksToBounds;
    }
    return _fillView;
}
- (MysticContentViewBorder *) borderView;
{
    if(!_borderView)
    {
        MysticContentViewBorder *view = [[MysticContentViewBorder alloc] initWithFrame:CGRectz(self.contentView.bounds)];
        [self.contentView addSubview:view];
        _borderView = [view autorelease];
        _borderView.tag = MysticViewTypeBorder;
        _borderView.clipsToBounds = self.clipsToBounds;
        _borderView.layer.masksToBounds = self.layer.masksToBounds;
    }
    return _borderView;
}
- (MysticTransContentView *) contentView;
{
    if(!_contentView)
    {
        MysticTransContentView *view = [[MysticTransContentView alloc] initWithFrame:CGRectz(self.bounds)];
        [self addSubview:view];
        _contentView = [view autorelease];
        _contentView.clipsToBounds = self.clipsToBounds;
        _contentView.layer.masksToBounds = self.layer.masksToBounds;
        _contentView.autoresizesSubviews = NO;
        _contentView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentView;
}
- (MysticDrawView *) drawView;
{
    if(!_drawView)
    {
        MysticDrawView *view = [[MysticDrawView alloc] initWithFrame:CGRectz(self.bounds)];
        [self addSubview:view];
        _drawView = [view autorelease];
        _drawView.clipsToBounds = self.clipsToBounds;
        _drawView.layer.masksToBounds = self.layer.masksToBounds;
    }
    return _drawView;
}
- (void) setDrawView:(MysticDrawView *)drawView;
{
    if(!drawView && _drawView) [_drawView removeFromSuperview];
    _drawView = drawView;
}
- (void) setContentView:(MysticTransContentView *)view;
{
    if(!view && _contentView) [_contentView removeFromSuperview];
    _contentView = view;
}
- (void) setFillView:(MysticContentViewFill *)view;
{
    if(!view && _fillView) [_fillView removeFromSuperview];
    _fillView = view;
}
- (void) setBorderView:(MysticContentViewBorder *)view;
{
    if(!view && _borderView) [_borderView removeFromSuperview];
    _borderView = view;
}
- (void) setImageView:(UIImageView *)view;
{
    if(!view && _imageView) [_imageView removeFromSuperview];
    _imageView = view;
}
- (BOOL) hasContentView; {return _contentView != nil;}
- (BOOL) hasDrawView; {return _drawView != nil;}
- (BOOL) hasImageView; {return _imageView != nil;}
- (BOOL) hasFillView; {return _fillView != nil && _fillView.superview; }
- (BOOL) hasBorderView; {return _borderView != nil && _borderView.superview; }
- (void) setNeedsDisplay;
{
    if(_drawView && !_drawView.choice.drawEffectsOnViewLayer && _drawView.choice.hasBorder)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.drawView.drawBlock = nil;
            self.drawView.choice = self.drawView.choice;
            [self.drawView setNeedsDisplay];
        });
    }
    [super setNeedsDisplay];

}
- (CGRect) innerFrame;
{
    return self.hasFillView ? self.fillView.frame : self.frame;

}
- (void) setNewFrame:(CGRect)frame;
{
    _previousFrame = [super frame];
    [super setFrame:frame];
    if(!CGRectSizeEqual(frame, _previousFrame)) { [self updateLayout:YES]; }
}
- (void) setFrame:(CGRect)frame;
{
    _previousFrame = [super frame];
    [super setFrame:frame];
    [self updateLayout:YES];
}
- (void) updateLayout; { [self updateLayout:NO]; }
- (void) updateLayout:(BOOL)up;
{
    NSString *v1 = VLLogStr(self);
    up = up || self.shouldUpdateContent;
    CGRect newBounds = self.bounds;
    for (UIView *subview in self.subviews)
    {
        if(_drawView && [subview isEqual:_drawView]) continue;
        subview.center = CGPointCenter(self.bounds);
        if(up && [subview respondsToSelector:@selector(setBounds:layoutSubviews:)])
        {
            [(MysticTransContentView *)subview setBounds:newBounds layoutSubviews:up];
        }
        else subview.bounds = newBounds;
    }
    if(self.shouldUpdateContent) self.shouldUpdateContent = NO;
}


@end

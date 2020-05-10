//
//  MysticDrawLayerView.m
//  Mystic
//
//  Created by Me on 12/15/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDrawLayerView.h"
#import "MysticLayerBaseView.h"

@implementation MysticDrawLayerView
+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)context scale:(CGFloat)scale;
{
    return CGRectSize(targetSize);
}
- (void) dealloc;
{
    [_actualContext release], _actualContext=nil;
    [_maskImage release], _maskImage=nil;
    [_contextSizeContext release], _contextSizeContext=nil;
    [_strokeColor release], _strokeColor=nil;
    Block_release(_drawBlock);
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [super setBackgroundColor:[UIColor clearColor]];
        self.opaque = NO;
        self.minimumScaleFactor = 1;
        _backgroundRect = CGRectZero;
        _drawRect = CGRectInfinite;
        _renderRect = CGRectZero;
        _maskRect = CGRectZero;
        _scale = 0;
        _alignPosition = MysticPositionUnknown;
        _contentSizeOptions = MysticSizeOptionMatchGreatest;
        _shouldDrawAntiAlias = YES;
//        self.layer.rasterizationScale = 4.0 * [UIScreen mainScreen].scale;
//        self.layer.shouldRasterize = YES;
        self.layer.masksToBounds = NO;
        self.clipsToBounds = NO;
    }
    return self;
}

- (CGRect) maxBounds;
{
    return self.layerView ? self.layerView.maxBounds : (self.superview ? self.superview.bounds : self.bounds);
}
- (UIImage *) contentImage:(CGSize)imageSize;
{
    return nil;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (CGFloat) scale;
{
    return self.layerView ? self.layerView.contentView.scale : _scale;
}
- (CGRect) maskRect;
{
    CGRect maskRect = CGRectIsZero(_maskRect) ? CGRectSize(self.maskImage.size) : _maskRect;
    return CGRectScale(maskRect, self.scale);
}
- (CGRect) backgroundRect;
{
    CGRect r = CGRectIsZero(self.backgroundRect) ? self.drawRect : self.backgroundRect;
    return CGRectScale(r, self.scale);
}
- (CGRect) drawRectScaled;
{
    return CGRectScale(self.drawRect, self.scale);
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(!self.layerView.shouldRedraw) return;
    CGSize finalSize = CGSizeZero;
    MysticDrawingContext *c = self.contextSizeContext;
    finalSize = !CGSizeIsZero(c.totalSize) ? c.totalSize : finalSize;
    self.drawRect = CGSizeIsZero(finalSize) ? rect : CGRectSize(finalSize);
    
    self.rect = rect;
    CGRect finalRect = CGRectIsInfinite(self.drawRect) ? self.rect : self.drawRect;
    finalRect = MysticPositionRect(finalRect, CGRectScale(self.bounds, self.scale/2), self.alignPosition);
    self.drawRect = finalRect;
    [self drawWithRect:self.drawRect];
    [self endDraw:self.drawRect];
    
}
- (void) drawWithRect:(CGRect)rect;
{
    [self drawWithRect:rect bounds:CGRectScale(self.bounds, self.scale/2)];
}

- (void) drawWithRect:(CGRect)rect bounds:(CGRect)bounds;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(self.shouldDrawAntiAlias)
    {
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
    }
    if(self.maskImage)
    {
        CGRect maskRect = self.maskRect;
        maskRect = MysticPositionRect(maskRect, bounds, self.alignPosition);

        CGContextClipToMask(context, maskRect ,self.maskImage.CGImage);
    }
    
    if(![self.backgroundColor isEqualToColor:[UIColor clearColor]])
    {
        [self.backgroundColor setFill];
        
        CGRect bgRect = self.backgroundRect;
        bgRect = MysticPositionRect(bgRect, bounds, self.alignPosition);
        CGContextFillRect(context, bgRect);
    }

    self.contextSizeContext.adjustContentSizeToFit = YES;

    
}
- (void) endDraw:(CGRect)rect;
{
    if(self.layerView)
    {
        [self.layerView endDraw:rect];
    }
}
- (MysticDrawingContext *) contextSizeContext;
{
    return [self contextSizeContext:self.bounds];
}
- (MysticDrawingContext *) contextSizeContext:(CGRect)rect;
{
    if(!_contextSizeContext) [self contentSizeThatFits:rect];
    return _contextSizeContext;
}
- (CGSize) contentSizeThatFits:(CGRect)rect;
{
    MysticDrawingContext *c = [[MysticDrawingContext alloc] init];
    c.totalSize = rect.size;
    c.bounds = rect;
    self.contextSizeContext = [c autorelease];
    return rect.size;
}


@end

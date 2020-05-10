//
//  MysticDrawPathView.m
//  Mystic
//
//  Created by Travis A. Weerts on 11/21/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticDrawPathView.h"
#import "MysticColor.h"
#import "BezierUtils.h"
#import "MysticTypedefs.h"
#import "UIBezierPath+Elements.h"

@implementation MysticDrawPathView
@synthesize fillLayer=_fillLayer, borderLayer=_borderLayer, pathFrame=_pathFrame;
- (void) deepCopyOf:(MysticDrawPathView *)view;
{
    self.pathLayer.path = [[UIBezierPath bezierPathWithCGPath:view.pathLayer.path] safeCopy].CGPath;
    self.pathLayer.frame = view.pathLayer.frame;
    self.pathLayer.transform = view.pathLayer.transform;
    self.pathLayer.lineWidth=view.pathLayer.lineWidth;
    self.pathLayer.lineCap=view.pathLayer.lineCap;
    self.pathLayer.lineDashPattern=view.pathLayer.lineDashPattern;
    self.pathLayer.lineDashPhase=view.pathLayer.lineDashPhase;
    self.pathLayer.lineJoin=view.pathLayer.lineJoin;
    self.pathFrame = view.pathFrame;
    self.pathInfo.path = [UIBezierPath bezierPathWithCGPath:self.pathLayer.path];
    if(self.maskLayer)
    {
        self.maskLayer.path = [[UIBezierPath bezierPathWithCGPath:view.maskLayer.path] safeCopy].CGPath;
        self.maskLayer.frame = view.maskLayer.frame;
        self.maskLayer.transform = view.maskLayer.transform;
    }
    
}
- (void) dealloc;
{
    [_pathInfo release];
    [super dealloc];
}
- (instancetype) init;
{
    self = [super init];
    if(self)
    {
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
    }
    return self;
}
- (Class) pathLayerClass; { return [[self class] layerClass]; }
+ (Class) layerClass; { return [MysticPathLayer class]; }
- (MysticPathLayer *) pathLayer; {    return (id)self.layer; }

- (id) showDebug:(id)fillColor border:(id)borderColor;
{
    id view = nil;
    
    return view;
}
- (MysticPathView *) showDebugMask:(id)fillColor;
{
    return [self showDebugMask:fillColor border:fillColor];
}
- (MysticPathView *) showDebugMask:(id)fillColor border:(id)borderColor;
{
    MysticPathView *view = nil;
    id _fillColor = fillColor ? fillColor : !borderColor ? [UIColor redColor] : nil;
    id _borderColor = borderColor ? borderColor : !fillColor ? [UIColor redColor] : nil;
    
    if(self.maskLayer)
    {
        if([NSStringFromClass([self class]) containsString:@"Border"])
        {
            view = (id)[[MysticPathBorderDebug alloc] initWithFrame:self.frame];
            view.tag = MysticViewTypeDebugBorder;
        }
        else
        {
            view = (id)[[MysticPathFillDebug alloc] initWithFrame:self.frame];
            view.tag = MysticViewTypeDebug;
        }
    }
    if(view && self.maskLayer)
    {
        view.pathLayer.path = [UIBezierPath bezierPathWithCGPath:self.maskLayer.path].CGPath;
        view.pathLayer.frame = self.maskLayer.frame;
        if(_fillColor) view.pathLayer.fillColor = [[MysticColor color:_fillColor] alpha:0.3].CGColor;
        if(_borderColor)
        {
            view.pathLayer.strokeColor = [MysticColor color:_borderColor].CGColor;
            view.pathLayer.lineWidth = 1;
        }
    }
    if(view && self.superview)
    {
        UIView *v = [self.superview viewWithTag:MysticViewTypeDebugBorder];
        if(v) [v removeFromSuperview];
        [self.superview addSubview:view];
    }
    return view;
}

- (MysticPathLayer *) pathInfo:(MysticPath *)pathInfo;
{
    if(!self.pathLayer) self.pathLayer = [[self pathLayerClass] layer];
    if(!self.pathLayer.path) self.color = nil;
    self.pathInfo = pathInfo;
    self.pathLayer.path = self.pathInfo.path.CGPath;
    self.pathLayer.frame = self.pathInfo.frame;
    return self.pathLayer;
}

- (UIBezierPath *) path;
{
    return self.pathInfo && self.pathInfo.path ? self.pathInfo.path : !self.pathLayer.path ? nil : [UIBezierPath bezierPathWithCGPath:self.pathLayer.path];
}
- (CGRect) pathFrame;
{
    return self.pathInfo && !CGRectUnknownOrZero(self.pathInfo.frame) ? self.pathInfo.frame : self.pathLayer ? self.pathLayer.frame : CGRectUnknown;
}
- (void) setPathFrame:(CGRect)pathFrame;
{
    self.pathInfo.frame = pathFrame;
}
- (void) setPath:(UIBezierPath *)path;
{
    self.pathInfo.path = path;
    self.pathLayer.path = path ? path.CGPath : nil;
}
- (void) setColor:(id)color;
{
    self.pathLayer.fillColor = !color ? [UIColor white].CGColor : [MysticColor color:color].CGColor;
}
- (void) updatedSuperview:(CGRect)bounds scale:(CGScale)scale previous:(CGRect)oldBounds;
{
    CGRect frame = CGRectFit(self.frame, bounds);
    CGRect pathFrame = CGRectz(frame);
    CGRect currentFrame = self.frame;
    if(self.path)
    {
        self.path = SetPathRect(self.path, pathFrame);
        self.pathFrame = pathFrame;
        self.pathLayer.frame = pathFrame;
    }
    if(self.maskLayer)
    {
        self.maskLayer.frame = CGRectCenterAround(CGRectScaleWithScale(self.maskLayer.frame, scale), pathFrame);
        CGRect newMaskBounds = CGRectz(self.maskLayer.frame);
        CGRect pathFrameCentered = CGRectCenter(pathFrame,newMaskBounds);
        UIBezierPath *maskPath = [self.path inverseInRect:pathFrameCentered  bounds:newMaskBounds];
        if(!(CGRectIsNaN(newMaskBounds) || CGRectIsNaN(pathFrameCentered) || CGRectIsNaN(PathBoundingBox(maskPath))))
        {
            self.maskLayer.path = maskPath.CGPath;
        }
    }
    [super setFrame:frame];
}

- (void) updateFrame:(CGRect)frame;
{
    if(self.path)
    {
        self.path = SetPathRect(self.path, CGRectz(frame));
        self.pathFrame = CGRectz(frame);
        self.pathLayer.frame = self.pathFrame;
    }
    
    [super setFrame:frame];
}


- (MysticMaskLayer *)maskLayer; {    return (id)self.layer.mask; }
- (void) setMaskLayer:(CALayer *)layer; { self.layer.mask = layer; }
- (MysticBorderLayer *)borderLayer; {   return (id)self.layer; }
- (MysticFillLayer *)fillLayer; { return (id)self.layer; }

@end

@implementation MysticDrawPathFillView
+ (Class) layerClass; { return [MysticFillLayer class]; }

- (MysticPathLayer *) pathLayer;
{
    return self.fillLayer;
}

@end


@implementation MysticDrawPathBorderView
+ (Class) layerClass; { return [MysticBorderLayer class]; }
- (MysticPathLayer *) pathLayer;
{
    return self.borderLayer;
}

@end

@implementation MysticPathBorderDebug


@end

@implementation MysticPathFillDebug



@end



@implementation MysticPathLayer
+ (id) layer;
{
    CAShapeLayer *layer = [super layer];
    layer.masksToBounds = NO;
    return (id)layer;
}
- (UIBezierPath *) bezierPath;
{
    return [UIBezierPath bezierPathWithCGPath:self.path];
}
- (CGRect) pathBounds;
{
    if(self.lineWidth > 0)
    {
        NSString *lm = kCGLineJoinMiter;
        if([self.lineJoin equals:kCALineJoinBevel]) lm = kCGLineJoinBevel;
        else if([self.lineJoin equals:kCALineJoinRound]) lm = kCGLineJoinRound;
        
        NSString *lc = kCGLineCapButt;
        if([self.lineJoin equals:kCALineCapRound]) lm = kCGLineCapRound;
        else if([self.lineJoin equals:kCALineCapSquare]) lm = kCGLineCapSquare;
        return PathBoundingBox([UIBezierPath bezierPathWithCGPath:CGPathCreateCopyByStrokingPath(self.path, NULL, self.lineWidth, lc, lm, self.miterLimit)]);
    }
    return PathBoundingBox(self.bezierPath);
}
@end

@implementation MysticBorderLayer
- (NSString *) name; { return @"border"; }
@end

@implementation MysticMaskLayer
- (NSString *) name; { return @"mask"; }
- (CGFloat) lineWidth; { return 0; }
@end

@implementation MysticFillLayer
- (NSString *) name; { return @"fill"; }
@end

@implementation CALayer (Mystic)
- (id) layerWithName:(NSString *)name;
{
    for (CALayer *sublayer in self.sublayers)  if([sublayer.name isEqualToString:name]) return sublayer;
    return nil;
}
@end

@implementation MysticPathView




@end

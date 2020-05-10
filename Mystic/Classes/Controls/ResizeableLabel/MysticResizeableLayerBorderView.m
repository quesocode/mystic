//
//  MysticResizeableLabelBorderView.m
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import "MysticResizeableLayerBorderView.h"
#import "MysticConstants.h"
#import "UIColor+Mystic.h"



@implementation MysticResizeableLayerBorderView




- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        _handlesHidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [UIColor color:MysticColorTypeOrange];
        self.dashed = NO;
        _handlePostions = MysticPositionRight|MysticPositionLeft|MysticPositionBottom;
        self.handleSlitColor = [UIColor color:MysticColorTypeBlack];
        self.borderWidth = MYSTIC_UI_LAYER_BORDER;
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        _handleScale = 1;
    }
    return self;
}
- (CGRect) innerRect;
{
    CGFloat i = self.borderWidth + ((kMysticShortSide + kMysticHandleBorderWidth)/2);
    return CGRectIntegral(CGRectInset(self.bounds, i, i));
}
- (void) setHandlesHidden:(BOOL)v;
{
    BOOL c = v != _handlesHidden;
    _handlesHidden = v;
    if(c) [self setNeedsDisplay];
}
- (void) setHandlePostions:(MysticPosition)v;
{
    if(_handlePostions == MysticPositionUnknown) { self.handlesHidden = YES; return; }
    BOOL c = v != _handlePostions;
    _handlePostions = v;
    if(c) [self setNeedsDisplay];
}
- (void) setHandleScale:(CGFloat)handleScale;
{
    _handleScale = handleScale;
    [self setNeedsDisplay];
}
- (void) setBorderColor:(UIColor *)newColor;
{
    BOOL c = newColor != _borderColor;
    _borderColor = newColor;
    if(c) [self setNeedsDisplay];
}
- (void) setDashed:(BOOL)value
{
    BOOL c = value != _dashed;
    _dashed = value;
    if(c) [self setNeedsDisplay];
}
- (void) setBorderWidth:(CGFloat)value
{
    BOOL c = value != _borderWidth;
    _borderWidth = value;
    if(c) [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
//
//    [[[UIColor blackColor] colorWithAlphaComponent:0.6] setFill];
//    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);
    CGContextSetShouldAntialias(context, YES);
    if(self.dashed)
    {
        CGFloat dashes[] = {2,2};
    
        CGContextSetLineDash(context, 0.0, dashes, 2);
    }
    
    
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGFloat longSide = kMysticLongSide * _handleScale;
    CGFloat tallSide = kMysticTallSide * _handleScale;
    CGFloat shortSide = kMysticShortSide* _handleScale;
    CGFloat hRadius = kMysticHandleRadius* _handleScale;
    CGFloat hBorderWidth = kMysticHandleBorderWidth* _handleScale;
    CGFloat controlSize = kMYSTICLAYERControlIconSize * _handleScale;
    
    CGFloat i = self.borderWidth + ((shortSide + hBorderWidth)/2);
	CGRect innerRect = CGRectIntegral(CGRectInset(rect, i, i));
    
    CGRect rrect = CGRectMake(innerRect.origin.x, innerRect.origin.y, innerRect.size.width, innerRect.size.height);
    CGFloat radius = 7.0;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    
    
    
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);

    if(!_handlesHidden)
    {

        CGRect topRect = CGRectMake(innerRect.origin.x + (innerRect.size.width/2) - longSide/2,
                                    innerRect.origin.y - shortSide/2,
                                    longSide, shortSide);
        CGRect btmRect = CGRectMake(innerRect.origin.x + (innerRect.size.width/2) - longSide/2,
                                    innerRect.origin.y + innerRect.size.height  - shortSide/2,
                                    longSide, shortSide);
        CGRect leftRect = CGRectMake(innerRect.origin.x -shortSide/2,
                                     innerRect.origin.y + (innerRect.size.height/2) - tallSide/2,
                                     shortSide, tallSide);
        CGRect rightRect = CGRectMake(innerRect.origin.x + innerRect.size.width - shortSide/2,
                                      innerRect.origin.y + (innerRect.size.height/2) - tallSide/2,
                                      shortSide, tallSide);

        topRect.origin.x -= hBorderWidth/2;
        topRect.origin.y -= shortSide/2;
        topRect.size.width = longSide;
        topRect.size.height = shortSide;
        
        btmRect.origin.x -= hBorderWidth/2;
        btmRect.origin.y += shortSide/2;
        btmRect.size.width = longSide;
        btmRect.size.height = shortSide;

        
        leftRect.origin.y -= hBorderWidth/2;
        leftRect.origin.x -= shortSide/2;
        leftRect.size.width = shortSide;
        leftRect.size.height = tallSide;
        
        rightRect.origin.y -= hBorderWidth/2;
        rightRect.origin.x += shortSide/2;
        rightRect.size.height = tallSide;
        rightRect.size.width = shortSide;
        
        CGFloat dc = innerRect.origin.y + innerRect.size.height - radius;
        CGFloat dh = controlSize*2 + leftRect.size.height;
        
        CGFloat rc = innerRect.origin.y + radius;
        CGFloat rh = (innerRect.origin.y + innerRect.size.height) - controlSize*2;
        
        leftRect.origin.y = MAX(dc < dh ? dc - leftRect.size.height : controlSize*2, leftRect.origin.y);
        rightRect.origin.y = MIN(rc > rh ? rc : rh, rightRect.origin.y);
        
        topRect.origin.x = MAX(topRect.origin.x, controlSize*2);
        btmRect.origin.x = MIN(btmRect.origin.x, (innerRect.origin.x + innerRect.size.width) - controlSize*2);

        
        if(self.handlePostions & MysticPositionTop) [self drawRoundedRect:context rect:topRect borderWidth:hBorderWidth radius:hRadius stroke:self.borderColor fill:self.handleSlitColor];
        if(self.handlePostions & MysticPositionBottom) [self drawRoundedRect:context rect:btmRect borderWidth:hBorderWidth radius:hRadius stroke:self.borderColor fill:self.handleSlitColor];
        if(self.handlePostions & MysticPositionLeft) [self drawRoundedRect:context rect:leftRect borderWidth:hBorderWidth radius:hRadius stroke:self.borderColor fill:self.handleSlitColor];
        if(self.handlePostions & MysticPositionRight) [self drawRoundedRect:context rect:rightRect borderWidth:hBorderWidth radius:hRadius stroke:self.borderColor fill:self.handleSlitColor];

    }
}


- (void) drawRoundedRect:(CGContextRef)context rect:(CGRect)rect borderWidth:(CGFloat)width radius:(CGFloat)radius stroke:(UIColor *)stroke fill:(UIColor *)fill;
{
    CGContextSaveGState(context);
    CGContextSetShouldAntialias(context, YES);

    
    
    if(stroke)
    {
        CGContextSetLineWidth(context, width);
        CGContextSetStrokeColorWithColor(context, stroke.CGColor);
    }
    if(fill)
    {
        CGContextSetFillColorWithColor(context, fill.CGColor);
    }
    
    CGRect innerRect = rect;
    
    CGRect rrect = CGRectMake(innerRect.origin.x, innerRect.origin.y, innerRect.size.width, innerRect.size.height);
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    
    if(fill && stroke)
    {
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    if(stroke) CGContextStrokePath(context);

    if(fill) CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

@end

@implementation MysticResizeableLabelBorderView



@end

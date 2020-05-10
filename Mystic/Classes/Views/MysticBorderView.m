//
//  MysticBorderView.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"
#import <QuartzCore/QuartzCore.h>

@interface MysticBorderView ()

@property (nonatomic, retain) NSMutableDictionary *borderOffsetPoints;

@end
@implementation MysticBorderView


@synthesize showBorder=_showBorder, borderPosition=_borderPosition, borderColor=_borderColor, borderWidth=_borderWidth, dashed=_dashed, dashSize=_dashSize, drawBorderIntegral=_drawBorderIntegral, borderOffset=_borderOffset, borderOffsetPoints=_borderOffsetPoints;

+ (CGFloat) borderWidth;
{
    return 1;
}
- (void) dealloc;
{
    
    [super dealloc];
    [_borderColor release];
    [_borderOffsetPoints release];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
        
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    [super commonInit];
    _drawBorderIntegral = YES;
    _showBorder = YES;
    _borderAnchorPosition = MysticPositionUnknown;
    _dashed = NO;
    _borderOffset = CGPointUnknown;
    _borderInsets = UIEdgeInsetsZero;
    _contentInsets = UIEdgeInsetsZero;
    self.borderOffsetPoints = [NSMutableDictionary dictionary];
    _dashSize = CGSizeMake(1, 2);
    _borderWidth = [[self class] borderWidth];
    _borderPosition = MysticPositionUnknown;
    if(_borderColor) [_borderColor release], _borderColor=nil;
    _borderColor = [[UIColor color:MysticColorTypeLayerPanelBottomBarBorder] retain];
    self.clearsContextBeforeDrawing = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
}
- (void) setBorderColor:(UIColor *)value;
{
    if(_borderColor)
    {
        [_borderColor release], _borderColor=nil;
    }
    _borderColor = [value retain];
    [self setNeedsDisplay];
}
- (void) setBorderInsets:(UIEdgeInsets)borderInsets;
{
    _borderInsets = borderInsets;
    [self setNeedsDisplay];
}
- (void) setBorderWidth:(CGFloat)value;
{
    _borderWidth = value;
    [self setNeedsDisplay];
}
- (void) setShowBorder:(BOOL)showBorder;
{
    BOOL changed = showBorder != _showBorder;
    _showBorder = showBorder;
    if(changed) [self setNeedsDisplay];
}

- (void) setBorderOffset:(CGPoint)value;
{
    BOOL changed = !CGPointEqualToPoint(value, _borderOffset);
    _borderOffset = value;
    
    if(changed) [self setNeedsDisplay];
}

- (void) setDashed:(BOOL)dashed;
{
    _dashed = dashed;
    [self setNeedsDisplay];
}
- (void) setDashSize:(CGSize)dashSize;
{
    _dashSize = dashSize;
    [self setNeedsDisplay];
}
- (void) setNumberOfDivisions:(int)numberOfDivisions;
{
    _numberOfDivisions = numberOfDivisions;
    if(numberOfDivisions > 1 && self.borderPosition == MysticPositionUnknown) self.borderPosition = self.frame.size.width != [MysticUI screen].width ? MysticPositionHorizontalDivisions : MysticPositionVerticalDivisions;

}
- (void) setBorderAnchorPosition:(MysticPosition)borderAnchorPosition;
{
    _borderAnchorPosition = borderAnchorPosition;
    switch (_borderAnchorPosition) {
        case MysticPositionBottom:
            self.contentMode = UIViewContentModeBottom;
            break;
        case MysticPositionCenter:
            self.contentMode = UIViewContentModeCenter;
            break;
        case MysticPositionTop:
            self.contentMode = UIViewContentModeTop;
            break;
        case MysticPositionLeft:
            self.contentMode = UIViewContentModeLeft;
            break;
        case MysticPositionRight:
            self.contentMode = UIViewContentModeRight;
            break;
        case MysticPositionBottomLeft:
            self.contentMode = UIViewContentModeBottomLeft;
            break;
        case MysticPositionBottomRight:
            self.contentMode = UIViewContentModeBottomRight;
            break;
        case MysticPositionTopLeft:
            self.contentMode = UIViewContentModeTopLeft;
            break;
        case MysticPositionTopRight:
            self.contentMode = UIViewContentModeTopRight;
            break;
            
        default: break;
    }
}
- (CGPoint) contentCenter;
{
    return CGPointMake(self.center.x + self.contentInsets.left, self.center.y + self.contentInsets.top);
}
- (CGRect) contentBounds;
{
    return UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
}

- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    [self setNeedsDisplay];
}

- (void) addSubview:(UIView *)view;
{
    CGRect vf = view.frame;
    vf.origin.y = vf.origin.y == 0 ? self.contentInsets.top : vf.origin.y;
    [super addSubview:view];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect borderRect;
    
    if(self.backgroundColor.alpha > 0)
    {
        [self.backgroundColor setFill];
        CGContextFillRect(context, rect);
        
    }
    
    
    
    if(_showBorder)
    {
        CGPoint __borderOffset = CGPointEqualToPoint(self.borderOffset, CGPointUnknown) ? CGPointZero : self.borderOffset;
        if(self.dashed)
        {
            CGFloat dashes[] = {self.dashSize.width,self.dashSize.height};
            CGContextSetLineDash(context, 0.0, dashes, 2);
        }
        
        
        
        CGContextSetLineWidth(context, self.borderWidth);
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        
        
        [self.borderColor setFill];
        
        CGFloat sx = 0;
        CGFloat sx2 = 0;
        
        CGFloat sy = 0;
        CGFloat syb = 0;
        
        CGFloat ih = self.borderInsets.top + self.borderInsets.bottom;
        CGFloat iw = self.borderInsets.left + self.borderInsets.right;
        
        if(self.borderPosition & MysticPositionLeft)
        {
            CGContextMoveToPoint(context, self.borderInsets.left+ __borderOffset.x, self.borderInsets.top+ __borderOffset.y);
            CGContextAddLineToPoint(context, self.borderInsets.left+ __borderOffset.x, rect.size.height -ih+ __borderOffset.y);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
            sx = self.borderWidth;
            
        }
        
        if(self.borderPosition & MysticPositionRight)
        {
            borderRect = CGRectMake(rect.size.width - self.borderWidth - self.borderInsets.right+ __borderOffset.x, self.borderInsets.top+ __borderOffset.y, self.borderWidth, rect.size.height - ih);
            
            CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
            CGContextAddLineToPoint(context, borderRect.origin.x, borderRect.size.height);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
            sx2 = self.borderWidth;
            
        }
        
        
        if(self.borderPosition & MysticPositionVerticalDivisions)
        {
            CGFloat div = (rect.size.height - ih)/self.numberOfDivisions;
            
            borderRect = CGRectMake(self.borderInsets.left+ __borderOffset.x , self.borderInsets.top+ __borderOffset.y + div, rect.size.width - iw - __borderOffset.x - __borderOffset.x, rect.size.height - self.borderInsets.bottom - __borderOffset.y);
            
            for (int d = 0; d < self.numberOfDivisions-1; d++) {
                CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
                CGContextAddLineToPoint(context, borderRect.size.width, borderRect.origin.y);
                CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
                CGContextStrokePath(context);
                borderRect.origin.y += div;
            }
            
            
        }
        
        
        
        if(self.borderPosition & MysticPositionCenterVertical)
        {
            borderRect = CGRectMake((rect.size.width/2) - (self.borderWidth*.5)+ __borderOffset.x, self.borderInsets.top+ __borderOffset.y, self.borderWidth, rect.size.height - ih);
            
            
            
            
            CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
            CGContextAddLineToPoint(context, borderRect.origin.x, borderRect.size.height);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
            
            sx2 = self.borderWidth;
            
        }
        
        if(self.borderPosition & MysticPositionCenter)
        {
            
            borderRect = CGRectMake(sx + self.borderInsets.left+ __borderOffset.x, (rect.size.height/2) - self.borderWidth + __borderOffset.y, rect.size.width  - sx2 - iw, self.borderWidth);
            
            
            CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
            CGContextAddLineToPoint(context, borderRect.size.width, borderRect.origin.y);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
        }
        if(self.borderPosition & MysticPositionTop)
        {
            borderRect = CGRectMake(sx + self.borderInsets.left+ __borderOffset.x, self.borderInsets.top+ __borderOffset.y, rect.size.width - sx2 - iw, self.borderWidth);
            
            CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
            CGContextAddLineToPoint(context, borderRect.size.width, borderRect.origin.y);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
            
        }
        if(self.borderPosition & MysticPositionBottom)
        {
            borderRect = CGRectMake(sx + self.borderInsets.left+ __borderOffset.x, rect.size.height - self.borderWidth - self.borderInsets.bottom+ __borderOffset.y, rect.size.width - sx2 - iw, self.borderWidth);
            
            CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
            CGContextAddLineToPoint(context, borderRect.size.width, borderRect.origin.y);
            CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
        }
        
        
    }
}

@end

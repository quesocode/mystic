//
//  MysticBottomLipView.m
//  Mystic
//
//  Created by travis weerts on 6/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBottomLipView.h"
#import "UIColor+Mystic.h"

@implementation MysticBottomLipView
@synthesize borderStyle, rightOffset=_rightOffset, leftOffset=_leftOffset, radius=_radius, underneathColor=_underneathColor, leftBackgroundColor=_leftBackgroundColor, rightBackgroundColor=_rightBackgroundColor, leftBgOffset=_leftBgOffset, rightBgOffset=_rightBgOffset, showLip=_showLip;

- (void) dealloc;
{
    [_rightBackgroundColor release];
    [_leftBackgroundColor release];
    [_underneathColor release];
    
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        borderStyle = MysticBorderStyleNone;
        _rightOffset = 0.0f;
        _leftOffset = 0.0f;
        _radius = MYSTIC_UI_CORNER_RADIUS;
        _leftBgOffset = 0;
        _rightBgOffset = 0;
        _showLip = YES;
        self.backgroundColor = [UIColor mysticWhiteBackgroundColor];
        self.underneathColor = [UIColor mysticGrayBackgroundColor];
        [_leftBackgroundColor release];
        [_rightBackgroundColor release];
        _leftBackgroundColor = nil;
        _rightBackgroundColor = nil;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        borderStyle = MysticBorderStyleNone;
        _rightOffset = 0.0f;
        _leftOffset = 0.0f;
        _radius = MYSTIC_UI_CORNER_RADIUS;
        _leftBgOffset = 0;
        _rightBgOffset = 0;
        _showLip = YES;
        self.backgroundColor = [UIColor mysticWhiteBackgroundColor];
        self.underneathColor = [UIColor mysticGrayBackgroundColor];
        [_leftBackgroundColor release];
        [_rightBackgroundColor release];
        _leftBackgroundColor = nil;
        _rightBackgroundColor = nil;
    }
    return self;
}
- (void) reset;
{
    self.underneathColor = [UIColor mysticGrayBackgroundColor];

    self.backgroundColor = [UIColor mysticWhiteBackgroundColor];
    self.leftBackgroundColor = nil;
    self.rightBackgroundColor = nil;
    self.leftBgOffset = 0;
    self.rightBgOffset = 0;
}
- (void) setBackgroundColor:(UIColor *)value;
{
    [super setBackgroundColor:value];
    [self setNeedsDisplay];
}

//- (void) setUnderneathColor:(UIColor *)value;
//{
//    [_underneathColor release];
//    _underneathColor = [value retain];
//    [self setNeedsDisplay];
//}
//
//- (void) setRightBackgroundColor:(UIColor *)value;
//{
//    [_rightBackgroundColor release];
//    _rightBackgroundColor = [value retain];
////    [self setNeedsDisplay];
//}
//
//- (void) setLeftBackgroundColor:(UIColor *)value;
//{
//    [_leftBackgroundColor release];
//    _leftBackgroundColor = [value retain];
////    [self setNeedsDisplay];
//}


- (void) setBorderStyle:(MysticBorderStyle)aborderStyle
{
//    BOOL needDisplay = borderStyle != aborderStyle;
    
    borderStyle = aborderStyle;
    [self setNeedsDisplay];
}

- (void) setLeftOffset:(CGFloat)leftOffset
{
//    BOOL needDisplay = _leftOffset != leftOffset;
    
    _leftOffset = leftOffset;
    [self setNeedsDisplay];
}


- (void) setRightOffset:(CGFloat)rightOffset
{
    BOOL needDisplay = _rightOffset != rightOffset;
    
    _rightOffset = rightOffset;
    if(needDisplay)
    {
        [self setNeedsDisplay];
    }
}


- (void) setRadius:(CGFloat)radius
{
    BOOL needDisplay = _radius != radius;
    
    _radius = radius;
    if(needDisplay)
    {
        [self setNeedsDisplay];
    }
}

- (void) clear;
{
    [_leftBackgroundColor release];
    [_rightBackgroundColor release];
    _leftBackgroundColor = nil;
    _rightBackgroundColor = nil;
    _leftBgOffset = 0;
    _rightBgOffset = 0;
    _leftOffset = 0;
    _rightOffset = 0;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    [self.underneathColor setFill];

    
    CGContextFillRect(context, rect);
    
    
    if(self.showLip)
    {
    
        if(self.leftBackgroundColor && (self.radius-self.leftBgOffset) > 0)
        {
            [self.leftBackgroundColor setFill];
            CGRect lrect = CGRectMake(0, 0, self.radius-self.leftBgOffset, rect.size.height);
            CGContextFillRect(context, lrect);
        }
        else
        {
            [self.underneathColor setFill];
            CGRect lrect = CGRectMake(0, 0, self.radius-self.leftBgOffset, rect.size.height);
            CGContextFillRect(context, lrect);
        }
        
        if(self.rightBackgroundColor && self.rightBgOffset < self.radius)
        {
            
            [self.rightBackgroundColor setFill];
            CGContextFillRect(context, CGRectMake((rect.size.width-self.radius)+self.rightBgOffset, 0, self.radius-self.rightBgOffset, rect.size.height));
            
        }
        else
        {
            [self.underneathColor setFill];
            CGContextFillRect(context, CGRectMake((rect.size.width-self.radius)+self.rightBgOffset, 0, self.radius-self.rightBgOffset, rect.size.height));
        }
        
        
        [self.backgroundColor setFill];
        
        if(rect.size.height > self.radius)
        {
            CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height - (self.radius)));
        }
        
        
        
        UIBezierPath* path = [UIBezierPath bezierPath];
    //    [path moveToPoint: CGPointMake(0,rect.size.height - (self.radius-self.leftOffset))];
        [path moveToPoint: CGPointMake(0,rect.size.height - (self.radius))];
        [path addCurveToPoint: CGPointMake((self.radius-self.leftOffset),rect.size.height) controlPoint1: CGPointMake(0,rect.size.height-((self.radius-self.leftOffset)/2)) controlPoint2: CGPointMake(((self.radius-self.leftOffset)/2),rect.size.height)];
        [path addLineToPoint: CGPointMake(rect.size.width-(self.radius-self.rightOffset),rect.size.height)];
        [path addCurveToPoint: CGPointMake(rect.size.width,rect.size.height - (self.radius-self.rightOffset)) controlPoint1: CGPointMake(rect.size.width-((self.radius-self.rightOffset)/2),rect.size.height) controlPoint2: CGPointMake(rect.size.width,rect.size.height-((self.radius-self.rightOffset)/2))];
        [path addLineToPoint: CGPointMake(rect.size.width,rect.size.height - (self.radius))];
        
        
        
        [path fill];
        
        CGContextAddPath(context, path.CGPath);
        
        
        if(borderStyle == MysticBorderStyleTop)
        {
            CGContextSaveGState(context);
            
            CGRect newRect = CGRectMake(0, 0, rect.size.width, 2.0f);
            
            
            
            CGContextClipToRect(context, newRect);
            
            CGContextDrawTiledImage(context, CGRectMake(0,0, 6, 2.0f), [UIImage imageNamed:@"dottedTile.png"].CGImage);
        }
     
    }
    
    
}


@end

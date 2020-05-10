//
//  MysticRadialGradientLayer.m
//  Mystic
//
//  Created by Travis A. Weerts on 3/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticRadialGradientView.h"
#import "UIColor+Mystic.h"

@implementation MysticRadialGradientView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _feather = 1;
        self.color1 = UIColor.blackColor;
        self.color2 = [UIColor.blackColor colorWithAlphaComponent:0];
        
        [self setNeedsDisplay];
    }
    return self;
}
- (void) dealloc;
{
    [super dealloc];
    [_color1 release];
    [_color2 release];
}
- (void)drawCanvas1WithFrame: (CGRect)frame
{
    //// General Declarations
    
    if(self.color2 && self.feather>0)
    {

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();

        //// Gradient Declarations
        CGFloat gradientLocations[] = {1-_feather, (1-_feather) + _feather/2, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(id)self.color1.CGColor, (id)[self.color1 blendWithColor:self.color2 alpha:0.5].CGColor, (id)self.color2.CGColor], gradientLocations);
        
        //// Oval Drawing
        CGRect ovalRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.00000 + 0.5), floor(CGRectGetWidth(frame) * 1.00000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00000 + 0.5), floor(CGRectGetHeight(frame) * 1.00000 + 0.5) - floor(CGRectGetHeight(frame) * 0.00000 + 0.5));
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
        CGContextSaveGState(context);
        [ovalPath addClip];
        CGFloat ovalResizeRatio = MIN(CGRectGetWidth(ovalRect) / 100, CGRectGetHeight(ovalRect) / 100);
        CGContextDrawRadialGradient(context,
                                    gradient,
                                    CGPointMake(CGRectGetMidX(ovalRect) + 0 * ovalResizeRatio, CGRectGetMidY(ovalRect) + 0 * ovalResizeRatio),
                                    12.5 * ovalResizeRatio,
                                    CGPointMake(CGRectGetMidX(ovalRect) + 0 * ovalResizeRatio, CGRectGetMidY(ovalRect) + 0 * ovalResizeRatio),
                                    50.69 * ovalResizeRatio,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);

    }
    else
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect ovalRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.00000 + 0.5), floor(CGRectGetWidth(frame) * 1.00000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00000 + 0.5), floor(CGRectGetHeight(frame) * 1.00000 + 0.5) - floor(CGRectGetHeight(frame) * 0.00000 + 0.5));
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
        CGContextSaveGState(context);
        [ovalPath addClip];
        
        [self.color1 setFill];
        CGContextFillEllipseInRect(context, frame);
        CGContextRestoreGState(context);

    }
}

- (void) drawRect:(CGRect)rect;
{
    [self drawCanvas1WithFrame:rect];
}


@end

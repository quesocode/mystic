//
//  ILSaturationBrightnessPicker.m
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILSaturationBrightnessPickerView.h"


@implementation ILSaturationBrightnessPickerView

@synthesize hue, saturation, brightness;

- (void) dealloc;
{
    [super dealloc];
}
#pragma mark - Setup

-(void)setup
{
    [super setup];
    self.bounds=CGRectInset(self.bounds, -14, -14);
    hue=0;
    saturation=1;
    brightness=1;
    self.clipsToBounds=NO;
    self.layer.masksToBounds=NO;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // inset the rect
    CGRect orect = rect;
    rect=CGRectInset(rect, 14, 14);
    
    
    // draw the photoshop gradient
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
//    CGContextClipToRect(context, rect);
    [[UIColor hex:@"201F1F"] setFill];
    CGContextFillRect(context, rect);

    
    CGRect rrect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
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
    
    CGContextClip(context);
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    CGFloat locs[2]={ 0.00f, 1.0f };
    UIColor *bgc = [UIColor hex:@"201F1F"];
    NSArray *colors=[NSArray arrayWithObjects:
            (id)[[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1.0] CGColor],
            (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor], 
            nil];
    
    CGGradientRef grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
    CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointMake(0, 0), 0);
    CGGradientRelease(grad);

    colors=[NSArray arrayWithObjects:
            (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], 
            (id)[[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] colorWithMinBrightness:bgc.brightness+0.1] CGColor],
            nil];
    
    grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
    CGContextDrawLinearGradient(context, grad, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
    CGGradientRelease(grad);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(context);
    
    // draw the reticule
    
    CGPoint realPos=CGPointMake(saturation*rect.size.width, rect.size.height-(brightness*rect.size.height));
//    ALLog(@"color picker point", @[@"real pos", PLogStr(realPos),
//                                   @"sat", @(saturation),
//                                   @"brightness", @(brightness),
//                                   @"hue", @(hue), ]);

    CGRect reticuleRect=CGRectMake(realPos.x-10, realPos.y-10, 20, 20);

    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextSetLineWidth(context, 1);
    CGContextClosePath(context);
    CGContextSetStrokeColorWithColor(context, [bgc CGColor]);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
    [[bgc colorWithAlphaComponent:0.2] setFill];
    CGContextFillRect(context, rect);
    if(self.hasColor && self.showDropper && self.color)
    {
//        DLog(@"update dropper for hue brightness");
        CGContextClipToRect(context, rect);
        UIColor* fillColor = [UIColor hex:@"000000"] ;
        CGPoint p = (CGPoint){realPos.x - 13, realPos.y - 13};
        
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint: CGPointMake(13+p.x,0+p.y)];
        [path addCurveToPoint: CGPointMake(0+p.x,13+p.y) controlPoint1: CGPointMake(5+p.x,0+p.y) controlPoint2: CGPointMake(0+p.x,5+p.y)];
        [path addCurveToPoint: CGPointMake(13+p.x,26+p.y) controlPoint1: CGPointMake(0+p.x,20+p.y) controlPoint2: CGPointMake(5+p.x,26+p.y)];
        [path addLineToPoint: CGPointMake(23+p.x,26+p.y)];
        [path addCurveToPoint: CGPointMake(26+p.x,23+p.y) controlPoint1: CGPointMake(24+p.x,26+p.y) controlPoint2: CGPointMake(26+p.x,24+p.y)];
        [path addLineToPoint: CGPointMake(26+p.x,13+p.y)];
        [path addCurveToPoint: CGPointMake(13+p.x,0+p.y) controlPoint1: CGPointMake(26+p.x,5+p.y) controlPoint2: CGPointMake(20+p.x,0+p.y)];
        [fillColor setFill];
        [path fill];
        
        
        
        path = [UIBezierPath bezierPath];
        [path moveToPoint: CGPointMake(21+p.x,13+p.y)];
        [path addCurveToPoint: CGPointMake(13+p.x,20+p.y) controlPoint1: CGPointMake(21+p.x,17+p.y) controlPoint2: CGPointMake(17+p.x,20+p.y)];
        [path addCurveToPoint: CGPointMake(6+p.x,13+p.y) controlPoint1: CGPointMake(9+p.x,20+p.y) controlPoint2: CGPointMake(6+p.x,17+p.y)];
        [path addCurveToPoint: CGPointMake(13+p.x,5+p.y) controlPoint1: CGPointMake(6+p.x,8+p.y) controlPoint2: CGPointMake(9+p.x,5+p.y)];
        [path addCurveToPoint: CGPointMake(21+p.x,13+p.y) controlPoint1: CGPointMake(17+p.x,5+p.y) controlPoint2: CGPointMake(21+p.x,8+p.y)];
        [self.color setFill];
        [path fill];
    }
    
    
}


-(void)pickerChangedShowDropper:(BOOL)show picker:(id)picker;
{
    self.showDropper=show;
}
#pragma mark - Touches

-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super handleTouches:touches withEvent:event];

    CGPoint pos=[[touches anyObject] locationInView:self];
    
    float w=self.frame.size.width-28;
    float h=self.frame.size.height-28;
    if (pos.x<0)
        saturation=0;
    else if (pos.x>w)
        saturation=1;
    else
        saturation=pos.x/w;
    
    if (pos.y<0)
        brightness=1;
    else if (pos.y>h)
        brightness=0;
    else
        brightness=1-(pos.y/h);
    
    
    self.color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    [self.delegate colorPicked:self.color forPicker:self];
    
    [self setNeedsDisplay];
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    [self handleTouches:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    [self handleTouches:touches withEvent:event];
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    [self handleTouches:touches withEvent:event];
//}

#pragma mark - Property setters

-(void)setHue:(float)h
{
    hue=h;
    [self setNeedsDisplay];
}

-(void)setBrightness:(float)b
{
    brightness=b;
    [self setNeedsDisplay];
}

-(void)setSaturation:(float)s
{
    saturation=s;
    [self setNeedsDisplay];
}

#pragma mark - Current color

-(void)setColor:(UIColor *)cc
{
    
    [super setColor:cc];
    MysticColorHSB hsb=cc.hsb;
    hue=hsb.hue;
    saturation=hsb.saturation;
    brightness=hsb.brightness;
    if(saturation == 0) hue = 0.5;
    [self setNeedsDisplay];
}

- (void) colorPicked:(UIColor *)cc forPicker:(id)picker;
{
    [self.delegate colorPicked:cc forPicker:picker ? picker : self];
}

//-(UIColor *) color
//{
//    return _color;
////    if(_color) return _color;
////    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
//}

@end

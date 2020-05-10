//
//  ILRedPickerView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILRedPickerView.h"

@implementation ILRedPickerView


-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // draw the hue gradient
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [self.backgroundColor setFill];
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
    

    CGFloat locs[2]={
        0.00f,
        1.0f
    };
    UIColor *bgc = [UIColor hex:@"201F1F"];
    UIColor *c1 = nil;
    UIColor *c2 = nil;
    CGFloat v = 0.5;
    if(!self.color)
    {
        c1 = UIColor.redColor;
        c2 = [[UIColor blackColor] colorWithBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];
    }
    else
    {
        
        v =   self.rgb.red;
        MysticRGB rb = self.rgb;
        rb.red = 0;
        c1 = [[UIColor colorWithRed:1 green:self.rgb.green blue:self.rgb.blue alpha:1] colorWithMinBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];
        c2 = [[UIColor colorWithRed:MysticRGBisBlack(rb) ? 0.01 : 0 green:self.rgb.green blue:self.rgb.blue alpha:1] colorWithMinBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];

    }
        NSArray *colors=[NSArray arrayWithObjects:
                     (id)[c1 CGColor],
                     (id)[c2 CGColor],
                     nil];
    
    CGGradientRef grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
    if (self.pickerOrientation==0)
        CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointMake(0, 0), 0);
    else
        CGContextDrawLinearGradient(context, grad, CGPointMake(0,rect.size.height), CGPointMake(0, 0), 0);
    
    CGGradientRelease(grad);
    
    CGColorSpaceRelease(colorSpace);
    
    // Draw the indicator
    
    CGContextRestoreGState(context);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextSetLineWidth(context, 1);
    CGContextClosePath(context);
    CGContextSetStrokeColorWithColor(context, [bgc CGColor]);
    CGContextDrawPath(context, kCGPathStroke);
    //    [[bgc colorWithAlphaComponent:0.2] setFill];
    //    CGContextFillRect(context, rect);
    
    if(!self.showDropper) return;
    float pos=MAX(radius+2,MIN(rect.size.width-(radius+2),(self.pickerOrientation==0) ? rect.size.width*v : rect.size.height*v));
    
    CGContextSetFillColorWithColor(context, [bgc CGColor]);
    
    CGContextFillRect(context, (CGRect){pos-MYSTIC_UI_COLOR_SLIDER_INDICATOR/2,-1,MYSTIC_UI_COLOR_SLIDER_INDICATOR,rect.size.height+1});
    
}
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super handleTouches:touches withEvent:event];

    CGPoint pos=[[touches anyObject] locationInView:self];
    
    float p=(self.pickerOrientation==0) ? pos.x : pos.y;
    float b=(self.pickerOrientation==0) ? self.frame.size.width : self.frame.size.height;
    
    CGFloat v = 0;
    if (p<0)      v=0;
    else if (p>b) v=1;
    else          v=p/b;

    self.rgb = RGBRed(self.rgb,v);

    [self.delegate colorPicked:self.color forPicker:self];
    [self setNeedsDisplay];
}

@end

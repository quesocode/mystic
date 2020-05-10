//
//  ILHuePicker.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILHuePickerView.h"


@interface ILHuePickerView(Private)
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;

@end
@interface ILHuePickerView ()

@end
@implementation ILHuePickerView

@synthesize  hue;

#pragma mark - Setup

-(void)setup
{
    [super setup];
    hue=0.5;
}

#pragma mark - Drawing

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
    
    float step=0.166666666666667f;
    
    CGFloat locs[7]={ 
        0.00f, 
        step, 
        step*2, 
        step*3, 
        step*4, 
        step*5, 
        1.0f
    };
    
    NSArray *colors=[NSArray arrayWithObjects:
                     (id)[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] CGColor], 
                     (id)[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor], 
                     nil];
    
    CGGradientRef grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
    if (self.pickerOrientation==0)
        CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointMake(0, 0), 0);
    else
        CGContextDrawLinearGradient(context, grad, CGPointMake(0,rect.size.height), CGPointMake(0, 0), 0);
        
    CGGradientRelease(grad);
     
    CGColorSpaceRelease(colorSpace);
    
    
    
    UIColor *bgc = [UIColor hex:@"201F1F"];

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
//    
//    
//    [[bgc colorWithAlphaComponent:0.2] setFill];
//    CGContextFillRect(context, rect);
    if(!self.showDropper) return;
    // Draw the indicator
    float pos=MAX(radius+2,MIN(rect.size.width-(radius+2),(self.pickerOrientation==0) ? rect.size.width*hue : rect.size.height*hue));
    
    CGContextSetFillColorWithColor(context, [bgc CGColor]);
    
    CGContextFillRect(context, (CGRect){pos-MYSTIC_UI_COLOR_SLIDER_INDICATOR/2,-1,MYSTIC_UI_COLOR_SLIDER_INDICATOR,rect.size.height+1});

}

#pragma mark - Touches

-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super handleTouches:touches withEvent:event];

    CGPoint pos=[[touches anyObject] locationInView:self];
    
    float p=(self.pickerOrientation==0) ? pos.x : pos.y;
    float b=(self.pickerOrientation==0) ? self.frame.size.width : self.frame.size.height;
    
    if (p<0)
        hue=0;
    else if (p>b)
        hue=1;
    else
        hue=p/b;
    
    [self.delegate colorPicked:self.color forPicker:self];
    [self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.showDropper=YES;
    [self handleTouches:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches withEvent:event];
}

#pragma mark - Property Setters

-(void)setHue:(float)h
{
    hue=h;
    [self setNeedsDisplay];
}



#pragma mark - Current color

-(void)setColor:(UIColor *)cc
{
    if([cc isEqualToColor:self.color]) return;
    [super setColor:cc];
    MysticColorHSB ahsb=cc.hsb;
    hue=ahsb.hue == 0 ? 0.5 : ahsb.hue;
    ahsb.hue = hue;
    self.hsb = ahsb;
    [self setNeedsDisplay];
}

-(UIColor *)color
{
    return [UIColor colorWithHue:hue saturation:self.hsb.saturation brightness:self.hsb.brightness alpha:1.0];
}


- (void) colorPicked:(UIColor *)cc forPicker:(id)picker;
{
    [self.delegate colorPicked:cc forPicker:picker ? picker : self];
}
@end

//
//  ILHsbSatPickerView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILHsbSatPickerView.h"
#import "MysticUtility.h"

@interface ILHsbSatPickerView(Private)
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@implementation ILHsbSatPickerView


@synthesize sat=sat;


-(void)setup
{
    [super setup];
    sat=0.5;
}



-(void)drawRect:(CGRect)rect
{
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
    MysticColorHSB ahsb = (MysticColorHSB){self.hsb.hue,self.hsb.saturation,self.hsb.brightness};
    UIColor *c1 = self.hasColor ? [UIColor colorWithHue:ahsb.hue saturation:1 brightness:1 alpha:1] : UIColor.redColor;
    UIColor *c2 = [[[c1 colorWithSaturation:0] alpha:1] colorWithMinBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];

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
//    [[bgc colorWithAlphaComponent:0.2] setFill];
//    CGContextFillRect(context, rect);
    
    if(!self.showDropper) return;
    float pos=MAX(radius+2,MIN(rect.size.width-(radius+2),(self.pickerOrientation==0) ? rect.size.width*sat : rect.size.height*sat));
    
    CGContextSetFillColorWithColor(context, [bgc CGColor]);
    
    CGContextFillRect(context, (CGRect){pos-MYSTIC_UI_COLOR_SLIDER_INDICATOR/2,-1,MYSTIC_UI_COLOR_SLIDER_INDICATOR,rect.size.height+1});
    
}


-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super handleTouches:touches withEvent:event];

    CGPoint pos=[[touches anyObject] locationInView:self];
    
    float p=(self.pickerOrientation==0) ? pos.x : pos.y;
    float b=(self.pickerOrientation==0) ? self.frame.size.width : self.frame.size.height;
    
    if (p<0)      sat=0;
    else if (p>b) sat=1;
    else          sat=p/b;
    
    self.hsb = (MysticColorHSB){self.hsb.hue,sat,self.hsb.brightness};
    [self.delegate colorPicked:self.color forPicker:self];
    [self setNeedsDisplay];
}



#pragma mark - Property Setters

-(void)setSat:(float)h
{
    sat=h;
    [self setNeedsDisplay];
}


#pragma mark - Current color

-(void)setColor:(UIColor *)cc
{
    if(self.color && [cc isEqualToColor:self.color]) return;
    [super setColor:cc];
    MysticColorHSB ahsb=cc.hsb;
    sat=ahsb.saturation;
    self.hsb = ahsb;
    [self setNeedsDisplay];
}

-(UIColor *)color
{
    return [UIColor colorWithHue:self.hsb.hue saturation:sat brightness:self.hsb.brightness alpha:1.0];
}

- (void) colorPicked:(UIColor *)cc forPicker:(id)picker;
{
    [self.delegate colorPicked:cc forPicker:picker ? picker : self];
}

@end

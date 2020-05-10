//
//  ILTunePickerView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/4/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILTunePickerView.h"

@implementation ILTunePickerView


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
    
    CGFloat rangeMin = 0;
    CGFloat rangeMax = 1;
    CGFloat rangeMid = 0.5;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad;
    UIColor *bgc = [UIColor hex:@"201F1F"];
    UIColor *c1 = nil;
    UIColor *c2 = nil;
    CGFloat v = 0.5;
    NSArray *colors=nil;
    if(!self.color)
    {
        switch (self.tune) {
            case MysticTuneThreshold: c1 = UIColor.redColor; break;
            case MysticTuneRange: c1 = UIColor.blueColor; break;
            case MysticTuneAlpha: c1 = self.sourceColor; c2=self.color; break;
            case MysticTuneSmooth: c1 = UIColor.blackColor; break;
            default: break;
        }
        c2 = [c1 colorWithBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];
    }
    else
    {
        //        MysticRGB lrgb = self.threshold;
        //        MysticRGB hrgb = self.threshold;
        
        switch (self.tune) {
#pragma mark - Draw Threshold
            case MysticTuneThreshold:
            {
                
                v=self.threshold.threshold;
                MysticRGB lrgb = self.sourceColor.rgb;
                MysticRGB hrgb = self.color.rgb;
                c1 = c1 ? c1 : [[UIColor colorWithRed:hrgb.red green:hrgb.green blue:hrgb.blue alpha:1] colorWithMinBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];
                c2 = c2 ? c2 : [[UIColor colorWithRed:lrgb.red green:lrgb.green blue:lrgb.blue alpha:1] colorWithMinBrightness:MYSTIC_UI_INPUT_MIN_BRIGHT];
                CGFloat locs[2]={
                    0.00f,
                    1.0f
                };
                colors=[NSArray arrayWithObjects:
                        (id)[c2 CGColor],
                        (id)[c1 CGColor],
                        nil];
                grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
                break;
            }
#pragma mark - Draw Range
            case MysticTuneRange:
            {
                MysticHSB hsb = (MysticHSB){self.sourceColor.hsb.hue, self.sourceColor.hsb.saturation, self.sourceColor.hsb.brightness};
                
                float step=0.166666666666667f;
                hsb.saturation = 0.8;
                hsb.brightness = 1.0;
                
                CGFloat locs[7]={
                    0.00f,
                    step,
                    step*2,
                    step*3,
                    step*4,
                    step*5,
                    1.0f
                };
                
                colors=[NSArray arrayWithObjects:
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,-0.5)] CGColor],
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,-0.5+step)] CGColor],
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,-0.5+step*2)] CGColor],
                        (id)[[UIColor colorWithHSB:hsb] CGColor],
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,step)] CGColor],
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,step*2)] CGColor],
                        (id)[[UIColor colorWithHSB:MysticHSBAddHue(hsb,0.5)] CGColor],
                        nil];
                
                //                c1 = [[UIColor colorWithHSB:lhsb]  colorWithMinBrightness:bgc.brightness+0.1];
                //                c2 = [[UIColor colorWithHSB:hhsb] colorWithMinBrightness:bgc.brightness+0.1];
                v = self.threshold.range.mid;
   
                grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
                rangeMax = self.threshold.range.max;
                rangeMin = self.threshold.range.min;
                break;
            }
#pragma mark - Draw Alpha
                
            case MysticTuneAlpha:
            {
                [[bgc colorWithMinBrightness:0.1] setFill];
                CGContextFillRect(context, (CGRect)self.bounds);
                
                v=self.threshold.intensity;
                //                CGContextSaveGState(context);
                BOOL even = NO;
                CGFloat h = self.frame.size.height/2;
                CGPoint p = CGPointZero;
                for (int k=0; k<(int)ceilf(self.frame.size.width/h); k++) {
                    CGContextMoveToPoint(context, p.x, 0);
                    CGContextAddRect(context, (CGRect){p.x,even?h:0,h,h});
                    p.x += h;
                    even = !even;
                }
                CGContextClosePath(context);
                [[bgc colorWithMinBrightness:0.2] setFill];
                CGContextFillPath(context);
                c1 = [[self.color alpha:0.3] colorWithMinBrightness:bgc.brightness+0.15];
                c2 = [[self.color alpha:1] colorWithMinBrightness:bgc.brightness+0.15];
                CGFloat locs[2]={0.00f, 1.0f };
                grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(id)c2.CGColor,(id)c1.CGColor], locs);
                if (self.pickerOrientation==0) CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointZero, 0);
                else CGContextDrawLinearGradient(context, grad, CGPointMake(0,rect.size.height), CGPointZero, 0);
                CGGradientRelease(grad);
                grad=nil;
                
                break;
            }
#pragma mark - Draw Smooth
            case MysticTuneSmooth: {
                v=self.threshold.smoothing;
                c1 = self.sourceColor;
                c2 = self.color;
                CGFloat locs[2]={
                    0.00f,
                    1.0f
                };
                colors=[NSArray arrayWithObjects:
                        (id)[c1 CGColor],
                        (id)[c2 CGColor],
                        nil];
                grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
                break;
            }
                
            default: break;
        }

    }

    if(grad)
    {
        if (self.pickerOrientation==0)
            CGContextDrawLinearGradient(context, grad, CGPointMake(rect.size.width,0), CGPointMake(0, 0), 0);
        else
            CGContextDrawLinearGradient(context, grad, CGPointMake(0,rect.size.height), CGPointMake(0, 0), 0);
        
        CGGradientRelease(grad);
    }
    
    if(colorSpace) CGColorSpaceRelease(colorSpace);
    
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
    if(!self.showDropper) return;
    
    float pos=MAX(radius+2,MIN(rect.size.width-(radius+2),(self.pickerOrientation==0) ? rect.size.width*v : rect.size.height*v));
    switch (self.tune) {
        case MysticTuneRange:
        {
            
            pos=MAX(radius+2,MIN(rect.size.width-(radius+2),self.pickerOrientation==0 ? rect.size.width*0.5 : rect.size.height*0.5));
            
            float posl=MAX(radius+2,MIN(rect.size.width-(radius+2),self.pickerOrientation==0 ? rect.size.width*(0.5+rangeMin) : rect.size.height*(0.5+rangeMin)));
            
            float posh=MAX(radius+2,MIN(rect.size.width-(radius+2),self.pickerOrientation==0 ? rect.size.width*(0.5+rangeMax) : rect.size.height*(0.5+rangeMax)));
            
            
            if(!self.touching) {
                CGContextSetFillColorWithColor(context, [[UIColor.blackColor alpha:0.1]  CGColor] );
                CGContextFillRect(context, (CGRect){posl,0,posh-posl,rect.size.height});
            }
            
            CGContextSetFillColorWithColor(context, [bgc CGColor]);
            //            CGFloat ind = 1.5;
            //            CGContextFillRect(context, (CGRect){pos-ind/2,0,ind,rect.size.height});
            CGFloat ind = MYSTIC_UI_COLOR_SLIDER_INDICATOR;
            
            //            CGContextSetFillColorWithColor(context, [bgc CGColor]);
            //            CGContextSetFillColorWithColor(context, [[[UIColor whiteColor] alpha:0.5] CGColor]);
            CGContextFillRect(context, (CGRect){posl-ind/2,0,ind,rect.size.height});
            CGContextFillRect(context, (CGRect){posh-ind/2,0,ind,rect.size.height});
            break;
        }
        default:
            CGContextSetFillColorWithColor(context, [bgc CGColor]);
            CGContextFillRect(context, (CGRect){pos-MYSTIC_UI_COLOR_SLIDER_INDICATOR/2,-1,MYSTIC_UI_COLOR_SLIDER_INDICATOR,rect.size.height+1});
            break;
    }
    
    
}
-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super handleTouches:touches withEvent:event];
    CGPoint pos=[[touches anyObject] locationInView:self];
    MysticThreshold n = self.threshold;

    float p=(self.pickerOrientation==0) ? pos.x : pos.y;
    float b=(self.pickerOrientation==0) ? self.frame.size.width : self.frame.size.height;
    
    CGFloat         v=0;
    
    if (p<0)        v=0;
    else if (p>b)   v=1;
    else            v=p/b;
    
    switch (self.tune) {
        case MysticTuneThreshold: n.threshold = v; break;
        case MysticTuneSmooth: n.smoothing = v; break;
        case MysticTuneRange:
        {
            CGFloat mid = 0.5;
            if(v < mid && self.adjustType != MysticAdjustTypeMax)
            {
                n.range.min = -(mid-v);
                self.adjustType =  MysticAdjustTypeMin;
            }
            else if(v>mid && self.adjustType != MysticAdjustTypeMin)
            {
                n.range.max = v-mid;
                self.adjustType = MysticAdjustTypeMax;
                
            }
            break;
        }
        case MysticTuneAlpha: n.intensity = v; break;
        default: break;
    }
    self.threshold = n;
    [self.delegate tunePicked:self.threshold forPicker:self];
    [self setNeedsDisplay];
}
- (void) setThreshold:(MysticThreshold)v;
{
    _threshold=v;
    _originalThreshold = (MysticThreshold){v.range,v.threshold,v.smoothing,v.intensity};
    [self setNeedsDisplay];
}
@end

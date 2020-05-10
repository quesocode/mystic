//
//  ILHsbHuePickerView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILHsbHuePickerView.h"

@implementation ILHsbHuePickerView

- (void) colorPicked:(UIColor *)cc forPicker:(id)picker;
{
    [self.delegate colorPicked:cc forPicker:picker ? picker : self];
}
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
@end

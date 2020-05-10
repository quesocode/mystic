//
//  ILRGBPickerView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILRGBPickerView.h"

@implementation ILRGBPickerView

- (BOOL) hidesColorDropper; { return NO; }
- (void) setup;
{
    [super setup];
    _state = MysticColorStateUnknown;
}
- (void) setColor:(UIColor *)cc;
{
    [super setColor:cc];
    self.rgb = (MysticRGB){cc.red,cc.green,cc.blue,1.0};
    [self setNeedsDisplay];
}
//- (UIColor *) color;
//{
//    return [UIColor colorWithRed:self.rgb.red green:self.rgb.green blue:self.rgb.blue alpha:1];
//}




@end


@implementation ILHSBPickerView



- (void) setColor:(UIColor *)cc;
{
    //    if([cc isEqualToColor:self.color]) return;
    [super setColor:cc];
    self.hsb = (MysticColorHSB){cc.hue,cc.saturation,cc.brightness};
    [self setNeedsDisplay];
}
- (UIColor *) color;
{
    return [UIColor colorWithHSBA:self.hsb];
}




@end

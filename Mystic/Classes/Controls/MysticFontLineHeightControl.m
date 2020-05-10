//
//  MysticFontLineHeightControl.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontLineHeightControl.h"

@implementation MysticFontLineHeightControl

- (MysticIconType) plusIconType; { return MysticIconTypeToolUpCenter; }
- (MysticIconType) minusIconType; { return MysticIconTypeToolDownCenter; }
- (CGFloat) minimumValue; { return 0.05; }
- (CGFloat) maximumValue; { return MYSTIC_MAX_LINEHEIGHT_SCALE; }
- (CGFloat) defaultValue; { return MYSTIC_DEFAULT_LINEHEIGHT_SCALE; }
- (CGFloat) incrementSize; { return 0.025; }
- (BOOL) allowLoop; { return NO; }
- (NSTimeInterval) incrementInterval; { return MYSTIC_HOLD_INTERVAL_NORMAL; }

- (MysticToolType) toolType; { return MysticToolTypeFontLineHeight; }


- (void) commonInit;
{
    [super commonInit];

}

- (CGFloat) formatValue:(CGFloat)newValue;
{
    CGFloat d = self.maximumValue - self.minimumValue;
//    CGFloat i = d/self.incrementSize;
    
    CGFloat p = newValue/self.maximumValue;
    
    CGFloat steps = 100.f;
    
    
    p = newValue - self.incrementSize <= self.minimumValue ? 0 : p;
    p = newValue - self.incrementSize >= self.maximumValue ? 1 : p;
    
    CGFloat n = steps * p;
    
//    ALLog(@"format lineheight", @[@"value", @(newValue), @"output", @(n), @"percent", @(p), @"steps", @(i)]);
    
    return n;
}

@end

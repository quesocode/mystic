//
//  MysticColor.h
//  Mystic
//
//  Created by travis weerts on 6/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "UIColor+Mystic.h"

@interface MysticColor : UIColor

+ (UIColor *) colorWithType:(MysticColorType)colorType;
+ (void) printColors;
+ (BOOL) color:(UIColor *)color equals:(UIColor *)color2;
+ (UIColor *) colorForObject:(MysticObjectType)objType orColor:(UIColor *)dcolor;
+ (UIColor *) colorForObject:(MysticObjectType)objType or:(MysticColorType)dtype;
+ (MysticColorType) colorTypeForObject:(MysticObjectType)objType or:(MysticColorType)dtype;
+ (UIColor *) color:(id)color;
+ (MysticColorType) brightnessColorType:(UIColor *)color;
+ (CGFloat) brightness:(UIColor *)color;

@end

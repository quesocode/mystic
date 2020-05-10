//
//  MysticDrawKit.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/29/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticChoice.h"
#import "Bezier.h"
#import "CGPath_Boolean.h"
#import "CGPath_Utilities.h"

@interface MysticDrawKit : NSObject

+ (id) kit;
+ (Class) drawClass:(MysticChoice *)choice;
+ (NSDictionary *) draw:(MysticChoice *)choice frame:(CGRect)frame;
+ (UIBezierPath *) path:(MysticChoice *)choice frame:(CGRect)frame;
+ (NSDictionary *) pathBounds:(MysticChoice *)choice;
+ (NSDictionary *) pathBounds:(MysticChoice *)choice border:(float)borderWidth;
+ (UIImage *) imageMask:(MysticChoice *)choice scale:(float)scale quality:(CGInterpolationQuality)quality;
+ (NSDictionary *) pathAndSubpaths:(MysticChoice *)choice frame:(CGRect)frame;


+ (UIImage *) image:(SEL)selector frame:(CGRect)frame bounds:(CGRect)bounds color:(UIColor *)color scale:(float)scale  contentMode:(UIViewContentMode)contentMode quality:(CGInterpolationQuality)quality;
+ (UIImage *) image:(SEL)selector frame:(CGRect)frame color:(UIColor *)color;


+ (void)drawBorderWidthWithFrame: (NSValue *)frame color:(UIColor *)color;
+ (void)drawBorderColorFrame: (NSValue *)frame color:(UIColor *)color;
+ (void)drawBorderAlphaFrame: (NSValue *)frame color:(UIColor *)color;

@end

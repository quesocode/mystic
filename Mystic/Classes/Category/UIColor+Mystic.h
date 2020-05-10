//
//  Tiny.h
//  Tiny
//
//  Created by Travis Weerts on 4/2/11.
//  Copyright 2011 Tinymatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticColor.h"

void RGBtoHSV3(float r, float g, float b, float *h, float *s, float *v);
void HSVtoRGB3(float h, float s, float v, float *r, float *g, float *b);

@interface UIColor (Mystic)
+ (CGFloat) differenceLAB:(UIColor *)color color2:(UIColor *)color2;

+ (UIColor *)colorWithLightness:(CGFloat)lightness A:(CGFloat)A B:(CGFloat)B alpha:(CGFloat)alpha;
- (void)getLightness:(CGFloat *)lightness A:(CGFloat *)a B:(CGFloat *)b alpha:(CGFloat *)alpha;
- (UIColor *)offsetWithLightness:(CGFloat)lightness a:(CGFloat)a b:(CGFloat)b alpha:(CGFloat)alpha;

#pragma mark - Intermediate Colorspace XYZ
- (void)getX:(CGFloat *)xOut Y:(CGFloat *)yOut Z:(CGFloat *)zOut alpha:(CGFloat *)alphaOut;
- (NSArray *)rgbaArray;
- (NSArray *)hsbaArray;

+ (UIColor *) color:(MysticColorType)colorType;
+ (UIColor *) colorWithRGB:(MysticRGB)rgb;
+ (UIColor *) colorWithHSBA:(MysticColorHSB)hsb;
+ (UIColor *) colorWithHSB:(MysticHSB)hsb;
+ (UIColor *) colorWithRGB:(MysticRGB)rgb alpha:(CGFloat)alpha;
+ (UIColor *) colorWithHSB:(MysticHSB)hsb alpha:(CGFloat)alpha;
+ (UIColor *) colorWithType:(MysticColorType)colorType;
- (UIColor *) colorWithMinBrightness:(CGFloat)b;
- (UIColor *) colorWithMinSaturation:(CGFloat)b;
+ (UIColor *) mysticChocolateColor;
+ (UIColor *) mysticDarkChocolateColor;
+ (UIColor *) mysticBackgroundColor;
+ (UIColor *) mysticDarkGrayBackgroundColor;
+ (UIColor *) mysticDarkBackgroundColor;
+ (UIColor *) mysticGrayBackgroundColor;
+ (UIColor *) mysticWhiteBackgroundColor;
+ (UIColor *) mysticDarkTextColor;
+ (UIColor *) mysticLightTextColor;
+ (UIColor *) mysticLightTextShadowColor;
+ (UIColor *) mysticDarkTextShadowColor;
+ (UIColor *) mysticBlueColor;
+ (UIColor *) mysticLightBlueColor;
+ (UIColor *) mysticGrayColor;
+ (UIColor *) mysticBlackColor;
+ (UIColor *) mysticBrownColor;
+ (UIColor *) mysticDarkRedColor;
+ (UIColor *) mysticRedColor;
+ (UIColor *) mysticWhiteColor;
+ (UIColor *) mysticPinkColor;
+ (UIColor *) mysticInactiveIconColor;
+ (UIColor *) mysticDarkGrayColor;
+ (UIColor *) mysticTitleDarkColor;
+ (UIColor *) mysticTitleLightColor;
+ (UIColor *) mysticReallyLightGrayColor;
+ (UIColor *) mysticSubGrayColor;
+ (UIColor *) mysticGreenColor;
+ (UIColor *) mysticRustColor;
+ (UIColor *) mysticBurnoutKhaki;
- (CGColorSpaceModel) colorSpaceModel;
- (NSString *) colorSpaceString;
- (UIColor *) clear;
+ (UIColor *) clear;
+ (UIColor *) yellow;
+ (UIColor *) red;
+ (UIColor *) blue;
+ (UIColor *) green;
+ (UIColor *) black;
+ (UIColor *) white;
+ (UIColor *) orange;
+ (UIColor *) purple;
+ (UIColor *) cyan;
+ (UIColor *) magenta;


- (UIColor *) lighterThan:(UIColor *)color;
- (UIColor *) darkerThan:(UIColor *)color;
- (BOOL) isDarkerThan:(UIColor *)color;
- (BOOL) isLighterThan:(UIColor *)color;
- (MysticRGB) differenceThan:(UIColor *)color;
- (CIColor *) CIColor;

- (UIColor *) invertedColor;
- (BOOL) canProvideRGBComponents;
- (NSArray *) arrayFromRGBAComponents;
- (CGFloat) red;
- (CGFloat) blue;
- (CGFloat) green;
- (CGFloat) alpha;
- (NSString *) rgbaString;
- (NSString *) vec4Str;
- (NSString *) stringFromColor;
- (NSString *) hexStringFromColor;
+ (UIColor *) hex: (NSString *) hex;
+ (UIColor *) string: (NSString *) string;
- (UIColor *) opaque;
- (BOOL) isDifferentThan:(UIColor *)color;
- (BOOL) isDifferentThan:(UIColor *)color threshold:(float)threshold;
- (BOOL) isHueDifferentThan:(UIColor *)color threshold:(float)threshold;
- (float) hueDifference:(UIColor *)color;
- (BOOL) isHueDifferentThan:(UIColor *)color;

- (BOOL)isEqualToColor:(UIColor *)color;
- (UIColor *) addRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

+ (UIColor *) colorWithString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

+ (UIColor *) fromHex: (NSString *) stringToConvert;
+ (UIColor *) fromString: (NSString *) str;
+ (UIColor *) randomColor;
- (NSString *) hexValue;
- (UIColor *) alpha:(CGFloat)a;
- (UIColor *) darker:(CGFloat)percent;
- (UIColor *) lighter:(CGFloat)percent;
- (MysticColorHSB) hsb;
- (UIColor *) colorWithBrightness:(CGFloat)value;
- (UIColor *) colorWithSaturation:(CGFloat)sat;
- (UIColor *) colorWithHue:(CGFloat)hue;
- (UIColor *) colorWithHue:(CGFloat)hue saturation:(CGFloat)sat brightness:(CGFloat)b;

- (UIColor*) blendWithColor:(UIColor*)color2 alpha:(CGFloat)alpha2;
- (void) componentsDescription;
- (UIColor *) colorWithHSB:(MysticColorHSB)__hsb;

@property (readonly)	BOOL isInGraySpace;
@property (readonly)    MysticRGB rgb;
@property (readonly)	CGFloat red;
@property (readonly)	CGFloat green;
@property (readonly)	CGFloat blue;
@property (readonly)	CGFloat alpha;
@property (readonly)	CGFloat hue;
@property (readonly)	CGFloat saturation;
@property (readonly)	CGFloat brightness;
@property (readonly)    int red255, blue255, green255;
@property (readonly)    NSString *fgString, *bgString, *rgb255, *hexString;

@property (readonly, nonatomic) UIColor *displayColor, *colorTransparent, *colorOpaque;
@end

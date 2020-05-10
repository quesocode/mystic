//
//  MysticFont.m
//  Mystic
//
//  Created by Me on 7/5/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFont.h"

@implementation MysticFont


#pragma mark - Fonts
+ (UIFont *) defaultTypeFont:(CGFloat)size; {   return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size]; }
+ (UIFont *) font:(CGFloat)size; {              return [self gotham:size]; }
+ (UIFont *) fontBold:(CGFloat)size; {          return [self gothamBold:size]; }
+ (UIFont *) fontBook:(CGFloat)size; {          return [self gothamBook:size]; }
+ (UIFont *) fontLight:(CGFloat)size; {         return [self gothamLight:size]; }
+ (UIFont *) fontXLight:(CGFloat)size; {        return [self gothamXLight:size]; }
+ (UIFont *) fontMedium:(CGFloat)size; {        return [self gothamMedium:size]; }
+ (UIFont *) fontBlack:(CGFloat)size; {         return [self gothamBlack:size]; }


+ (UIFont *) gotham:(CGFloat)size; {            return [self gothamMedium:size]; }
+ (UIFont *) gothamBook:(CGFloat)size; {        return [UIFont fontWithName:@"GothamHTF-Book" size:size]; }
+ (UIFont *) gothamMedium:(CGFloat)size; {      return [UIFont fontWithName:@"GothamHTF-Medium" size:size]; }
+ (UIFont *) gothamLight:(CGFloat)size; {       return [UIFont fontWithName:@"GothamHTF-Light" size:size]; }
+ (UIFont *) gothamBold:(CGFloat)size; {        return [UIFont fontWithName:@"GothamHTF-Bold" size:size]; }
+ (UIFont *) gothamBlack:(CGFloat)size; {       return [UIFont fontWithName:@"GothamHTF-Black" size:size]; }
+ (UIFont *) gothamXLight:(CGFloat)size; {      return [UIFont fontWithName:@"GothamHTF-XLight" size:size]; }


@end

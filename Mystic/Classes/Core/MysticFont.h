//
//  MysticFont.h
//  Mystic
//
//  Created by Me on 7/5/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticUI.h"

@interface MysticFont : MysticUI


+ (UIFont *) gotham:(CGFloat)size;
+ (UIFont *) gothamLight:(CGFloat)size;
+ (UIFont *) gothamXLight:(CGFloat)size;
+ (UIFont *) gothamBold:(CGFloat)size;
+ (UIFont *) gothamMedium:(CGFloat)size;
+ (UIFont *) gothamBook:(CGFloat)size;
+ (UIFont *) font:(CGFloat)size;
+ (UIFont *) fontBold:(CGFloat)size;
+ (UIFont *) fontBook:(CGFloat)size;
+ (UIFont *) fontMedium:(CGFloat)size;
+ (UIFont *) fontLight:(CGFloat)size;
+ (UIFont *) fontXLight:(CGFloat)size;
+ (UIFont *) defaultTypeFont:(CGFloat)size;
+ (UIFont *) fontBlack:(CGFloat)size;
+ (UIFont *) gothamBlack:(CGFloat)size;

@end

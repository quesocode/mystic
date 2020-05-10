//
//  LLog.h
//  Mystic
//
//  Created by Travis A. Weerts on 2/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticUtility.h"


@interface LLog : NSObject;

+ (id) logger;
+ (void) log;
+ (void) log:(NSString *)name;
+ (void) log:(NSString *)name values:(NSArray *)values;
- (void) log;
- (void) log:(NSString *)name;
- (void) log:(NSString *)name values:(NSArray *)values;


+ (instancetype) black;
+ (instancetype) bg;
+ (instancetype) light;
+ (instancetype) dark;
+ (instancetype) line;
+ (instancetype) space;
+ (instancetype) set:(id)value;
+ (instancetype)set:(id)key view:(UIView *)value;
+ (instancetype)set:(id)key fl:(float)value;
+ (instancetype)set:(id)key int:(int)value;
+ (instancetype)set:(id)key use:(id)value;
+ (instancetype)set:(id)key b:(BOOL)value;
+ (instancetype)set:(id)key f:(CGRect)value;
+ (instancetype)set:(id)key s:(CGSize)value;
+ (instancetype)set:(id)key p:(CGPoint)value;
+ (instancetype)set:(id)key sc:(CGScale)value;
+ (instancetype)set:(id)key ins:(UIEdgeInsets)value;
+ (instancetype)set:(id)key trans:(CGAffineTransform)value;
+ (instancetype) add:(NSArray *)keyValues;

- (instancetype) color:(id)color;
- (instancetype) colorKey:(id)color;
- (instancetype) green;
- (instancetype) greenKey;
- (instancetype) greenBright;
- (instancetype) greenBrightKey;
- (instancetype) date;
- (instancetype) dateKey;
- (instancetype) dull;
- (instancetype) dullKey;
- (instancetype) dots;
- (instancetype) dotsKey;
- (instancetype) purple;
- (instancetype) purpleKey;
- (instancetype) yellow;
- (instancetype) yellowKey;
- (instancetype) blue;
- (instancetype) blueKey;
- (instancetype) white;
- (instancetype) whiteKey;
- (instancetype) red;
- (instancetype) redKey;
- (instancetype) pink;
- (instancetype) pinkKey;
- (instancetype) bgColor;
- (instancetype) bgColorKey;
- (instancetype) cyan;
- (instancetype) cyanKey;

- (instancetype) indent;
- (void) logObjs;



+ (instancetype) start;
+ (void) clear;


- (instancetype) black;
- (instancetype) bg;
- (instancetype) light;
- (instancetype) dark;
- (instancetype) line;
- (instancetype) space;
- (instancetype) set:(id)value;
- (instancetype)set:(id)key use:(id)value;
- (instancetype)set:(id)key b:(BOOL)value;
- (instancetype)set:(id)key f:(CGRect)value;
- (instancetype)set:(id)key s:(CGSize)value;
- (instancetype)set:(id)key p:(CGPoint)value;
- (instancetype)set:(id)key sc:(CGScale)value;
- (instancetype)set:(id)key trans:(CGAffineTransform)value;
- (instancetype)set:(id)key ins:
(UIEdgeInsets)value;
- (instancetype)set:(id)key view:(UIView *)value;
- (instancetype) add:(NSArray *)keyValues;
- (instancetype) line:(NSArray *)keyValues;
- (instancetype) space:(NSArray *)keyValues;
- (instancetype) bg:(NSArray *)keyValues;
- (instancetype) dark:(NSArray *)keyValues;
- (instancetype) black:(NSArray *)keyValues;
- (instancetype) light:(NSArray *)keyValues;

- (instancetype)set:(id)key fl:(float)value;
- (instancetype)set:(id)key int:(int)value;


@end

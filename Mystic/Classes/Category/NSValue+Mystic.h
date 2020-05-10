//
//  NSValue+NSValue_Mystic.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/30/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (Mystic)
+ (instancetype) rect:(CGRect)value;
+ (instancetype) point:(CGPoint)value;
+ (instancetype) size:(CGSize)value;
+ (instancetype) insets:(UIEdgeInsets)value;
+ (instancetype) transform:(CGAffineTransform)value;
+ (instancetype) boolean:(BOOL)value;
+ (instancetype) floatn:(float)value;
+ (instancetype) intn:(int)value;
@property (nonatomic, readonly) NSString *typeString;
@property (nonatomic, readonly) BOOL isCGRect, isCGPoint, isCGSize, isUIEdgeInsets, isFloat, isInteger, isBoolean, isUnknown, isTransform, isRange;

@property (nonatomic, readonly) CGAffineTransform transform;
@property (nonatomic, readonly) float y, x, width, height, top, left, bottom, right, length, location;

@end

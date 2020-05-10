//
//  NSValue+NSValue_Mystic.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/30/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "NSValue+Mystic.h"
#import "MysticConstants.h"

@implementation NSValue (Mystic)

@dynamic isCGSize, isBoolean, isRange, isTransform, isInteger, isFloat, isUIEdgeInsets, isCGPoint, isCGRect, isUnknown;

+ (instancetype) rect:(CGRect)value; { return [[self class] valueWithCGRect:value]; }
+ (instancetype) point:(CGPoint)value; { return [[self class] valueWithCGPoint:value]; }
+ (instancetype) size:(CGSize)value; { return [[self class] valueWithCGSize:value]; }
+ (instancetype) insets:(UIEdgeInsets)value; { return [[self class] valueWithUIEdgeInsets:value]; }
+ (instancetype) transform:(CGAffineTransform)value; { return [[self class] valueWithCGAffineTransform:value]; }
+ (instancetype) boolean:(BOOL)value; { return value ? @YES : @NO; }
+ (instancetype) floatn:(float)value; { return @(value); }
+ (instancetype) intn:(int)value; { return @(value); }

+ (instancetype) range:(NSRange)value; { return [[self class] valueWithRange:value]; }

- (NSString *) typeString;
{
    return [NSString stringWithCString:self.objCType encoding:NSASCIIStringEncoding];
    
}
- (BOOL) isCGRect; {    return [self.typeString hasPrefix:@"{CGRect"]; }
- (BOOL) isCGPoint; {    return [self.typeString hasPrefix:@"{CGPoint"]; }
- (BOOL) isCGSize; {    return [self.typeString hasPrefix:@"{CGSize"]; }
- (BOOL) isUIEdgeInsets; {    return [self.typeString hasPrefix:@"{UIEdgeInset"]; }
- (BOOL) isFloat; {    return [self.typeString hasPrefix:@"f"]; }
- (BOOL) isInteger; {    return [self.typeString hasPrefix:@"q"]; }
- (BOOL) isTransform; {    return [self.typeString hasPrefix:@"{CGAffineTransform"]; }
- (BOOL) isRange; {    return [self.typeString hasPrefix:@"{_NSRange"]; }
- (BOOL) isBoolean; {    return [self.typeString hasPrefix:@"c"]; }
- (BOOL) isUnknown; {
    return !self.isBoolean
        && !self.isCGPoint
        && !self.isCGRect
        && !self.isCGSize
        && !self.isUIEdgeInsets
        && !self.isFloat
        && !self.isInteger
        && !self.isTransform
        && !self.isRange;
}

- (float) y; { return self.isCGPoint ? self.CGPointValue.y : self.isCGRect ? self.CGRectValue.origin.y : NAN; }
- (float) x; { return self.isCGPoint ? self.CGPointValue.x : self.isCGRect ? self.CGRectValue.origin.x : NAN; }
- (float) width; { return self.isCGSize ? self.CGSizeValue.width : self.isCGRect ? self.CGRectValue.size.width : NAN; }
- (float) height; { return self.isCGSize ? self.CGSizeValue.height : self.isCGRect ? self.CGRectValue.size.height : NAN; }
- (float) top; { return self.isUIEdgeInsets ? self.UIEdgeInsetsValue.top : NAN; }
- (float) left; { return self.isUIEdgeInsets ? self.UIEdgeInsetsValue.left : NAN; }
- (float) right; { return self.isUIEdgeInsets ? self.UIEdgeInsetsValue.right : NAN; }
- (float) bottom; { return self.isUIEdgeInsets ? self.UIEdgeInsetsValue.bottom : NAN; }
- (float) location; { return self.isRange ? self.rangeValue.location : NAN; }
- (float) length; { return self.isRange ? self.rangeValue.length : NAN; }
- (CGAffineTransform) transform; { return self.isTransform ? self.CGAffineTransformValue : CGAffineTransformUnknown; }

@end

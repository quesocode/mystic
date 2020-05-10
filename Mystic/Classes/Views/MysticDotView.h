//
//  MysticDotView.h
//  Mystic
//
//  Created by travis weerts on 8/8/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticColor.h"

@interface MysticDotView : UIView
@property (nonatomic, assign) UIEdgeInsets hitInsets;
+ (id) dot:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size;
+ (id) dot:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size borderWidth:(CGFloat)borderWidth;

- (id)initWithPoint:(CGPoint)point;
- (id)initWithPoint:(CGPoint)point color:(MysticColorType)colorType;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color;
- (id)initWithPoint:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size;
- (id)initWithPoint:(CGPoint)point color:(UIColor *)colorType size:(CGFloat)size borderWidth:(CGFloat)borderWidth;

- (id) connectTo:(MysticDotView *)otherDot color:(id)color;
@end

@interface MysticDotConnectionView : UIView

@property (nonatomic, assign) MysticDotView *dot1, *dot2;

+ (id) connect:(MysticDotView *)dot1 to:(MysticDotView *)dot2 color:(id)color;
- (id) initWithDot:(MysticDotView *)dot1 toDot:(MysticDotView *)dot2;


@end

//
//  MysticIcon.h
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "MysticImageIcon.h"

@class PackPotionOption;

CGPoint MyPoint(CGSize size, CGSize oldSize, CGPoint oldPoint);

@interface MysticIcon : UIView
+ (NSString *) name:(MysticIconType)iconType;
+ (BOOL) hasCustomColor:(id)iconTypeOrFilename;
+ (NSString *) name:(MysticIconType)iconType state:(UIControlState)state;

+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;

+ (void) draw:(UIImage *)img color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
+ (void) draw:(UIImage *)img color:(UIColor *)color context:(CGContextRef)context;
+ (void) draw:(UIImage *)img color:(UIColor *)color highlight:(UIColor *)highlight rect:(CGRect)rect bounds:(CGRect)bounds context:(CGContextRef)context;

+ (CGPathRef) drawIconType:(MysticIconType)type color:(UIColor *)color rect:(CGRect)rect context:(CGContextRef)context;
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType size:(CGSize)size color:(UIColor *)color backgroundColor:(id)bgColor;

+ (MysticImageIcon *) imageNamed:(NSString *)name colorType:(MysticColorType)colorType;
+ (MysticImageIcon *) imageNamed:(NSString *)name color:(UIColor *)color;

+ (MysticImageIcon *)roundedRect:(CGRect)rect color:(UIColor *)fillColor radius:(CGFloat)radius;
+ (MysticImageIcon *)roundedRect:(CGRect)rect color:(UIColor *)fillColor radii:(UIEdgeInsets)radii;

+ (MysticImageIcon *) image:(UIImage *)img color:(UIColor *)color;

+ (MysticIconType) iconTypeForObjectType:(MysticObjectType)objectType;
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType color:(UIColor *)color image:(UIImage *)image;
+ (MysticImageIcon *) iconForType:(MysticIconType)iconType color:(UIColor *)color;
+ (MysticImageIcon *) iconForSetting:(MysticObjectType)setting color:(id)color;
+ (MysticImageIcon *) iconForSetting:(MysticObjectType)setting size:(CGSize)size color:(id)color ;

+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option;
+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option color:(UIColor *)color;
+ (MysticImageIcon *) iconForOption:(PackPotionOption *)option type:(MysticIconType)iconType color:(UIColor *)color;

+ (MysticImageIcon *) iconWithNumber:(int)number size:(CGSize)size color:(UIColor *)color textColor:(UIColor *)textColor;

+ (MysticImageIcon *) iconForType:(MysticIconType)iconType size:(CGSize)size color:(UIColor *)color;


@property (nonatomic, retain) UIImage *customImage;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) MysticIconType type;
@property (nonatomic, assign) CGFloat padding;
+ (MysticIcon *) indicatorWithColorType:(MysticColorType)value size:(CGSize)theSize;
+ (MysticIcon *) indicatorWithColor:(UIColor *)value size:(CGSize)theSize;
+ (MysticIcon *) iconWithColor:(UIColor *)value type:(MysticIconType)theType size:(CGSize)theSize;
+ (MysticIcon *) customIconWithColor:(UIColor *)value type:(MysticIconType)theType size:(CGSize)theSize;

- (id) initWithFrame:(CGRect)frame color:(UIColor *)value type:(MysticIconType)theType;

@end

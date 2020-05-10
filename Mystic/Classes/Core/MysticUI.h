//
//  MysticUI.h
//  Mystic
//
//  Created by travis weerts on 12/8/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@class MysticBarButtonItem, MysticButton;

@interface MysticUI : NSObject





+ (BOOL) iphone5:(void (^)())iphone5Block iphone:(void (^)())iphoneBlock iPad:(void (^)())ipadBlock;
+ (BOOL) iphone5:(void (^)())iphone5Block iphone:(void (^)())iphoneBlock;
+ (BOOL) isIPhone5;
+ (CGRect) bounds;
+ (CGRect) pixelBounds;
+ (CGSize) size;
+ (CGSize) pixelSize;
+ (CGSize) screen;
+ (CGSize) pixelScreen;
+ (CGRect) frame;
+ (CGFloat) scale;
+(BOOL)isIPhone4;
+(BOOL)isRetinaFourInch;
+(BOOL)isRetinaiPhone6;
+(BOOL)isRetinaHDDisplay;
+(BOOL)isRetinaDisplay;
+(BOOL)isIOS8OrGreater;
+(BOOL)isIOS7OrGreater;
+(BOOL)isIOS5OrGreater;
+(BOOL)isIOS4_2OrGreater;
+(BOOL)isIPad;
+(BOOL)isIOS6OrGreater;
+ (void) layout:(NSArray *)views bounds:(CGRect)bounds mode:(MysticLayoutMode)layoutMode;


//+ (CGPathRef) roundedRectPath:(CGRect)rect radius:(CGFloat)radius;
+ (CGRect) normalRect:(CGRect)rect bounds:(CGRect)bounds;
+ (CGRect) translateNormalRect:(CGRect)rect bounds:(CGRect)bounds;
+ (CGSize) normalize:(CGSize)size normalValues:(CGSize)normal;
+ (CGRect) normalize:(CGSize)size bounds:(CGSize)bounds mode:(MysticStretchMode)stretchMode;
+ (CGRect) normalize:(CGRect)rect normalRect:(CGRect)normalr;

+ (CGSize) scaleSize:(CGSize)size bounds:(CGSize)bounds;
+ (CGSize) scaleDown:(CGSize)size scale:(CGFloat)scale;
+ (CGRect) scaleToFill:(CGRect)sizer bounds:(CGRect)bounds;
+ (CGRect) scaleRect:(CGRect)rect scale:(CGFloat)scale;
+ (CGRect) scaleHeight:(CGRect)sizerect width:(CGFloat)_width;
+ (CGRect) scaleWidth:(CGRect)sizerect height:(CGFloat)_height;
+ (CGFloat) heightToWidth:(CGSize)sized;
+ (CGFloat) widthToHeight:(CGSize)sized;
+ (CGRect) cloneRectangle:(CGRect)maxRect;
+ (CGRect) aspectFit:(CGRect)rect bounds:(CGRect)maxRect;
+ (CGPoint) scalePoint:(CGPoint)point scale:(CGFloat)scale;
+ (NSString *) stringFromRect:(CGRect)rect;
+ (NSString *) stringFromSize:(CGSize)size;

+ (CGRect) rectWithSize:(CGSize)size;
+ (CGRect) rectWithPoint:(CGPoint)point;
+ (CGSize) scaleSize:(CGSize)size scale:(CGFloat)scale;
+ (CGRect) positionRect:(CGRect)rect inBounds:(CGRect)bounds position:(MysticPosition)position;
+ (void) printFrameOfView:(UIView*)node;
+ (void) printFrameOfView:(UIView*)node depth:(int)d maxDepth:(int)max;
+ (void) setBackgroundColorOfViewTree:(UIView *)view color:(UIColor *)bgcolor;



+ (CGFloat) linearStep:(CGFloat)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInOutQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeOutQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInQuadStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeOutExpoStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInExpoStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInQuartStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInQuintStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInCircStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInSineStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;

+ (CGFloat) easeInCubicStep:(NSTimeInterval)step start:(CGFloat)startValue end:(CGFloat)endValue totalSteps:(NSTimeInterval)totalSteps;



+ (UIImage *) buttonBgImageNamed:(NSString *)imageName;

+ (UIFont *) gotham:(CGFloat)size;
+ (UIFont *) gothamLight:(CGFloat)size;
+ (UIFont *) gothamBold:(CGFloat)size;
+ (UIFont *) gothamMedium:(CGFloat)size;
+ (UIFont *) gothamBook:(CGFloat)size;
+ (UIFont *) font:(CGFloat)size;
+ (UIFont *) fontBold:(CGFloat)size;




+ (MysticButton *) forwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (MysticButton *) backButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (MysticButton *) backButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (MysticButton *) forwardButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (MysticButton *) confirmButton:(MysticBlockSender) action;
+ (MysticButton *) cancelButton:(ActionBlock) action;
+ (MysticButton *) buttonWithImage:(UIImage *)image action:(ActionBlock)action;
+ (MysticButton *) buttonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
+ (MysticButton *) buttonWithTitle:(NSString *)title action:(MysticBlock)action;
+ (MysticButton *) buttonWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (MysticButton *) button:(id)titleOrImg action:(MysticBlockSender)action;
+ (MysticButton *) confirmButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) cancelButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) buttonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (MysticButton *) buttonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (MysticButton *) clearButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (MysticButton *) clearButtonWithImage:(UIImage *)image action:(ActionBlock)action;
+ (MysticButton *) moreSettingsButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) camButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) slideOutButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) closeButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) downArrowButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) dotsButtonWithTarget:(id)target sel:(SEL)action;
+ (MysticButton *) switchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
+ (MysticButton *) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
+ (MysticButton *) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
+ (MysticButton *) slideOutButton:(ActionBlock)action;
+ (MysticButton *) camButton:(ActionBlock)action;
+ (MysticButton *) closeButton:(ActionBlock)action;
+ (void) resizeButton:(MysticButton *)button;


+ (MysticBarButtonItem *) barButtonItem:(ActionBlock) action;
+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title action:(ActionBlock)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) confirmButtonItem:(MysticBlockSender) action;
+ (MysticBarButtonItem *) cancelButtonItem:(ActionBlock) action;
+ (MysticBarButtonItem *) barButtonItemWithImage:(UIImage *)image action:(ActionBlock) action;
+ (MysticBarButtonItem *) backButtonItem:(id)titleOrImg action:(ActionBlock)action;
+ (MysticBarButtonItem *) forwardButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title action:(ActionBlock)action;
+ (MysticBarButtonItem *) forwardButtonItem:(id)titleOrImg action:(ActionBlock)action;
+ (MysticBarButtonItem *) backButtonItem:(ActionBlock) action;
+ (MysticBarButtonItem *) backButtonItemWithTarget:(id)target action:(SEL)action;
+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) buttonItem:(id)titleOrImg senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) confirmButtonItemWithTarget:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) cancelButtonItemWithTarget:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) clearButtonItemWithImage:(UIImage *)image action:(ActionBlock)action;
+ (MysticBarButtonItem *) clearSwitchButtonItemTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
+ (MysticBarButtonItem *) slideOutButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) emptyItem;
+ (MysticBarButtonItem *) closeButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) camButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) infoButtonItem:(MysticBlockSender)action;
+ (MysticBarButtonItem *) questionButtonItem:(MysticBlockSender)action;




@end

//
//  MysticTipView.h
//  Mystic
//
//  Created by Travis A. Weerts on 5/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticBlurBackgroundView.h"
#import "MysticCommon.h"




@interface MysticTipView : UIView
@property (nonatomic, assign) UIView *targetView, *container;
@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) MysticPosition position, arrowPosition;
@property (nonatomic, assign) NSAttributedString *message;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) CGPoint arrowOffset, offset;
@property (nonatomic, assign) BOOL automaticallyHide, animated, hideOnTouch;
@property (nonatomic, assign) MysticAccessoryType accessoryType;
@property (nonatomic, assign) MysticBlurBackgroundView *backgroundView;
@property (nonatomic, assign) NSTimeInterval autoHideAfter;

@property (nonatomic, assign) UILabel *titleLabel, *messageLabel;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
+ (BOOL) tip:(NSString *)key inView:(UIView *)view targetView:(UIView *)targetView offsetArrow:(CGPoint)offset hideAfter:(NSTimeInterval)hideAfter delay:(NSTimeInterval)delay animated:(BOOL)animated;

+ (instancetype) tip:(NSString *)title message:(NSAttributedString *)message inView:(UIView *)view targetView:(UIView *)targetView;
+ (instancetype) tip:(NSString *)key inView:(UIView *)view targetView:(UIView *)targetView hideAfter:(NSTimeInterval)hideAfter delay:(NSTimeInterval)delay animated:(BOOL)animated;

+ (instancetype) tipWithTitle:(NSString *)title message:(NSAttributedString *)message point:(CGPoint)point;
- (void) hide;
- (void) hide:(BOOL)animated;
@end
@interface MysticTipsView : UIView

@end
@interface MysticTipViewManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *tips;
@property (nonatomic, strong) NSMutableDictionary *tipsShown;
@property (nonatomic, strong) NSMutableArray *tipsOrder;
@property (nonatomic, strong) MysticTipsView *tipsView;
+ (instancetype) manager;
+ (id) set:(id)key tip:(MysticTipView *)tip;
+ (id) add:(MysticTipView *)tip;
+ (id) tip:(id)key;
+ (id) remove:(MysticTipView *)tip;
+ (MysticTipView *) lastTip;
+ (void) removeLastTip;
+ (void) hide:(id)key animated:(BOOL)animated;
+ (void) hideAll;
+ (void) hide:(id)key;
+ (BOOL) tipHasBeenShown:(id)key;
+ (void) resetTips;
+ (void) hideAll:(BOOL)animated;
+ (void) hideLast;
+ (void) hideLast:(BOOL)animated;
+ (void) hideAll:(BOOL)animated except:(id)exceptions;

@end


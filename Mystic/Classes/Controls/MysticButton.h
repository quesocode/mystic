//
//  MysticButton.h
//  Mystic
//
//  Created by travis weerts on 3/7/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MysticConstants.h"
#import "UIView+Mystic.h"




@interface MysticButton : UIButton
@property (nonatomic, retain) NSMutableDictionary *borderControlStates, *buttonWidthStates;
@property (nonatomic, retain) id touchTarget;
@property (nonatomic, assign) SEL touchAction;
@property (nonatomic, assign) UIControlEvents touchEvents;
@property (nonatomic, assign) BOOL canSelect, continueOnHold, touchUpCancelsDown, ignoreUserActions;
@property (nonatomic, assign) MysticPosition buttonPosition;
@property (nonatomic, assign) NSTimeInterval holdingInterval, holdingDelay;
@property (nonatomic, copy) MysticBlockButton stateBlock;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) MysticColorType selectedColorType;
@property (nonatomic, retain) UIColor *selectedBackgroundColor, *normalBackgroundColor;
@property (nonatomic, assign) CGPoint positionOffset;
@property (nonatomic, assign) UIEdgeInsets hitInsets;
@property (nonatomic, assign) MysticToolType toolType;
@property (nonatomic, assign) MysticAlignPosition imageAlignment;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) BOOL cancelsEvents, userCausedAction, hasUserCausedAction, resetsUserAction, userSelected;
@property (nonatomic, assign) MysticObjectType objectType;
+ (CGFloat) buttonHeight;
- (void) setSelected:(BOOL)selected resetUser:(BOOL)shouldResetUser;

- (id) handleControlEvent:(UIControlEvents)event
                               withBlock:(ActionBlock) action;
- (id) handleControlEvent:(UIControlEvents)event
                         withBlockSender:(MysticBlockSender) action;
- (id) handleTouchAndHoldForDuration:(NSTimeInterval)duration action:(MysticBlockSender)action;
- (id) handleDoubleTapEvent:(MysticBlockSender) action;

- (void) clear;

- (void) setBackgroundColor:(id)backgroundColor forState:(UIControlState)forState;
- (void) setBorderColor:(id)borderColor forState:(UIControlState)forState;
- (void) setWidth:(CGFloat)width forState:(UIControlState)forState;

- (void) commonInit;
- (void) tap;
- (void) run;

+ (UIImage *) buttonBgImageNamed:(NSString *)imageName;
+ (instancetype) buttonWithAttrStr:(NSAttributedString *)title target:(id)target action:(SEL)action;

+ (instancetype) backButton:(MysticBlockSender)action;
+ (instancetype) forwardButton:(MysticBlockSender)action;
+ (instancetype) forwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) blueForwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) backButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) backButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (instancetype) forwardButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (instancetype) confirmButton:(MysticBlockSender) action;
+ (instancetype) cancelButton:(MysticBlockSender) action;
+ (instancetype) buttonWithImage:(UIImage *)image action:(ActionBlock)action;
+ (instancetype) buttonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
+ (instancetype) buttonWithTitle:(NSString *)title action:(MysticBlock)action;
+ (instancetype) buttonWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (instancetype) button:(id)titleOrImg action:(MysticBlockSender)action;
+ (instancetype) confirmButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) cancelButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) blueButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) buttonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) buttonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (instancetype) whiteButtonWithTitle:(NSString *)title action:(ActionBlock)action;
+ (instancetype) clearButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
+ (instancetype) clearButtonWithImage:(UIImage *)image action:(ActionBlock)action;
+ (instancetype) clearButtonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
+ (instancetype) moreSettingsButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) camButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) slideOutButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) closeButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) downArrowButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) dotsButtonWithTarget:(id)target sel:(SEL)action;
+ (instancetype) switchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
+ (instancetype) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
+ (instancetype) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
+ (instancetype) slideOutButton:(ActionBlock)action;
+ (instancetype) camButton:(ActionBlock)action;
+ (instancetype) closeButton:(ActionBlock)action;
+ (void) resizeButton:(MysticButton *)button;
+ (instancetype) button:(id)titleOrImg target:(id)target sel:(SEL)action;
+ (instancetype) buttonWithAttrStr:(NSAttributedString *)title senderAction:(MysticBlockSender)action;


+ (instancetype) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType target:(id)target action:(SEL)action;

+ (instancetype) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType action:(MysticBlockSender)action;

+ (instancetype) moreButton:(MysticBlockSender)action;
+ (instancetype) moreButton:(id)target action:(SEL)action;



@end

@interface MysticButtonSelectable : MysticButton

@end
@interface MysticButtonBorderAlign : MysticButtonSelectable

@end

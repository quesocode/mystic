//
//  SubBarButton.h
//  Mystic
//
//  Created by travis weerts on 1/28/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticButton.h"

@interface SubBarButtonBackgroundView : UIView
{
    
}
@property (nonatomic, assign) BOOL selected, showDots, alignDotsOnTop;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, assign) MysticObjectType type;
@property (nonatomic, retain) NSArray *types;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end


@interface SubBarButton : UIControl
{
    
}
@property (nonatomic, retain) NSArray *controlStates;
@property (nonatomic, retain) SubBarButtonBackgroundView *bgView;
@property (nonatomic, assign) MysticObjectType type, objectType, setting;
@property (nonatomic, assign) int controlStateNormal, controlState;
@property (nonatomic, assign) BOOL isFirst, isLast, active, adjustsImageWhenHighlighted, adjustsImageWhenDisabled, allowSelect, debug, canUnselect, toggleSelected;
@property (nonatomic, assign) CGFloat rightOffset, leftOffset, radius, maxImageHeight, labelHeight, titleIconSpacing;
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets, contentInsets;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign) MysticColorType activeColorType, selectedColorType, normalColorType;
@property (nonatomic, retain) NSMutableDictionary *states;
@property (nonatomic, retain) UIColor *rootColor;
@property (nonatomic, readonly) NSArray *types;
@property (nonatomic, assign) NSInteger tabIndex;
@property (nonatomic, assign) MysticColorType iconColorType;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, readonly) BOOL hasControlStates;
+ (id) buttonWithType:(UIButtonType)type frame:(CGRect)frame showTitle:(BOOL)showTitle;
+ (CGFloat) maxImageHeight;
- (void) nextControlState;
- (UIImage *) imageForState:(UIControlState)thestate;

-(MysticButton *) handleControlEvent:(UIControlEvents)event
                           withBlock:(ActionBlock) action;
-(MysticButton *) handleControlEvent:(UIControlEvents)event
                     withBlockSender:(MysticBlockSender) action;
- (MysticButton *) handleTouchAndHoldForDuration:(NSTimeInterval)duration action:(MysticBlockSender)action;
- (id)initWithFrame:(CGRect)frame showTitle:(BOOL)showTitle;

- (void) clear;
- (void) setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void) setImage:(UIImage *)image forState:(UIControlState)state;
- (void) setTitle:(NSString *)title forState:(UIControlState)state;

+ (SubBarButton *) buttonWithType:(UIButtonType)type;
- (Class) backgroundViewClass;
+ (UIFont *) labelFont;
+ (UIEdgeInsets) contentInsets;
- (CGRect) setImageViewFrame:(CGRect)newFrame;
- (void) setActive:(BOOL)isActive animated:(BOOL)animated;
- (void) showAsSelected:(BOOL)doselected;
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)thestate;
- (UIColor *) titleColorForState:(UIControlState)thestate;


@end

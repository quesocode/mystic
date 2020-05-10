//
//  EffectControl.h
//  Mystic
//
//  Created by travis weerts on 12/8/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "GPUImage.h"
#import "EffectControlProtocol.h"
#import "MysticPageControl.h"

@class EffectObject, EffectControl;



@interface EffectControl : UIControl

@property (nonatomic, retain) MysticImageView *imageView, *selectedOverlayView;
@property (nonatomic, retain) MysticView *backgroundView;
@property (nonatomic, retain) UIView *accessoryView;

@property (nonatomic, readonly) UIButton *settingsButton, *cancelButton;
@property (nonatomic, retain) MysticControlObject *effect;
@property (nonatomic, readonly) PackPotionOption *option;
@property (nonatomic, retain) PackPotionOption *targetOption;
@property (nonatomic, readonly) UIColor *currentBackgroundColor;
@property (nonatomic, retain) MysticPageControl *pageControl;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIView *renderView;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, readonly) NSInteger visiblePosition;
@property (nonatomic, readonly) UIScrollView * scrollView;
@property (nonatomic, assign) id <EffectControlDelegate> delegate;
@property (nonatomic, assign) BOOL cancelsEffect, isLast, isFirst, wasSelected;
@property (nonatomic, assign) BOOL showLabel, showCancel;
@property (nonatomic, readonly, getter = isActive) BOOL active;
@property (nonatomic, readonly) BOOL hasBackgroundView, hasImageView, hasSelectedOverlayView;

@property (nonatomic, assign) BOOL selectable, updatesSiblingsOnChange;
@property (nonatomic, assign) BOOL deselectable;
@property (nonatomic, copy) EffectContolAction action;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, readonly) CGRect contentFrame;
@property (nonatomic) NSInteger position;

- (void) touchedEffect;
- (void) touchedUpEffect;

- (void) showAsSelected:(BOOL)isSelected;
- (void) showAsSelected;
+ (CGFloat) overlayNippleHeight;
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction margin:(CGFloat)margins;

- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction;
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex action:(EffectContolAction)anAction marginInsets:(UIEdgeInsets)marginInsets;

- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject action:(EffectContolAction)anAction;
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject;
- (id)initWithFrame:(CGRect)frame effect:(MysticControlObject *)effectObject position:(NSInteger)theIndex;
- (void) setCornerRadius:(CGFloat)radius;
- (void) updateSiblings:(BOOL)willSelect;
- (void) didTouchDown:(id) sender;
- (void) updateLabel:(BOOL)isSelected;
- (void) didTouchUpInside:(id) sender;
- (void) toggle;
- (void) reuse;
- (void) prepare;
- (void) viewDidBecomeActive;
- (void) viewDidBecomeInactive;
- (void) setSuperSelected:(BOOL)isSelected;
- (void)stateWasUpdated;
- (void) updateControl;
- (void) accessoryTouched:(id)sender;
- (void) setAccessoryView:(UIView *)accessoryView center:(CGPoint)newCenter;

@end



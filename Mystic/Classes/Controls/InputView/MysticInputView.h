//
//  MysticInputView.h
//  Mystic
//
//  Created by Me on 11/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticBarColorButton.h"
#import "MysticToolbarTitleButton.h"
#import "ILColorPickerView.h"

@class PackPotionOptionFont, PackPotionOption;

@protocol MysticInputViewDelegate;
@interface MysticInputView : UIView
@property (nonatomic, assign) MysticInputType type;
@property (nonatomic, assign) MysticObjectType setting;
@property (nonatomic, assign) MysticColorType colorType;
@property (nonatomic, retain) ILColorPickerView *picker;
@property (nonatomic, assign) ColorPickerMode colorPickerMode;
@property (nonatomic, assign) CGFloat colorAlpha;
@property (nonatomic, retain) UIColor *color, *oldColor, *colorAndPicker;
@property (nonatomic, assign) UIColor *oldColorBtnColor, *currentColorBtnColor;
@property (nonatomic, assign) BOOL sendFinished, sendDelegateMethods, hasOldColor, touchesEnded;

@property (nonatomic, assign) MysticThreshold threshold;
@property (nonatomic, retain) MysticBarColorButton *oldColorBtn, *currentColorBtn;
@property (nonatomic, copy) MysticBlockInput finished, changed, refresh, update;
//@property (nonatomic, copy) MysticBlockObjObjObjBOOL finishedBoth, changedBoth, refreshBoth, updateBoth;

@property (nonatomic, assign) CGRect keyboardRect, inputFrame;
@property (nonatomic, retain) PackPotionOptionFont *fontOption, *font;
@property (nonatomic, assign) CGPoint selectedColorPoint;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, readonly) MysticButton *confirmBtn;
@property (nonatomic, retain) PackPotionOption *targetOption;
@property (nonatomic, retain) UIView *toolbar;
@property (nonatomic, retain) MysticToolbarTitleButton *hexLabel;
@property (nonatomic, retain) UIImageView *toolbarNipple;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSString *title, *selectedColorTitle, *selectedColorWithColorTitle;
@property (nonatomic, assign) BOOL allowEyeDropper, showHexValues, showColorTools, showRemoveButton, showColors, showToolbarBorder, showNewButton, showDropper;
@property (nonatomic, assign) NSInteger selectedColorIndex;
@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, assign) MysticButton *removeBtn,*addBtn,*pickColorBtn;

@property (nonatomic, assign) id <MysticInputViewDelegate> delegate;
+ (void) addUserColor:(id)color;
+ (NSArray *) userColors;
+ (id) showInView:(UIView *)view type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
+ (id) inputView:(UIView *)view type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
+ (id) inputView:(UIView *)view title:(NSString *)title type:(MysticInputType)inputType finished:(MysticBlockInput)finished;
- (id) initWithFrame:(CGRect)frame title:(NSString *)title;

- (void) showInView:(UIView *)view type:(MysticInputType)inputType;
- (void) dismiss;
- (UIView *) makeInputAccessoryView;
- (void) toolbarDone:(id)sender;
- (void) hideAddBtn:(BOOL)animated;

- (void) showAddBtn:(BOOL)animated;

- (void) hideRemoveBtn:(BOOL)animated;

- (void) showRemoveBtn:(BOOL)animated;

- (void) hideControl:(UIView *)control animated:(BOOL)animated;

- (void) showControl:(UIView *)control animated:(BOOL)animated;

@end


@protocol MysticInputViewDelegate <NSObject>

@optional


- (void) inputViewChangedThreshold:(MysticInputView *)inputView picker:(ILControl *)picker;
- (void) inputViewTouchesBegan:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) inputViewTouchesMoved:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) inputViewTouchesEnded:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
- (void) inputViewTouchesCancelled:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;

- (void) inputViewFinished:(MysticInputView *)inputView;
- (void) inputViewSwitchedMode:(MysticInputView *)inputView;
- (void) inputViewDismissed:(MysticInputView *)inputView;
- (void) inputViewDidShow:(MysticInputView *)inputView;
- (void) inputViewSelectedColorTouched:(MysticInputView *)inputView ;
- (void) inputViewColorTouched:(MysticInputView *)inputView ;
- (void) inputViewRemoveTouched:(MysticInputView *)inputView ;
- (void) inputViewRemoveAllTouched:(MysticInputView *)inputView ;

- (void) inputViewNewTouched:(MysticInputView *)inputView ;

- (void) inputViewSetColor:(MysticInputView *)inputView finished:(BOOL)finished;
- (void) inputViewSetSelectedColor:(MysticInputView *)inputView finished:(BOOL)finished;

- (NSInteger) inputViewNumberOfColors:(MysticInputView *)inputView ;
@end


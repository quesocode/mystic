//
//  MysticLayerEditViewController.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/19/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticViewController.h"
#import "MysticTransView.h"
#import "MysticTouchView.h"
#import "MysticDrawView.h"
#import "MysticNippleView.h"

@class MysticLayerEditViewController, PackPotionOptionView, MysticLayerToolbar,  MysticLayerBaseView, MysticChoice, MysticHiddenTextField;

@protocol MysticLayerEditViewControllerDelegate <NSObject>

@required

- (void) layerEditViewController:(MysticLayerEditViewController *)controller didChooseContent:(id)content;

- (void) layerEditViewControllerDidCancel:(MysticLayerEditViewController *)controller;


@end



@class MysticPack, ILColorPickerView, MysticControlObject;

@interface MysticLayerEditViewController : MysticViewController
{
    id _content;
    BOOL _updateLayerShadow;
    BOOL _updateContent;
    BOOL releaseHiddenText;
    BOOL settingUpInput;
    BOOL settingContentOffset, _setupPresentView;

}
@property (retain, nonatomic) MysticTransView *transView;
@property (nonatomic, retain) PackPotionOptionView *option;
@property (nonatomic, assign) id <MysticLayerEditViewControllerDelegate> delegate;
@property (nonatomic, assign) CGAffineTransform originalTransform;

@property (nonatomic, assign) CGRect keyboardRect, originalClipViewFrame;
@property (nonatomic, retain) id content;
@property (nonatomic, copy) MysticBlockAnimation animationIn, animationOut;
@property (nonatomic, assign) MysticChoice *choice;
@property (nonatomic, retain) IBOutlet MysticHiddenTextField *hiddenTextField;
@property (nonatomic, retain) MysticPack *pack;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, retain) MysticNippleView *nippleView, *toolbarNippleView;
@property (nonatomic, retain) MysticLayerToolbar *toolbar, *subToolbar;
@property (nonatomic, retain) MysticLayerBaseView *layerView;
@property (nonatomic, retain) MysticTouchView *touchView;
@property (nonatomic, assign) CGPathRef shadowPath;
@property (nonatomic, assign) UIEdgeInsets inputFrameInsets;
@property (nonatomic, retain) UIColor *color, *shadowColor, *backgroundColor;
@property (nonatomic, assign) CGSize startSize, endSize, contentSizeChangeScale, shadowOffset;
@property (nonatomic, readonly) CGRect previewFrame, previewFrameInset, inputFrame;
@property (nonatomic, assign) BOOL updateContent, userTappedBg, stopAutoScroll, shouldResizeContent;
@property (nonatomic, assign) MysticObjectType setting, subSetting;
@property (nonatomic, assign) MysticColorInputOptions colorInputOptions;
@property (nonatomic, assign) float colorAlpha, shadowAlpha, shadowRadius;
@property (nonatomic, assign) MysticSlider *opacitySlider, *blurSlider, *widthSlider;
@property (nonatomic, assign) MysticPosition position;
@property (nonatomic, retain) NSArray *contentChoices;
@property (nonatomic, retain) UIView *presentView, *colorChip, *inputView;
- (id) initWithContent:(id)content;
- (void) commonInit;
- (void) presentInView:(UIView *)view fromView:(UIView *)fromView;
- (void) unloadViews;
- (void) dismissToView:(UIView *)fromView animations:(MysticBlockAnimationInfo)animations complete:(MysticBlockBOOL)finished;
- (UIView *) inputView:(MysticIconType)iconType;
- (BOOL) toggleFadeBgColor:(BOOL)animated sender:(id)sender;
- (void) fadeOutBgColor:(BOOL)animated sender:(id)sender;
- (void) fadeInBgColor:(BOOL)animated sender:(id)sender;
- (void) updateViews;
- (void) updateViews:(NSArray *)shadowViews debug:(id)debug;
-(void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker;
- (void) effectControlDidTouchUp:(UIControl *)effectControl effect:(MysticControlObject *)effect;
- (void) moveNipple:(CGFloat)x completion:(MysticBlockAnimationFinished)complete;
- (void) resetPreviousInputView:(MysticIconType)iconType;

@end

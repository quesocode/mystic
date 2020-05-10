//
//  MysticViewController.h
//  Mystic
//
//  Created by travis weerts on 1/26/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "MysticGestureView.h"
#import "ImageControlsViewController.h"
#import "GPUImage.h"
#import "Mystic.h"
#import "UIViewController+MMDrawerController.h"
#import "BottomToolbar.h"
#import "BottomBar.h"
#import "EffectControl.h"
#import "MysticSlider.h"
#import "MysticPhotoContainerView.h"
#import "MysticTextField.h"
#import "MysticLippedView.h"
#import "MysticBottomLipView.h"
#import "MysticToggleButton.h"
#import "MysticDotView.h"
#import "MysticTabBar.h"
#import "MysticOptionsProtocol.h"
#import "EffectControlProtocol.h"
#import "MysticTabBarProtocol.h"
#import "MysticShapesView.h"
#import "MysticProgressHUD.h"
#import "MysticFontStylesViewController.h"
#import "MysticLayerPanelViewController.h"
#import "MysticNavigationViewController.h"
#import "MysticPanelView.h"
#import "MysticShapesViewController.h"
#import "MysticShapesOverlaysView.h"
#import "Mystic-Swift.h"
#import "MysticInputView.h"
#import "MysticPointColorBtn.h"
#import "MysticCanvasController.h"
#import "CKRadialMenu.h"
#import "MysticTipView.h"
#import "WDLabel.h"
#import "UIView+Additions.h"
#import "WDActionNameView.h"

@class MysticLabelsView, MysticScrollView, MysticDrawerViewController, MysticOptionsDelegate, MysticTabBar, MysticLayerPanelViewController, MysticPickerViewController;

@interface MysticController : ImageControlsViewController <EffectControlDelegate, MysticProgressHUDDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, MysticOptionsDelegate, MysticTabBarDelegate, CKRadialMenuDelegate, WDActionNameViewDelegate>
{
    CGFloat mCurrentScale, mLastScale, lastScale, mPreCurrentScale;
    CGPoint panLastPoint, panStartPoint, panEndPoint, panDeltaPoint, pinLastPoint, pinLastAnchor, pinOriginalPoint, finalAnchor;
    CGFloat firstX, firstY;
    BOOL outputDebug;
    MysticButtonType firstOptionButtonType;
    UIView *debugView;
    
    NSMutableArray *dots;
}
@property (nonatomic, retain) MysticPickerViewController *customImagePicker;
@property (nonatomic, retain) UIView *undoRedoTools;
@property (nonatomic, retain)  MysticMessage                 *messageLabel;
@property (nonatomic, retain) NSTimer *messageTimer, *imageMessageTimer;
@property (nonatomic, retain) WDActionNameView *imageMessageView;
@property (nonatomic, retain) MysticCanvasController *canvasController;
@property (nonatomic, readonly)                      MysticDrawerViewController *drawer;
@property (nonatomic, assign) MMDrawerSide currentOpenSide;
@property (nonatomic, assign) MysticInputView *activeInputView;
@property (nonatomic, assign) MysticPointColorBtn *dropper;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) MysticObjectType currentSetting, lastSetting, parentSetting, extraControlsSetting;
@property (nonatomic, retain) MysticLayerPanelView *layerPanelView;

@property (nonatomic, assign) MysticObjectType launchState;
@property (nonatomic, readonly) MysticObjectType parentSettingType;
@property (nonatomic, copy) MysticBlockAnimationCompleteForward preReloadImageBlock;
@property (nonatomic, retain) IBOutlet MysticTabBar *tabBar, *addTabBar;
@property (nonatomic, retain) IBOutlet BottomToolbar *bottomToolbar;
@property (nonatomic, retain) IBOutlet MysticPhotoContainerView *imageView;
@property (retain, nonatomic) IBOutlet MysticGestureView *overlayView;
@property (nonatomic, retain) IBOutlet MysticPanelView *bottomPanelView;
@property (nonatomic, retain) MysticFontStylesViewController *fontStylesController;
@property (nonatomic, assign) MysticFontOverlaysView *labelsView;
@property (nonatomic, retain) MysticShapesViewController *shapesController;
@property (nonatomic, assign) MysticShapesOverlaysView *shapesView;
@property (nonatomic, retain) CanvasMaskView *sketchView;
@property (nonatomic, retain) UIView *testImageBlurView;
@property (nonatomic, retain) UIImageView *testImageView;
@property (nonatomic, retain) MysticPack *activePack;
@property (nonatomic, retain) PackPotionOption *transformOption;
@property (nonatomic, retain) NSMutableDictionary *activePacks;
@property (nonatomic, assign) CGSize previewSize;
@property (nonatomic, retain) MysticButton *navCenterView, *navLeftView, *navRightView;
@property (nonatomic, retain) UIImage *blurImage;
@property (nonatomic, assign) BOOL isMenuVisible, isNavViewVisible, areGesturesEnabled, readyForRenderEngine, preventMessages;

@property (nonatomic, retain) MysticLayerPanelViewController *layerPanelController;
@property (nonatomic, readonly) CGRect imageFrame, imageVisibleFrame;
@property (nonatomic, readonly) CGFloat navViewHeight;

@property (nonatomic, retain) NSMutableArray *photoInfo;
@property (nonatomic, assign) BOOL createNewObject, preventToolsFromBeingVisible;
@property (nonatomic, readonly) NSArray *transformViews;

@property (nonatomic, readonly) NSArray *layersViews;
@property (nonatomic, retain) NSMutableArray *info, *extraControls;
@property (nonatomic, assign) UIView *extraContainer;
+ (void) controller:(id)value;
+ (UIImage *) screenShot;
+ (UIImage *) screenShot:(BOOL)includeBars;
+ (UIImage *) screenShot:(BOOL)includeBars renderedImage:(UIImage *)renderedImage rect:(CGRect)inRect tintColor:(UIColor *)tintColor  complete:(MysticBlockObjObjBOOL)finishedScreenShot;

+ (MysticController *) controller;
- (void) updateVignetteDots;
- (void) removeExtraControls;
- (void) removeExtraControlsExcept:(NSArray *)exceptions;

+ (void) setNeedsDisplay;
- (void) hideHUD;
- (void) resetInterface:(MysticBlockObjBOOL)finished;
- (void) updateConfig;
- (void) updateConfig:(BOOL)forceDownload complete:(MysticBlockBOOL)completed;
- (void) showImageMessage:(NSArray *)images title:(NSString *)title message:(NSString *)message;
- (void) hideImageMessage:(NSTimer *)timer;
- (void) hideMessage:(NSTimer *)timer;
- (void) showMessage:(NSString *)message;
- (void) logMenuItemClicked:(id)sender;

- (void)pinched:(UIPinchGestureRecognizer *)sender;
- (void)panned:(UIPanGestureRecognizer *)sender;
- (void) doubleTapped:(UITapGestureRecognizer *)sender;
- (void) runViewIsReady;

- (void) revealPlaceholderImage:(UIImage *)image;
- (void) revealPlaceholderImage:(UIImage *)image duration:(NSTimeInterval)dur;


- (CGRect) setImageViewFrame:(CGRect)newImageViewFrame insets:(UIEdgeInsets)insets offset:(CGPoint)offset;

- (MysticProgressHUD *) showHUD:(NSString *)message checked:(id)checked;

- (MysticProgressHUD *) HUD;

- (CGRect) refreshImageViewFrame:(MysticBlockBOOL)finished;
- (CGRect) refreshImageViewFrameDuration:(NSTimeInterval)animDuration complete:(MysticBlockBOOL)finished;
- (CGRect) insetImageView:(UIEdgeInsets)insets complete:(MysticBlockBOOL)finished;
- (CGRect) insetImageView:(UIEdgeInsets)insets duration:(NSTimeInterval)animDuration complete:(MysticBlockBOOL)finished;


- (void) openProject:(MysticProject *)project complete:(MysticBlockObjBOOL)finished;
- (void) info:(NSArray *)info ready:(MysticBlockSender)finished;

- (void) setInfo:(NSArray *)info reset:(BOOL)shouldReset finished:(MysticBlock)finished;

- (void) setInfo:(NSArray *)info finished:(MysticBlock)finished;
- (void) recrop;
- (id)initWithNibName:(NSString *)nibNameOrNil images:(NSArray *)userInfo;
- (void) pick:(MysticPickerSourceType)sourceType finished:(MysticBlock)finished;

- (void) reloadImageInBackground:(BOOL)useHUD;
- (void) reloadImageInBackground:(BOOL)useHUD settings:(MysticRenderOptions)settings;
- (void) reloadImageInBackground:(BOOL)useHUD settings:(MysticRenderOptions)settings complete:(MysticBlockImageObjOptions)finished;

- (void) reload:(id)useHUD;
- (void) reload:(id)useHUD complete:(MysticBlockImageObjOptions)finished;
- (void) reloadImage:(BOOL)useHUD;
- (void) reloadImage:(BOOL)useHUD complete:(MysticBlockImageObjOptions)finished;
- (void) reload:(id)useHUD hudDelay:(NSTimeInterval)hudDelay complete:(MysticBlockImageObjOptions)finished;
- (void) reloadImageWithMsg:(id)useHUD placeholder:(UIImage *)placeholder hudDelay:(NSTimeInterval)hudDelay complete:(MysticBlockImageObjOptions)finished;
- (void) setTestImage:(UIImage *)image;
- (void) showSketchView:(MysticSketchToolType)type;
- (void) hideSketchView;
- (UIImage *) getSketchImage;
- (void) sketchImageIsDone;

-(IBAction)sliderValueChanged:(MysticSlider *)sender;
- (void)sliderEditingDidEnd:(MysticSlider *)sender;
- (void) refreshState:(NSDictionary *)newUserInfo;
- (void) refreshState:(MysticObjectType)state info:(NSDictionary *)newInfo;
- (void) setState:(MysticObjectType)state info:(NSDictionary *)userInfo;
- (void) setState:(MysticObjectType)state animated:(BOOL)animated complete:(void (^)())finished;
- (void) setStateConfirmed:(MysticObjectType)state animated:(BOOL)animated info:(NSDictionary *)userInfo complete:(void (^)())finishedState;
- (void) setLeftButton:(id)btns animate:(BOOL)animate;
- (void) setRightButton:(id)btns animate:(BOOL)animate;
- (void) refreshPack:(BOOL)reloadControls;
- (void) loadPack:(MysticPack *)pack info:(NSDictionary *)userInfo scrollView:(MysticScrollView *)scrollView complete:(MysticBlock)completed;
- (void) loadPack:(MysticPack *)pack info:(NSDictionary *)userInfo controls:(NSArray *)controls scrollView:(MysticScrollView *)scrollView complete:(MysticBlock)completed;
- (void) setupDrawerState;
//- (void) setupGestures:(MysticObjectType)state disable:(BOOL)disableGestures;
- (void) drawerScrolled:(CGPoint)drawerOffset;
- (void) toggleMoreToolsShow;

- (void) toggleMoreToolsHide;
//- (void) updateBlurViews;
- (void) refreshBlurImage;
- (BOOL) activatePack:(MysticPack *)pack;
- (MysticPack *) currentOptionPack:(PackPotionOption *)targetOption;

- (void) setNeedsDisplay;


- (void) showPackPickerForType:(NSArray *)theTypes complete:(MysticBlock)finished;
- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption complete:(MysticBlock)finished;

- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption layoutStyle:(MysticLayoutStyle)layoutStyle complete:(MysticBlock)finished;
- (void) closeDrawerIfOpened:(BOOL)animated finished:(MysticBlockBOOL)finished;
- (void) showAddTabBar:(NSArray *)theOptions finished:(MysticBlockObjObj)addedOption;
- (void) hideAddTabBar;
- (void) ignoreOption:(PackPotionOption *)option;
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color colorSetting:(MysticObjectType)_colorSetting colorChoice:(MysticOptionColorType)_colorType colorOption:(PackPotionOptionColor *)_colorOpt control:(EffectControl *)__effectControl finished:(MysticBlockInput)finished;
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color init:(MysticBlockObject)initBlock finished:(MysticBlockInput)finished;
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color finished:(MysticBlockInput)finished;
- (MysticPointColorBtn *) colorButtonAtIndex:(NSInteger)i;
- (void) rerender;
- (void) rerender:(MysticBlockImageObjOptions)finished;
- (void) render:(BOOL)shouldReturnImage atSourceSize:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)finished;
- (void) render:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)finished;
- (void) render:(MysticBlockImageObjOptions)finished;

@end


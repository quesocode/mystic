//
//  MysticController.m
//  Mystic
//
//  Created by travis weerts on 1/26/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MysticLog.h"
#ifdef DEBUG
//#import "FLEXManager.h"

#endif
#import "MysticBlurBackgroundView.h"
#import "MysticGestureView.h"
#import "ABX.h"
#import "ABXNavigationController.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "MysticImageFilter.h"
#import "MysticController.h"
#import "AppDelegate.h"
#import "TitleView.h"
#import "MysticRangeSlider.h"
#import "SubBarButton.h"
#import "MysticScrollView.h"
#import "MysticFontTools.h"
#import "MysticMoveToolbar.h"
#import "MysticRotateScaleToolbar.h"
#import "MysticLabel.h"
#import "MysticTools.h"
#import "MysticSettingsController.h"
#import "PackPotionOptionMulti.h"
#import "MysticToolbar.h"
#import "MysticHorizontalMenu.h"
#import "SubBarButton.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "NavigationViewController.h"
#import "MKInfoPanel.h"
#import "NavigationBar.h"
#import "MysticEffectsManager.h"
#import "MysticResizeableLabel.h"
#import "MysticResizeableLayer.h"
#import "MysticLayerPanelView.h"
#import "MysticTabBarPanel.h"
#import "MysticCGLabel.h"
#import "MysticIcon.h"
#import "UIFont+Mystic.h"
#import "MysticLabelsView.h"
#import "MysticRecipeProjectAboutView.h"
#import "UIView+ColorOfPoint.h"
#import "MysticLayersViewController.h"
#import "MysticLeftViewController.h"
#import "MysticMainDrawerViewController.h"
#import "MysticDrawerViewController.h"
#import "MysticConstants.h"
#import "MysticLayerToolbar.h"
#import "UserPotion.h"
#import "MysticRenderEngine.h"
#import "MysticShapeView.h"
#import "MysticTabButton.h"
#import "MysticNavigationBar.h"
#import "MysticPackPickerViewController.h"
#import "MysticLayersViewController.h"
#import "MysticTabBarAddLayer.h"
#import "MysticOptionsCacheManager.h"
#import "UIImage+Mystic.h"
#import "MysticQuoteViewController.h"
#import "MysticPanelObject.h"
#import "MysticLayerCountButton.h"
#import "MysticShareItem.h"
#import "MysticTransView.h"
#import "UIView+Mystic.h"
#import "MysticLayerShapeView.h"
#import "MysticLayerEditViewController.h"
#import "MysticControllerView.h"
#import "MysticTabBarShapes.h"
#import "MysticShapesKit.h"
#import "UIView+Mystic.h"
#import "MysticShader.h"
#import "MysticFillFilter.h"
#import "AHKActionSheet.h"
#import "MysticProgressView.h"
#define PROGRESS_HEIGHT 2
#define PROGRESS_ANCHOR 0


static BOOL tabrendering = NO;
static BOOL tabrefreshing = NO;


@interface MysticRenderCompleteObject : NSObject

@property (nonatomic, copy) MysticBlockImageObjOptions complete;
@property (nonatomic, assign) BOOL atSourceSize, returnImage;

+ (instancetype) returns:(BOOL)returnImage atSourceSize:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)complete;

@end

@implementation MysticRenderCompleteObject

+ (instancetype) returns:(BOOL)returnImage atSourceSize:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)complete;
{
    MysticRenderCompleteObject *obj = [[MysticRenderCompleteObject alloc] init];
    obj.complete = complete;
    obj.atSourceSize = atSourceSize;
    obj.returnImage = returnImage;
    return [obj autorelease];
}

@end

@interface MysticController () <MysticLayerViewDelegate, UITextViewDelegate, MysticPhotoContainerViewDelegate, MysticLayersViewDelegate, MysticLayerToolbarDelegate,  MysticLayerPanelViewDelegate, MysticHorizontalMenuDelegate,  MysticPackPickerDelegate, MysticScrollHeaderViewDelegate, MysticQuoteViewControllerDelegate, MysticLayerEditViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UIImageView *sectionTitleView;
    MysticLabel *sectionLabel;
    MysticProgressHUD *HUD, *HUD2;
    BOOL showHUD, reloadingImage, blendFont, pickingColor;
    CGPoint startPoint, endPoint, lastPoint;
    BOOL showingSlider, canMoveTexture, setLayersTransform, setNewSize, displayedImage;
    MysticConfirmType showingConfirm;
    MysticDotView *pin, *activeDot;
    float vignetteValue;
    float lastPinchValue, lastTouchValue;
    UIView *leftBottomBarButton, *rightBottomBarButton;
    NSMutableSet *temporaryControlViews;
    int moveDirection;
    int memoryWarningCount;
    int textMoveDirection , textureMoveDirection, lightMoveDirection, settingsMoveDirection, frameMoveDirection, filterMoveDirection, badgeMoveDirection;
    NSString *lastSearch;
    MysticObjectType confirmedSetting, canceledSetting, firstCamLayerState, startState;
    BOOL keyboardHidden;
    BOOL reloadTheImage;
    BOOL hasPermission;
    BOOL showingMemoryWarning;
    BOOL blendingopen;
    BOOL hasRendered;
    BOOL renderFailed;
    BOOL ignoreSliderUpdates;
    
    CGFloat lastSliderValue;
    NSUInteger lastSettingTag;
    UIButton *opacityChangedButton;
    NSTimer *reloadTimer, *renderTimer;
    NSInteger lastLoadedPackId;
    MysticObjectType lastLoadedPackType;
    
    BOOL _removedNavCenter, _removedNavLeft, _removedNavRight;
}
#ifdef MYSTIC_DEBUG

@property (nonatomic, retain) UILabel *debugLabel;

#endif
@property (nonatomic, retain) MysticRenderCompleteObject *renderCompleteObj;
@property (nonatomic, assign) CGFloat originalPinchScale;
@property (nonatomic, assign) MysticPointColorBtn *activeDropper;
@property (nonatomic, retain) MysticPointColorBtn *panningDropper;
@property (nonatomic, retain) NSString *lastOptionSlotKey;
@property (nonatomic, retain) UIImage *colorPickerImage;
@property (nonatomic, assign) NSTimeInterval revealDuration;
@property (nonatomic, assign) BOOL canRefreshEffects, gestureNeedsReload, isDestroyed, initStateComplete, autoUpdating, hasCheckedForUpdateAtLeastOnce, loadLayerSectionOnOpen, ignoreStateChanges, isSavingLargeImage, isObservingLargeImage, previousGestureDisabled, didSwipe, colorButtonsHidden, colorButtonsHiddenAnimating, lastColorButtonsHidden, tappedFirstTab;
@property (nonatomic, retain) UIView *topView, *hudContainerView, *actionView, *fadeView, *extraView;
@property (nonatomic, retain) UIImageView *overlaysPreviewImageView, *sourceImageView;
@property (nonatomic, retain) NSTimer *renderTimer, *moreToolsTimer, *shaderTimer;
@property (nonatomic, retain) MysticProgressView *progressView;

@property (nonatomic, retain) NSDate *startTime, *endTime;
@property (nonatomic, retain) MysticProgressHUD *reloadHud;
@property (nonatomic, copy) MysticBlockSender viewIsReady;
@property (nonatomic, copy) MysticBlockObjObj addedOptionBlock;
@property (nonatomic, assign) CGFloat lastDrawerPercentVisible;
@property (nonatomic, assign) MysticObjectType reloadImageState, previousGesutreState;
@property (nonatomic, retain) MysticQuoteViewController *quoteController;
@property (nonatomic, assign) MysticLayerCountButton *layerCountButton;
@property (nonatomic, retain) MysticTools *moreToolsView;
@property (nonatomic, retain) MysticLayerEditViewController *layerEditController;
@end

@implementation MysticController

@synthesize imageView=_imageView, tabBar=_tabBar, bottomToolbar=_bottomToolbar, info=_info,   parentSettingType, parentSetting, bottomPanelView=_bottomPanelView, startTime, endTime, canRefreshEffects, gestureNeedsReload, photoInfo=_photoInfo, viewIsReady=_viewIsReady, currentSetting, lastSetting, renderTimer=_renderTimer, topView=_topView, initStateComplete=_initStateComplete, shapesView=_shapesView, layerPanelView=_layerPanelView, blurImage=_blurImage;


static MysticController *instance;
static BOOL firstAppeared = NO;
static BOOL firstDidAppear = NO;

+ (void) controller:(id)value;
{
    if(instance)
    {
        [instance destroy];
        [instance release], instance = nil;
    }
    if(value)
    {
        instance = [value retain];
    }
}
+ (MysticController *) controller;
{
    return instance;
}

+ (UIImage *) screenShot;
{
    return [[self class] screenShot:YES renderedImage:nil rect:CGRectZero tintColor:nil  complete:nil];
}
+ (UIImage *) screenShot:(BOOL)includeBars;
{
    return [[self class] screenShot:includeBars renderedImage:nil rect:CGRectZero tintColor:nil complete:nil];
}
+ (UIImage *) screenShot:(BOOL)includeBars renderedImage:(UIImage *)renderedImage rect:(CGRect)inRect tintColor:(UIColor *)tintColor  complete:(MysticBlockObjObjBOOL)finishedScreenShot;
{
    
    [renderedImage retain];
    UIView *view = includeBars ? [AppDelegate instance].window : nil;
    UIImage *screenshot = nil;
    CGSize imgSize = [[UIScreen mainScreen] bounds].size;
    MysticController *weakSelf = [MysticController controller];
    UIImage *previewImg = renderedImage ? renderedImage : nil; // [MysticOptions current].currentRenderedImage;
    UIImage *finalBlurImg = nil;
    CGRect imgRect = weakSelf.imageView.imageView.frame;
    
    if(view)
    {
        screenshot = [MysticImage renderedImageWithSize:view.frame.size view:view finished:nil];
        imgSize = screenshot.size;
    }
    
    imgRect.origin.y += !weakSelf.navigationController.navigationBarHidden && !weakSelf.navigationController.navigationBar.translucent ? weakSelf.navigationController.navigationBar.frame.size.height : 0;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(includeBars)
    {
        [screenshot drawInRect:CGRectSize(screenshot.size)];
    }

    if(previewImg)
    {
        if(previewImg.scale == 1)
        {
            previewImg = [UIImage imageWithCGImage:previewImg.CGImage scale:[Mystic scale] orientation:previewImg.imageOrientation];
        }
        [previewImg drawInRect:CGRectEqualToRect(inRect, CGRectZero) ? imgRect : inRect];
    }
    else
    {
        [[UIColor blackColor] setFill];
        CGContextFillRect(context, imgRect);
    }
    
    if(tintColor)
    {
        [tintColor setFill];
        CGContextFillRect(context, CGRectSize(imgSize));
    }
    
    finalBlurImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(finishedScreenShot) finishedScreenShot(finalBlurImg, previewImg, finalBlurImg ? YES : NO);
    [renderedImage autorelease];
    return finalBlurImg;
}

+ (void) setNeedsDisplay;
{
    if(instance)
    {
        [instance setNeedsDisplay];
    }
}

- (void) setNeedsDisplay;
{
    [self.tabBar setNeedsDisplay];
}
- (void) destroy;
{
    
    tabrendering = NO;
    tabrefreshing = NO;
    
    
    if(self.isDestroyed) return;
    //    [self stopMoreToolsTimer];
    if(self.moreToolsTimer)
    {
        [self.moreToolsTimer invalidate];
        self.moreToolsTimer = nil;
    }
    if(self.renderCompleteObj)
    {
        self.renderCompleteObj = nil;
    }
    [self.moreToolsView removeFromSuperview];
    self.moreToolsView = nil;
    if(self.layerCountButton)
    {
        [self.layerCountButton removeFromSuperview];
        self.layerCountButton = nil;
    }
    if(self.extraView)
    {
        [self.extraView removeFromSuperview];
        self.extraView = nil;
    }
    if(self.overlaysPreviewImageView)
    {
        [self.overlaysPreviewImageView removeFromSuperview];
        self.overlaysPreviewImageView = nil;
    }
    if(self.sourceImageView)
    {
        [self.sourceImageView removeFromSuperview];
        self.sourceImageView = nil;
    }
    
    [self destroyLayerPanelController];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
    [self.mm_drawerController setDrawerVisualStateBlock:nil];
    [self.undoRedoTools removeFromSuperview];
    self.undoRedoTools = nil;
    self.renderTimer = nil;
    self.preReloadImageBlock = nil;
    if(HUD) HUD.delegate = nil;
    if(HUD2) HUD2.delegate = nil;
    //    if(self.popupMenu) [self.popupMenu dismissAnimated:NO];
    self.tabBar.delegate = nil;
    self.imageView.delegate = nil;
    self.tabBar.tabBarDelegate = nil;
    [self.fontStylesController destroy];
    self.labelsView = nil;
    self.fontStylesController = nil;
    self.shapesView = nil;
    self.shapesController = nil;
    self.currentOption = nil;
    [self.navCenterView removeFromSuperview];
    self.navCenterView = nil;
    [self.navLeftView removeFromSuperview];
    self.navLeftView = nil;
    [self.navRightView removeFromSuperview];
    self.navRightView = nil;
    self.quoteController = nil;
    self.layerEditController = nil;
    if(self.testImageView) [self.testImageView removeFromSuperview];
    if(self.testImageBlurView) [self.testImageBlurView removeFromSuperview];
    self.testImageView = nil;
    self.testImageBlurView = nil;
    self.lastOptionSlotKey = nil;
    [MysticOptions current].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MysticEffectsManager manager].options = nil;
    [UserPotion reset];
    if(self.reloadHud)
    {
        [self removeReloadHUD];
    }
    [MysticProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    self.blurImage = nil;
    self.isDestroyed = YES;
    // inserted hack to release a reference that i couldnt find
    //    [self autorelease];
    
    
}


- (void) dealloc
{
    [self destroy];
    _layerCountButton = nil;
    if(_renderCompleteObj) [_renderCompleteObj release], _renderCompleteObj = nil;
    if(_colorPickerImage) [_colorPickerImage release], _colorPickerImage=nil;
    if(_renderTimer) { [_renderTimer invalidate]; [_renderTimer release], _renderTimer=nil; }
    if(_moreToolsTimer) { [_moreToolsTimer invalidate]; [_moreToolsTimer release]; }
    [_testImageView release]; [_testImageBlurView release];
    [_photoInfo release];
    [_navCenterView release];
    [_navLeftView release];
    [_navRightView release];
    [_blurImage release];
    [_layerPanelView release], _layerPanelView=nil;
    [_lastOptionSlotKey release], _lastOptionSlotKey=nil;
    [instance release], instance=nil;
    [_labelsView release], _labelsView=nil;
    [_shapesView release], _shapesView=nil;
    if(_undoRedoTools) [_undoRedoTools release], _undoRedoTools=nil;
    if(_overlaysPreviewImageView) [_overlaysPreviewImageView release], _overlaysPreviewImageView = nil;
    if(_sourceImageView) [_sourceImageView release], _sourceImageView = nil;

    if(_extraView) [_extraView release], _extraView=nil;
    if(_fadeView) [_fadeView release], _fadeView=nil;
    [_fontStylesController release];
    [_shapesController release];
    if(_actionView) [_actionView release], _actionView=nil;
    if(_addTabBar) [_addTabBar release], _addTabBar = nil;
    [_imageView release], _imageView = nil;
    [_bottomToolbar release], _bottomToolbar=nil;
    if(_tabBar) [_tabBar release], _tabBar = nil;
    if(sectionTitleView) [sectionTitleView release], sectionTitleView=nil;
    if(temporaryControlViews) [temporaryControlViews release], temporaryControlViews=nil;
    if(_bottomPanelView) [_bottomPanelView release], _bottomPanelView=nil;
    if(_activePacks) [_activePacks release], _activePacks=nil;
    if(_activePack) [_activePack release], _activePack=nil;
    if(_shapesView) [_shapesView release], _shapesView = nil;
    if(_overlayView) [_overlayView release], _overlayView=nil;
    if(_transformOption) [_transformOption release], _transformOption=nil;
    if(startTime) [startTime release];
    if(endTime) [endTime release];
    if(_info) [_info release];
    [_sketchView release];
    if(_reloadHud) [_reloadHud release];
    if(_layerPanelController) [_layerPanelController release];
    if(_addedOptionBlock) Block_release(_addedOptionBlock);
    if(_preReloadImageBlock) Block_release(_preReloadImageBlock);
    if(_quoteController) [_quoteController release], _quoteController=nil;
    if(_layerEditController) [_layerEditController release], _layerEditController=nil;
    [super dealloc];
    
    
}


- (id) initWithNibName:(NSString *)nibNameOrNil images:(NSArray *)userInfo;
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
#ifdef MYSTIC_START_STATE
        startState = MYSTIC_START_STATE;
#else
        startState = MysticSettingUnknown;
#endif
        memoryWarningCount = 0;
        self.currentOpenSide = MMDrawerSideNone;
        self.isDestroyed = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        ignoreSliderUpdates = NO;
        mCurrentScale = 1.0;
        mLastScale = 1.0;
        showingSlider = NO;
        setNewSize = YES;
        _launchState = MysticSettingLaunch;
        _previewSize = CGSizeZero;
        showHUD = YES;
        _isSavingLargeImage=NO;
        _isObservingLargeImage=NO;
        displayedImage = NO;
        hasRendered = NO;
        _readyForRenderEngine = YES;
        outputDebug = NO;
        reloadingImage=NO;
        keyboardHidden = YES;
        _revealDuration=0;
        vignetteValue = 0;
        pinLastAnchor = CGPointZero;
        lastSliderValue = -999.9f;
        lastSettingTag = NSNotFound;
        confirmedSetting = MysticSettingNone;
        canceledSetting = MysticSettingNone;
        lastSetting = MysticSettingNone;
        currentSetting = MysticSettingUnLaunched;
        HUD2 = nil;
        self.extraControls = [NSMutableArray array];
        self.loadLayerSectionOnOpen = YES;
        self.lastDrawerPercentVisible = 0;
        firstCamLayerState = MysticSettingCamLayerSetup;
        temporaryControlViews = [[NSMutableSet set] retain];
        self.info = userInfo ? [NSMutableArray arrayWithArray:userInfo] : nil;
        self.navigationItem.hidesBackButton = YES;
        self.hidesBottomBarWhenPushed = YES;
        instance = [self retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPotionChanged:) name:MysticUserPotionChangedEventName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionChanged:) name:MysticInternetAvailableEventName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionChanged:) name:MysticInternetUnavailableEventName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionNeeded:) name:MysticInternetNeededEventName object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide:) name:UIMenuControllerWillHideMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoRedoChanged:) name:kMysticUndoRedoChangedNotification object:nil];

        NSString *theName = MYSTIC_TRANSFORM_COMPLETE_NOTIFICATION;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transformImageComplete:) name:theName object:nil];
        
    }
    return self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void) hideNavViews:(MysticBlockAnimationFinished)finished;
{
    [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        if(_navCenterView)
        {
            _navCenterView.alpha = 0;
        }
        if(_navLeftView)
        {
            _navLeftView.alpha = 0;
        }
        if(_navRightView)
        {
            _navRightView.alpha = 0;
        }
    } completion:finished];
}
- (void) showNavViews:(MysticBlockAnimationFinished)finished;
{
    [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        if(_navCenterView)
        {
            _navCenterView.alpha = 1;
        }
        if(_navLeftView)
        {
            _navLeftView.alpha = 1;
        }
        if(_navRightView)
        {
            _navRightView.alpha = 1;
        }
    } completion:finished];
}
- (BOOL) isNavViewVisible;
{
    return (self.navCenterView && self.navCenterView.alpha > 0 && !self.navCenterView.hidden) ||
    (self.navLeftView && self.navLeftView.alpha > 0 && !self.navLeftView.hidden) ||
    (self.navRightView && self.navRightView.alpha > 0 && !self.navRightView.hidden);
    
}
- (CGFloat) navViewHeight;
{
    CGFloat h = 0;
    h = MAX(h, (self.navCenterView && self.navCenterView.alpha > 0 && !self.navCenterView.hidden) ? self.navCenterView.frame.size.height : 0 );
    h = MAX(h, (self.navLeftView && self.navLeftView.alpha > 0 && !self.navLeftView.hidden) ? self.navLeftView.frame.size.height : 0 );
    h = MAX(h, (self.navRightView && self.navRightView.alpha > 0 && !self.navRightView.hidden) ? self.navRightView.frame.size.height : 0 );
    return h;
}
- (void) navCenterViewTouched:(MysticButton *)sender;
{
    
}
- (void) navLeftViewTouched:(MysticButton *)sender;
{
    
}
- (void) navRightViewTouched:(MysticButton *)sender;
{
    
}
- (void) setNavCenterView:(MysticButton *)view;
{
    [self setNavCenterView:view animated:YES];
}
- (void) setNavCenterView:(MysticButton *)view animated:(BOOL)animated;
{
    
    if(view && [view isKindOfClass:[NSString class]])
    {
        view = [MysticButton buttonWithTitle:(NSString *)view target:self sel:@selector(navCenterViewTouched:)];
        [view setTitleColor:[UIColor color:MysticColorTypeNavBarText] forState:UIControlStateNormal];
        view.titleLabel.font = [MysticFont font:12];
    }
    if(animated)
    {
        __unsafe_unretained __block MysticController *weakSelf = self;
        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if(_navCenterView) _navCenterView.alpha = 0;
        } completion:^(BOOL finished) {
            if(_navCenterView)
            {
                [_navCenterView removeFromSuperview];
                [_navCenterView release];
                _navCenterView = nil;
                
            }
            view.alpha = 0;
            if(!view || !finished) return;
            _navCenterView = [view retain];
            _navCenterView.center = CGPointMake(weakSelf.view.center.x, 26);
            [weakSelf.view addSubview:_navCenterView];
            
            [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                _navCenterView.alpha = 1;
            } completion:nil];
            
        }];
    }
    else
    {
        if(_navCenterView)
        {
            [_navCenterView removeFromSuperview];
            [_navCenterView release];
            _navCenterView = nil;
            
        }
        if(!view) return;
        
        _navCenterView = [view retain];
        _navCenterView.center = CGPointMake(self.view.center.x, 26);
        [self.view addSubview:_navCenterView];
    }
}
- (void) setNavLeftView:(MysticButton *)view;
{
    [self setNavLeftView:view animated:YES];
}
- (void) setNavLeftView:(UIView *)view animated:(BOOL)animated;
{
    if(view && [view isKindOfClass:[NSString class]])
    {
        view = [MysticButton buttonWithTitle:(NSString *)view target:self sel:@selector(navLeftViewTouched:)];
        [(MysticButton *)view setTitleColor:[UIColor color:MysticColorTypeNavBarText] forState:UIControlStateNormal];
        ((MysticButton *) view).titleLabel.font = [MysticFont font:12];
    }
    if(animated)
    {
        __unsafe_unretained __block MysticController *weakSelf = self;
        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            if(_navLeftView)
            {
                _navLeftView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            if(_navLeftView)
            {
                [_navLeftView removeFromSuperview];
                [_navLeftView release];
                _navLeftView = nil;
                
            }
            view.alpha = 0;
            
            if(!view || !finished) return;
            
            _navLeftView = (id)[view retain];
            _navLeftView.center = CGPointMake(28, 26);
            [weakSelf.view addSubview:_navLeftView];
            
            [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                _navLeftView.alpha = 1;
            } completion:nil];
            
        }];
    }
    else
    {
        
        if(_navLeftView)
        {
            [_navLeftView removeFromSuperview];
            [_navLeftView release];
            _navLeftView = nil;
        }
        if(!view)
        {
            return;
        }
        _navLeftView = (id)[view retain];
        _navLeftView.center = CGPointMake(28, 26);
        [self.view addSubview:view];
    }
}
- (void) setNavRightView:(MysticButton *)view;
{
    [self setNavRightView:view animated:YES];
}
- (void) setNavRightView:(MysticButton *)view animated:(BOOL)animated;
{
    if(view && [view isKindOfClass:[NSString class]])
    {
        view = [MysticButton buttonWithTitle:(NSString *)view target:self sel:@selector(navRightViewTouched:)];
        [view setTitleColor:[UIColor color:MysticColorTypeNavBarText] forState:UIControlStateNormal];
        view.titleLabel.font = [MysticFont font:12];
    }
    if(animated)
    {
        __unsafe_unretained __block MysticController *weakSelf = self;
        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            if(_navRightView)
            {
                _navRightView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            if(_navRightView)
            {
                [_navRightView removeFromSuperview];
                [_navRightView release];
                _navRightView = nil;
                
            }
            view.alpha = 0;
            
            if(!view || !finished) return;
            _navRightView = [view retain];
            _navRightView.center = CGPointMake(weakSelf.view.frame.size.width - (_navRightView.frame.size.width/2) -  7, 26);
            [weakSelf.view addSubview:view];
            
            
            [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                _navRightView.alpha = 1;
            } completion:nil];
            
        }];
    }
    else
    {
        
        if(_navRightView)
        {
            [_navRightView removeFromSuperview];
            [_navRightView release];
            _navRightView = nil;
            
        }
        if(!view) return;
        
        _navRightView = [view retain];
        _navRightView.center = CGPointMake(self.view.frame.size.width - 20, 26);
        [self.view addSubview:view];
    }
}
- (MysticProgressHUD *) HUD; { return HUD2; }
- (MysticProgressHUD *) showHUD:(NSString *)message checked:(id)checked;
{
    mdispatch( ^{
        BOOL created = NO;
        if(!HUD2)
        {
            created = YES;
            HUD2 = [[MysticProgressHUD alloc] initWithView:self.hudContainerView];
            HUD2.delegate = self;
            HUD2.completionBlock = NULL;
            HUD2.removeFromSuperViewOnHide = YES;
            if(![self.hudContainerView.subviews containsObject:HUD2]) [self.hudContainerView addSubview:HUD2];
            
        }
        
        if(message && !checked)
        {
            HUD2.labelText = message;
        }
        else if(checked && message) {
            HUD2.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark-white.png"]] autorelease];
            HUD2.mode = MysticProgressHUDModeCustomView;
            HUD2.labelText = message;
        }
        else if(!checked)
        {
            HUD2.mode = MysticProgressHUDModeIndeterminate;
        }
        [HUD2 show:created];
        if(checked) [self hideHUDAfterDelay:[checked isKindOfClass:[NSNumber class]] ? [checked floatValue] : 1];
    });
    return HUD2;
}

- (BOOL) createNewOption;
{
    BOOL createNewObject = NO;
    if(self.currentStateInfo && [self.currentStateInfo objectForKey:@"createNewObject"])
    {
        createNewObject = [[self.currentStateInfo objectForKey:@"createNewObject"] boolValue];
    }
    return createNewObject;
}
- (void) hideHUD;
{
    [self hideHUDAfterDelay:0];
}
- (void) hideHUDAfterDelay:(NSTimeInterval)delay;
{
    if(HUD2 && delay <= 0)
    {
        [MysticProgressHUD hideHUDForView:self.hudContainerView animated:YES];
        [HUD2 release]; HUD2 = nil;
    }
    else if(HUD2)
    {
        
        [HUD2 hide:YES afterDelay:delay];
        [HUD2 release]; HUD2 = nil;
        
    }
}

- (UIView *) hudContainerView;
{
    return self.view;
}

- (UIView *) topView;
{
    return self.view;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DDLogMemory(@"Memory warning: %d", memoryWarningCount);
    
    switch (memoryWarningCount) {
        case 0:
        {
            self.layerCountButton.layer.borderColor = [UIColor yellowGreenColor].CGColor;
            break;
        }
        case 1:
        {
            self.layerCountButton.layer.borderColor = [UIColor yellowColor].CGColor;
            break;
        }
        case 2:
        {
            self.layerCountButton.layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
        case 3:
        {
            self.layerCountButton.layer.borderColor = [UIColor red].CGColor;
            break;
        }
            
        default:
        {
            self.layerCountButton.layer.borderColor = [UIColor purpleColor].CGColor;
            break;
        }
    }
    memoryWarningCount++;
    [Mystic freeMemory];
    [MysticEffectsManager cleanFrameBuffers];
    
    __unsafe_unretained __block MysticController *weakself = self;
    [NSTimer wait:1 block:^{
        [weakself.layerCountButton resetColor];
    }];
    
    if(showingMemoryWarning || memoryWarningCount < 7) return;
    memoryWarningCount = 0;
    //    showingMemoryWarning = YES;
    //    [MysticAlert ask:@"Memory Warning" message:@"There's too much going on, you should save your image before Mystic crashes" yes:^(id object, id o2) {
    //        showingMemoryWarning = NO;
    //    } no:^(id object, id o2) {
    //    } options:@{@"cancelTitle": @"Ignore", @"button": @"OK"}];
    
}

- (void) internetConnectionChanged:(NSNotification *)notification;
{
    if(![Mystic hasInternetConnection])
    {
        
    }
}


- (void) hideBarsAnimate:(NSTimeInterval)duration complete:(MysticBlock)finished
{
    
    duration = duration == -1 ? MYSTIC_HIDEBARS_DURATION : duration;
    [self hideBottomBar:YES duration:duration complete:nil];
    [(MysticNavigationViewController *)self.navigationController hideNavigationBar:YES duration:duration complete:^{
        if(finished) finished();
    }];
}
- (void) showBarsAnimate:(NSTimeInterval)duration complete:(MysticBlock)finished
{
    
    duration = duration == -1 ? MYSTIC_SHOWBARS_DURATION : duration;
    [(MysticNavigationViewController *)self.navigationController hideNavigationBar:YES duration:duration complete:nil];
    [self hideBottomBar:NO duration:duration complete:finished];
}
- (void) hideNavBar:(BOOL)hide duration:(NSTimeInterval)duration complete:(MysticBlock)finished;
{
    duration = duration == -1 ? (hide ? MYSTIC_HIDEBARS_DURATION : MYSTIC_SHOWBARS_DURATION) : duration;
    [(MysticNavigationViewController *)self.navigationController hideNavigationBar:hide duration:duration complete:^{
        if(finished) finished();
    }];
}
- (void) hideBottomBar:(BOOL)hide duration:(NSTimeInterval)duration complete:(MysticBlock)finished;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block MysticBlock __finished = finished ? Block_copy(finished) : nil;
    
    mdispatch( ^{
        
        __block NSTimeInterval _duration = duration == -1 ? MYSTIC_HIDEBARS_DURATION : duration;
        
        CGRect viewRect = weakSelf.view.frame;
        if(hide)
        {
            
            if(!self.bottomPanelView.hidden)
            {
                
                weakSelf.bottomPanelView.isHiding = YES;
                CGRect nf = weakSelf.bottomPanelView.frame;
                nf.origin.y = viewRect.size.height;
                
                if(_duration == 0)
                {
                    weakSelf.bottomPanelView.frame = nf;
                    weakSelf.bottomPanelView.hidden = YES;
                    if(__finished){ __finished(); Block_release(__finished); }
                    
                }
                else
                {
                    [MysticUIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        weakSelf.bottomPanelView.frame = nf;
                    } completion:^(BOOL finishedAnimation) {
                        
                        weakSelf.bottomPanelView.hidden = YES;
                        weakSelf.bottomPanelView.frame = nf;
                        
                        if(__finished){ __finished(); Block_release(__finished); }
                        
                    }];
                }
            }
            else
            {
                
                weakSelf.bottomPanelView.isHiding = NO;
                weakSelf.bottomPanelView.isShowing = NO;
                weakSelf.bottomPanelView.hidden = YES;
                
                if(__finished){ __finished(); Block_release(__finished); }
            }
        }
        else
        {
            CGRect nf = weakSelf.bottomPanelView.frame;
            nf.origin.y =viewRect.size.height - nf.size.height;
            __block NSTimeInterval _duration = duration == -1 ? MYSTIC_HIDEBARS_DURATION : duration;
            
            if(weakSelf.bottomPanelView.hidden)
            {
                
                weakSelf.bottomPanelView.hidden = NO;
                weakSelf.bottomPanelView.isShowing = YES;
                
                if(_duration == 0)
                {
                    weakSelf.bottomPanelView.frame = nf;
                    weakSelf.bottomPanelView.isShowing = NO;
                    
                    if(__finished){ __finished(); Block_release(__finished); }
                    
                }
                else
                {
                    [MysticUIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        weakSelf.bottomPanelView.frame = nf;
                    } completion:^(BOOL finishedAnimation) {
                        
                        
                        weakSelf.bottomPanelView.isShowing = NO;
                        weakSelf.bottomPanelView.frame = nf;
                        if(__finished){ __finished(); Block_release(__finished); }
                        
                    }];
                }
            }
            else
            {
                weakSelf.bottomPanelView.hidden = NO;
                weakSelf.bottomPanelView.isHiding = NO;
                weakSelf.bottomPanelView.isShowing = NO;
                if(__finished){ __finished(); Block_release(__finished); }
            }
        }
    });
}



- (void) internetConnectionNeeded:(NSNotification *)notification;
{
    [self showNoInternetConnectionPanel];
}
- (void) showNoInternetConnectionPanel;
{
    [self hideNoInternetConnectionPanel];
    MKInfoPanel *panel = [MKInfoPanel showPanelInView:self.view
                                                 type:MKInfoPanelTypeError
                                                title:@"Network Failure!"
                                             subtitle:@"Check your internet connection and try again!"
                                            hideAfter:3];
    panel.delegate = self;
    panel.onTouched = @selector(hideNoInternetConnectionPanel);
    
}

- (void) hideNoInternetConnectionPanel;
{
    [MKInfoPanel hideAllPanelsUnderView:self.view];
    [MKInfoPanel hideAllPanelsUnderView:self.navigationController.view];
    
}

#pragma mark - setInfo - set Image
- (void) pick:(MysticPickerSourceType)sourceType finished:(MysticBlock)finished;
{
    currentSetting = MysticSettingChangeSource;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openCam:nil source:sourceType complete:finished];
}
- (void) info:(NSArray *)info ready:(MysticBlockSender)finished;
{
    self.photoInfo = [NSMutableArray arrayWithArray:(info ? info : self.photoInfo)];
    self.viewIsReady = finished;
}
- (void) setInfo:(NSArray *)info finished:(MysticBlock)finished;
{
    [self setInfo:info reset:YES finished:finished];
}
- (void) setInfo:(NSArray *)info reset:(BOOL)shouldReset finished:(MysticBlock)finished;
{
    __unsafe_unretained __block  MysticController *weakSelf = self;
    info = info ? info : self.photoInfo;
    if(info)
    {
        __unsafe_unretained __block MysticBlock __finished = finished ? Block_copy(finished) : nil;
        __unsafe_unretained __block NSArray *__info = [info retain];
        if(self.currentSetting != MysticSettingChangeSource)
        {
            if(shouldReset)
            {
                setNewSize = YES;
                [self.fontStylesController removeOverlays];
                [UserPotion startNewProject];
                [UserPotion reset:NO];
                if(self.navigationController ) [self.navigationController setToolbarHidden:YES animated:NO];
            }
            [self.imageView resetFrame];
            [self setState:self.launchState animated:NO complete:^{
                [[UserPotion potion] preparePhoto:[__info lastObject] previewSize:[MysticUI screen] reset:shouldReset finished:^(CGSize size, UIImage *preparedPhoto, NSString *imageFilePath){
                    mdispatch( ^{
                        weakSelf.previewSize = size;
                        weakSelf.imageView.imageViewFrame = CGRectSize(size);
                        weakSelf.imageView.imageView.frame = weakSelf.imageView.imageViewFrame;
                        
                        [weakSelf updateImageViewFrame:CGRectInfinite];
                        
                        [weakSelf.view setNeedsLayout];
                        if([MysticOptions current]) [[MysticOptions current] setNeedsRender];
                        [weakSelf reloadImage:YES placeholder:nil complete:^(UIImage *i, id o, id opt, BOOL c) {
                            runBlock(__finished), __finished=nil;
                            [__info release];
//                            FLog(@"image view frame", weakSelf.imageView.imageViewFrame);
//                            FLog(@"image view frame2", weakSelf.imageView.frame);
//                            
//                            FLog(@"view", weakSelf.view.frame);
//                            [weakSelf.imageView removeAllRects];
//                            [weakSelf.imageView addAllRects];
//                            VLLog(weakSelf.imageView);
                        }];
                    });
                }];
            }];
        }
        else
        {
            setNewSize = YES;
            setLayersTransform = NO;
            [self.imageView resetFrame];
            [self setState:MysticSettingNone animated:NO complete:^{
                [[UserPotion potion] preparePhoto:[__info lastObject] previewSize:[MysticUI screen] reset:shouldReset finished:^(CGSize size, UIImage *preparedPhoto, NSString *imageFilePath){
                    weakSelf.previewSize = size;
                    weakSelf.imageView.imageViewFrame = CGRectSize(size);
                    weakSelf.imageView.imageView.frame = weakSelf.imageView.imageViewFrame;
                    [weakSelf updateImageViewFrame:CGRectInfinite];
                    [weakSelf.view setNeedsLayout];
                    if([MysticOptions current])
                    {
                        [MysticOptions current].size = weakSelf.previewSize;
                        [[MysticOptions current] setNeedsRender];
                    }
                    
                    __unsafe_unretained __block UIImage *_preparedPhoto = preparedPhoto ? [preparedPhoto retain] : nil;
                    [weakSelf reloadImage:YES placeholder:nil complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                        [weakSelf rebuildBlurImage:nil renderedImage:_preparedPhoto];
                        runBlock(__finished), __finished=nil;
                        [_preparedPhoto release];
                        [__info release];
                    }];
                }];
            }];
        }
    }
}

- (void) runViewIsReady;
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    if(self.viewIsReady)
    {
        self.viewIsReady(self);
        self.viewIsReady = nil;
        Block_release(_viewIsReady);
    }
    self.photoInfo = nil;
    [self.overlayView setupGestures:self.currentSetting];
}

#pragma mark -
#pragma mark View Events


- (void) setupDrawerState;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    [weakSelf.mm_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
        switch (drawerController.openSide)
        {
            case MMDrawerSideNone:
            {
                [weakSelf.drawer emptyData];
                break;
            }
            default: break;
        }
        
    }];
//    DLog(@"setup drawer state");
    [weakSelf.mm_drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        BOOL skipManualFadeoutAnim = (weakSelf.lastDrawerPercentVisible==1 && percentVisible == 0) ? YES : NO;
        BOOL needsRender = NO;
        BOOL resetRecognizeDrawerGesture = YES;
        MMDrawerSide nextDrawerSide = drawerSide;
        if((percentVisible == 0 && (self.currentOpenSide == MMDrawerSideNone)) || (percentVisible == 1 && self.currentOpenSide == drawerSide))
        {
            nextDrawerSide = MMDrawerSideNone;
            
        }
        if(self.fadeView) self.fadeView.frame = self.view.bounds;
        switch (nextDrawerSide)
        {
            case MMDrawerSideNone:
            {
                
                weakSelf.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
                weakSelf.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
                weakSelf.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
                [weakSelf.overlayView setupGestures:weakSelf.currentSetting];
                weakSelf.loadLayerSectionOnOpen = YES;
                
                if(percentVisible == 1 && needsRender)
                {
                    [MysticOptions enable:MysticRenderOptionsForceProcess];
                    [weakSelf reloadImage:YES];
                }
                
                break;
            }
            case MMDrawerSideLeft:
            {
                if(percentVisible == 1.0)
                {
                    switch (self.currentOpenSide)
                    {
                        case MMDrawerSideLeft:
                        {
                            resetRecognizeDrawerGesture = NO;
                            break;
                        }
                        case MMDrawerSideNone:
                        {
                            resetRecognizeDrawerGesture = NO;
                            self.currentOpenSide = MMDrawerSideLeft;
                            [weakSelf showFadeOutView:YES finished:nil];
                            
                            break;
                        }
                        default:
                            break;
                    }
                    
                    switch (weakSelf.currentSetting)
                    {
                        case MysticSettingNone:
                        case MysticSettingNoneFromLoadProject:
                        case MysticSettingLaunch:
                        case MysticSettingNoneFromBack:
                        case MysticSettingNoneFromCancel:
                        case MysticSettingNoneFromConfirm:
                            break;
                        default:
                            [weakSelf toggleMoreTools:YES];
                            break;
                    }
                    
                    
                    if(resetRecognizeDrawerGesture)
                    {
                        
                        weakSelf.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
                        weakSelf.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
                        weakSelf.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
                        [weakSelf.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                        [weakSelf.mm_drawerController
                         setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
                             return NO;
                         }];
                    }
                    
                }
                else if(percentVisible == 0)
                {
                    switch (self.currentOpenSide)
                    {
                        case MMDrawerSideNone:
                        {
                            if(weakSelf.loadLayerSectionOnOpen)
                            {
                                [weakSelf.drawer loadSection:MysticDrawerSectionMain];
                            }
                            
                            [weakSelf showFadeOutView:skipManualFadeoutAnim finished:nil];
                            
                            break;
                        }
                        case MMDrawerSideLeft:
                        {
                            [weakSelf hideFadeOutView:skipManualFadeoutAnim finished:nil];
                            resetRecognizeDrawerGesture = NO;
                            weakSelf.loadLayerSectionOnOpen = YES;
                            break;
                        }
                        default:
                            
                            break;
                    }
                    
                    
                    if(resetRecognizeDrawerGesture)
                    {
                        weakSelf.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
                        weakSelf.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeCustom;
                        weakSelf.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
                        
                        [weakSelf.mm_drawerController
                         setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
                             
                             return NO;
                         }];
                        
                        
                        
                    }
                    if(needsRender)
                    {
                        [MysticOptions enable:MysticRenderOptionsForceProcess];
                        [weakSelf reloadImage:YES];
                    }
                    if(!skipManualFadeoutAnim && self.fadeView)
                    {
                        [self animateFadeOutView:(CGFloat) MIN(1,percentVisible + (percentVisible * 0.1)) changeControls:YES];
                        
                    }
                    
                }
                break;
            }
            case MMDrawerSideRight:
            {
                
                
                if(percentVisible == 1.0)
                {
                    
                    switch (self.currentOpenSide) {
                        case MMDrawerSideLeft:
                        case MMDrawerSideRight:
                        {
                            if(self.fadeView)
                            {
                                UIImageView *iv = [self.fadeView.subviews objectAtIndex:0];
                                [MysticUIView animateWithDuration:0.1 animations:^{
                                    iv.transform = CGAffineTransformMakeTranslation(iv.image.size.width, 0);
                                }];
                                
                            }
                            
                            break;
                        }
                        case MMDrawerSideNone:
                        {
                            self.currentOpenSide = MMDrawerSideRight;
                            
                            [weakSelf showFadeOutView:YES finished:nil];
                            
                            break;
                        }
                        default:
                            break;
                    }
                    weakSelf.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
                    weakSelf.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
                    [weakSelf.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                    
                    [weakSelf.mm_drawerController
                     setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
                         return NO;
                     }];
                }
                else
                {
                    
                    weakSelf.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
                    weakSelf.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
                    weakSelf.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
                    
                    if(percentVisible == 0)
                    {
                        switch (self.currentOpenSide) {
                            case MMDrawerSideLeft:
                            case MMDrawerSideRight:
                            {
                                if(needsRender)
                                {
                                    
                                    [weakSelf reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess];
                                }
                                
                                [weakSelf hideFadeOutView:skipManualFadeoutAnim finished:nil];
                                
                                self.currentOpenSide = MMDrawerSideNone;
                                
                                
                                break;
                            }
                            case MMDrawerSideNone:
                            {
                                [weakSelf showFadeOutView:skipManualFadeoutAnim finished:nil];
                                break;
                            }
                                
                            default:
                                break;
                        }
                        
                    }
                    
                    if(!skipManualFadeoutAnim && self.fadeView)
                    {
                        [self animateFadeOutView:(CGFloat) MIN(1,percentVisible + (percentVisible * 0.1)) changeControls:YES];
                        
                    }
                    
                    
                }
                break;
            }
            default: break;
        }
        
        weakSelf.lastDrawerPercentVisible = percentVisible;
        
    }];
}

- (void) removeFadeView;
{
    if(!self.fadeView) return;
    [self.fadeView removeFromSuperview];
    self.fadeView = nil;
}

- (void) animateFadeOutView:(CGFloat)fa changeControls:(BOOL)changeControls;
{
    BOOL shouldAnimate = fa == -1 || fa == 2;
    fa = fa == -1 ? 0 : fa;
    fa = fa == 2 ? 1 : fa;
    
    fa = MAX(0, fa);
    fa = MIN(1, fa);
    CGAffineTransform t = CGAffineTransformIdentity;
    NSTimeInterval delay = 0;
    __unsafe_unretained __block MysticController *weakSelf = self;
    self.fadeView.backgroundColor = [[UIColor hex:@"4F4846"] colorWithAlphaComponent:.91 * fa];
    shouldAnimate = NO;
    if(changeControls)
    {
        if(shouldAnimate)
        {
            [MysticUIView animateWithDuration:0.4 delay:0.1 * fa  options:(fa == 1 ? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn) animations:^{
                weakSelf.fadeView.alpha = fa;
                
            } completion:^(BOOL finished) {
                if(fa == 0) [weakSelf removeFadeView];
            }];
        }
        else
        {
            weakSelf.fadeView.alpha = fa;
            
            if(fa == 0) [weakSelf removeFadeView];
        }
    }
}
- (void) drawerScrolled:(CGPoint)drawerOffset;
{
    switch (self.currentOpenSide) {
        case MMDrawerSideLeft:
            if(self.fadeView)
            {
                UIImageView *iv = [self.fadeView.subviews objectAtIndex:0];
                CGRect ivf = iv.frame;
                ivf.origin.y = (-1*drawerOffset.y);
                iv.frame = ivf;
            }
            break;
            
        default: break;
    }
}
- (void) showFadeOutView:(BOOL)animated finished:(MysticBlockAnimationFinished)finishedanim;
{
    if(!self.fadeView)
    {
        MysticBlurBackgroundView *fadeView = [[MysticBlurBackgroundView alloc] initWithFrame:self.view.bounds];
        fadeView.userInteractionEnabled = NO;
        fadeView.opaque = NO;
        self.fadeView = [fadeView autorelease];
        [self.view addSubview:self.fadeView];
        [self animateFadeOutView:0 changeControls:NO];
    }
    
    [self.view bringSubviewToFront:self.fadeView];
    if(animated)
    {
        __block MysticBlockAnimationFinished _f = finishedanim ? Block_copy(finishedanim) : nil;
        [MysticUIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [self animateFadeOutView:1 changeControls:NO];
        } completion:^(BOOL finished) {
            if(_f)
            {
                _f(finished);
                Block_release(_f);
            }
        }];
    }
    else
    {
        
        [self animateFadeOutView:2 changeControls:YES];
        if(finishedanim) finishedanim(YES);
    }
}

- (void) hideFadeOutView:(BOOL)animated  finished:(MysticBlockAnimationFinished)finishedanim;
{
    
    if(self.fadeView)
    {
        if(animated)
        {
            __block MysticBlockAnimationFinished _f = finishedanim ? Block_copy(finishedanim) : nil;
            [MysticUIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                
                [self animateFadeOutView:0 changeControls:NO];
                
            } completion:^(BOOL finished) {
                
                [self animateFadeOutView:-1 changeControls:YES];
                if(_f)
                {
                    _f(finished);
                    Block_release(_f);
                }
            }];
        }
        else
        {
            [self animateFadeOutView:-1 changeControls:YES];
            if(finishedanim) finishedanim(YES);
        }
    }
}

- (void) setCurrentSetting:(MysticObjectType)c gotoState:(BOOL)go;
{
    if(go) self.currentSetting = c;
    else currentSetting = c;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBar setNeedsDisplay];
    self.navigationController.toolbarHidden = YES;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    [(NavigationBar *)self.navigationController.navigationBar setBorderStyle:NavigationBarBorderStyleNone];
    [(NavigationBar *)self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [self hideNavBar:YES duration:0 complete:nil];
    switch (currentSetting) {
        case MysticSettingUnLaunched:
        case MysticSettingLaunch:
        {
            [self removeTempControls:self.layerPanelView];
            self.bottomPanelView.frame = CGRectMake(0, self.view.frame.size.height - kBottomToolBarHeight, self.view.frame.size.width, kBottomToolBarHeight);
            [self updateImageViewFrame:CGRectInfinite];
            currentSetting = MysticSettingNone;
            break;
        }
            
        default: break;
    }
    firstAppeared = YES;
}


- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
    if(firstDidAppear) return;
    firstDidAppear = YES;
    self.imageView.hidden = CGSizeIsZero(self.previewSize);
    mdispatch_default(^{
        [(MysticDrawerNavViewController *)self.drawer.navigationController loadSection:MysticDrawerSectionMain];
        [self rebuildBlurImage:nil renderedImage:[UserPotion potion].sourceImageResized];
    });
}



- (void) viewDidUnload;
{
    [self setOverlayView:nil];
    [self setLabelsView:nil];
    [self setShapesView:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.frame = CGRectSize([MysticUI screen]);
    self.view.backgroundColor = [UIColor hex:@"141412"];
    self.view.userInteractionEnabled = YES;
    self.view.multipleTouchEnabled = YES;
    [(MysticControllerView *)self.view setController:self];
    self.tabBar.tabBarDelegate = self;
    self.imageView.delegate = self;
    CGRect imageViewFrame = self.view.frame;
    self.imageView.frame = imageViewFrame;
    MysticFontStylesViewController *fontStylesC = [[[MysticFontStylesViewController alloc] initWithFrame:self.imageView.imageView.bounds delegate:self] autorelease];
    fontStylesC.parentView = self.view;
    self.fontStylesController = fontStylesC;
    self.labelsView = (MysticFontOverlaysView *)fontStylesC.view;
    [self.imageView.imageView addSubview:self.labelsView];
    [self.fontStylesController disableOverlays];
    self.progressView = [[[MysticProgressView alloc] initWithFrame:CGRectMake(0, PROGRESS_ANCHOR, self.view.frame.size.width, PROGRESS_HEIGHT)] autorelease];
    [self.view addSubview:self.progressView];
    self.bottomPanelView.frame = CGRectYWH(self.bottomPanelView.frame, imageViewFrame.origin.y + imageViewFrame.size.height, CGRectW(self.view.frame), kBottomToolBarHeight);
    self.bottomPanelView.clipsToBounds = YES;
    self.bottomToolbar.frame = CGRectWidth(self.bottomToolbar.frame, self.view.frame.size.width);
    self.bottomPanelView.blurBackground=YES;
    self.bottomPanelView.backgroundColor = self.view.backgroundColor;
    [self tabBar:nil];
    self.layerCountButton = [[[MysticLayerCountButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 25 - 13, 13, 25, 25)] autorelease];
    self.layerCountButton.hidden = ![MysticUser is:Mk_DEBUG];
    self.layerCountButton.backgroundColor = [self.view.backgroundColor alpha:0.6];
//    self.layerCountButton.layer.shadowColor = self.view.backgroundColor.CGColor;
//    self.layerCountButton.layer.shadowRadius = 2.0;
//    self.layerCountButton.layer.shadowOffset = CGSizeZero;
//    self.layerCountButton.layer.shadowOpacity = 0.6;
    [self.layerCountButton addTarget:self action:@selector(layerCountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.layerCountButton];
    [MysticTipView tip:@"addlayer" inView:self.view targetView:[self.tabBar tabForType:MysticSettingAddLayer] hideAfter:10 delay:1 animated:YES];
    
    
    

}
- (void) layerCountButtonTapped:(id)sender;
{
    [self longPress:sender];
}
- (void) setTestImage:(UIImage *)image;
{
    [self setTestImage:image frame:self.imageView.imageView.frame];
}
- (void) setTestImage:(UIImage *)image frame:(CGRect)newFrame;
{
    if(!self.testImageView)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:newFrame];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        MBorder(iv, nil, 2);
        self.testImageView = iv;
        [self.view addSubview:[iv autorelease]];
    }
    if(!image) { self.testImageView.alpha =0; return; }
    mdispatch( ^{
        [MysticController controller].testImageView.image = image;
        [[MysticController controller].testImageView setNeedsDisplay];
    });
}

- (void) addTransformView:(UIView *)transformView;
{
    
}
- (NSArray *) transformViews;
{
    NSMutableArray *layers = [NSMutableArray arrayWithArray:self.layersViews];
    if(self.overlayView) [layers addObject:self.overlayView];
//    if(self.sketchView) [layers addObject:self.sketchView];
    return layers;
}
- (NSArray *) dontTransformViews;
{
    return self.sketchView ? @[self.sketchView] : @[];
}
- (NSArray *) layersViews;
{
    NSMutableArray *layers = [NSMutableArray array];
    for (UIView *subview in self.view.subviews)
        if([subview isKindOfClass:[MysticOverlaysView class]] || [subview isKindOfClass:[MysticLabelsView class]] || [subview isKindOfClass:[MysticShapesOverlaysView class]])
            [layers addObject:subview];
    return layers;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if ([[touches anyObject] tapCount] == 2) [NSObject cancelPreviousPerformRequestsWithTarget:self];
}



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1)
    {
        if (self.areGesturesEnabled && CGRectContainsPoint(self.imageView.imageView.frame,[touch locationInView:self.view]))
        {
            if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen) [self tapped:nil];
            else [self performSelector:@selector(tapped:) withObject:nil afterDelay:0.2];
        }
        else
        {
            switch (self.parentSetting) {
                case MysticSettingShape:
                case MysticObjectTypeShape: [self.shapesController tapped:nil]; break;
                case MysticSettingType:
                case MysticObjectTypeFont:
                case MysticObjectTypeFontStyle: [self.fontStylesController tapped:nil]; break;
                default: break;
            }
        }
    } else if (self.areGesturesEnabled && touch.tapCount == 2) [self doubleTapped:nil];
}




#pragma mark -
#pragma mark Gestures
- (void) doubleTapped:(UITapGestureRecognizer *)sender;
{
    self.imageView.alpha = 1;
    if(self.isMenuVisible
       || (self.layerPanelView && CGRectContainsPoint(self.layerPanelView.frame, [sender locationInView:self.layerPanelView]))
       || (self.bottomPanelView && CGRectContainsPoint(self.bottomPanelView.frame, [sender locationInView:self.bottomPanelView]))
       ) return;
    [self logMenuItemClicked:nil];
}
- (void) setTransformOption:(PackPotionOption *)transformOption;
{
    if(_transformOption) [_transformOption release], _transformOption=nil;
    [[MysticOptions current] transform:transformOption];
    _transformOption = transformOption ? [transformOption retain] : nil;
}
- (void) resetTransformOption;
{
    PackPotionOption *option = self.transformOption;
    if(!option) return;
    if(self.layerPanelView)
    {
        if(!self.layerPanelView.animating && self.layerPanelView.state == MysticLayerPanelStateOpen)
        {
            [self.imageView.layer removeAllAnimations];
            self.imageView.alpha = 0.2;
            self.imageView.layer.opacity = 0.3;
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [animation setDuration:1/60];
            [animation setFromValue:@(0.3)];
            [animation setToValue:@(1.0)];
            [animation setRemovedOnCompletion:NO];
            [animation setFillMode:kCAFillModeForwards];
            [self.imageView.layer addAnimation:animation forKey:@"imageviewblink"];
            return;
        }
        else if(self.layerPanelView.animating) return;
    }
    MysticProgressHUD *mysthud = [[MysticProgressHUD alloc] initWithFrame:self.imageFrame];
    mysthud.underlyingView = self.imageView;
    mysthud.removeFromSuperViewOnHide = YES;
    mysthud.tag = MysticViewTypeHUD;
    mysthud.mode = MysticProgressHUDModeIndeterminate;
    mysthud.labelText = NSLocalizedString(@"Resetting", nil);
    if(self.moreToolsView) [self.moreToolsView fadeOut];
    [self addHud:mysthud];
    [mysthud show:YES];
    __unsafe_unretained __block MysticProgressHUD *__mystHud = mysthud;
    [option resetTransform];
    [self reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
        [__mystHud hide:YES afterDelay:0.1f];
    }];
    
}


- (void) tapped:(UITapGestureRecognizer *)sender;
{
    self.imageView.alpha = 1;
    if(self.isMenuVisible) return;
    BOOL updateMoreTools = YES;
    BOOL hideUIControls = NO;

    switch (self.currentSetting)
    {
        case MysticSettingLaunch:
        case MysticSettingPreferences:
        case MysticSettingNone:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm: hideUIControls=YES; break;
            
        case MysticSettingChooseFont:
        case MysticSettingEditType:
        case MysticSettingEditFont:
        case MysticSettingType:
        case MysticSettingTypeNew:
        case MysticSettingSelectType:
        case MysticSettingShape:
        case MysticSettingShare: updateMoreTools = NO; break;
        default: break;
    }
    
    if(updateMoreTools)
    {
        [self stopMoreToolsTimer];
        if(!self.moreToolsView && !self.preventToolsFromBeingVisible) [self toggleMoreTools:NO showForTime:-1 option:nil];
        else
        {
            self.moreToolsView.hidden = NO;
            if(self.moreToolsView.alpha < 1 && !self.preventToolsFromBeingVisible)
                [self.moreToolsView fadeInWithTimer:MYSTIC_TOOLS_TAP_FADEOUT_DELAY];
            else [self.moreToolsView fadeOutFast];
        }
    }
    if(hideUIControls)
    {
        if(self.navLeftView && self.navLeftView.hidden == NO) [self hideUIControlsDuration:0.15 completion:nil];
        else if(self.navLeftView && self.navLeftView.hidden) [self showUIControlsDuration:0.15 completion:nil];
    }
}

- (void) hideUIControlsDuration:(NSTimeInterval)dur completion:(MysticBlock)completion;
{
    if(dur <= 0)
    {
        self.navLeftView.hidden = YES;
        self.navRightView.hidden = YES;
        self.navCenterView.hidden = YES;
        self.undoRedoTools.hidden = YES;
        self.navLeftView.alpha = 0;
        self.navRightView.alpha = 0;
        self.undoRedoTools.alpha = 0;
        self.navCenterView.alpha = 0;
        if(completion) completion();
        return;
    }
    __unsafe_unretained __block MysticBlock _c = completion ? Block_copy(completion) : nil;
    [MysticUIView animate:dur animations:^{
        self.navLeftView.alpha = 0;
        self.navRightView.alpha = 0;
        self.navCenterView.alpha = 0;
        self.undoRedoTools.alpha = 0;
    } completion:^(BOOL finished) {
        self.navLeftView.hidden = YES;
        self.navRightView.hidden = YES;
        self.navCenterView.hidden = YES;
        self.undoRedoTools.hidden = YES;
        if(_c)
        {
            _c();
            Block_release(_c);
        }
    }];
}
- (void) showUIControlsDuration:(NSTimeInterval)dur completion:(MysticBlock)completion;
{

    if(dur <= 0)
    {
        self.navLeftView.hidden = NO;
        self.navRightView.hidden = NO;
        self.navCenterView.hidden = NO;
        self.undoRedoTools.hidden = NO;
        self.navLeftView.alpha = 1;
        self.navRightView.alpha = 1;
        self.navCenterView.alpha = 1;
        self.undoRedoTools.alpha = 1;
        if(completion) completion();
        return;
    }
    self.navLeftView.hidden = NO;
    self.navRightView.hidden = NO;
    self.navCenterView.hidden = NO;
    self.undoRedoTools.hidden = NO;
    self.navLeftView.alpha = 0;
    self.navRightView.alpha = 0;
    self.navCenterView.alpha = 0;
    self.undoRedoTools.alpha = 0;
    __unsafe_unretained __block MysticBlock _c = completion ? Block_copy(completion) : nil;

    [MysticUIView animate:dur animations:^{
        self.navLeftView.alpha = 1;
        self.navRightView.alpha = 1;
        self.navCenterView.alpha = 1;
        self.undoRedoTools.alpha = 1;
        
    } completion:^(BOOL finished) {
        if(_c)
        {
            _c();
            Block_release(_c);
        }
    }];
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    DLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer:  %@", otherGestureRecognizer);

    return YES;
}

- (void)panned:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption || self.didSwipe) { return; }
    switch (self.currentSetting) {
        case MysticObjectTypeText:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeImage:
        case MysticObjectTypeCustom:
        case MysticObjectTypeSetting:
        case MysticObjectTypeSourceSetting:
        case MysticSettingSettings:
        case MysticSettingFrame:
        case MysticSettingLighting:
        case MysticSettingTexture:
        case MysticSettingChooseText:
        case MysticSettingText:
        case MysticSettingTextAlpha:
        case MysticSettingTextColor:
        case MysticSettingBadgeColor:
        case MysticSettingCamLayerColor:
        case MysticSettingChooseBadge:
        case MysticSettingBadge:
        case MysticSettingChooseCamLayer:
        case MysticSettingCamLayer:
        case MysticSettingCamLayerSetup:
        case MysticSettingCamLayerAlpha:
        case MysticSettingEditText:
        case MysticSettingEditTexture:
        case MysticSettingEditLighting:
        case MysticSettingEditFrame: break;
        default: return;
    }
    __unsafe_unretained __block   MysticController *weakSelf = self;
    self.transformOption.refreshState = MysticSettingTransform;
    CGSize transRectSize = self.transformOption.transformRect.size;
    CGSize transRectSizeDefault = self.transformOption.adjustedRect.size;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            weakSelf.gestureNeedsReload = NO;
            panStartPoint = [sender locationInView:weakSelf.imageView.imageView];
            panLastPoint = self.transformOption.transformRect.origin;
            weakSelf.canRefreshEffects = YES;
            if(self.moreToolsView)
            {
                self.moreToolsView.hidden = YES;
                [self.moreToolsView stopTimer];
            }
            self.transformOption.isTransforming = YES;
            self.transformOption.inFocus = YES;
            if(!self.transformOption.transformFilter)
            {
                NSMutableString *ss = [NSMutableString string];
                for (MysticFilterLayer *layer in [MysticOptions current].filters.allLayers) {
                    [ss appendFormat:@"layer: %p  %@ (%@)\n", layer, layer.option.name, layer.option.optionSlotKey];
                }
                ErrorLog(@"panning beginning but there is no transform filter for option: %@   layer: \n%@", self.transformOption, ss);
                
                
                weakSelf.canRefreshEffects = NO;
                
            }
            return;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.isTransforming = NO;
            self.transformOption.hasChanged = YES;
            __unsafe_unretained __block MysticController *weakSelf = self;
            [MysticEffectsManager refresh:self.transformOption completion:^{
                weakSelf.moreToolsView.hidden = NO;
                weakSelf.moreToolsView.alpha = 0;
                
                [weakSelf refreshBlurImageFinished:^(NSArray *objs, BOOL success) {
                    if(weakSelf.moreToolsView && (!weakSelf.layerPanelView || weakSelf.layerPanelView.state != MysticLayerPanelStateOpen))
                        [weakSelf.moreToolsView fadeInWithTimer:MYSTIC_TOOLS_FADEIN_SHOWTIME];
                }];
                
            }];
            if(weakSelf.gestureNeedsReload) weakSelf.gestureNeedsReload = NO;
            else [[MysticOptions current] finishedRendering];
            return;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            BOOL reloadImage = NO;
            
            panEndPoint = [sender locationInView:weakSelf.imageView.imageView];
            
            CGSize imgViewActualSize = weakSelf.imageView.imageView.bounds.size;
            BOOL imgPortrait = imgViewActualSize.height > imgViewActualSize.width;
            
            CGPoint panDiffPoint = CGPointMake(panEndPoint.x - panStartPoint.x, panEndPoint.y - panStartPoint.y);
            
            panDeltaPoint = CGPointMake(panDiffPoint.x/imgViewActualSize.width, panDiffPoint.y/imgViewActualSize.height);
            
            CGFloat ratioY2 = !imgPortrait ? 1 : ((imgViewActualSize.height/imgViewActualSize.width) * (transRectSize.width/transRectSize.height));
            CGFloat ratioX2 = imgPortrait ? 1 : ((imgViewActualSize.width/imgViewActualSize.height) * (transRectSize.height/transRectSize.width));
            
            CGFloat ratioY = (ratioY2 * (transRectSizeDefault.height/transRectSize.height)) * transRectSizeDefault.height;
            CGFloat ratioX = (ratioX2 * (transRectSizeDefault.width/transRectSize.width)) * transRectSizeDefault.width;
            
            
            CGRect newRect = self.transformOption.transformRect;
            newRect.origin.x = panLastPoint.x + ((panDeltaPoint.x*2)*ratioX);
            newRect.origin.y = panLastPoint.y + ((panDeltaPoint.y*2)*ratioY);
            panEndPoint = CGPointZero;
            
            if(!CGRectEqualToRect(newRect, self.transformOption.transformRect))
            {
                self.transformOption.transformRect = newRect;
                [self.transformOption updateTransform:NO];
                reloadImage = YES;
            }
            
            if(reloadImage && weakSelf.canRefreshEffects) [MysticEffectsManager refresh:self.transformOption completion:nil];
            break;
        }
        default: break;
    }
    
}

- (void) swiped:(UISwipeGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    DLogRender(@"swiped: %@", @(sender.direction) );
    self.didSwipe = YES;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan: break;
        case UIGestureRecognizerStateEnded:
        {
            self.didSwipe = NO;
            break;
        }
        default: break;
    }
}

- (void)pinched:(UIPinchGestureRecognizer *)sender;
{
    __unsafe_unretained __block  MysticController *weakSelf = self;
    BOOL outputFirstDebug = NO;
    BOOL outputLastDebug = NO;
    BOOL reloadImage = NO;
    BOOL allowRender = YES;
    switch (weakSelf.currentSetting) {
        case MysticObjectTypeText:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
        case MysticObjectTypeCamLayer:
        case MysticSettingFrame:
        case MysticSettingLighting:
        case MysticSettingTexture:
        case MysticSettingChooseText:
        case MysticSettingText:
        case MysticSettingTextAlpha:
        case MysticSettingTextColor:
        case MysticSettingBadgeColor:
        case MysticSettingCamLayerColor:
        case MysticSettingChooseBadge:
        case MysticSettingBadge:
        case MysticSettingChooseCamLayer:
        case MysticSettingCamLayer:
        case MysticSettingCamLayerSetup:
        case MysticSettingCamLayerAlpha:
        case MysticSettingEditText:
        case MysticSettingEditTexture:
        case MysticSettingEditLighting:
        case MysticSettingEditFrame: break;
        default: return;
    }
    
    //    self.transformOption = self.transformOption ? self.transformOption : [weakSelf currentOption:weakSelf.currentSetting];
    if(!self.transformOption || sender.numberOfTouches < 2) return;
    
    self.transformOption.refreshState = MysticSettingTransform;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            weakSelf.gestureNeedsReload = NO;
            pinLastPoint = [sender locationInView:weakSelf.view];
            pinOriginalPoint = pinLastPoint;
            pinLastAnchor = self.transformOption.transformRect.origin;
            
            weakSelf.canRefreshEffects = NO;
            if(self.moreToolsView) { self.moreToolsView.hidden = YES; [self.moreToolsView stopTimer]; }
            
            self.transformOption.isTransforming = YES;
            weakSelf.canRefreshEffects = YES;
            
            CGPoint p1 = [sender locationOfTouch:0 inView:self.overlayView];
            CGPoint p2 = [sender locationOfTouch:1 inView:self.overlayView];
            CGFloat m = CGSizeMaxWH(CGSizeNormal(CGSizeFromMaxPoint(CGPointDiffABS(p1, CGPointMidPoint(p1, p2))), self.overlayView.frame.size));
//            m = MAX(MIN(1,m),0);
            self.originalPinchScale = m;

            return;
        }
        case UIGestureRecognizerStateEnded:
        {
            mLastScale = 1.0;
            self.transformOption.isTransforming = NO;
            self.transformOption.hasChanged = YES;
            
            __unsafe_unretained __block MysticController *weakSelf = self;
            [MysticEffectsManager refresh:self.transformOption completion:^{
                weakSelf.moreToolsView.hidden = NO;
                weakSelf.moreToolsView.alpha = 0;
                
                [weakSelf refreshBlurImageFinished:^(NSArray *objs, BOOL success) {
                    if(weakSelf.moreToolsView && (!weakSelf.layerPanelView || weakSelf.layerPanelView.state != MysticLayerPanelStateOpen))
                    {
                        [weakSelf.moreToolsView fadeInWithTimer:MYSTIC_TOOLS_FADEIN_SHOWTIME];
                        
                    }
                }];
                
            }];
            
            
            if(gestureNeedsReload)
            {
                [weakSelf reloadImage:NO];
                gestureNeedsReload = NO;
            }
            else [[MysticOptions current] finishedRendering];
            return;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            
            CGSize boxSize = weakSelf.imageView.imageViewFrame.size;
            
            mPreCurrentScale = mCurrentScale;
            mCurrentScale += [sender scale] - mLastScale;
            allowRender = !allowRender ? allowRender : ([sender scale] != mLastScale );
            
            mLastScale = [sender scale];
            CGPoint anchorPoint = CGPointZero;
            finalAnchor = self.transformOption.transformRect.origin;
            
            CGPoint point = [sender locationInView:weakSelf.view];
            CGPoint scaledCenterPoint = [MysticUI scalePoint:point scale:mCurrentScale];
            CGPoint driftPoint = CGPointMake(pinLastPoint.x - point.x, pinLastPoint.y - point.y);
            
            CGPoint distancePoint = CGPointZero;
            distancePoint.x = scaledCenterPoint.x - point.x;
            distancePoint.y = scaledCenterPoint.y - point.y;
            
            
            CGPoint sizePoint = distancePoint;
            CGPoint sizePointScaled = sizePoint;
            sizePointScaled.x = sizePointScaled.x/mCurrentScale;
            sizePointScaled.y = sizePointScaled.y/mCurrentScale;
            
            distancePoint.x = -(sizePointScaled.x/(boxSize.width));
            distancePoint.y = -(sizePointScaled.y/(boxSize.height));
            
            
            anchorPoint = distancePoint;
            
//            finalAnchor.x = (pinLastAnchor.x - anchorPoint.x)+driftPoint.x;
//            finalAnchor.y = (pinLastAnchor.y - anchorPoint.y)+driftPoint.y;
//            finalAnchor = anchorPoint;
//            finalAnchor.x = (finalAnchor.x)+(driftPoint.x/(boxSize.width));
//            finalAnchor.y = (finalAnchor.y)+(driftPoint.y/(boxSize.height));
            
            
            
            if(allowRender)
            {
                
                CGPoint p1 = [sender locationOfTouch:0 inView:self.overlayView];
                CGPoint p2 = [sender locationOfTouch:1 inView:self.overlayView];
                CGFloat m = CGSizeMaxWH(CGSizeNormal(CGSizeFromMaxPoint(CGPointDiffABS(p1, CGPointMidPoint(p1, p2))), self.overlayView.frame.size));
//                m = MAX(MIN(1,m),0);
                CGRect newRect = self.transformOption.transformRect;
                CGRect oRect = self.transformOption.transformRect;
                
//                newRect.size.width = self.transformOption.adjustedRect.size.width != 0 ? mCurrentScale * self.transformOption.adjustedRect.size.width : mCurrentScale;
//                newRect.size.height = self.transformOption.adjustedRect.size.height != 0 ? mCurrentScale * self.transformOption.adjustedRect.size.height : mCurrentScale;
                CGFloat d = m/self.originalPinchScale;
                float d2 = fabs(1.0-d)/2.5;
                float d3 = 1.0 + (d<1?-d2:d2);
                
                
//                newRect.size.width = m/self.originalPinchScale;
//                newRect.size.height = m/self.originalPinchScale;
                newRect.size.width = d3;
                newRect.size.height = d3;
//                
//                
//                CGSize imgSize = self.imageView.imageView.frame.size;
//                CGSize imgSizeNormal = CGSizeScale(imgSize, d3);
//                CGSize imgSizeNormalBefore = CGSizeMake(imgSize.width*oRect.size.width,imgSize.height*oRect.size.height);
//                CGPoint anchorP = CGPointOfNormal(newRect.origin, imgSize);
//                CGSize imgSizeDiff = CGSizeDiff(imgSizeNormalBefore, imgSizeNormal);
                
////                DLog(@"pinch: %2.2f  ->  %2.2f   (%2.2f | %2.2f == %2.2f)", self.originalPinchScale, m, d, d2, d3);
//                DLog(@"anchor:  %@     size: %2.3fx%2.3f     trans: %2.3fx%2.3f      new: %2.3fx%2.3f           diff: %2.5fx%2.5f", p(newRect.origin), imgSize.width,imgSize.height, imgSizeNormalBefore.width,imgSizeNormalBefore.height, imgSizeNormal.width,imgSizeNormal.height, imgSizeDiff.width,imgSizeDiff.height);
//                
//                newRect.origin = finalAnchor;
                
                if(!CGRectEqualToRect(newRect, self.transformOption.transformRect))
                {
                    self.transformOption.transformRect = newRect;
                    
                    self.transformOption.transformFilter.affineTransform = self.transformOption.transform;
                    reloadImage = YES;
                }
                
                if(reloadImage) [MysticEffectsManager refresh:self.transformOption];
                
            }
            break;
        }
        default: break;
    }
}

- (void) doubleTappedDistortStretch:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.stretchCenter = (CGPoint){0.5,0.5};
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageStretchDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortStretch];
            filter.center = self.transformOption.stretchCenter;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedDistortStretch:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    for (MysticDotView *dot in self.extraControls) {
        
        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            
            self.transformOption.stretchCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
            
            centerDot.center = [sender locationInView:self.view];
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageStretchDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortStretch];
            filter.center = self.transformOption.stretchCenter;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) doubleTappedDistortPinch:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.pinchRadius = kpinchRadius;
            self.transformOption.pinchCenter = (CGPoint){0.5,0.5};
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImagePinchDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortPinch];
            filter.radius = self.transformOption.pinchRadius;
            filter.center = self.transformOption.pinchCenter;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedDistortPinch:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    for (MysticDotView *dot in self.extraControls) {
        
        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            
            self.transformOption.pinchCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
            
            centerDot.center = [sender locationInView:self.view];
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImagePinchDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortPinch];
            filter.radius = self.transformOption.pinchRadius;
            filter.center = self.transformOption.pinchCenter;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) doubleTappedDistortBuldge:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.buldgeRadius = kbuldgeRadius;
            self.transformOption.buldgeCenter = (CGPoint){0.5,0.5};
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageBulgeDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortBuldge];
            filter.radius = self.transformOption.buldgeRadius;
            filter.center = self.transformOption.buldgeCenter;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedDistortBuldge:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    for (MysticDotView *dot in self.extraControls) {
        
        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            
            self.transformOption.buldgeCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
            
            centerDot.center = [sender locationInView:self.view];
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageBulgeDistortionFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortBuldge];
            filter.radius = self.transformOption.buldgeRadius;
            filter.center = self.transformOption.buldgeCenter;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) doubleTappedDistortSphere:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.sphereRadius = ksphereRadius;
            self.transformOption.sphereCenter = (CGPoint){0.5,0.5};
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageGlassSphereFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortGlassSphere];
            filter.radius = self.transformOption.sphereRadius;
            filter.center = self.transformOption.sphereCenter;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedDistortSphere:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    for (MysticDotView *dot in self.extraControls) {
        
        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            
            MysticDotView *touchDot = nil;
            CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
            for (MysticDotView *dot in self.extraControls) {
                CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
                
                if(CGRectContainsPoint(dotHitBounds, touch))
                {
                    CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
                    if(!touchDot || dotDist < distFromDot)
                    {
                        distFromDot = dotDist;
                        touchDot = dot;
                    }
                }
            }
            touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
            touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
            activeDot = touchDot;
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            
            self.transformOption.sphereCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
            
            centerDot.center = [sender locationInView:self.view];
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageGlassSphereFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortGlassSphere];
            filter.radius = self.transformOption.sphereRadius;
            filter.center = self.transformOption.sphereCenter;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) doubleTappedDistortSwirl:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.swirlRadius = kswirlRadius;
            self.transformOption.swirlCenter = (CGPoint){0.5,0.5};
            self.transformOption.swirlAngle = kswirlAngle;
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageSwirlFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortSwirl];
            filter.radius = self.transformOption.swirlRadius;
            filter.center = self.transformOption.swirlCenter;
            filter.angle = self.transformOption.swirlAngle;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedDistortSwirl:(UIPanGestureRecognizer *)sender;
{
    
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = self.extraControls.firstObject;
    MysticDotView *angleDot = self.extraControls.lastObject;
    
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastPoint = CGPointDiff(angleDot.center, centerDot.center);

            lastTouchValue = touch.y;
            
            MysticDotView *touchDot = nil;
            CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
            for (MysticDotView *dot in self.extraControls) {
                CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
                
                if(CGRectContainsPoint(dotHitBounds, touch))
                {
                    CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
                    if(!touchDot || dotDist < distFromDot)
                    {
                        distFromDot = dotDist;
                        touchDot = dot;
                    }
                }
            }
            touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
            touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
            activeDot = touchDot;
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            if([activeDot isEqual:centerDot])
            {
                self.transformOption.swirlCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
                centerDot.center = [sender locationInView:self.view];
                angleDot.center = (CGPoint){centerDot.center.x+lastPoint.x, centerDot.center.y + lastPoint.y};
                
            }
            else if([activeDot isEqual:angleDot])
            {
                CGFloat dist = CGPointDistanceFrom(angleDot.center, centerDot.center);
                CGFloat radians = CGPointAngle([sender locationInView:self.view], centerDot.center);
                angleDot.center = (CGPoint){cosf(radians) * -dist + centerDot.center.x,sinf(radians) * -dist + centerDot.center.y} ;
                self.transformOption.swirlAngle = radians;
            }
           
            
            
            
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageSwirlFilter *filter = [layer filterForKey:MysticLayerKeySettingDistortSwirl];
            filter.radius = self.transformOption.swirlRadius;
            filter.center = self.transformOption.swirlCenter;
            filter.angle = self.transformOption.swirlAngle;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
    
    
}

- (void) doubleTappedBlurZoom:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.blurZoomSize = kblurZoomSize;
            self.transformOption.blurZoomCenter = (CGPoint){0.5,0.5};
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];

            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageZoomBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurZoom];
            filter.blurSize = self.transformOption.blurZoomSize;
            filter.blurCenter = self.transformOption.blurZoomCenter;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedBlurZoom:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    for (MysticDotView *dot in self.extraControls) {

        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
           
            
            self.transformOption.blurZoomCenter =  CGPointNormal(touchLocation,self.imageView.imageView.frame);
            
            centerDot.center = [sender locationInView:self.view];
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageZoomBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurZoom];
            filter.blurSize = self.transformOption.blurZoomSize;
            filter.blurCenter = self.transformOption.blurZoomCenter;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) doubleTappedBlurMotion:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.blurMotionSize = kblurMotionSize;
            self.transformOption.blurMotionAngle = kblurMotionAngle;
            CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
            
            MysticDotView *centerDot = (MysticDotView *)self.extraControls.firstObject;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageMotionBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurMotion];
            filter.blurSize = self.transformOption.blurMotionSize;
            filter.blurAngle = self.transformOption.blurMotionAngle;
            [MysticEffectsManager refresh:self.transformOption];
            centerDot.center = centerPoint;
            break;
        }
        default: break;
    }
}
- (void) pannedBlurMotion:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = self.extraControls.firstObject;
    MysticDotView *angleDot = self.extraControls.lastObject;
    MysticDotView *touchDot = angleDot;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            CGFloat dist = CGPointDistanceFrom(angleDot.center, centerDot.center);
            CGPoint touch = [sender locationInView:self.view];
            CGFloat radians = CGPointAngle(touch, centerDot.center);
            CGPoint newPoint = CGPointZero;
            newPoint.y = sinf(radians) * -dist + centerDot.center.y;
            newPoint.x = cosf(radians) * -dist + centerDot.center.x;
            angleDot.center = newPoint;
            self.transformOption.blurMotionAngle = radianToDegrees(radians);
            if(!activeDot) lastTouchValue = touch.y;
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageMotionBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurMotion];
            filter.blurSize = self.transformOption.blurMotionSize;
            filter.blurAngle = self.transformOption.blurMotionAngle;
            [MysticEffectsManager refresh:self.transformOption];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}

- (void) doubleTappedBlurCircle:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.blurCircleExcludeRadius = kblurCircleExcludeRadius;
            self.transformOption.blurCircleAspectRatio = kblurCircleAspectRatio;
            self.transformOption.blurCirclePoint = (CGPoint){0.5,0.5};
            self.transformOption.blurCircleRadius = kblurCircleRadius;
            self.transformOption.blurCircleExcludeSize = kblurCircleExcludeSize;
            [self updateBlurCircleDots:sender.state];
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageGaussianSelectiveBlurFilter *tiltShift = [layer filterForKey:MysticLayerKeySettingBlurCircle];
            tiltShift.excludeCircleRadius = self.transformOption.blurCircleExcludeRadius;
            tiltShift.excludeCirclePoint = self.transformOption.blurCirclePoint;
            tiltShift.blurRadiusInPixels = self.transformOption.blurCircleRadius;
            tiltShift.excludeBlurSize = self.transformOption.blurCircleExcludeSize;
            tiltShift.aspectRatio = self.transformOption.blurCircleAspectRatio;
            [MysticEffectsManager refresh:self.transformOption];
            break;
        }
        default: break;
    }
}
- (void) pannedBlurCircle:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    MysticDotView *touchDot = nil;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = nil;
    UIView *circleView = nil;
    for (MysticDotView *dot in self.extraControls) {
        if(![dot isKindOfClass:[MysticDotView class]])
        {
            if(dot.tag == MysticViewTypeButton2)
            {
                circleView = (id)dot;
                continue;
            }
        }
        centerDot = dot;
        CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
        
        if(sender.state == UIGestureRecognizerStateBegan && CGRectContainsPoint(dotHitBounds, touch))
        {
            CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
            if(!touchDot || dotDist < distFromDot)
            {
                distFromDot = dotDist;
                touchDot = dot;
            }
        }
    }

    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            if(touchDot)
            {
                touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
                activeDot = touchDot;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint c2 = CGPointNormal([sender locationInView:self.imageView.imageView],self.imageView.imageView.frame);
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            CGPoint c3 = CGPointNormal(touchLocation,self.imageView.imageView.frame);
            CGRect bounds = [self.imageView.imageView.superview convertRect:self.imageView.imageView.frame toView:self.view];
            
            self.transformOption.blurCirclePoint = c3;
            
            centerDot.center = [sender locationInView:self.view];
            circleView.center = centerDot.center;
            if(!activeDot) lastTouchValue = touch.y;
            
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageGaussianSelectiveBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurCircle];
            filter.excludeCircleRadius = self.transformOption.blurCircleExcludeRadius;
            filter.excludeCirclePoint = self.transformOption.blurCirclePoint;
            filter.blurRadiusInPixels = self.transformOption.blurCircleRadius;
            filter.excludeBlurSize = self.transformOption.blurCircleExcludeSize;
            filter.aspectRatio = self.transformOption.blurCircleAspectRatio;
            [MysticEffectsManager refresh:self.transformOption];
            [self updateBlurCircleDots:sender.state];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) pinchedBlurCircle:(UIPinchGestureRecognizer *)recognizer;
{
    if(!self.transformOption || recognizer.numberOfTouches < 2) return;
    CGPoint p1 = [recognizer locationOfTouch:0 inView:self.imageView.imageView];
    CGPoint p2 = [recognizer locationOfTouch:1 inView:self.imageView.imageView];
    CGPoint pointDiff = CGPointDiffABS(p1, p2);
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastPinchValue = pointDiff.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGFloat changeDiff = lastPinchValue - pointDiff.y;
            CGFloat percentDiff = changeDiff/self.imageView.imageView.frame.size.height;
            //            DLogDebug(@"pinch: %2.4f -> %2.4f     %2.4f / %2.4f     %2.4f / %2.4f", changeDiff, percentDiff, self.transformOption.tiltShiftTop, self.transformOption.tiltShiftBottom, self.transformOption.tiltShiftTop + percentDiff, self.transformOption.tiltShiftBottom + percentDiff);
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageGaussianSelectiveBlurFilter *filter = [layer filterForKey:MysticLayerKeySettingBlurCircle];
            
            filter.excludeCircleRadius -= percentDiff;
            self.transformOption.blurCircleExcludeRadius = filter.excludeCircleRadius;
            
            [self updateBlurCircleDots:recognizer.state];
            [MysticEffectsManager refresh:self.transformOption];
            lastPinchValue = pointDiff.y;
            break;
        }
        default: break;
    }
}



- (void) updateBlurCircleDots:(UIGestureRecognizerState)state;
{
    MysticDotView *top = [self.view viewWithTag:MysticViewTypeButton1];
    UIView *circle = [self.view viewWithTag:MysticViewTypeButton2];
    
    CGRect bounds = [self.imageView.imageView.superview convertRect:self.imageView.imageView.frame toView:self.view];
    
    CGFloat excludeRadius = (bounds.size.width)*self.transformOption.blurCircleExcludeRadius;
    circle.bounds = (CGRect){0,0,excludeRadius*2,excludeRadius*2};
    circle.center = top.center;
    circle.layer.cornerRadius = circle.bounds.size.width/2;
  
}


- (void) tappedTiltShift:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint c = [sender locationInView:self.imageView.imageView];
            //            self.transformOption.vignetteCenter = CGPointNormal(c,self.imageView.imageView.frame);
            //            [self updateVignetteDots];
            //            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
            [MysticEffectsManager refresh:self.transformOption];
            break;
        }
        default: break;
    }
}
- (void) doubleTappedTiltShift:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            self.transformOption.tiltShift = kTiltShift;
            self.transformOption.tiltShiftTop = kTiltShiftMin;
            self.transformOption.tiltShiftBottom = kTiltShiftMax;
            self.transformOption.tiltShiftFallOff = kTiltShiftFallOffRate;
            self.transformOption.tiltShiftBlurSizeInPixels = kTiltShiftBlurRadius;
            [self updateTiltShiftDots:sender.state];
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageTiltShiftFilter *tiltShift = [layer filterForKey:MysticLayerKeySettingTiltShift];
            tiltShift.topFocusLevel = self.transformOption.tiltShiftTop;
            tiltShift.bottomFocusLevel = self.transformOption.tiltShiftBottom;
            tiltShift.focusFallOffRate = self.transformOption.tiltShiftFallOff;
            tiltShift.blurRadiusInPixels = self.transformOption.tiltShiftBlurSizeInPixels;

            [MysticEffectsManager refresh:self.transformOption];
            break;
        }
        default: break;
    }
}
- (void) pannedTiltShift:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    CGPoint touch = [sender locationInView:self.view];

    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            lastTouchValue = touch.y;
            
            MysticDotView *touchDot = nil;
            CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
            for (MysticDotView *dot in self.extraControls) {
                CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
                
                if(CGRectContainsPoint(dotHitBounds, touch))
                {
                    CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
                    if(!touchDot || dotDist < distFromDot)
                    {
                        distFromDot = dotDist;
                        touchDot = dot;
                    }
                }
            }
            touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
            touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
            activeDot = touchDot;
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint c2 = CGPointNormal([sender locationInView:self.imageView.imageView],self.imageView.imageView.frame);
            CGFloat diff = (self.transformOption.tiltShiftBottom - self.transformOption.tiltShiftTop);
            if(activeDot)
            {
                CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
                CGPoint c3 = CGPointNormal(touchLocation,self.imageView.imageView.frame);
                CGRect bounds = [self.imageView.imageView.superview convertRect:self.imageView.imageView.frame toView:self.view];

                
                switch (activeDot.tag) {
                    case MysticViewTypeButton1:
                        if(c3.y < self.transformOption.tiltShiftBottom) self.transformOption.tiltShiftTop = c3.y;

                        break;
                    case MysticViewTypeButton2:
                    {
                        MysticDotView *topDot, *bottomDot = nil;
                        
                        for (MysticDotView *dot in self.extraControls) {
                            if(dot.tag == MysticViewTypeButton1) { topDot = dot; continue; }
                            else if(dot.tag == MysticViewTypeButton3) { bottomDot = dot; continue; }
                        }
                        CGFloat fallOffDistance = topDot.center.y - bounds.origin.y;
                        CGFloat fallOffPercent = 1.0 - (touchLocation.y/fallOffDistance);

                        if(self.transformOption.tiltShiftTop < 0)
                        {
                            CGPoint bottomPoint = [bottomDot.superview convertPoint:bottomDot.center toView:self.imageView.imageView];

                            fallOffDistance = bounds.origin.y + bounds.size.height - bottomDot.center.y;
                            fallOffPercent = ((touchLocation.y-bottomPoint.y)/fallOffDistance);
                        }
                        self.transformOption.tiltShiftFallOff = fallOffPercent > 0 ? fallOffPercent/2 : 0;

//                        if(sender.state == UIGestureRecognizerStateEnded)
//                        {
//                            ALLog(@"pan top2", @[@"touch %2.2f", @(touchLocation.y),
//                                                 @"fallOffDistance %2.2f", @(fallOffDistance),
//                                                 @"percent %2.2f", @(fallOffPercent),
//                                                 @"-",
//                                                 @"bounds", FLogStr(bounds),
//                                                 @"top dot %2.2f", @(topDot.center.y),
//                                                 @"bottom dot %2.2f", @(bottomDot.center.y),
//                                                 @"top tilt %2.2f", @(self.transformOption.tiltShiftTop),
//                                                 @"fall off %2.2f", @(self.transformOption.tiltShiftFallOff),
//
//                                                 ]);
//                            
//                        }
                        bgAlpha = 0.1;
                        break;
                    }
                    case MysticViewTypeButton3:
                        if(c3.y > self.transformOption.tiltShiftTop) self.transformOption.tiltShiftBottom = c3.y;
                        break;
                    case MysticViewTypeButton4:
                    {
                        MysticDotView *topDot, *bottomDot = nil;
                        
                        for (MysticDotView *dot in self.extraControls) {
                            if(dot.tag == MysticViewTypeButton1) { topDot = dot; continue; }
                            else if(dot.tag == MysticViewTypeButton3) { bottomDot = dot; continue; }
                        }
                        
                        CGPoint bottomPoint = [bottomDot.superview convertPoint:bottomDot.center toView:self.imageView.imageView];

                        CGFloat fallOffDistance = bounds.origin.y + bounds.size.height - bottomDot.center.y;
                        CGFloat fallOffPercent = ((touchLocation.y-bottomPoint.y)/fallOffDistance);
                        
                        if(self.transformOption.tiltShiftBottom < 0)
                        {
                            fallOffDistance = topDot.center.y - bounds.origin.y;
                            fallOffPercent = 1.0 - (touchLocation.y/fallOffDistance);
                        }
                        self.transformOption.tiltShiftFallOff = fallOffPercent > 0 ? fallOffPercent/2 : 0;

//                        if(sender.state == UIGestureRecognizerStateEnded)
//                        {
//                            ALLog(@"pan bottom 2", @[@"touch %2.2f", @(touchLocation.y),
//                                                     @"touch2 %2.2f", @(touchLocation.y-bottomPoint.y),
//                                                     @"bottom point %2.2f", @(bottomPoint.y),
//                                                 @"fallOffDistance %2.2f", @(fallOffDistance),
//                                                 @"percent %2.2f", @(fallOffPercent),
//                                                 @"-",
//                                                 @"bounds", FLogStr(bounds),
//                                                 @"top dot %2.2f", @(topDot.center.y),
//                                                 @"bottom dot %2.2f", @(bottomDot.center.y),
//                                                 @"bottom tilt %2.2f", @(self.transformOption.tiltShiftBottom),
//                                                 @"fall off %2.2f", @(self.transformOption.tiltShiftFallOff),
//
//                                                 ]);
//                            
//                        }
                        bgAlpha = 0.1;
                        break;
                    }
                    default:
                        break;
                }
            }
            else
            {
                
                CGFloat touchDist = touch.y - lastTouchValue;
                CGFloat touchDistABS = touchDist < 0 ? touchDist*-1 : touchDist;
                CGFloat touchDistPercentOfSize = touchDistABS/self.imageView.imageView.frame.size.height;
          
                self.transformOption.tiltShiftTop = self.transformOption.tiltShiftTop + (touchDist < 0 ? touchDistPercentOfSize*-1 : touchDistPercentOfSize);
                self.transformOption.tiltShiftBottom = self.transformOption.tiltShiftTop + diff;
                
                lastTouchValue = touch.y;
                
            }
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageTiltShiftFilter *tiltShift = [layer filterForKey:MysticLayerKeySettingTiltShift];
            tiltShift.topFocusLevel = self.transformOption.tiltShiftTop;
            tiltShift.bottomFocusLevel = self.transformOption.tiltShiftBottom;
            tiltShift.focusFallOffRate = self.transformOption.tiltShiftFallOff;
            tiltShift.blurRadiusInPixels = self.transformOption.tiltShiftBlurSizeInPixels;
            [MysticEffectsManager refresh:self.transformOption];
            [self updateTiltShiftDots:sender.state];
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                activeDot.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
}
- (void) pinchedTiltShift:(UIPinchGestureRecognizer *)recognizer;
{
    if(!self.transformOption || recognizer.numberOfTouches < 2) return;
    CGPoint p1 = [recognizer locationOfTouch:0 inView:self.imageView.imageView];
    CGPoint p2 = [recognizer locationOfTouch:1 inView:self.imageView.imageView];
    CGPoint pointDiff = CGPointDiffABS(p1, p2);
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastPinchValue = pointDiff.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGFloat changeDiff = lastPinchValue - pointDiff.y;
            CGFloat percentDiff = changeDiff/self.imageView.imageView.frame.size.height;
//            DLogDebug(@"pinch: %2.4f -> %2.4f     %2.4f / %2.4f     %2.4f / %2.4f", changeDiff, percentDiff, self.transformOption.tiltShiftTop, self.transformOption.tiltShiftBottom, self.transformOption.tiltShiftTop + percentDiff, self.transformOption.tiltShiftBottom + percentDiff);
            MysticFilterLayer *layer = [[MysticOptions current].filters layerForOption:self.transformOption];
            GPUImageTiltShiftFilter *tiltShift = [layer filterForKey:MysticLayerKeySettingTiltShift];
            CGFloat top = self.transformOption.tiltShiftTop + percentDiff;
            CGFloat bottom = self.transformOption.tiltShiftBottom + (percentDiff*-1);
            tiltShift.topFocusLevel = top < self.transformOption.tiltShiftBottom ? top : self.transformOption.tiltShiftTop;
            tiltShift.bottomFocusLevel = bottom > self.transformOption.tiltShiftTop ? bottom : self.transformOption.tiltShiftBottom;
            self.transformOption.tiltShiftTop = tiltShift.topFocusLevel;
            self.transformOption.tiltShiftBottom = tiltShift.bottomFocusLevel;
            
            [self updateTiltShiftDots:recognizer.state];
            [MysticEffectsManager refresh:self.transformOption];
            lastPinchValue = pointDiff.y;
            break;
        }
        default: break;
    }
}

- (void) updateTiltShiftDots:(UIGestureRecognizerState)state;
{
    MysticDotView *top = [self.view viewWithTag:MysticViewTypeButton1];
    MysticDotView *top2 = [self.view viewWithTag:MysticViewTypeButton2];
    MysticDotView *bottom = [self.view viewWithTag:MysticViewTypeButton3];
    MysticDotView *bottom2 = [self.view viewWithTag:MysticViewTypeButton4];
    
    CGRect bounds = [self.imageView.imageView.superview convertRect:self.imageView.imageView.frame toView:self.view];
    CGPoint centerPoint = [self.imageView.imageView.superview convertPoint:self.imageView.imageView.center toView:self.view];
    
    CGPoint topPoint = (CGPoint){top.center.x, (centerPoint.y - (bounds.size.height/2))};
    CGPoint bottomPoint = (CGPoint){top.center.x, (centerPoint.y + bounds.size.height/2)};
    CGPoint topPoint2 = topPoint;
    CGPoint bottomPoint2 = bottomPoint;
    
    bottomPoint.y = bottomPoint.y - (bounds.size.height * (1-self.transformOption.tiltShiftBottom));
    topPoint.y = topPoint.y + (bounds.size.height *self.transformOption.tiltShiftTop);
    topPoint2.y = topPoint.y - ((topPoint.y - bounds.origin.y) * (self.transformOption.tiltShiftFallOff*2));
    bottomPoint2.y = bottomPoint.y + ((bounds.origin.y + bounds.size.height - bottomPoint.y) * (self.transformOption.tiltShiftFallOff*2));

    if(topPoint2.y + 2 + top2.bounds.size.height/2 >= (topPoint.y-top.bounds.size.height/2))
    {
        topPoint2.y = topPoint.y-2-top.bounds.size.height/2-top2.bounds.size.height/2;
    }
    if(bottomPoint2.y - 2 - bottom2.bounds.size.height/2 <= (bottomPoint.y+bottom.bounds.size.height/2))
    {
        bottomPoint2.y = bottomPoint.y+2+bottom.bounds.size.height/2+bottom2.bounds.size.height/2;
    }
    
    top.center = topPoint;
    bottom.center = bottomPoint;
    top2.center = topPoint2;
    bottom2.center = bottomPoint2;
//    if(state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
//            ALLog(@"updateTiltShiftDots", @[
//                                @"tilt top %2.2f", @(self.transformOption.tiltShiftTop),
//                                @"tilt bottom %2.2f", @(self.transformOption.tiltShiftBottom),
//                                @"tilt fall %2.2f", @(self.transformOption.tiltShiftFallOff),
//                                 @"bounds", FLogStr(bounds),
//                                 @" - ",
//                                 @"top %2.2f", @(topPoint.y),
//                                 @"top 2 %2.2f", @(top2.center.y),
//    
//                                 @"center %2.2f", @(centerPoint.y),
//                                 @"bottom 2 %2.2f", @(bottom2.center.y),
//    
//                                 @"bottom %2.2f", @(bottom.center.y)]);
}


- (void) tappedVignette:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint c = [sender locationInView:self.imageView.imageView];
            self.transformOption.vignetteCenter = CGPointNormal(c,self.imageView.imageView.frame);
            [self updateVignetteDots];
            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
            [MysticEffectsManager refresh:self.transformOption];
            break;
        }
        default: break;
    }
}
- (void) doubleTappedVignette:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint c = [sender locationInView:self.imageView.imageView];
            MysticDotView *centerDot = [self.extraControls objectAtIndex:2];
            MysticDotView *rightDot = self.extraControls.lastObject;
            MysticDotView *leftDot = self.extraControls.firstObject;
            MysticDotView *leftDot2 = [self.extraControls objectAtIndex:1];
            MysticDotView *rightDot2 = [self.extraControls objectAtIndex:3];
            
            CGPoint newOtherCenter = leftDot.center;
            CGFloat dx = centerDot.center.x - leftDot.center.x;
            CGFloat dx2 = centerDot.center.x - leftDot2.center.x;
            
            
            self.transformOption.vignetteCenter = CGPointVignetteCenterDefault;
//            self.transformOption.vignetteStart = kVignetteStart;
//            self.transformOption.vignetteEnd = kVignetteEnd;
            [self updateVignetteDots];
            
            newOtherCenter.y = centerDot.center.y;
            newOtherCenter.x = centerDot.center.x - dx;
            leftDot.center = newOtherCenter;
            
            newOtherCenter.x = centerDot.center.x - dx2;
            leftDot2.center = newOtherCenter;
            
            newOtherCenter.x = centerDot.center.x + dx;
            rightDot.center = newOtherCenter;
            
            newOtherCenter.x = centerDot.center.x + dx2;
            rightDot2.center = newOtherCenter;
            
            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
            [MysticEffectsManager refresh:self.transformOption];
            break;
        }
        default: break;
    }
}
- (void) pannedVignette2:(UIPanGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint c = [sender locationInView:self.imageView.imageView];
            self.transformOption.vignetteCenter = CGPointNormal(c,self.imageView.imageView.frame);
            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
            [MysticEffectsManager refresh:self.transformOption];
            [self updateVignetteDots];
            break;
        }
        default: break;
    }
}


- (void) pannedVignette:(UIPanGestureRecognizer *)sender;
{
    
    if(!self.transformOption) return;
    CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
    CGPoint touch = [sender locationInView:self.view];
    MysticDotView *centerDot = [self.extraControls objectAtIndex:2];
    MysticDotView *rightDot = self.extraControls.lastObject;
    MysticDotView *leftDot = self.extraControls.firstObject;
    MysticDotView *leftDot2 = [self.extraControls objectAtIndex:1];
    MysticDotView *rightDot2 = [self.extraControls objectAtIndex:3];

    MysticDotView *touchDot = nil;

    CGFloat start = self.transformOption.vignetteStart;
    CGFloat end = self.transformOption.vignetteEnd;
    
    CGFloat newStart = start;
    CGFloat newEnd = end;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastTouchValue = touch.y;
            MysticDotView *touchDot = nil;
            CGFloat distFromDot = MYSTIC_FLOAT_UNKNOWN;
            for (MysticDotView *dot in self.extraControls) {
                CGRect dotHitBounds = UIEdgeInsetsInsetRect(dot.frame, dot.hitInsets);
                
                if(CGRectContainsPoint(dotHitBounds, touch))
                {
                    CGFloat dotDist = CGPointDistanceFrom(touch, dot.center);
                    if(!touchDot || dotDist < distFromDot)
                    {
                        distFromDot = dotDist;
                        touchDot = dot;
                    }
                }
            }
            touchDot.backgroundColor = [touchDot.backgroundColor colorWithAlphaComponent:1];
            if([touchDot isEqual:leftDot2] || [touchDot isEqual:rightDot2])
            {
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
            }
            else
            {
                touchDot.transform = CGAffineTransformMakeScale(1.5, 1.5);
            }
            activeDot = touchDot;
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGFloat bgAlpha = 0.4;
            CGPoint touchLocation = [sender locationInView:self.imageView.imageView];
            
            if([activeDot isEqual:centerDot])
            {
                CGPoint c = [sender locationInView:self.imageView.imageView];
                self.transformOption.vignetteCenter = CGPointNormal(c,self.imageView.imageView.frame);
                CGPoint newOtherCenter = leftDot.center;
                CGFloat dx = centerDot.center.x - leftDot.center.x;
                CGFloat dx2 = centerDot.center.x - leftDot2.center.x;
                centerDot.center = [sender locationInView:self.view];
                newOtherCenter.x = centerDot.center.x - dx;
                newOtherCenter.y = centerDot.center.y;
                leftDot.center = newOtherCenter;
                newOtherCenter.x = centerDot.center.x + dx;
                rightDot.center = newOtherCenter;
                newOtherCenter.x = centerDot.center.x - dx2;
                leftDot2.center = newOtherCenter;
                newOtherCenter.x = centerDot.center.x + dx2;
                rightDot2.center = newOtherCenter;
                leftDot.transform = CGAffineTransformMakeScale(.5, .5);
                rightDot.transform = leftDot.transform;
                leftDot2.transform = leftDot.transform;
                rightDot2.transform = leftDot.transform;
            }
            else if([activeDot isEqual:rightDot])
            {
                CGPoint newPoint = [sender locationInView:self.view];
                CGFloat centerX = rightDot2.center.x + rightDot2.frame.size.width/2 + rightDot.frame.size.width/2;
                newPoint.x = MAX(centerX, newPoint.x);
                newPoint.y = leftDot.center.y;
                rightDot.center = newPoint;
                CGPoint newOtherCenter = leftDot.center;
                newOtherCenter.x = centerDot.center.x - (newPoint.x - centerDot.center.x);
                leftDot.center = newOtherCenter;
                leftDot.transform = rightDot.transform;
            }
            else if([activeDot isEqual:leftDot])
            {
                CGPoint newPoint = [sender locationInView:self.view];
                CGFloat centerX = leftDot2.center.x - leftDot2.frame.size.width/2 - leftDot.frame.size.width/2;
                newPoint.x = MIN(centerX, newPoint.x);
                newPoint.y = leftDot.center.y;
                leftDot.center = newPoint;
                CGPoint newOtherCenter = rightDot.center;
                newOtherCenter.x = centerDot.center.x + (centerDot.center.x - newPoint.x);
                rightDot.center = newOtherCenter;
                rightDot.transform = leftDot.transform;
            }
            else if([activeDot isEqual:rightDot2])
            {
                CGPoint newPoint = [sender locationInView:self.view];
                CGFloat centerX = centerDot.center.x + centerDot.frame.size.width/2 + rightDot2.frame.size.width/2;
                CGFloat centerXmin = rightDot.center.x - rightDot.frame.size.width/2 - rightDot2.frame.size.width/2;
                newPoint.x = MIN(MAX(centerX, newPoint.x), centerXmin);
                newPoint.y = leftDot.center.y;
                rightDot2.center = newPoint;
                CGPoint newOtherCenter = leftDot2.center;
                newOtherCenter.x = centerDot.center.x - (newPoint.x - centerDot.center.x);
                leftDot2.center = newOtherCenter;
                leftDot2.transform = rightDot2.transform;
            }
            else if([activeDot isEqual:leftDot2])
            {
                CGPoint newPoint = [sender locationInView:self.view];
                CGFloat centerX = centerDot.center.x - centerDot.frame.size.width/2 - leftDot.frame.size.width/2;
                CGFloat centerXmax = leftDot.center.x + leftDot.frame.size.width/2 + leftDot2.frame.size.width/2;
                newPoint.x = MAX(MIN(centerX, newPoint.x), centerXmax);
                newPoint.y = leftDot.center.y;
                leftDot2.center = newPoint;
                CGPoint newOtherCenter = rightDot.center;
                newOtherCenter.x = centerDot.center.x + (centerDot.center.x - newPoint.x);
                rightDot2.center = newOtherCenter;
                rightDot2.transform = leftDot2.transform;
            }
            
            CGFloat distFromCenter = rightDot.center.x - centerDot.center.x;
            CGFloat percentOfWidth = distFromCenter/self.imageView.imageView.frame.size.width;
            newEnd = percentOfWidth;
            
            CGFloat distFromCenter2 = rightDot2.center.x - centerDot.center.x;
            CGFloat percentOfWidth2 = distFromCenter2/self.imageView.imageView.frame.size.width;
            newStart = percentOfWidth2;
            
            self.transformOption.vignetteEnd = newEnd;
            self.transformOption.vignetteStart = newStart;
            
            if(!activeDot) lastTouchValue = touch.y;
            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
            [MysticEffectsManager refresh:self.transformOption];
            [self updateVignetteDots];
            
            
            if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
            {
                activeDot.backgroundColor = [activeDot.backgroundColor colorWithAlphaComponent:bgAlpha];
                leftDot.transform = CGAffineTransformIdentity;
                rightDot.transform = CGAffineTransformIdentity;
                centerDot.transform = CGAffineTransformIdentity;
                leftDot2.transform = CGAffineTransformIdentity;
                rightDot2.transform = CGAffineTransformIdentity;
                activeDot = nil;
            }
            break;
        }
        default: break;
    }
    
    
}


- (void) pinchedVignette:(UIPinchGestureRecognizer *)recognizer;
{
    return;
//    if(!self.transformOption || recognizer.numberOfTouches < 2) return;
//    switch (recognizer.state) {
//        case UIGestureRecognizerStateChanged:
//        case UIGestureRecognizerStateBegan:
//        {
//            CGPoint p1 = [recognizer locationOfTouch:0 inView:self.imageView.imageView];
//            CGPoint p2 = [recognizer locationOfTouch:1 inView:self.imageView.imageView];
//            CGFloat m = CGSizeMaxWH(CGSizeNormal(CGSizeFromMaxPoint(CGPointDiffABS(p1, CGPointMidPoint(p1, p2))), self.imageView.imageView.frame.size));
//            self.transformOption.vignetteStart = MAX(MIN(1,m),0);
//            self.transformOption.vignetteEnd = MAX(MIN(1,m*2 + self.transformOption.vignetteStart),0);
//            [self updateVignetteDots];
//            [[MysticOptions current].filters.filter setVignette:self.transformOption.vignetteCenter color:self.transformOption.vignetteColor start:self.transformOption.vignetteStart end:self.transformOption.vignetteEnd option:self.transformOption];
//            [MysticEffectsManager refresh:self.transformOption];
//            break;
//        }
//        default: break;
//    }
}
- (void) setExtraControlsSetting:(MysticObjectType)extraControlsSetting;
{
    _extraControlsSetting = extraControlsSetting;
    switch(extraControlsSetting)
    {
        case MysticSettingVignette: [self updateVignetteDots]; break;
        case MysticSettingTiltShift: [self updateTiltShiftDots:UIGestureRecognizerStateBegan]; break;
        case MysticSettingBlurCircle: [self updateBlurCircleDots:UIGestureRecognizerStateRecognized]; break;

        default: break;
    }
}
- (void) removeExtraControls;
{
    [self removeExtraControlsExcept:nil];
}
- (void) removeExtraControlsExcept:(NSArray *)exceptions;
{
    if(!self.extraControls || self.extraControls.count == 0) return;
    NSMutableArray *removed = [NSMutableArray arrayWithArray:self.extraControls];
    for (UIView *control in self.extraControls) {
        if(exceptions && exceptions.count && [exceptions containsObject:control]) continue;
        [control removeFromSuperview];
        [removed removeObject:control];
    }
    self.extraControls = removed;
    
}
- (void) updateVignetteDots;
{
    MysticDotView *left = [self.view viewWithTag:MysticViewTypeButton1];
    MysticDotView *center = [self.view viewWithTag:MysticViewTypeButton2];
    MysticDotView *right = [self.view viewWithTag:MysticViewTypeButton3];

    CGRect bounds = self.imageView.imageView.frame;
    bounds = [self.imageView.imageView.superview convertRect:bounds toView:self.view];
    CGSize imageSize = self.imageView.imageView.frame.size;
    CGPoint centerPoint = (CGPoint){imageSize.width*self.transformOption.vignetteCenter.x, imageSize.height*self.transformOption.vignetteCenter.y};
    
    centerPoint = [self.imageView.imageView convertPoint:centerPoint toView:center.superview];
    
    
    CGFloat size = imageSize.width/2 ;
    CGFloat start = size * self.transformOption.vignetteStart;
    CGFloat end = size * self.transformOption.vignetteEnd;
    CGFloat diff = (end - start)/2;
    
    CGPoint leftPoint = centerPoint;
    CGPoint rightPoint = centerPoint;
    leftPoint.x = center.center.x - (end + diff*1.75);
    rightPoint.x = center.center.x + (end + diff*1.75);
    center.center = centerPoint;
//    left.center = leftPoint;
//    right.center = rightPoint;

//    ALLog(@"vignette", @[@"start", @(self.transformOption.vignetteStart),
//                         @"center", PLogStr(self.transformOption.vignetteCenter),
//                         @"end", @(self.transformOption.vignetteEnd),
//                         @" - ",
//                         @"left", PLogStr(left.center),
//                         @"center", PLogStr(center.center),
//                         @"right", PLogStr(right.center)]);
    
}


- (void) longPress:(UILongPressGestureRecognizer *) sender {
    MysticObjectType ot = MysticTypeForSetting(self.currentSetting, self.currentOption);
    BOOL showDefaultMenu = NO;
    CGRect targetRect = CGRectZero;
    NSMutableArray *menu = [NSMutableArray array];
    if ([sender isKindOfClass:[UIView class]] || [sender state] == UIGestureRecognizerStateBegan) {
        
        if([sender isKindOfClass:[UIGestureRecognizer class]])
        {
            showDefaultMenu = self.isMenuVisible == NO;
            targetRect = CGRectPointAddY([sender locationInView:self.view], -24);
        }
        else if([sender isKindOfClass:[UIView class]])
        {
            targetRect = CGRectPoint([(UIView *)sender center]);
            showDefaultMenu = YES;
        }
        self.isMenuVisible = YES;
        switch (ot) {
            case MysticObjectTypeBadge:
            case MysticObjectTypeText:
            case MysticObjectTypeTexture:
            case MysticObjectTypeLight:
            case MysticObjectTypeFrame:
            case MysticObjectTypeFilter:
            case MysticObjectTypeImage:
            case MysticObjectTypeCamLayer:
            case MysticObjectTypeCustom:
            {
                if(showDefaultMenu) break;
#ifdef DEBUG
                [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Crash" action:@selector(crashMenuItemTouched:)] autorelease]];
#endif
                [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Undo" action:@selector(resetMenuItemClicked:)] autorelease]];
                [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Log" action:@selector(logMenuItemClicked:)] autorelease]];
                [menu addObject:[[[UIMenuItem alloc] initWithTitle:[MysticUser is:Mk_DEBUG] ? @"Off" : @"On" action:@selector(debugMenuItemClicked:)] autorelease]];
                break;
            }
            default:
                switch (self.currentSetting) {
                    case MysticObjectTypeAll:
                    case MysticSettingLaunch:
                    case MysticSettingNone:
                    case MysticSettingNoneFromLoadProject:
                    case MysticSettingNoneFromBack:
                    case MysticSettingNoneFromCancel:
                    case MysticSettingNoneFromConfirm: showDefaultMenu=YES; break;
                    default: break;
                }
                break;
        }
        if(showDefaultMenu && !menu.count)
        {
            if(imageInClipboard()) [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Paste" action:@selector(pasteNewLayer:)] autorelease]];
            if([UserPotion hasPreviousHistory]) [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Undo" action:@selector(undoMenuItemClicked:)] autorelease]];
            if([UserPotion hasNextHistory]) [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Redo" action:@selector(redoMenuItemClicked:)] autorelease]];
#ifdef DEBUG
//            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"FLEX" action:@selector(flexMenuItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Potion" action:@selector(savePotionItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Log" action:@selector(logMenuItemClicked:)] autorelease]];

            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Crash" action:@selector(crashMenuItemTouched:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:[MysticUser is:Mk_DEBUG] ? @"Off" : @"On" action:@selector(debugMenuItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:[[NSString fraction:[MysticUser getf:Mk_TIME]] suffix:@"x"] action:@selector(timeMenuItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Scale" action:@selector(scaleMenuItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Shader" action:@selector(shaderFileMenuItemClicked:)] autorelease]];
            [menu addObject:[[[UIMenuItem alloc] initWithTitle:@"Forget" action:@selector(userForgetAllTouched:)] autorelease]];

#endif
            

        }
        self.imageView.alpha = [sender isKindOfClass:[UIGestureRecognizer class]] ? .6f : self.imageView.alpha;
        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = menu;
        [menuController setTargetRect:targetRect inView:self.view];
        [menuController setMenuVisible:YES animated:YES];
        [MysticTipViewManager hideAll];
    }
    else if(sender.state == UIGestureRecognizerStateCancelled) self.imageView.alpha = 1;
}

#pragma mark - Popup Menu



- (void) menuWillShow:(NSNotification *)sender;
{
    [MysticLog answer:@"Menu" info:@{@"type":MysticObjectTypeTitleParent(currentSetting, MysticObjectTypeUnknown)}];
    self.isMenuVisible = YES;
    self.imageView.alpha = .6f;
}
- (void) menuWillHide:(NSNotification *)sender;
{
    self.imageView.alpha = 1.f;
}
- (void) menuDidHide:(NSNotification *)sender;
{
    MysticWait(0.5, ^{ [MysticController controller].isMenuVisible = NO; self.imageView.alpha=1; });
}


- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    
    BOOL canCopy = NO;
    switch (self.currentSetting) {
        case MysticSettingLaunch:
        case MysticSettingNone:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm:
        case MysticSettingNoneFromLoadProject: canCopy = YES; break;
        default: break;
    }
    return (selector == @selector(deleteMenuItemClicked:) ||
            selector == @selector(shaderFileMenuItemClicked:) ||
            selector == @selector(mergeItemClicked:) ||
            selector == @selector(userForgetAllTouched:) ||
            selector == @selector(pasteNewLayer:) ||
            selector == @selector(menuItemClicked:) ||
            selector == @selector(refreshMenuItemClicked:) ||
            selector == @selector(undoMenuItemClicked:) ||
            selector == @selector(redoMenuItemClicked:) ||
            selector == @selector(timeMenuItemClicked:) ||
            selector == @selector(savePotionItemClicked:) ||

#ifdef DEBUG
        
            selector == @selector(debugMenuItemClicked:) ||
            selector == @selector(crashMenuItemTouched:) ||
            selector == @selector(flexMenuItemClicked:) ||

            selector == @selector(logMenuItemClicked:) ||
            selector == @selector(scaleMenuItemClicked:) ||
#endif
            selector == @selector(emptyMenuItemClicked:) ||
            (selector == @selector(copy:) && canCopy) || selector == @selector(resetMenuItemClicked:));
}
- (void) shaderFileMenuItemClicked:(id)sender;
{
    [MysticUser toggle:Mk_SHADER_WITH_FILE];
    @try {
        [UserPotion useLastHistoryItem];
        [[MysticOptions current] enable:MysticRenderOptionsSaveLayers];
        [[MysticOptions current] setNeedsRender:YES force:YES];
        [self rerender:^(UIImage *image, id obj, id options, BOOL cancelled) {
            [MysticUser toggle:Mk_SHADER_WITH_FILE];
            [[MysticOptions current] disable:MysticRenderOptionsSaveLayers];
        }];
    }
    @catch (NSException *exception) {
        DLogError(@"Shader failed to reload:  \n\n%@\n\n", exception.reason);
        [MysticUser toggle:Mk_SHADER_WITH_FILE];
    }
 
   
}
- (void) userForgetAllTouched:(id)sender;
{
    [MysticUser forgetAll];
}

- (void) logMenuItemClicked:(id)sender;
{
    BOOL unrenderedOptions = [MysticOptions current].hasUnrenderedOptions;
    
    ALLog([NSString format:@"Render%@", sender && [sender isKindOfClass:[NSString class]] ? [@": " suffix:sender] : @""],
          @[@"Current Setting", MObj(MysticString(currentSetting)),
            @"Options", MObj([MysticOptions current]),
            @" -+ ",
            unrenderedOptions ? @"Unrendered Adjustments" : @"Adjustments", MObj(unrenderedOptions ? [MysticOptions current].optionsUnrenderedAdjustmentsDescription : [MysticOptions current].optionsRenderedAdjustmentsDescription) ,
            !unrenderedOptions ? @"Unrendered Adjustments" : @"Adjustments", MObj(!unrenderedOptions ? [MysticOptions current].optionsUnrenderedAdjustmentsDescription : [MysticOptions current].optionsRenderedAdjustmentsDescription) ,

            @" -+ ",
            @"Filters", MObj([MysticOptions current].liveTargetOptions ? [[MysticOptions current].liveTargetOptions.filters debugDescription] : [[MysticOptions current].filters debugDescription]),
            LINE,
            [NSString format:@"History  #%d of %d", (int)[UserPotion potion].historyIndex, (int)[UserPotion potion].history.count],
            MObj( [UserPotion potion].history),
            ]);
}
- (void) debugMenuItemClicked:(id)sender;
{
    [MysticUser toggle:Mk_DEBUG];
    self.imageView.previewOrRenderView.hidden = ![MysticUser is:Mk_DEBUG];
    self.layerCountButton.hidden = self.imageView.previewOrRenderView.hidden;
}
#ifdef DEBUG

- (void) flexMenuItemClicked:(id)sender;
{
    //[[FLEXManager sharedManager] showExplorer];
}
- (void) crashMenuItemTouched:(id)sender;
{
    @[][1];
}
#endif
- (void) scaleMenuItemClicked:(id)sender;
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Off",@"25%",@"33%",@"50%", @"75%", @"100%", nil] autorelease];
    sheet.tag = MysticViewTypeToolbarSize;

    [sheet showFromRect:self.view.frame inView:self.view animated:YES];
}

- (void) timeMenuItemClicked:(id)sender;
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1x",@"1.5x", @"2x", @"2.5x", @"3x", @"1/10x",@"1/4x",@"1/3x",@"1/2x",@"2/3x",@"3/4x",@"9/10x", @"5x", @"10x", @"20x", nil] autorelease];
    sheet.tag = MysticViewTypePreview;
    [sheet showFromRect:self.view.frame inView:self.view animated:YES];
}


- (void) undoMenuItemClicked:(id)sender;
{
    if(![UserPotion useLastHistoryItem]) return;
    [self revealPlaceholderImage:[UserPotion potion].sourceImageResized];
    [MysticOptions reset];
}

- (void) redoMenuItemClicked:(id)sender;
{
    if(![UserPotion useNextHistoryItem]) return;
    [self revealPlaceholderImage:[UserPotion potion].sourceImageResized];
    [MysticOptions reset];
}

- (void) emptyMenuItemClicked:(id)sender;
{
    [MysticCache clearAllSafely];
    
}
- (void) refreshMenuItemClicked:(id)sender;
{
    MysticProgressHUD *mysthud = [[MysticProgressHUD alloc] initWithFrame:self.imageFrame];
    mysthud.underlyingView = self.hudContainerView;
    //    mysthud.backgroundImage = self.blurImage;
    [mysthud setCompletionBlock:^{
    }];
    mysthud.tag = MysticViewTypeHUD;
    mysthud.mode = MysticProgressHUDModeIndeterminate;
    [self addHud:mysthud];
    [mysthud show:YES];
    
    __unsafe_unretained __block MysticProgressHUD *__mystHud = mysthud;
    
    [self reloadImageInQueue:dispatch_get_main_queue() useHUD:YES settings:MysticRenderOptionsForceProcess complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
        [__mystHud hide:YES afterDelay:1.0f];
    }];
}


- (void) resetMenuItemClicked:(id)sender;
{
    PackPotionOption *option = self.transformOption ? self.transformOption : [[MysticOptions current] option:self.currentSetting];
    
    MysticProgressHUD *mysthud = [[MysticProgressHUD alloc] initWithFrame:self.imageFrame];
    mysthud.underlyingView = self.imageView;
    //    mysthud.backgroundImage = self.blurImage;
    mysthud.removeFromSuperViewOnHide = YES;
    
    mysthud.tag = MysticViewTypeHUD;
    mysthud.mode = MysticProgressHUDModeIndeterminate;
    mysthud.labelText = NSLocalizedString(@"Resetting", nil);
    if(self.moreToolsView)
    {
        [self.moreToolsView fadeOut];
    }
    [self addHud:mysthud];
    [mysthud show:YES];
    __unsafe_unretained __block MysticProgressHUD *__mystHud = mysthud;
    
    
    [option setDefaultSettings];
    
    [option resetTransform];
    
    if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
    {
        
        if(self.layerPanelView.visiblePanel.isASubSection)
        {
            [self.layerPanelView.visiblePanel reset:YES];
            
        }
        
        
    }
    
    
    
    [self reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
        [__mystHud hide:YES afterDelay:0.1f];
        
    }];
    
    [mysthud release];
    
    
}
- (void) savePotionItemClicked:(id)sender;
{
    int c = (int)[PackPotionOptionMulti potions].count;
    
    MysticAlert *alert = [MysticAlert input:@"What do you want to name your potion?" message:nil action:^(id obj1, MysticAlert *obj2) {
        
        NSString *v = obj2.firstInput.text;
        [[MysticOptions current] savePotion:v];
    } cancel:^(id obj1, id obj2) {

    } inputs:@[@{@"text": c == 0 ? @"My Potion" : [NSString stringWithFormat:@"My Potion #%d", c+1], @"placeholder": @"Name"}] options:nil];
    [alert show];
    
    
}
- (void) deleteMenuItemClicked:(id)sender;
{
    id __currentOption = [self currentOption:self.currentSetting];
    
    __currentOption = !__currentOption ? self.currentOption : __currentOption;
    
    if(__currentOption)
    {
        
        [self removeOption:__currentOption];
        
        [self reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess];
    }
}
- (void) recrop;
{
    self.currentSetting = MysticSettingCropSourceImage;
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
    __unsafe_unretained __block MysticController *weakSelf = self;
    mdispatch_high(^{
        // Do something...
        UIImage *renderedImg = [UserPotion potion].sourceImage;
        renderedImg = renderedImg ? renderedImg : [UserPotion potion].sourceImageResized;
        [[UIPasteboard generalPasteboard] setData:UIImageJPEGRepresentation(renderedImg, 1.0)
                                forPasteboardType:@"public.jpeg"];
    });
}


#pragma mark - reloadHUD

static __unsafe_unretained MysticProgressHUD *_reloadHud;

- (MysticProgressHUD *) reloadHud;
{
    return _reloadHud ? _reloadHud : nil;
}
- (void) setReloadHud:(MysticProgressHUD *)value;
{
    if(_reloadHud) [self removeReloadHUD];
    _reloadHud = [value retain];
}
- (void) removeReloadHUD;
{
    if(_reloadHud)
    {
        _reloadHud.delegate = nil;
        _reloadHud.completionBlock = nil;
        [_reloadHud release], _reloadHud=nil;
    }
}

- (void) addHud:(MysticProgressHUD *)hudView;
{
    hudView.coverParent = NO;
    [self.hudContainerView addSubview:hudView];
    
}


- (void)options:(MysticOptions *)options downloaded:(NSUInteger)totalDownloaded expectedSize:(long long)expectedSize;
{
    
}

#pragma mark - transformImageComplete



- (void) transformImageComplete:(NSNotification *)notification;
{
    mdispatch( ^{
        
        [self refreshBlurImageFinished:^(NSArray *objs, BOOL success) {
            
        }];
        
    });
}

#pragma mark - refreshImageComplete

- (void) refreshImageComplete:(NSNotification *)notification;
{
    
}

#pragma mark - reloadImage
- (void) render:(MysticBlockImageObjOptions)finished;
{
    [self render:finished!=nil atSourceSize:NO complete:finished];
}
- (void) render:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)finished;
{
    [self render:finished!=nil atSourceSize:atSourceSize complete:finished];
}
- (void) rerender;
{
    [self render:NO atSourceSize:NO complete:nil];
}
- (void) rerenderRevealDuration:(NSTimeInterval)duration;
{
    self.revealDuration = duration;
    [self render:NO atSourceSize:NO complete:nil];
}
    
- (void) rerender:(MysticBlockImageObjOptions)finished;
{
    [self render:NO atSourceSize:NO complete:finished];
}
- (void) renderWhenReady:(BOOL)shouldReturnImage atSourceSize:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)finished;
{
    if(self.isSavingLargeImage && !self.isObservingLargeImage)
    {
        self.renderCompleteObj = [MysticRenderCompleteObject returns:shouldReturnImage atSourceSize:atSourceSize complete:finished];
        [self showHUD:@"One sec..." checked:nil];
        [self addObserver:self forKeyPath:@"isSavingLargeImage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.isObservingLargeImage = YES;
    }
    else if(!self.isSavingLargeImage)
    {
        if(self.isObservingLargeImage)
        {
            [self removeObserver:self forKeyPath:@"isSavingLargeImage"];
            self.isObservingLargeImage = NO;
        }
        [self render:shouldReturnImage atSourceSize:atSourceSize complete:finished];
    }
}
- (void) render:(BOOL)shouldReturnImage atSourceSize:(BOOL)atSourceSize complete:(MysticBlockImageObjOptions)finished;
{
    [[MysticOptions current] setHasChanged:YES changeOptions:NO];
    [[MysticOptions current] enable:!atSourceSize ? MysticRenderOptionsPreview : MysticRenderOptionsSource];
    [[MysticOptions current] enable:MysticRenderOptionsForceProcess];
    [[MysticOptions current] enable:MysticRenderOptionsRebuildBuffer];
    if(shouldReturnImage)
    {
        [[MysticOptions current] enable:MysticRenderOptionsSaveState];
        [[MysticOptions current] enable:MysticRenderOptionsSaveImageOutput];
    }
    else
    {
        [[MysticOptions current] disable:MysticRenderOptionsSaveState];
        [[MysticOptions current] disable:MysticRenderOptionsSaveImageOutput];
    }
    [[MysticController controller] reloadImageWithMsg:nil placeholder:nil hudDelay:0 settings:nil complete:finished];
}
- (void) reload:(id)useHUD;
{
    [self reloadImageWithMsg:useHUD placeholder:nil hudDelay:0 complete:nil];
}
- (void) reload:(id)useHUD hudDelay:(NSTimeInterval)hudDelay complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageWithMsg:useHUD placeholder:nil hudDelay:hudDelay complete:finished];
    
}
- (void) reload:(id)useHUD complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageWithMsg:useHUD placeholder:nil hudDelay:0 complete:finished];
}

- (void) reloadImage:(BOOL)useHUD;
{
    [self reloadImage:useHUD complete:nil];
}

- (void) reloadImageInBackground:(BOOL)useHUD;
{
    [self reloadImageInBackground:useHUD settings:MysticRenderOptionsNone complete:nil];
    
}

- (void) reloadImageInBackground:(BOOL)useHUD settings:(MysticRenderOptions)settings;
{
    [self reloadImageInBackground:useHUD settings:settings complete:nil];
}

- (void) reloadImageInBackground:(BOOL)useHUD settings:(MysticRenderOptions)settings complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageInQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) useHUD:useHUD settings:settings complete:finished];
}
- (void) reloadImageInQueue:(dispatch_queue_t)queue useHUD:(BOOL)useHUD settings:(MysticRenderOptions)settings complete:(MysticBlockImageObjOptions)finished;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    BOOL hasChanged = settings != MysticRenderOptionsNil && (settings & MysticRenderOptionsForceProcess || settings == MysticRenderOptionsForceProcess);
    if(hasChanged) [MysticOptions enable:settings];
    if(hasChanged || [MysticOptions isEnabled:MysticRenderOptionsForceProcess] ) [[MysticOptions current] setHasChanged:YES changeOptions:NO];
    dispatch_async(queue, ^{ [weakSelf reloadImage:useHUD complete:finished]; });
}




- (void) reloadImage:(BOOL)useHUD settings:(MysticRenderOptions)settings complete:(MysticBlockImageObjOptions)finished;
{
    BOOL hasChanged = settings != MysticRenderOptionsNil && (settings & MysticRenderOptionsForceProcess || settings == MysticRenderOptionsForceProcess);
    if(hasChanged) [MysticOptions enable:settings];
    if(hasChanged || [MysticOptions isEnabled:MysticRenderOptionsForceProcess] ) [[MysticOptions current] setHasChanged:YES changeOptions:NO];
    __unsafe_unretained __block  MysticController *weakSelf = self;
    mdispatch( ^{ [weakSelf reloadImageWithMsg:useHUD placeholder:nil hudDelay:0 complete:finished]; });
}


- (void) reloadImage:(BOOL)useHUD complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageWithMsg:useHUD ? @YES : nil placeholder:nil hudDelay:0 complete:finished];
}
- (void) reloadImage:(BOOL)useHUD placeholder:(UIImage *)placeholder complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageWithMsg:useHUD ? @YES : nil placeholder:placeholder hudDelay:0 complete:finished];
}
- (void) reloadImageWithMsg:(id)useHUD placeholder:(UIImage *)placeholder hudDelay:(NSTimeInterval)hudDelay complete:(MysticBlockImageObjOptions)finished;
{
    [self reloadImageWithMsg:useHUD placeholder:placeholder hudDelay:hudDelay settings:MysticRenderOptionsNone complete:finished];
}
- (void) reloadImageWithMsg:(id)useHUD placeholder:(UIImage *)placeholder hudDelay:(NSTimeInterval)hudDelay settings:(MysticRenderOptions)settings  complete:(MysticBlockImageObjOptions)finished;
{

    
    
    
    @try
    {
        __unsafe_unretained __block  MysticController *weakSelf = self;
        if(settings != MysticRenderOptionsNil) [MysticOptions enable:settings];
        weakSelf.reloadImageState = weakSelf.currentSetting;
        mdispatch(^{

            @autoreleasepool {
#ifdef MYSTIC_LOAD_NEWEST_SHADER
                
                if(weakSelf.shaderTimer) { [weakSelf.shaderTimer invalidate]; weakSelf.shaderTimer=nil; }
                
#endif
                
                BOOL _useHUD = useHUD && ([useHUD isKindOfClass:[NSValue class]] || [useHUD isKindOfClass:[NSString class]])  ? YES : NO;
                reloadingImage = YES;
                if(setNewSize)
                {
                    CGRect imageBounds = weakSelf.view.frame;
                    CGSize scaledSize = [MysticUI scaleSize:[UserPotion potion].sourceImageSize bounds:[MysticUI scaleRect:imageBounds scale:[Mystic scale]].size];
                    CGSize newSize = [MysticUI scaleDown:scaledSize scale:[Mystic scale]];
                    imageBounds = CGRectZero;
                    imageBounds.size = newSize;
                    setLayersTransform = NO;
                    [weakSelf.imageView setSize:CGRectIntegral(imageBounds).size force:YES];
                    setNewSize = NO;
                }
                
                
                MysticOptions *renderEffects = [UserPotion renderEffects];
                renderEffects.delegate = weakSelf;
                __block BOOL willSaveState = [renderEffects isEnabled:MysticRenderOptionsSaveState];
                PackPotionOptionFontStyle *fontOption = (PackPotionOptionFontStyle *)[renderEffects option:MysticObjectTypeFontStyle];
                
                switch (weakSelf.currentSetting) {
                    case MysticSettingType:
                    case MysticSettingSelectType:
                    case MysticSettingTypeAlpha: if(fontOption && fontOption.blended) fontOption.ignoreRender = YES; break;
                    default: if(fontOption && fontOption.blended) fontOption.ignoreRender = NO; break;
                }
                
                
                [weakSelf.layerCountButton setTitle:[NSString stringWithFormat:@"%d", (int)[MysticOptions current].count+1] forState:UIControlStateNormal];
                
                if(weakSelf.reloadHud) [weakSelf removeReloadHUD];
                
                if(_useHUD)
                {
                    weakSelf.progressView.hidden = NO;
                    mdispatch( ^{
                        [CATransaction begin];
                        [weakSelf.progressView.layer removeAllAnimations];
                        [CATransaction commit];
                        weakSelf.progressView.frame = CGRectY(CGRectWidth(weakSelf.progressView.frame, 2), PROGRESS_ANCHOR);
                    });
                }
                
                
                
                if(![renderEffects isEnabled:MysticRenderOptionsSource] && ![renderEffects isEnabled:MysticRenderOptionsPreview]) [renderEffects enable:MysticRenderOptionsPreview];
                if(willSaveState) weakSelf.isSavingLargeImage = YES;
                
                if([renderEffects isEnabled:MysticRenderOptionsBuildFromGroudUp])
                {
                    [weakSelf revealPlaceholderImage:nil];
                    weakSelf.isSavingLargeImage = YES;
                    if(_useHUD) [weakSelf showHUD:NSLocalizedString([useHUD isKindOfClass:[NSString class]] ? useHUD : @"Loading...", nil) checked:nil];
                    
                    [MysticEffectsManager renderFromGroundUp:renderEffects progress:!useHUD ? nil : ^(NSUInteger receivedSize, NSUInteger expectedSize) {

                    }
                    pass:^(UIImage *image, GPUImageOutput *lastOutput, MysticOptions *renderedOptions, BOOL isCancelled, MysticBlockImageObjOptions resumeBlock)
                    {
                         if(image) {
                             float n = (float)renderedOptions.manager.numberOfPasses;
                             float i = (float)renderedOptions.passIndex + 1;
                             if(i < n)
                             {
                                 [MysticUIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                     UIViewWidth(weakSelf.progressView, weakSelf.view.frame.size.width * (i/n));
                                 }];
                             }
                             [weakSelf revealPlaceholderImage:[UserPotion potion].sourceImageResized];
                         }
                         if(resumeBlock) resumeBlock(image, lastOutput, renderedOptions, isCancelled);
                         
                         
                     } complete:^(UIImage *image, GPUImageOutput *lastOutput, MysticOptions *renderedOptions, BOOL isCancelled) {
                         __unsafe_unretained __block UIImage *_image = image;
                         __unsafe_unretained __block GPUImageOutput *_lastOutput = lastOutput;
                         __unsafe_unretained __block MysticOptions *_renderedOptions = renderedOptions;
                         mdispatch( ^{
                             weakSelf.isSavingLargeImage = NO;
                             [weakSelf showHUD:NSLocalizedString(@"Done!     ", nil) checked:@(1)];
                             [[MysticOptions current] disable:MysticRenderOptionsSource];
                             [[MysticOptions current] enable:MysticRenderOptionsPreview];
                             [[MysticOptions current] disable:MysticRenderOptionsBuildFromGroudUp];
                             [[MysticOptions current] disable:MysticRenderOptionsSaveState];
                             [weakSelf revealPlaceholderImage:[UserPotion potion].sourceImageResized];
                             [MysticUIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
                                 UIViewWidth(weakSelf.progressView, weakSelf.view.frame.size.width);
                             } completion:^(BOOL finished) {
                                 [MysticUIView animateWithDuration:0.15 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                                     UIViewY(weakSelf.progressView, PROGRESS_ANCHOR-PROGRESS_HEIGHT);
                                 }];
                             }];
                             if(finished) finished(_image, _lastOutput, _renderedOptions, isCancelled);
                         });
                     }];
                }
                else
                {
                    
#pragma mark - Render Normal
                    if(weakSelf.imageView) weakSelf.imageView.hidden = NO;
                    
                    CGSize renderSize = [MysticEffectsManager sizeForSettings:renderEffects.settings];
                    CGScale scaledSize = CGScaleOfSizes(renderSize,[UserPotion potion].sourceImageSize);
                    
                    [renderEffects.filters.filter setFullScale:scaledSize.inverse];
                    
                    [MysticEffectsManager render:nil size:renderSize view:weakSelf.imageView.renderImageView effects:renderEffects options:renderEffects.settings progress:!useHUD ? nil : ^(NSUInteger s, NSUInteger total) {
                        mdispatch( ^{ UIViewWidth(weakSelf.progressView, MAX(2, CGRectW(weakSelf.view.frame) * (float)(((float)s/(float)total)*(willSaveState?.5:1)))); });
                    } complete:^(UIImage *image, GPUImageOutput *lastOutput, MysticOptions *renderedOptions, BOOL isCancelled) {
                        mdispatch(^{
                            weakSelf.imageView.hidden = NO;
                            if(!willSaveState)
                            {
                                [MysticUIView animateWithDuration:0.15 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^{
                                    UIViewWidth(weakSelf.progressView, weakSelf.view.frame.size.width * ([renderedOptions isEnabled:MysticRenderOptionsSaveState] ? 0.5 : 1));
                                } completion:^(BOOL finished) {
                                    [MysticUIView animateWithDuration:0.15 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                                        UIViewY(weakSelf.progressView, PROGRESS_ANCHOR-PROGRESS_HEIGHT);
                                    }];
                                }];
                            }
                            if(weakSelf.currentSetting == weakSelf.reloadImageState) [weakSelf.imageView revealRenderImageView:weakSelf.revealDuration];
                            if(!weakSelf.isObservingLargeImage) MysticWait(hudDelay, ^{ [MysticProgressHUD hideAllHUDsForView:weakSelf.hudContainerView animated:YES]; });
                            
                            if([renderedOptions isEnabled:MysticRenderOptionsSaveState] ) {
                                __unsafe_unretained __block MysticBlockImageObjOptions __save = finished ? Block_copy(finished) : nil;
                                __unsafe_unretained __block MysticOptions *_renderedOptions = renderedOptions ? [renderedOptions retain] : nil;
                                mdispatch(^{
                                    [weakSelf saveLargePhoto:renderedOptions lastOutput:lastOutput finished:^(id o, id p) {
                                        weakSelf.isSavingLargeImage = NO;
                                        if(__save) { __save(o,p,_renderedOptions,isCancelled); Block_release(__save); }
                                        [_renderedOptions release];
                                        [[MysticOptions current] enable:MysticRenderOptionsPreview];
                                    }];
                                });
                            }
                            else
                            {
                                weakSelf.revealDuration=0;
                                weakSelf.isSavingLargeImage = NO;
                                if(finished) finished(image, lastOutput, renderedOptions, isCancelled);
                                [[MysticOptions current] enable:MysticRenderOptionsPreview];
                            }
#ifdef MYSTIC_LOAD_NEWEST_SHADER
                            
                            weakSelf.shaderTimer = [NSTimer timerWithTimeInterval:0.5 target:weakSelf selector:@selector(checkForShader) userInfo:nil repeats:YES];
                            [[NSRunLoop currentRunLoop] addTimer:self.shaderTimer forMode:NSDefaultRunLoopMode];
                            
#endif
                            
                        });
                    }];
                }
            }
        });
        hasRendered = YES;
    }
    @catch (NSException *ex)
    {
        ErrorLog(@"MysticController: ERROR: reloadImage ERROR: %@", ex.reason);
    }
}

#pragma mark - Save Large Photo

- (void) saveLargePhoto:(MysticOptions *)renderedOptions lastOutput:(GPUImageOutput *)lastOutput finished:(MysticBlockObjObj)finished;
{
    @try {
        __unsafe_unretained __block MysticController *weakSelf = self;
        if([renderedOptions isEnabled:MysticRenderOptionsSaveState] && lastOutput)
        {

            __unsafe_unretained __block UIImage *_image = [lastOutput isKindOfClass:[UIImage class]] ? (id)lastOutput : [lastOutput imageFromCurrentFramebuffer];
            if(_image) [_image retain];
            __unsafe_unretained __block MysticBlockObjObj __finished = finished ? Block_copy(finished) : nil;
            CGSize _imageSize = _image ? [MysticImage sizeInPixels:_image] : CGSizeZero;

            if(_image && (CGSizeGreater(_imageSize,  self.previewSize)
                          || ([renderedOptions isEnabled:MysticRenderOptionsSource] && CGSizeEqual(_imageSize, [MysticEffectsManager sizeForSettings:MysticRenderOptionsSource]))
                          || ([renderedOptions isEnabled:MysticRenderOptionsOriginal] && CGSizeEqual(_imageSize, [MysticEffectsManager sizeForSettings:MysticRenderOptionsOriginal]))))
            {
                [[UserPotion potion] preparePhoto:_image previewSize:[MysticUI screen] reset:YES finished:^(CGSize size, UIImage *preparedImage, NSString *imageFilePath) {
                    
                    [MysticOptions current].hasRendered = YES;
                    [[MysticOptions current] enable:MysticRenderOptionsPreview];
                    [weakSelf revealPlaceholderImage:[UserPotion potion].sourceImageResized duration:weakSelf.revealDuration];
                    if(__finished) { __finished(preparedImage, imageFilePath); Block_release(__finished); }
                    
                }];
                [_image release];
            }
            else if(_image && [renderedOptions isEnabled:MysticRenderOptionsRevealPlaceholder])
            {

                [weakSelf revealPlaceholderImage:_image duration:weakSelf.revealDuration];
                if(__finished) { __finished(_image, @"file://(image not saved)"); Block_release(__finished); }
                [_image release];

            }
            else
            {

                if(__finished) { __finished(_image, _image ? @"file://(image not saved)" : nil); Block_release(__finished); }
                if(_image) [_image release];

            }
        }
        [renderedOptions disable:MysticRenderOptionsSaveState];
    }
    @catch (NSException *exception) {
        ErrorLog(@"EditPhotoController: saveLargePhoto: exception: %@", ExceptionString(exception));
    }
    
}
- (void) revealPlaceholderImage:(UIImage *)image;
{
    [self revealPlaceholderImage:image duration:0];
}
- (void) revealPlaceholderImage:(UIImage *)image duration:(NSTimeInterval)dur;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block UIImage *_image = image ? [image retain] : nil;
    mdispatch(^{
        [weakSelf.imageView showPlaceholder:isNullOr(_image) ? _image : [UserPotion potion].sourceImageResized duration:dur];
        [[MysticOptions current] disable:MysticRenderOptionsRevealPlaceholder];
        if(weakSelf.overlaysPreviewImageView) [weakSelf.overlaysPreviewImageView removeFromSuperview], weakSelf.overlaysPreviewImageView = nil;
        [weakSelf.view setNeedsDisplay];
        [_image release];
        [[MysticOptions current] optimizeForOffScreen];
        weakSelf.revealDuration=0;

    });
}
- (void)hudWasHidden:(MysticProgressHUD *)hud {
    if(![HUD.superview isEqual:self.imageView]) return;
    [HUD removeFromSuperview];
    [HUD release], HUD = nil;
}
- (CGRect) imageVisibleFrame;
{
    CGRect imageFrame = CGRectHeight(self.view.frame, CGPointAddY(self.imageView.center, self.imageView.offset.y).y * 2);
    if(!self.navigationController.navigationBarHidden)
    {
        imageFrame.origin.y = self.navigationController.navigationBar.frame.size.height;
        imageFrame.size.height -= self.navigationController.navigationBar.frame.size.height*2;
    }
    return imageFrame;
}
- (CGRect) imageFrame;
{
    CGRect imageFrame = self.view.frame;
    CGFloat nav = ![(MysticNavigationViewController *)self.navigationController willNavigationBarBeVisible] ? 0 : self.navigationController.navigationBar.frame.size.height;
    if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
    {
        imageFrame.size.height -= (nav + self.layerPanelView.visibleHeight);
    }
    else
    {
        imageFrame.size.height -= (nav + self.bottomPanelView.frame.size.height);
        imageFrame.origin.y += nav;
    }
    return imageFrame;
}


#pragma mark - Open Project


- (void) openProject:(MysticProject *)project complete:(MysticBlockObjBOOL)finished;
{
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self showHUD:NSLocalizedString(@"Loading...", nil) checked:nil];
    
    [self resetInterface:^(id obj, BOOL success) {
        [self showHUD:NSLocalizedString(@"Have fun!", nil) checked:@(1)];
        if(finished) finished(project, YES);
    }];
    
    
}

- (void) resetInterface:(MysticBlockObjBOOL)finished;
{
    
    switch (self.currentSetting) {
        case MysticSettingLaunch:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingNone:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm:
        {
            if(finished) finished(self, YES);
            return;
        }
            
        default: break;
    }
    [self setState:self.launchState animated:YES complete:^{
        mdispatch( ^{
            [self reloadImage:YES complete:^(UIImage *image, id lastOutput, MysticOptions *renderedOptions, BOOL isCancelled) {
                if(finished) finished(self, YES);
            }];
        });
    }];
}

- (void) setPreviewSize:(CGSize)previewSize;
{
    [[MysticUser user] setSize:previewSize forType:MysticImageSizeTypePreview];
    _previewSize = previewSize;
    self.imageView.imageViewFrame = [MysticUI rectWithSize:previewSize];
    [self.view setNeedsLayout];
    
    if(self.imageView.hidden)
    {
        
        [NSTimer wait:0.25 block:^{
            self.imageView.hidden = NO;
            
        }];
    }
    
}






#pragma mark - Set Nav Buttons

- (BOOL) isLeftButton:(NSInteger)tag;
{
    return self.navigationItem.leftBarButtonItem && self.navigationItem.leftBarButtonItem.tag == tag;
}
- (BOOL) isRightButton:(NSInteger)tag;
{
    return self.navigationItem.rightBarButtonItem && self.navigationItem.rightBarButtonItem.tag == tag;
}
- (void) setLeftButton:(id)btns animate:(BOOL)animate;
{
    if(btns)
    {
        [self.navigationItem setLeftBarButtonItems:([btns isKindOfClass:[NSArray class]] ? btns : [NSArray arrayWithObject:btns]) animated:animate];
    }
    else
    {
        if([self.navigationItem.leftBarButtonItems count])
        {
            [self.navigationItem setLeftBarButtonItems:nil animated:animate];
            [self.navigationItem setLeftBarButtonItem:nil animated:animate];
        }
        else
        {
            [self.navigationItem setLeftBarButtonItem:nil animated:animate];
        }
    }
}

- (void) setRightButton:(id)btns animate:(BOOL)animate;
{
    if(btns)
    {
        [self.navigationItem setRightBarButtonItems:([btns isKindOfClass:[NSArray class]] ? btns : [NSArray arrayWithObject:btns]) animated:animate];
    }
    else
    {
        if([self.navigationItem.rightBarButtonItems count])
        {
            [self.navigationItem setRightBarButtonItems:nil animated:animate];
            [self.navigationItem setRightBarButtonItem:nil animated:animate];
        }
        else
        {
            [self.navigationItem setRightBarButtonItem:nil animated:animate];
        }
    }
}


#pragma mark - top bar buttons

- (void) logoTouched:(id)sender;
{
    
}

- (void) compareButtonTouched:(MysticBarButton *)sender
{
    [self revealPlaceholderImage:[UserPotion historySourceImageAndResized:YES] duration:-1];
//    self.navLeftView.alpha = 0;
//    self.undoRedoTools.alpha = 0;
//    self.bottomPanelView.alpha = 0;
}
- (void) compareButtonReleased:(MysticBarButton *)sender
{
    [self revealPlaceholderImage:[UserPotion potion].sourceImageResized duration:-1];
    self.navLeftView.alpha = 1;
    self.undoRedoTools.alpha = 1;
    self.bottomPanelView.alpha = 1;
}

- (void) backButtonTouched:(MysticBarButton *)sender
{
    if(sender) sender.selected = !sender.selected;
    [(MysticDrawerNavViewController *)self.drawer.navigationController loadSection:MysticDrawerSectionMain];
    [self toggleDrawerSide:MMDrawerSideLeft completion:^(BOOL active) {
        
    }];
    
}

- (void) saveButtonTouched:(MysticBarButton *)sender
{
//    if(sender) sender.selected = !sender.selected;
   
    [self setStateConfirmed:MysticSettingShare animated:YES info:nil complete:nil];

    
}

- (void) toggleDrawerSide:(MMDrawerSide)openSide completion:(MysticBlockBOOL)finished;
{
    //    self.currentOpenSide = openSide;
    [self.mm_drawerController toggleDrawerSide:openSide animated:YES completion:finished];
}





- (void) manageLayers:(id)sender
{
    [self manageLayers:sender complete:nil];
}
- (void) manageLayers:(id)sender complete:(MysticBlockBOOL)completed;
{
    //    [self.drawer loadSection:MysticDrawerSectionMain];
    
    //    if(!self.mm_drawerController.rightDrawerViewController)
    //    {
    //        MysticLayersViewController *layersDrawer = [[MysticLayersViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
    //        self.mm_drawerController.rightDrawerViewController = layersDrawer;
    //        [layersDrawer release];
    //    }
    
    MMDrawerSide nextSide = MMDrawerSideRight;
    [self.mm_drawerController toggleDrawerSide:nextSide animated:YES completion:completed];
    
}



#pragma mark - Drawer

- (MysticDrawerViewController *) drawer;
{
    return (id)self.mm_drawerController.leftDrawerViewController;
    //
    //    MysticMainDrawerViewController *drawerNav = (MysticMainDrawerViewController *)self.mm_drawerController.leftDrawerViewController;
    //    return (MysticDrawerViewController *)drawerNav.visibleViewController;
}


- (void) closeDrawerIfOpened:(BOOL)animated finished:(MysticBlockBOOL)finished;
{
    MMDrawerSide openSide = self.mm_drawerController.openSide;
    if(openSide != MMDrawerSideNone)
    {
        [self.mm_drawerController toggleDrawerSide:openSide animated:animated completion:finished];
    }
}












#pragma mark - slider events
- (void) sliderEditingDidEnd:(MysticSlider *)sender;
{
    if(sender.sliderCalls > 0)
    {
        sender.sliderCalls = 2;
        [self updateSlider:sender];
    }
    sender.sliderCalls = 0;
    
    
}
-(void) sliderValueChanged:(MysticSlider *)sender;
{
    if(ignoreSliderUpdates) {
        return;
    }
    switch (sender.setting) {
        case MysticSettingTypeAlpha:
        {
            MysticFontStyleView *selectedLayer = [self.fontStylesController selectedLayer];
            if(selectedLayer)
            {
                selectedLayer.alpha = sender.value;
            }
            else for (MysticFontStyleView *l in self.fontStylesController.overlays) l.alpha = sender.value;
            break;
        }
        default: break;
    }
    [self updateSlider:sender];
}



-(void) updateSlider:(MysticSlider *)sender {
    
    
    if(ignoreSliderUpdates) return;
    
    NSTimeInterval wait = 0;
    BOOL useHUD = NO;
    BOOL reloadImage = NO;
    BOOL refreshImage = NO;
    BOOL skipNeedsReloadCheck = NO;
    BOOL madeNewOption = NO;
    BOOL sliderIsAdjustment = MysticTypeSubTypeOf(sender.setting, MysticSettingSettings);
    BOOL updateOpacityButton = NO;
    PackPotionOption *option = sender.targetOption ? sender.targetOption : [self currentOption:self.parentSetting];
    MysticObjectType _parentSetting =  MysticTypeForSetting(self.parentSetting, option);
    
    if(self.moreToolsView && !self.moreToolsView.hidden)
    {
        self.moreToolsView.hidden = YES;
    }
    
    if(_parentSetting == MysticObjectTypeSetting && !option)
    {
        
        option = [UserPotion makeOption:_parentSetting];
        if(option)
        {
            self.currentOption = option;
            madeNewOption = YES;
            reloadImage = YES;
        }
    }
    PackPotionOption* refreshOption = option;
    
    
    BOOL setHasChanged = sliderIsAdjustment || [option isKindOfClass:[PackPotionOptionSetting class]];
    switch (sender.setting)
    {
        case MysticSettingChooseColorAndIntensity:
        case MysticSettingChooseColor:
        case MysticSettingIntensity:
        {
            
            
            if(!option) return;
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kLayerIntensity;
            setHasChanged = NO;
            switch (option.type) {
                case MysticObjectTypeShape:
                    refreshImage = NO;
                    reloadImage = NO;
                    PackPotionOptionShape *shapeOption = (PackPotionOptionShape *)option;
                    if(shapeOption.view)
                    {
                        shapeOption.view.contentView.alpha = sender.value;
                    }
                    break;
                    
                default: break;
            }
            break;
        }
        case MysticSettingBadge:
        case MysticSettingBadgeAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kBadgeAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingChooseText:
        case MysticSettingText:
        case MysticSettingTextAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kTextAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingCamLayer:
        case MysticSettingCamLayerAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kCamLayerAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingTextColor:
            break;
        case MysticSettingFrame:
        case MysticSettingFrameAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kFrameAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingFilter:
        case MysticSettingFilterAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value;  }
            updateOpacityButton = sender.value != kColorAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingTexture:
        case MysticSettingTextureAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kTextureAlpha;
            setHasChanged = NO;
            
            break;
        case MysticSettingLighting:
        case MysticSettingLightingAlpha:
            refreshImage = !(option.intensity == sender.value);
            if(refreshImage) { option.intensity = sender.value; }
            updateOpacityButton = sender.value != kTextureAlpha;
            setHasChanged = NO;
            break;
            
            
        case MysticSettingFrameColor:
            break;
            
        case MysticSettingBadgeColor:
            break;
            
        case MysticSettingHaze:
            refreshImage = !(option.haze == sender.value);
            if(refreshImage) option.haze = sender.value;
            break;
        case MysticSettingBrightness:
            refreshImage = !(option.brightness == sender.value);
            if(refreshImage) option.brightness = sender.value;
            break;
            
        case MysticSettingWearAndTear:
            refreshImage = !(option.wearAndTear == sender.value);
            if(refreshImage) option.wearAndTear = sender.value;
            break;
            
        case MysticSettingTemperature:
            refreshImage = !(option.temperature == sender.value);
            if(refreshImage) option.temperature = sender.value;
            break;
            
            
        case MysticSettingExposure:
            refreshImage = !(option.exposure == sender.value);
            if(refreshImage) option.exposure = sender.value;
            break;
        case MysticSettingGamma:
            refreshImage = !(option.gamma == sender.value);
            if(refreshImage) option.gamma = sender.value;
            break;
        case MysticSettingSkin:
            refreshImage = !(option.skinToneAdjust == sender.value);
            if(refreshImage) option.skinToneAdjust = sender.value;
            break;
        case MysticSettingVibrance:
            refreshImage = !(option.vibrance == sender.value);
            if(refreshImage) option.vibrance = sender.value;
            break;
            
        case MysticSettingColorBalance:
        case MysticSettingColorBalanceRed:
            refreshImage = !(option.rgb.one == sender.value);
            if(refreshImage) option.rgb = (GPUVector3){sender.value, option.rgb.two, option.rgb.three};
            break;
        case MysticSettingColorBalanceGreen:
            refreshImage = !(option.rgb.two == sender.value);
            if(refreshImage) option.rgb = (GPUVector3){option.rgb.one, sender.value,  option.rgb.three};
            break;
        case MysticSettingColorBalanceBlue:
            refreshImage = !(option.rgb.three == sender.value);
            if(refreshImage) option.rgb = (GPUVector3){option.rgb.one, option.rgb.two, sender.value};
            break;
            
        case MysticSettingHSB:
        case MysticSettingHSBHue:
            refreshImage = !(option.hsb.hue == sender.value);
            if(refreshImage) option.hsb = (MysticHSB){sender.value, option.hsb.saturation, option.hsb.brightness};
            break;
        case MysticSettingHSBSaturation:
            refreshImage = !(option.hsb.saturation == sender.value);
            if(refreshImage) option.hsb = (MysticHSB){ option.hsb.hue, sender.value, option.hsb.brightness};
            break;
        case MysticSettingHSBBrightness:
            refreshImage = !(option.hsb.brightness == sender.value);
            if(refreshImage) option.hsb = (MysticHSB){ option.hsb.hue, option.hsb.saturation, sender.value};
            break;
            
            
        case MysticSettingCamLayerSetup:
        case MysticSettingLevels:
        {
            
            refreshImage = !(option.whiteLevels == [(MysticRangeSlider *)sender selectedMaximumValue] && option.blackLevels == [(MysticRangeSlider *)sender selectedMinimumValue]);
            if(refreshImage)
            {
                option.whiteLevels = [(MysticRangeSlider *)sender selectedMaximumValue];
                option.blackLevels = [(MysticRangeSlider *)sender selectedMinimumValue];
                
            }
            break;
        }
        case MysticSettingShadows:
            refreshImage = !(option.shadows == sender.value);
            if(refreshImage) option.shadows = sender.value;
            break;
        case MysticSettingHighlights:
            refreshImage = !(option.highlights == sender.value);
            if(refreshImage) option.highlights = sender.value;
            break;
        case MysticSettingContrast:
            refreshImage = !(option.contrast == sender.value);
            if(refreshImage) option.contrast = sender.value;
            break;
        case MysticSettingSaturation:
            refreshImage = !(option.saturation == sender.value);
            if(refreshImage) option.saturation = sender.value;
            
            
            break;
            
            
        case MysticSettingSharpness:
            refreshImage = !(option.sharpness == sender.value);
            if(refreshImage) option.sharpness = sender.value;
            break;
        case MysticSettingVignette:
        {
            vignetteValue = sender.value;
            refreshImage = !(option.vignetteValue == sender.value);
            
            if(refreshImage) {
                option.vignetteValue = vignetteValue;
            }
            
            
            break;
        }
            
            
        default: break;
    }
    
    
    
    BOOL forceAReload = NO;
    
    
    if(updateOpacityButton && opacityChangedButton)
    {
        [opacityChangedButton setImage:[MysticIcon imageNamed:@"iconMask-intensity-on.png" colorType:MysticColorTypeWhiteBarActive] forState:UIControlStateNormal];
    }
    else if(!updateOpacityButton && opacityChangedButton)
    {
        [opacityChangedButton setImage:[MysticIcon imageNamed:@"iconMask-intensity-off.png" colorType:MysticColorTypeWhiteBarInactive] forState:UIControlStateNormal];
    }
    
    __unsafe_unretained __block MysticController *weakSelf = self;
    
    [refreshOption updateTag];
    
    if(!setHasChanged)
    {
        refreshOption.hasChanged = NO;
    }
    else
    {
        refreshOption.hasChanged = YES;
    }
    
    BOOL needsReload = NO;
    
    if(!sender.preventsRender)
    {
        if(refreshOption) [refreshOption addAdjustOrder:sender.setting];
        refreshOption.refreshState = sender.setting;
        needsReload = [refreshOption updateFilters:sender.setting];
        [refreshOption setupFilter:[MysticOptions current].filters.filter];
        
        
        
        
        
        int d = 0;
        
        if(refreshImage && !needsReload )
        {
            d = 1;
            ignoreSliderUpdates = NO;
            
            mdispatch(^{
                [MysticEffectsManager refresh:refreshOption];
            });
        }
        else if(reloadImage || (needsReload && refreshImage))
        {
            d = 2;
            [MysticOptions enable:MysticRenderOptionsForceProcess];
            [MysticOptions current].hasChanged = YES;
            ignoreSliderUpdates = YES;
            
            __unsafe_unretained __block MysticSlider *__slider = [sender retain];
            mdispatch_high(^{
                [[MysticOptions current] setNeedsRender];
                [weakSelf reloadImage:useHUD complete:^(UIImage *image, id lastOutput, MysticOptions *renderedOptions, BOOL isCancelled) {
                    ignoreSliderUpdates = NO;
                    __slider.sliderCalls++;
                    if(__slider.sliderCalls == 1)
                    {
                        [weakSelf sliderValueChanged:__slider];
                    }
                    else
                    {
                        __slider.sliderCalls = 0;
                    }
                    [__slider release];
                }];
            });
            
        }
        
        
        
        //        DLog(@"Slide %d: \" %@ \"  (%@)        |  Refresh: %@  |  Reload: %@  |  NeedsReload: %@",
        //             d,
        //             refreshOption.name,
        //             MyString(sender.setting),
        //             MBOOL(refreshImage),
        //             MBOOL(reloadImage),
        //             MBOOL(needsReload));
        
    }
    
}

- (void) refreshSliderAction:(MysticSlider *)slider;
{
    mdispatch(^{
        ignoreSliderUpdates = NO;
        [MysticEffectsManager refresh:slider.targetOption];
        switch (slider.setting) {
            case MysticSettingBlurCircle: [self updateBlurCircleDots:UIGestureRecognizerStateRecognized]; break;
                
            default:
                break;
        }
    });
}
- (void) reloadSliderAction:(MysticSlider *)slider;
{
    if(ignoreSliderUpdates) return;
    __unsafe_unretained __block MysticController *weakSelf = self;
    [MysticOptions enable:MysticRenderOptionsForceProcess];
    [MysticOptions current].hasChanged = YES;
    ignoreSliderUpdates = YES;
    
    mdispatch_high(^{
        [[MysticOptions current] setNeedsRender];
        [weakSelf reloadImage:NO complete:^(UIImage *image, id lastOutput, MysticOptions *renderedOptions, BOOL isCancelled) {
            ignoreSliderUpdates = NO;
            
        }];
    });
}
- (void) finishSliderAction:(MysticSlider *)slider;
{
    mdispatch(^{
        [MysticEffectsManager refresh:slider.targetOption];
        switch (slider.setting) {
            case MysticSettingBlurCircle:
                [self updateBlurCircleDots:UIGestureRecognizerStateChanged];
                break;
                
            default:
                break;
        }
    });
}

- (void) stillSliderAction:(MysticSlider *)slider;
{
    
}


#pragma mark - Color Input
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color finished:(MysticBlockInput)finished;
{
    [self showColorInput:target title:title color:color colorSetting:MysticSettingUnknown colorChoice:MysticOptionColorTypeUnknown colorOption:nil control:nil init:nil finished:finished];
}
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color init:(MysticBlockObject)initBlock finished:(MysticBlockInput)finished;
{
    [self showColorInput:target title:title color:color colorSetting:MysticSettingUnknown colorChoice:MysticOptionColorTypeUnknown colorOption:nil control:nil init:initBlock finished:finished];
}
- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color colorSetting:(MysticObjectType)_colorSetting colorChoice:(MysticOptionColorType)_colorType colorOption:(PackPotionOptionColor *)_colorOpt control:(EffectControl *)__effectControl finished:(MysticBlockInput)finished;
{
    [self showColorInput:target title:title color:color colorSetting:_colorSetting colorChoice:_colorType colorOption:_colorOpt control:__effectControl init:nil finished:finished];
}

- (void) showColorInput:(PackPotionOption *)target title:(NSString *)title color:(UIColor *)color colorSetting:(MysticObjectType)_colorSetting colorChoice:(MysticOptionColorType)_colorType colorOption:(PackPotionOptionColor *)_colorOpt control:(EffectControl *)__effectControl init:(MysticBlockObject)initBlock finished:(MysticBlockInput)finished;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block EffectControl *_effectControl = __effectControl ? [__effectControl retain] : nil;
    __unsafe_unretained __block PackPotionOption *targetOption = target ? [target retain] : nil;
    __unsafe_unretained __block PackPotionOptionColor *colorOpt = _colorOpt ? [_colorOpt retain] : nil;
    __block MysticObjectType colorSetting = _colorSetting;
    __block MysticOptionColorType colorType = _colorType;
    __unsafe_unretained __block MysticBlockInput _f = finished ? Block_copy(finished) : nil;
    
    MysticInputView *iv = [MysticInputView inputView:self.view title:title type:MysticInputTypeColor finished:^(UIColor *c, UIColor *c2, CGPoint p, MysticThreshold t, int i,  MysticInputView *_iv, BOOL finished) {
        mdispatch(^{
            [weakSelf updateImageViewFrame:CGRectInfinite animated:YES];
            [weakSelf showNavViews:nil];
        });
        
        if(_f) { _f(c,c2,p,t,i, _iv, YES); Block_release(_f); return; }
        if(targetOption)
        {
            targetOption.layerEffect = MysticLayerEffectNone;
            if(colorType!=MysticOptionColorTypeUnknown) [targetOption setColorType:colorType color:_iv.color];
            [targetOption setupFilter:[MysticOptions current].filters.filter];
        }
        if(colorOpt)
        {
            [colorOpt setColor:_iv.color];
            if(_effectControl) [colorOpt updateLabel:nil control:_effectControl selected:_effectControl.selected];
        }
        
        mdispatch(^{
            if(targetOption) [MysticEffectsManager refresh:[targetOption autorelease]];
            if(colorOpt) [colorOpt release];
            if(_effectControl) [_effectControl release];
            
        });
    }];
    iv.targetOption = targetOption ? targetOption : nil;
    iv.setting = colorSetting;
    iv.colorType = colorType;
    UIColor *newColor = color ? color : (targetOption ? [targetOption color:colorType] : nil);
    newColor = newColor ? newColor : (_effectControl ? [(PackPotionOptionColor *)_effectControl.effect color] : nil);
    if(newColor) iv.color = newColor;
    iv.changed = ^(UIColor *c, UIColor *c2, CGPoint p, MysticThreshold t, int i,  MysticInputView *_iv, BOOL finished) {
        if(_f) { _f(c,c2,p,t,i, _iv, NO); return; }
        if(targetOption)
        {
            if(colorType!=MysticOptionColorTypeUnknown) [targetOption setColorType:colorType color:c];
            [targetOption setupFilter:[MysticOptions current].filters.filter];
            mdispatch(^{ [MysticEffectsManager refresh:targetOption]; });
        }
    };
    [weakSelf hideNavViews:nil];
    if(initBlock) initBlock(iv);
    if(iv.allowEyeDropper)
    {
        iv.sendDelegateMethods=YES;
        iv.delegate = (id <MysticInputViewDelegate>)self;
        self.activeInputView = iv;
        iv.setting=self.transformOption.refreshState;
        __unsafe_unretained __block MysticInputView *_iv = [iv retain];
        [self renderWhenReady:YES atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
            
            if(![obj isKindOfClass:[NSString class]] || !image) { DLogError(@"input view eyedropper render error:  %@    %@    %@", obj, ILogStr(image), b(cancelled));
                //return;
            }
            
            weakSelf.colorPickerImage = image ? image: [UserPotion potion].sourceImageResized;
            UIColor *activeColor = self.transformOption.lastAdjustColor;
            _iv.selectedColor = activeColor ? activeColor : [self colorAtImagePoint:CGPointUnknown];
            _iv.colorAndPicker = _iv.selectedColor;
            [_iv showInView:weakSelf.view type:MysticInputTypeColor];
            [_iv hideAddBtn:NO];
            weakSelf.readyForRenderEngine = weakSelf.transformOption.hasMapImage;
            UIEdgeInsets insets = UIEdgeInsetsZero;
            CGFloat t = (weakSelf.imageFrame.size.height - _iv.inputFrame.origin.y)/2;
            insets.top =  -t;
            insets.bottom = _iv.inputFrame.size.height - t;
            [weakSelf insetImageView:insets complete:nil];
            [_iv release];
            [weakSelf.overlayView setupGestures:MysticSettingEyeDropper disable:NO];
        }];
        return;
        
    }
    [iv showInView:self.view type:MysticInputTypeColor];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    CGFloat t = (self.imageFrame.size.height - iv.inputFrame.origin.y)/2;
    insets.top =  -t;
    insets.bottom = iv.inputFrame.size.height - t;
    [self insetImageView:insets complete:nil];
}
- (void) inputViewDidShow:(MysticInputView *)iv;
{
    NSDictionary *lastColor = self.transformOption.lastAdjustColorInfo;
    if(lastColor)
    {
        iv.selectedColor = lastColor[@"source"];
        iv.colorAndPicker = lastColor[@"color"];
        iv.colorAlpha = [lastColor[@"intensity"] floatValue];
        iv.selectedColorIndex = [lastColor[@"index"] integerValue];
        iv.selectedColorPoint =  [lastColor[@"index"] CGPointValue];
    }
    NSInteger i = iv.selectedColorIndex;
    if(!self.dropper)
    {
        CGPoint p1 = lastColor && !CGPointIsUnknown([lastColor[@"point"] CGPointValue]) ? [lastColor[@"point"] CGPointValue] : CGPointCenter(self.imageView.imageView.frame);
        if(!lastColor && !iv.selectedColor) iv.selectedColor = [self colorAtImagePoint:p1];
        if(!lastColor) self.activeInputView.selectedColorIndex = 0;
        self.dropper = [self addColorButtonAtPoint:p1 info:@{@"index":@(iv.selectedColorIndex),@"source":MNull(iv.selectedColor)} create:lastColor==nil];
        self.dropper.selected = YES;
        self.dropper.alpha = 0;
        self.dropper.color2 = iv.color ? iv.color : self.dropper.color;
        self.dropper.point = p1;
        self.dropper.focus = 3;
        iv.selectedColor = self.dropper.color;
        iv.colorAndPicker = self.dropper.color2;
        __unsafe_unretained __block NSMutableArray *clrs = [[NSMutableArray array] retain];
        for (NSDictionary *a in self.transformOption.adjustColors) {
            if([a[@"index"] integerValue] == self.dropper.index) continue;
            MysticPointColorBtn *btn = [self addColorButtonAtPoint:[a[@"point"] CGPointValue] info:a create:NO];
            btn.selected = NO;
            btn.alpha = 0;
            btn.focus = -1;
            btn.point = [a[@"point"] CGPointValue];
            [clrs addObject:btn];
        }
        [MysticUIView animateWithDuration:0.45 animations:^{
            self.dropper.focus = 0;
            self.dropper.alpha = 1;
            if(clrs.count > 0) for (MysticPointColorBtn*b in clrs) { b.focus=0; b.selected = NO; }
            [clrs release];
        }];
    }
}
static BOOL stopDebug = NO;

- (void) inputViewDismissed:(MysticInputView *)iv;
{

    if(self.activeInputView) self.activeInputView = nil;
    if(self.dropper) { self.dropper = nil; }
    for (UIView*v in [self colorButtons]) [v removeFromSuperview];
    [self.overlayView setupPreviousGestures];
    [self.transformOption finalizeAdjustColors];
    [self.imageView hideFilterView:0];
    
}

- (UIColor *) colorAtImagePoint:(CGPoint)p;
{
    CGPoint p1 = !CGPointIsUnknown(p) ? p : CGPointCenter(self.imageView.imageView.frame);
    CGPoint p2 = CGPointNormal(p1, self.imageView.imageView.bounds);
    CGSize s = CGSizeImage(self.colorPickerImage);
    if(!CGRectContainsPoint(CGRectSize(s), p1) || !self.colorPickerImage) return nil;
    return [self getPixelColorAtLocation:CGPointOfNormal(p2, s) image:self.colorPickerImage];
    
}
- (void) setColorButtonsHidden:(BOOL)colorButtonsHidden;
{
    [self setColorButtonsHidden:colorButtonsHidden delay:0];
}
- (void) setColorButtonsHidden:(BOOL)colorButtonsHidden delay:(NSTimeInterval)delay;
{
    if(_colorButtonsHiddenAnimating && _lastColorButtonsHidden==colorButtonsHidden) return;
    self.colorButtonsHiddenAnimating=YES;
    self.lastColorButtonsHidden=colorButtonsHidden;
    NSArray *buttons = [[self colorButtons] retain];
    if(buttons.count < 1) { _colorButtonsHidden=NO; _colorButtonsHiddenAnimating=NO; _lastColorButtonsHidden=NO; [buttons release]; return; }

    if(!colorButtonsHidden)
    {
        for (MysticPointColorBtn *btn in buttons) btn.focus = -1;
        [MysticUIView animateWithDuration:0.4 delay:delay usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (MysticPointColorBtn *btn in buttons) {
                btn.alpha = 1;
                btn.focus = 0;
                btn.userInteractionEnabled=YES;
            }
        } completion:^(BOOL finished) {
            _colorButtonsHidden=NO;
            _lastColorButtonsHidden=NO;
            _colorButtonsHiddenAnimating=NO;
            [buttons release];
        }];
    }
    else
    {
        for (MysticPointColorBtn *btn in buttons) btn.focus = 0;
        [MysticUIView animateWithDuration:0.07 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (MysticPointColorBtn *btn in buttons) {
                btn.alpha = 0;
                btn.focus = -1;
                btn.userInteractionEnabled=NO;
            }
        } completion:^(BOOL finished) {
            _colorButtonsHidden=YES;
            _lastColorButtonsHidden=YES;
            for (MysticPointColorBtn *btn in buttons) btn.focus = 0;
            [buttons release];
            _colorButtonsHiddenAnimating=NO;
        }];
    }
}

- (void) inputViewTouchesBegan:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(!picker.hidesColorDropper) return;
    [self setColorButtonsHidden:YES delay:0];
}
- (void) inputViewTouchesMoved:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{

}
- (void) inputViewTouchesEnded:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    if(!picker.hidesColorDropper) return;
    if(self.colorButtonsHidden) self.colorButtonsHidden=NO;

}
- (void) inputViewTouchesCancelled:(MysticInputView *)inputView picker:(ILControl *)picker touches:(NSSet *)touches event:(UIEvent *)event;
{
    
}
- (void) inputViewRemoveTouched:(MysticInputView *)iv;
{
    if([self inputViewNumberOfColors:iv] == 0) return;

    [self.transformOption removeAdjustColorAtIndex:iv.selectedColorIndex];
    MysticPointColorBtn *lastC = nil;
    __unsafe_unretained __block NSMutableArray *rm = [[NSMutableArray array] retain];
    for (MysticPointColorBtn*c in [self colorButtons]) {
        if(c.index!=iv.selectedColorIndex) { lastC = c; continue; }
        if([c isEqual:self.dropper]) self.dropper=nil;
        if([c isEqual:self.activeDropper]) self.activeDropper=nil;
        [rm addObject:c];
    }
    if(lastC) { lastC.selected=YES; [lastC tap]; }
    if(!rm.count) return [rm release];
    [[MysticController controller] rerender];
    [MysticUIView animateWithDuration:0.4 animations:^{
        for (MysticPointColorBtn *v in rm) {
            v.alpha = 0;
            v.focus = 2;
        }
    } completion:^(BOOL f) {
        for (UIView *v in rm) [v removeFromSuperview];
        [rm release];
        if([self inputViewNumberOfColors:iv] == 0)
        {
            [iv hideRemoveBtn:YES];
        }
        if([self inputViewNumberOfColors:iv] < 1)
        {
            [iv showAddBtn:YES];
        }
    }];
}
- (NSInteger) inputViewNumberOfColors:(MysticInputView *)inputView ;
{
    return [self.imageView.imageView numberOfSubviewsOfClass:[MysticPointColorBtn class]];
}
- (void) inputViewRemoveAllTouched:(MysticInputView *)iv ;
{
    __unsafe_unretained __block NSMutableArray *rm = [[NSMutableArray arrayWithArray:[self colorButtons]] retain];
    __unsafe_unretained __block MysticController *weakSelf = self;
    [self.transformOption removeAdjustColors];
    self.dropper=nil;
    self.activeDropper=nil;
    if(!rm.count) return [rm release];
    [[MysticController controller] rerender];
    [MysticUIView animateWithDuration:0.4 animations:^{
        for (MysticPointColorBtn *v in rm) {
            v.alpha = 0;
            v.focus = 2;
        }
    } completion:^(BOOL f) {
        for (UIView *v in rm) [v removeFromSuperview];
        [rm release];
        [weakSelf.activeInputView dismiss];
    }];
    
}
- (void) inputViewChangedThreshold:(MysticInputView *)iv picker:(ILTunePickerView *)picker;
{
    if(picker && picker.tune == MysticTuneAlpha) return;
    self.activeInputView.update(iv.color,iv.selectedColor, iv.selectedColorPoint, iv.threshold,iv.selectedColorIndex, iv,iv.touchesEnded && self.readyForRenderEngine);
}

- (void) inputViewNewTouched:(MysticInputView *)iv;
{
    if([self inputViewNumberOfColors:iv] >= 1)
    {
        [iv hideAddBtn:YES];
        return;
    }
    CGPoint p1 = CGPointCenter(self.imageView.imageView.frame);
    MysticPointColorBtn *btn = [self colorButtonAtPoint:p1 ignoreActive:NO];
    if(btn)
    {
        btn.selected=YES;
        [btn tap];
        self.dropper.alpha = 0;
        self.dropper.point = p1;
        self.dropper.focus = 1;
        return [MysticUIView animateWithDuration:0.3 animations:^{
            self.dropper.focus = 0;
            self.dropper.alpha = 1;
        }];
    }
    self.dropper = [self addColorButtonAtPoint:p1 info:nil create:YES];
    self.dropper.selected = YES;
    self.dropper.alpha = 0;
    self.dropper.point = p1;
    self.dropper.focus = 1;
    [MysticUIView animateWithDuration:0.3 animations:^{
        self.dropper.focus = 0;
        self.dropper.alpha = 1;
    } completion:^(BOOL f) {
        if([self inputViewNumberOfColors:iv] >= 1)
        {
            [iv hideAddBtn:YES];
            return;
        }
    }];
    
}
- (void) inputViewSelectedColorTouched:(MysticInputView *)iv;
{
    if(!(self.dropper && !CGPointIsUnknown(iv.selectedColorPoint))) return;
    self.dropper.point = iv.selectedColorPoint;
    self.dropper.color = iv.selectedColor;
}
static int mapIndex = 0;
- (void) inputViewSetSelectedColor:(MysticInputView *)iv finished:(BOOL)finished;
{
    self.dropper.color = iv.selectedColor;
    
    NSArray *adjusts = self.transformOption.adjustColorsSourceColors;
    if(adjusts.count < 1) return ;
    
    if(!iv.touchesEnded)
    {
        if(mapIndex > 0) return;
        else mapIndex++;
    }
    
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block MysticInputView *_iv = [weakSelf.activeInputView retain];
    weakSelf.readyForRenderEngine = NO;
    mdispatch_high(^{
        MysticLookupImage *limg = [[[MysticLookupImage alloc] init] autorelease];
        UIImage *img = [limg renderMap:_iv.selectedColor rangeMin:fabs(_iv.threshold.range.min) rangeMax:_iv.threshold.range.max];
        self.transformOption.mapDarkest = limg.darkest;
        self.transformOption.mapBrightest = limg.brightest;
        [[MysticOptions current].filters.filter setBrightest:limg.brightest darkest:limg.darkest option:self.transformOption];
        [weakSelf.transformOption setMapImage:img complete:^{

            weakSelf.readyForRenderEngine = YES;
            [weakSelf render:NO atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                _iv.update(_iv.color,_iv.selectedColor, _iv.selectedColorPoint, _iv.threshold,_iv.selectedColorIndex, _iv,YES);
                [_iv autorelease];
                
            }];
        }];
    });
}
- (void) inputViewSetColor:(MysticInputView *)iv finished:(BOOL)finished;
{
    self.dropper.hidden = !finished;
    self.dropper.color2 = iv.color;
    if(!self.readyForRenderEngine) return [self inputViewSetSelectedColor:iv finished:YES];
    iv.update(iv.color,iv.selectedColor, iv.selectedColorPoint, iv.threshold,iv.selectedColorIndex, iv,finished && self.readyForRenderEngine);
}


- (void) tappedImage:(UITapGestureRecognizer *)sender;
{
//    if(sender.state == UIGestureRecognizerStateEnded)
//    {
//        CGPoint p0 = [sender locationInView:self.imageView.imageView];
//        MysticPointColorBtn *btn = [self colorButtonAtPoint:p0 ignoreActive:NO];
//        if(btn)
//        {
//
//        }
//    }

}
- (void) pannedImage:(UITapGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    UIColor *c = nil, *c2 = nil;
    CGPoint p0 = [sender locationInView:self.imageView.imageView];

    if(!CGRectContainsPoint(self.imageView.imageView.bounds, p0)) return;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            self.activeInputView.touchesEnded = NO;
            if(sender.state == UIGestureRecognizerStateBegan) {
                if(self.colorButtonsHidden) [self setColorButtonsHidden:NO];
                MysticPointColorBtn *b = [self colorButtonAtPoint:p0 ignoreActive:NO];
                if(b) {b.selected = YES; [b tap]; c=b.color; }
                self.panningDropper = b;
            }
            if(!self.panningDropper) return;
            c = c ? c : [self colorAtImagePoint:p0];
            if(!c) return;
            c2 = c;
            
            self.panningDropper.point = p0;
            self.panningDropper.color = c;
            self.panningDropper.color2 = c2;
            self.activeInputView.sendFinished = NO;
            self.activeInputView.selectedColor = c;
            self.activeInputView.selectedColorPoint = p0;
            self.activeInputView.colorAndPicker = c2;
            if(self.activeInputView.showDropper) self.activeInputView.showDropper=NO;
            self.activeInputView.update(c2,c,p0,self.activeInputView.threshold, self.panningDropper.index, self.activeInputView,NO);
            self.activeInputView.picker.displayColor = [c isHueDifferentThan:self.activeInputView.picker.displayColor threshold:0.1] ? c : nil;
            break;
        }
        default: break;
    }
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.activeInputView.sendFinished = YES;
        self.activeInputView.showDropper=YES;
        self.activeInputView.touchesEnded = YES;
        self.activeInputView.selectedColor = c;
        self.activeInputView.selectedColorPoint = p0;
        self.activeInputView.colorAndPicker = c2;
        self.panningDropper = nil;

    }

}

- (void) longPressedImage:(UILongPressGestureRecognizer *)sender;
{
    if(!self.transformOption) return;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self.imageView quickLookAtImage:self.colorPickerImage duration:0.2];
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.imageView hideQuickLook:0.2];
            break;
        }
        default:
            break;
    }
    /*
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint p0 = [sender locationInView:self.imageView.imageView];
            MysticPointColorBtn *btn = [self colorButtonAtPoint:p0 ignoreActive:NO];
            if(btn && ![btn isEqual:self.activeDropper])
                switch (sender.state) {
                    case UIGestureRecognizerStateBegan:
                        self.activeInputView.selectedColorIndex = btn.index;
//                        [self revealPlaceholderImage:self.colorPickerImage duration:0.1];
                        self.activeInputView.sendFinished = NO;
                        [MysticUIView animateSpring:0.2 animations:^{
                            btn.focus = 2;
                            btn.alpha = 1;
                            self.dropper.selected=NO;
                        }];
                        break;
                    case UIGestureRecognizerStateChanged:
                    {
                        self.activeInputView.selectedColorPoint = p0;
                        self.activeDropper.center=p0;
                        UIColor *color = [self colorAtImagePoint:p0];
                        if(!color) break;
                        UIColor *color2 = nil;
                        if(self.activeInputView.color) color2 = [UIColor colorWithHue:color.hue saturation:self.activeInputView.color.saturation brightness:self.activeInputView.color.brightness alpha:1];
                        self.activeDropper.color2 = color2;
                        self.activeDropper.color = color;
                        self.activeInputView.selectedColor = color;
                        self.activeInputView.colorAndPicker = color2;
                        self.activeInputView.update(color,color2, p0, self.activeInputView.threshold, self.activeDropper.index, self.activeInputView,NO);
                        break;
                    }
                    case UIGestureRecognizerStateEnded:
                    {
                        [MysticUIView animateSpring:0.2 animations:^{ btn.focus = 0; btn.selected=YES; [btn tap]; }]; break;
                        self.activeInputView.showDropper=YES;
                        UIColor *color = [self colorAtImagePoint:p0];
                        if(!color) break;
                        UIColor *color2 = nil;
                        if(self.activeInputView.color)
                        {
                            MysticColorHSB hsb = self.activeInputView.color.hsb;
                            color2 = [UIColor colorWithHue:color.hue saturation:self.activeInputView.color.saturation brightness:self.activeInputView.color.brightness alpha:1];
                        }
                        self.activeInputView.sendFinished = YES;

                        self.activeInputView.colorAndPicker = color;
                        [self updateSpotColor:color with:color2 threshold:self.activeInputView.threshold save:YES display:YES finished:^{
                            self.activeInputView.update(color,color2, p0, self.activeInputView.threshold, self.activeDropper.index, self.activeInputView,NO);
                        }];

//                        [self rerenderRevealDuration:0.1];
                        break;
                    }
                    default: break;
                }
            
            else switch (sender.state) {
//                case UIGestureRecognizerStateBegan: [self revealPlaceholderImage:self.colorPickerImage duration:0.1]; break;
                case UIGestureRecognizerStateChanged: break;
//                case UIGestureRecognizerStateEnded: [self rerenderRevealDuration:0.1]; break;
                default: break; }
            break;
        }
        default: break;
    }
     */
}
- (MysticPointColorBtn *) addColorButtonAtPoint:(CGPoint)p0 info:(NSDictionary *)clr create:(BOOL)create;
{
    UIColor *k = clr && clr[@"source"] ? clr[@"source"] : nil;
    NSInteger i = clr && clr[@"index"] ? [clr[@"index"] integerValue] : [self.imageView.imageView numberOfSubviewsOfClass:[MysticPointColorBtn class]];
    MysticPointColorBtn *btn = [MysticPointColorBtn color:k?k:[self colorAtImagePoint:p0] point:p0 size:(CGSize){40,40} index:i action:^(MysticPointColorBtn *sender) {
//        if(sender.selected) return;
        for (MysticPointColorBtn*v in [MysticController controller].imageView.imageView.subviews)
            if([v isKindOfClass:[MysticPointColorBtn class]] && ![v isEqual:sender]) v.selected=NO;
        sender.selected = !sender.selected;
        [MysticController controller].dropper = sender;
        [MysticController controller].activeInputView.selectedColorPoint = p0;
        [MysticController controller].activeInputView.selectedColorIndex = sender.index;
        [MysticController controller].activeInputView.selectedColor = isNullOr(sender.color);
        [MysticController controller].activeInputView.colorAndPicker = isNullOr([[MysticController controller].transformOption adjustedColorAtIndex:sender.index]);
        [MysticController controller].activeInputView.showDropper = [MysticController controller].activeInputView.colorAndPicker!=nil;
        [MysticController controller].activeInputView.colorAlpha = [[MysticController controller].transformOption adjustColorIntensityAtIndex:sender.index];
    }];
    self.activeInputView.picker.userInteractionEnabled=YES;
    [self.imageView.imageView addSubview:btn];
    if(create) self.activeInputView.update(btn.color2,btn.color, p0, self.activeInputView.threshold, self.activeDropper.index, self.activeInputView,NO);
    return btn;
}
- (MysticPointColorBtn *) colorButtonAtIndex:(NSInteger)i;
{
    for (MysticPointColorBtn*v in self.imageView.imageView.subviews) {
        if([v isKindOfClass:[MysticPointColorBtn class]] && (i==v.index || (i==NSNotFound && v.selected)))
            return v;
    }
    return nil;
}
- (NSArray *) colorButtons;
{
    return [self.imageView.imageView subviewsOfClass:[MysticPointColorBtn class]];
}

- (MysticPointColorBtn *) colorButtonAtPoint:(CGPoint)c ignoreActive:(BOOL)i;
{
    NSArray *btns1 = [self colorButtons];
    if(!btns1 || btns1.count == 0) return nil;
    NSArray *btns = [[NSArray alloc] initWithArray:btns1];
    id d = i == NO ? [self.dropper retain] : nil;
    for (MysticPointColorBtn*v in btns) {
        if([v isKindOfClass:[MysticPointColorBtn class]] && (i==NO || ![v isEqual:d]))
            if(CGRectContainsPoint(CGRectInset(v.frame,-10,-10), c)) { [d autorelease]; [btns autorelease]; return v; }
    }
    [d autorelease];
    [btns autorelease];
    return nil;
}
- (UIColor*) getPixelColorAtLocation:(CGPoint)point image:(UIImage *)image;
{
    if(!image || CGSizeIsZero(image.size)) return UIColor.blackColor;
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    
    
    
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    //CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

#pragma mark - Show Message
- (void) nixMessageLabel;
{
    mdispatch(^{

        if (self.messageTimer) {
            [_messageTimer invalidate];
            [_messageTimer release];
            _messageTimer = nil;
        }
        
        if (self.messageLabel) {
            [_messageLabel removeFromSuperview];
            [_messageLabel release];
            _messageLabel = nil;
        }
    });
}
- (void) nixImageMessageView;
{
    mdispatch(^{
        
    
        if (self.imageMessageTimer) {
            [_imageMessageTimer invalidate];
            [_imageMessageTimer release];
            _imageMessageTimer = nil;
        }
        
        if (self.imageMessageView) {
            [_imageMessageView removeFromSuperview];
            [_imageMessageView release];
            _imageMessageView = nil;
        }
    });
}
- (void) hideImageMessage:(NSTimer *)timer
{
    [UIView animateWithDuration:0.2f
                     animations:^{ self.imageMessageView.alpha = 0.0f; }
                     completion:^(BOOL finished) {
                         [self nixImageMessageView];
                     }];
    
}

- (void) showImageMessage:(NSArray *)images title:(NSString *)title message:(NSString *)message;
{
    mdispatch(^{
        
        
        if (!self.imageMessageView) {
            NSMutableArray  *imageViews = [NSMutableArray array];
            float           totalWidth = 0;
            float           maxHeight = 0;
            
            // create an image view for each image, and simultaneously compute bounds
            for (UIImage *image in images) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [imageViews addObject:imageView];
                
                totalWidth += CGRectGetWidth(imageView.frame);
                maxHeight = MAX(maxHeight, CGRectGetHeight(imageView.frame));
                
            }
            _imageMessageView = [[WDActionNameView alloc] initWithFrame:CGRectMake(0,0,kMysticImageMessageWidth,kMysticImageMessageHeight)];
            _imageMessageView.delegate = self;
            
            // add the sub image views
            float offset = 0;
            for (UIImageView *imageView in imageViews) {
                imageView.frame = CGRectOffset(imageView.frame, offset, 0);
                [_imageMessageView addSubview:imageView];
                offset += CGRectGetWidth(imageView.frame);
            }
            
            DLog(@"%2.2f", _imageMessageView.frame.size.height);
            // center and show the message view
            CGPoint newCenter = MCenterOfRect(self.imageView.imageViewFrame);
            newCenter.y = 30;
            _imageMessageView.sharpCenter = newCenter;
            
            [self.view addSubview:_imageMessageView];
        }
        [self.imageMessageView setTitle:title message:message];
        [CATransaction begin];
        [self.imageMessageView.layer removeAllAnimations];
        [CATransaction commit];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        // other animation properties
        
        // set view properties
        self.imageMessageView.alpha = 1;
        [UIView commitAnimations];
        if (self.imageMessageTimer) {
            [_imageMessageTimer invalidate];
            [_imageMessageTimer release];
            _imageMessageTimer = nil;
        }
        self.imageMessageTimer = [NSTimer scheduledTimerWithTimeInterval:kMysticImageMessageFadeDelay
                                                              target:self
                                                            selector:@selector(hideImageMessage:)
                                                            userInfo:nil
                                                             repeats:NO];
    });
}
- (void) fadedOutActionNameView:(WDActionNameView *)actionNameView;
{
    if(_imageMessageView)
    {
        [_imageMessageView release];
        _imageMessageView = nil;
    }
    if (self.imageMessageTimer) {
        [_imageMessageTimer invalidate];
        [_imageMessageTimer release];
        _imageMessageTimer = nil;
    }
}
- (void) fadingOutActionNameView:(WDActionNameView *)inActionNameView
{
//    if(_imageMessageView) return;
//    [_imageMessageView release];
//    _imageMessageView = nil;
}

- (void) hideMessage:(NSTimer *)timer
{
    [UIView animateWithDuration:0.2f
                     animations:^{ _messageLabel.alpha = 0.0f; }
                     completion:^(BOOL finished) {
                         [self nixMessageLabel];
                     }];
    
}
- (void) showMessage:(NSString *)message
{
    [self showMessage:message autoHide:YES position:MCenterOfRect(self.view.bounds) duration:kMysticMessageFadeDelay];
}

- (void) showMessage:(NSString *)message autoHide:(BOOL)autoHide position:(CGPoint)position duration:(float)duration
{
    if(self.preventMessages) return;
    BOOL created = NO;
    
    
    if (!_messageLabel) {
        _messageLabel = [[MysticMessage alloc] initWithFrame:CGRectInset(CGRectMake(0,0,100,40), -8, -8)];
        _messageLabel.label.textColor = [UIColor whiteColor];
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:24.0f];
        _messageLabel.label.textAlignment = UITextAlignmentCenter;
        _messageLabel.opaque = NO;
        _messageLabel.backgroundColor = nil;
        _messageLabel.alpha = 0;
        created = YES;
    }
    
    if ([message length] > 20 && runningOnPhone()) {
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:15.0f];
    } else {
        _messageLabel.label.font = [UIFont boldSystemFontOfSize:24.0f];
    }
    
    _messageLabel.text = message;
    [_messageLabel sizeToFit];
    
    CGRect frame = _messageLabel.frame;
    frame.size.width = MAX(frame.size.width, kMysticMinimumMessageWidth);
    frame = CGRectInset(frame, -12, -8);
    _messageLabel.frame = frame;
    _messageLabel.sharpCenter = position;
    if (created) {
        [self.view addSubview:_messageLabel];
        [CATransaction begin];
        [_messageLabel.layer removeAllAnimations];
        [CATransaction commit];
        
        [UIView animateWithDuration:0.2f animations:^{ _messageLabel.alpha = 1; }];
    }
    
    // start message dismissal timer
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        [_messageTimer release];
        _messageTimer = nil;
    }
    
    if (autoHide) self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hideMessage:) userInfo:nil repeats:NO];
    
}

#pragma mark - EffectControlDelegate methods


- (void) toggleButtonToggled:(MysticToggleButton *)toggler;
{
    [self.moreToolsView fadeOutFast];
    [self showImageMessage:nil title:MysticLayerEffectNotifyString(toggler.toggleState) message:nil];
}

- (void) effectControl:(EffectControl *)effectControl accessoryTouched:(id)sender;
{
    MysticButton *senderButton = sender;
    if(self.layerPanelView)
    {
        [self.moreToolsView fadeOutFast];
        if(!self.layerPanelView.targetOption) self.layerPanelView.targetOption = effectControl.option.activeOption ?effectControl.option.activeOption : effectControl.option;
    }
    switch (effectControl.option.type)
    {
        case MysticObjectTypeFilter:
        {
            if(self.layerPanelView) [self.layerPanelView pushPanel:[MysticPanelObject info:@{
                                                                                             @"state": @(self.currentSetting),
                                                                                             @"optionType": @(effectControl.option.type),
                                                                                             @"title": MysticObjectTypeTitleParent(MysticSettingIntensity, MysticObjectTypeUnknown),
                                                                                             @"panel": @(MysticPanelTypeOptionFilterSettings),
                                                                                             @"setting": @(MysticSettingIntensity),
                                                                                             @"subtitle": @"Intensity",
                                                                                             }] complete:nil];
            break;
        }
            
        case MysticObjectTypeColor:
        {
            [((MysticScrollView *)effectControl.superview) scrollViewDidScroll:(id)effectControl.superview];
            if(self.layerPanelView) [self showColorInput:[(PackPotionOption *)effectControl.effect targetOption] title:nil color:nil colorSetting:[(PackPotionOptionColor *)effectControl.effect setting] colorChoice:[(PackPotionOptionColor *)effectControl.effect optionType] colorOption:(PackPotionOptionColor *)effectControl.effect control:effectControl finished:nil];
            break;
        }
            
        default:
        {
            if(self.layerPanelView)
            {
                [MysticTipViewManager hide:@"editlayer" animated:NO];
                [MysticLog answer:@"EditLayer" info:@{@"type":MysticObjectTypeTitleParent(effectControl.option.type, MysticObjectTypeUnknown)}];
                [self.layerPanelView pushPanel:[MysticPanelObject info:@{
                                                                                       @"state": @(self.currentSetting),
                                                                                       @"optionType": @(effectControl.option.type),
                                                                                       @"title": MysticObjectTypeTitleParent(effectControl.option.type, MysticObjectTypeUnknown),
                                                                                       @"animationTransition": @(MysticAnimationTransitionHideBottom),
                                                                                       @"panel": @(MysticPanelTypeOptionLayerSettings),
                                                                                       }] complete:nil];
                
            }
            break;
        }
    }
    
}
- (void) effectControlWasDeselected:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    if([effect isKindOfClass:[PackPotionOption class]]) {
        ((PackPotionOption *)effect).layerEffect = MysticLayerEffectNone;
        MysticToggleButton *toggler = [self.layerPanelView.toolbar.toggleTitleViewReplacement subviewOfClass:[MysticToggleButton class]];
        toggler.hasToggled = NO;
    }
}
- (void) effectControlDidTouchUp:(UIControl *)_effectControl effect:(PackPotionOption *)effectObj;
{
    
    __unsafe_unretained __block  MysticController *weakSelf = self;
    __unsafe_unretained __block  EffectControl *__effectControl = (EffectControl *)_effectControl;
    __unsafe_unretained __block MysticScrollView *_scrollView = (id)[__effectControl.superview retain];
    
    if(_scrollView) [_scrollView setSelectedItem:_effectControl];
    PackPotionOption *effect = (PackPotionOption *)effectObj;
    EffectControl *effectControl = (EffectControl *)_effectControl;
    BOOL reloadImage = YES;
    BOOL skipTools = YES;
    BOOL skipBuildTools = NO;
    BOOL buildTools = NO;
    BOOL showLayerTools = NO;
    NSDictionary *userInfo = nil;
    NSTimeInterval toolsDelay = 0;
    NSInteger nextlastSettingTag = effectControl.tag+ (effect.type + 10000);
    BOOL createNewObject =weakSelf.currentStateInfo[@"createNewObject"] ? [weakSelf.currentStateInfo[@"createNewObject"] boolValue] : NO;
    effect.createNewCopy = createNewObject;
    switch (effect.type) {
            
        case MysticObjectTypeMulti:
        {
            skipTools = YES;
            if(weakSelf.layerPanelView)
            {
                weakSelf.layerPanelView.enabled = effectControl.selected;
                [weakSelf.layerPanelView updateWithTargetOption:effect];
            }
            
            weakSelf.transformOption = effect;
            if(_scrollView)
            {
                __unsafe_unretained __block  EffectControl *_e = [(EffectControl *)_effectControl retain];
                [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                    if([_e respondsToSelector:@selector(viewDidBecomeActive)]) [_e viewDidBecomeActive];
                    [_e release];
                }];
            }
            [effect setUserChoice:YES finished:^{
                [MysticTipViewManager hideAll];
                [weakSelf reloadImageInBackground:YES settings:createNewObject ? MysticRenderOptionsForceProcess : MysticRenderOptionsNone complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                    
                }];
            }];
            break;
        }
        default:
            
            [super userFinishedEffectControlSelections:effectControl effect:effect];
            break;
    }
    
    
    switch (effect.type) {
        case MysticSettingColorFilter:
        case MysticObjectTypeFilter:
        case MysticSettingFilter:
        {
            buildTools = NO;
            weakSelf.transformOption = effect;
            userInfo = @{@"object": effect, @"createNewObject": @(createNewObject), @"refreshState": @YES };
            [weakSelf.currentStateInfo addEntriesFromDictionary:userInfo];
            if(weakSelf.layerPanelView)
            {
                weakSelf.layerPanelView.enabled = effectControl.selected;
                [weakSelf.layerPanelView updateWithTargetOption:effect];
            }
            if(_scrollView)
            {
                __unsafe_unretained __block  EffectControl *_e = [(EffectControl *)_effectControl retain];
                [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                    if([_e respondsToSelector:@selector(viewDidBecomeActive)]) [_e viewDidBecomeActive];
                    [_e release];
                }];
            }
            [weakSelf reloadImageInBackground:YES settings:createNewObject ? MysticRenderOptionsForceProcess : MysticRenderOptionsNone complete:nil];
            break;
        }
        case MysticSettingBadge:
        case MysticSettingFrame:
        case MysticSettingLighting:
        case MysticSettingTexture:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
        case MysticObjectTypeText:
        case MysticObjectTypeCamLayer:
        case MysticSettingColorOverlay:
        case MysticObjectTypeColorOverlay:
        {
            if(self.moreToolsView) [self.moreToolsView fadeOutFast];
            else
            {
                buildTools = YES;
                toolsDelay = MYSTIC_TOOLS_FADEIN_DELAY;
            }
            switch (MysticTypeForSetting(effect.type, effect))
            {
                case MysticObjectTypeBadge:
                case MysticObjectTypeFrame:
                case MysticObjectTypeLight:
                case MysticObjectTypeTexture:
                case MysticObjectTypeText:
                case MysticObjectTypeCamLayer: showLayerTools = YES; break;
                default: break;
            }
            
            weakSelf.transformOption = effect;
            effect.activePack = weakSelf.activePack;
            userInfo = @{@"object": effect, @"createNewObject": @(createNewObject), @"refreshState": @YES };
            [weakSelf.currentStateInfo addEntriesFromDictionary:userInfo];
            if(weakSelf.layerPanelView)
            {
                weakSelf.layerPanelView.enabled = effectControl.selected;
                [weakSelf.layerPanelView updateWithTargetOption:effect];
            }
            
            if(_scrollView)
            {
                __unsafe_unretained __block  EffectControl *_e = [(EffectControl *)_effectControl retain];
                [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                    if([_e respondsToSelector:@selector(viewDidBecomeActive)]) [_e viewDidBecomeActive];
                    [_e release];
                }];
            }
            weakSelf.preventToolsFromBeingVisible = NO;
            if(!(weakSelf.layerPanelView.toolbar.titleToggleView && !weakSelf.layerPanelView.toolbar.hasToggled && weakSelf.layerPanelView.toolbar.titleToggleIndex != NSNotFound))
            {
                MysticToggleButton *toggler = [weakSelf.layerPanelView.toolbar.toggleTitleViewReplacement subviewOfClass:[MysticToggleButton class]];
                toggler.toggleStateAndTrigger = ((PackPotionOption *)__effectControl.effect).layerEffect;
            }
            [MysticTipViewManager hideAll];
            [weakSelf reloadImageInBackground:YES settings:createNewObject ? MysticRenderOptionsForceProcess : MysticRenderOptionsNone complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                if(buildTools && !skipBuildTools) [weakSelf toggleMoreTools:!showLayerTools showForTime:MYSTIC_TOOLS_FADEIN_SHOWTIME afterDelay:toolsDelay];
                if(weakSelf.layerPanelView.toolbar.titleToggleView && !weakSelf.layerPanelView.toolbar.hasToggled && weakSelf.layerPanelView.toolbar.titleToggleIndex != NSNotFound)
                {
                    [weakSelf.layerPanelView.toolbar toggleTitleView:YES complete:^(UIView *newView, UIView *oldView, MysticLayerToolbar *toolbar){
                        
                        MysticToggleButton *toggler = [weakSelf.layerPanelView.toolbar.toggleTitleViewReplacement subviewOfClass:[MysticToggleButton class]];
                        if(!toggler) return;
                        if(![MysticTipView tip:@"magicbutton" inView:weakSelf.view targetView:newView offsetArrow:CGPointMake(0,0) hideAfter:6 delay:0.4 animated:YES])
                            [MysticTipView tip:@"editlayer" inView:weakSelf.view targetView:__effectControl offsetArrow:CGPointMake(-3,__effectControl.frame.size.height/2 - 20) hideAfter:6 delay:0.4 animated:YES];
                        toggler.toggleState = ((PackPotionOption *)__effectControl.effect).layerEffect;
                    }];
                    
                }
                else
                {
                    BOOL showedTip = [MysticTipView tip:@"magicbutton" inView:weakSelf.view targetView:weakSelf.layerPanelView.toolbar.activeToggleTitleView offsetArrow:CGPointMake(0,0) hideAfter:6 delay:0.4 animated:YES];
                    if(!showedTip) [MysticTipView tip:@"editlayer" inView:weakSelf.view targetView:__effectControl offsetArrow:CGPointMake(-3,__effectControl.frame.size.height/2 - 20) hideAfter:6 delay:0.4 animated:YES];
                }
            }];
            skipTools = YES;
            break;
        }
            
        case MysticObjectTypePotion:
        case MysticSettingPotions:
        {
            buildTools = NO;
            if(self.moreToolsView) [self.moreToolsView fadeOutFast];
            
            
            userInfo = @{@"object": effect, @"createNewObject": @(createNewObject), @"refreshState": @YES };
            [weakSelf.currentStateInfo addEntriesFromDictionary:userInfo];
            
            if(weakSelf.layerPanelView)
            {
                weakSelf.layerPanelView.enabled = effectControl.selected;
                [weakSelf.layerPanelView updateWithTargetOption:effect];
            }
            if(_scrollView)
            {
                __unsafe_unretained __block  EffectControl *___effectControl = [(EffectControl *)_effectControl retain];
                [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                    if([___effectControl respondsToSelector:@selector(viewDidBecomeActive)]) [___effectControl viewDidBecomeActive];
                    [___effectControl release];
                }];
            }
            
            MysticOptions *projOptions = [(PackPotionOptionRecipe *)effect project].optionsObject;
            if(projOptions)
            {
                [MysticEffectsManager manager].options = projOptions;
                [weakSelf reloadImageWithMsg:@"Loading..." placeholder:nil hudDelay:0 complete:nil];
                
            }
            weakSelf.preventToolsFromBeingVisible = YES;
            skipTools = YES;
            break;
        }
        case MysticSettingChooseColorFilter:
        {
            buildTools = NO;
            PackPotionOption * lastOption = [[MysticOptions current] option:MysticObjectTypeFilter];
            if(lastOption && lastOption.type == MysticObjectTypeFilter)
            {
                userInfo = @{@"object": lastOption, @"createNewObject": @(createNewObject)};
                [weakSelf.currentStateInfo addEntriesFromDictionary:userInfo];
            }
            if(weakSelf.currentSetting != MysticSettingChooseColorFilter)
            {
                [weakSelf setStateConfirmed:MysticSettingChooseColorFilter animated:YES info:userInfo complete:nil];
            }
            break;
        }
        case MysticSettingUnsharpMask:
        case MysticSettingRGB:
        case MysticSettingLevels:
        case MysticSettingVignette:
        case MysticSettingSharpness:
        case MysticSettingShadows:
        case MysticSettingHighlights:
        case MysticSettingContrast:
        case MysticSettingExposure:
        case MysticSettingGamma:
        case MysticSettingTiltShift:
        case MysticSettingSaturation:
        case MysticSettingBrightness:
        case MysticSettingTemperature:
        case MysticSettingBlending:
        case MysticSettingHaze:
        case MysticSettingCamLayerSetup:
        case MysticSettingColorBalanceRed:
        case MysticSettingColorBalanceGreen:
        case MysticSettingColorBalanceBlue:
        case MysticSettingColorBalance:
        case MysticSettingHSB:
        case MysticSettingHSBHue:
        case MysticSettingHSBSaturation:
        case MysticSettingHSBBrightness:
        {
            [self setStateConfirmed:effect.type animated:YES info:weakSelf.currentStateInfo complete:nil];
            break;
            
        }
        case MysticSettingReset:
        {
            __unsafe_unretained __block MysticController *wself = self;
            NSString *title = @"Are you sure?";
            NSString *message = @"Do you really want to reset your adjustments?";
            
            [MysticAlert ask:title message:message yes:^(id object, id o2) {
                
                [UserPotion resetSettings];
                [wself setState:MysticSettingNone animated:YES complete:^{
                    [wself reloadImage:YES];
                }];
            } no:^(id object, id o2) {
                
            } options:nil];
            
            break;
        }
            
            
        case MysticObjectTypeColor:
        {
            if(_scrollView && [_scrollView isKindOfClass:[MysticScrollView class]]) [_scrollView centerOnView:__effectControl animate:YES complete:nil];
            effect.targetOption.hasChanged = YES;
            [(PackPotionOptionColor *)effect.targetOption setupFilter:[MysticOptions current].filters.filter];
            
            if(__effectControl.option.userChoiceRequiresImageReload)
            {
                [self reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                    __effectControl.option.userChoiceRequiresImageReload = NO;
                }];
            }
            else [MysticEffectsManager refresh:(PackPotionOption *)effect.targetOption];
            break;
        }
        case MysticObjectTypeFont:
        {
            skipTools = YES;
            __unsafe_unretained __block id _scrollView = __effectControl.superview;
            [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                
            }];
            
            break;
        }
        case MysticObjectTypeFontStyle:
        {
            skipTools = YES;
            __unsafe_unretained __block id _scrollView = __effectControl.superview;
            [(MysticScrollView *)_scrollView centerOnView:__effectControl animate:YES complete:^{
                
            }];
            
            break;
        }
        case MysticObjectTypeBlend:
        {
            
            PackPotionOptionBlend *blendOption = (PackPotionOptionBlend *)effect;
            PackPotionOption *option = blendOption.targetOption ? blendOption.targetOption : [weakSelf currentOption:weakSelf.lastSetting];
            [option setBlendingType:MysticFilterTypeFromString([(PackPotionOptionBlend *)effect blendingMode])];
            option.hasChanged = YES;
            [weakSelf reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess];
            break;
        }
        case MysticObjectTypeMulti: break;
        default:
        {
            [self reloadImage:YES];
            break;
        }
    }
    lastSettingTag = nextlastSettingTag;
    if(!skipTools && buildTools)
    {
        [self toggleMoreTools:!showLayerTools];
    }
    
    [_scrollView release];
    
}

#pragma mark - Undo / Redo
- (void) showCompareButton;
{
//    if([UserPotion hasHistory])
//    {
//        if(self.navRightView) return;
//        UIView *rightNavBtnBg = [[[UIView alloc] initWithFrame:(CGRect){0,0, MYSTIC_UI_TOOLS_TOOL_SIZE, MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
//        UIVisualEffectView *effectView2 = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
//        
//        MysticButton *rightNavBtn = [[[MysticButton alloc] initWithFrame:rightNavBtnBg.bounds] autorelease];
//        [rightNavBtn setImage:[MysticIcon iconForType:MysticIconTypeCompare size:(CGSize){17,17} color:[UIColor colorWithRed:0.84 green:0.82 blue:0.76 alpha:1.00]] forState:UIControlStateNormal];
//        [rightNavBtn setImage:[MysticIcon iconForType:MysticIconTypeCompare size:(CGSize){17,17} color:[UIColor colorWithRed:0.87 green:0.38 blue:0.43 alpha:1.00]] forState:UIControlStateHighlighted];
//        [rightNavBtn addTarget:self action:@selector(compareButtonTouched:) forControlEvents:UIControlEventTouchDown];
//        [rightNavBtn addTarget:self action:@selector(compareButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
//        [rightNavBtn addTarget:self action:@selector(compareButtonReleased:) forControlEvents:UIControlEventTouchUpOutside];
//        [rightNavBtn addTarget:self action:@selector(compareButtonReleased:) forControlEvents:UIControlEventTouchCancel];
//
//        rightNavBtn.frame = rightNavBtnBg.bounds;
//        rightNavBtn.contentMode = UIViewContentModeCenter;
//        rightNavBtnBg.userInteractionEnabled = YES;
//        effectView2.frame = rightNavBtnBg.bounds;
//        rightNavBtnBg.clipsToBounds = YES;
//        rightNavBtnBg.layer.cornerRadius = CGRectGetHeight(rightNavBtnBg.frame)/2;
//        [rightNavBtnBg addSubview:effectView2];
//        [rightNavBtnBg addSubview:rightNavBtn];
//        [self setNavRightView:(id)rightNavBtnBg animated:YES];
//    }
//    else
//    {
//        self.navRightView = nil;
//    }
}
- (void) undoRedoChanged:(NSNotification *)notification;
{
    switch (self.currentSetting) {
        case MysticSettingLaunch:
        case MysticSettingNone:
        case MysticSettingNoneFromConfirm:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromLoadProject: { [self showUndoRedo:nil]; [self showCompareButton]; break; }
        default: break;
    }
    [[MysticOptions current] saveProject];

}
- (void) hideUndoRedo:(MysticBlockAnimationCompleteBOOL)completion;
{
    __unsafe_unretained __block MysticBlockAnimationCompleteBOOL _c = completion ? Block_copy(completion) : nil;

    [self.undoRedoTools fadeOut:0.3 completion:^(BOOL finished) {
        [self.undoRedoTools removeFromSuperview];
        self.undoRedoTools = nil;
        if(_c) { _c(finished); Block_release(_c); }
    }];
}
- (void) showUndoRedo:(MysticBlockAnimationCompleteBOOL)completion;
{
    self.navigationController.navigationBarHidden = YES;
    BOOL canUndo = [UserPotion canUndo];
    BOOL canRedo = [UserPotion canRedo];
    if(!canRedo && !canUndo)
    {
        if(self.undoRedoTools) [self hideUndoRedo:completion];
        return;
    }
    
    if(!self.undoRedoTools)
    {
//        DLog(@"making undo redo tools");
        self.undoRedoTools = [[[UIView alloc] initWithFrame:(CGRect){0,0,CGRectInset(self.view.bounds, 24,0).size.width,MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
        self.undoRedoTools.userInteractionEnabled = YES;

        UIView *undoView = [[[UIView alloc] initWithFrame:(CGRect){0,0, MYSTIC_UI_TOOLS_TOOL_SIZE, MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
        UIView *redoView = [[[UIView alloc] initWithFrame:(CGRect){self.undoRedoTools.frame.size.width - MYSTIC_UI_TOOLS_TOOL_SIZE,0, MYSTIC_UI_TOOLS_TOOL_SIZE, MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
        undoView.tag = MysticViewTypeUndo*3;
        redoView.tag = MysticViewTypeRedo*3;
        UIVisualEffectView *effectView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
        UIVisualEffectView *effectView2 = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
        effectView.tag = MysticViewTypeUndo*2;
        effectView.tag = MysticViewTypeRedo*2;

        MysticButton *undoButton = [MysticButton button:nil target:self sel:@selector(undoTouched:)];
        undoButton.frame = undoView.bounds;
        [undoButton setImage:[MysticImage image:@(MysticIconTypeSketchUndo) size:CGSizeIntegral((CGSize){MYSTIC_UI_TOOLS_TOOL_SIZE/2,MYSTIC_UI_TOOLS_TOOL_SIZE/2}) color:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]] forState:UIControlStateNormal];
        undoButton.contentMode = UIViewContentModeCenter;
        MysticButton *redoButton = [MysticButton button:nil target:self sel:@selector(redoTouched:)];
        redoButton.frame = redoView.bounds;
        [redoButton setImage:[MysticImage image:@(MysticIconTypeSketchRedo) size:CGSizeIntegral((CGSize){MYSTIC_UI_TOOLS_TOOL_SIZE/2,MYSTIC_UI_TOOLS_TOOL_SIZE/2}) color:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]] forState:UIControlStateNormal];
        redoButton.contentMode = UIViewContentModeCenter;
        redoView.hidden = !canRedo;
        undoView.hidden = !canUndo;
        undoButton.tag = MysticViewTypeUndo;
        redoButton.tag = MysticViewTypeRedo;
        redoView.userInteractionEnabled = YES;
        undoView.userInteractionEnabled = YES;
        effectView.frame = undoView.bounds;
        effectView2.frame = redoView.bounds;
        undoView.clipsToBounds = YES;
        redoView.clipsToBounds = YES;
        undoView.layer.cornerRadius = CGRectGetHeight(undoView.frame)/2;
        redoView.layer.cornerRadius = CGRectGetHeight(redoView.frame)/2;

        [undoView addSubview:effectView];
        [redoView addSubview:effectView2];
        [undoView addSubview:undoButton];
        [redoView addSubview:redoButton];
        [self.undoRedoTools addSubview:redoView];
        [self.undoRedoTools addSubview:undoView];
        self.undoRedoTools.alpha = 0;
        self.undoRedoTools.center = (CGPoint){self.view.center.x, self.bottomPanelView.frame.origin.y- 33};
        [self.view addSubview:self.undoRedoTools];
        [self.view bringSubviewToFront:self.undoRedoTools];
        [self.undoRedoTools fadeIn:0.3 completion:completion];
    }
    else
    {
        UIView *undoButton = [self.undoRedoTools viewWithTag:MysticViewTypeUndo*3];
        UIView *redoButton = [self.undoRedoTools viewWithTag:MysticViewTypeRedo*3];
        undoButton.alpha = canUndo && undoButton.hidden ? 0 : 1;
        redoButton.alpha = canRedo && redoButton.hidden ? 0 : 1;
        undoButton.hidden = canUndo ? NO : undoButton.hidden;
        redoButton.hidden = canRedo ? NO : redoButton.hidden;
        BOOL changed = NO;
        if((!undoButton.hidden && undoButton.alpha != canUndo ? 1 : 0) || (undoButton.hidden && canUndo)) changed = YES;
        if(!changed && ((!redoButton.hidden && redoButton.alpha != canRedo ? 1 : 0) || (redoButton.hidden && canRedo))) changed = YES;
        if(!changed)
        {
            redoButton.hidden = !canRedo;
            undoButton.hidden = !canUndo;
            return;
        }
        __unsafe_unretained __block MysticBlockAnimationCompleteBOOL _c = completion ? Block_copy(completion) : nil;
        [MysticUIView animate:0.3 animations:^{
            if(!undoButton.hidden && undoButton.alpha != canUndo ? 1 : 0) undoButton.alpha = canUndo ? 1 : 0;
            if(!redoButton.hidden && redoButton.alpha != canRedo ? 1 : 0) redoButton.alpha = canRedo ? 1 : 0;
        } completion:^(BOOL finished) {
            redoButton.hidden = !canRedo;
            undoButton.hidden = !canUndo;
            if(_c) { _c(finished); Block_release(_c); }
        }];
        

    }
}
- (void) undoTouched:(MysticTransformButton *)sender;
{
    if(![UserPotion useLastHistoryItem]) return;
    [self showImageMessage:nil title:@"UNDO" message:nil];
    [self revealPlaceholderImage:[UserPotion potion].sourceImageResized duration:0];
    [MysticOptions reset];
}
- (void) redoTouched:(MysticTransformButton *)sender;
{
    if(![UserPotion useNextHistoryItem]) return;
    [self showImageMessage:nil title:@"REDO" message:nil];
    [self revealPlaceholderImage:[UserPotion potion].sourceImageResized duration:0];
    [MysticOptions reset];
    
}
#pragma mark -
#pragma mark More Tools

- (void) hideMoreTools;
{
    [self toggleMoreTools:YES showForTime:0 afterDelay:0 option:self.currentOption];
}

- (void) showMoreTools;
{
    [self toggleMoreTools:NO showForTime:0 afterDelay:0 option:self.currentOption];
}
- (BOOL) showOrHideMoreTools;
{
    BOOL toolsHidden = self.moreToolsView != nil;
    [self toggleMoreTools:toolsHidden showForTime:0 afterDelay:0 option:self.currentOption];
    return toolsHidden;
}


- (void) toggleMoreTools:(BOOL)hide afterDelay:(NSTimeInterval)tdelay;
{
    [self toggleMoreTools:hide showForTime:-1 afterDelay:tdelay];
    
}
- (void) toggleMoreTools:(BOOL)hide showForTime:(NSTimeInterval)showTime afterDelay:(NSTimeInterval)tdelay;
{
    [self toggleMoreTools:hide showForTime:showTime afterDelay:tdelay option:nil];
}
- (void) toggleMoreTools:(BOOL)hide showForTime:(NSTimeInterval)showTime afterDelay:(NSTimeInterval)tdelay option:(PackPotionOption *)opt;
{
    
    
    showTime = showTime <= 0 ? MYSTIC_TOOLS_TAP_FADEOUT_DELAY : showTime;
    
    if(tdelay > 0)
    {
        __unsafe_unretained __block MysticController *weakSelf = self;
        [weakSelf stopMoreToolsTimer];
        mdispatch(^{
            weakSelf.moreToolsTimer = [NSTimer scheduledTimerWithTimeInterval:tdelay target:weakSelf selector:hide ? @selector(toggleMoreToolsHide) : @selector(toggleMoreToolsShow) userInfo:opt ? @{@"showForTime": @(showTime), @"option": opt} : @{@"showForTime": @(showTime)} repeats:NO];
        });
        
    }
    else
    {
        [self toggleMoreTools:hide showForTime:showTime option:opt];
    }
    
}

- (void) stopMoreToolsTimer;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    
    mdispatch(^{
        
        if(weakSelf.moreToolsTimer)
        {
            [weakSelf.moreToolsTimer invalidate];
            weakSelf.moreToolsTimer = nil;
        }
        
    });
    
}

- (void) toggleMoreToolsHide;
{
    [self toggleMoreTools:YES];
}
- (void) toggleMoreToolsShow;
{
    NSTimeInterval showTime = self.moreToolsTimer && [self.moreToolsTimer.userInfo objectForKey:@"showForTime"] ? [[self.moreToolsTimer.userInfo objectForKey:@"showForTime"] floatValue] : -1;
    [self toggleMoreTools:NO showForTime:showTime option:[self.moreToolsTimer.userInfo objectForKey:@"option"]];
}

- (void) toggleMoreTools:(BOOL)hide
{
    [self toggleMoreTools:hide showForTime:-1 option:nil];
}
- (void) toggleMoreTools:(BOOL)hide showForTime:(NSTimeInterval)showTime option:(PackPotionOption *)opt;
{
    showTime = showTime == -1 ? MYSTIC_TOOLS_TAP_FADEOUT_DELAY :  showTime;
    [self stopMoreToolsTimer];
    
    
    BOOL hasMoreTools = self.moreToolsView != nil;
    if(self.moreToolsView && hide) { [self.moreToolsView removeFromSuperview];  self.moreToolsView = nil; }
    
    //self.imageView.userInteractionEnabled = hide;
    
    if(hide || self.moreToolsView || self.preventToolsFromBeingVisible) return;
    if(self.moreToolsView)
    {
        [self.moreToolsView resetDefaults];
    }
    CGFloat toolSize = MYSTIC_UI_TOOLS_TOOL_SIZE;
    BOOL barsVisible = [(MysticNavigationViewController *)self.navigationController willNavigationBarBeVisible];
    UIEdgeInsets insets = [MysticPhotoContainerView insets];
    insets.top -= barsVisible ? MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET;
    insets.bottom -= barsVisible ? MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET;
    
    if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
    {
        switch (self.layerPanelView.visiblePanel.panelType) {
            case MysticPanelTypeFont:
            case MysticPanelTypeFonts:
            case MysticPanelTypeFontStyle:
            case MysticPanelTypeFontAdjust:
            case MysticPanelTypeFontAlign:
            case MysticPanelTypeShape:
            {
                insets.top += MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_Y;
                insets.bottom += MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_Y;
                insets.left += MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_X;
                insets.right += MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_X;
                toolSize = MYSTIC_UI_TOOLS_TOOL_SIZE_SMALL;
                break;
            }
                
            default:
            {
                insets.top += MYSTIC_UI_TOOLS_INSET_EDIT;
                insets.bottom += MYSTIC_UI_TOOLS_INSET_EDIT;
                break;
            }
        }
    }
    else
    {
        insets.top += MYSTIC_UI_TOOLS_INSET_HOME;
        insets.bottom += MYSTIC_UI_TOOLS_INSET_HOME;
    }
    
    CGRect toolsFrame = UIEdgeInsetsInsetRect(self.imageVisibleFrame, insets);
    
    self.moreToolsView = [[[MysticTools alloc] initWithFrame:toolsFrame setting:currentSetting] autorelease];
    self.moreToolsView.option = opt;
    self.moreToolsView.hidden = NO;
    self.moreToolsView.viewController = self;
    self.moreToolsView.alpha = 0;
    self.moreToolsView.toolSize = toolSize;
    self.moreToolsView.currentSetting = currentSetting;
    
    [self.view insertSubview:self.moreToolsView aboveSubview:self.overlayView];
    [self.view bringSubviewToFront:self.moreToolsView];
    
    if(!hasMoreTools)
    {
        
        if(showTime == -1)
        {
            [self.moreToolsView fadeInWithTimer:showTime];
        }
        else
        {
            [self.moreToolsView fadeInFast];
        }
        
    }
    
    
    
    
}

- (void) refreshBlurImage;
{
    [self refreshBlurImageFinished:nil];
}
- (void) refreshBlurImageFinished:(MysticBlockArrayBOOL)finished;
{
    return;
    
}

- (void) rebuildBlurImage:(MysticBlockArrayBOOL)finished renderedImage:(UIImage *)renderedImage;
{
    //    DLog(@"rebuild blur image: %@  tag: %@",  MBOOL(renderedImage != nil), [MysticOptions current].tag);
    
    return;
    //    if(![MysticOptions current] || ![MysticOptions current].tag)
    //    {
    //         DLog(@"NO TAG?????");
    //    }
    //
    //    [self setBlurImage:[[self class] screenShot:NO renderedImage:renderedImage rect:CGRectZero tintColor:nil complete:nil] finished:finished];
    //
    //    [[MysticCache tempCache] storeImage:self.blurImage.downsampleImage forKey:[NSString stringWithFormat:@"%@____BLUR", [MysticOptions current].projectName] toDisk:YES toMemory:NO];
    //    [[MysticCache tempCache] storeImage:self.blurImage.downsampleImage forKey:[NSString stringWithFormat:@"%@____xBLR%@", [MysticOptions current].projectName, [MysticOptions current].tag] toDisk:YES toMemory:NO];
    
}









#pragma mark - NSNotification for MysticUserPotionChanged

- (void) userPotionChanged:(NSNotification *)notification
{
    
    MysticObjectType changeType = [[notification.userInfo objectForKey:@"type"] intValue];
    
    
    switch (changeType) {
        case MysticSettingFilter:
            if(sectionLabel)
            {
                [sectionLabel removeFromSuperview]; [sectionLabel release], sectionLabel=nil;
            }
            
            
            
            break;
            
            
        default: break;
    }
}



#pragma mark - Set Title
- (void) setTitle:(NSString *)value;
{
    
    
    if(value && self.navigationItem.titleView)
    {
        self.navigationItem.titleView=nil;
    }
    
    value = value ? [value uppercaseString] : nil;
    self.navigationItem.title = value ? NSLocalizedString(value, nil) : nil;
    [super setTitle:self.navigationItem.title];
    
    if(value)
    {
        
        
        
        NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:value];
        [str setCharacterSpacing:2];
        [str setFont:[[[MysticNavigationBar appearance] titleTextAttributes] objectForKey:UITextAttributeFont]];
        [str setTextColor:[[[MysticNavigationBar appearance] titleTextAttributes] objectForKey:UITextAttributeTextColor]];
        OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, [MysticUI screen].width, self.navigationController.navigationBar.frame.size.height)];
        [label setAttributedText:str];
        label.centerVertically = YES;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        [label release];
        
    }
    
}

- (void) updateOverlaysView:(MysticOverlaysView *)overlaysView refreshLayerPanel:(BOOL)refreshLayerPanel;
{
    overlaysView.hidden = NO;
    if(overlaysView && self.layerPanelView && overlaysView.selectedLayer) [self.layerPanelView refresh];
 
}

#pragma mark - PhotoViewContainer Delegate

- (void) photoViewContainer:(MysticPhotoContainerView *)container didChangeFrame:(CGRect)frame original:(CGRect)originalFrame;
{
    [self updateTransformViews];
}
- (void) updateTransformViews;
{
    BOOL layersHidden = self.labelsView.hidden;
    BOOL shapesHidden = self.shapesView.hidden;
    NSArray *dontTransformViews = [self dontTransformViews];
    self.labelsView.frame = self.imageView.imageView.bounds;
    self.shapesView.frame = self.imageView.imageView.bounds;
    [self.overlayView updateFrame];
    for (MysticOverlaysView *lView in self.transformViews) {
        if([dontTransformViews containsObject:lView] || [lView isEqual:self.overlayView]) continue;
        lView.frame = self.imageView.imageView.bounds;
    }
    self.labelsView.hidden = layersHidden;
    self.shapesView.hidden = shapesHidden;
}


- (void) removeTempControls:(id)exceptObj;
{
    if(!temporaryControlViews.count) return;
    
    NSMutableSet *controls = [NSMutableSet setWithSet:temporaryControlViews];
    
    NSArray *except = ![exceptObj isKindOfClass:[NSArray class]] && exceptObj ? @[exceptObj] : exceptObj;
    for (UIView *tControl in temporaryControlViews) {
        if(except && [except containsObject:tControl]) continue;
        [tControl removeFromSuperview];
        [controls removeObject:tControl];
    }
    [temporaryControlViews release];
    temporaryControlViews = [controls retain];
}



- (CGRect) refreshImageViewFrame:(MysticBlockBOOL)finished; { return [self refreshImageViewFrameDuration:-1 complete:finished]; }
- (CGRect) refreshImageViewFrameDuration:(NSTimeInterval)animDuration complete:(MysticBlockBOOL)finished;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    BOOL barsVisible = [(MysticNavigationViewController *)weakSelf.navigationController willNavigationBarBeVisible];
    CGFloat navH = !barsVisible ? 0 : weakSelf.navigationController.navigationBar.frame.size.height;
    UIEdgeInsets insets = [MysticPhotoContainerView defaultInsets];
    insets.top = barsVisible ? navH + MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET;
    insets.bottom = barsVisible ? kBottomToolBarHeight + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET;
    if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
    {
        switch (self.layerPanelView.visiblePanel.panelType) {
            case MysticPanelTypeFont:
            case MysticPanelTypeFonts:
            case MysticPanelTypeFontStyle:
            case MysticPanelTypeFontAdjust:
            case MysticPanelTypeFontAlign:
            case MysticPanelTypeShape:
            {
                insets.top += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                insets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                insets.left = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                insets.right = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                break;
            }
            default:
            {
                insets.top += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                insets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                break;
            }
        }
    }
    else
    {
        insets.top += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
        insets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
    }
    return [self insetImageView:insets duration:animDuration complete:finished];
}
- (CGRect) insetImageView:(UIEdgeInsets)insets complete:(MysticBlockBOOL)finished;
{
    return [self insetImageView:insets duration:-1 complete:finished];
}
- (CGRect) insetImageView:(UIEdgeInsets)insets duration:(NSTimeInterval)animDuration complete:(MysticBlockBOOL)finished;
{
    __unsafe_unretained __block MysticController *ws = self;
    if(self.isNavViewVisible) insets.top = MAX(MYSTIC_UI_IMAGEVIEW_INSET_NAV_VIEWS_OFFSET, insets.top);
    CGFrameInsets r = [self imageViewFrame:self.view.frame insets:UIEdgeInsetsCopy(insets) offset:CGPointZero];
    [MysticUIView animateWithDuration:animDuration<0 ?.25:animDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:
     ^{
         [ws setImageViewFrame:ws.view.frame insets:insets offset:CGPointZero];
     } completion:finished];
    return r.frame;
}


- (CGRect) setImageViewFrame:(CGRect)frame insets:(UIEdgeInsets)insets offset:(CGPoint)offset;
{
    CGFrameInsets r = [self imageViewFrame:frame insets:insets offset:offset];
    [self.imageView centerImageView:r.insets];
//    self.overlayView.frame = self.labelsView.frame;
//    for (UIView *v in self.transformViews) {
//        v.transform = self.labelsView.transform;
//        v.center = self.imageView.imageView.center;
//    }
    if(self.moreToolsView) self.moreToolsView.center = self.moreToolsView.center;
    return r.frame;
    
}
- (CGFrameInsets) imageViewFrame:(CGRect)newImageViewFrame insets:(UIEdgeInsets)insets offset:(CGPoint)offset;
{
    __unsafe_unretained __block  MysticController *weakSelf = self;
//    if(self.labelsView) self.labelsView.center = CGPointCenter(self.imageView.frame);
//    if(self.shapesView) self.shapesView.center = CGPointCenter(self.imageView.frame);
    self.imageView.offset = offset;
    self.imageView.frame = self.view.bounds;
    insets.left = 10;
    insets.right = 10;
    switch (currentSetting) {
        case MysticSettingUnLaunched:
        case MysticSettingLaunch:
        case MysticSettingNone:
        case MysticSettingNoneFromConfirm:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromLoadProject:
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticSettingDesign:
        case MysticSettingChooseText:
        case MysticSettingText:
        case MysticSettingCamLayer:
        case MysticSettingBadge:
        case MysticSettingFrame:
        case MysticSettingLighting:
        case MysticSettingTexture:
        case MysticSettingFilter:
        case MysticSettingChooseColorFilter:
        case MysticObjectTypeColorOverlay:
        case MysticSettingColorOverlay:
        {
            insets.left = 0;
            insets.right = 0;
            break;
        }
        case MysticSettingAddLayer:
        {
            insets.left = 30;
            insets.right = 30;
            break;
        }
        default:
        {
            if(!(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)) break;
            switch (self.layerPanelView.visiblePanel.panelType) {
                case MysticPanelTypeShape:
                case MysticPanelTypeFont:
                case MysticPanelTypeFonts:
                case MysticPanelTypeFontStyle:
                case MysticPanelTypeFontAdjust:
                case MysticPanelTypeFontAlign: insets.left = 0; insets.right = 0; break;
                default: break;
            }
        }
    }
    
    return (CGFrameInsets){[self.imageView centerImageViewFrame:insets], insets};
}

#pragma mark - Share

- (void) shareTouched:(id)sender
{
    self.currentSetting = MysticSettingShare;
    
}

#pragma mark - STATE: Close State

- (void) setCurrentOption:(PackPotionOption *)option;
{
    [super setCurrentOption:option];
    if(option && option.type == MysticObjectTypeSetting)
    {
        if(self.layerPanelView)
        {
            self.layerPanelView.targetOption = option;
        }
    }
}
- (void) closeState:(MysticObjectType)currentState nextState:(MysticObjectType)nextState info:(NSDictionary *)userInfo;
{
    
    __unsafe_unretained __block  MysticController *weakSelf = self;
    switch (currentState) {
            
        case MysticObjectTypeFont:
        case MysticObjectTypeFontStyle:
        case MysticSettingType:
        {
            
            
            break;
        }
        default: break;
    }
}

- (void) closedState:(MysticObjectType)state;
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    
    if(self.isObservingLargeImage && [keyPath isEqualToString:@"isSavingLargeImage"] && [[change objectForKey:NSKeyValueChangeNewKey] boolValue] != [[change objectForKey:NSKeyValueChangeOldKey] boolValue] && ![[change objectForKey:NSKeyValueChangeNewKey] boolValue])
    {
        if(self.renderCompleteObj)
        {
            [self render:self.renderCompleteObj.returnImage atSourceSize:self.renderCompleteObj.atSourceSize complete:self.renderCompleteObj.complete];
            self.renderCompleteObj = nil;
            [self removeObserver:self forKeyPath:@"isSavingLargeImage"];
            self.isObservingLargeImage = NO;
        }
        else [self setState:MysticSettingShare animated:NO complete:nil];
    }
}


#pragma mark - Set State
- (void) setParentStateBasedOnState:(MysticObjectType)state;
{
    __unsafe_unretained __block  MysticController *weakSelf = self;
    
    if(weakSelf.parentSetting != MysticSettingInTransition)
    {
        switch (state) {
            case MysticSettingChooseFont:
            case MysticSettingSelectType:
            case MysticSettingTypeAlpha:
            case MysticSettingType:
                weakSelf.parentSetting = MysticSettingType;
                break;
            case MysticSettingText:
            case MysticSettingTextAlpha:
            case MysticSettingTextColor:
            case MysticSettingTextTransform:
                weakSelf.parentSetting = MysticSettingText;
                break;
            case MysticSettingTexture:
            case MysticSettingTextureAlpha:
                weakSelf.parentSetting = MysticSettingTexture;
                break;
            case MysticSettingFrame:
            case MysticSettingFrameAlpha:
            case MysticSettingFrameColor:
            case MysticSettingFrameTransform:
                weakSelf.parentSetting = MysticSettingFrame;
                break;
            case MysticSettingLighting:
            case MysticSettingLightingAlpha:
                weakSelf.parentSetting = MysticSettingLighting;
                break;
            case MysticSettingFilter:
            case MysticSettingFilterAlpha:
                weakSelf.parentSetting = MysticSettingFilter;
                break;
            case MysticSettingCamLayer:
            case MysticSettingCamLayerAlpha:
            case MysticSettingCamLayerSetup:
            case MysticSettingCamLayerColor:
            case MysticSettingCamLayerTakePhoto:
                weakSelf.parentSetting = MysticSettingCamLayer;
                
            case MysticSettingRecipe:
            case MysticSettingRecipeProject:
                weakSelf.parentSetting = MysticSettingRecipe;
                break;
                
            case MysticSettingSettings:
            case MysticSettingTemperature:
            case MysticSettingTiltShift:
            case MysticSettingSaturation:
            case MysticSettingVignette:
            case MysticSettingGamma:
            case MysticSettingContrast:
            case MysticSettingExposure:
            case MysticSettingHighlights:
            case MysticSettingShadows:
            case MysticSettingBrightness:
            case MysticSettingHaze:
            case MysticSettingSharpness:
            case MysticSettingLevels:
            case MysticSettingUnsharpMask:
            case MysticSettingHSB:
            case MysticSettingHSBHue:
            case MysticSettingHSBSaturation:
            case MysticSettingHSBBrightness:
            case MysticSettingColorBalance:
            case MysticSettingColorBalanceRed:
            case MysticSettingColorBalanceGreen:
            case MysticSettingColorBalanceBlue:
            {
                switch (weakSelf.parentSetting) {
                    case MysticSettingType:
                    case MysticSettingText:
                    case MysticSettingCamLayer:
                    case MysticSettingRecipe:
                    case MysticSettingFilter:
                    case MysticSettingTexture:
                    case MysticSettingLighting:
                    case MysticSettingFrame: break;
                    default:
                        weakSelf.parentSetting = MysticSettingSettings;
                        break;
                }
                break;
            }
            default:
            {
                weakSelf.parentSetting = MysticSettingNone;
                break;
            }
        }
    }
}

- (void) refreshState:(NSDictionary *)newInfo;
{
    [self refreshState:currentSetting info:newInfo];
}
- (void) refreshState:(MysticObjectType)state info:(NSDictionary *)newInfo;
{
    [self refreshState:state info:newInfo completion:nil];
}
- (void) refreshState:(MysticObjectType)state info:(NSDictionary *)newInfo completion:(MysticBlock)finished;
{
    currentSetting = lastSetting;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.currentStateInfo];
    [userInfo setObject:@(YES) forKey:@"refreshState"];
    if(newInfo) [userInfo addEntriesFromDictionary:newInfo];
    
    [self setStateConfirmed:state animated:YES info:userInfo complete:finished];
}
- (void) setCurrentSetting:(MysticObjectType)_currentSetting
{
    [self setState:_currentSetting animated:YES complete:nil];
}
- (void) setState:(MysticObjectType)state info:(NSDictionary *)userInfo;
{
    [self setStateConfirmed:state animated:YES info:userInfo complete:nil];
}
- (void) setState:(MysticObjectType)state animated:(BOOL)animated complete:(void (^)())finishedState;
{
    [self setStateConfirmed:state animated:animated complete:finishedState];
}

- (void) setStateConfirmed:(MysticObjectType)state animated:(BOOL)animated complete:(void (^)())finishedState;
{
    [self setStateConfirmed:state animated:animated info:[NSDictionary dictionary] complete:finishedState];
    
}


- (void) setStateConfirmed:(MysticObjectType)state animated:(BOOL)animated info:(NSDictionary *)userInfo complete:(void (^)())finishedState;
{
    [self state:state animate:@(animated) info:userInfo complete:finishedState];
}
- (MysticAnimationBlockObject *) state:(MysticObjectType)state animate:(id)animatedObj info:(NSDictionary *)userInfo complete:(void (^)())finishedState;
{
    MysticAnimationBlockObject *animation = [self stateAnim:state animate:animatedObj info:userInfo complete:finishedState];
    if(animation && !animation.finished) [animation animate];
    return animation;
}
- (MysticAnimationBlockObject *) stateAnim:(MysticObjectType)state animate:(id)animatedObj info:(NSDictionary *)userInfo complete:(void (^)())finishedState;
{
    BOOL animated = animatedObj && [animatedObj isKindOfClass:[MysticAnimationBlockObject class]] ? [(MysticAnimationBlockObject *)animatedObj animated] : [animatedObj boolValue];
    NSTimeInterval animationDuration = 0.3;
    NSTimeInterval animationDelay = 0;
    __unsafe_unretained __block  MysticController *weakSelf = self;
    __unsafe_unretained __block MysticAnimationBlockObject *animation = [MysticAnimationBlockObject animation];
    animation.duration = animationDuration;
    animation.delay = animationDelay;
    animation.animationOptions = animation.animationOptions == 0 ? UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState : animation.animationOptions;
    animation.name = animation.name ? animation.name : [NSString stringWithFormat:@"%@ -> %@", MysticString(self.currentSetting), MysticString(state)];
    [animation addAnimations:animatedObj];
    
    MysticObjectType closedState = weakSelf.currentSetting;
    [weakSelf closeState:weakSelf.currentSetting nextState:state info:userInfo];
    [weakSelf setParentStateBasedOnState:state];
    [weakSelf.layerCountButton setTitle:[NSString stringWithFormat:@"%d", (int)[MysticOptions current].count+1] forState:UIControlStateNormal];
#pragma mark - STATE: Set defaults
    
    NSString *bottomBarTitle = nil;
    
    BOOL refreshingState = userInfo && [userInfo objectForKey:@"refreshState"] ? [[userInfo objectForKey:@"refreshState"] boolValue] : NO;
    BOOL reloadImage = NO;
    BOOL reloadImageWithHUD = YES;
    BOOL bottomToolBarHidden = NO;
    BOOL bottomPanelHidden = NO;
    BOOL bottomToolBarButtonsHidden = NO;
    BOOL layerToolsHidden = YES;
    BOOL ignoreLayerTools = NO;
    BOOL removeHiddenControls = YES;
    BOOL navigationBorder = NO;
    BOOL createNewObject = NO;
    BOOL hideNavBar = NO;
    BOOL willShowBars = NO;
    BOOL setHasChangedOptions = NO;
    BOOL skipUILayout = NO;
    BOOL needsScrollToSelected = currentSetting == state ? NO : YES;
    CGPoint offset = CGPointZero;
    weakSelf.preventToolsFromBeingVisible = YES;
    pickingColor = NO;
    
    id moveBottomNippleTo = nil;
    MysticBlockAnimation animations = nil;
    MysticBlockAnimationComplete animationsComplete = nil;
    MysticBlock reloadImageComplete = nil;
    UIEdgeInsets insets = [MysticPhotoContainerView defaultInsets];
    
    CGSize viewSize = weakSelf.view.frame.size;
    CGRect newFrameBottomToolBar = weakSelf.bottomToolbar.frame;
    newFrameBottomToolBar.size.width = [MysticUI screen].width;
    CGRect newFrameImageView = weakSelf.imageView.frame;
    CGRect newBottomPanelFrame = weakSelf.bottomPanelView.frame;
    
    
    lastSetting = currentSetting;
    currentSetting = state;
    [UserPotion potion].editingType = currentSetting;
    
    if(weakSelf.shapesView) [weakSelf.shapesController disableOverlays];
    if(weakSelf.labelsView) [weakSelf.fontStylesController disableOverlays];
    
    
    if(!refreshingState && temporaryControlViews.count) [temporaryControlViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (UIView *subview in weakSelf.bottomToolbar.subviews)  if(subview != weakSelf.tabBar && subview.hidden) subview.hidden = NO;
    
    
    if(self.fadeView) [self removeFadeView];
    
    
#pragma mark - STATE:     UserInfo
    
    PackPotionOption *_currentOption = nil;
    if(userInfo && [userInfo objectForKey:@"object"] && [[userInfo objectForKey:@"object"] isKindOfClass:[MysticOption class]])
    {
        _currentOption = [userInfo objectForKey:@"object"];
        weakSelf.transformOption = _currentOption;
    }
    else
    {
        _currentOption = [self currentOption:state];
    }
    MysticObjectType userNextState = MysticSettingUnknown;
    if([userInfo objectForKey:@"nextState"]) userNextState = [[userInfo objectForKey:@"nextState"] integerValue];
    MysticObjectType userBackState = MysticSettingUnknown;
    if([userInfo objectForKey:@"cancelState"]) userBackState = [[userInfo objectForKey:@"cancelState"] integerValue];
    
    MysticObjectType lastState = userNextState != MysticSettingUnknown ? userNextState : weakSelf.lastSetting;
    MysticObjectType userConfirmedState = userNextState != MysticSettingUnknown ? userNextState : MysticSettingNone;
    MysticObjectType userCanceledState = userBackState != MysticSettingUnknown ? userBackState : userConfirmedState;
    userConfirmedState = userConfirmedState == weakSelf.currentSetting ? MysticSettingNone : userConfirmedState;
    
    if(userInfo && [userInfo objectForKey:@"createNewObject"]) createNewObject = [[userInfo objectForKey:@"createNewObject"] boolValue];
    
    self.shouldScrollToActiveControl = !createNewObject;
    self.shouldSelectActiveControls = !createNewObject;
    
    MysticObjectType theType = MysticTypeForSetting(state, _currentOption);
    self.currentStateInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [self.currentStateInfo removeObjectsForKeys:refreshingState ? @[@"refreshState"] : @[@"nextState", @"cancelState", @"createNewObject", @"refreshState"]];
#pragma mark - STATE: Non Home Screen
    switch (self.currentSetting) {
        case MysticSettingLaunch:
        case MysticSettingNone:
        case MysticSettingNoneFromConfirm:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingStartProject:
        case MysticSettingNewProject:
        case MysticSettingShare:
        case MysticSettingFeedback:
        case MysticSettingPreferences:
        case MysticSettingAddLayer:
        {
            break;
        }
            
        default:
            weakSelf.navLeftView = nil;
            weakSelf.navRightView = nil;

            break;
    }
    
    switch (self.currentSetting) {
            
#pragma mark - STATE: New Project
        case MysticSettingNewProject:
        {
            weakSelf.currentOption = nil;
            [(AppDelegate *)[UIApplication sharedApplication].delegate newProject];
            return nil;
        }
            
            
            
            
            
            
#pragma mark - STATE: Start Project
            
        case MysticSettingStartProject:
        {
            weakSelf.currentOption = nil;
            [[(PackPotionOptionRecipe *)[userInfo objectForKey:@"project"] project] open:^(MysticProject *obj, BOOL success) {
                mdispatch(^{
                    [weakSelf setState:MysticSettingNone animated:YES complete:^{ [weakSelf reloadImage:YES complete:nil]; }];
                });
            }];
            return nil;
        }
            
            
            
            
            
            
            
#pragma mark - STATE: HOME   None  &  Launch
            
        case MysticSettingLaunch:
        case MysticSettingNone:
        case MysticSettingNoneFromConfirm:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromLoadProject:
        {
            weakSelf.navCenterView = nil;
            //weakSelf.navLeftView = nil;
//            weakSelf.navRightView = nil;
            [weakSelf.view removeAllRects];
            
            
            UIView *leftNavBtnBg = [[[UIView alloc] initWithFrame:(CGRect){0,0, MYSTIC_UI_TOOLS_TOOL_SIZE, MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
            UIVisualEffectView *effectView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
            
            MysticButton *leftNavBtn = [MysticButton buttonWithImage:[MysticIcon iconForType:MysticIconTypeMenu size:(CGSize){17,17} color:[UIColor colorWithRed:0.84 green:0.82 blue:0.76 alpha:1.00]] target:weakSelf sel:@selector(backButtonTouched:)];
            leftNavBtn.frame = leftNavBtnBg.bounds;
            leftNavBtn.contentMode = UIViewContentModeCenter;
            leftNavBtnBg.userInteractionEnabled = YES;
            effectView.frame = leftNavBtnBg.bounds;
            leftNavBtnBg.clipsToBounds = YES;
            leftNavBtnBg.layer.cornerRadius = CGRectGetHeight(leftNavBtnBg.frame)/2;
            [leftNavBtnBg addSubview:effectView];
            [leftNavBtnBg addSubview:leftNavBtn];
            [weakSelf setNavLeftView:(id)leftNavBtnBg animated:YES];
            
            
            tabrendering = NO;
            tabrefreshing = NO;
            
            
            UIView *rightNavBtnBg = [[[UIView alloc] initWithFrame:(CGRect){0,0, 64.5, MYSTIC_UI_TOOLS_TOOL_SIZE}] autorelease];
            UIVisualEffectView *effectView2 = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
            
            MysticButton *rightNavBtn = [MysticButton buttonWithTitle:@"SAVE" target:weakSelf sel:@selector(saveButtonTouched:)];
            [rightNavBtn setTitleColor:[UIColor color:MysticColorTypeNavBarText] forState:UIControlStateNormal];
            rightNavBtn.titleLabel.font = [MysticFont font:12];
            CGRect newRightBtnFrame = rightNavBtn.bounds;
            newRightBtnFrame.origin.y = 3;
            
            rightNavBtn.frame = newRightBtnFrame;
            rightNavBtn.contentMode = UIViewContentModeCenter;
            rightNavBtnBg.userInteractionEnabled = YES;
            CGRect newEffectViewBounds = rightNavBtn.bounds;
            newEffectViewBounds.size.height = effectView.bounds.size.height;
            newEffectViewBounds.size.width = rightNavBtnBg.bounds.size.width;
            effectView2.frame = newEffectViewBounds;
            rightNavBtnBg.clipsToBounds = YES;
            rightNavBtnBg.layer.cornerRadius = CGRectGetHeight(rightNavBtnBg.frame)/2;
            [rightNavBtnBg addSubview:effectView2];
            [rightNavBtnBg addSubview:rightNavBtn];
            [weakSelf setNavRightView:(id)rightNavBtnBg animated:YES];
            
            
            
            
//            [self showCompareButton];
            MysticWait(1, ^{ weakSelf.navigationController.navigationBar.userInteractionEnabled = NO; });

            if(weakSelf.quoteController)
            {
                [weakSelf quoteViewControllerDidClose:weakSelf.quoteController];
                [weakSelf.quoteController.view removeFromSuperview];
                weakSelf.quoteController = nil;
            }
            if(weakSelf.layerEditController)
            {
                [weakSelf layerEditViewControllerDidClose:weakSelf.layerEditController];
                weakSelf.layerEditController = nil;
            }
            [weakSelf.colorButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.activeDropper = nil;
            self.dropper = nil;
            
            confirmedSetting = MysticSettingNone;
            canceledSetting = MysticSettingNone;
            
            bottomToolBarHidden = NO;
            
            newFrameBottomToolBar.origin.y = viewSize.height - kBottomToolBarHeight;
            newFrameImageView.size.height = newFrameBottomToolBar.origin.y;
            newFrameImageView.origin.y = 0;
            
            [weakSelf removeSubviews:weakSelf.bottomToolbar except:[NSArray arrayWithObjects:weakSelf.tabBar, weakSelf.view, nil]];
            [weakSelf.navigationController.navigationBar layoutIfNeeded];
            
            [MysticOptions current].optionRules = MysticRenderOptionsAuto;
            reloadImage = NO;
            reloadImageWithHUD = NO;
            willShowBars = YES;
            skipUILayout = NO;
            setHasChangedOptions = YES;
            switch (state)
            {
                case MysticSettingNoneFromConfirm:
                {
                    layerToolsHidden = YES;
                    ignoreLayerTools = NO;
                    skipUILayout = YES;
                    [[MysticOptions current] enable:MysticRenderOptionsRevealPlaceholder];
                    if([MysticOptions current].hasMadeChanges && ([MysticOptions current].numberOfChangedOptions > 0 || [MysticOptions current].numberOfUnrenderedOptions > 0))
                    {

                        reloadImage = YES;
                        [[MysticOptions current] setHasChanged:YES changeOptions:NO];
                        [[MysticOptions current] enable:MysticRenderOptionsSource];
                        [[MysticOptions current] enable:MysticRenderOptionsSaveImageOutput];
                        [[MysticOptions current] enable:MysticRenderOptionsForceProcess];
                        [[MysticOptions current] enable:MysticRenderOptionsRebuildBuffer];
                        [[MysticOptions current] enable:MysticRenderOptionsSaveState];
                    }
                    else [weakSelf revealPlaceholderImage:nil];
                    break;
                }
                case MysticSettingNoneFromCancel:
                case MysticSettingNoneFromBack:
                {
                    layerToolsHidden = YES;
                    ignoreLayerTools = NO;
                    skipUILayout = YES;
                    [[MysticOptions current] enable:MysticRenderOptionsRevealPlaceholder];
                    if([MysticOptions current].hasMadeChanges && ([MysticOptions current].numberOfChangedOptions > 0 || [MysticOptions current].numberOfUnrenderedOptions > 0))
                    {
                        reloadImage = YES;
                        [[MysticOptions current] setHasChanged:YES changeOptions:NO];
                        [[MysticOptions current] enable:MysticRenderOptionsPreview];
                        [[MysticOptions current] enable:MysticRenderOptionsSaveImageOutput];
                        [[MysticOptions current] enable:MysticRenderOptionsForceProcess];
                        [[MysticOptions current] enable:MysticRenderOptionsRebuildBuffer];
                        [[MysticOptions current] enable:MysticRenderOptionsSaveState];
                    }
                    else [weakSelf revealPlaceholderImage:nil];
                    break;
                }
                case MysticSettingNoneFromLoadProject:
                {
                    reloadImage = YES;
                    layerToolsHidden = YES;
                    ignoreLayerTools = NO;
                    reloadImageWithHUD = YES;
                    break;
                }
                default: [[MysticOptions current] enable:MysticRenderOptionsPreview]; break;
            }
            if(reloadImage && weakSelf.canvasController)
            {
                if(!weakSelf.canvasController.hasSketched)
                {
                    [weakSelf.canvasController close];
                    [weakSelf.canvasController.view removeFromSuperview];
                    [weakSelf.canvasController removeFromParentViewController];
                    weakSelf.canvasController = nil;
                }
                else
                {
                    reloadImageComplete = ^{
                
                        [weakSelf.canvasController close];
                        [weakSelf.canvasController.view removeFromSuperview];
                        [weakSelf.canvasController removeFromParentViewController];
                        weakSelf.canvasController = nil;
                    };
                }
            }
            else if(weakSelf.canvasController)
            {
                [weakSelf.canvasController close];
                [weakSelf.canvasController.view removeFromSuperview];
                [weakSelf.canvasController removeFromParentViewController];
                weakSelf.canvasController = nil;
            }
            
            [MysticOptions current].originalTag = nil;
            animation = [weakSelf showBottomBarAnimation:animation];
            weakSelf.currentOption = nil;
            animationsComplete = ^(BOOL animFinished, MysticAnimationBlockObject *animObj){
                [Mystic freeMemory];
                if(weakSelf.tabBar) [weakSelf.tabBar resetAll];
                if(weakSelf.addTabBar) [weakSelf.addTabBar resetAll];
                weakSelf.transformOption = nil;
                [MysticTipViewManager hideAll:NO except:@"addlayer"];
                [weakSelf setNeedsDisplay];
                
                if(!reloadImage) [weakSelf showUndoRedo:nil];
                if(weakSelf.navLeftView && weakSelf.navLeftView.hidden) [weakSelf showUIControlsDuration:0.15 completion:nil];
                
#pragma mark - START STATE
#ifdef MYSTIC_START_STATE
                if(startState != MysticSettingUnknown)
                {
                    switch (startState) {
                        case MysticObjectTypeDesign:
                        case MysticObjectTypeText:
                        case MysticObjectTypeTexture:
                        case MysticObjectTypeCamLayer:
                        case MysticObjectTypeBadge:
                        case MysticObjectTypeFrame:
                        case MysticObjectTypeLight:
                        case MysticSettingDesign:
                        case MysticSettingChooseText:
                        case MysticSettingText:
                        case MysticSettingCamLayer:
                        case MysticSettingBadge:
                        case MysticSettingFrame:
                        case MysticSettingLighting:
                        case MysticSettingTexture:
                        {
                            NSArray *packs = [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(startState)|MysticOptionTypeShowFeaturedPack];
                            MysticPack *pack = packs && packs.count ? [packs objectAtIndex:0] : nil;
                            if(!pack) return;
                            [self chosePack:packs createNew:YES];
                            break;
                        }
//                        case MysticObjectTypeSketch:
//                        {
//                            break;
//                        }
                        case MysticObjectTypeDesignSettings:
                        case MysticObjectTypeTextureSettings:
                        case MysticObjectTypeCamLayerSettings:
                        case MysticObjectTypeBadgeSettings:
                        case MysticObjectTypeFrameSettings:
                        case MysticObjectTypeLightSettings:
                        {
                            MysticObjectType otype = MysticOptionTypesToObjectType(MysticObjectTypeToOptionTypes(startState));
                            NSArray *packs = [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(startState)|MysticOptionTypeShowFeaturedPack];
                            MysticPack *pack = packs && packs.count ? [packs objectAtIndex:0] : nil;
                            if(!pack) return;
                            __unsafe_unretained __block MysticPack *__pack = [pack retain];
                            __block BOOL usedEffect = NO;
                            [pack packOptions:^(NSArray *controls, MysticDataState dataState) {
                                
                                
                                if(!usedEffect && dataState & MysticDataStateNew && controls && controls.count)
                                {
                                    PackPotionOption *effect = controls.count ? controls[0] : nil;
                                    
                                    if(!effect) return;
                            
                                    effect.createNewCopy = YES;
                                    [effect setUserChoice];
                                    [weakSelf.currentStateInfo addEntriesFromDictionary:@{@"object": effect, @"createNewObject": @(createNewObject), @"refreshState": @YES }];
                                    weakSelf.transformOption = effect;
                                    usedEffect = YES;
                                                                                      
                                                                                      
                                    weakSelf.activePack = __pack;
                                    effect.activePack = __pack;
                                    animation = [weakSelf showLayerPanelAnimation:nil info:@{
                                                                                             @"backgroundAlpha": @(1),
                                                                                             @"hideToggler": @YES,
                                                                                                   @"state":@(otype),
                                                                                                   @"option": effect ? effect : @NO,
                                                                                                   @"panel": [MysticPanelObject info:@{
                                                                                                                                                     @"reload": @YES,
                                                                                                                                                     @"option": effect ? effect : @NO,
                                                                                                                                                     @"state": @(otype),
                                                                                                                                                     @"optionType": @(otype),
                                                                                                                                                     @"title": MysticObjectTypeTitleParent(otype, MysticObjectTypeUnknown),
                                                                                                                                                     @"animationTransition": @(MysticAnimationTransitionHideBottom),
                                                                                                                                                     @"panel": @(MysticPanelTypeOptionLayerSettings),
                                                                                                                                                     
                                                                                                                                                     
                                                                                                                                                     }],
                                                                                                   
                                                                                                   }];
                                    [animation animate:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                        [weakSelf.overlayView setupGestures:weakSelf.currentSetting];
                                        [weakSelf reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess complete:nil];
                                    }];
                                    [__pack release];
                                }
                            }];
                            break;
                        }
                        case MysticObjectTypeSetting:
                            MysticWait(1, ^{
                                MysticTabButton *btn = [weakSelf.tabBar tabForType:MysticObjectTypeSetting];
                                [weakSelf mysticTabBar:weakSelf.tabBar didSelectItem:btn info:nil];
#ifdef MYSTIC_START_SUB_STATE
                                MysticWait(2, ^{
                                    MysticTabButton *btn = [weakSelf.layerPanelView.visiblePanel.tabBar tabForType:MYSTIC_START_SUB_STATE];
                                    if(btn) [(MysticController *)weakSelf.layerPanelController mysticTabBar:weakSelf.layerPanelView.visiblePanel.tabBar didSelectItem:btn info:nil];
                                });
#endif
                            });
                            startState = MysticSettingUnknown;
                            return;
                        default: [weakSelf setStateConfirmed:startState animated:YES complete:nil]; break;
                    }
                }
                startState = MysticSettingUnknown;
                
#undef MYSTIC_START_STATE
#endif

            };
            break;
        }
            
            
#pragma mark - STATE: Share
            
        case MysticSettingShare:
        {
            if(weakSelf.isSavingLargeImage && !weakSelf.isObservingLargeImage)
            {
                [weakSelf showHUD:@"One sec..." checked:nil];
                [weakSelf addObserver:weakSelf forKeyPath:@"isSavingLargeImage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
                weakSelf.isObservingLargeImage = YES;
            }
            else if(!weakSelf.isSavingLargeImage)
            {
                if(weakSelf.isObservingLargeImage)
                {
                    [weakSelf removeObserver:weakSelf forKeyPath:@"isSavingLargeImage"];
                    weakSelf.isObservingLargeImage = NO;
                }
                if(HUD2) [weakSelf hideHUD];
                
                MysticShareItem *item = [MysticShareItem itemWithImage:[UserPotion potion].sourceImage subject:nil];
                UIActivityViewController *activityViewController = [[[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil] autorelease];
                [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
                {
                    if(!completed && !activityError) return;
                    BOOL hasSaved = [activityType isEqualToString:UIActivityTypeSaveToCameraRoll];
                    [MysticLog answer:@"Share"
                                   info:@{@"type":activityType, @"error":activityError ? activityError.description : @(NO),
                                                      
                                                      @"image":hasSaved ? s(CGSizeImage([(MysticShareItem *)returnedItems.firstObject image])) : @"no image"}];
                    if(hasSaved) [weakSelf showImageMessage:nil title:@"SAVED" message:nil];
                    else if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) [weakSelf showImageMessage:nil title:@"COPIED" message:nil];
                    else if([activityType isEqualToString:UIActivityTypePostToFacebook]) [weakSelf showImageMessage:nil title:@"POSTED" message:nil];
                    else if([activityType isEqualToString:UIActivityTypePostToTwitter]) [weakSelf showImageMessage:nil title:@"TWEETED" message:nil];
                }];
                activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo];
                [weakSelf.navigationController presentViewController:activityViewController animated:YES completion:nil];
            }
            return nil;
        }
#pragma mark - STATE: Add / Manage Layers
        case MysticSettingOptions:
        case MysticSettingLayers:
        {
            [weakSelf.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                 if(finished) [weakSelf setState:MysticSettingShare animated:YES complete:nil];
             }];
            return nil;
        }
            
#pragma mark - STATE: Add Layer Tab Bar
            
        case MysticSettingAddLayer:
        {
            [MysticTipViewManager hide:@"addlayer" animated:NO];
            [weakSelf showAddTabBar:nil finished:^(id object, id packObj) {
                [NSTimer wait:1 block:^{
                    [weakSelf hideAddTabBar];
                }];
            }];
            return nil;
        }
            

#pragma mark - STATE: Shape
        case MysticObjectTypeShape:
        case MysticSettingShape:
        {
            [weakSelf hideUndoRedo:nil];

            bottomToolBarHidden = YES;
            bottomPanelHidden = YES;
            newBottomPanelFrame.origin.y = viewSize.height;
            
            if(!weakSelf.shapesView)
            {
                MysticShapesViewController *controller = [[MysticShapesViewController alloc] initWithFrame:weakSelf.imageView.imageView.bounds delegate:self];
                controller.parentView = self.view;
                weakSelf.shapesController = controller;
                weakSelf.shapesView = (MysticShapesOverlaysView *)controller.view;
                [weakSelf.imageView.imageView insertSubview:weakSelf.shapesView belowSubview:weakSelf.labelsView];
                [weakSelf.shapesController disableOverlays];
                [controller release];
                weakSelf.shapesView.frame = weakSelf.imageView.originalImageViewFrame;
                weakSelf.shapesView.originalFrame = weakSelf.imageView.originalImageViewFrame;
                weakSelf.shapesView.transform = weakSelf.imageView.imageView.transform;
                weakSelf.shapesView.center = weakSelf.imageView.imageView.center;

            }
            
            [weakSelf.shapesView enableOverlays];
            weakSelf.parentSetting = MysticSettingShape;
            weakSelf.shapesView.allowGridViewToHide = YES;
            [weakSelf updateOverlaysView:weakSelf.shapesView refreshLayerPanel:NO];
            
            
            PackPotionOptionShape *option = (PackPotionOptionShape *)[UserPotion optionForType:MysticObjectTypeShape];
            option = option ? option : [PackPotionOptionShape parentOption];
            option.overlaysView = weakSelf.shapesView;
            weakSelf.currentOption = option;
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           
                                                                           @"state":@(MysticSettingShape),
                                                                           @"option":option,
                                                                           @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                                             @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                                                                             @"state": @(state),
                                                                                                                             @"optionType": @(MysticObjectTypeShape),
                                                                                                                             @"title": MysticObjectTypeTitleParent(MysticObjectTypeShape, MysticObjectTypeUnknown),
                                                                                                                             @"panel": @(MysticPanelTypeShape)
                                                                                                                             }],
                                                                           
                                                                           }];
            [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                [weakSelf.overlayView setupGestures:state];
                weakSelf.shapesController.selectedLayer = !weakSelf.shapesView.overlays.count || createNewObject ? [weakSelf.shapesController addNewOverlay] : [weakSelf.shapesController lastOverlay];
                weakSelf.currentOption.hasRendered = NO;
                [weakSelf updateOverlaysView:weakSelf.shapesView refreshLayerPanel:YES];
            }];
            break;
        }
            
#pragma mark - STATE: Type
        case MysticObjectTypeFont:
        case MysticObjectTypeFontStyle:
        case MysticSettingChooseFont:
        case MysticSettingEditType:
        case MysticSettingEditFont:
        case MysticSettingType:
        case MysticSettingTypeNew:
        {
            [weakSelf hideUndoRedo:nil];
            bottomToolBarHidden = YES;
            bottomPanelHidden = YES;
            newBottomPanelFrame.origin.y = viewSize.height;
            
            
            [weakSelf.labelsView enableOverlays];
            
            weakSelf.parentSetting = MysticSettingType;
            weakSelf.labelsView.allowGridViewToHide = YES;
            [weakSelf updateOverlaysView:weakSelf.labelsView refreshLayerPanel:NO];
            
            
            PackPotionOptionFont *option = (PackPotionOptionFont *)[UserPotion optionForType:MysticObjectTypeFont];
            option = option ? option : [PackPotionOptionFont parentOption];
            option.overlaysView = weakSelf.labelsView;
            weakSelf.currentOption = option;
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           
                                                                           @"state":@(MysticSettingType),
                                                                           @"option":option,
                                                                           @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                                             @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                                                                             @"state": @(state),
                                                                                                                             @"optionType": @(MysticObjectTypeFont),
                                                                                                                             @"title": MysticObjectTypeTitleParent(MysticObjectTypeFont, MysticObjectTypeUnknown),
                                                                                                                             @"panel": @(MysticPanelTypeFonts)
                                                                                                                             }],
                                                                           
                                                                           }];
            
            [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                [weakSelf.overlayView setupGestures:state];
                weakSelf.fontStylesController.selectedLayer = !weakSelf.labelsView.overlays.count || createNewObject ? [weakSelf.fontStylesController addNewOverlay] : [weakSelf.fontStylesController lastOverlay];
                weakSelf.currentOption.hasRendered = NO;
                [weakSelf updateOverlaysView:weakSelf.labelsView refreshLayerPanel:YES];
            }];
            break;
        }
            
            
            
            
#pragma mark - STATE: Potions
        case MysticSettingPotions:
        {
            [weakSelf hideUndoRedo:nil];

            __unsafe_unretained __block MysticPanelObject *panelObj = [MysticPanelObject info:@{
                                                                                                               @"state": @(MysticSettingPotions),
                                                                                                               @"optionType": @(MysticObjectTypePotion),
                                                                                                               @"title": MysticObjectTypeTitleParent(MysticObjectTypePotion, MysticObjectTypeUnknown),
                                                                                                               @"panel": @(MysticPanelTypePotions)
                                                                                                               }];
            panelObj.targetOption = nil;
            [panelObj ready:^(MysticPanelObject *panelObj, BOOL s) { }];
            [panelObj confirm:^(id sender, MysticPanelObject *panelObj, BOOL s) {
                [weakSelf confirmedOption:panelObj.targetOption object:sender];
                [MysticController setNeedsDisplay];
            }];
            [panelObj cancel:^(id sender, MysticPanelObject *panelObj, BOOL s) {
                [weakSelf cancelledOption:panelObj.targetOption object:sender];
                [MysticController setNeedsDisplay];
            }];
            
            
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           @"backgroundAlpha": @(0),
                                                                           @"option":@YES,
                                                                           @"hideToggler": @YES,
                                                                           @"enabled":@NO,
                                                                           @"animateContext": @NO,
                                                                           @"panel": panelObj
                                                                           }];
            return [animation addAnimationComplete:^(BOOL f, MysticAnimationBlockObject *animObj) { [weakSelf.overlayView setupGestures:currentSetting]; }];
        }
            
        case MysticSettingAboutProjects:
        {
            
            break;
        }
            
#pragma mark - STATE: Crop Source Image
            
        case MysticSettingCropSourceImage:
        {
            
            break;
        }
            
            
            
            
            
            
            
            
#pragma mark - STATE: Filters
            
        case MysticSettingFilter:
        case MysticSettingChooseColorFilter:
        {
            [weakSelf hideUndoRedo:nil];

            PackPotionOption *option = nil;
            
            createNewObject = YES;
            
            if(!createNewObject)
            {
                if(_currentOption)
                {
                    [[MysticOptions current] focus:_currentOption];
                    _currentOption.isConfirmed = NO;
                }
                
                option = _currentOption ? _currentOption : nil;
                if(!option)
                {
                    PackPotionOption *toption = [[MysticOptions current] transformingOption:state];
                    if(toption.type == theType)
                    {
                        _currentOption = toption;
                        [weakSelf.currentStateInfo setObject:_currentOption forKey:@"object"];
                    }
                }
                if(_currentOption)
                {
                    _currentOption.state  = _currentOption.state | MysticOptionStatePreviewing;
                }
            }
            else
            {
                _currentOption = nil;
            }
            
            weakSelf.preventToolsFromBeingVisible = YES;
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            
            animation=[weakSelf showLayerPanelAnimation:animation info:@{
                                                                         
                                                                         @"option":_currentOption ? _currentOption : @YES,
                                                                         @"hideToggler": @YES,
                                                                         @"enabled":_currentOption ? @YES : @NO,
                                                                         @"create": @(createNewObject),
                                                                         @"animateContext": @NO,
                                                                         @"panel": [MysticPanelObject info:@{
                                                                                                                           
                                                                                                                           @"state": @(state),
                                                                                                                           @"optionType": @(MysticObjectTypeFilter),
                                                                                                                           @"title": MysticObjectTypeTitleParent(MysticObjectTypeFilter, MysticObjectTypeUnknown),
                                                                                                                           @"panel":@(MysticPanelTypeOptionFilter)
                                                                                                                           }]
                                                                         }];
            if(!createNewObject && _currentOption && weakSelf.imageView.renderIsHidden)
            {
                [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                    
                    [weakSelf reloadImage:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                        DLog(@"filters state reloaded image and render view hidden: %@", MBOOL(weakSelf.imageView.renderIsHidden));
                    }];
                }];
            }
            return [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) { [weakSelf.overlayView setupGestures:weakSelf.currentSetting]; }];
        }
            
            
#pragma mark - STATE: Layers
            
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        case MysticObjectTypeTexture:
        case MysticObjectTypeCamLayer:
        case MysticObjectTypeBadge:
        case MysticObjectTypeFrame:
        case MysticObjectTypeLight:
        case MysticSettingDesign:
        case MysticSettingChooseText:
        case MysticSettingText:
        case MysticSettingCamLayer:
        case MysticSettingBadge:
        case MysticSettingFrame:
        case MysticSettingLighting:
        case MysticSettingTexture:
        {
            [weakSelf hideUndoRedo:nil];

            PackPotionOption *option = nil;
            if(!createNewObject)
            {
                if(_currentOption)
                {
                    [[MysticOptions current] focus:_currentOption];
                    _currentOption.isConfirmed = NO;
                }
                option = _currentOption ? _currentOption : nil;
                if(!option)
                {
                    PackPotionOption *toption = [weakSelf currentOption:state];
                    if(toption.type == theType)
                    {
                        _currentOption = toption;
                        weakSelf.currentOption = _currentOption;
                    }
                }
                if(_currentOption) _currentOption.state  = _currentOption.state | MysticOptionStatePreviewing;
                option = _currentOption ? _currentOption : nil;
            }
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            MysticObjectType optionType = MysticTypeForSetting(state, option);
            MysticLayoutStyle layoutStyle = MysticLayoutStyleList;
            MysticObjectSelectionType selectionStyle = MysticObjectSelectionTypePack;
            CGFloat _backgroundAlpha = MYSTIC_UI_PANEL_BG_ALPHA;
            switch (state) {
                case MysticObjectTypeDesign:
                case MysticObjectTypeText:
                case MysticObjectTypeTexture:
                case MysticObjectTypeCamLayer:
                case MysticObjectTypeFrame:
                case MysticObjectTypeLight:
                case MysticSettingDesign:
                case MysticSettingChooseText:
                case MysticSettingText:
                case MysticSettingCamLayer:
                case MysticSettingFrame:
                case MysticSettingLighting:
                case MysticSettingTexture:
                {
                    _backgroundAlpha = 0.0;
                    layoutStyle = MysticLayoutStyleList;
                    break;
                }
                case MysticObjectTypeBadge:
                case MysticSettingBadge:
                {
                    layoutStyle = MysticLayoutStyleGrid;
                    selectionStyle =MysticObjectSelectionTypeOption;
                    break;
                }
                default: break;
            }
            
#pragma mark - STATE: Layers Code
            
            if(option) [weakSelf editOption:option createNew:createNewObject];
            else
            {
                __unsafe_unretained __block MysticBlock __finishedState = finishedState ? Block_copy(finishedState) : nil;
                [weakSelf showPackPickerForType:@[@(optionType)] option:nil layoutStyle:layoutStyle selectionType:selectionStyle picked:^(MysticPack *pack, PackPotionOption* option, BOOL success) {
                    __unsafe_unretained __block PackPotionOption *__option = option ? [option retain] : nil;
                    __unsafe_unretained __block MysticPack *__pack = pack ? [pack retain] : nil;
                    if(__option) [self editOption:__option createNew:YES];
                    else if(__pack) [self chosePack:__pack createNew:YES];
                    if(__pack) { [__pack release]; __pack = nil; }
                    if(__option) { [__option release]; __option=nil; }
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{ runBlock(__finishedState); }];
                }];
            }
            return [animation addAnimationComplete:^(BOOL f, MysticAnimationBlockObject *obj) { [weakSelf.overlayView setupGestures:weakSelf.currentSetting]; }];
        }
#pragma mark - STATE: Sketch
            
        case MysticObjectTypeSketch:
        {
            [weakSelf hideUndoRedo:nil];

//            [MysticOptions current].originalTag = [MysticOptions current].tag;
            [MysticOptions current].originalTag = nil;


            PackPotionOption *option = (id)[[MysticOptions current] option:MysticObjectTypeSketch];
            option = option ? option : [[[[PackPotionOptionSketch alloc] init] autorelease] setUserChoice];
            weakSelf.currentOption = option;
            weakSelf.transformOption = option;

            weakSelf.canvasController = [[[MysticCanvasController alloc] init] autorelease];
            [weakSelf.view addSubview:weakSelf.canvasController.view];
            weakSelf.canvasController.controller = weakSelf;
            weakSelf.canvasController.view.transform = CGAffineTransformMakeTranslation(0, -108.0/2);
            [weakSelf.canvasController setupView];
            [weakSelf addChildViewController:weakSelf.canvasController];
            [weakSelf.canvasController didMoveToParentViewController:weakSelf];
            
            [UserPotionManager setImage:[UserPotion potion].sourceImage tag:@"thesource"];
            
            CGFloat totalHeight1 = weakSelf.imageView.scrollView.frame.size.height + weakSelf.imageView.scrollView.frame.origin.y*2;
            CGFloat totalHeight = weakSelf.view.frame.size.height;
            CGFloat imageViewHeight = weakSelf.imageView.imageViewFrame.size.height;
            CGFloat imageViewHeightScale = imageViewHeight/totalHeight;
            if(weakSelf.imageView.scrollView.frame.size.height != imageViewHeight)
                imageViewHeightScale = 1;
            else weakSelf.canvasController.scaleSizeHeight = imageViewHeight/totalHeight1;
            weakSelf.canvasController.scaleHeight = imageViewHeightScale;

            
            [weakSelf.canvasController createDocument:[UserPotion potion].sourceImage size:[UserPotion potion].sourceImageSize finished:^(id object) {
                [weakSelf.imageView destroyRenderImageView];
                [weakSelf.imageView destroyPlaceholderImageView];
                [weakSelf.canvasController setupView];

            }];
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           
                                                                           @"state":@(MysticObjectTypeSketch),
                                                                           @"option":option ? option : @YES,
                                                                           @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_SKETCH_HEIGHT),
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                               @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_SKETCH_HEIGHT),
                                                                                                               @"state": @(state),
                                                                                                               @"optionType": @(MysticObjectTypeSketch),
                                                                                                               @"title": MysticObjectTypeTitleParent(MysticObjectTypeSketch, MysticObjectTypeUnknown),
                                                                                                               @"panel": @(MysticPanelTypeSketch)
                                                                                                               }],
                                                                           
                                                                           }];
            
            
            [weakSelf.overlayView setupGestures:weakSelf.currentSetting disable:YES];
            return [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                [MysticTipView tip:@"pickbrush" inView:weakSelf.view targetView:[weakSelf.layerPanelView.replacementTabBar tabForType:MysticSettingSketchBrush] hideAfter:5 delay:0.5 animated:YES];

            }];
        }
#pragma mark - STATE: Color Overlays
            
        case MysticObjectTypeColorOverlay:
        case MysticSettingColorOverlay:
        {
            [weakSelf hideUndoRedo:nil];

            PackPotionOption *option = nil;
            if(!createNewObject)
            {
                if(_currentOption)
                {
                    [[MysticOptions current] focus:_currentOption];
                    _currentOption.isConfirmed = NO;
                }
                option = _currentOption ? _currentOption : nil;
                if(!option)
                {
                    PackPotionOption *toption = [weakSelf currentOption:state];
                    if(toption.type == theType)
                    {
                        _currentOption = toption;
                        weakSelf.currentOption = _currentOption;
                    }
                }
                if(_currentOption) _currentOption.state  = _currentOption.state | MysticOptionStatePreviewing;
                option = _currentOption ? _currentOption : nil;
            }
            else
            {
                _currentOption = nil;
            }
            weakSelf.preventToolsFromBeingVisible = YES;
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           
                                                                           @"backgroundAlpha": @(1),
                                                                           @"option":_currentOption ? _currentOption : @YES,
                                                                           @"create": @(createNewObject),
                                                                           @"enabled":_currentOption ? @YES : @NO,
                                                                           @"animateContext": @NO,
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                                             @"state": @(state),
//                                                                                                                             @"animationTransition": @(MysticAnimationTransitionHideBottom),
                                                                                                                             
                                                                                                                             @"optionType": @(MysticObjectTypeColorOverlay),
                                                                                                                             @"title": MysticObjectTypeTitleParent(MysticObjectTypeColorOverlay, MysticObjectTypeUnknown),
                                                                                                                             @"panel": @(MysticPanelTypeOptionLayer)
                                                                                                                             }]
                                                                           }];
            
            return [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) { [weakSelf.overlayView setupGestures:weakSelf.currentSetting]; }];
        }
            
            
            
#pragma mark - STATE: Settings & Layer Settings
            
            
        case MysticSettingSettingsLayer: break;
        case MysticSettingSettings:
        {
            [weakSelf hideUndoRedo:nil];
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            BOOL editingLayer = NO;
            BOOL createdNewSettingObj = NO;
            _currentOption = _currentOption ? _currentOption : (PackPotionOptionSetting *)[weakSelf currentOption:state == MysticSettingSettings ?  MysticObjectTypeSetting : MysticObjectTypeAll];
            if(_currentOption && _currentOption.type != MysticObjectTypeSetting)
            {
                weakSelf.currentOption = nil;
                _currentOption = nil;
            }
            
            if((!_currentOption && state == MysticSettingSettings) || (_currentOption && _currentOption.hasRendered))
            {
                createdNewSettingObj = YES;
                _currentOption = [MysticOptions makeOption:MysticObjectTypeSourceSetting userInfo:nil];
                weakSelf.currentOption = _currentOption;
            }
            if(!createdNewSettingObj) weakSelf.preventToolsFromBeingVisible = NO;
            weakSelf.transformOption = _currentOption;
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           @"backgroundAlpha": @(0),
                                                                           @"blurBackground": @(NO),
                                                                           @"option":_currentOption ? _currentOption : @YES,
                                                                           @"hideToggler": @YES,
                                                                           @"enabled":@YES,
                                                                           @"animateContext":@NO,
                                                                           @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                                             @"state": @(state),
                                                                                                                             @"bottomBarHeight": @(MYSTIC_UI_TOOLBAR_HIDE_HEIGHT),
                                                                                                                             @"animationTransition": @(MysticAnimationTransitionHideBottom),
                                                                                                                             @"optionType": @(MysticObjectTypeSetting),
                                                                                                                             @"title": MysticObjectTypeTitleParent(MysticObjectTypeSetting, MysticObjectTypeUnknown),
                                                                                                                             @"panel": @(MysticPanelTypeOptionSettings)
                                                                                                                             }],
                                                                           
                                                                           }];
            
            if(_currentOption.hasRendered) _currentOption.hasRendered = NO;
            skipUILayout = YES;
            __unsafe_unretained __block PackPotionOption *_settingOptions = _currentOption;
            return [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj)
             {
                 [weakSelf reloadImage:NO settings:MysticRenderOptionsForceProcess|MysticRenderOptionsSetupRender complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                     weakSelf.preventToolsFromBeingVisible = YES;
                 }];
                 _settingOptions.hasChanged = NO;
             }];
        }
            
            
#pragma mark - STATE: Preferences
            
        case MysticSettingFeedback:
        case MysticSettingPreferences:
        {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate openSettingsAnimated:YES complete:finishedState];
            return animation;
        }
        case MysticObjectTypeSpecial:
        {
            PackPotionOption *option = nil;
            if(!createNewObject)
            {
                if(_currentOption)
                {
                    [[MysticOptions current] focus:_currentOption];
                    _currentOption.isConfirmed = NO;
                }
                option = _currentOption ? _currentOption : nil;
                if(!option)
                {
                    PackPotionOption *toption = [weakSelf currentOption:state];
                    if(toption.type == theType)
                    {
                        _currentOption = toption;
                        weakSelf.currentOption = _currentOption;
                    }
                }
                if(_currentOption) _currentOption.state  = _currentOption.state | MysticOptionStatePreviewing;
                option = _currentOption ? _currentOption : nil;
            }
            weakSelf.preventToolsFromBeingVisible = YES;
            [MysticOptions current].originalTag = [MysticOptions current].tag;
            animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                           
                                                                           @"backgroundAlpha": @(1),
                                                                           @"option":_currentOption ? _currentOption : @YES,
                                                                           @"hideToggler": @YES,
                                                                           @"enabled":_currentOption ? @YES : @NO,
                                                                           @"animateContext": @NO,
                                                                           @"panel": [MysticPanelObject info:@{
                                                                                                                             @"state": @(state),
                                                                                                                             @"optionType": @(MysticObjectTypeSpecial),
                                                                                                                             @"title": MysticObjectTypeTitleParent(MysticObjectTypeSpecial, MysticObjectTypeUnknown),
                                                                                                                             @"panel": @(MysticPanelTypeOptionSpecial)
                                                                                                                             }]
                                                                           }];
            
            return [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) { [weakSelf.overlayView setupGestures:weakSelf.currentSetting]; }];
        }

        default:
        {
            moveBottomNippleTo = nil;
            return animation;
        }
            
    }
    
    
#pragma mark - State Setup
    
    
    if(!weakSelf.navigationItem.rightBarButtonItem && weakSelf.navigationItem.leftBarButtonItem)
    {
        UIView *emptyView = [[UIView alloc] initWithFrame:weakSelf.navigationItem.leftBarButtonItem.customView.frame];
        [weakSelf setRightButton:[[[UIBarButtonItem alloc] initWithCustomView:emptyView] autorelease] animate:YES];
        [emptyView release];
    }
    
    if(!weakSelf.navigationItem.leftBarButtonItem && weakSelf.navigationItem.rightBarButtonItem)
    {
        UIView *emptyView = [[UIView alloc] initWithFrame:weakSelf.navigationItem.rightBarButtonItem.customView.frame];
        DLog(@"setting left button");
        [weakSelf setLeftButton:[[[UIBarButtonItem alloc] initWithCustomView:emptyView] autorelease] animate:YES];
        [emptyView release];
    }
    weakSelf.tabBar.hidden = bottomToolBarButtonsHidden;
    if(!bottomToolBarHidden && weakSelf.bottomToolbar.hidden) weakSelf.bottomToolbar.hidden = bottomToolBarHidden;
    if(!(weakSelf.bottomPanelView.hidden) && !bottomPanelHidden)
    {
        newBottomPanelFrame.origin.y = newFrameImageView.origin.y + newFrameImageView.size.height;
        newBottomPanelFrame.size.height = viewSize.height - newBottomPanelFrame.origin.y;
        newBottomPanelFrame.size.height = weakSelf.bottomToolbar.frame.size.height;
        newBottomPanelFrame.origin.y = viewSize.height - newBottomPanelFrame.size.height;
    }
    
    newFrameBottomToolBar.origin.y = newBottomPanelFrame.size.height - newFrameBottomToolBar.size.height;
    newFrameImageView = weakSelf.view.frame;
    
    BOOL navBarWillBeHidden = (weakSelf.navigationController.navigationBarHidden && !willShowBars) || hideNavBar;
    BOOL bottomBarWillBeHidden = (weakSelf.bottomPanelView.hidden && !willShowBars) || hideNavBar;
    
    CGFloat navH = navBarWillBeHidden ? 0 : weakSelf.navigationController.navigationBar.frame.size.height;
    
    CGFloat navBarOffset = !navBarWillBeHidden ? MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET;
    CGFloat bottomBarOffset = !bottomBarWillBeHidden ? MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET : MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET;
    
    insets.top = navH + navBarOffset;
    insets.bottom = (bottomBarWillBeHidden ? 0 : newBottomPanelFrame.size.height)+bottomBarOffset;
    
    
    if(!bottomToolBarHidden && !weakSelf.tabBar) [weakSelf tabBar:nil];
    
#pragma mark - STATE Animations
    
    animation.duration = animationDuration;
    animation.delay = animationDelay;
    
    __unsafe_unretained __block MysticBlock __finishedState = finishedState ? Block_copy(finishedState) : nil;
    
    MysticBlockAnimation __animations = ^{
        if(layerToolsHidden && !ignoreLayerTools && weakSelf.moreToolsView) [weakSelf toggleMoreTools:layerToolsHidden];
        weakSelf.bottomPanelView.frame = newBottomPanelFrame;
        weakSelf.bottomToolbar.frame = newFrameBottomToolBar;
    };
    MysticBlock __reloadImageComplete = reloadImageComplete ? Block_copy(reloadImageComplete) : nil;
    MysticBlockAnimationComplete __animationsCompleteReloadImage = ^(BOOL animFinished, MysticAnimationBlockObject *animObj){
        
        weakSelf.bottomToolbar.hidden = bottomToolBarHidden;
        [weakSelf.overlayView updateFrame];
//        weakSelf.overlayView.transform = weakSelf.imageView.imageView.transform;
        if(reloadImage)
        {
            [weakSelf reloadImage:reloadImageWithHUD complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                if(!layerToolsHidden && !ignoreLayerTools) [weakSelf toggleMoreTools:layerToolsHidden afterDelay:1.5];
                if(__reloadImageComplete) { __reloadImageComplete(); Block_release(__reloadImageComplete); }
                if(setHasChangedOptions) [[MysticOptions current] setHasChanged:NO changeOptions:YES];
                if(__finishedState) { __finishedState(); Block_release(__finishedState); }
            }];
        }
        else
        {
            if(!layerToolsHidden && !ignoreLayerTools) [weakSelf toggleMoreTools:layerToolsHidden afterDelay:1.5];
            if(__reloadImageComplete) { __reloadImageComplete(); Block_release(__reloadImageComplete); }
            if(setHasChangedOptions) [[MysticOptions current] setHasChanged:NO changeOptions:YES];
            if(__finishedState) { __finishedState(); Block_release(__finishedState); }
        }
        [weakSelf.overlayView setupGestures:weakSelf.currentSetting];
        [weakSelf closedState:closedState];
    };
    
    MysticBlockAnimationComplete __animationsComplete = !weakSelf.preReloadImageBlock ? __animationsCompleteReloadImage : nil;
    if(!__animationsComplete)
    {
        __unsafe_unretained __block MysticBlockAnimationComplete ___reloadBlock = Block_copy(__animationsCompleteReloadImage);
        __animationsComplete = ^(BOOL animFinished, MysticAnimationBlockObject *animObj){
            weakSelf.preReloadImageBlock(___reloadBlock, animFinished, animObj); Block_release(___reloadBlock);
            weakSelf.preReloadImageBlock = nil;
        };
    }
    [animation addAnimation:skipUILayout ? nil  : __animations complete:__animationsComplete];
    [animation addAnimation:animations complete:animationsComplete];
    animation.animated = [MysticUser user].useAnimations && animation.animated && !skipUILayout ? YES : animation.animated;
    return animation;
    
}



- (void) removeOption:(PackPotionOption *)option;
{
    [self removeOption:option updateUI:YES];
}
- (void) removeOption:(PackPotionOption *)option updateUI:(BOOL)shouldUpdateUI;
{
    [option removeOption];
    [UserPotion removeOption:option];
    [self.layerPanelController removeLastSelectedIndexesForOption:option];
    if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
    {
        if(shouldUpdateUI) [self.layerPanelView.visiblePanel.scrollView deselectAll];
        if(self.layerPanelView.visiblePanel.isASubSection)
        {
            [self.layerPanelView.visiblePanel canceledOption];
        }
    }
    
    self.currentOption = nil;
    self.transformOption = nil;
    [[MysticOptions current] saveProject];
    
    
}








#pragma mark - Layers Nav Delegate


- (void) navBarGridTouched:(MysticButton *)sender;
{
    BOOL isGridBtnSelected = !sender.selected;
    sender.selected = !sender.selected;
    MysticResizeableLayersViewController *controller = self.shapesController ? self.shapesController : self.fontStylesController;

    if(isGridBtnSelected)
    {
        controller.allowGridViewToHide = NO;
        controller.allowGridViewToShow = YES;
        [controller showGrid:nil animated:YES force:YES];
    }
    else
    {
        controller.allowGridViewToHide = YES;
        controller.allowGridViewToShow = YES;
        [controller hideGrid:nil animated:YES force:YES];
    }
}
- (void) navBarSelectTouched:(MysticButton *)sender;
{
    sender.selected = !sender.selected;
    if(sender.selected) [self.labelsView selectAll];
    else
    {
        [self.labelsView deselectLayersExcept:nil];
        if(self.moreToolsView) [self hideMoreTools];
    }
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }
}





#pragma mark - Layers View Delegate


- (void)layerViewDidMove:(MysticLayerView *)layerView;
{
    MysticViewType layersType = layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            break;
        }
        default: break;
    }
    
    if(layerView && !controller.gridView)
    {
        [controller showGrid:nil animated:NO force:YES];
        [controller moveLayersToBackgroundExcept:overlaysView.selectedLayers];
        
    }
    
    if(self.moreToolsView) self.moreToolsView.hidden = YES;
}

- (void)layerViewDidEndMoving:(MysticLayerView *)layerView;
{
    MysticViewType layersType = layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            break;
        }
        default: break;
    }
    
    if(!controller.isGridHidden && !self.moreToolsView) {
        [controller hideGrid:nil animated:YES force:YES];
        [controller moveLayersOutOfBackground];
    }
    if(self.moreToolsView)
    {
        self.moreToolsView.alpha = 0;
        self.moreToolsView.hidden = NO;
        [self.moreToolsView fadeInFastAfterDelay:0.15];
    }
    
    if(self.layerPanelView.replacementTabBar) [self.layerPanelView.replacementTabBar setNeedsDisplay];
}



- (void)layerViewDidSelect:(id <MysticLayerViewAbstract>)layerView;
{
    if(self.extraView)
    {
        [self.extraView removeFromSuperview];
        self.extraView = nil;
    }
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar resetAll];
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }
}

- (void)layerViewDidActivate:(id <MysticLayerViewAbstract>)layerView;
{
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar resetAll];
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }
}
- (void)layerViewDidDeactivate:(MysticResizeableLayer *)layerView;
{
    MysticViewType layersType = layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            if(!self.shapesView.selectedCount)
            {
                if(self.moreToolsView) [self hideMoreTools];
                if(!self.shapesController.isGridHidden) [self.shapesController hideGrid:nil animated:YES force:YES];
            }
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            if(!self.labelsView.selectedCount)
            {
                if(self.moreToolsView) [self hideMoreTools];
                if(!self.fontStylesController.isGridHidden) [self.fontStylesController hideGrid:nil animated:YES force:YES];
            }
            break;
        }
        default: break;
    }
    if(self.extraView)
    {
        [self.extraView removeFromSuperview];
        self.extraView = nil;
    }
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar resetAll];
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
    }
    
    
    
}
- (void) layerViewDidClose:(id <MysticLayerViewAbstract>)layerView;
{
    PackPotionOption *_currentOption = self.currentOption;
    if(!_currentOption || (layerView.option && [layerView.option isEqual:_currentOption]))
    {
        self.currentOption = nil;
        if(self.layerPanelView)
        {
            [self updateLayerPanel:self.layerPanelView];
            self.layerPanelView.targetOption = nil;
        }
    }
    else if(_currentOption && !layerView.option)
    {
        self.currentOption = nil;
        if(self.layerPanelView)
        {
            [self updateLayerPanel:self.layerPanelView];
            self.layerPanelView.targetOption = nil;
        }
    }
}
- (void)layersViewDidDoubleTap:(MysticOverlaysView *)layersView;
{
    [self.imageView.scrollView doubleTapped:nil];
}
- (void)layersViewDidTap:(MysticOverlaysView *)layersView;
{
    MysticViewType layersType = layersView ? layersView.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            break;
        }
        default: break;
    }
    if(self.moreToolsView)
    {
        [controller moveLayersOutOfBackground];
        controller.allowGridViewToHide = YES;
        [controller hideGrid:nil];
        [self hideMoreTools];
    }
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }
    
    
    
}
- (void)layersViewDidAddLayer:(id <MysticLayerViewAbstract>)layerView;
{
    
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }
    
}
- (void)layersViewDidChangeGrid:(id)layersView isHidden:(BOOL)hidden;
{
    
    
}
- (void)layersViewDidConfirm:(MysticOverlaysView *)layersView;
{
    if(self.moreToolsView) [self hideMoreTools];
}

- (void)layerViewDidRemove:(id <MysticLayerViewAbstract>)layerView;
{
    MysticViewType layersType = layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            break;
        }
        default: break;
    }
    if(self.extraView)
    {
        [self.extraView removeFromSuperview];
        self.extraView = nil;
    }
    if(!overlaysView.selectedCount)
    {
        if(self.moreToolsView) [self hideMoreTools];
        if(!controller.isGridHidden) [controller hideGrid:nil animated:YES force:YES];
    }
    if(self.layerPanelView.replacementTabBar)
    {
        [self.layerPanelView.replacementTabBar resetAll];
        [self.layerPanelView.replacementTabBar setNeedsDisplay];
        [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
    }
}
- (void) layerViewDidLongPress:(MysticLayerView *)layerView gesture:(UILongPressGestureRecognizer *)gesture;
{
    if(!self.layerPanelView.replacementTabBar) return;
    [self.layerPanelView.replacementTabBar setNeedsDisplay];
    [self.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
}

- (void) layerViewDidDoubleTap:(id<MysticLayerViewAbstract>)layerView;
{
    MysticObjectType editSetting = MysticSettingUnknown;
    MysticViewType layersType = layerView && layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            editSetting = MysticSettingShapeEdit;
            break;
        }
        case MysticViewTypeLayersFonts:
        {
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            editSetting = MysticSettingFontEdit;
            break;
        }
        default: break;
    }
    [self editLayerView:(id)layerView setting:editSetting];
}

#pragma mark - Edit Quote or Resizeable Layer

- (void) editLayerView:(MysticLayerBaseView *)layerView setting:(MysticObjectType)setting;
{
    __unsafe_unretained __block MysticController *ws = self;
    MysticViewType layersType = layerView && layerView.superview ? layerView.superview.tag : MysticViewTypeLayers;
    MysticOverlaysView *overlaysView = nil;
    MysticResizeableLayersViewController *controller = nil;
    MysticLayerEditViewController *layerController = nil;
    switch (layersType) {
        case MysticViewTypeLayersShapes:
            overlaysView = (id)self.shapesView;
            controller = self.shapesController;
            break;
        case MysticViewTypeLayersFonts:
            overlaysView = (id)self.labelsView;
            controller = self.fontStylesController;
            break;
        default: break;
    }
    controller.keyObjectLayer = layerView;
    CGRect inputFrame = CGRectSize((CGSize){[MysticUI screen].width, 253});
    CGFloat t = (self.imageFrame.size.height - (MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT))/2 - MYSTIC_UI_PANEL_BORDER*2;
    UIEdgeInsets ins = UIEdgeInsetsZero;
    ins.top = self.isNavViewVisible ? MAX(MYSTIC_UI_IMAGEVIEW_INSET_NAV_VIEWS_OFFSET, -t) : -t;
    MysticBlock animIn = nil;
    MysticBlock present = ^{};
    switch (layersType) {
        case MysticViewTypeLayersShapes:
        {
            layerController = [[MysticLayerEditViewController alloc] initWithContent:layerView.content];
            layerController.delegate = self;
            layerController.option = (id)[layerView option];
            layerController.layerView = (id)layerView;
            layerController.color = layerView.choice.color;
            layerController.position = layerView.position;
            layerController.inputFrameInsets = ins;
            layerController.setting = setting;
            layerController.colorAlpha = layerView.contentView.alpha;
            self.layerEditController = [layerController autorelease];
            layerController = self.layerEditController;
            __unsafe_unretained __block MysticLayerBaseView *_layerView = layerView;
            present = ^{ [_layerView animateBorderOut:^(BOOL f) { [ws.layerEditController presentInView:ws.view fromView:(id)_layerView]; }]; };
            break;
        }
        case MysticViewTypeLayersFonts:
        {
 
            MysticLayerTypeView *fontView = (id)layerView;
            MysticQuoteViewController *quoteController = [[MysticQuoteViewController alloc] initWithQuote:nil];
            quoteController.delegate = self;
            quoteController.fontOption = (id)[layerView option];
            quoteController.fontView = (id)layerView;
            quoteController.color = fontView.choice.attributedString.color;
            quoteController.spacing = fontView.choice.attributedString.kerning;
            quoteController.lineHeight = fontView.lineHeightScale;
            quoteController.textAlignment =fontView.choice.attributedString.textAlignment;
            quoteController.content = layerView.choice;
            quoteController.setting = setting;
            quoteController.font = fontView.choice.attributedString.font;
            fontView.attributedText=fontView.choice.attributedString;
            self.quoteController = [quoteController autorelease];
            layerController = self.quoteController;
            present = ^{ [ws.quoteController.fontView animateBorderOut:^(BOOL f) { [ws.quoteController presentInView:ws.view fromView:(id)ws.quoteController.fontView]; }]; };
            
            break;
        }
        default: break;
    }
    
    [self hideNavViews:nil];
    if(self.moreToolsView)
    {
        [controller moveLayersOutOfBackground];
        controller.allowGridViewToHide = YES;
        [controller hideGrid:nil];
        [self hideMoreTools];
    }
    
    [self.overlayView disableGestures];
    [controller disableGestures];
    CGPoint c2 = [self.view convertPoint:self.imageView.imageView.center fromView:self.imageView.imageView.superview];
    CGPoint diff = CGPointDiff(CGPointCenter(layerController.previewFrame), c2);
    layerController.animationIn = animIn ? animIn : ^{
        [ws.imageView.scrollView resetPosition:NO];
        [ws.imageView offsetImageView:diff];
    };
    present();
}




#pragma mark - Layer Edit Controller Delegate

- (void) layerEditViewControllerDidClose:(MysticLayerEditViewController *)controller;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    MysticLayerBaseView *layerView = controller.layerView;
    layerView.contentView.alpha = 0.5;
    layerView.hidden = NO;
    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
    [weakSelf.layerEditController unloadViews];
    weakSelf.layerEditController = nil;
    [weakSelf.shapesController enableGestures];
    [weakSelf.overlayView enableGestures];
    mdispatch(^{
        [MysticUIView animateWithDuration:0.26 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [weakSelf.imageView removeOffset];
        }];
        [weakSelf showNavViews:nil];
    });
}

- (void) layerEditViewController:(MysticLayerEditViewController *)controller didChooseContent:(id)content;
{
    __unsafe_unretained __block MysticController *ws = self;
    __unsafe_unretained __block MysticLayerBaseView *layerView = controller.layerView;
    if(layerView)
    {
        layerView.drawContext.adjustContentSizeToFit = NO;
        layerView.position = controller.position;
        layerView.color = controller.color;
        layerView.drawView.renderRect = CGRectZero;
        [layerView replaceContent:content adjust:NO scale:controller.contentSizeChangeScale];
    }
    mdispatch(^{
        layerView.contentView.alpha = controller.colorAlpha;
        [controller dismissToView:layerView animations:^NSDictionary *{
            return @{Mk_FRAME:[NSValue rect:[ws.imageView removeOffset]]};
        } complete:^(BOOL f) {
            ws.layerEditController = nil;
            [ws.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
            [layerView setKeyObject];
            layerView.selected = YES;
            layerView.hidden = NO;
            [layerView animateBorderIn:nil];
            [ws.overlayView enableGestures];
            [ws.shapesController enableGestures];
        }];
    });
}
- (void) layerEditViewControllerDidCancel:(MysticLayerEditViewController *)controller;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    [weakSelf.layerEditController dismissToView:controller.layerView animations:nil complete:^(BOOL active) {
        weakSelf.layerEditController = nil;
        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }];
    mdispatch(^{
        [MysticUIView animateWithDuration:0.26 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [weakSelf.imageView removeOffset];
        }];
        [weakSelf showNavViews:nil];
        [weakSelf.overlayView enableGestures];
        [weakSelf.shapesController enableGestures];
    });
    
}








#pragma mark - Quote Controller Delegate

- (void) quoteViewControllerDidClose:(MysticQuoteViewController *)controller;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    controller.fontView.hidden = NO;
    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
    [weakSelf.quoteController unloadViews];
    weakSelf.quoteController = nil;
    [weakSelf.fontStylesController enableGestures];
    [weakSelf.overlayView enableGestures];
    mdispatch(^{
        [MysticUIView animateWithDuration:0.26 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [weakSelf.imageView removeOffset];
        }];
        [weakSelf showNavViews:nil];
    });
}

- (void) quoteViewController:(MysticQuoteViewController *)controller didChooseQuote:(id)content;
{
    __unsafe_unretained __block MysticController *ws = self;
    if(((MysticChoice *)content).attributedString.string.lengthVisible < 1)
    {
        [ws.quoteController dismissToView:ws.quoteController.fontView animations:^NSDictionary *{
            ws.quoteController.fontView.alpha = 0;
            return @{Mk_FRAME:[NSValue rect:[ws.imageView removeOffset]]};
        } complete:^(BOOL f) {
            [ws.labelsView removeLayer:ws.quoteController.fontView];
            [ws.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
            [ws.overlayView enableGestures];
            [ws.fontStylesController enableGestures];
            ws.quoteController = nil;
        }];
        return;
    }
    controller.fontView.drawContext.adjustContentSizeToFit = NO;
    controller.fontView.font = [(MysticChoice *)content attributedString].font;
    controller.fontView.lineHeightScale = [(MysticChoice *)content attributedString].lineHeightMultiple;
    controller.fontView.textSpacing = [(MysticChoice *)content attributedString].kerning;
    controller.fontView.textAlignment = [(MysticChoice *)content attributedString].textAlignment;
    controller.fontView.color = [(MysticChoice *)content attributedString].color;
    controller.fontView.choice = (id)content;
    [controller.fontView replaceContent:(MysticChoice *)content adjust:NO scale:controller.contentSizeChangeScale];
    controller.fontView.contentView.alpha = controller.colorAlpha;
    [ws.quoteController dismissToView:ws.quoteController.fontView animations:^NSDictionary *{
        return @{Mk_FRAME:[NSValue rect:[ws.imageView removeOffset]]};
    } complete:^(BOOL f) {
        [ws.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        [ws.quoteController.fontView setKeyObject];
        ws.quoteController.fontView.selected = YES;
        ws.quoteController.fontView.hidden = NO;
        ws.quoteController.fontView.alpha = 1;
        [ws.quoteController.fontView animateBorderIn:nil];
        [ws.overlayView enableGestures];
        [ws.fontStylesController enableGestures];
        ws.quoteController = nil;
    }];
}
- (void) quoteViewControllerDidCancel:(MysticQuoteViewController *)controller;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    [weakSelf.quoteController dismissToView:controller.fontView animations:nil complete:^(BOOL active) {
        weakSelf.quoteController = nil;
        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
        
    }];
    mdispatch(^{
        [MysticUIView animateWithDuration:0.26 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [weakSelf.imageView removeOffset];
        }];
        [weakSelf showNavViews:nil];
        [weakSelf.overlayView enableGestures];
        [weakSelf.shapesController enableGestures];
    });
    
}


#pragma mark - Load Pack:
- (void) refreshPack;
{
    [self refreshPack:NO];
}
- (void) refreshPack:(BOOL)reloadControls;
{
    [self loadPack:self.activePack info:self.currentStateInfo controls:reloadControls ? self.activePack.packOptions : nil scrollView:nil complete:nil];
}
- (void) loadPack:(MysticPack *)pack info:(NSDictionary *)userInfo scrollView:(MysticScrollView *)scrollView complete:(MysticBlock)completed;
{
    [self loadPack:pack info:userInfo controls:pack.packOptions scrollView:scrollView complete:completed];
}
- (void) loadPack:(MysticPack *)pack info:(NSDictionary *)userInfo controls:(NSArray *)controls scrollView:(MysticScrollView *)scrollView complete:(MysticBlock)completed;
{
    __unsafe_unretained __block  MysticController *weakSelf = self;
    
    scrollView = scrollView ? scrollView : nil;
    
    if(![weakSelf activatePack:pack]) return;
    
    if(scrollView && controls)
    {
        scrollView.enableControls = YES;
        if(controls)
        {
            [scrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:completed];
        }
    }
    else
    {
        if(completed) completed();
        
    }
}
- (MysticPack *) currentOptionPack:(PackPotionOption *)targetOption;
{
    MysticObjectType optionType = MysticTypeForSetting(self.currentSetting, targetOption);
    
    MysticPack *pack = self.activePack;
    if(!pack) pack = [self.activePacks objectForKey:[NSNumber numberWithInteger:optionType]];
    if(!pack)
    {
        if(!targetOption)
        {
            if(!pack)
            {
                NSArray *packs = [Mystic topicsForType:optionType];
                pack = packs && packs.count ? [packs objectAtIndex:0] : nil;
            }
        }
        else
        {
            if(targetOption.activePack && !self.createNewObject) pack = targetOption.activePack;
            if(!pack)
            {
                pack = [MysticPack packForOption:targetOption];
                if(!pack)
                {
                    PackPotionOption *option = [[MysticOptions current] transformingOption:optionType];
                    if(option) pack = [MysticPack packForOption:option];
                }
            }
            
        }
    }
    
    
    
    return pack;
}
- (BOOL) activatePack:(MysticPack *)pack;
{
    
    
    __unsafe_unretained __block  MysticController *weakSelf = self;
    MysticObjectType optionType = MysticTypeForSetting(self.currentSetting, weakSelf.currentOption);
    //    NSString *action = nil;
    //    NSString *activePackStr = weakSelf.activePack ? weakSelf.activePack.name : @"---";
    if(!pack)
    {
        if(weakSelf.activePack)
        {
            MysticPack *_pack = weakSelf.activePack;
            PackPotionOption *opt = [UserPotion confirmedOptionForType:_pack.groupType];
            
            if(_pack.groupType == optionType && (!opt || [opt belongsToPack:_pack]))
            {
                //                action = [@"addedToCache: " stringByAppendingString:_pack.name];
                [weakSelf.activePacks setObject:_pack forKey:[NSNumber numberWithInteger:_pack.groupType]];
                
            }
            else
            {
                //                action = [@"removedFromCache: " stringByAppendingString:_pack.name];
                [weakSelf.activePacks removeObjectForKey:[NSNumber numberWithInteger:_pack.groupType]];
            }
            
            
        }
        lastLoadedPackId = NSNotFound;
        lastLoadedPackType = MysticObjectTypeUnknown;
        weakSelf.activePack = nil;
    }
    else
    {
        lastLoadedPackType = pack.groupType;
        lastLoadedPackId = pack.packId;
        weakSelf.activePack = pack;
        if(!weakSelf.activePacks) weakSelf.activePacks = [NSMutableDictionary dictionary];
        PackPotionOption *opt = [UserPotion confirmedOptionForType:pack.groupType];
        
        if(!opt || [opt belongsToPack:pack])
        {
            [weakSelf.activePacks setObject:pack forKey:[NSNumber numberWithInteger:pack.groupType]];
        }
    }
    
    return pack ? YES : NO;
}

- (void) toolBarCanceledOption:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];
    __unsafe_unretained __block MysticController *weakSelf = self;
    id __currentOption = [self currentOption:self.currentSetting];
    __currentOption = !__currentOption ? self.currentOption : __currentOption;
    [self cancelledOption:__currentOption object:sender];
}
- (void) cancelledOption:(PackPotionOption *)__currentOption object:(id)sender;
{
    [self stopMoreToolsTimer];
    
    __unsafe_unretained __block MysticController *weakSelf = self;
    
    BOOL shouldConfirm = NO;
    NSString *confirmTitle = nil;
    NSString *confirmMsg = nil;
    NSString *confirmBtnTitle = nil;
    NSString *cancelBtnTitle = nil;
    MysticBlockObject cancelBlock = nil;
    MysticBlockObject confirmBlock = nil;
    if(__currentOption)
    {
        MysticObjectType oType = [(PackPotionOption *)__currentOption type];
        switch (oType)
        {
            case MysticObjectTypeSpecial:
            {
                __unsafe_unretained __block PackPotionOption *__confirmedOption = [__currentOption retain];
                shouldConfirm = YES;
                confirmTitle = @"Remove?";
                confirmMsg = @"Are you sure you want to remove this effect?";
                cancelBlock = ^(id sender){
//                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:nil];
                    [__confirmedOption autorelease];
                };
                confirmBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:[__confirmedOption autorelease]];
                };
                break;
            }
            case MysticObjectTypeSetting:
            {
                __unsafe_unretained __block PackPotionOption *__confirmedOption = [__currentOption retain];
                shouldConfirm = YES;
                confirmTitle = @"Remove adjustments?";
                confirmMsg = @"Are you sure you want to remove your adjustments?";
                cancelBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:nil];
                    [__confirmedOption autorelease];
                };
                confirmBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:[__confirmedOption autorelease]];
                };
                break;
            }
            case MysticObjectTypeBadge:
            case MysticObjectTypeFilter:
            case MysticObjectTypeText:
            case MysticObjectTypeTexture:
            case MysticObjectTypeLight:
            case MysticObjectTypeFrame:
            case MysticObjectTypeCustom:
            case MysticObjectTypePotion:
            case MysticObjectTypeMulti:
            case MysticObjectTypeColorOverlay:
            {
                __unsafe_unretained __block PackPotionOption *__confirmedOption = [__currentOption retain];
                shouldConfirm = YES;
                NSString *typeTitle = [MysticObjectTypeTitleParent(oType, MysticObjectTypeUnknown) capitalizedString];
                confirmTitle = [NSString stringWithFormat:@"Remove %@?", typeTitle];
                confirmMsg = [NSString stringWithFormat:@"Are you sure you want to remove this %@?",typeTitle];
                cancelBlock = ^(id sender){
//                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:nil];
                    [__confirmedOption autorelease];
                };
                confirmBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:[__confirmedOption autorelease]];
                };
                break;
                
            }
            case MysticObjectTypeShape:
            case MysticSettingShape:
            {
                __unsafe_unretained __block PackPotionOption *__confirmedOption = [__currentOption retain];
                shouldConfirm = YES;
                confirmTitle = @"Remove shapes?";
                confirmMsg = @"Are you sure you want to remove this?";
                cancelBlock = ^(id sender){
//                    PackPotionOptionView *__currentOptionView = nil;
//                    __currentOptionView= [weakSelf.shapesView confirmOverlays:(id)__confirmedOption complete:nil];
//                    __currentOptionView = !__currentOptionView ? (id)__confirmedOption : nil;
//                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:__currentOptionView];
                    [__currentOption autorelease];
                };
                confirmBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:[__confirmedOption autorelease]];
                };
            }
            case MysticObjectTypeFont:
            case MysticSettingType:
            {
                __unsafe_unretained __block PackPotionOption *__confirmedOption = [__currentOption retain];
                shouldConfirm = YES;
                confirmTitle = @"Remove text?";
                confirmMsg = @"Are you sure you want to remove this?";
                cancelBlock = ^(id sender){
//                    PackPotionOptionView *__currentOptionView = nil;
//                    __currentOptionView = [weakSelf.labelsView confirmOverlays:(id)__confirmedOption complete:nil];
//                    __currentOptionView = !__currentOptionView ? (id)__confirmedOption : nil;
//                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:__currentOptionView];
                    [__currentOption autorelease];
                };
                confirmBlock = ^(id sender){
                    [weakSelf toolBarCanceledOptionAndConfirmed:sender option:[__confirmedOption autorelease]];
                };
                break;
                
            }
            default: break;
        }
    }
    
    
    if(shouldConfirm)
    {
//        [MysticAlert ask:confirmTitle message:confirmMsg yes:^(id object, id o2) {
//            if(confirmBlock) confirmBlock();
//        } no:^(id object, id o2) {
//            if(cancelBlock) cancelBlock();
//        } options:nil];
        
        
        AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:confirmTitle];
        [actionSheet setupAppearance:MysticActionSheetStyleYesOrNo];
        actionSheet.cancelButtonHeight = 0;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"YES", nil) type:AHKActionSheetButtonTypeDefault handler:confirmBlock];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"NO", nil) type:AHKActionSheetButtonTypeDestructive handler:cancelBlock];
        [actionSheet show];
    }
    else
    {
        [self toolBarCanceledOptionAndConfirmed:sender option:__currentOption];
    }
    
    
}
- (void) toolBarCanceledOptionAndConfirmed:(MysticButton *)sender option:(id)theOption;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    if(self.moreToolsView) [self.moreToolsView fadeOutFast:^(BOOL a) { [weakSelf.moreToolsView removeFromSuperview]; weakSelf.moreToolsView = nil; }];
    [self toolBarCanceledOptionAndConfirmedNoTools:sender option:theOption];
    
    
}
- (void) toolBarCanceledOptionAndConfirmedNoTools:(MysticButton *)sender option:(id)theOption;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    self.layerPanelController.ignoreStateChanges = YES;
    self.lastOptionSlotKey = nil;
    if(theOption)
    {
        PackPotionOption *_theOption = theOption;
        switch (_theOption.type) {
            case MysticObjectTypeFontStyle:
            case MysticObjectTypeFont:
                [weakSelf.fontStylesController cancelOverlays:nil]; break;
            case MysticObjectTypeShape: [weakSelf.shapesView cancelOverlays:nil]; break;
            default: break;
        }
        [self removeOption:theOption updateUI:NO];
    }
    if(self.extraView)
    {
        [self.extraView removeFromSuperview];
        self.extraView = nil;
    }
    MysticBlock layerAnimBlock = [self.layerPanelController layerPanelStateChangeAnimationBlock:(MysticLayerPanelView *)weakSelf.layerPanelController.view state:MysticLayerPanelStateClosed];
    [self.layerPanelView setState:MysticLayerPanelStateClosed animated:YES duration:0.22f animations:layerAnimBlock finished:^(BOOL done){ [weakSelf destroyLayerPanelController]; }];
    Block_release(layerAnimBlock);
    [weakSelf activatePack:nil];
    weakSelf.transformOption = nil;
    weakSelf.currentOption = nil;
    MysticWait(0.1, ^{ [weakSelf setState:MysticSettingNoneFromCancel animated:YES complete:nil]; });
}

- (void) toolBarCanceledSketchOption:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];

    __unsafe_unretained __block MysticController *weakSelf = self;
    if(!self.canvasController.hasSketched)
    {
        weakSelf.canvasController.canvas.preventMessages = YES;
        weakSelf.canvasController.canvas.userInteractionEnabled = NO;
        [weakSelf.canvasController.canvas resetScale];
        [weakSelf.canvasController destroyControls];
        [[MysticOptions current] removeOption:weakSelf.transformOption];
        [MysticOptions current].hasChanged = NO;
        weakSelf.transformOption = nil;
        weakSelf.canvasController.view.frame = CGRectXH(weakSelf.view.frame, 0, weakSelf.view.frame.size.height-weakSelf.bottomPanelView.frame.size.height);
        if(weakSelf.extraView) { [weakSelf.extraView removeFromSuperview]; weakSelf.extraView = nil; }
        [[weakSelf stateAnim:MysticSettingNoneFromConfirm animate:[weakSelf hideLayerPanelAnimation:nil] info:nil complete:nil] animate:nil];
        return;
    }
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"REMOVE SKETCH?"];
    [actionSheet setupAppearance:MysticActionSheetStyleDefaultNoBlur];
    actionSheet.cancelButtonHeight = 0;
    actionSheet.scrollEnabled = NO;
    actionSheet.cancelOnTapEmptyAreaEnabled = @NO;
    actionSheet.cancelOnPanGestureEnabled = @NO;
    actionSheet.hideTopSeparator=@YES;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"YES", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        weakSelf.canvasController.canvas.userInteractionEnabled = NO;
        weakSelf.canvasController.canvas.preventMessages = YES;
        [weakSelf.canvasController.canvas resetScale];
        [weakSelf.canvasController destroyControls];
        [[MysticOptions current] removeOption:weakSelf.transformOption];
        [MysticOptions current].hasChanged = NO;
        weakSelf.transformOption = nil;
        weakSelf.canvasController.view.frame = CGRectXH(weakSelf.view.frame, 0, weakSelf.view.frame.size.height-weakSelf.bottomPanelView.frame.size.height);
        if(weakSelf.extraView) { [weakSelf.extraView removeFromSuperview]; weakSelf.extraView = nil; }
        [[weakSelf stateAnim:MysticSettingNoneFromConfirm animate:[weakSelf hideLayerPanelAnimation:nil] info:nil complete:nil] animate:nil];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"NO", nil) type:AHKActionSheetButtonTypeDestructive handler:^(AHKActionSheet *actionSheet) {
        [weakSelf.canvasController showInterface];
        weakSelf.canvasController.canvas.preventMessages = NO;
        weakSelf.canvasController.canvas.userInteractionEnabled = YES;

    }];
    [actionSheet show];
    self.canvasController.canvas.preventMessages = YES;
    self.canvasController.canvas.userInteractionEnabled = NO;
    [self.canvasController hideInterface];
    [self.canvasController.canvas scaleDocumentToFit:YES];
    
}
- (void) toolBarUndo:(MysticButton *)sender;
{
    [self.canvasController undo:sender];
}
- (void) toolBarRedo:(MysticButton *)sender;
{
    [self.canvasController redo:sender];

}


- (void) toolBarConfirmedSketchOption:(id)sender;
{
    [MysticTipViewManager hideAll:NO];

    PackPotionOptionSketch *option = (id)self.transformOption;
    self.canvasController.canvas.preventMessages = YES;
    self.canvasController.canvas.userInteractionEnabled = NO;
    if(!self.canvasController.hasSketched)
    {
        
        [[MysticOptions current] removeOption:option];
        [MysticOptions current].hasChanged = NO;
        [self.canvasController.canvas resetScale];

        self.transformOption = nil;
        self.canvasController.view.frame = CGRectXH(self.view.frame, 0, self.view.frame.size.height-self.bottomPanelView.frame.size.height);

        if(self.extraView) { [self.extraView removeFromSuperview]; self.extraView = nil; }
        [[self stateAnim:MysticSettingNoneFromConfirm animate:[self hideLayerPanelAnimation:nil] info:nil complete:nil] animate:nil];
        return;
    }
    [self.canvasController destroyControls];

    __unsafe_unretained __block  UIImage *img = [self.canvasController.image retain];
    __unsafe_unretained __block MysticController *weakSelf = self;
    if(!option || option.type != MysticObjectTypeSketch)
    {
        if(option) option = (id)[[MysticOptions current] option:MysticObjectTypeSketch];
        if(!option) option = [[[[PackPotionOptionSketch alloc] init] autorelease] setUserChoice];
    }
    [self.canvasController.canvas resetScale];
    self.canvasController.view.frame = CGRectXH(self.view.frame, 0, self.view.frame.size.height-self.bottomPanelView.frame.size.height);
    option.customLayerImage = [img autorelease];
    [UserPotion confirmOption:option];
    [UserPotion confirmed];
    [[MysticOptions current] saveProject];
    option.hasRendered = NO;
    option.hasChanged = YES;
    [MysticOptions current].hasChanged = YES;
    [MysticOptions current].tag = nil;
    
    if(option) [MysticLog answer:option.name type:MysticObjectTypeTitleParent(option.type, MysticObjectTypeUnknown) tag:option.tag info:@{}];
    if(self.extraView) { [self.extraView removeFromSuperview]; self.extraView = nil; }
    [[weakSelf stateAnim:MysticSettingNoneFromConfirm animate:[weakSelf hideLayerPanelAnimation:nil] info:nil complete:nil] animate:nil];
    
}
- (void) toolBarHide:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];
    __unsafe_unretained __block MysticController *weakSelf = self;
    [self.moreToolsView fadeOutFast:^(BOOL active) { [weakSelf.moreToolsView removeFromSuperview]; weakSelf.moreToolsView = nil; }];
    [self confirmedOption:self.layerPanelView.targetOption object:sender finished:nil];
}
- (void) toolBarConfirmedOption:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];
    [self confirmedOption:self.layerPanelView.targetOption object:sender finished:nil];
}

- (void) confirmedOption:(PackPotionOption *)__currentOption object:(id)sender;
{
    [self confirmedOption:__currentOption object:sender finished:nil];
}
- (void) confirmedOption:(PackPotionOption *)confirmedOption object:(id)sender finished:(MysticBlock)finished;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block PackPotionOption *__confirmedOption = nil;
    [self stopMoreToolsTimer];
    if(weakSelf.moreToolsView)  [weakSelf toggleMoreTools:YES];
    MysticBlockOption finalizeOptionBlock = nil;
    self.lastOptionSlotKey = nil;
    
    BOOL hideLayerPanelAnim = YES;
    if(confirmedOption.refreshState == MysticSettingAdjustColor)
    {
        hideLayerPanelAnim = NO;
    }
    
    confirmedOption.refreshState = MysticSettingUnknown;
    MysticObjectType optionType = confirmedOption ? confirmedOption.type : MysticObjectTypeUnknown;
    if(confirmedOption) self.lastOptionSlotKey = confirmedOption.optionSlotKey;
    else
    {
        confirmedOption = self.currentOption;
        if(!confirmedOption) confirmedOption = self.layerPanelView.targetOption;
    }
    __unsafe_unretained __block MysticOverlaysView *__overlaysView = nil;
    if(confirmedOption)
    {
        BOOL skipConfirm = NO;
        if(confirmedOption.intensity <= 0) skipConfirm = YES;
        if(self.layerPanelView.targetOption && self.layerPanelView.visiblePanel.pack) self.layerPanelView.targetOption.packIndex = self.layerPanelView.visiblePanel.pack.index;
        switch (confirmedOption.type)
        {
            case MysticObjectTypeFontStyle:
            case MysticObjectTypeFont:
            {
                
                if(weakSelf.labelsView.overlays.count)
                {
                    confirmedOption = [weakSelf.labelsView confirmOverlays:(PackPotionOptionView *)confirmedOption complete:nil];
                    confirmedOption.hasRendered = NO;
                    confirmedOption.hasChanged = YES;
                    [MysticOptions current].hasChanged = YES;
                    if(!confirmedOption) skipConfirm = YES;
                    else
                    {
                        __overlaysView = weakSelf.labelsView;
                        finalizeOptionBlock = ^(PackPotionOptionView *o, MysticBlockObjObj c){
                            [o prepareViewImageComplete:c]; };
                    }
                }
                else skipConfirm = YES;
                break;
            }
            case MysticObjectTypeShape:
            {
                if(weakSelf.shapesView.overlays.count)
                {
                    confirmedOption = [weakSelf.shapesController confirmOverlays:(PackPotionOptionView *)confirmedOption complete:nil];
                    confirmedOption.hasRendered = NO;
                    confirmedOption.hasChanged = YES;
                    [MysticOptions current].hasChanged = YES;
                    if(!confirmedOption) skipConfirm = YES;
                    if(confirmedOption)
                    {
                        __overlaysView = weakSelf.shapesView;
                        finalizeOptionBlock = ^(PackPotionOptionView *o, MysticBlockObjObj c){ [o prepareViewImageComplete:c]; };
                    }
                }
                else skipConfirm = YES;
                break;
            }
            case MysticObjectTypeSetting: skipConfirm = !confirmedOption.adjustments || confirmedOption.adjustments.count < 2; break;
            default: break;
        }
        if(confirmedOption) __confirmedOption = [confirmedOption retain];
        if(!skipConfirm)
        {
            [UserPotion confirmOption:confirmedOption];
            [UserPotion confirmed];
            [[MysticOptions current] saveProject];
        }
        else if([[MysticOptions current] contains:confirmedOption]) [[MysticOptions current] removeOption:confirmedOption];
    }
    
    // TODO: Track the user action that is important for you.
    if(__confirmedOption) [MysticLog answer:__confirmedOption.name type:MysticObjectTypeTitleParent(__confirmedOption.type, MysticObjectTypeUnknown) tag:__confirmedOption.tag info:@{}];

    
    if(self.extraView) { [self.extraView removeFromSuperview]; self.extraView = nil; }
    MysticAnimationBlockObject *animation = hideLayerPanelAnim ? [weakSelf hideLayerPanelAnimation:nil] : nil;
    self.transformOption = nil;
    [MysticOptions current].tag = nil;
    if(finalizeOptionBlock != nil)
    {
        __unsafe_unretained __block MysticBlockOption _finalizeOption = Block_copy(finalizeOptionBlock);
        self.preReloadImageBlock = ^(MysticBlockAnimationComplete animBlock, BOOL f, MysticAnimationBlockObject *animObj)
        {
            __unsafe_unretained __block MysticBlockAnimationComplete _a = animBlock ? Block_copy(animBlock) : nil;
            __unsafe_unretained __block MysticAnimationBlockObject *_animObj = animObj ? [animObj retain] : nil;
            _finalizeOption(__confirmedOption, !_a ? nil : ^(UIImage *largeImage, NSValue *overlaysFrameVal)
            {
//                [UserPotionManager setImage:largeImage tag:[NSString stringWithFormat:@"layersImage-%@", overlaysFrameVal ? fs(overlaysFrameVal.CGRectValue) : @"none"]];
                if(!overlaysFrameVal)
                {
                    if(!weakSelf.overlaysPreviewImageView)
                    {
                        weakSelf.overlaysPreviewImageView = [[[UIImageView alloc] initWithFrame:__overlaysView.frame] autorelease];
                        weakSelf.overlaysPreviewImageView.contentMode = UIViewContentModeCenter;
                        [__overlaysView.superview insertSubview:weakSelf.overlaysPreviewImageView aboveSubview:__overlaysView];
                    }
                    weakSelf.overlaysPreviewImageView.image = largeImage;
                }
                else
                {
                    _a(f, _animObj); Block_release(_a);
                    if(_animObj) [_animObj autorelease];
                    __overlaysView.hidden = YES;
                    __overlaysView.frame = overlaysFrameVal.CGRectValue;
                    [__overlaysView autorelease];
                }
            });
    
            Block_release(_finalizeOption);
            if(__confirmedOption) [__confirmedOption release];
        };
    }
    animation = [weakSelf stateAnim:MysticSettingNoneFromConfirm animate:animation info:nil complete:nil];
    __unsafe_unretained __block MysticBlock _finished = finished ? Block_copy(finished) : nil;
    [animation animate:^(BOOL finished, MysticAnimationBlockObject *obj) { runBlock(_finished); }];
}

- (void) toolBarCanceledOptionSetting:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];
    [self stopMoreToolsTimer];
    id __currentOption = [self currentOption:self.currentSetting];
    __currentOption = !__currentOption ? self.currentOption : __currentOption;
    [self canceledOptionSettingForOption:__currentOption object:sender];
}
- (void) canceledOptionSettingForOption:(PackPotionOption *)option object:(MysticButton *)sender;
{
    if(!option) return [self toolBarCanceledOptionSettingAndConfirmed:sender option:option];
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block PackPotionOption *__option = !option ? nil : [option retain];
    __unsafe_unretained __block MysticButton *__sender = !sender ? nil : [sender retain];
    MysticBlockObject cancelBlock = !option ? nil : ^(id sender){ [__option release]; [__sender release]; };
    MysticBlockObject confirmBlock = !option ? nil : ^(id sender){ [weakSelf toolBarCanceledOptionSettingAndConfirmed:__sender option:[__option autorelease]]; [__sender release]; };
    if(option && !option.hasAdjustments) { if(confirmBlock) confirmBlock(nil); return; }
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"REMOVE CHANGES?"];
    [actionSheet setupAppearance:MysticActionSheetStyleYesOrNo];
    actionSheet.cancelButtonHeight = 0;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"YES", nil) type:AHKActionSheetButtonTypeDefault handler:confirmBlock];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"NO", nil) type:AHKActionSheetButtonTypeDestructive handler:cancelBlock];
    [actionSheet show];
}
- (void) toolBarCanceledOptionSettingAndConfirmed:(MysticButton *)sender option:(PackPotionOption *)option;
{
    [MysticTipViewManager hideAll:NO];
    [MysticOptions current].tag = nil;
    MysticObjectType optionSetting = self.layerPanelView.visiblePanel.setting;
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block PackPotionOption *_option = option ? option : nil;
    __unsafe_unretained __block id _sender = sender;
    
    if(!option) { [weakSelf toolBarConfirmedOptionSetting:sender]; return [[MysticOptions current] saveProject]; }
    [self.layerPanelView.visiblePanel canceledOption:option setting:optionSetting finished:^(id newValue, BOOL reload, BOOL refresh) {
        [weakSelf removeExtraControls];
        [weakSelf.overlayView setupGestures:weakSelf.currentSetting disable:NO];
        if(!reload && optionSetting != MysticSettingUnknown)
        {
            [_option undoLastAdjustment];
//            MysticSlider *slider = weakSelf.layerPanelView.visiblePanel.slider;
//            if(slider)
//            {
//                slider.blockEvents = YES;
//                [slider resetToValue:[newValue floatValue] animated:@(0.2) finished:^(BOOL f) {
//                    _option.refreshState = MysticSettingUnknown;
//                    [[MysticOptions current] saveProject];
//                    [_option setupFilter:nil];
//                    [[MysticOptions current].filters refresh:_option completion:nil];
//                    slider.blockEvents = NO;
//                    [weakSelf toolBarConfirmedOptionSetting:_sender];
//                }];
//            }
//            else
//            {
                _option.refreshState = MysticSettingUnknown;
                [_option setupFilter:nil];
                [[MysticOptions current].filters refresh:_option completion:nil];
                [weakSelf toolBarConfirmedOptionSetting:_sender];
                [[MysticOptions current] saveProject];
//            }
        }
        else
        {
            if(optionSetting > MysticSettingImageProcessing) [_option undoLastAdjustment];

//            MysticSlider *slider = weakSelf.layerPanelView.visiblePanel.slider;
//            if(slider && optionSetting < MysticSettingImageProcessing)
//            {
//                slider.blockEvents = YES;
//                [slider resetToValue:[newValue floatValue] animated:@(0.2) finished:^(BOOL f) {
//                    [[MysticOptions current] saveProject];
//                    MysticWait(0.15, ^{
//                        _option.refreshState = MysticSettingUnknown;
//                        slider.blockEvents = NO;
//                        [weakSelf toolBarConfirmedOptionSetting:_sender];
//                        [_option setupFilter:nil];
//                        [MysticOptions current].hasChanged = YES;
//                        [weakSelf reloadImageWithMsg:@(NO) placeholder:nil hudDelay:-1 settings:MysticRenderOptionsForceProcess complete:nil];
//                    });
//                }];
//            }
//            else
//            {
                _option.refreshState = MysticSettingUnknown;
                [_option setupFilter:nil];
                [[MysticOptions current].filters refresh:_option completion:nil];
                [weakSelf toolBarConfirmedOptionSetting:_sender];
                [[MysticOptions current] saveProject];
                [weakSelf reloadImageWithMsg:@(NO) placeholder:nil hudDelay:-1 settings:MysticRenderOptionsForceProcess complete:nil];
//            }
        }
    }];
}
- (void) toolBarConfirmedOptionSetting:(MysticButton *)sender;
{
    [MysticTipViewManager hideAll:NO];
    MysticObjectType optionSetting = self.layerPanelView.visiblePanel.setting;
    self.layerPanelView.targetOption.refreshState = MysticSettingNone;
    [MysticOptions current].tag = nil;
    [[MysticOptions current] saveProject];
    MysticObjectType gestureState= self.currentSetting;
    BOOL reloadImageAndSave = NO;
    if(optionSetting > MysticSettingImageProcessing)
    {
        reloadImageAndSave = YES;
        [[MysticOptions current] setHasChanged:YES changeOptions:NO];
        [[MysticOptions current] enable:MysticRenderOptionsSource];
        [[MysticOptions current] enable:MysticRenderOptionsSaveImageOutput];
        [[MysticOptions current] enable:MysticRenderOptionsForceProcess];
        [[MysticOptions current] enable:MysticRenderOptionsRebuildBuffer];
        [[MysticOptions current] enable:MysticRenderOptionsSaveState];
    }
    switch (optionSetting) {
        case MysticSettingMaskLayer: [self sketchImageIsDone]; break;
        case MysticSettingVignetteBlending: gestureState = MysticSettingVignette; break;
        default: break;
    }
 
    [self removeExtraControls];
    
    if(reloadImageAndSave)
    {
        __unsafe_unretained __block PackPotionOption *transOption = [self.transformOption retain];
        __unsafe_unretained __block MysticController *weakSelf = self;
        [weakSelf.overlayView setupGestures:gestureState disable:NO];
        weakSelf.transformOption = nil;
        [weakSelf reloadImageWithMsg:@"Saving" placeholder:nil hudDelay:0.2 settings:[MysticOptions current].settings complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
            [weakSelf.layerPanelView.tabBar setNeedsDisplay];
            transOption.hasRendered = NO;
            weakSelf.transformOption = [transOption autorelease];
            [MysticOptions current].needsRender = YES;
            [MysticOptions current].hasChanged = YES;
            [weakSelf.layerPanelView popToPreviousPanel:^{ [weakSelf reloadImage:YES complete:nil]; }];
        }];
        
    }
    else
    {
        __unsafe_unretained __block MysticController *weakSelf = self;

        [self.layerPanelView popToPreviousPanel:^{
            DLog(@"pop to previous: %@  %@  toggled: %@  toggleIndex: %@", MysticObjectTypeToString(weakSelf.layerPanelView.visiblePanel.optionType), weakSelf.layerPanelView.toolbar.titleToggleView, MBOOL(weakSelf.layerPanelView.toolbar.hasToggled), MBOOL(weakSelf.layerPanelView.toolbar.titleToggleIndex != NSNotFound));
            
            if(weakSelf.layerPanelView.toolbar.titleToggleView)
            {
                [weakSelf.layerPanelView.toolbar toggleTitleView:YES complete:^(UIView *newView, UIView *oldView, MysticLayerToolbar *toolbar){
                    
                    MysticToggleButton *toggler = [weakSelf.layerPanelView.toolbar.toggleTitleViewReplacement subviewOfClass:[MysticToggleButton class]];
                    if(!toggler) return;
                    
                    toggler.toggleState = ((PackPotionOption *)weakSelf.layerPanelView.visiblePanel.targetOption).layerEffect;
                }];
                

//                toggler.toggleStateAndTrigger = ((PackPotionOption *)__effectControl.effect).layerEffect;
            }
        }];
        [self.overlayView setupGestures:gestureState disable:NO];
    }
    

}

- (void) scrollHeader:(MysticScrollHeaderView *)headerView didTouchItem:(MysticButton *)sender;
{
    MysticLayoutStyle layoutStyle = MysticLayoutStyleList;
    MysticObjectSelectionType selectionType = MysticObjectSelectionTypePack;
    MysticObjectType objectType = self.layerPanelView.visiblePanel.optionType;
    switch (objectType) {
            
        case MysticSettingDesign:
        case MysticSettingText:
        case MysticObjectTypeDesign:
        case MysticObjectTypeText: layoutStyle = MysticLayoutStyleList; break;
        case MysticObjectTypeBadge:
        case MysticSettingBadge: layoutStyle = MysticLayoutStyleGrid; selectionType = MysticObjectSelectionTypeOption; break;
        default:
        {
            if(!MysticTypeHasPack(objectType)) return [headerView.scrollView hideHeader:0.5 delay:0.5 finished:nil];
            break;
        }
    }
    
    MysticAnimationBlockObject *animation = [self hideLayerPanelAnimation:nil];
    [animation animate];
    
    [self showPackPickerForType:@[@(objectType)] option:nil layoutStyle:layoutStyle selectionType:selectionType picked:^(MysticPack *pack, PackPotionOption* option, BOOL success) {
        __unsafe_unretained __block PackPotionOption *__option = option ? [option retain] : nil;
        __unsafe_unretained __block MysticPack *__pack = pack ? [pack retain] : nil;
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if(__pack) [__pack release], __pack=nil;
            if(__option) [__option release], __option=nil;
        }];
        if(option) [self editOption:option createNew:YES];
        else if(pack) [self chosePack:pack createNew:YES];
    }];
    
    
    
}

- (void) toolBarLabelTouched:(MysticToolbarTitleButton *)titleLabel; { [self toolBarLabelTouched:titleLabel option:nil]; }
- (void) toolBarLabelTouched:(MysticToolbarTitleButton *)titleLabel option:(PackPotionOption *)option;
{
    switch (titleLabel.toolType) {
        case MysticToolTypeVariant:
        {
            if(self.layerPanelView.targetOption)
            {
                self.layerPanelView.targetOption.activeOption.layerEffect = [(MysticToggleButton *)titleLabel toggleState];
                [self reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess];
            }
            break;
        }
        default:
        {
            switch (option ? option.type : titleLabel.objectType)
            {
                case MysticObjectTypeColorOverlay:
                case MysticObjectTypeFilter: return;
                default: break;
            }
            [self showPackPickerForType:@[@(option ? option.type : titleLabel.objectType)] option:nil layoutStyle:MysticLayoutStyleListToGrid complete:nil];
            break;
        }
    }
}

#pragma mark - canBecomeFirstResponder


- (BOOL) canBecomeFirstResponder { return YES; }

#pragma mark - Layer Panel


- (MysticLayerPanelView *) showLayerPanel:(BOOL)opened info:(NSDictionary *)__options;
{
    return [self showLayerPanel:opened animated:opened info:__options complete:nil];
}
- (MysticLayerPanelView *) prepareLayerPanel:(BOOL)prepareToOpen info:(NSDictionary *)__options;
{
    if(!self.layerPanelController) [self setupLayerPanelController];
    CGSize viewSize = self.navigationController.navigationBarHidden ? [MysticUI screen] : self.view.bounds.size;
    CGSize toViewSize = !self.navigationController.navigationBarHidden ? [MysticUI screen] : self.view.bounds.size;
    if(!self.layerPanelView)
    {
        self.layerPanelView = [self.layerPanelController showLayerPanel:prepareToOpen info:[NSMutableDictionary dictionaryWithDictionary:__options]];
        self.layerPanelView.closedAnchor = CGPointMake(0, viewSize.height + MYSTIC_UI_PANEL_CLOSEDINSET);
        [self.view addSubview:self.layerPanelView];
        [self.view bringSubviewToFront:self.layerPanelView];
    }
    else
    {
        [self updateLayerPanel:self.layerPanelView];
        [self.layerPanelView setOptions:[NSMutableDictionary dictionaryWithDictionary:__options]];
    }
    self.layerPanelView.openInset = MYSTIC_UI_PANEL_OPENINSET;
    self.layerPanelView.frame = CGRectMake(0, toViewSize.height + MYSTIC_UI_PANEL_CLOSEDINSET, toViewSize.width, MYSTIC_UI_PANEL_HEIGHT);
    self.layerPanelView.anchor = self.layerPanelView.frame.origin;
    if(prepareToOpen) [self.layerPanelView prepareToOpen];
    [self.view setNeedsDisplay];
    return self.layerPanelView;
}
- (MysticLayerPanelView *) showLayerPanel:(BOOL)opened animated:(BOOL)animated info:(NSDictionary *)__options complete:(MysticBlockBOOL)completed;
{
    [MysticAnimation removeAnimations:@"panel"];
    [self prepareLayerPanel:opened info:__options];
    if(self.layerPanelView.state != MysticLayerPanelStateOpen && opened) [self.layerPanelView setState:MysticLayerPanelStateOpen animated:animated finished:completed];
    return self.layerPanelView;
    
}
- (MysticAnimationBlockObject *) showLayerPanelAnimation:(MysticAnimationBlockObject *)animation info:(id)info;
{
    [MysticAnimation removeAnimations:@"panel"];
    __unsafe_unretained __block MysticController *weakSelf = self;
    CGSize viewSize = weakSelf.view.frame.size;
    animation = animation ? animation : [MysticAnimationBlockObject animation];
    [weakSelf showLayerPanel:YES animated:NO info:info complete:nil];
    MysticBlock layerAnimBlock = [self.layerPanelController layerPanelStateChangeAnimationBlock:(MysticLayerPanelView *)weakSelf.layerPanelController.view state:MysticLayerPanelStateOpen];
    weakSelf.layerPanelView.frame = CGRectMake(0, viewSize.height+MYSTIC_UI_PANEL_CLOSEDINSET, viewSize.width, weakSelf.layerPanelView.frame.size.height);
    animation = [weakSelf hideBottomBarAnimation:animation];
    [animation addKeyFrame:0.05 duration:0.2 animations:^{ weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateOpen]; }];
    [animation addKeyFrame:0.15 duration:0.3 animations:layerAnimBlock];
    [animation addAnimationComplete:^(BOOL f, MysticAnimationBlockObject *obj) { [weakSelf.tabBar removeFromSuperview], weakSelf.tabBar = nil; }];
    Block_release(layerAnimBlock);
    return animation;
}
- (MysticAnimationBlockObject *) hideLayerPanelAnimation:(MysticAnimationBlockObject *)animation;
{
    [MysticAnimation removeAnimations:@"panel"];
    __unsafe_unretained __block MysticController *weakSelf = self;
    animation = animation ? animation : [MysticAnimationBlockObject animation];
    animation.animationType = MysticAnimationTypeKeyFrame;
    self.layerPanelController.ignoreStateChanges = YES;
    self.layerPanelView.isHiding = YES;
    [animation addKeyFrame:0 duration:0.2 animations:^{ weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateClosed]; }];
    MysticBlock animBlock = [self.layerPanelController layerPanelStateChangeAnimationBlock:self.layerPanelView state:MysticLayerPanelStateClosed];
    [animation addKeyFrame:0.15 duration:0.3 animations:animBlock];
    [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) { [weakSelf destroyLayerPanelController]; }];
    Block_release(animBlock);
    return animation;
}

- (void) setupLayerPanelController;
{
    MysticLayerPanelViewController *layerPanelC = [[MysticLayerPanelViewController alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, MYSTIC_UI_PANEL_TOGGLER_HEIGHT) delegate:self];
    self.layerPanelController = layerPanelC;
    [self addChildViewController:layerPanelC];
    [self.layerPanelController didMoveToParentViewController:self];
    [layerPanelC release];
}

- (void) destroyLayerPanelController;
{
    self.layerPanelView.delegate = nil;
    [self.layerPanelController panelClosed];
    self.layerPanelView = nil;
    self.layerPanelController.delegate = nil;
    [self.layerPanelController removeFromParentViewController];
    self.layerPanelController = nil;
    
    
}

- (void) layerPanelFrameChanged:(MysticLayerPanelView *)panelView;
{
    
}

- (MysticAnimationBlockObject *) hideBottomBarAnimation:(MysticAnimationBlockObject *)animation;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    CGSize viewSize = weakSelf.view.frame.size;
    animation = animation ? animation : [MysticAnimationBlockObject animation];
    
    [animation addKeyOrAnimation:0 duration:0.25 animations:^{
        CGRect nf = weakSelf.bottomPanelView.frame;
        nf.origin.y =viewSize.height;
        weakSelf.bottomPanelView.frame = nf;
    }];
    return animation;
}

- (MysticAnimationBlockObject *) showBottomBarAnimation:(MysticAnimationBlockObject *)animation;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    CGSize viewSize = weakSelf.view.frame.size;
    animation = animation ? animation : [MysticAnimationBlockObject animation];
    weakSelf.bottomPanelView.hidden = NO;
    [animation addKeyOrAnimation:animation.duration*.7 duration:0.2 animations:^{
        CGRect nf = weakSelf.bottomPanelView.frame;
        nf.origin.y =viewSize.height - nf.size.height;
        
        weakSelf.bottomPanelView.frame = nf;
    }];
    return animation;
}


- (void) updateLayerPanel:(MysticLayerPanelView *)panelView;
{
    self.layerPanelView.targetOption = self.currentOption;
}









#pragma mark - Search Text Field Delegate Methods

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    textField.leftView = [MysticButton clearButtonWithImage:[UIImage imageNamed:([textField.text length] ?  @"header-search-icon-highlighted.png" : @"header-search-icon.png")] action:^{
        
    }];
    
    if(!textField.text || ![textField.text length])
    {
        
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    else
    {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    textField.leftView = [MysticButton clearButtonWithImage:[UIImage imageNamed:([textField.text length] ?  @"header-search-icon-highlighted.png" : @"header-search-icon.png")] action:^{
        
    }];
    
    if(!textField.text || ![textField.text length])
    {
        
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    else
    {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.leftView = [MysticButton clearButtonWithImage:[UIImage imageNamed:([newStr length] ?  @"header-search-icon-highlighted.png" : @"header-search-icon.png")] action:^{
        
    }];
    
    
    if(!newStr || ![newStr length])
    {
        
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    else
    {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
- (void) searchKeyboardShowing:(NSNotification *)notification
{
    keyboardHidden = NO;
}
- (void) searchKeyboardHidden:(NSNotification *)notification
{
    
}

#pragma mark - Choose Pack

- (void) chosePack:(id)packOrPacks createNew:(BOOL)createNewObj;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    MysticPack *pack = [packOrPacks isKindOfClass:[NSArray class]] ? [packOrPacks objectAtIndex:0] : packOrPacks;
    lastSetting = currentSetting;
    currentSetting = pack.groupType;
    pack.createNewCopy = createNewObj;
    
    [MysticOptions current].originalTag = [MysticOptions current].tag;
    self.transformOption = nil;
    
    
   
    
    MysticAnimationBlockObject *animation = [weakSelf showLayerPanelAnimation:nil info:@{
                                                                                         
                                                                                         @"backgroundAlpha": @(1),
                                                                                         @"option":@YES,
                                                                                         @"hideToggler": @YES,
                                                                                         @"enabled":@NO,
                                                                                         @"animateContext": @NO,
                                                                                         @"panel": [MysticPanelObject info:@{
                                                                                                                                           @"state": @(pack.groupType),
                                                                                                                                           @"optionType": @(pack.groupType),
                                                                                                                                           @"pack": pack ? pack : @NO,
                                                                                                                                           @"packs": [packOrPacks isKindOfClass:[NSArray class]] ? packOrPacks : @NO,
                                                                                                                                           @"reload": @YES,
                                                                                                                                           @"title": MysticObjectTypeTitleParent(pack.groupType, MysticObjectTypeUnknown),
                                                                                                                                           @"panel": @(MysticPanelTypeOptionLayer)
                                                                                                                                           }],
                                                                                         }];
    [animation animate:^(BOOL finished, MysticAnimationBlockObject *obj) {
        [weakSelf.overlayView setupGestures:weakSelf.currentSetting];
        
    }];
    
    
}


#pragma mark - Edit Layer

- (void) editOption:(PackPotionOption *)option createNew:(BOOL)createNewObj;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    lastSetting = currentSetting;
    currentSetting = option.type;
    option.createNewCopy = createNewObj;
    
    __unsafe_unretained __block MysticAnimationBlockObject *animation = [[MysticAnimationBlockObject animationWithDuration:0.3] retain];
    
    __unsafe_unretained __block MysticPanelObject *panelObj = [[MysticPanelObject info:@{
                                                                                                       @"state": @(option.type),
                                                                                                       @"reload": @YES,
                                                                                                       
                                                                                                       @"optionType": @(option.type),
                                                                                                       @"title": MysticObjectTypeTitleParent(option.type, MysticObjectTypeUnknown),
                                                                                                       @"panel": @(MysticPanelTypeOptionLayer)
                                                                                                       }] retain];
    
    panelObj.targetOption = option;
    panelObj.pack = option.packIndex ? [MysticPack packForIndex:option.packIndex] : panelObj.pack;
    [option setUserChoice:YES finished:nil];
    self.transformOption = option;
    [MysticOptions current].originalTag = [MysticOptions current].tag;
    
    [NSTimer wait:0.12 block:^{
        
        [panelObj ready:^(MysticPanelObject *panelObj, BOOL success) {
            
            [weakSelf reloadImage:YES complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                weakSelf.preventToolsFromBeingVisible = NO;
            }];
            
        }];
        [panelObj confirm:^(id sender, MysticPanelObject *panelObj, BOOL success) {
            
            [weakSelf confirmedOption:panelObj.targetOption object:sender];
            [MysticController setNeedsDisplay];
            
        }];
        [panelObj cancel:^(id sender, MysticPanelObject *panelObj, BOOL success) {
            
            
            [weakSelf cancelledOption:panelObj.targetOption object:sender];
            [MysticController setNeedsDisplay];
            
            
        }];
        [panelObj touch:^(id sender, MysticPanelObject *panelObj) {
            
            
            [weakSelf toolBarLabelTouched:sender option:panelObj.targetOption];
        }];
        [panelObj destroy:^(MysticPanelObject *panelObj) {
        }];
        
        animation = [weakSelf showLayerPanelAnimation:animation info:@{
                                                                       
                                                                       @"backgroundAlpha": @(0),
                                                                       @"option":option ? option : @YES,
                                                                       @"hideToggler": @YES,
                                                                       @"enabled":option ? @YES : @NO,
                                                                       @"animateContext": @NO,
                                                                       @"panel": panelObj
                                                                       }];
        [panelObj release];
        [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
            [weakSelf.overlayView setupGestures:weakSelf.currentSetting];
        }];
        [animation animate:nil];
        [animation release];
    }];
    
}




- (CGRect) updateImageViewFrame:(CGRect)imgFrame;
{
    return [self updateImageViewFrame:imgFrame animated:NO];
}
- (CGRect) updateImageViewFrame:(CGRect)imgFrame animated:(BOOL)animated;
{
    BOOL isNavHidden = self.navigationController.navigationBarHidden && ![(MysticNavigationViewController *)self.navigationController willNavigationBarBeVisible] && (!self.navigationController.navigationBar.translucent || (self.navigationController.navigationBarHidden && self.navigationController.navigationBar.translucent));
    return [self updateImageViewFrame:imgFrame navHidden:isNavHidden bottomHidden:isNavHidden animated:animated];
}


- (CGRect) updateImageViewFrame:(CGRect)imgFrame navHidden:(BOOL)isNavHidden bottomHidden:(BOOL)isBtmHidden animated:(BOOL)animated;
{
    CGRect imgFrame_in = imgFrame;
    if(CGRectEqual(imgFrame, CGRectInfinite) || CGRectIsZero(imgFrame)) imgFrame = CGRectSize(self.bottomPanelView.frame.size);
    UIEdgeInsets imInsets = [MysticPhotoContainerView defaultInsets];
    imInsets.top = isNavHidden ? MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET : self.navigationController.navigationBar.frame.size.height + MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET;
    imInsets.bottom = imgFrame.size.height+(isNavHidden  ? MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET :MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET);
    
    if(self.actionView && self.actionView.superview)
    {
        imInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
        imInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
    }
    else
    {
        if(self.layerPanelView && self.layerPanelView.state == MysticLayerPanelStateOpen)
        {
            imInsets.bottom = MAX(self.layerPanelView.visibleHeight + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET, imInsets.bottom);
            switch (self.layerPanelView.visiblePanel.panelType) {
                case MysticPanelTypeShape:
                case MysticPanelTypeFont:
                case MysticPanelTypeFonts:
                case MysticPanelTypeFontStyle:
                case MysticPanelTypeFontAdjust:
                case MysticPanelTypeFontAlign:
                {
                    imInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                    imInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                    imInsets.left = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                    imInsets.right = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                    break;
                }
                default:
                {
                    imInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                    imInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                    break;
                }
            }
        }
        else
        {
            imInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
            imInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
        }
    }
    
    CGRect iframe = animated ? self.view.frame : [self setImageViewFrame:self.view.frame insets:imInsets offset:CGPointZero];
    if(animated)
    {
        iframe = [self.imageView centerImageViewFrame:imInsets];
        __unsafe_unretained __block MysticController *weakSelf = self;
        [MysticUIView animateWithDuration:0.26 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{[weakSelf setImageViewFrame:iframe insets:imInsets offset:CGPointZero];}];
    }
    return iframe;
}

#pragma mark - Toolbar

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    switch (toolbar.tag) {
        case MysticViewTypeTabBarShapeAlign:
        {
            MysticPosition pos = MysticPositionUnknown;
            UIEdgeInsets offset = UIEdgeInsetsZero;
            MysticToggleButton *alignToBtn = (id)[toolbar itemWithTag:MysticViewTypeToggler];
            
            
            
            MysticObjectType alignTo = alignToBtn ? alignToBtn.toggleState : MysticSettingAlignToArtboard;
            switch (sender.objectType)
            {
                case MysticSettingShapeAlignLeft:
                {
                    pos = MysticPositionLeftOnly;
                    break;
                }
                case MysticSettingShapeAlignRight:
                {
                    pos = MysticPositionRightOnly;
                    break;
                }
                case MysticSettingShapeAlignCenterHorizontal:
                {
                    pos = MysticPositionCenterOnly;
                    break;
                }
                case MysticSettingShapeAlignTop:
                {
                    pos = MysticPositionTopOnly;
                    break;
                }
                case MysticSettingShapeAlignCenterVertical:
                {
                    pos = MysticPositionCenterVerticalOnly;
                    break;
                }
                case MysticSettingShapeAlignBottom:
                {
                    pos = MysticPositionBottomOnly;
                    break;
                }
                case MysticSettingShapeAlignTo:
                {
                    alignTo = [(MysticToggleButton *)sender toggle];
                    break;
                }
                default:
                {
                    break;
                }
            }
            MysticResizeableLayersViewController *controller = self.shapesController ? self.shapesController : self.fontStylesController;
            NSArray *selectedLayers = controller.selectedLayers;
            if(pos != MysticPositionUnknown && (selectedLayers.count < 2 && alignTo != MysticSettingAlignToArtboard))
            {
                DLog(@"ignoring align because there is only one selected layer: %@", MysticString(alignTo));
            }
            else if(pos != MysticPositionUnknown)
            {
                CGPoint alignToOrigin = [(UIView *)controller.keyObjectLayer center];
                if(alignTo == MysticSettingAlignToSelection)
                {
                    CGRect alignRect = CGRectZero;
                    alignRect.origin.x = CGFLOAT_MAX;
                    alignRect.origin.y = CGFLOAT_MAX;

                    for (MysticLayerBaseView *layer in selectedLayers) {
                        switch (pos) {
                            case MysticPositionCenterVerticalOnly:
                            {
                                alignRect.origin.y = alignRect.origin.y == CGFLOAT_MAX ? layer.frame.origin.y : MIN(alignRect.origin.y, layer.frame.origin.y);
                                alignRect.origin.x = alignRect.origin.x == CGFLOAT_MAX ? layer.frame.origin.x : MIN(alignRect.origin.x, layer.frame.origin.x);
                                break;
                            }
                            case MysticPositionCenterOnly:
                            {
                                alignRect.origin.y = alignRect.origin.y == CGFLOAT_MAX ? layer.frame.origin.y : MIN(alignRect.origin.y, layer.frame.origin.y);
                                alignRect.origin.x = alignRect.origin.x == CGFLOAT_MAX ? layer.frame.origin.x : MIN(alignRect.origin.x, layer.frame.origin.x);
                                break;
                            }
                            default: break;
                        }
                    }
                    for (MysticLayerBaseView *layer in selectedLayers) {
                        switch (pos) {
                            case MysticPositionBottomOnly:
                            {
                                alignToOrigin.y = MAX(alignToOrigin.y, layer.frame.origin.y + layer.frame.size.height);
                                break;
                            }
                            case MysticPositionTopOnly:
                            {
                                alignToOrigin.y = MIN(alignToOrigin.y, layer.frame.origin.y);
                                break;
                            }
                            case MysticPositionLeftOnly:
                            {
                                alignToOrigin.x = MIN(alignToOrigin.x, layer.frame.origin.x);
                                break;
                            }
                            case MysticPositionRightOnly:
                            {
                                alignToOrigin.x = MAX(alignToOrigin.x, layer.frame.origin.x + layer.frame.size.width);
                                break;
                            }
                            case MysticPositionCenterVerticalOnly:
                            case MysticPositionCenterOnly:
                            {
                                alignRect.size.height = CGRectGetMaxY(alignRect) - alignRect.origin.y > CGRectGetMaxY(layer.frame) - alignRect.origin.y ? alignRect.size.height : CGRectGetMaxY(layer.frame) - alignRect.origin.y;
                                alignRect.size.width = CGRectGetMaxX(alignRect) - alignRect.origin.x > CGRectGetMaxX(layer.frame) - alignRect.origin.x ? alignRect.size.width : CGRectGetMaxX(layer.frame) - alignRect.origin.x;
                                alignToOrigin.y = alignRect.origin.y + (alignRect.size.height/2);
                                alignToOrigin.x = alignRect.origin.x + (alignRect.size.width/2);

                                
                                break;
                            }
                                
                            default:
                                break;
                        }

                    }

                    
                }
                else
                {
                    switch (alignTo) {
                        case MysticSettingAlignToArtboard:
                        {
                            switch (pos) {
                                case MysticPositionCenterOnly:
                                    pos = MysticPositionCenterVerticalOnly;
                                    break;
                                case MysticPositionCenterVerticalOnly:
                                    pos = MysticPositionCenterOnly;
                                    break;
                                    
                                default:
                                    break;
                            }
                            break;
                        }
                        default:
                            break;
                    }
                }
                for (MysticLayerBaseView *layer in selectedLayers) {
                    
                    switch (alignTo) {
                        case MysticSettingAlignToSelection:
                        {
                            switch (pos) {
                                case MysticPositionCenterOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.y = alignToOrigin.y;
                                    r.origin.x = r.origin.x + (r.size.width/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                case MysticPositionBottomOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.y = alignToOrigin.y - (r.size.height/2);
                                    r.origin.x = r.origin.x + (r.size.width/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                case MysticPositionTopOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.y = alignToOrigin.y + (r.size.height/2);
                                    r.origin.x = r.origin.x + (r.size.width/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                case MysticPositionLeftOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.x = alignToOrigin.x + (r.size.width/2);
                                    r.origin.y = r.origin.y + (r.size.height/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                
                                case MysticPositionCenterVerticalOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.x = alignToOrigin.x;
                                    r.origin.y = r.origin.y + (r.size.height/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                case MysticPositionRightOnly:
                                {
                                    CGRect r = layer.frame;
                                    r.origin.x = alignToOrigin.x - (r.size.width/2);
                                    r.origin.y = r.origin.y + (r.size.height/2);
                                    layer.center = r.origin;
                                    break;
                                }
                                default: break;
                            }
                            break;
                        }
                        case MysticSettingAlignToKeyObject:
                        {
                            DLog(@"align to keyobject");
                            
                            break;
                        }
                        case MysticSettingAlignToArtboard:
                        {
                            switch (pos) {
                                case MysticPositionBottomOnly:
                                {
                                    offset.bottom = -layer.contentView.frame.origin.y;
                                    break;
                                }
                                case MysticPositionTopOnly:
                                {
                                    offset.top = -layer.contentView.frame.origin.y;
                                    break;
                                }
                                case MysticPositionLeftOnly:
                                {
                                    offset.left = -layer.contentView.frame.origin.x;
                                    break;
                                }
                                case MysticPositionRightOnly:
                                {
                                    offset.right = -layer.contentView.frame.origin.x;
                                    break;
                                }
                                default: break;
                            }
                            CGRect r = CGRectPosition(layer.frame, UIEdgeInsetsInsetRect(controller.overlaysView.bounds, offset) , pos);
                            CGPoint newCenter = (CGPoint){r.origin.x + (r.size.width/2), r.origin.y + (r.size.height/2)};
                            layer.center = newCenter;
                            break;
                        }
                        default:
                        {
                            
                            break;
                        }
                    }
                    
                }
            }
            break;
        }
        default: break;
    }
    
}



- (MysticObjectType) parentSettingType;
{
    SubBarButton *lastSelectedButton = [self.tabBar selectedButton];
    if(lastSelectedButton)
    {
        return lastSelectedButton.type;
    }
    
    
    return MysticObjectTypeUnknown;
}


#pragma mark - mysticHorizontalMenuDelegate

- (void) mysticHorizontalMenu:(MysticHorizontalMenu *)menu buttonTouchedAtIndex:(NSInteger)index;
{
    DLog(@"horizontal menu button touched index: %d", (int)index);
}

- (void) mysticHorizontalMenu:(MysticHorizontalMenu *)menu indexChanged:(NSInteger)index;
{
    __unsafe_unretained __block MysticLayerPanelView *__panelView = self.layerPanelView;
    NSDictionary *item = [menu itemAtIndex:index];
    MysticSlider *adjustSlider = (MysticSlider *)[__panelView viewWithTag:(MysticViewTypePanel + MysticViewTypeSlider)];
    
    if(!adjustSlider) return;
    MysticObjectType state = [item objectForKey:@"state"] ? [[item objectForKey:@"state"] integerValue] : MysticSettingHSBHue;
    CGFloat sliderValue = [item objectForKey:@"value"] ? [[item objectForKey:@"value"] floatValue] : 1.0f;
    CGFloat minValue = [item objectForKey:@"min"] ? [[item objectForKey:@"min"] floatValue] : 0;
    CGFloat maxValue = [item objectForKey:@"max"] ? [[item objectForKey:@"max"] floatValue] : 2.0f;
    
    NSString *property = [item objectForKey:@"property"] ? [item objectForKey:@"property"]  : nil;
    
    if(property)
    {
        id _sliderValue = [__panelView.targetOption valueForKeyPath:property];
        sliderValue = _sliderValue ? [_sliderValue floatValue] : sliderValue;
        
    }
    
    adjustSlider.setting = state;
    adjustSlider.targetOption = __panelView.targetOption;
    adjustSlider.minimumValue = minValue;
    adjustSlider.maximumValue = maxValue;
    if(__panelView.targetOption)
    {
        adjustSlider.value = sliderValue;
    }
    else
    {
        adjustSlider.value = 1;
    }
    
    
}



- (void) updateConfig;
{
    [self updateConfig:NO complete:nil];
}
- (void) updateConfig:(BOOL)forceDownload complete:(MysticBlockBOOL)completed;
{
    
    if(forceDownload || (([Mystic hasCacheExpired] || !self.hasCheckedForUpdateAtLeastOnce) && [MysticUser user].autoUpdate && !self.autoUpdating))
    {
        if(!self.hasCheckedForUpdateAtLeastOnce)
        {
            NSTimeInterval t = [Mystic lastCheckedForUpdate] + kConfigCacheExpirationTime30Min;
            if(t > [NSDate timeIntervalSinceReferenceDate])
            {
                
                
                return;
            }
        }
        __unsafe_unretained __block MysticController *weakSelf = self;
        __unsafe_unretained __block MysticBlockBOOL _completed = completed ? Block_copy(completed) : nil;
        weakSelf.autoUpdating = YES;
        weakSelf.hasCheckedForUpdateAtLeastOnce = YES;
        [[Mystic core] updateConfig:^(BOOL startingDownload) {
            
            //            DLog(@"EditController: starting update download: %@", MBOOL(startingDownload));
            
            if(!startingDownload) return;
            
            
            
        } complete:^(BOOL success) {
            
            //            if(success) DLog(@"finished update download: %@", MBOOL(success));
            weakSelf.autoUpdating = NO;
            if(_completed) _completed(success);
            if(!success) return;
            
            
            
            
            
        }];
    }
}



#pragma mark - PackPicker Delegate


- (void) showPackPickerForType:(NSArray *)theTypes complete:(MysticBlock)finished;
{
    [self showPackPickerForType:theTypes option:nil layoutStyle:MysticLayoutStyleGrid complete:finished];
}
- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption complete:(MysticBlock)finished;
{
    [self showPackPickerForType:theTypes option:selectedOption layoutStyle:MysticLayoutStyleGrid complete:finished];
}
- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption layoutStyle:(MysticLayoutStyle)layoutStyle complete:(MysticBlock)finished;
{
    [self updateConfig];
    MysticNavigationViewController *nav;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
    }
    nav.view.backgroundColor = [UIColor blackColor];
    MysticPackPickerViewController *acontroller = [[MysticPackPickerViewController alloc] initWithNibName:nil bundle:nil layout:layoutStyle types:theTypes];
    acontroller.selectedOption = selectedOption;
    acontroller.delegate = self;
    [nav pushViewController:acontroller animated:NO];
    [self.navigationController presentViewController:nav animated:YES completion:finished];
    [acontroller release];
}

- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption layoutStyle:(MysticLayoutStyle)layoutStyle picked:(MysticBlockObjObjBOOL)pickedBlock;
{
    [self showPackPickerForType:theTypes option:selectedOption layoutStyle:layoutStyle selectionType:MysticObjectSelectionTypeOption picked:pickedBlock];
}
- (void) showPackPickerForType:(NSArray *)theTypes option:(PackPotionOption *)selectedOption layoutStyle:(MysticLayoutStyle)layoutStyle selectionType:(MysticObjectSelectionType)selectionType picked:(MysticBlockObjObjBOOL)pickedBlock;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block NSArray *_theTypes = theTypes ? [theTypes retain] : nil;
    __unsafe_unretained __block MysticBlockObjObjBOOL _pickedBlock = pickedBlock ? Block_copy(pickedBlock) : nil;
    __block MysticLayoutStyle _layoutStyle = layoutStyle;
    __block MysticObjectSelectionType _selectionType = selectionType;
    [self updateConfig];
    
    mdispatch_high(^{
        
        
        MysticNavigationViewController *nav;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        } else {
            nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        }
        nav.view.backgroundColor = [UIColor blackColor];
        __unsafe_unretained __block MysticPackPickerViewController *acontroller = [[MysticPackPickerViewController alloc] initWithNibName:nil bundle:nil layout:_layoutStyle types:_theTypes];
        acontroller.selectionType = _selectionType;
        acontroller.selectedOption = selectedOption;
        acontroller.delegate = weakSelf;
        acontroller.selectedBlock = _pickedBlock;
        
        __unsafe_unretained __block MysticNavigationViewController *_nav = [nav retain];
        [acontroller prepareData:^{
            mdispatch( ^{
                [_nav pushViewController:acontroller animated:NO];
                [weakSelf.navigationController presentViewController:_nav animated:YES completion:nil];
                [acontroller release];
                [_nav release];
            });
            if(_pickedBlock) Block_release(_pickedBlock);
            if(_theTypes) [_theTypes release];
        }];
        
    });
}


- (void) packPickerDidCancel:(MysticPackPickerViewController *)pickerController;
{
    if(!self.layerPanelView)
    {
        [self setStateConfirmed:MysticSettingNone animated:NO complete:nil];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void) packPicker:(MysticPackPickerViewController *)pickerController didSelectPack:(MysticPack *)pack;
{
    [self packPicker:pickerController didSelectPack:pack option:nil];
}
- (void) packPicker:(MysticPackPickerViewController *)pickerController didSelectPack:(MysticPack *)pack option:(PackPotionOption *)option;
{
    [self closeDrawerIfOpened:NO finished:nil];
    __unsafe_unretained __block MysticController *weakSelf = self;
    __unsafe_unretained __block MysticPack *_pack = [pack retain];
    BOOL shouldReloadImage = NO;
    
    
    if(option)
    {
        self.preventToolsFromBeingVisible = NO;
        shouldReloadImage = YES;
        [option setUserChoice:YES finished:nil];
        if(weakSelf.layerPanelView)
        {
            [weakSelf.layerPanelView updateWithTargetOption:option];
        }
        
    }
    
    if(shouldReloadImage)
    {
        [weakSelf reloadImageInBackground:YES settings:MysticRenderOptionsForceProcess];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        MysticObjectType optionType = _pack.packType;
        [weakSelf activatePack:_pack];
        //        MysticObjectType currentObjectType = MysticTypeForSetting(weakSelf.currentSetting, nil);
        
        
        if(weakSelf.layerPanelView && weakSelf.layerPanelView.visiblePanel)
        {
            MysticLayerToolbar *toolbar = [weakSelf.layerPanelController toolbarForSection:weakSelf.layerPanelView.visiblePanel];
            //            [toolbar setTitle:_pack.name];
            [toolbar setTitle:@"MORE ART"];
            weakSelf.layerPanelView.visiblePanel.pack = _pack;
            MysticBlockObjObj f = [weakSelf.layerPanelController layerPanel:weakSelf.layerPanelView sectionIsReadyBlock:weakSelf.layerPanelView.visiblePanel];
            if(f)
            {
                f(weakSelf.layerPanelView.visiblePanel.contentView, weakSelf.layerPanelView.visiblePanel);
            }
        }
        else
        {
            
            [weakSelf showLayerPanel:YES info:@{
                                                
                                                @"backgroundAlpha": @(MYSTIC_UI_PANEL_BG_ALPHA),
                                                @"option":option ? option : @YES,
                                                @"hideToggler": @YES,
                                                @"enabled":option ? @YES : @NO,
                                                @"panel": [MysticPanelObject info:@{
                                                                                                  @"state": @(weakSelf.currentSetting),
                                                                                                  @"optionType": @(optionType),
                                                                                                  @"title": MysticObjectTypeTitleParent(optionType, MysticObjectTypeUnknown),
                                                                                                  @"panel": @(MysticPanelTypeOptionLayer),
                                                                                                  @"pack": _pack ? _pack : @NO,
                                                                                                  }]
                                                }];
            
            
        }
        [_pack release];
        
        
        
    }];
}

- (void) ignoreOption:(PackPotionOption *)option;
{
    switch (option.type) {
        case MysticObjectTypeFont:
        case MysticObjectTypeFontStyle:
            [self.fontStylesController ignoreOverlays:option.ignoreActualRender];
            
            break;
        case MysticObjectTypeShape:
            [self.shapesController ignoreOverlays:option.ignoreActualRender];

            break;
        default: break;
    }
}

#pragma mark - Tab Bar

- (void) tabBar:(NSArray *)theOptions;
{
    theOptions = theOptions ? theOptions : nil;
    
    if(!theOptions)
    {
        switch ([MysticUser user].appVersion) {
            case MysticVersionLight:
            {
                theOptions = @[
                               
//                               @{@"type": @(MysticSettingNewProject), },
                               
//                               @{@"type": @(MysticObjectTypePotion), },

                               @{@"type": @(MysticObjectTypeText), },

                               
                               @{@"type": @(MysticObjectTypeFilter), },
                               
                               @{@"type": @(MysticSettingAddLayer), },
                               
                               @{@"type": @(MysticObjectTypeSetting), },
                               
//                               @{@"type": @(MysticSettingOptions)},
                               
                               @{@"type": @(MysticSettingAdjustColor)},

                               
                               
                               ];
                
                
                break;
            }
            case MysticVersionCosmos:
            {
                theOptions = @[
                               @{@"type": @(MysticObjectTypeFilter), },
                               
                               @{@"type": @(MysticObjectTypeDesign), },
                               @{@"type": @(MysticSettingAddLayer), },
                               
                               @{@"type": @(MysticObjectTypeTexture), },
                               @{@"type": @(MysticObjectTypeFrame), },
                               
                               
                               @{@"type": @(MysticObjectTypeLight), },
                               @{@"type": @(MysticObjectTypeBadge), },
                               
                               @{@"type": @(MysticObjectTypeSetting), },
                               
                               ];
                break;
            }
            default: break;
        }
    }
    MysticTabBar *__tabBar = [[MysticTabBar alloc] initWithFrame:self.bottomToolbar.bounds options:theOptions layout:MysticLayoutStyleFixed rect:CGRectInset(self.bottomToolbar.bounds, 5, 0)];
    __tabBar.tag = MysticViewTypeTabBarMain;
    __tabBar.tabBarDelegate = self;
    __tabBar.scrollEnabled = NO;
    __tabBar.unSelectAllOnDisplay = YES;
//    self.bottomToolbar.backgroundColor =  [UIColor colorWithType:MysticColorTypeTabBarBackground];
//    self.bottomToolbar.backgroundColor =  self.view.backgroundColor;
    self.bottomToolbar.backgroundColor = UIColor.clearColor;
    
    __tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tabBar = __tabBar;
    [__tabBar release];
    [self.bottomToolbar addSubview:self.tabBar];
    self.tabBar.hidden = NO;
    self.tabBar.userInteractionEnabled = YES;
    
}

- (void) showAddTabBar:(NSArray *)theOptions;
{
    [self showAddTabBar:theOptions finished:nil];
}
- (void) showAddTabBar:(NSArray *)theOptions finished:(MysticBlockObjObj)addedOption;
{
    theOptions = theOptions ? theOptions : nil;
    if(!theOptions)
    {
        switch ([MysticUser user].appVersion) {
            case MysticVersionCosmos:
            case MysticVersionLight:
            {
                theOptions = @[
//                               @{@"type": @(MysticObjectTypeDesign), },
                               //#ifdef DEBUG
                               @{@"type": @(MysticObjectTypeSketch), },
                               //#endif
                               @{@"type": @(MysticObjectTypeFont), },
                               @{@"type": @(MysticObjectTypeTexture), },
//                               @{@"type": @(MysticObjectTypeFilter), },

                               @{@"type": @(MysticObjectTypeFrame), },

                               @{@"type": @(MysticObjectTypeImage), },

//                               @{@"type": @(MysticObjectTypeShape), },
                               @{@"type": @(MysticObjectTypeLight), },
                               @{@"type": @(MysticObjectTypeColorOverlay), },
                               ];
                break;
            }
            default: break;
        }
    }
    CGRect onframe = self.bottomToolbar.bounds;
    CGRect ontopFrame = onframe;
    ontopFrame.origin.y = -MYSTIC_UI_TOOLBAR_HIDE_HEIGHT;
    
    CGRect tabFrame = ontopFrame;
    tabFrame.size.height  = 75;
    
    CGRect totalFrame = tabFrame;
    totalFrame.size.height += MYSTIC_UI_TOOLBAR_HIDE_HEIGHT;
    
    CGRect offframe = self.bottomToolbar.bounds;
    offframe.origin.y = tabFrame.size.height;
    
    CGRect barelyFrame = offframe;
    barelyFrame.origin.y -= MYSTIC_UI_TOOLBAR_HIDE_HEIGHT;
    
    
    __unsafe_unretained __block MysticController *weakSelf = self;
    UIView *addTabView = self.addTabBar ? (id)self.addTabBar.superview : nil;
    if(!self.addTabBar)
    {
        CGRect tf = tabFrame;
        tf.origin = CGPointZero;
        MysticTabBarAddLayer *__tabBar = [[MysticTabBarAddLayer alloc] initWithFrame:tf options:theOptions];
        __tabBar.tag = MysticViewTypeTabBarAddLayer;
        __tabBar.tabBarDelegate = self;
        __tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        __tabBar.backgroundColor = [UIColor hex:@"141412"];
        self.addTabBar = __tabBar;
        [__tabBar release];
        
        MysticButton *closeBtn = [MysticButton button:[MysticImageIcon image:@(MysticIconTypeToolHide) size:(CGSize){10, 6} color:[UIColor hex:@"6C5F58"]] action:^(id sender) {
            [weakSelf hideAddTabBar];
            MysticWait(0.25, ^{ [weakSelf showUndoRedo:nil]; });
        }];
        closeBtn.backgroundColor = [UIColor hex:@"242422"];
        closeBtn.frame = (CGRect){0,tabFrame.size.height,tabFrame.size.width, MYSTIC_UI_TOOLBAR_HIDE_HEIGHT};
        CGRect actionViewFrame = (CGRect){0,self.view.frame.size.height, totalFrame.size.width, totalFrame.size.height + 50};
        addTabView = [[UIView alloc] initWithFrame:actionViewFrame];
        
        addTabView.clipsToBounds = YES;
        CGRect tbFrame = addTabView.bounds;
        tbFrame.origin.y = -2;
        tbFrame.size.height += (tbFrame.origin.y * -1)*2;
        addTabView.backgroundColor = [UIColor hex:@"141412"];
        [addTabView addSubview:self.addTabBar];
        [addTabView addSubview:closeBtn];
        self.actionView = addTabView;
        [self.view addSubview:self.actionView];
        [addTabView release];
        
        
        
    }
    self.bottomPanelView.backgroundColor = [UIColor clearColor];
    self.bottomPanelView.clipsToBounds = YES;
    self.addTabBar.hidden = NO;
    self.tabBar.userInteractionEnabled = NO;
    self.tabBar.scrollEnabled = NO;
    self.addTabBar.userInteractionEnabled = NO;
    self.addTabBar.scrollEnabled = NO;
    
    CGRect bpFrame = totalFrame;
    bpFrame.origin.y = self.view.frame.size.height - bpFrame.size.height + 50;
    
    CGRect newActionFrame = CGRectAlign(self.actionView.frame, self.view.bounds, MysticAlignTypeBottom);
    newActionFrame.origin.y += 50;
    
    [self.view bringSubviewToFront:self.actionView];
    [self hideNavBar:YES duration:0.1 complete:nil];
    currentSetting = MysticSettingAddLayer;
    
    MysticAnimationBlockObject *animation = [MysticAnimationBlockObject animation];
    
    animation = [self hideBottomBarAnimation:animation];
    animation.animationOptions = UIViewAnimationCurveEaseIn;
    [weakSelf.addTabBar setNeedsDisplay:NO];
    
    MysticAnimationBlockObject *animation2 = [MysticAnimationBlockObject animation];
    animation2.animationType = MysticAnimationTypeSpring;
    animation2.duration = 0.45;
    animation2.delay = 0.15;
    [animation2 addAnimation:^{
        weakSelf.actionView.frame = newActionFrame;
        //        [weakSelf updateImageViewFrame:bpFrame navHidden:YES bottomHidden:NO animated:NO];
    } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
        weakSelf.addTabBar.userInteractionEnabled = YES;
        weakSelf.addTabBar.scrollEnabled = YES;
        [weakSelf.addTabBar setNeedsDisplay:NO];
        [weakSelf.tabBar removeFromSuperview];
        weakSelf.tabBar = nil;
        
    }];
    
    [animation startAnimation];
    [animation2 startAnimation];
    
    
    
}

- (void) hideAddTabBar;
{
    [self hideAddTabBar:YES showTabBar:YES updateImageViewFrame:YES];
}
- (void) hideAddTabBar:(BOOL)animated;
{
    [self hideAddTabBar:animated showTabBar:YES updateImageViewFrame:YES];
}
- (void) hideAddTabBar:(BOOL)animated showTabBar:(BOOL)showTabBar updateImageViewFrame:(BOOL)updateImageViewFrame;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    
    if(!weakSelf.tabBar && showTabBar) [weakSelf tabBar:nil];
    
    
    weakSelf.tabBar.userInteractionEnabled = NO;
    weakSelf.tabBar.scrollEnabled = NO;
    weakSelf.addTabBar.userInteractionEnabled = NO;
    weakSelf.addTabBar.scrollEnabled = NO;
    [weakSelf.tabBar resetAll];
    
    CGRect totalFrame = CGRectz(weakSelf.tabBar.frame);
    CGRect bpFrame = totalFrame;
    bpFrame.origin.y = weakSelf.view.frame.size.height - bpFrame.size.height;
    
    
    currentSetting = MysticSettingNone;
    [weakSelf hideActionView:animated animations:^{
        if(showTabBar)
        {
            weakSelf.tabBar.frame = totalFrame;
            weakSelf.bottomToolbar.frame = totalFrame;
        }
        weakSelf.bottomPanelView.frame = bpFrame;
        if(updateImageViewFrame) [weakSelf updateImageViewFrame:bpFrame];
    } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
        
        weakSelf.addTabBar.tabBarDelegate = nil;
        weakSelf.addTabBar = nil;
        weakSelf.tabBar.userInteractionEnabled = YES;
        weakSelf.tabBar.scrollEnabled = YES;
        

    }];
    
}
- (void) hideActionView:(BOOL)animated animations:(MysticBlock)animations complete:(MysticBlockAnimationComplete)complete;
{
    CGRect offframe = self.actionView.bounds;
    offframe.origin.y = self.view.frame.size.height;
    MysticBorderView *addTabView = (id)self.actionView;
    __unsafe_unretained __block MysticController *weakSelf = self;
    MysticAnimationBlockObject *animation = [MysticAnimationBlockObject animationWithDuration:0.25];
    animation.animationOptions = UIViewAnimationCurveEaseInOut;
    [animation addKeyOrAnimation:0 duration:0.25 animations:^{
        weakSelf.actionView.frame = offframe;
        
    }];
    [animation addKeyOrAnimation:0 duration:0.25 animations:animations];
    [animation addAnimationComplete:^(BOOL finished, MysticAnimationBlockObject *obj) {
        [weakSelf.actionView removeFromSuperview];
        weakSelf.actionView = nil;
    }];
    [animation addAnimationComplete:complete];
    [animation startAnimation];
    
}



#pragma mark - SKETCH tab bar delegate

- (void) sketchTabBar:(MysticTabBar *)tabBar selectedTab:(MysticTabButton *)item;
{
    if(!self.canvasController) return;
    switch (item.objectType) {
        case MysticSettingColorAndIntensity:
        {
            
            [self showColorInput:nil title:@"Color" color:self.canvasController.paintColor finished:^(UIColor *color, UIColor *selectedColor, CGPoint p, MysticThreshold threshold, int index, MysticInputView *input, BOOL finished) {
                if(finished) [MysticController controller].canvasController.paintColor = color;
            }];
            break;
        }
        case MysticSettingSketchEraser:
            if(item.selected)
            {
                [MysticTipViewManager hide:@"pickeraser" animated:NO];
                [self.canvasController showBrushPanel:item];
                return;
            }
            item.selected = YES;
            [MysticTipView tip:@"pickeraser" inView:self.view targetView:[self.layerPanelView.replacementTabBar tabForType:MysticSettingSketchEraser] hideAfter:4 delay:0 animated:YES];
            [self.canvasController setEraserTool:item];
            break;
        case MysticSettingSketchBrush:
            if(item.selected)
            {
                [MysticTipViewManager hide:@"pickbrush" animated:NO];
                [self.canvasController showBrushPanel:item];
                return;
            }

            item.selected = YES;
            [self.canvasController setBrushTool:item];

            break;
        case MysticSettingSketchLayers: [self.canvasController showLayers:item]; break;
        case MysticSettingSketchSettings: [self.canvasController showSettings:item]; break;
        default: break;
    }
}
#pragma mark - tab bar delegate




- (void) mysticTabBar:(MysticTabBar *)tabBar didSelectItem:(MysticTabButton *)item info:(id)userInfo;
{
    __unsafe_unretained __block MysticController *weakSelf = self;
    BOOL removeExtra = YES;
    BOOL updateTabBar = YES;
    [self hideUndoRedo:nil];
    switch (tabBar.tag)
    {
#pragma mark - tab bar SHAPE

        case MysticViewTypeTabBarShape:
        {
            NSString *title = nil;
            NSString *msg = nil;
            PackPotionOptionShape *option = self.transformOption ? (id)self.transformOption : [[MysticOptions current] option:MysticObjectTypeFont];
            MysticLayerShapeView *focusedLayer = self.shapesView.keyObjectLayer;
            BOOL pleaseSelectAlert = NO;
            BOOL showAsSelected = NO;
            BOOL hideMoreTools = ![tabBar isTabOfTypeSelected:MysticSettingShapeMove];
            tabBar.scrollEnabled = YES;
            switch (item.objectType) {
                case MysticSettingShapeAdd:
                {
                    [weakSelf.shapesController addNewOverlayAndMakeKeyObject:NO];
                    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    break;
                }
                case MysticSettingShapeAlign:
                {
                    showAsSelected = !item.selected;
                    hideMoreTools = YES;
                    if(self.extraView) break;
                    CGFloat h = 50;
                    CGSize iconSize = (CGSize){20,20};
                    
                    
                    MysticToggleButton *alignToButton = [MysticToggleButton buttonWithImage:nil target:nil sel:nil];
                    alignToButton.maxToggleState = MysticSettingAlignToArtboard;
                    alignToButton.minToggleState = MysticSettingAlignToKeyObject;
                    alignToButton.defaultToggleState = MysticSettingAlignToArtboard;
                    
                    alignToButton.iconColor = [UIColor color:MysticColorTypeTabIconActive];
                    alignToButton.iconColorType = MysticColorTypeTabIconActive;
                    alignToButton.contentMode = UIViewContentModeCenter;
                    [alignToButton setIconImage:[MysticImage image:@(MysticIconTypeAlignToArtboard) size:iconSize color:@(MysticColorTypeTabIconActive)] forState:MysticSettingAlignToArtboard];
                    [alignToButton setIconImage:[MysticImage image:@(MysticIconTypeAlignToSelection) size:iconSize color:@(MysticColorTypeTabIconActive)] forState:MysticSettingAlignToSelection];
                    [alignToButton setIconImage:[MysticImage image:@(MysticIconTypeAlignToKeyObject) size:iconSize color:@(MysticColorTypeTabIconActive)] forState:MysticSettingAlignToKeyObject];
                    
                    alignToButton.toggleState = weakSelf.shapesController.selectedLayers.count > 1 ? MysticSettingAlignToSelection : MysticSettingAlignToArtboard;
                    
                    CGFloat w = self.view.frame.size.width/7;
                    
                    NSArray *items = @[
                                       @{@"toolType": @(MysticToolTypeStatic),
                                         @"width":@(-10)},
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignLeft),
                                         @"icon": @(MysticIconTypeAlignGroupLeft),
                                         @"color": @(MysticColorTypeAuto),
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"width": @(w),
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignCenterHorizontal),
                                         @"icon": @(MysticIconTypeAlignGroupHorizontal),
                                         @"color": @(MysticColorTypeAuto),
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"width": @(w),
                                         
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignRight),
                                         @"icon": @(MysticIconTypeAlignGroupRight),
                                         @"color": @(MysticColorTypeAuto),
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"width": @(w),
                                         
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignTop),
                                         @"icon": @(MysticIconTypeAlignGroupTop),
                                         @"color": @(MysticColorTypeAuto),
                                         
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"width": @(w),
                                         
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignCenterVertical),
                                         @"icon": @(MysticIconTypeAlignGroupVertical),
                                         @"color": @(MysticColorTypeAuto),
                                         
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"width": @(w),
                                         
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignBottom),
                                         @"icon": @(MysticIconTypeAlignGroupBottom),
                                         @"color": @(MysticColorTypeAuto),
                                         
                                         @"iconSize": [NSValue valueWithCGSize:iconSize],
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         @"width": @(w),
                                         
                                         },
                                       @(MysticToolTypeFlexible),
                                       
                                       @{@"objectType": @(MysticSettingShapeAlignTo),
                                         @"view": alignToButton,
                                         @"tag": @(MysticViewTypeToggler),
                                         @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                         //                                         @"eventAdded": @YES,
                                         @"width": @(w),
                                         
                                         },
                                       @{@"toolType": @(MysticToolTypeStatic),
                                         @"width":@(-17)},
                                       
                                       ];
                    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:items delegate:self height:h];
                    toolbar.frame = (CGRect){0, weakSelf.layerPanelView.frame.origin.y -h, weakSelf.view.frame.size.width, h};
                    toolbar.backgroundColor = self.view.backgroundColor;
                    toolbar.delegate = self;
                    toolbar.tag = MysticViewTypeTabBarShapeAlign;
                    
                    
                    toolbar.hidden = NO;
                    toolbar.userInteractionEnabled = YES;
                    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                    [weakSelf.view addSubview:toolbar];
                    weakSelf.extraView = toolbar;
                    removeExtra = NO;
                    for (MysticTabButton *tab in tabBar.tabs) {
                        tab.enabled = [tab isEqual:item];
                    }
                    break;
                }
                case MysticSettingShapeDelete:
                {
                    NSArray *selectedLayers = weakSelf.shapesView.selectedLayers;
                    if(selectedLayers.count)
                    {
                        for (id layer in selectedLayers) {
                            [weakSelf.shapesController removeLayer:layer];
                        }
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Delete what?";
                        msg = @"Select the text you want to delete first";
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingShapeClone:
                {
                    NSArray *selectedLayers = weakSelf.shapesController.selectedLayers;
                    if(selectedLayers.count)
                    {
                        CGPoint offsetPoint = [weakSelf.shapesController offsetPointForLayer:selectedLayers];
                        NSMutableArray *clones = [NSMutableArray arrayWithCapacity:selectedLayers.count];
                        for (id layer in selectedLayers) {
                            [clones addObject:[weakSelf.shapesController duplicateLayer:layer option:nil animated:YES offset:offsetPoint]];
                        }
                        [weakSelf.shapesController selectLayers:clones];
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Clone what?";
                        msg = @"Select the shape you want to clone first";
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingShapeStyle:
                case MysticSettingShapeEdit:
                {
                    if(focusedLayer)
                    {
                        [weakSelf editLayerView:focusedLayer setting:item.objectType];
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Edit what?";
                        msg = @"Select the shape you want to edit first";
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingShapeColor:
                {
                    if(weakSelf.shapesController.selectedLayers.count)
                    {
                        [weakSelf showColorInput:focusedLayer.option title:nil color:focusedLayer.color colorSetting:MysticSettingFontColor colorChoice:MysticOptionColorTypeForeground colorOption:[(PackPotionOptionShape *)[focusedLayer option] colorOption] control:nil finished:^(UIColor *color,UIColor *c2, CGPoint p, MysticThreshold t, int i, MysticInputView *inputView, BOOL finished)
                         {
                             for (MysticLayerShapeView *layer in weakSelf.shapesController.selectedLayers) {
                                 layer.color = color;
                                 [layer redraw:NO];
                             }
                             [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                         }];
                        
                    
                    }
                    else
                    {
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingShapeMove:
                {
                    if(weakSelf.shapesController.selectedLayers.count)
                    {
                        showAsSelected = !item.selected;
                        hideMoreTools = NO;
                        
                        weakSelf.preventToolsFromBeingVisible = NO;
                        
                        if(showAsSelected)
                        {
                            __block MysticLayerShapeView *__layer = weakSelf.shapesController.keyObjectLayer;
                            __block PackPotionOptionShape *_option = option ? option : (id)__layer.option;
                            
                            [weakSelf showMoreTools];
                            weakSelf.moreToolsView.option = _option;
                            weakSelf.moreToolsView.hideControlsWhenDone = NO;
                            weakSelf.moreToolsView.onTransform = ^(MysticTransformButton *button, MysticToolsTransformType transformType, MysticTools *tools, BOOL finished)
                            {
                                if(!__layer) return;
                                
                                for (MysticLayerShapeView *_layer in weakSelf.shapesController.selectedLayers)
                                {
                                    MysticToolType toolType = MysticTransformTypeToToolType(transformType);
                                    
                                    switch (transformType)
                                    {
                                        case MysticToolsTransformRight:
                                        case MysticToolsTransformLeft:
                                        {
                                            CGFloat ax = [tools.currentOption increment:toolType];
                                            CGFloat ay = 0.0f;
                                            _layer.center = CGPointAdd(_layer.center, (CGPoint){ax,ay});
                                            break;
                                        }
                                        case MysticToolsTransformDown:
                                        case MysticToolsTransformUp:
                                        {
                                            CGFloat ay = [tools.currentOption increment:toolType];
                                            CGFloat ax = 0.0f;
                                            _layer.center = CGPointAdd(_layer.center, (CGPoint){ax,ay});
                                            break;
                                        }
                                        case MysticToolsTransformMinus:
                                        case MysticToolsTransformPlus:
                                        {
                                            [_layer transformSize:[tools.currentOption increment:toolType]];
                                            break;
                                        }
                                        case MysticToolsTransformFlipLandscape:
                                        {
                                            break;
                                        }
                                        case MysticToolsTransformFlipPortrait:
                                        {
                                            break;
                                        }
                                            
                                        case MysticToolsTransformRotateLeft:
                                        case MysticToolsTransformRotateRight:
                                        {
                                            CGFloat cr = [tools.currentOption increment:toolType];
                                            CGFloat angle = normalizedDegreesToRadians(cr);
                                            [_layer changeRotation:angle];
                                            break;
                                        }
                                        case MysticToolsTransformRotateClockwise:
                                        case MysticToolsTransformRotateCounterClockwise:
                                        {
                                            CGFloat rotationRadians= fromDegreesToRadians(_layer.rotation);
                                            CGFloat cr = [tools.currentOption increment:toolType];
                                            CGFloat cr2 = -1*cr;
                                            
                                            MysticPosition _rotatePosition = _layer.rotatePosition;
                                            if(_rotatePosition == MysticPositionUnknown)
                                            {
                                                if((rotationRadians <= 0 && rotationRadians > cr) || (rotationRadians >= cr2 *3 && rotationRadians < cr2*4))
                                                {
                                                    _rotatePosition = MysticPositionTop;
                                                }
                                                else if(rotationRadians >= 0 && rotationRadians < cr2)
                                                {
                                                    _rotatePosition = MysticPositionRight;
                                                }
                                                else if((rotationRadians <= cr && rotationRadians > cr*2) || (rotationRadians >= cr2*2 && rotationRadians < cr2*3))
                                                {
                                                    _rotatePosition = MysticPositionLeft;
                                                }
                                                else
                                                {
                                                    _rotatePosition = MysticPositionBottom;
                                                }
                                            }
                                            switch (_rotatePosition)
                                            {
                                                case MysticPositionTop:
                                                    _rotatePosition = MysticPositionLeft;
                                                    rotationRadians = cr;
                                                    break;
                                                case MysticPositionLeft:
                                                    _rotatePosition = MysticPositionBottom;
                                                    rotationRadians = cr * 2;
                                                    break;
                                                case MysticPositionBottom:
                                                    _rotatePosition = MysticPositionRight;
                                                    rotationRadians = cr * 3;
                                                    break;
                                                case MysticPositionRight:
                                                    _rotatePosition = MysticPositionTop;
                                                    rotationRadians = 0;
                                                    break;
                                                default:
                                                    break;
                                            }
                                            _layer.rotatePosition = _rotatePosition;
                                            _layer.rotation = normalizedDegreesToRadians(rotationRadians);
                                            break;
                                        }
                                        default:
                                            break;
                                    }
                                }
                            };
                            weakSelf.moreToolsView.toolHitInsets = MYSTIC_UI_TOOLS_HIT_INSET;
                            [weakSelf.moreToolsView setToolHitInsets:UIEdgeInsetsMake(6, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET) forType:MysticToolsTransformRotateLeft];
                            [weakSelf.moreToolsView setToolHitInsets:UIEdgeInsetsMake(6, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET) forType:MysticToolsTransformUp];
                            
                            [weakSelf.shapesController moveLayersToBackgroundExcept:weakSelf.shapesController.selectedLayers];
                            for (MysticLayerShapeView *layer in weakSelf.shapesView.selectedLayers) {
                                [layer hideControls:NO];
                                [layer setEnabledAndKeepSelection:NO];
                            }
                            
                            
                        }
                        else
                        {
                            [weakSelf hideMoreTools];
                            [weakSelf.shapesController moveLayersOutOfBackground];
                            for (MysticLayerShapeView *layer in weakSelf.shapesView.selectedLayers) {
                                [layer showControls:NO];
                                [layer setEnabledAndKeepSelection:YES];
                            }
                        }
                        if(weakSelf.shapesController.isGridHidden && showAsSelected)
                        {
                            weakSelf.shapesController.allowGridViewToHide = NO;
                            [weakSelf.shapesView showGrid:nil animated:YES force:YES];
                        }
                        else if(!showAsSelected)
                        {
                            weakSelf.shapesController.allowGridViewToHide = YES;
                            [weakSelf.shapesView hideGrid:nil animated:YES force:NO];
                        }
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Move what?";
                        msg = @"Select the text you want to move first";
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingShapeSelect:
                {
                    [weakSelf showNavViews:nil];
                    
                    if(item.selected)
                    {
                        [weakSelf.shapesView deselectLayersExcept:nil];
                    }
                    else
                    {
                        NSArray *selections = [weakSelf.shapesView selectAll];
                        showAsSelected = YES;
                    }
                    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    
                    break;
                }
                    
                default: break;
            }
            [item showAsSelected:showAsSelected];
            [tabBar setNeedsDisplay];
            
            
            if(hideMoreTools) [weakSelf hideMoreTools];
            if(pleaseSelectAlert) [MysticAlert notice:title ? title : @"Oops" message:msg ? msg : @"Select some text first."  action:nil options:nil];
            
            break;
        }
#pragma mark - tab bar FONT
            
        case MysticViewTypeTabBarFont:
        {
            NSString *title = nil;
            NSString *msg = nil;
            PackPotionOptionFont *option = self.transformOption ? (id)self.transformOption : [[MysticOptions current] option:MysticObjectTypeFont];
            MysticFontStyleViewBasic *selectedFontView = self.labelsView.keyObjectLayer;
            BOOL pleaseSelectAlert = NO;
            BOOL showAsSelected = NO;
            BOOL hideMoreTools = ![tabBar isTabOfTypeSelected:MysticSettingFontMove];
            tabBar.scrollEnabled = YES;
            switch (item.objectType) {
                case MysticSettingFontAdd:
                {
                    
                    [weakSelf.fontStylesController addNewOverlayAndMakeKeyObject:NO];
                    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    
                    break;
                }
                case MysticSettingFontDelete:
                {
                    
                    NSArray *selectedLayers = weakSelf.labelsView.selectedLayers;
                    if(selectedLayers.count)
                    {
                        for (id layer in selectedLayers) {
                            [weakSelf.labelsView removeLayer:layer];
                        }
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Delete what?";
                        msg = @"Select the text you want to delete first";
                        pleaseSelectAlert = YES;
                    }
                    
                    break;
                }
                case MysticSettingFontClone:
                {
                    
                    NSArray *selectedLayers = weakSelf.labelsView.selectedLayers;
                    if(selectedLayers.count)
                    {
                        CGPoint offsetPoint = [weakSelf.fontStylesController offsetPointForLayer:selectedLayers];
                        id <MysticLayerViewAbstract> clone;
                        NSMutableArray *clones = [NSMutableArray arrayWithCapacity:selectedLayers.count];
                        for (id layer in selectedLayers) {
                            clone = [weakSelf.fontStylesController duplicateLayer:layer option:nil animated:YES offset:offsetPoint];
                            [clones addObject:clone];
                        }
                        [weakSelf.fontStylesController selectLayers:clones];
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                        
                    }
                    else
                    {
                        title = @"Clone what?";
                        
                        msg = @"Select the text you want to clone first";
                        
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingFontStyle:
                case MysticSettingFontEdit:
                {
                    
                    if(selectedFontView)
                    {
                        [weakSelf editLayerView:(id)selectedFontView setting:item.objectType];
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                        
                    }
                    else
                    {
                        title = @"Edit what?";
                        
                        msg = @"Select the text you want to edit first";
                        
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingFontColor:
                {
                    
                    
                    if(weakSelf.labelsView.selectedLayers.count)
                    {
                        [weakSelf showColorInput:selectedFontView.option title:nil color:selectedFontView.color colorSetting:MysticSettingFontColor colorChoice:MysticOptionColorTypeForeground colorOption:selectedFontView.option.colorOption control:nil finished:^(UIColor *color,UIColor *c2, CGPoint p, MysticThreshold t, int i, MysticInputView *inputView, BOOL finished)
                         {
                             for (MysticLayerTypeView *layer in weakSelf.labelsView.selectedLayers) {
                                 layer.color = color;
                                 [layer redraw:NO];
                             }
                             [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                             
                             
                         }];
                    }
                    else
                    {
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingFontMove:
                {
                    if(weakSelf.labelsView.selectedLayers.count)
                    {
                        showAsSelected = !item.selected;
                        hideMoreTools = NO;
                        
                        weakSelf.preventToolsFromBeingVisible = NO;
                        
                        if(showAsSelected)
                        {
                            __block MysticFontStyleViewBasic *__layer = weakSelf.labelsView.keyObjectLayer;
                            __block PackPotionOptionFont *_option = option ? option : __layer.option;
                            
                            [weakSelf showMoreTools];
                            weakSelf.moreToolsView.option = _option;
                            weakSelf.moreToolsView.hideControlsWhenDone = NO;
                            weakSelf.moreToolsView.onTransform = ^(MysticTransformButton *button, MysticToolsTransformType transformType, MysticTools *tools, BOOL finished)
                            {
                                if(!__layer) return;
                                
                                for (MysticFontStyleViewBasic *_layer in weakSelf.labelsView.selectedLayers)
                                {
                                    MysticToolType toolType = MysticTransformTypeToToolType(transformType);
                                    
                                    switch (transformType)
                                    {
                                        case MysticToolsTransformRight:
                                        case MysticToolsTransformLeft:
                                        {
                                            CGFloat ax = [tools.currentOption increment:toolType];
                                            CGFloat ay = 0.0f;
                                            
                                            CGPoint newCenter = _layer.center;
                                            newCenter.x += ax;
                                            newCenter.y += ay;
                                            
                                            _layer.center = newCenter;
                                            break;
                                        }
                                        case MysticToolsTransformDown:
                                        case MysticToolsTransformUp:
                                        {
                                            CGFloat ay = [tools.currentOption increment:toolType];
                                            CGFloat ax = 0.0f;
                                            
                                            CGPoint newCenter = _layer.center;
                                            newCenter.x += ax;
                                            newCenter.y += ay;
                                            
                                            _layer.center = newCenter;
                                            
                                            break;
                                        }
                                        case MysticToolsTransformMinus:
                                        case MysticToolsTransformPlus:
                                        {
                                            
                                            [_layer transformSize:[tools.currentOption increment:toolType]];
                                            break;
                                        }
                                            
                                        case MysticToolsTransformFlipLandscape:
                                        {
                                            break;
                                        }
                                        case MysticToolsTransformFlipPortrait:
                                        {
                                            break;
                                        }
                                            
                                        case MysticToolsTransformRotateLeft:
                                        case MysticToolsTransformRotateRight:
                                        {
                                            CGFloat cr = [tools.currentOption increment:toolType];
                                            CGFloat angle = normalizedDegreesToRadians(cr);
                                            
                                            [_layer changeRotation:angle];
                                            
                                            break;
                                        }
                                        case MysticToolsTransformRotateClockwise:
                                        case MysticToolsTransformRotateCounterClockwise:
                                        {
                                            CGFloat rotationRadians= fromDegreesToRadians(_layer.rotation);
                                            CGFloat cr = [tools.currentOption increment:toolType];
                                            CGFloat cr2 = -1*cr;
                                            
                                            MysticPosition _rotatePosition = _layer.rotatePosition;
                                            if(_rotatePosition == MysticPositionUnknown)
                                            {
                                                if((rotationRadians <= 0 && rotationRadians > cr) || (rotationRadians >= cr2 *3 && rotationRadians < cr2*4))
                                                {
                                                    _rotatePosition = MysticPositionTop;
                                                    
                                                }
                                                else if(rotationRadians >= 0 && rotationRadians < cr2)
                                                {
                                                    _rotatePosition = MysticPositionRight;
                                                }
                                                else if((rotationRadians <= cr && rotationRadians > cr*2) || (rotationRadians >= cr2*2 && rotationRadians < cr2*3))
                                                {
                                                    _rotatePosition = MysticPositionLeft;
                                                    
                                                }
                                                else
                                                {
                                                    _rotatePosition = MysticPositionBottom;
                                                }
                                            }
                                            switch (_rotatePosition)
                                            {
                                                case MysticPositionTop:
                                                    _rotatePosition = MysticPositionLeft;
                                                    rotationRadians = cr;
                                                    break;
                                                case MysticPositionLeft:
                                                    _rotatePosition = MysticPositionBottom;
                                                    rotationRadians = cr * 2;
                                                    break;
                                                case MysticPositionBottom:
                                                    _rotatePosition = MysticPositionRight;
                                                    rotationRadians = cr * 3;
                                                    break;
                                                case MysticPositionRight:
                                                    _rotatePosition = MysticPositionTop;
                                                    rotationRadians = 0;
                                                    break;
                                                default:
                                                    break;
                                            }
                                            _layer.rotatePosition = _rotatePosition;
                                            _layer.rotation = normalizedDegreesToRadians(rotationRadians);
                                            break;
                                        }
                                        default:
                                            break;
                                    }
                                }
                            };
                            weakSelf.moreToolsView.toolHitInsets = MYSTIC_UI_TOOLS_HIT_INSET;
                            [weakSelf.moreToolsView setToolHitInsets:UIEdgeInsetsMake(6, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET) forType:MysticToolsTransformRotateLeft];
                            [weakSelf.moreToolsView setToolHitInsets:UIEdgeInsetsMake(6, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET, MYSTIC_UI_TOOLS_HIT_INSET) forType:MysticToolsTransformUp];
                            
                            [weakSelf.fontStylesController moveLayersToBackgroundExcept:weakSelf.labelsView.selectedLayers];
                            for (MysticLayerTypeView *layerTypeView in weakSelf.labelsView.selectedLayers) {
                                [layerTypeView hideControls:NO];
                                [layerTypeView setEnabledAndKeepSelection:NO];
                            }
                            
                            
                        }
                        else
                        {
                            [weakSelf hideMoreTools];
                            [weakSelf.fontStylesController moveLayersOutOfBackground];
                            for (MysticLayerTypeView *layerTypeView in weakSelf.labelsView.selectedLayers) {
                                [layerTypeView showControls:NO];
                                [layerTypeView setEnabledAndKeepSelection:YES];
                            }
                        }
                        if(weakSelf.fontStylesController.isGridHidden && showAsSelected)
                        {
                            weakSelf.fontStylesController.allowGridViewToHide = NO;
                            [weakSelf.labelsView showGrid:nil animated:YES force:YES];
                        }
                        else if(!showAsSelected)
                        {
                            
                            weakSelf.fontStylesController.allowGridViewToHide = YES;
                            [weakSelf.labelsView hideGrid:nil animated:YES force:NO];
                        }
                        [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    }
                    else
                    {
                        title = @"Move what?";
                        msg = @"Select the text you want to move first";
                        pleaseSelectAlert = YES;
                    }
                    break;
                }
                case MysticSettingFontSelect:
                {
                    [weakSelf showNavViews:nil];
                    
                    if(item.selected)
                    {
                        [weakSelf.labelsView deselectLayersExcept:nil];
                    }
                    else
                    {
                        NSArray *selections = [weakSelf.labelsView selectAll];
                        showAsSelected = YES;
                    }
                    [weakSelf.layerPanelView.replacementTabBar setContentOffset:CGPointZero animated:YES];
                    
                    break;
                }
                    
                default: break;
            }
            [item showAsSelected:showAsSelected];
            [tabBar setNeedsDisplay];
            
            
            if(hideMoreTools)
            {
                [weakSelf hideMoreTools];
            }
            
            if(pleaseSelectAlert)
            {
                [MysticAlert notice:title ? title : @"Oops" message:msg ? msg : @"Select some text first."  action:nil options:nil];
            }
            break;
        }
        case MysticViewTypeTabBarPanel:
        {
            break;
        }
#pragma mark - tab bar ADD LAYER

        case MysticViewTypeTabBarAddLayer:
        {
            MysticLayoutStyle layoutStyle = MysticLayoutStyleList;
            MysticObjectSelectionType selectionType = MysticObjectSelectionTypePack;
            [MysticLog answer:@"Tab-Add" info:@{@"type":MysticObjectTypeTitleParent(item.objectType, MysticObjectTypeUnknown)}];

            switch (item.objectType) {
                    
                case MysticSettingDesign:
                case MysticSettingText:
                case MysticObjectTypeDesign:
                case MysticObjectTypeText:
                {
                    layoutStyle = MysticLayoutStyleList;
                    break;
                }
                case MysticObjectTypeBadge:
                case MysticSettingBadge:
                {
                    layoutStyle = MysticLayoutStyleGrid;
                    selectionType = MysticObjectSelectionTypeOption;
                    break;
                }
                case MysticSettingFilter:
                case MysticObjectTypeFilter:
                case MysticObjectTypeColorOverlay:
                {
                    NSMutableDictionary *unfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                    [unfo setObject:@YES forKey:@"createNewObject"];
                    [unfo setObject:@YES forKey:@"refreshState"];
                    [unfo removeObjectForKey:@"object"];
                    self.currentOption = nil;
                    [self hideAddTabBar:YES];                    
                    [self setStateConfirmed:MysticSettingForObjectType(item.objectType) animated:YES info:unfo complete:nil];
                    return;
                    
                }
                case MysticObjectTypeCustom:
                case MysticObjectTypeImage:
                case MysticObjectTypeCamLayer:
                {
                    currentSetting = item.objectType;
                    self.currentOption = nil;
                    UIImage *imageInClipboard = [UIPasteboard generalPasteboard].image;
                    
                    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
                    actionSheet.cancelButtonTitle = @"CANCEL";
                    actionSheet.title = @"ADD PHOTO FROM";
//                    actionSheet.cancelButtonImage = [MysticImageIcon image:@(MysticIconTypeToolHide) size:(CGSize){10, 6} color:[UIColor hex:@"6C5F58"]];
//                    actionSheet.cancelButtonImageHighlighted = [MysticImageIcon image:@(MysticIconTypeToolHide) size:(CGSize){10, 6} color:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]];
                    actionSheet.cancelOnTapEmptyAreaEnabled = @YES;
                    actionSheet.blurTintColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.65];
                    actionSheet.blurRadius = 20.0f;
                    actionSheet.buttonHeight = 66.0f;
                    actionSheet.titleHeight = 34;
                    actionSheet.cancelButtonHeight = 66.0f;
                    actionSheet.buttonTextCenteringEnabled = @YES;
                    actionSheet.animationDuration = 0.25f;
                    actionSheet.buttonBackgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.65];
                    actionSheet.cancelButtonBackgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.65];
                    actionSheet.separatorColor = [UIColor colorWithRed:0.19 green:0.19 blue:0.19 alpha:1];
                    actionSheet.selectedBackgroundColor = [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00];
                    UIFont *defaultFont = [MysticFont gotham:12.0f];
                    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                        NSKernAttributeName: @(3.0),
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1.00] };
                    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                                NSForegroundColorAttributeName : [UIColor grayColor] };
                    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : [MysticFont gothamMedium:11.0f],
                                                              NSKernAttributeName: @(3.0),
                                                              NSForegroundColorAttributeName : [UIColor colorWithRed:0.87 green:0.26 blue:0.28 alpha:1.00] };
                    NSMutableParagraphStyle *paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
                    paragraph.alignment = NSTextAlignmentCenter;
                    actionSheet.titleTextAttributes = @{ NSFontAttributeName : [MysticFont gothamMedium:10.0f],
                                                         NSKernAttributeName: @(2.0),
                                                         NSParagraphStyleAttributeName: paragraph,
                                                         NSForegroundColorAttributeName : [UIColor colorWithRed:0.42 green:0.37 blue:0.35 alpha:1.00] };
     
                    [actionSheet addButtonWithTitle:NSLocalizedString(@"CAMERA", @"CAMERA") type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
                        [[MysticController controller] cameraButtonTouched:(id)sender];
                    }];
                    [actionSheet addButtonWithTitle:NSLocalizedString(@"PHOTO LIBRARY", @"PHOTO LIBRARY") type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
                        [[MysticController controller] albumButtonTouched:(id)sender];
                    }];
                    if(imageInClipboard)
                    {
                        [actionSheet addButtonWithTitle:NSLocalizedString(@"PASTE", @"PASTE") type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
                            [[MysticController controller] pasteNewLayer:(id)sender];
                        }];
                    }
//                    UIActionSheet *actionSheet = imageInClipboard ? [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Photo Library", @"Paste Image", nil] autorelease] : [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Photo Library", nil] autorelease];
//                    actionSheet.tintColor = [UIColor color:MysticColorTypePink];
                    actionSheet.tag = MysticViewTypeLayers;
                    [actionSheet show];
                    return;
                }
                case MysticObjectTypeSketch:
                {
                    if(!MysticTypeHasPack(item.objectType))
                    {
                        NSMutableDictionary *unfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                        [unfo setObject:@YES forKey:@"createNewObject"];
                        [unfo setObject:@YES forKey:@"refreshState"];
                        [unfo removeObjectForKey:@"object"];
                        self.currentOption = nil;
                        [self setStateConfirmed:MysticSettingForObjectType(item.objectType) animated:YES info:unfo complete:nil];
                        [self hideAddTabBar:YES showTabBar:YES updateImageViewFrame:NO];

                        
                    }
                    return;
                }
                default:
                {
                    if(!MysticTypeHasPack(item.objectType))
                    {
                        NSMutableDictionary *unfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                        [unfo setObject:@YES forKey:@"createNewObject"];
                        [unfo setObject:@YES forKey:@"refreshState"];
                        [unfo removeObjectForKey:@"object"];
                        self.currentOption = nil;
                        [self hideAddTabBar:YES];
                        [self setStateConfirmed:MysticSettingForObjectType(item.objectType) animated:YES info:unfo complete:nil];
                        return;
                    }
                    break;
                }
            }
            self.navLeftView = nil;
            self.navRightView = nil;
        
            [self hideAddTabBar:NO];
            NSArray *packs = [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(item.objectType)|MysticOptionTypeShowFeaturedPack];
            MysticPack *pack = packs && packs.count ? [packs objectAtIndex:0] : nil;
            if(!pack) return;
            [self chosePack:packs createNew:YES];
            break;
        }
        default:
        {
            BOOL changeState = YES;
            switch (item.tag)
            {
                case MysticButtonTypeAddLayer:
                {
                    
                    [self stateAnim:MysticSettingAddLayer animate:nil info:nil complete:nil];
                    break;
                }
                
                default:
                {
                    switch (item.objectType) {
                        case MysticSettingMenu:
                        {
                            [self backButtonTouched:nil];
                            [tabBar resetAll];
                            break;
                        }
                        case MysticSettingAdjustColor:
                        {
                            [weakSelf hideUndoRedo:nil];
                            [MysticOptions current].originalTag = [MysticOptions current].tag;

                            changeState = NO;
                            
                            BOOL reloadImage = YES;

                            PackPotionOptionSetting *targetOption=nil;
                            __unsafe_unretained __block MysticTabButton *_item = [item retain];
                            MysticWait(0.1, ^{
                                _item.selected = NO;
                                _item.highlighted = NO;
                            });
                            
                            targetOption = (id)[MysticOptions makeOption:MysticObjectTypeSourceSetting userInfo:nil];
                            targetOption.hasRendered = NO;
                            self.currentOption = targetOption;
                            self.transformOption = targetOption;

                            [weakSelf reloadImage:NO settings:MysticRenderOptionsForceProcess|MysticRenderOptionsSetupRender complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                                weakSelf.preventToolsFromBeingVisible = YES;
                                
                                weakSelf.transformOption.refreshState = MysticSettingAdjustColor;
                                [weakSelf showColorInput:targetOption title:@"ADJUST" color:nil init:^(MysticInputView *input)
                                 {
                                     input.allowEyeDropper=YES;
                                     input.showHexValues=NO;
                                     input.showRemoveButton=YES;
                                     input.showColorTools=YES;
                                     input.showColors=NO;
                                     input.showNewButton = YES;
                                     input.showToolbarBorder=NO;
                                     input.colorPickerMode = ColorPickerModeTone;
                                     input.selectedColorTitle = @"PICK A COLOR";
                                     input.selectedColorWithColorTitle = @"ADJUST";
                                     input.update = ^(UIColor *obj, UIColor *selectedColor, CGPoint p, MysticThreshold threshold, int index,  MysticInputView *input, BOOL finished)
                                     {
                                         MysticAdjustColorInfo info = (MysticAdjustColorInfo){NSNotFound,NO};
                                         if(CGPointIsUnknown(p)) {
                                             MysticPointColorBtn *b = [[MysticController controller] colorButtonAtIndex:input.selectedColorIndex];
                                             if(b) p = b.point;
                                         }
                                         if(obj) info = [input.targetOption adjustColor:selectedColor toColor:obj intensity:obj.alpha point:p threshold:threshold index:index];
                                         if(!finished || info.added) return;
                                         [input.targetOption setupFilter:nil];
                                         if(!tabrendering && !tabrefreshing && [MysticController controller].readyForRenderEngine)
                                         {
                                             tabrefreshing = YES;
                                             [MysticEffectsManager refresh:input.targetOption completion:^{
                                                 tabrendering = NO;
                                                 tabrefreshing=NO;
                                             }];
                                         }
                                     };
                                     
                                 } finished:^(UIColor *obj, UIColor *selectedColor, CGPoint p0, MysticThreshold threshold, int index,  MysticInputView *input, BOOL finished) {
                                     MysticAdjustColorInfo info = (MysticAdjustColorInfo){NSNotFound,NO};
                                     if(CGPointIsUnknown(p0)) { MysticPointColorBtn *b = [[MysticController controller] colorButtonAtIndex:input.selectedColorIndex]; p0 = b ? b.point : p0; }
                                     if(obj) info = [input.targetOption adjustColor:selectedColor toColor:obj intensity:obj.alpha point:p0 threshold:threshold index:index];
                                     input.selectedColorIndex=info.index;
                                     input.targetOption.hasChanged = YES;
                                     [input.targetOption setupFilter:nil];
                                     //                                        DLog(@"info: %@   %ld   finished: %@   render: %@  refresh: %@  ready: %@", MBOOL(info.added), (long)info.index, MBOOL(finished), MBOOL(tabrendering), MBOOL(tabrefreshing), MBOOL([MysticController controller].readyForRenderEngine));
                                     if(!tabrendering && !tabrefreshing && [MysticController controller].readyForRenderEngine)
                                     {
                                         if(!info.added && !finished){
                                             
                                             //                                                DLog(@"refreshing....");
                                             tabrefreshing=YES;
                                             
                                             [MysticEffectsManager refresh:input.targetOption completion:^{
                                                 tabrendering = NO;
                                                 tabrefreshing=NO;
                                                 
                                             }];
                                         }
                                         else {
                                             __unsafe_unretained __block MysticInputView *_in = input ? [input retain] : nil;
                                             //                                                                        DLogRender(@"rendering....");
                                             tabrendering = NO;
                                             tabrefreshing=NO;
                                             weakSelf.transformOption.hasRendered = NO;
                                             weakSelf.transformOption.hasChanged = YES;
                                             [MysticOptions current].hasChanged = YES;
                                             
                                             
                                             
                                             [[MysticOptions current] setHasChanged:YES changeOptions:NO];
                                             [[MysticOptions current] enable:MysticRenderOptionsSource];
                                             [[MysticOptions current] enable:MysticRenderOptionsSaveImageOutput];
                                             [[MysticOptions current] enable:MysticRenderOptionsForceProcess];
                                             [[MysticOptions current] enable:MysticRenderOptionsRebuildBuffer];
                                             [[MysticOptions current] enable:MysticRenderOptionsSaveState];
                                             
                                             
                                             
                                             
                                             [MysticOptions current].tag = nil;
                                             [[MysticOptions current] saveProject];
                                             MysticObjectType gestureState= weakSelf.currentSetting;
                                             
                                             
//                                             [weakSelf removeExtraControls];
                                             
                                             __unsafe_unretained __block PackPotionOption *transOption = [weakSelf.transformOption retain];
                                             [weakSelf.overlayView setupGestures:gestureState disable:NO];
                                             weakSelf.transformOption = nil;
                                             [weakSelf reloadImageWithMsg:@"Saving" placeholder:nil hudDelay:0.2 settings:[MysticOptions current].settings complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
                                                 
                                                 tabrendering = NO;
                                                 tabrefreshing=NO;
                                                 
//                                                 transOption.hasRendered = NO;
//                                                 weakSelf.transformOption = [transOption autorelease];
                                                 [MysticOptions current].needsRender = YES;
                                                 [MysticOptions current].hasChanged = YES;
//                                                 [weakSelf confirmedOption:weakSelf.transformOption object:nil finished:nil];
                                                 
                                                 
                                                 [UserPotion confirmOption:weakSelf.transformOption];
                                                 [UserPotion confirmed];
                                                 [[MysticOptions current] saveProject];
                                                 
                                                 
                                                 weakSelf.transformOption = nil;
                                                 [MysticOptions current].tag = nil;
                                                 
                                                 MysticAnimationBlockObject *animation = [weakSelf stateAnim:MysticSettingNoneFromConfirm animate:nil info:nil complete:nil];
                                                 [animation animate:nil];
                                                 
                                                 
                                                 [_in autorelease];

                                             }];
                                             
                                             
                                             
                                             
//                                             [[MysticController controller] render:NO atSourceSize:YES complete:^(UIImage *i, id n, id o, BOOL c) {
//                                                 //                        [MysticEffectsManager refresh:_in.targetOption];
//                                                 
//                                                 weakSelf.transformOption.hasRendered = NO;
//                                                 weakSelf.transformOption.hasChanged = YES;
//                                                 [MysticOptions current].hasChanged = YES;
//                                                 
//                                             }];
                                             
                                             
                                             
                                         }
                                     }
                                     if(!finished) return;
                                     _item.selected = NO;
                                     _item.highlighted = NO;
                                     [_item release];
                                 }];
                                
                            }];
                            targetOption.hasChanged = NO;

                            
                            
                            
                            
                            break;
                        }
                        case MysticObjectTypeText:
                        {
                            changeState = NO;
                            self.navLeftView = nil;
                            self.navRightView = nil;
                            
                            [self hideAddTabBar:NO];
                            NSArray *packs = [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(item.objectType)|MysticOptionTypeShowFeaturedPack];
                            MysticPack *pack = packs && packs.count ? [packs objectAtIndex:0] : nil;
                            if(!pack) return;
                            [self chosePack:packs createNew:YES];
                            
                            break;
                        }
                        default:  break;
                    }
#ifndef MYSTIC_START_STATE
                    if(!self.tappedFirstTab) [MysticLog answer:@"Tab-First" info:@{@"type":MysticObjectTypeTitleParent(item.objectType, MysticObjectTypeUnknown)}];
#endif
                    [MysticLog answer:@"Tab" info:@{@"type":MysticObjectTypeTitleParent(item.objectType, MysticObjectTypeUnknown)}];

                    if(changeState)
                    {

                        [self setStateConfirmed:MysticSettingForObjectType(item.objectType) animated:YES info:userInfo complete:nil];
                    }
                    break;
                }
            }
            break;
        }
    }
    if(self.extraView && removeExtra)
    {
        [self.extraView removeFromSuperview];
        self.extraView=nil;
    }
}

- (BOOL) mysticTabBar:(MysticTabBar *)tabBar isItemActive:(MysticTabButton *)item;
{
    switch (tabBar.tag)
    {
        case MysticViewTypeTabBarFont:
        case MysticViewTypeTabBarShape:
        {
            switch (item.objectType) {
                case MysticSettingFontAlign:
                case MysticSettingShapeAlign:
                    return (self.extraView == nil && item.selected) || (self.extraView && item.selected);
                case MysticSettingShapeMove:
                case MysticSettingFontMove:
                    return (BOOL)(self.moreToolsView != nil);
                default: break;
            }
            break;
        }
        default: break;
    }
    return NO;
}


- (void) tabBarDidScroll:(MysticTabBar *)tabBar;
{
    
}


- (void) moveTabBarToDefaultState:(MysticTabBar *)tabBar animated:(BOOL)animated;
{
    [tabBar setContentOffset:CGPointZero animated:animated duration:-1 delay:0 curve:0 animations:nil complete:^(id scrollview) {
        [(MysticTabBar *)scrollview resetAll];
        
    }];
}
#pragma mark - Sketch View
- (void) generateBlendingImages;
{
    NSArray *names = @[@"kCGBlendModeNormal", @"kCGBlendModeMultiply", @"kCGBlendModeScreen", @"kCGBlendModeOverlay", @"kCGBlendModeDarken", @"kCGBlendModeLighten", @"kCGBlendModeColorDodge", @"kCGBlendModeColorBurn", @"kCGBlendModeSoftLight", @"kCGBlendModeHardLight", @"kCGBlendModeDifference", @"kCGBlendModeExclusion", @"kCGBlendModeHue", @"kCGBlendModeSaturation", @"kCGBlendModeColor", @"kCGBlendModeLuminosity", @"kCGBlendModeClear", @"kCGBlendModeCopy", @"kCGBlendModeSourceIn", @"kCGBlendModeSourceOut", @"kCGBlendModeSourceAtop", @"kCGBlendModeDestinationOver", @"kCGBlendModeDestinationIn", @"kCGBlendModeDestinationOut", @"kCGBlendModeDestinationAtop", @"kCGBlendModeXOR", @"kCGBlendModePlusDarker", @"kCGBlendModePlusLighter"];
    
    CGRect rect = CGRectMake(0, 0, 100, 100);
    UIBezierPath *shape1 = [UIBezierPath bezierPathWithOvalInRect:rect];
    rect.origin.x += 50;
    UIBezierPath *shape2 = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    for (int i = kCGBlendModeNormal; i <= kCGBlendModePlusLighter; i++)
    {
        NSString *name = [names[i - kCGBlendModeNormal] stringByAppendingPathExtension:@"png"];
        UIGraphicsBeginImageContext(CGSizeMake(150, 100));
        
        [UIColor.greenColor set];
        [shape1 fill];
        
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), i);
        
        [UIColor.purpleColor set];
        [shape2 fill];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        NSData *data = UIImagePNGRepresentation(image);
        NSError *error = nil;
        [data writeToFile:[[MysticCache cache:MysticCacheTypeTemp] cachePathForKey:name]  options:NSDataWritingAtomic error:&error];
        UIGraphicsEndImageContext();
        name = [[names[i - kCGBlendModeNormal] stringByAppendingString:@"_alpha"] stringByAppendingPathExtension:@"png"];
        UIGraphicsBeginImageContext(CGSizeMake(150, 100));
        [UIColor.greenColor set];
        [shape1 fill];
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), i);
        [[UIColor.purpleColor colorWithAlphaComponent:0.5] set];
        [shape2 fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        data = UIImagePNGRepresentation(image);
        error = nil;
        [data writeToFile:[[MysticCache cache:MysticCacheTypeTemp] cachePathForKey:name]  options:NSDataWritingAtomic error:&error];
        UIGraphicsEndImageContext();
        
    }
}

- (void) showSketchView:(MysticSketchToolType)type;
{
    BOOL reloadImage = NO;
    if(!_sketchView || !_sketchView.superview)
    {
        if(_sketchView)
        {
            [_sketchView removeFromSuperview];
            [_sketchView release], _sketchView=nil;
        }
        switch (type) {
            case MysticSketchToolTypeMask:
            case MysticSketchToolTypeMaskErase: {
                CGRect r = self.imageView.originalImageViewFrame;
                CGSize newSize = [MysticEffectsManager sizeForSettings:MysticRenderOptionsSource];
                r.size = CGSizeMax(r.size, CGSizeScale(newSize, 1/[Mystic scale]));
                r.origin = CGPointZero;
                self.sketchView = [[CanvasMaskView alloc] initWithFrame:r];
                CGFloat s = self.imageView.originalImageViewFrame.size.width/r.size.width;
                self.sketchView.transform = CGAffineTransformMakeScale(s, s);
                if(self.transformOption.hasMaskImage) self.sketchView.image = self.transformOption.maskImage;
                break;
            }
            default: self.sketchView = (CanvasMaskView *)[[CanvasMaskView alloc] initWithFrame:self.imageView.originalImageViewFrame]; break;
        }
        self.sketchView.hidden = YES;
        self.sketchView.userInteractionEnabled=YES;
        reloadImage = YES;
        [self.imageView addView:self.sketchView];
        [self.imageView destroyRenderImageView];
        [self.imageView destroyPlaceholderImageView];
        [self.imageView.scrollView resetPosition:YES];
      
    }
    else self.sketchView.hidden = YES;
    
    if(self.transformOption)
    {
        self.sketchView.lineOpacity = self.transformOption.maskBrush.opacity;
        self.sketchView.lineFeather = self.transformOption.maskBrush.feather;
        self.sketchView.lineScale = self.transformOption.maskBrush.size;
        
    }
    if([MysticUser get:@"maskPanelBrushSize"]!=nil) self.sketchView.lineScale = [MysticUser getf:@"maskPanelBrushSize"];
    if([MysticUser get:@"maskPanelBrushOpacity"]!=nil) self.sketchView.lineOpacity = [MysticUser getf:@"maskPanelBrushOpacity"];
    if([MysticUser get:@"maskPanelBrushFeather"]!=nil) self.sketchView.lineFeather = [MysticUser getf:@"maskPanelBrushFeather"];
    
    self.sketchView.toolType = (NSInteger)type;
    switch (type) {
        case MysticSketchToolTypeMaskErase:
        case MysticSketchToolTypeMask:
            self.sketchView.backgroundImage = [UserPotion potion].sourceImageResized;
            self.sketchView.backgroundColor = [UIColor clearColor];
            break;
        default:
            self.sketchView.backgroundColor = [UIColor clearColor];
            self.sketchView.color = [self.transformOption color:MysticOptionColorTypeForeground];
            break;
    }
    [self updateTransformViews];
    self.sketchView.updated = ^(UIImage *img, NSString *tag, CanvasMaskView *c) {
        [UserPotionManager setImage:img tag:[[tag prefix:@"-mask--"] prefix:[UserPotion potion].tag]]; };
    if(reloadImage)
    {
        BOOL hasMask = self.transformOption.hasMaskImage;
        UIImage *maskImage = hasMask ? [self.transformOption.maskImage retain] : nil;
        if(hasMask) self.transformOption.maskImage = nil;
        __unsafe_unretained __block MysticController *weakSelf = self;
        [self renderWhenReady:YES atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {

            if(![obj isKindOfClass:[NSString class]] || !image) { DLogError(@"sketch error:  %@    %@", obj, ILogStr(image)); return; }
            weakSelf.sketchView.foregroundImage=image;
            weakSelf.sketchView.hidden=NO;
            weakSelf.imageView.debugColor = [UIColor cyanColor];
            if(!hasMask || !maskImage) return;
            weakSelf.sketchView.layerMaskImage = [maskImage autorelease];
        }];
    }
    else self.sketchView.hidden=NO;

}
- (void) hideSketchView;
{
    mdispatch(^{
        if(_sketchView) { [self.sketchView removeFromSuperview]; self.sketchView = nil; }
        [self.overlayView setupGestures:self.currentSetting];
    });
}
- (void) sketchImageIsDone;
{
    __unsafe_unretained __block MysticController *weakSelf = self;

    [self.transformOption setMaskImage:self.sketchView.layerMaskImage complete:^{
        [weakSelf renderWhenReady:YES atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
            [weakSelf hideSketchView];
            weakSelf.imageView.debugColor = nil;
        }];
    }];
    
    
    
}
- (UIImage *) getSketchImage;
{
    return self.sketchView.image;
}

#pragma mark - Open Photo Or Library

- (void)cameraButtonTouched:(MysticButton *)sender
{
    if(sender) sender.enabled = NO;
    __unsafe_unretained __block  MysticController *weakSelf = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypeCameraOrPhotoLibrary complete:nil];
    }
    else
    {
        [MysticAlert notice:@"No Camera" message:@"Your device doesn't have a camera, so you'll have to choose a photo from your album instead." action:^(id object, id o2) {
            [weakSelf albumButtonTouched:sender];
        } options:@{@"button":@"Choose Photo"}];
    }
}
- (void)albumButtonTouched:(MysticButton *)sender
{
    if(sender) sender.enabled = NO;
    [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypePhotoLibrary complete:^{
        
    }];
    
}


- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
{
//    @autoreleasepool {
        MysticPickerViewController *picker ;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController" owner:nil options:nil] lastObject];
        } else {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController_iPad" owner:nil options:nil] lastObject];
        }
        [picker setupWithSource:sourceType];
        picker.sourceType = sourceType;
        picker.imagePickerDelegate = (delegate ? delegate : self);
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        UIViewController *p = [picker present:picker.sourceType viewController:picker animated:NO finished:nil];
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            __unsafe_unretained __block  MysticPickerViewController *weakPicker = picker;
            [self.navigationController presentViewController:picker animated:animated completion:^{
                [weakPicker viewDidPresent:animated];
                if(finished) finished();
            }];
        }
        else
        {
            [self presentModalViewController:picker animated:animated];
            [picker viewDidPresent:animated];
            if(finished) finished();
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
//    }
}
- (void) closeCam:(void (^)())finished;
{
//    @autoreleasepool {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        __unsafe_unretained __block  MysticPickerViewController *picker = nil;
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            picker = (MysticPickerViewController *)self.presentedViewController;
            self.customImagePicker = picker;
            __unsafe_unretained __block MysticBlock __f = finished ? Block_copy(finished) : nil;
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                if(__f) {
                    __f();
                    Block_release(__f);
                }
                self.customImagePicker = nil;
            }];
        }
        else
        {
            picker = (MysticPickerViewController *)self.modalViewController;
            [self dismissModalViewControllerAnimated:YES];
            if(finished) finished();
        }
//    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo
{
    [self imagePickerController:picker didFinishPickingMediaWithInfo:returnInfo finished:nil];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo finished:(MysticBlockObject)finishedBlock;
{
    if(!returnInfo) { [self imagePickerControllerDidCancel:picker]; return; }
    if([picker respondsToSelector:@selector(imagePickerDelegate)])
    {
        [(MysticPickerViewController *)picker setImagePickerDelegate:nil];
        [(MysticPickerViewController *)picker setDelegate:nil];
    }
    NSArray *info = nil;
    if([returnInfo isKindOfClass:[NSDictionary class]]) info = [NSArray arrayWithObject:returnInfo];
    else if([returnInfo isKindOfClass:[NSArray class]]) info = (NSArray *)returnInfo;
    [self addCustomLayer:nil image:[[info lastObject] objectForKey:UIImagePickerControllerEditedImage] ? [[info lastObject] objectForKey:UIImagePickerControllerEditedImage] : [[info lastObject] objectForKey:UIImagePickerControllerOriginalImage]];
    [self closeCam:nil];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([picker respondsToSelector:@selector(imagePickerDelegate)])
    {
        MysticPickerViewController *pp = (id)picker;
        [(MysticPickerViewController *)picker setImagePickerDelegate:nil];
        [(MysticPickerViewController *)picker setDelegate:nil];
    }
    if((id)picker != self) [self closeCam:nil];
}
- (void) pasteNewLayer:(id)sender;
{
    [self addCustomLayer:sender image:imageInClipboard()];
}
- (void) addCustomLayer:(id)sender image:(UIImage *)_camLayerSource;
{
    if(!_camLayerSource) return;
    switch (currentSetting) {
        case MysticObjectTypeCamLayer: self.transformOption = [PackPotionOptionCamLayer optionWithName:[NSString format:@"Cam Image %d", (int)([[MysticOptions current] numberOfOptions:@(MysticObjectTypeImage)]+1)] info:@{}]; break;
        default: self.transformOption = [PackPotionOptionImage optionWithName:[NSString format:@"Image %d", (int)([[MysticOptions current] numberOfOptions:@(MysticObjectTypeImage)]+1)] info:@{}]; break;
    }
    __unsafe_unretained __block UIImage *camLayerSource = [_camLayerSource retain];
    self.transformOption.createNewCopy = YES;
    self.transformOption.hasChanged = YES;
    if(camLayerSource)
    {
        __unsafe_unretained __block id _sender = !sender ? nil : [sender retain];
        __unsafe_unretained __block  MysticController *weakSelf = self;
        self.transformOption.transformRect = CGRectMake(0,0,0.9,0.9);
        self.transformOption.stretchMode = MysticStretchModeAspectFit;
        self.transformOption.forceReizeLayerImage = YES;
        [self.transformOption setCustomLayerImage:camLayerSource complete:^{
            [camLayerSource release];
            [weakSelf.transformOption setUserChoice];
            weakSelf.transformOption.hasRendered = NO;
            weakSelf.transformOption.ignoreRender = NO;
            [[MysticOptions current] setHasChanged:YES changeOptions:NO];
            [[MysticOptions current] setNeedsRender];
            MysticAnimation *anim = (id)[weakSelf showLayerPanelAnimation:nil info:@{
                                                                                     @"backgroundAlpha": @(1),
                                                                                     @"hideToggler": @YES,
                                                                                     @"state":@(weakSelf.transformOption.type),
                                                                                     @"option": weakSelf.transformOption ? weakSelf.transformOption : @NO,
                                                                                     @"panel": [MysticPanelObject info:@{
                                                                                                                         @"option": weakSelf.transformOption ? weakSelf.transformOption : @NO,
                                                                                                                         @"state": @(weakSelf.transformOption.type),
                                                                                                                         @"optionType": @(weakSelf.transformOption.type),
                                                                                                                         @"title": MysticObjectTypeTitleParent(weakSelf.transformOption.type, MysticObjectTypeUnknown),
                                                                                                                         @"animationTransition": @(MysticAnimationTransitionHideBottom),
                                                                                                                         @"panel": @(MysticPanelTypeOptionImageLayerSettings),
                                                                                                                         }]}];
            
            if(_sender && [(UIView *)_sender tag] == MysticViewTypeLayers)
            {
                [weakSelf hideAddTabBar];
                [weakSelf hideBottomBarAnimation:anim];
            }
            [anim animate:^(BOOL finished, MysticAnimationBlockObject *obj) {
                [weakSelf rerender:^(UIImage *i, id o, id opts, BOOL c) {
                    currentSetting = weakSelf.transformOption.type;
                    weakSelf.preventToolsFromBeingVisible = NO;
                    [weakSelf.overlayView setupGestures:weakSelf.transformOption.type];
                }];
            }];
            if(_sender) [_sender release];
        }];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case MysticViewTypeLayers:
        {
            switch (buttonIndex) {
                case 0: [self cameraButtonTouched:nil];         break;
                case 1: [self albumButtonTouched:nil];          break;
                case 2: [self pasteNewLayer:actionSheet];       break;
                default: break;
            }
            break;
        }
        case MysticViewTypePreview:
        {
            switch (buttonIndex) {
                case 0:    [MysticUser set:@(1)    key:Mk_TIME]; break;
                case 1:    [MysticUser set:@(1.5)  key:Mk_TIME]; break;
                case 2:    [MysticUser set:@(2)    key:Mk_TIME]; break;
                case 3:    [MysticUser set:@(2.5)  key:Mk_TIME]; break;
                case 4:    [MysticUser set:@(3)    key:Mk_TIME]; break;
                case 5:    [MysticUser set:@(.1)   key:Mk_TIME]; break;
                case 6:    [MysticUser set:@(.25)  key:Mk_TIME]; break;
                case 7:    [MysticUser set:@(.33)  key:Mk_TIME]; break;
                case 8:    [MysticUser set:@(.5)   key:Mk_TIME]; break;
                case 9:    [MysticUser set:@(.66)  key:Mk_TIME]; break;
                case 10:   [MysticUser set:@(.75)  key:Mk_TIME]; break;
                case 11:   [MysticUser set:@(.9)   key:Mk_TIME]; break;
                case 12:   [MysticUser set:@(5)    key:Mk_TIME]; break;
                case 13:   [MysticUser set:@(10)   key:Mk_TIME]; break;
                case 14:   [MysticUser set:@(20)   key:Mk_TIME]; break;
                default: break;
            }
            break;
        }
        case MysticViewTypeToolbarSize:
        {
            switch (buttonIndex) {
                case 0:   [MysticUser set:@(0) key:Mk_SCALE];                   break;
                case 1:   [MysticUser set:@(0.7487922705314)   key:Mk_SCALE];   break;
                case 2:   [MysticUser set:@(1)  key:Mk_SCALE];                  break;
                case 3:   [MysticUser set:@(1.5)  key:Mk_SCALE];                break;
                case 4:   [MysticUser set:@(2.2487922705314)   key:Mk_SCALE];   break;
                case 5:   [MysticUser set:@(3)  key:Mk_SCALE];                  break;
            }
            break;
        }
        default: break;
    }
    
}

- (void) checkForShader;
{
    if([MysticShader shaderFileIsNewer] && !self.imageView.renderIsHidden)
    {
        [MysticEffectsManager refresh:self.transformOption];
    }
}

#pragma mark - CKRadialMenu Delegate

-(void)radialMenu:(CKRadialMenu *)radialMenu didSelectPopoutWithIndentifier: (NSString *) identifier;
{
    if([identifier isEqualToString:@"var1"])
    {
        self.transformOption.inverted = !self.transformOption.inverted;
    }
    else if([identifier isEqualToString:@"var1"])
    {
        self.transformOption.layerEffect = MysticLayerEffectDesaturate;
    }
    else if([identifier isEqualToString:@"var2"])
    {
        self.transformOption.layerEffect = MysticLayerEffectOne;
    }
    else if([identifier isEqualToString:@"var3"])
    {
        self.transformOption.layerEffect = MysticLayerEffectTwo;
    }
    else if([identifier isEqualToString:@"var4"])
    {
        self.transformOption.layerEffect = MysticLayerEffectThree;
    }
    [self render:NO atSourceSize:NO complete:nil];
}
@end

//
//  MysticLayerPanelView.h
//  Mystic
//
//  Created by Me on 1/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticSegmentedControl.h"
#import "MysticLayerPanelBottomBarView.h"
#import "MysticLayerPanelBaseView.h"
#import "MysticPanelContentView.h"
#import "MysticTabBarPanel.h"

@class MysticLayerPanelView, MysticPanelObject;

@protocol MysticLayerPanelViewDelegate <NSObject>

@optional

- (void) layerPanel:(MysticLayerPanelView *)panelView stateDidChange:(MysticLayerPanelState)state;
- (void) layerPanel:(MysticLayerPanelView *)panelView stateWillChange:(MysticLayerPanelState)state;
- (void) layerPanel:(MysticLayerPanelView *)panelView selectedSection:(MysticPanelObject *)sectionInfo;
- (void) layerPanel:(MysticLayerPanelView *)panelView selectedTabSection:(MysticPanelObject *)sectionInfo;
- (void) layerPanel:(MysticLayerPanelView *)panelView resetSection:(MysticPanelObject *)sectionInfo;

- (void) layerPanel:(MysticLayerPanelView *)panelView replaceSection:(MysticPanelObject *)section1 withSection:(MysticPanelObject *)section2;

- (MysticPanelObject *) layerPanel:(MysticLayerPanelView *)panelView panelObjectForSection:(MysticPanelObject *)sectionInfo;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionWillAppearBlock:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionWillDisappearBlock:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidDisappearBlock:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidAppearBlock:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionIsReadyBlock:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidRemoveFromSuperview:(MysticPanelObject *)section;
- (MysticBlockObjObjComplete) layerPanel:(MysticLayerPanelView *)panelView prepareContainerForSectionBlock:(MysticPanelObject *)section;


- (UIView *) layerPanel:(MysticLayerPanelView *)panelView viewForSection:(MysticPanelObject *)sectionInfo;
- (id) layerPanel:(MysticLayerPanelView *)panelView sectionDidChange:(MysticPanelObject *)section;
- (void) layerPanel:(MysticLayerPanelView *)panelView sectionWillChange:(MysticPanelObject *)sectionInfo;
- (void) layerPanel:(MysticLayerPanelView *)panelView updateSection:(MysticPanelObject *)sectionInfo;
- (void) layerPanel:(MysticLayerPanelView *)panelView refreshSection:(MysticPanelObject *)sectionInfo;
- (void) layerPanel:(MysticLayerPanelView *)panelView disableSection:(MysticPanelObject *)sectionInfo;
- (void) layerPanelContentWillHide:(MysticLayerPanelView *)panelView;
- (void) layerPanelContentDidHide:(MysticLayerPanelView *)panelView;
- (void) layerPanelFrameChanged:(MysticLayerPanelView *)panelView state:(MysticLayerPanelState)state;


@end



@interface MysticLayerPanelView : MysticLayerPanelBaseView

@property (nonatomic, assign) MysticLayerPanelState state, previousState, nextState;
@property (nonatomic, assign) CGPoint anchor, closedAnchor;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL enabled, animating,  createNewOption, stopLayout;
@property (nonatomic, retain) NSMutableArray *panels;
@property (nonatomic, assign) CGFloat openInset, backgroundAlpha, panelSpacing, offsetY;

@property (nonatomic, readonly) MysticPanelType sectionType;
@property (nonatomic, readonly) CGSize openSize;
@property (nonatomic, readonly) CGFloat visibleHeight;
@property (nonatomic, readonly) NSInteger selectedControlIndex;
@property (nonatomic, readonly) BOOL showTabsAndSections;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) MysticPanelObject *topPanel;
@property (nonatomic, readonly) MysticPanelObject *previousPanel, *topPanelOrTab;
@property (nonatomic, retain) MysticPanelObject *visiblePanel;


@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) PackPotionOption *targetOption;

@property (nonatomic, retain) MysticSegmentedControl *segmentedControl;
@property (nonatomic, retain) MysticTabBarPanel *tabBar;
@property (nonatomic, assign) MysticTabBarPanel *replacementTabBar;
@property (nonatomic, retain) UIView *contentView, *backgroundView;
@property (nonatomic, retain) MysticButton *leftButton, *rightButton;
@property (nonatomic, retain) MysticLayerPanelBottomBarView *bottomBarView;
@property (nonatomic, readonly) MysticLayerToolbar *toolbar;

@property (nonatomic, retain) id <MysticLayerPanelViewDelegate> delegate;
@property (nonatomic, retain) MysticPanelContainerView *contentContainerView;

- (void) reset:(BOOL)resetOption;
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated finished:(MysticBlockBOOL)finished;
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated animations:(MysticBlock)animations finished:(MysticBlockBOOL)finished;
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated duration:(NSTimeInterval)duration animations:(MysticBlock)animations finished:(MysticBlockBOOL)finished;

- (void) setContentFrame:(CGRect)contentFrame animate:(BOOL)animated completion:(MysticBlockBOOL)finished;
- (void) setContentFrame:(CGRect)contentFrame animate:(BOOL)animated duration:(NSTimeInterval)duration key:(NSString *)animKey completion:(MysticBlockBOOL)finished;

- (void) show:(MysticBlockBOOL)finished;
- (void) hide:(MysticBlockBOOL)finished;
- (void) setOptions:(NSMutableDictionary *)options;
- (void) setContentView:(UIView *)contentView completion:(MysticBlockObject)finished;
- (void) replaceContentView:(UIView *)contentView animated:(BOOL)animated completion:(MysticBlockObject)finished;
- (void) reset;
- (UIView *) removeContentView;
- (void) update;
- (void) disable;
- (void) reload;
- (void) reload:(BOOL)resetAll;
- (void) hideContentView:(MysticBlock)finished;
- (void) rebuild:(MysticPanelObject *)section animated:(BOOL)animated complete:(MysticBlock)finished;
- (void) rebuild;
- (void) setTopPanel:(MysticPanelObject *)activeSection complete:(MysticBlock)finished;
- (void) buildFirstContentViewAnimated:(BOOL)animated complete:(MysticBlock)finished;
- (void) removeContentViewDuration:(NSTimeInterval)duration completion:(MysticBlockBOOL)completionBlock;
- (void) resetBackgroundColor;
- (void) resetDarkBackgroundColor;
- (void) replaceContentViewAndResize:(UIView *)newContentView duration:(NSTimeInterval)duration completion:(MysticBlockObject)finished;
- (void) prepareForState:(MysticLayerPanelState)state;
- (void) prepareToOpen;
- (CGRect) frameForState:(MysticLayerPanelState)state;
- (CGRect) frameForState;
- (void) setBottomBarHeight:(CGFloat)height;
- (void) retainContentView:(UIView *)contentView;
- (void) keepContentView:(UIView *)contentView;

- (void) refresh;
- (MysticPanelObject *) popToPreviousPanel;
- (MysticPanelObject *) popToPreviousPanel:(MysticBlock)complete;
- (void) pushPanel:(MysticPanelObject *)newPanelObject;
- (void) pushPanel:(MysticPanelObject *)newPanelObject complete:(MysticBlock)complete;
@end



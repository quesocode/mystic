//
//  MysticPanelObject.h
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewObject.h"
#import "MysticPanelSubView.h"
#import "MysticLayerPanelView.h"
#import "MysticConstants.h"
#import "MysticSlider.h"
#import "MysticPack.h"

@protocol MysticLayerPanelViewDelegate;

@class MysticLayerPanelView, MysticScrollView, MysticPacksScrollView;

@interface MysticPanelObject : MysticViewObject

@property (nonatomic) MysticPanelType sectionType, panelType;
@property (nonatomic, assign) BOOL showBottomBorder, resetAll;
@property (nonatomic, assign) MysticLayerPanelView *panel;
@property (nonatomic, retain) PackPotionOption *targetOption;
@property (nonatomic, retain) MysticPack *pack;
@property (nonatomic, readonly) NSArray *packs;

@property (nonatomic, retain) MysticPanelObject *activeSubPanelObject, *parentPanelObject;
@property (nonatomic, assign) MysticObjectType state, optionType;
@property (nonatomic, assign) CGFloat bottomBarHeight;
@property (nonatomic, assign) MysticAnimationTransition animationTransition;
@property (nonatomic, readonly) NSInteger activeTab;
@property (nonatomic, readonly) MysticPanelSubView *subPanelView;
@property (nonatomic, readonly) MysticView *contentView;
@property (nonatomic, retain) MysticScrollView *scrollView;
@property (nonatomic, readonly) MysticPacksScrollView *packsView;

@property (nonatomic, retain) MysticTabBar *tabBar;
@property (nonatomic, retain) MysticSlider *slider;
@property (nonatomic, copy) MysticBlockObject panelDestroyedBlock;
@property (nonatomic, copy) MysticBlockObjBOOL panelIsReady;
@property (nonatomic, copy) MysticBlockObjObjBOOL panelConfirmedBlock, panelCancelledBlock;
@property (nonatomic, copy) MysticBlockObjObj panelTouchedBlock;

@property (nonatomic, readonly) id <MysticLayerPanelViewDelegate> delegate;
@property (nonatomic, retain) NSString *title, *subtitle;
@property (nonatomic, retain) NSString *toolbarTitle;
@property (nonatomic, readonly) BOOL isASubSection;
- (void) resetPanel;

+ (id) panelObjectWithPanelObject:(MysticPanelObject *)other;
- (void) canceledOption;
- (void) canceledOption:(PackPotionOption *)option setting:(MysticObjectType)optionSetting finished:(MysticBlockObjBOOLBOOL)finished;
- (void) ready:(MysticBlockObjBOOL)readyBlock;
- (void) confirm:(MysticBlockObjObjBOOL)confirmBlock;
- (void) cancel:(MysticBlockObjObjBOOL)cancelBlock;
- (void) touch:(MysticBlockObjObj)touchBlock;
- (void) destroy:(MysticBlockObject)aBlock;
- (NSString *) debugDescriptionStr;

- (void) reset:(BOOL)animated;
@end

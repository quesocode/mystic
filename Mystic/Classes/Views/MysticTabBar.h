//
//  MysticTabBar.h
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticScrollView.h"
#import "MysticTabButton.h"
#import "MysticTabBarProtocol.h"

@class MysticTabBar, MysticController;




@interface MysticTabBar : MysticScrollView <UIScrollViewDelegate>
{
    CGFloat _numberOfVisibleTabs;
}
@property (nonatomic, assign) SEL tabSelectedAction;
@property (nonatomic, assign) id <MysticTabBarDelegate> tabBarDelegate;
@property (nonatomic, assign) NSArray *options;
@property (nonatomic, assign) NSArray *tabs;
@property (nonatomic, assign) MysticTabButton *selectedButton;
@property (nonatomic, assign) MysticTabStyle tabStyle;
@property (nonatomic, assign) MysticScrollViewRevealStyle revealStyle;

@property (nonatomic, assign) UIEdgeInsets insets, buttonPadding, buttonImageInsets;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat numberOfVisibleTabs;
@property (nonatomic, assign) CGPoint layoutOrigin;
@property (nonatomic, assign) CGRect layoutRect;
@property (nonatomic, assign) MysticLayoutStyle tabLayoutStyle;
@property (nonatomic, readonly) BOOL showTitles;
@property (nonatomic, assign) BOOL  scrollToItemBeforeEvent, preventsScrollOnHide, lookForActiveOptions, showActiveTypes, unSelectAllOnDisplay, autoSelection;



- (id) initWithFrame:(CGRect)frame options:(NSArray *)options;
- (id) initWithFrame:(CGRect)frame options:(NSArray *)theoptions layout:(MysticLayoutStyle)layoutType;
- (id) initWithFrame:(CGRect)frame options:(NSArray *)theoptions layout:(MysticLayoutStyle)layoutType rect:(CGRect)layoutRect;


- (void) removeAllSubviews;
- (void) setButtonType:(MysticObjectType)type active:(BOOL)activated;
- (void) resetAll;
- (BOOL) isTabOfTypeSelected:(MysticObjectType)type;
- (BOOL) containsButtonOfType:(MysticObjectType)type;
- (void) setSelected:(MysticObjectType)selectType;
- (MysticButtonType) tagForType:(MysticObjectType)buttonType;
- (void) setSelected:(MysticObjectType)selectType selected:(BOOL)isSelected;
- (MysticTabButton *) tabAtIndex:(NSInteger)index;
- (Class) tabButtonClass;
- (void) setSelectedIndex:(NSInteger)selectedIndex callEvent:(BOOL)callEvent;
- (void) setSelectedIndex:(NSInteger)selectedIndex callEvent:(BOOL)callEvent animated:(BOOL)animated;
- (void) deactivateAll;
- (id) customizeTab:(MysticTabButton *)tab info:(NSDictionary *)info;
- (void) tabBarButtonTouched:(id)button;
- (void) setNeedsDisplay:(BOOL)animated ignore:(BOOL)ignore;
- (void) setNeedsDisplay:(BOOL)animated;
- (void) updateDisplayForTab:(id)tab animated:(BOOL)animated;
- (void) setDefaults;
- (MysticTabButton *) tabForType:(MysticObjectType)type;

@end

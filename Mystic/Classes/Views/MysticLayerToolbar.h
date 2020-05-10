//
//  MysticLayerToolbar.h
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticToolbar.h"
#import "Mystic.h"
#import "MysticBarButtonItem.h"
#import "MysticBarButton.h"

@class MysticLayerToolbar;
@class MysticControl;
@protocol MysticLayerToolbarDelegate



@optional
- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;

- (void) toolbar:(MysticLayerToolbar *)toolbar valueChanged:(MysticBarButton *)sender toolType:(MysticToolType)toolType change:(CGFloat)changedAmount;

- (void) toolbar:(MysticLayerToolbar *)toolbar itemDoubleTapped:(MysticBarButton *)sender toolType:(MysticToolType)toolType;

@end

@interface MysticLayerToolbar : MysticToolbar
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL titleBorderHidden, useLayout, hasToggled, swipeDownToClose;
@property (nonatomic, retain) Class toggleTitleViewClass;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) MysticObjectType objectType;
@property (nonatomic, retain) NSArray *oldItems;
@property (nonatomic, assign) NSArray *itemsInput;
@property (nonatomic, assign) MysticToolbarState state;
@property (nonatomic, readonly) BOOL activeToggleTitleIsNew;
@property (nonatomic, readonly) UIView *activeToggleTitleView;
@property (nonatomic, readonly) UIView *toggleTitleViewReplacement;
@property (nonatomic, readonly) Class itemClass;
@property (nonatomic, readonly) NSArray * spacingItems, *nonSpacingItems, *nonFlexibleItems, *flexibleItems;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, retain) PackPotionOption *targetOption;
@property (nonatomic, copy) MysticBlockObjObjObj onChange;
@property (nonatomic, retain) MysticBarButtonItem *titleToggleView;
@property (nonatomic, assign) NSInteger titleToggleIndex;
+ (NSArray *) defaultItems;
+ (NSArray *) defaultItemsWithHeight:(CGFloat)height;
+ (NSArray *) defaultItemsWithDelegate:(id)delegate height:(CGFloat)height;
+ (NSArray *) defaultItemsWithDelegate:(id)delegate toolbar:(MysticLayerToolbar *)toolbar height:(CGFloat)height;
+ (NSArray *) defaultItemsWithDelegate:(id)delegate;


+ (id) toolbar;
+ (id) toolbarWithFrame:(CGRect)frame;
+ (id) toolbarWithDelegate:(id)delegate height:(CGFloat)height;

+ (id) toolbarWithHeight:(CGFloat)height;
+ (id) toolbarWithItems:(NSArray *)theItems;
+ (id) toolbarWithItems:(NSArray *)theItems delegate:(id)delegate;
+ (id) toolbarWithItems:(NSArray *)theItems delegate:(id)delegate height:(CGFloat)height;

+ (id) toolbarForObjectType:(MysticObjectType)objectType delegate:(id)delegate;
+ (id) toolbarForObjectType:(MysticObjectType)objectType info:(NSDictionary *)info delegate:(id)delegate;


- (id) initWithItems:(NSArray *)theItems;
- (id) initWithFrame:(CGRect)frame items:(NSArray *)theItems;
- (id) initWithFrame:(CGRect)frame delegate:(id)theDelegate;

- (void) addItem:(id)item;
- (void) commonInit;
- (void) setTitleEnabled:(BOOL)enabled;
- (void) toggleTitleView:(BOOL)animated complete:(MysticBlockObjObjObj)completed;
- (void) setTitle:(NSString *)value;
- (void) setTitle:(NSString *)value duration:(NSTimeInterval)dur;
- (void) setTitle:(NSString *)value animated:(BOOL)animated;
- (void) useItems:(NSArray *)theItems;
- (void) useItems:(NSArray *)theItems animated:(BOOL)animated;
- (id) itemViewWithTag:(NSInteger)tag;
- (void) itemDoubleTapped:(MysticBarButton *)sender;
- (void) itemTapped:(MysticBarButton *)sender;
- (MysticControl *)controlForItem:(MysticBarButtonItem *)item;
- (NSArray *) replaceItems:(NSArray *)items;
- (NSArray *) replaceItems:(NSArray *)newItems animated:(BOOL)animated;
- (NSArray *) restoreItemsAnimated:(BOOL)animated;
- (NSArray *) restoreItems;
- (void) setItemsInput:(NSArray *)theItems;
- (void) setItemsInput:(NSArray *)theItems animated:(BOOL)animated;
- (NSArray *) items:(NSArray *)theItems addSpacing:(BOOL)addSpacing;
- (NSArray *) items:(NSArray *)theItems spacing:(BOOL)addSpacing margin:(BOOL)addMargins;
- (void) updateToolsWithOption:(PackPotionOption *)option;
- (void) selectItem:(MysticBarButton *)sender;
- (MysticBarButton *) buttonForType:(MysticToolType)toolType;
- (void) hideItemOfType:(MysticToolType)tooltype animated:(BOOL)animated;
- (void) hideItemAtIndex:(NSInteger)toolIndex animated:(BOOL)animated;
- (void) showItemOfType:(MysticToolType)tooltype animated:(BOOL)animated;
- (void) showItemAtIndex:(NSInteger)toolIndex animated:(BOOL)animated;
- (NSInteger) indexOfItemWithType:(MysticToolType)toolIndex;
- (void) setItemHidden:(BOOL)hidden item:(MysticBarButtonItem *)item animated:(BOOL)animated;
- (NSArray *) replaceItemsWithInfo:(NSArray *)newItems animated:(BOOL)animated;
- (id) makeItemWithInfo:(NSDictionary *)itemInfo;
- (void) replaceItemAtIndex:(NSUInteger)itemIndex view:(UIView *)view completion:(MysticBlock)complete;

@end

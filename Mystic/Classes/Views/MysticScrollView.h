//
//  MysticScrollView.h
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticScrollHeaderView.h"
#import "MysticIndicatorView.h"
#import "MysticScrollViewControl.h"
#import "MysticChoiceButton.h"
@interface _MysticScrollView : UIScrollView
{
    BOOL _debug;
}
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, assign) CGPoint offsetZero;
- (void) commonInit;

@end


@interface MysticScrollView : _MysticScrollView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint rightPoint, leftPoint, tileOrigin, offsetAnchor;
@property (nonatomic, assign) CGSize tileSize, centerOffset, extraContentSize;
@property (nonatomic, assign) CGFloat tileSpacing, tileMargin;
@property (nonatomic, readonly) NSInteger tileCount, currentPage;
@property (nonatomic, readonly) BOOL isRevealing;
@property (nonatomic, assign) BOOL shouldSelectActiveControls, cacheControlEnabled, isScrolling, revealsTouchSpace, enableControls, snapsToTiles, showsControlAccessory, ignoreScrollWhileRevealing, useHeaderControl, showScrollBars, ignoreIndicator;
@property (nonatomic, assign) UIEdgeInsets originalInsets;
@property (nonatomic, assign) MysticScrollDirection direction, scrollDirection;
@property (nonatomic, assign) MysticLayoutStyle layoutStyle;
@property (nonatomic, assign) id selectedItem;
@property (nonatomic, readonly) NSArray *controls;
@property (nonatomic, retain) MysticScrollHeaderView *headerView;
@property (nonatomic, assign) UIEdgeInsets controlInsets;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) id<EffectControlDelegate> controlDelegate;
@property (nonatomic, assign) NSInteger itemsPerRow, bufferItemsPerRow, selectedItemIndex;
@property (nonatomic, readonly) NSInteger selectedItemTag;
@property (nonatomic, readonly) MysticChoiceButton *firstControl;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, copy) MysticBlockReturnsBOOL shouldSelectControlBlock;
@property (nonatomic, assign) MysticIndicatorView *indicatorView;
@property (nonatomic, retain) NSMutableArray *controlsData;
@property (nonatomic, assign) Class viewClass;
@property (nonatomic, copy) MysticBlockMakeTile makeTileBlock;
@property (nonatomic, copy) MysticBlockUpdateTile updateTileBlock;
@property (nonatomic, assign) MysticTableLayout gridSize;

+ (CGSize) tileSizeForFrame:(CGRect)rect items:(int)numberOfItems;
+ (CGSize) tileSizeForFrame:(CGRect)rect items:(int)numberOfItems margin:(CGFloat)margin;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void) removeSubviewsExcept:(NSArray *)exceptions;
- (CGSize) tileSizeForItems:(int)numberOfItems;
- (CGSize) tileSizeForFrame:(CGRect)rect;
- (MysticScrollDirection) reveal;
- (void) revealNext;
- (void) revealPrevious;
- (void) itemTapped:(UIView *)item;
- (void) revealTouchSpaceAround:(UIView *)item;
- (void) revealItem:(UIView *)item complete:(MysticBlockObject)finished;
- (void) revealItem:(UIView *)item;
- (MysticScrollDirection) revealDirectionForItem:(UIView *)item;
- (CGRect) revealToFrameForItem:(UIView *)item;
- (BOOL) itemNeedsReveal:(UIView *)item;
- (CGFloat) gutterRightOf:(UIView *)item;
- (CGFloat) gutterLeftOf:(UIView *)item;
- (UIView *) itemAfter:(UIView *)item;
- (UIView *) itemBefore:(UIView *)item;
- (void) centerOnView:(UIView *)targetView animate:(BOOL)animated complete:(MysticBlock)finished;
- (NSInteger) centerOnOption:(id)targetOption animate:(BOOL)animated complete:(MysticBlock)finished;
- (void) centerOnIndex:(NSInteger)index animate:(BOOL)animated complete:(MysticBlock)finished;
- (NSInteger) selectOption:(id)targetOption animate:(BOOL)animated complete:(MysticBlock)finished;
- (void) loadControls:(NSArray *)controls selectIndex:(NSInteger)selectIndex animated:(BOOL)animated complete:(MysticBlock)finishedLoading;
- (void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated duration:(NSTimeInterval)dur  delay:(NSTimeInterval)delay curve:(UIViewAnimationCurve)curve animations:(MysticBlockObject)animations complete:(MysticBlockObject)completed;
- (void) wiggleTo:(CGPoint)wigglePoint duration:(NSTimeInterval)dur delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)completed;
- (void) scrollToView:(UIView *)view animated:(BOOL)animated finished:(MysticBlockObject)finished;


- (void) deselectAll;
- (void) reloadControls;
- (void) reloadControls:(BOOL)animated completion:(MysticBlock)finished;
- (void) loadControls:(NSArray *)controls;
- (void) loadControls:(NSArray *)controls selectIndex:(NSInteger)selectIndex animated:(BOOL)animated;
- (void) scrollToPage:(int)page animated:(BOOL)animated;

- (void) removeControls;
- (void) removeControlsExcept:(NSArray *)exceptions;
- (CGRect) centeredFrameForRect:(CGRect)rect;
- (void) hideHeader;
- (void) showHeader;
- (void) hideHeader:(NSTimeInterval)dur delay:(NSTimeInterval)delay finished:(MysticBlockBOOL)finished;
- (void) hideHeader:(MysticBlockBOOL)finished;
- (void) scrollToSelected:(BOOL)animated finished:(MysticBlockObject)finished;
- (void) revealItem:(UIView *)item animated:(BOOL)animated complete:(MysticBlockObject)finished;
- (BOOL) contentOffsetEqual:(CGPoint)offset;

@end

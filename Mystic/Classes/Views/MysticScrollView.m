//
//  MysticScrollView.m
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticScrollView.h"
#import "MysticController.h"

static inline NSString * MysticScrollViewTileKeyForControlIndex(NSInteger index) {
    return [NSString stringWithFormat:@"%ld", (long)index];
}

@interface _MysticScrollView ()
{
    BOOL _goingToZero;
    
}

@end

@implementation _MysticScrollView
@synthesize debug=_debug;

- (void) commonInit;
{
    _debug = NO;
    _offsetZero = CGPointZero;
    _goingToZero = NO;
}
//- (void) setContentOffset:(CGPoint)contentOffset;
//{
//    if(_debug)
//    {
//        DLogDebug(@"current: %@   newOffset: %@    offsetZero: %@    going: %@", p(self.contentOffset), p(contentOffset), p(_offsetZero), b(_goingToZero));
//        
//        int i = 0;
//    }
//    if(CGPointEqual(contentOffset, _offsetZero) && !CGPointUnknownOrZero(_offsetZero))
//    {
//        
//        
//        DLogError(@"newContentOffset is offsetZero: %@  current: %@", b(_goingToZero), p(self.contentOffset));
//        _goingToZero = NO;
//        
//        
//        
//        int i = 0;
//    }
//    
////    if(CGPointIsZero(contentOffset) && !CGPointUnknownOrZero(_offsetZero) && !_goingToZero)
////    {
////        [super setContentOffset:contentOffset];
////        _goingToZero = YES;
////        
////        [super setContentOffset:_offsetZero animated:YES];
////    }
////    else
////    {
//        [super setContentOffset:contentOffset];
////    }
//}

- (void) setOffsetZero:(CGPoint)offsetZero;
{
    _offsetZero = offsetZero;
    if(CGPointUnknownOrZero(offsetZero)) return;
    UIEdgeInsets i = self.contentInset;
    i.top = -offsetZero.y;
    i.left = -offsetZero.x;
    [super setContentInset:i];
}
@end

@interface MysticScrollView () <UIScrollViewDelegate>
{
    // We use the following ivars to keep track of
    // which view indexes are visible.
    int firstVisibleIndex_, lastVisibleIndex_, lastItemsPerRow_;
    CGSize tileSize;
    BOOL isReady, shouldScrollToSelectedControl, removingControls, _isRevealing;
    NSInteger topRow, bottomRow, _firstVisibleIndex, _lastVisibleIndex, __auto__selected__index;
    NSString *identifier, *identifierCancel;
    NSInteger nextPage;
}
@property (nonatomic, retain) NSMutableDictionary *reusableTileSets;
@property (nonatomic, retain) NSMutableArray *viewKeysToRemove;
@property (nonatomic, retain) NSMutableDictionary *visibleViews;
@property (nonatomic, retain) NSMutableSet *reusableTileViews;
@property (nonatomic, retain) NSTimer *resetTimer;
@property (nonatomic, assign) id<UIScrollViewDelegate> realDelegate;
@property (nonatomic, copy) MysticBlockObject finishedAnimBlock;
@property (nonatomic, assign) UIView *focusedView;


@end
@implementation MysticScrollView

@synthesize scrollView=_scrollView, selectedItem=_selectedItem, tileSize=_tileSize, direction=_direction, revealsTouchSpace=_revealsTouchSpace, margin=_margin, enableControls=_enableControls, realDelegate=_realDelegate, snapsToTiles=_snapsToTiles, tileSpacing=_tileSpacing, finishedAnimBlock=_finishedAnimBlock, controlDelegate=_controlDelegate, shouldSelectActiveControls=_shouldSelectActiveControls, tileMargin=_tileMargin, cacheControlEnabled=_cacheControlEnabled, itemsPerRow=_itemsPerRow, bufferItemsPerRow=_bufferItemsPerRow, animationDuration=_animationDuration, useHeaderControl=_useHeaderControl, viewClass=_viewClass, scrollDirection=_scrollDirection, selectedItemIndex=_selectedItemIndex;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    [super commonInit];
    nextPage = NSNotFound;
    __auto__selected__index = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
    _bufferItemsPerRow = 2;
    _cacheControlEnabled = NO;
    _revealsTouchSpace = YES;
    _enableControls = YES;
    _extraContentSize = CGSizeZero;
    _useHeaderControl = NO;
    _centerOffset = CGSizeZero;
    _tileOrigin = CGPointZero;
    _offsetAnchor = CGPointUnknown;
    _snapsToTiles = NO;
    _selectedItemIndex = NSNotFound;
    _showsControlAccessory = YES;
    _scrollDirection = MysticScrollDirectionHorizontal;
    _layoutStyle = MysticLayoutStyleHorizontal;
    _tileSpacing = kColumnPadding;
    _selectedItem = nil;
    _animationDuration = -1;
    _isRevealing = NO;
    _shouldSelectActiveControls = YES;
    _controlInsets = UIEdgeInsetsZero;
    _ignoreScrollWhileRevealing = YES;
    _gridSize = (MysticTableLayout){INT_MAX, INT_MAX};
    _realDelegate = nil;
    _itemsPerRow = NSNotFound;
    _isScrolling = NO;
    _shouldSelectControlBlock = nil;
    _tileSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
    _margin = kExtraWidth;
    identifier = [[NSString stringWithFormat:@"ScrollControl-%p", self] retain];
    identifierCancel = [[NSString stringWithFormat:@"ScrollControlCancel-%p", self] retain];
    _makeTileBlock = nil;
    self.visibleViews = [NSMutableDictionary dictionary];
    self.viewKeysToRemove = [NSMutableArray array];
    self.reusableTileViews = [NSMutableSet set];
    topRow = 0;
    bottomRow = 0;
    removingControls = NO;
    _viewClass = [EffectControl class];
    // No thumbnail views are visible at first; note this by
    // making the firsts very high and the lasts very low
    firstVisibleIndex_ = (int)NSIntegerMax;
    lastVisibleIndex_  = (int)NSIntegerMin;
    _firstVisibleIndex = (int)NSIntegerMax;
    _lastVisibleIndex = (int)NSIntegerMin;
    lastItemsPerRow_   = (int)NSIntegerMin;
    self.delaysContentTouches = YES;
    _showScrollBars = NO;
    [super setDelegate:self];
}

- (void) dealloc;
{
    if(_headerView)
    {
        _headerView.delegate = nil;
        [_headerView release], _headerView = nil;
    }
    [super dealloc];
    _controlDelegate=nil;
    //self.delegate = nil;
    _realDelegate = nil;
    _selectedItem = nil;
    _focusedView = nil;
    if(_resetTimer)
    {
        [_resetTimer invalidate];
        
        
        [_resetTimer release], _resetTimer=nil;
    }
    _indicatorView=nil;
    [_controlsData removeAllObjects];
    [_controlsData release], _controlsData=nil;
    [_visibleViews release];
    [_viewKeysToRemove release];
    [_reusableTileSets release];
    [identifier release];
    [identifierCancel release];
    [_reusableTileViews release];
    _viewClass = nil;
    if(_makeTileBlock) Block_release(_makeTileBlock);
    Block_release(_finishedAnimBlock);
    if(_shouldSelectControlBlock) Block_release(_shouldSelectControlBlock);
}
- (void) setScrollDirection:(MysticScrollDirection)direction;
{
    _scrollDirection = direction;
    self.showScrollBars = _showScrollBars;
}
- (MysticScrollDirection) scrollDirection;
{
    if(_scrollDirection == MysticScrollDirectionHorizontal || _scrollDirection == MysticScrollDirectionVertical) return _scrollDirection;
    MysticScrollDirection d = MysticScrollDirectionNone;
    
    if(self.contentSize.width == self.frame.size.width)
    {
        d = MysticScrollDirectionVertical;
    }
    else if(self.contentSize.height == self.frame.size.height)
    {
        d = MysticScrollDirectionHorizontal;
    }
    return d == MysticScrollDirectionNone ? _scrollDirection : d ;
}
- (void) setShowScrollBars:(BOOL)showScrollBars;
{
    _showScrollBars = showScrollBars;
    switch (self.scrollDirection) {
        case MysticScrollDirectionHorizontal:
            self.showsVerticalScrollIndicator = NO;
            self.showsHorizontalScrollIndicator = showScrollBars;
            break;
        case MysticScrollDirectionVertical:
            self.showsHorizontalScrollIndicator = NO;
            self.showsVerticalScrollIndicator = showScrollBars;
            break;
        default:
        {
            
            self.showsHorizontalScrollIndicator = showScrollBars;
            self.showsHorizontalScrollIndicator = showScrollBars;
            break;
        }
    }
    self.showsVerticalScrollIndicator = showScrollBars;
}
- (void) setIndicatorView:(MysticIndicatorView *)indicatorView;
{
    if(_indicatorView)
    {
        [_indicatorView removeFromSuperview];
        _indicatorView = nil;
    }
    _indicatorView = indicatorView;
    [self addSubview:_indicatorView];
}
- (BOOL) isRevealing; { return _isRevealing; }
- (void) setDelegate:(id<UIScrollViewDelegate>)delegateObj;
{
    _realDelegate = delegateObj;
}
- (id <UIScrollViewDelegate>) realDelegate;
{
    return _realDelegate != nil && ![_realDelegate isEqual:self] ? _realDelegate : nil;
}

- (void) setMargin:(CGFloat)margin;
{
    _margin = margin;
    if(UIEdgeInsetsEqualToEdgeInsets(_controlInsets, UIEdgeInsetsZero))
    {
        self.controlInsets = UIEdgeInsetsMake(_margin, 0, 0, _margin);
    }
}
- (NSInteger) itemsPerRow;
{
    if(_itemsPerRow == NSNotFound)
    {
        _itemsPerRow = (NSInteger)ceil((self.frame.size.width / (CGSizeIsZero(self.tileSize) && self.gridSize.columns != INT_MAX ? self.gridSize.columns : self.tileSize.width)));
    }
    return _itemsPerRow;
}
- (void) scrollToPage:(int)page animated:(BOOL)animated;
{
    if(!self.pagingEnabled) return;
    CGFloat newX = CGRectGetWidth(self.bounds) * page;
    nextPage = page;
    [self setContentOffset:(CGPoint){newX, self.contentOffset.y} animated:animated];
    if(self.pagingEnabled && self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidChangePage:)]) [self.realDelegate performSelector:@selector(scrollViewDidChangePage:) withObject:self];
    
}
- (NSInteger) currentPage;
{
    if(nextPage != NSNotFound) return nextPage;
    if (0 == self.frame.size.width) {
        return 0;
    }
    
    return round(self.contentOffset.x / self.frame.size.width);
}

- (BOOL) contentOffsetEqual:(CGPoint)offset;
{
    return CGPointEqual(self.contentOffset, offset);
}
- (UIScrollView *)scrollView
{
    return self;
}

- (CGSize) tileSizeForFrame:(CGRect)rect;
{
    return [MysticScrollView tileSizeForFrame:rect items:MYSTIC_UI_CONTROLS_NUMBER];
}

- (CGSize) tileSizeForItems:(int)numberOfItems;
{
    return [MysticScrollView tileSizeForFrame:self.frame items:numberOfItems];
}
+ (CGSize) tileSizeForFrame:(CGRect)rect items:(int)numberOfItems;
{
    return [MysticScrollView tileSizeForFrame:rect items:numberOfItems margin:kExtraWidth];
}
+ (CGSize) tileSizeForFrame:(CGRect)rect items:(int)numberOfItems margin:(CGFloat)margin;
{
    
    CGSize newSize = CGSizeZero;
    newSize.height = rect.size.height;
    if(numberOfItems > 0)
    {
        CGFloat totalWidth = rect.size.width - ((numberOfItems-1)*margin);
        
        newSize.width = floorf(totalWidth/numberOfItems);
        
        return newSize;
    }
    return CGSizeMake(rect.size.height + kExtraWidth, rect.size.height);
}

- (MysticScrollDirection) reveal;
{
    return MysticScrollDirectionNone;
}
- (CGFloat) gutterRightOf:(UIView *)item;
{
    CGPoint p = item.frame.origin;
    p.x += item.frame.size.width + self.margin;
    CGFloat dx = p.x - self.contentOffset.x;
    CGFloat gutter = self.frame.size.width - dx;
    return gutter;
}

- (CGFloat) gutterLeftOf:(UIView *)item;
{
    CGPoint p = item.frame.origin;
    CGFloat gutter = p.x - self.contentOffset.x;
    return gutter;
}

- (void) itemTapped:(UIView *)item;
{
    _selectedItem = item;
    self.selectedItemIndex = item.tag - self.tag - 1 - MysticViewTypeControl;
    if(self.revealsTouchSpace) [self revealTouchSpaceAround:item];
}

- (void) setSelectedItem:(UIView *)item;
{
    _selectedItem = item;
    self.selectedItemIndex = item.tag - self.tag - 1 - MysticViewTypeControl;
}

- (BOOL) itemNeedsReveal:(UIView *)item;
{
    CGPoint newPoint = self.contentOffset;
    CGRect newRect = [self revealToFrameForItem:item];
    return !CGPointEqualToPoint(newPoint, newRect.origin);
}
- (MysticScrollDirection) revealDirectionForItem:(UIView *)item;
{
    MysticScrollDirection adirection = MysticScrollDirectionNone;
    CGFloat gutterRight = [self gutterRightOf:item];
    CGFloat gutterLeft = [self gutterLeftOf:item];
    CGFloat space = (self.tileSize.width + self.margin*2);
    if(gutterRight < gutterLeft)
    {
        if(gutterRight < space)
        {
            adirection = MysticScrollDirectionRight;
        }
    }
    else
    {
        if(gutterLeft < space)
        {
            adirection = MysticScrollDirectionLeft;
            
        }
    }
    return adirection;
    
}
- (CGRect) revealToFrameForItem:(UIView *)item;
{
    CGPoint newPoint = self.contentOffset;
    CGFloat gutterRight = [self gutterRightOf:item];
    CGFloat gutterLeft = [self gutterLeftOf:item];
    CGFloat space = (self.tileSize.width + self.margin*2);
    if(gutterRight < gutterLeft)
    {
        if(gutterRight < space)
        {
            newPoint.x = item.frame.origin.x + space;
        }
    }
    else
    {
        if(gutterLeft < space)
        {
            newPoint.x = item.frame.origin.x - space;
        }
    }
    CGRect newRect = CGRectMake(newPoint.x, newPoint.y, self.tileSize.width, self.tileSize.height);
    newRect.origin = [self contentOffsetFixed:newRect.origin];
    return newRect;
}
- (void) revealTouchSpaceAround:(UIView *)item;
{
    [self revealItem:item complete:nil];
}
- (void) revealItem:(UIView *)item;
{
    [self revealItem:item complete:nil];
}
- (void) revealItem:(UIView *)item complete:(MysticBlockObject)finished;
{
    [self revealItem:item animated:YES complete:finished];
}
- (void) revealItem:(UIView *)item animated:(BOOL)animated complete:(MysticBlockObject)finished;
{
    if(!item)
    {
        self.finishedAnimBlock = finished;
        [self setContentOffset:CGPointMake(0, 0) animated:animated];
        return;
    }
    
    CGPoint newPoint = self.contentOffset;
    MysticScrollDirection adirection = MysticScrollDirectionNone;
    CGFloat gutterRight = [self gutterRightOf:item];
    CGFloat gutterLeft = [self gutterLeftOf:item];
    CGFloat tileWidth = self.tileSize.width;
    CGFloat space = (self.tileSize.width + self.margin*2);
    UIView *nextItem = [self viewWithTag:item.tag+1];
    if(nextItem && nextItem.frame.size.width != self.tileSize.width)
    {
        space = (nextItem.frame.size.width + self.margin*2);
        tileWidth = nextItem.frame.size.width;
    }
    if(gutterRight < gutterLeft)
    {
        if(gutterRight < space)
        {
            adirection = MysticScrollDirectionRight;
            newPoint.x = item.frame.origin.x + space;
        }
    }
    else
    {
        if(gutterLeft < space)
        {
            adirection = MysticScrollDirectionLeft;
            newPoint.x = item.frame.origin.x - space;
        }
    }
    self.direction = adirection;
    CGRect newRect = CGRectMake(newPoint.x, newPoint.y, tileWidth, self.tileSize.height);
    newRect.origin = [self contentOffsetFixed:newRect.origin];
    self.finishedAnimBlock = finished;
    [self scrollRectToVisible:newRect animated:animated ];
    
    if(!self.ignoreIndicator && _indicatorView && _indicatorView.superview) [_indicatorView animateToView:item animated:animated complete:nil];

}
- (void) revealNext;
{
    self.direction = MysticScrollDirectionRight;
    CGPoint newPoint = self.contentOffset;
    CGRect newRect = CGRectMake(newPoint.x + self.tileSize.width, newPoint.y, self.tileSize.width, self.tileSize.height);
    newRect.origin = [self contentOffsetFixed:newRect.origin];
    [self scrollRectToVisible:newRect animated:YES];
}
- (CGPoint) contentOffsetFixed:(CGPoint)newPoint;
{
    newPoint.x = MAX(0, newPoint.x);
    newPoint.x = MIN(newPoint.x, self.contentSize.width - self.tileSize.width);
    return newPoint;
}

- (void) revealPrevious;
{
    self.direction = MysticScrollDirectionRight;
    CGPoint newPoint = self.contentOffset;
    CGRect newRect = CGRectMake(newPoint.x - self.tileSize.width, newPoint.y, self.tileSize.width, self.tileSize.height);
    newRect.origin = [self contentOffsetFixed:newRect.origin];
    [self scrollRectToVisible:newRect animated:YES];
}


- (id) selectedItem;
{
    for (UIControl *control in self.controls) if(control.selected) return control;
    return nil;
}


- (UIView *) itemAfter:(UIView *)item;
{
    return !item ? nil : [self viewWithTag:item.tag + 1];
}
- (UIView *) itemBefore:(UIView *)item;
{
    return !item ? nil : [self viewWithTag:item.tag - 1];
}

- (void) setEnableControls:(BOOL)enableControls;
{
    _enableControls = enableControls;
    for (UIControl *button in self.controls)
    {
        if([button respondsToSelector:@selector(setEnabled:)] && button.isEnabled != _enableControls)
        {
            [button setEnabled:_enableControls];
        }
    }
}

- (void) addSubview:(UIView *)view;
{
    if([view isKindOfClass:self.viewClass] && [view respondsToSelector:@selector(setEnabled:)] && [(UIControl *)view isEnabled] != _enableControls)
    {
        [(UIControl *)view setEnabled:_enableControls];
    }
    if(self.autoresizesSubviews) view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [super addSubview:view];
}



- (CGFloat) decelerationRate;
{
    return UIScrollViewDecelerationRateFast;
}
- (CGRect) centeredFrameForIndex:(NSInteger)index;
{
    if(index == NSNotFound || index == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX) return CGRectInfinite;
    CGRect rect = [self frameForTileAtIndex:index];
    return [self centeredFrameForRect:rect];
}
- (CGRect) centeredFrameForRect:(CGRect)rect;
{
    CGFloat maxX = self.contentSize.width - self.bounds.size.width;
    rect.origin.x =  MIN(maxX, MAX(0, (rect.origin.x + (rect.size.width/2) - (self.frame.size.width/2)))) + self.centerOffset.width;
    return rect;
}
- (void) centerOnView:(UIView *)targetView animate:(BOOL)animated complete:(MysticBlock)finished;
{
    self.focusedView = targetView;
    [self centerOnFrame:[self centeredFrameForRect:targetView.frame] animate:animated complete:finished];
}
- (void) centerOnIndex:(NSInteger)index animate:(BOOL)animated complete:(MysticBlock)finished;
{
    if(index == NSNotFound || index == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX) return;
    [self centerOnFrame:[self centeredFrameForIndex:index] animate:animated complete:finished];
}
- (void) centerOnFrame:(CGRect)targetRect animate:(BOOL)animated complete:(MysticBlock)finished;
{
    if(CGRectEqualToRect(targetRect, CGRectInfinite) || self.contentSize.width <= self.frame.size.width) return;
    _isRevealing = YES;
    [self setContentOffset:CGPointMake(targetRect.origin.x, 0) animated:animated duration:-1 delay:0 curve:UIViewAnimationCurveEaseInOut animations:nil complete:finished];
}

- (NSInteger) selectOption:(id)option animate:(BOOL)animated complete:(MysticBlock)finished;
{
    NSInteger index = [self.controlsData containsObject:option] ? [self.controlsData indexOfObject:option] : NSNotFound;
    if(index != NSNotFound)
    {
        MysticScrollViewControl *selectedControl = [self tileAtIndex:index];
        if(selectedControl) [selectedControl showAsSelected:YES];
        [self centerOnFrame:[self centeredFrameForIndex:index] animate:animated complete:finished];
    }
    return index;

}
- (NSInteger) centerOnOption:(id)option animate:(BOOL)animated complete:(MysticBlock)finished;
{
    NSInteger index = [self.controlsData containsObject:option] ? [self.controlsData indexOfObject:option] : NSNotFound;
    if(index != NSNotFound) [self centerOnIndex:index animate:animated complete:finished];
    return index;
}


- (void)snapScrollView:(UIScrollView *)scrollView
{
    if(!_snapsToTiles) return;
    CGPoint offset = scrollView.contentOffset;
    if ((offset.x + scrollView.frame.size.width) >= scrollView.contentSize.width) return;
    offset.x = floorf(offset.x / (self.tileSize.width+self.tileSpacing) + 0.5) * (self.tileSize.width+self.tileSpacing);
    _isRevealing = YES;
    [MysticUIView animateWithDuration:0.1
                     animations:^{
                         scrollView.contentOffset = offset;
                     } completion:^(BOOL finished) {
                         _isRevealing = NO;
                     }];
}

- (NSInteger) tileCount;
{
    return self.controlsData ? self.controlsData.count : 0;
}
- (NSArray *) controls;
{
    NSMutableArray *c = [NSMutableArray array];
    for (id sub in self.subviews) {
        if([sub isKindOfClass:self.viewClass]) [c addObject:sub];
    }
    return c;
}

- (void) deselectAll;
{
    self.selectedItem = nil;
    if(!self.controls.count)
    {
        for (MysticButton *control in self.subviews) {
            if([control respondsToSelector:@selector(setSelected:)] && control.selected) control.selected = NO;
        }
        return;
    }
    for (MysticScrollViewControl *control in self.controls)
    {
        if(control.selected)
        {
            if([control respondsToSelector:@selector(showAsSelected:)])
            {
                [control showAsSelected:NO];
            }
            else
            {
                control.selected = NO;
            }
        }
    }
}
- (void) reloadControls;
{
    [self reloadControls:YES completion:nil];
}
- (void) reloadControls:(BOOL)animated completion:(MysticBlock)finished;
{
    [self deselectAll];
    int index = 0;
    NSInteger selectedIndex = NSNotFound;
    if(self.controlsData)
    {
        id selectedOption = nil;
        for (MysticChoice *control in self.controlsData) {
            if(control.isActive)
            {
                selectedOption = control;
                selectedIndex = index;
                break;
            }
            index++;
        }
        if(selectedOption)
        {
            MysticScrollViewControl *selectedControl = [self tileAtIndex:selectedIndex];
            if(selectedControl) [selectedControl showAsSelected:YES];
            [self centerOnFrame:[self centeredFrameForIndex:selectedIndex] animate:animated complete:finished];
        }
        else
        {
            self.contentOffset = CGPointZero;
        }
    }
}

- (NSInteger)indexOfSelectedItemInControlData;
{
    if(__auto__selected__index == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX && self.controlDelegate)
    {
        __auto__selected__index = NSNotFound;
        NSInteger i = 0;
        for (id control in self.controlsData) {
            if(self.shouldSelectControlBlock && self.shouldSelectControlBlock(control))
            {
                __auto__selected__index = i; break;
            }
            if([self.controlDelegate isOptionActive:control shouldSelectActiveControls:self.shouldSelectActiveControls index:i scrollView:self])
            {
                __auto__selected__index = i; break;
            }
            i++;
        }
    }
    return __auto__selected__index;
}

- (void) setControlsData:(NSMutableArray *)controlsData;
{
    __auto__selected__index = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
    if(_controlsData) [_controlsData release], _controlsData = nil;
    _controlsData = [controlsData retain];
}
#pragma mark - Load Controls

- (void) loadControls:(NSArray *)controls;
{
    [self loadControls:controls animated:NO];
}
- (void) loadControls:(NSArray *)controls animated:(BOOL)animated;
{
    [self loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:animated];
}
- (void) loadControls:(NSArray *)controls selectIndex:(NSInteger)selectIndex animated:(BOOL)animated;
{
    [self loadControls:controls selectIndex:selectIndex animated:animated complete:nil];
}
- (void) loadControls:(NSArray *)controls selectIndex:(NSInteger)selectIndex animated:(BOOL)animated complete:(MysticBlock)finishedLoading;
{
    
    if(selectIndex < 0) selectIndex = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
    [self removeControls];
    self.controlsData = [NSMutableArray arrayWithArray:controls];
    
    
    if(self.useHeaderControl && self.controlsData.count)
    {
        MysticChoice *lastControl = [self.controlsData lastObject];
        if([lastControl respondsToSelector:@selector(type)] && MysticTypeHasPack(lastControl.type) && !self.headerView)
        {
            CGRect hframe = [self frameForTileAtIndex:0];
            hframe.size.height -= self.margin;
            hframe.origin.y = self.margin;
            MysticScrollHeaderView *hView = [MysticScrollHeaderView headerViewWithScrollView:self frame:hframe];
            hView.delegate = (id)self.controlDelegate;
            hView.visibleDelay = 0;
            self.headerView = hView;
        }
    }
    
    
    if(!self.cacheControlEnabled)
    {
        MysticScrollViewControl *selectedControl = nil;
        for (NSInteger index = 0; index < self.controlsData.count; index++) {
            
            MysticScrollViewControl *controlView = (id)[self makeTiledViewForIndex:index frame:[self frameForTileAtIndex:index]];
            [self addSubview:controlView];
            
            if(!selectedControl && ((selectIndex != NSNotFound && index == selectIndex) || controlView.selected)) selectedControl = controlView;
        }
        [self updateContentSize];
        
        if(selectedControl)
        {
            if([selectedControl respondsToSelector:@selector(showAsSelected:)]) [selectedControl showAsSelected:YES];
            else selectedControl.selected = YES;
            [self centerOnView:selectedControl animate:animated complete:finishedLoading];
        }
        else if(finishedLoading) finishedLoading();
    }
    else
    {
        self.selectedItemIndex =  selectIndex == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX ? [self indexOfSelectedItemInControlData] : selectIndex;
        [self reloadCacheControlsAndSelectIndex:_selectedItemIndex complete:finishedLoading];
    }
}
- (void) setSelectedItemIndex:(NSInteger)selectedItemIndex;
{
    if(isNotFoundOrAuto(selectedItemIndex))
    {
        _selectedItemIndex = selectedItemIndex; return;
    }
    _selectedItemIndex = self.tag + 1 + MysticViewTypeControl + selectedItemIndex;
}
- (NSInteger) selectedItemIndex;
{
    if(_selectedItemIndex == NSNotFound) return NSNotFound;
    return _selectedItemIndex - (self.tag + 1 + MysticViewTypeControl);
}
- (NSInteger) selectedItemTag;
{
    return _selectedItemIndex;
}
- (void) scrollToView:(UIView *)view animated:(BOOL)animated finished:(MysticBlockObject)finished;
{
    [self revealItem:view animated:animated complete:finished];
}
- (void) scrollToSelected:(BOOL)animated finished:(MysticBlockObject)finished;
{
    NSInteger selectIndex = self.selectedItemIndex != NSNotFound ? self.selectedItemIndex : [self indexOfSelectedItemInControlData];
    if(selectIndex != NSNotFound)
    {
        __unsafe_unretained __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
        CGRect selectedFrame = [self frameForTileAtIndex:selectIndex];
        [self centerOnIndex:selectIndex animate:animated complete:^{
            [self scrollViewDidScroll:self];
            if(_f)
            {
                _f(self.selectedItem);
                Block_release(_f);
            }
        }];
    }
    else if(finished) finished(nil);
}

- (MysticChoiceButton *) firstControl;
{
    MysticChoiceButton * v = nil;
    for (MysticChoiceButton *b in self.controls) {
        if(CGPointEqual(b.frame.origin, self.tileOrigin)) return b;
        v = !v ? b : b.frame.origin.x < v.frame.origin.x ? b : v;
    }
    return v;
}

- (void) reloadCacheControlsAndSelectIndex:(NSInteger)selectIndex complete:(MysticBlock)finishedLoading;
{
    
    self.reusableTileSets = [NSMutableDictionary dictionary];
    topRow = 0;
    bottomRow = self.tileCount;
    for (id key in [self.visibleViews allKeys]) {
        [[self.visibleViews objectForKey:key] removeFromSuperview];
        [self.viewKeysToRemove addObject:key];
    }
    [self.visibleViews removeObjectsForKeys:self.viewKeysToRemove];
    [self.viewKeysToRemove removeAllObjects];
    [self updateContentSize];
    if(selectIndex != NSNotFound && selectIndex != MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX && selectIndex > 0 && selectIndex < self.controlsData.count)
    {
        [self centerOnIndex:selectIndex animate:NO complete:finishedLoading];
    }
    else
    {
        self.finishedAnimBlock = finishedLoading;
        [self.delegate scrollViewDidScroll:self];
        [self animationDidStop:@"scollviewreveal" finished:@(YES) context:nil];
    }
}

- (void) updateContentSize;
{
    CGSize cSize = CGSizeZero;
    switch (self.layoutStyle) {
        case MysticLayoutStyleGrid:
        {
            cSize = CGSizeMake((self.tileSize.width*(float)self.gridSize.columns + (kColumnPadding * (float)self.gridSize.columns-1)),
                                          self.tileOrigin.y + (self.tileSize.height*(ceilf((float)self.tileCount/(float)self.gridSize.columns)) + (kColumnPadding * (ceilf((float)self.tileCount/(float)self.gridSize.columns)-1.0))));
            break;
        }
        case MysticLayoutStyleVertical:
        {
            cSize = CGSizeMake(self.tileSize.width, self.tileSize.height*self.tileCount + (kColumnPadding * (self.tileCount-1)) + self.tileOrigin.y);
            break;
        }
        case MysticLayoutStyleHorizontal:
        default:
            cSize = CGSizeMake(self.tileSize.width*self.tileCount + (kColumnPadding * (self.tileCount-1)) + self.tileOrigin.x, self.tileSize.height);
            break;
    }
    if(!CGSizeIsZero(self.extraContentSize))
    {
        cSize.width += self.extraContentSize.width;
        cSize.height += self.extraContentSize.height;
        
    }
    self.contentSize = cSize;
}


- (void) removeControls;
{
    [self removeControlsExcept:nil];
}
- (void) removeControlsExcept:(NSArray *)exceptions;
{
    @autoreleasepool {
        for (UIView *subview in self.controls) {
            if(!exceptions || ![exceptions containsObject:subview]) [subview removeFromSuperview];
        }
    }
    if([self isKindOfClass:[UIScrollView class]]) [(UIScrollView *)self setContentOffset:CGPointZero];
}

- (void) removeSubviewsExcept:(NSArray *)exceptions;
{
    NSMutableArray *_exceptions = exceptions ? [NSMutableArray array] : nil;
    if(exceptions.count)
    {
        for (id s in exceptions) {
            if([s isKindOfClass:[NSNumber class]])
            {
                id v = [self viewWithTag:[s integerValue]];
                if(v) [_exceptions addObject:v];
            }
            else
            {
                [_exceptions addObject:s];
            }
        }
    }
    @autoreleasepool {
        for (UIView *subview in self.subviews) {
            if(!_exceptions || ![_exceptions containsObject:subview]) [subview removeFromSuperview];
        }
    }
    if([self isKindOfClass:[UIScrollView class]]) [(UIScrollView *)self setContentOffset:CGPointZero];
}

#pragma mark - UIScrollViewDelegate 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if(self.useHeaderControl && _headerView) [self cancelHeaderTimer];
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.realDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.realDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (!decelerate) [self snapScrollView:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])  [self.realDelegate scrollViewDidEndDecelerating:scrollView];
    if(scrollView.pagingEnabled && self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidChangePage:)]) [self.realDelegate performSelector:@selector(scrollViewDidChangePage:) withObject:self];

    [self snapScrollView:scrollView];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    float expectedOffset = targetContentOffset->x;
    if(self.useHeaderControl && _headerView && expectedOffset <= 0)
    {
        if(((-self.contentOffset.x + self.margin)/_headerView.originalFrame.size.width) > _headerView.visibleThreshold)
        {
            targetContentOffset->x = _headerView.originalFrame.origin.x;
            [self showHeader];
        }
        else
        {
            [MysticUIView animateWithDuration:_headerView.animateOutDuration animations:^{
                self.contentInset = self.originalInsets;
            }];
        }
    }
    if(!CGPointIsUnknown(self.offsetAnchor) && scrollView.contentOffset.y > 0)
    {
        targetContentOffset->y = targetContentOffset->y < self.offsetAnchor.y && targetContentOffset->y > 0 ? self.offsetAnchor.y : targetContentOffset->y;
    }
    if(!CGPointIsUnknown(self.offsetZero) && CGPointIsZero((CGPoint){targetContentOffset->x, targetContentOffset->y}))
    {
//        targetContentOffset->y = self.offsetZero.y;
//        targetContentOffset->x = self.offsetZero.x;
//        *targetContentOffset = self.offsetZero;

    }
    
    
    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.realDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
#pragma mark - ScrollView Did Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(_isRevealing && _ignoreScrollWhileRevealing) return;
    if(self.cacheControlEnabled)
    {
        @autoreleasepool {
        
            if (self.itemsPerRow != lastItemsPerRow_) [self queueReusableTileViews];
            lastItemsPerRow_ = self.itemsPerRow;
            CGFloat bufferDistance = 0;
            CGRect visibleRect;
            CGRect realVisibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
            switch (self.layoutStyle) {
                case MysticLayoutStyleGrid:
                {
                    bufferDistance = self.bufferItemsPerRow > 0 ? ((self.bufferItemsPerRow *self.tileSize.height) + ((self.bufferItemsPerRow - 1) *kColumnPadding)) : 0;
                    visibleRect = CGRectMake(scrollView.contentOffset.x , MAX(0,scrollView.contentOffset.y - bufferDistance), scrollView.frame.size.width, scrollView.frame.size.height+ (bufferDistance*(MAX(0,scrollView.contentOffset.y - bufferDistance) > 0 ? 2 : 1)));
                    int _topRow = -1;
                    int _bottomRow = -1;
                    if([self cleanVisibleCachedViews:visibleRect] == 0)
                    {
                        _topRow = (scrollView.contentOffset.y > self.tileSize.height ? (NSInteger)(floorf(scrollView.contentOffset.y / self.tileSize.height)) : 0);
                        topRow = _topRow * self.gridSize.columns;
                        bottomRow = MIN(self.tileCount, (topRow + ((self.gridSize.rows * self.itemsPerRow) + (self.bufferItemsPerRow* self.itemsPerRow))));

                    }
                    else
                    {
                        NSArray *sortedKeys = [[self.visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
                            if ([obj1 integerValue] < [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedAscending;
                            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedDescending;
                            } else {
                                return (NSComparisonResult)NSOrderedSame;
                            }
                        }];
                        topRow = [[sortedKeys objectAtIndex:0] integerValue];
                        bottomRow = [[sortedKeys lastObject] integerValue];
                        _topRow = topRow;
                        _bottomRow = bottomRow;
                        topRow = MAX(0, topRow - self.itemsPerRow - (self.bufferItemsPerRow * self.itemsPerRow));
                        bottomRow = MIN(self.tileCount, bottomRow + self.itemsPerRow + (self.bufferItemsPerRow * self.itemsPerRow));

                    }

                    break;
                }
                case MysticLayoutStyleVertical:
                {
                    bufferDistance = self.bufferItemsPerRow > 0 ? ((self.bufferItemsPerRow *self.tileSize.height) + ((self.bufferItemsPerRow - 1) *kColumnPadding)) : 0;
                    visibleRect = CGRectMake(scrollView.contentOffset.x , scrollView.contentOffset.y - bufferDistance, scrollView.frame.size.width, scrollView.frame.size.height+ bufferDistance*2);
                    if([self cleanVisibleCachedViews:visibleRect] == 0)
                    {
                        topRow = scrollView.contentOffset.y > self.tileSize.height ? (NSInteger)(floorf(scrollView.contentOffset.y / self.tileSize.height)) : 0;
                        bottomRow = MIN(self.tileCount, topRow + self.itemsPerRow + self.bufferItemsPerRow);
                    }
                    else
                    {
                        NSArray *sortedKeys = [[self.visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
                            if ([obj1 integerValue] < [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedAscending;
                            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedDescending;
                            } else {
                                return (NSComparisonResult)NSOrderedSame;
                            }
                        }];
                        topRow = [[sortedKeys objectAtIndex:0] integerValue];
                        bottomRow = [[sortedKeys lastObject] integerValue];
                        topRow = MAX(0, topRow - self.bufferItemsPerRow);
                        bottomRow = MIN(self.tileCount, bottomRow + self.bufferItemsPerRow);
                    }
                    
                    break;
                }
                case MysticLayoutStyleHorizontal:
                default:
                {
                    bufferDistance = self.bufferItemsPerRow > 0 ? ((self.bufferItemsPerRow *self.tileSize.width) + ((self.bufferItemsPerRow - 1) *kColumnPadding)) : 0;
                    visibleRect = CGRectMake(scrollView.contentOffset.x - bufferDistance, scrollView.contentOffset.y, scrollView.frame.size.width + bufferDistance*2, scrollView.frame.size.height);
                    
                    if([self cleanVisibleCachedViews:visibleRect] == 0)
                    {
                        topRow = scrollView.contentOffset.x > self.tileSize.width ? (NSInteger)(floorf(scrollView.contentOffset.x / self.tileSize.width)) : 0;
                        bottomRow = MIN(self.tileCount, topRow + self.itemsPerRow + self.bufferItemsPerRow);
                    }
                    else
                    {
                        NSArray *sortedKeys = [[self.visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
                            if ([obj1 integerValue] < [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedAscending;
                            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                                return (NSComparisonResult)NSOrderedDescending;
                            } else {
                                return (NSComparisonResult)NSOrderedSame;
                            }
                        }];
                        topRow = [[sortedKeys objectAtIndex:0] integerValue];
                        bottomRow = [[sortedKeys lastObject] integerValue];
                        topRow = MAX(0, topRow - self.bufferItemsPerRow);
                        bottomRow = MIN(self.tileCount, bottomRow + self.bufferItemsPerRow);
                    }
                    
                    break;
                }
            }
            
            
            
            
            NSInteger startAtIndex = topRow;
            NSInteger stopAtIndex = bottomRow;
            for (int index = startAtIndex; index < stopAtIndex; index++) {
                NSString *key = MysticScrollViewTileKeyForControlIndex(index);
                CGRect rect = [self frameForTileAtIndex:index];
                if (![self.visibleViews objectForKey:key] && CGRectIntersectsRect(visibleRect, rect)) {
                    UIView *tileView = [self tileForIndex:index dequeue:YES frame:rect];
                    tileView.frame = rect;
                    [self.visibleViews setObject:tileView forKey:key];
                    [scrollView addSubview:tileView];
                    [scrollView sendSubviewToBack:tileView];
                }
                if(CGRectIntersectsRect(realVisibleRect, rect))
                {
                    _firstVisibleIndex = MIN(_firstVisibleIndex, index);
                    _lastVisibleIndex = MAX(_lastVisibleIndex, index);
                }
            }
            

            
            firstVisibleIndex_ = startAtIndex;
            lastVisibleIndex_  = stopAtIndex;
        }
    }

    if(self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) [self.realDelegate scrollViewDidScroll:scrollView];
    if(self.useHeaderControl && _headerView)
    {
        if(_headerView && self.contentOffset.x <= (_headerView.originalFrame.size.width + self.margin))
        {
            [_headerView updatePosition:self.contentOffset scrollView:self];
            if(!_headerView.superview) [super addSubview:_headerView];
        }
        else if(_headerView && _headerView.superview) [_headerView removeFromSuperview];
    }
}

- (NSInteger) cleanVisibleCachedViews:(CGRect)visibleRect;
{
    for (id key in self.visibleViews.allKeys) {
        UIView *view = [self.visibleViews objectForKey:key];
        if (!CGRectIntersectsRect(visibleRect, view.frame))
        {
            [self reuseTile:(id)view];
            [view removeFromSuperview];
            [self.viewKeysToRemove addObject:key];
        }
    }
    [self.visibleViews removeObjectsForKeys:self.viewKeysToRemove];
    [self.viewKeysToRemove removeAllObjects];
    return self.visibleViews.count;
}
#pragma mark - Cache Control Enabled

- (void) queueReusableTileViews;
{
    for (UIView *view in self.controls) {
        [self reuseTile:(id)view];
        [view removeFromSuperview];
    }
    _firstVisibleIndex = (int)NSIntegerMax;
    _lastVisibleIndex = (int)NSIntegerMin;
    firstVisibleIndex_ = (int)NSIntegerMax;
    lastVisibleIndex_  = (int)NSIntegerMin;
}


- (UIView *) dequeueReusableSubview:(int)index
{
    MysticChoice *effect = [self.controlsData objectAtIndex:index];
    NSString *idr = effect.cancelsEffect ? [NSString stringWithFormat:@"%@", identifierCancel]  : [NSString stringWithFormat:@"%@", identifier];
    idr = [idr stringByAppendingString:NSStringFromClass([self class])];
    if(![self.reusableTileSets objectForKey:idr]) return nil;
    UIView *tileView = [[self.reusableTileSets objectForKey:idr] anyObject];
    if (tileView != nil) {
        [[tileView retain] autorelease];
        [[self.reusableTileSets objectForKey:idr] removeObject:tileView];
        if([tileView respondsToSelector:@selector(reuse)]) [tileView performSelector:@selector(reuse)];
    }
    return tileView;
}

#pragma mark - Tile & Frame For Tile

- (CGRect) frameForTileAtIndex:(NSUInteger)index
{
    switch (self.layoutStyle) {
        case MysticLayoutStyleGrid:
        {
            int column = index % self.gridSize.columns;
            int row = (int)(floorf(index/self.gridSize.columns));
            return CGRectMake(self.tileOrigin.x + (self.tileSize.width*(float)column + (kColumnPadding*(float)column)), self.tileOrigin.y + (self.tileSize.height*(float)row + (kColumnPadding*(float)row)), self.tileSize.width, self.tileSize.height);
        }
        case MysticLayoutStyleVertical:
        {
            return CGRectMake(self.tileOrigin.x, self.tileOrigin.y + (self.tileSize.height*index + (kColumnPadding*index)), self.tileSize.width, self.tileSize.height);
        }
        default: break;
    }
    return CGRectMake(self.tileOrigin.x + (self.tileSize.width*index + (kColumnPadding*index)), self.tileOrigin.y, self.tileSize.width, self.tileSize.height);
}
- (id) tileAtIndex:(int)index;
{
    return (id)[self viewWithTag:index + self.tag + MysticViewTypeControl + 1];
}
- (void) reuseTile:(MysticScrollViewControl *)tileView
{
    NSString *idr = tileView.effect.cancelsEffect ? [NSString stringWithFormat:@"%@", identifierCancel]  : [NSString stringWithFormat:@"%@", identifier];
    idr = [idr stringByAppendingString:NSStringFromClass([self class])];
    if(![self.reusableTileSets objectForKey:idr]) [self.reusableTileSets setObject:[NSMutableSet set] forKey:idr];
    if(tileView) [[self.reusableTileSets objectForKey:idr] addObject:tileView];
}

- (UIView *)tileForIndex:(NSInteger)index dequeue:(BOOL)shouldReuse frame:(CGRect)frame;
{
    MysticScrollViewControl *tiledView = shouldReuse ? (id)[self dequeueReusableSubview:index] : nil;
    int column = index % self.gridSize.columns;
    int row = (int)(floorf(index/self.gridSize.columns));
    
    if (!tiledView) {
        tiledView = (id)[self makeTiledViewForIndex:index frame:frame];
        tiledView.tag = self.tag + MysticViewTypeControl + index + 1;
        if([tiledView respondsToSelector:@selector(setPosition:)]) tiledView.position = index;
    }
    else
    {
        tiledView.tag = self.tag + MysticViewTypeControl + index + 1;
        tiledView.frame = frame;
        if([tiledView respondsToSelector:@selector(setPosition:)]) tiledView.position = index;
        if([tiledView respondsToSelector:@selector(setIsLast:)]) tiledView.isLast = [self.controlsData count] == (index+1);
        if([tiledView respondsToSelector:@selector(setIsFirst:)]) tiledView.isFirst = index==0;
        if([tiledView respondsToSelector:@selector(setGridIndex:)]) tiledView.gridIndex = (MysticGridIndex){column,row};
        if([tiledView respondsToSelector:@selector(setEffect:)])
        {
            tiledView.effect = (id)[self.controlsData objectAtIndex:index];
            BOOL isActive = [self.controlDelegate isOptionActive:(id)tiledView.effect shouldSelectActiveControls:self.shouldSelectActiveControls index:index scrollView:self];
            if(tiledView.selected != isActive)
            {
                [tiledView showAsSelected:isActive];
            }
            else if([tiledView respondsToSelector:@selector(updateLabel:)])
            {
                [tiledView updateLabel:isActive];
            }
            if(self.updateTileBlock) self.updateTileBlock(index, tiledView.effect, tiledView, isActive, (id)self);

        }
        
    }
    if([tiledView respondsToSelector:@selector(setTargetOption:)]) tiledView.targetOption = nil;
    return tiledView;
}



- (UIView *) makeTiledViewForIndex:(int)index frame:(CGRect)frame;
{
    CGRect tileFrame = CGRectIsZero(frame) ? [self frameForTileAtIndex:index] : frame;
    int column = index % self.gridSize.columns;
    int row = (int)(floorf(index/self.gridSize.columns));
    
    MysticChoice *theeffect = [self.controlsData objectAtIndex:index];
    if(self.makeTileBlock) {
        MysticScrollViewControl *tiledView = self.makeTileBlock(index, theeffect, tileFrame, (id)self);
        tiledView.position = index;
        if([tiledView respondsToSelector:@selector(setGridIndex:)]) tiledView.gridIndex = (MysticGridIndex){column,row};
        self.viewClass = tiledView && ![tiledView isKindOfClass:self.viewClass] ? [tiledView class] : self.viewClass;
        return tiledView;
    }
    
    MysticScrollViewControl *tiledView = [[self.viewClass alloc] initWithFrame:tileFrame effect:(id)theeffect position:index action:theeffect.action marginInsets:self.controlInsets];
    tiledView.delegate = (id<MysticScrollViewControlDelegate>)self.controlDelegate;
    tiledView.position = index;
    if([tiledView respondsToSelector:@selector(setGridIndex:)]) tiledView.gridIndex = (MysticGridIndex){column,row};
    tiledView.isLast = [self.controlsData count] == (index+1);
    tiledView.isFirst = index==0;
    tiledView.tag = self.tag + MysticViewTypeControl + index + 1;
    tiledView.opaque = YES;
    tiledView.frame = frame;
    if([tiledView respondsToSelector:@selector(prepare)]) [tiledView prepare];
    if(self.controlDelegate && [self.controlDelegate respondsToSelector:@selector(isOptionActive:shouldSelectActiveControls:index:scrollView:)])
    {
        [tiledView showAsSelected:[self.controlDelegate isOptionActive:(id)theeffect shouldSelectActiveControls:self.shouldSelectActiveControls index:index scrollView:self]];
    }
    return [(UIView *)tiledView autorelease];
}

- (CGPoint) leftPoint;
{
    return CGPointZero;
}
- (CGPoint) rightPoint;
{
    return (CGPoint){self.contentSize.width - self.frame.size.width,0};
}

#pragma mark - Animations


- (NSTimeInterval) animationDuration;
{
    return _animationDuration < 0 ? 0.25 : _animationDuration;
}

- (NSTimeInterval) animationDurationForPoint:(CGPoint)point;
{
    return self.animationDuration;
}
- (void) setContentSize:(CGSize)contentSize;
{
    CGPoint offset = self.contentOffset;
    
    [super setContentSize:contentSize];
    self.scrollDirection = self.scrollDirection;
    if(!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero))
    {
        [super setContentOffset:offset];
    }
}
//- (void) setContentOffset:(CGPoint)contentOffset;
//{
//    [self setContentOffset:contentOffset animated:NO];
//}
- (void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
{
    [self setContentOffset:contentOffset animated:animated duration:-1 delay:0 curve:UIViewAnimationCurveEaseInOut animations:nil complete:nil];
}
- (void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated duration:(NSTimeInterval)dur  delay:(NSTimeInterval)delay curve:(UIViewAnimationCurve)curve animations:(MysticBlockObject)animations complete:(MysticBlockObject)completed;
{
    if(!self.scrollEnabled && completed)
    {
        _ignoreScrollWhileRevealing = YES;
        completed(self);
        return;
    }
//    DLog(@"setting content offset: %@  complete: %@", self.finishedAnimBlock ? @"has block" : @" --- ", completed ? @"has complete" : @" --- ");
//    contentOffset.x = MAX(0, contentOffset.x);
    if(completed) self.finishedAnimBlock = completed;
    
    if(CGPointEqualToPoint(contentOffset, self.contentOffset))
    {
        [self animationDidStop:@"scollviewreveal" finished:@(YES) context:nil];
        return;
    }
    self.isScrolling = !animated ? NO : YES;
    _isRevealing = YES;
    if(animated)
    {
        [UIView beginAnimations:@"scollviewreveal" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:dur >= 0 ? dur : [self animationDurationForPoint:contentOffset]];
        [UIView setAnimationDelay:delay];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }
    [super setContentOffset:contentOffset animated:NO];
    if(animations) animations(self);

    if(animated) [UIView commitAnimations];
    else [self animationDidStop:@"scollviewreveal" finished:@(YES) context:nil];
}
- (void) wiggleTo:(CGPoint)wigglePoint duration:(NSTimeInterval)dur delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)completed;
{
    [MysticUIView animateWithDuration:dur delay:delay usingSpringWithDamping:0.3 initialSpringVelocity:1.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.contentOffset = wigglePoint;
    } completion:completed];
}
- (void) scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;
{
    rect.origin.x = MAX(0, rect.origin.x);
    _isRevealing = YES;
    self.isScrolling = YES;
    if(animated)
    {
        [UIView beginAnimations:@"scollviewrevealrect" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:[self animationDurationForPoint:rect.origin]];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }
    [super scrollRectToVisible:rect animated:NO];
    if(animated)
    {
        [UIView commitAnimations];
    }
    else
    {
        [self animationDidStop:@"scollviewrevealrect" finished:@(YES) context:nil];
    }
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [self scrollViewDidScroll:self];
    [NSTimer wait:0.5 block:^{
        self.isScrolling = NO;
    }];
    _ignoreScrollWhileRevealing = YES;
    _isRevealing = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) [self.delegate scrollViewDidScroll:self];

    if(self.finishedAnimBlock) self.finishedAnimBlock(self);
    self.finishedAnimBlock = nil;
    self.focusedView = nil;
    _animationDuration = -1;
    nextPage = NSNotFound;
}

- (void) setHeaderView:(MysticScrollHeaderView *)view;
{
    _useHeaderControl = YES;
    if(!_headerView) self.originalInsets = self.contentInset;
    if(_headerView)
    {
        [_headerView removeFromSuperview];
        [_headerView release], _headerView = nil;
    }
    _headerView = nil;
    if(view)
    {
        CGRect headerFrame = view.frame;
        switch (self.scrollDirection) {
            case MysticScrollDirectionHorizontal:
                headerFrame.origin = CGPointMake(0 - headerFrame.size.width - self.margin, headerFrame.origin.y);
                break;
            case MysticScrollDirectionVertical:
                headerFrame.origin = CGPointMake(headerFrame.origin.x, 0 - headerFrame.size.height - self.margin);
                break;
            default: break;
        }
        view.frame = headerFrame;
        view.originalFrame = headerFrame;
        _headerView = [view retain];
        [self.delegate scrollViewDidScroll:self];
    }
}



- (void) showHeader;
{
    if(!self.useHeaderControl || !_headerView) return;
    __unsafe_unretained __block MysticScrollView *weakSelf = self;
    [self cancelHeaderTimer];
    [MysticUIView animateWithDuration:_headerView.animateInDuration animations:^{
        weakSelf.contentInset = UIEdgeInsetsMake(weakSelf.originalInsets.top, _headerView.originalFrame.size.width + weakSelf.margin, weakSelf.originalInsets.bottom, weakSelf.originalInsets.right);
    } completion:^(BOOL finished) {
        if(finished)
        {
            if(weakSelf.headerView && weakSelf.headerView.visibleDelay > 0)
            {
                weakSelf.resetTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.headerView.visibleDelay target:weakSelf selector:@selector(hideHeaderSlowly) userInfo:nil repeats:NO];
            }
        }
    }];
}

- (void) cancelHeaderTimer;
{
    if(self.resetTimer)
    {
        [self.resetTimer invalidate];
        self.resetTimer = nil;
    }
}
- (void) hideHeaderSlowly;
{
    if(!self.useHeaderControl || !_headerView) return;
    [self hideHeader:_headerView.animateOutDuration*1.5 delay:0 finished:nil];
}
- (void) hideHeader;
{
    if(!self.useHeaderControl || !_headerView) return;
    [self hideHeader:_headerView.animateOutDuration delay:0 finished:nil];

}
- (void) hideHeader:(MysticBlockBOOL)finished;
{
    if(!self.useHeaderControl || !_headerView) return;
    [self hideHeader:_headerView.animateOutDuration delay:0 finished:finished];
}
- (void) hideHeader:(NSTimeInterval)dur delay:(NSTimeInterval)delay finished:(MysticBlockBOOL)finished;
{
    if(!self.useHeaderControl || !_headerView) return;
    [self cancelHeaderTimer];
    [MysticUIView animateWithDuration:dur delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentInset = self.originalInsets;
    } completion:finished];
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch *touch = [touches anyObject];
    return touch.phase == UITouchPhaseMoved ? NO : [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (void) removeFromSuperview;
{
    if(_headerView)
    {
        [self cancelHeaderTimer];
        _headerView.scrollView = nil;
        [_headerView removeFromSuperview];
    }
    self.delegate = nil;
    self.controlDelegate = nil;
    [super removeFromSuperview];
}

@end

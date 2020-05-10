//
//  ImageControlsViewController.m
//  Mystic
//
//  Created by travis weerts on 1/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "ImageControlsViewController.h"
#import <dispatch/dispatch.h>

static inline NSString * TileKeyForControlIndex(NSInteger index) {
    return [NSString stringWithFormat:@"%ld", (long)index];
}

static NSInteger potionTag = 777777;
static const NSString *identifier =  @"MysticEffectControl";
static const NSString *identifierCancel =  @"MysticEffectControlCancel";
static NSInteger itemsPerRow = 3;
@interface ImageControlsViewController ()
{
    CGPoint firstEffectPoint;
    dispatch_queue_t backgroundQueue;
    BOOL showedUserCancelFilterButtonOnce;
    BOOL lastControlsFromBottom;
    NSUInteger selectedControlTag;
    BOOL revealingNext;
    
    
    NSMutableSet *visibleControlsSet;
    NSMutableSet *reusableTileViews;
    NSMutableDictionary *reusableTileSets;
    // We use the following ivars to keep track of
    // which view indexes are visible.
    int firstVisibleIndex_;
    int lastVisibleIndex_;
    int bufferCount;
    int tileCount;
    int lastItemsPerRow_;
    BOOL removingControls;
    NSInteger _firstVisibleIndex, _lastVisibleIndex;
    
    
    CGSize tileSize;
    Class viewClass;
    BOOL isReady, shouldScrollToSelectedControl;

    NSInteger topRow;
    NSInteger bottomRow;
    NSUInteger selectedIndex;
    NSMutableDictionary *visibleViews;
    NSMutableArray *viewKeysToRemove, *visibleEffects;
    UIScrollView *_currentScrollView;
}

@end

@implementation ImageControlsViewController

@synthesize
visibleEffects,
shouldScrollToActiveControl=_shouldScrollToActiveControl,
shouldSelectActiveControls=_shouldSelectActiveControls,
currentStateInfo=_currentStateInfo;

//static CGFloat kColumnPadding = 10.0f;

- (void) dealloc
{
    [visibleControlsSet release], visibleControlsSet=nil;
    lastControlsFromBottom = NO;
    showedUserCancelFilterButtonOnce = NO;
    [_currentStateInfo release];
    if(visibleViews) [visibleViews release], visibleViews=nil;
    if(viewKeysToRemove) [viewKeysToRemove release], viewKeysToRemove=nil;
    if(reusableTileViews) [reusableTileViews release], reusableTileViews=nil;
    if(visibleEffects) [visibleEffects release], visibleEffects=nil;

    if(backgroundQueue) dispatch_release(backgroundQueue), backgroundQueue=nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        visibleControlsSet = [[NSMutableSet alloc] init];
        visibleEffects = [[NSMutableArray alloc] init];
        revealingNext = NO;
        visibleViews = [[NSMutableDictionary alloc] init];
        viewKeysToRemove = [[NSMutableArray alloc] init];
        reusableTileViews = [[NSMutableSet alloc] init];

        tileCount = 0;
        topRow = 0;
        bottomRow = 0;
        removingControls = NO;
        bufferCount = 1;
        // Initialization code
        itemsPerRow = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 3 : 9;
        viewClass = [EffectControl class];
        // No thumbnail views are visible at first; note this by
        // making the firsts very high and the lasts very low
        firstVisibleIndex_ = (int)NSIntegerMax;
        lastVisibleIndex_  = (int)NSIntegerMin;
        _firstVisibleIndex = (int)NSIntegerMax;
        _lastVisibleIndex = (int)NSIntegerMin;
        lastItemsPerRow_   = (int)NSIntegerMin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tileSize = CGSizeMake(70, 99);
	// Do any additional setup after loading the view.
}
- (void) hideControls:(MysticScrollView *)scrollView completed:(void (^)())completionBlock;
{
    [self loadControls:nil scrollView:scrollView completed:^(BOOL controlsVisible) {
        if(!controlsVisible)
        {
            completionBlock();
        }
    }];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView;
{
    [self loadControls:effects scrollView:scrollView completed:nil];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView tileSize:(CGSize)newTileSize;
{
    [self loadControls:effects scrollView:scrollView animated:YES tileSize:newTileSize completed:nil];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView completed:(void (^)(BOOL controlsVisible))completionBlock;
{
    [self loadControls:effects scrollView:scrollView animated:NO completed:completionBlock];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated completed:(void (^)(BOOL controlsVisible))completionBlock;
{
    CGSize newTileSize = CGSizeMake(scrollView.frame.size.height + kExtraWidth, scrollView.frame.size.height);
    [self loadControls:effects scrollView:scrollView animated:animated tileSize:newTileSize completed:completionBlock];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView info:(NSDictionary *)userInfo completed:(void (^)(BOOL controlsVisible))completionBlock;
{
    CGSize newTileSize = CGSizeMake(scrollView.frame.size.height + kExtraWidth, scrollView.frame.size.height);
    [self loadControls:effects scrollView:scrollView animated:YES tileSize:newTileSize info:userInfo completed:completionBlock];
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated tileSize:(CGSize)newTileSize completed:(void (^)(BOOL controlsVisible))completionBlock;
{
    [self loadControls:effects scrollView:scrollView animated:animated tileSize:newTileSize info:nil completed:completionBlock];
    
}
- (void) loadControls:(NSArray *)effects scrollView:(MysticScrollView *)scrollView animated:(BOOL)animated tileSize:(CGSize)newTileSize info:(NSDictionary *)userInfo completed:(void (^)(BOOL controlsVisible))completionBlock;
{
    BOOL fromBottom = YES;
    shouldScrollToSelectedControl = NO;
    _currentScrollView = scrollView;
    tileSize = newTileSize;
    scrollView.tileSize = newTileSize;
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y) animated:NO];
    @autoreleasepool {
        
        backgroundQueue = !backgroundQueue ? dispatch_queue_create([@"com.mysticapp.imageControlsQueue" UTF8String], NULL) : backgroundQueue;
        
        
        NSInteger numberOfColumns = 5;
        CGFloat startY = 125;
        CGFloat startX = 0;
        
        CGFloat columnSpacing = kColumnPadding;
        int n = 1;
        
        NSTimeInterval hideDuration = animated ? 0 : 0.0f;
        NSTimeInterval hideDelay = 0.0f;
        NSTimeInterval hideDelayStep = 0.00f;
        
        
        scrollView.scrollEnabled = YES;
        
      
        
        if([self areControlsVisibleFor:scrollView])
        {
            [visibleControlsSet removeObject:scrollView];
            NSMutableArray *controls = [NSMutableArray array];
            CGRect visibleRect = scrollView.frame;
            visibleRect.origin = scrollView.contentOffset;
            
            for (UIControl *potionControl in scrollView.subviews) {
                if(hideDuration)
                {
                    if([potionControl isKindOfClass:[EffectControl class]] && CGRectIntersectsRect(potionControl.frame, visibleRect)) [controls addObject:potionControl];
                    
                }
            }
            
            if(hideDuration && [controls count])
            {
                
                
                for (UIControl *potionControl in controls) {
                    
                    [MysticUIView animateWithDuration:hideDuration
                                          delay:hideDelay
                                        options:UIViewAnimationCurveEaseIn
                                     animations:^{
                                         CGRect newframe = potionControl.frame;
                                         newframe.origin.y = startY;
                                         potionControl.frame = newframe;
                                     } completion:^(BOOL finished) {
                                         if(!finished) return;
                                         if(n==[controls count])
                                         {
                                             if(completionBlock) completionBlock(NO);
                                             [self loadControls:effects scrollView:scrollView animated:animated tileSize:newTileSize info:userInfo completed:completionBlock];
                                         }
                                     }];
                    
                    hideDelay += hideDelayStep;
                    n++;
                    
                }
            }
            if(hideDuration <=0 || ![controls count])
            {
                if(completionBlock) completionBlock(NO);
                [self loadControls:effects scrollView:scrollView animated:animated tileSize:newTileSize info:userInfo completed:completionBlock];
            }
            return;
        }
        
        
        
        [self removeOptionControls:scrollView];
        if(effects == nil)
        {
            tileCount = 0;
            if(visibleEffects) [visibleEffects release], visibleEffects=nil;
            visibleEffects = [[NSMutableArray array] retain];
            if(completionBlock) completionBlock(YES);
            return;
        }
        if(scrollView) [visibleControlsSet addObject:scrollView];
        
        
        
        itemsPerRow = (int)floor(scrollView.frame.size.width / tileSize.width);
        EffectControl *cancelsControl = nil;
        int totalEffects = [effects count];
        tileCount = totalEffects;
        if(visibleEffects) [visibleEffects release], visibleEffects=nil;
        visibleEffects = [[NSMutableArray alloc] initWithArray:effects];

        
        selectedIndex = NSNotFound;
        if(self.shouldScrollToActiveControl)
        {
            NSUInteger b = 0;
            for (PackPotionOption *effect in visibleEffects) {
                if([self isControlActive:effect])
                {
                    selectedControlTag = potionTag + b;
                    selectedIndex = b;
                    break;
                }
                b++;
            }
        }
        
        scrollView.contentOffset = CGPointZero;
        [self reloadControls:scrollView];
        if(completionBlock) completionBlock(YES);
        
    }
}





#pragma mark - UIScrollViewDelegate


- (void) reloadControls:(UIScrollView *)scrollView;
{

    revealingNext = NO;
    if(reusableTileSets) [reusableTileSets release], reusableTileSets = nil;
    reusableTileSets = [[NSMutableDictionary alloc] init];
    
    topRow = 0;
    bottomRow = tileCount;

    for (id key in [visibleViews allKeys]) {
        EffectControl *view = [visibleViews objectForKey:key];
//        [self reuseTile:view];
        [view removeFromSuperview];
        [viewKeysToRemove addObject:key];
    }
    [visibleViews removeObjectsForKeys:viewKeysToRemove];
    [viewKeysToRemove removeAllObjects];
    
    scrollView.contentSize = CGSizeMake(tileSize.width*tileCount + (kColumnPadding * (tileCount-1)), tileSize.height);
    scrollView.delegate = self;
    if(selectedIndex != NSNotFound)
    {
        CGRect selectedFrame = [self frameForTileAtIndex:selectedIndex];
        scrollView.contentOffset = selectedFrame.origin;
        
    }
    [self scrollViewDidScroll:scrollView];
    if(shouldScrollToSelectedControl)
    {
        [self revealSelectedControlAtIndex:selectedIndex scrollView:scrollView animate:NO complete:nil];
    }
    
   
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(revealingNext || removingControls) {
//        DLog(@"skipping cuz: revealingNext || removingControls: %@ | %@", MBOOLStr(revealingNext), MBOOLStr(removingControls));
        return;
    }
 
    
    @autoreleasepool {
        
    
        int bufferItemsPerRow = 2;
        if (itemsPerRow != lastItemsPerRow_) {
           
            [self queueReusableTileViews];
        }
        lastItemsPerRow_ = itemsPerRow;
        int bCount = bufferCount * itemsPerRow;
        CGFloat bufferWidth = ((bCount *tileSize.width) + (bCount *kColumnPadding));
        
        
        CGFloat bufferX = scrollView.contentOffset.x - bufferWidth;
        CGRect visibleRect = CGRectMake(bufferX, scrollView.contentOffset.y, scrollView.frame.size.width + bufferWidth*2, scrollView.frame.size.height);
        CGRect realVisibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
        
        
        [visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            EffectControl *view = obj;
            
            CGRect viewRect = view.frame;
            if (!CGRectIntersectsRect(visibleRect, viewRect)) {
                [self reuseTile:view];
                [view removeFromSuperview];
                [viewKeysToRemove addObject:key];
            }
        }];
        
        [visibleViews removeObjectsForKeys:viewKeysToRemove];
        [viewKeysToRemove removeAllObjects];
            
        if([visibleViews count] == 0)
        {
            
            topRow = scrollView.contentOffset.x > tileSize.width ? floor(scrollView.contentOffset.x / tileSize.width) : 0;
            bottomRow = MIN(tileCount, topRow + itemsPerRow + bufferItemsPerRow);
        }
        else
        {
            NSArray *sortedKeys = [[visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                } else {
                    return (NSComparisonResult)NSOrderedSame;
                }
            }];
            
            topRow = [[sortedKeys objectAtIndex:0] integerValue];
            bottomRow = [[sortedKeys lastObject] integerValue] +1;
            
            
            topRow = MAX(0, topRow - bufferItemsPerRow);
            bottomRow = MIN(tileCount, bottomRow + bufferItemsPerRow);
            
            
        }
        
        NSInteger startAtIndex = topRow;
        NSInteger stopAtIndex = bottomRow;
        
        
        
//        
//        _firstVisibleIndex = NSIntegerMax;
//        _lastVisibleIndex = NSIntegerMin;
//        
        
        for (int index = startAtIndex; index < stopAtIndex; index++) {
            NSString *key = TileKeyForControlIndex(index);
            CGRect rect = [self frameForTileAtIndex:index];
            
            if (![visibleViews objectForKey:key] && CGRectIntersectsRect(visibleRect, rect)) {
                UIView *tileView = [self tileForIndex:index];
                tileView.frame = rect;
                
                [visibleViews setObject:tileView forKey:key];
                [scrollView addSubview:tileView];
                [scrollView sendSubviewToBack:tileView];
                
                
            }
            
            if(CGRectIntersectsRect(realVisibleRect, rect))
            {
                _firstVisibleIndex = MIN(_firstVisibleIndex, index);
                 _lastVisibleIndex = MAX(_lastVisibleIndex, index);
            }
            
        }
        
//        DLog(@"index: %d -> %d === visible %d -> %d", startAtIndex, stopAtIndex, _firstVisibleIndex, _lastVisibleIndex);
        
        firstVisibleIndex_ = startAtIndex;
        lastVisibleIndex_  = stopAtIndex;
        
    }
    
}
- (BOOL) isEffectControlVisible:(EffectControl *)control;
{
    if(control && control.position >= _firstVisibleIndex && control.position <= _lastVisibleIndex)
    {
        return YES;
    }
    return NO;
}
- (NSInteger) effectControlVisibilityIndex:(EffectControl *)control;
{
    
    if(_firstVisibleIndex == NSIntegerMax || _lastVisibleIndex - _firstVisibleIndex < itemsPerRow)
    {
        if(control.position < itemsPerRow)
        {
            return control.position;
        }
        
    }
    if(control && control.position >= _firstVisibleIndex && control.position <= _lastVisibleIndex)
    {
        return control.position - _firstVisibleIndex;
    }
    return NSNotFound;
}
#pragma mark - UIScrollView content

- (CGSize) tileSizeAtIndex:(NSUInteger)index
{
    return [self frameForTileAtIndex:index].size;
}
- (CGRect) frameForTileAtIndex:(NSUInteger)index
{
    return CGRectMake(tileSize.width*index + (kColumnPadding*index), 0, tileSize.width, tileSize.height);
}

#pragma mark -
#pragma mark TinyViewDataSourceDelegate





- (UIView *)tileForIndex:(NSInteger)index
{
    EffectControl *tiledView = [self dequeueReusableSubview:index];
    BOOL isActive = NO;
    if (!tiledView) {
        tiledView = [self newTiledViewForIndex:index];
        tiledView.tag = potionTag + index;
        tiledView.position = index;
        
//        isActive = tiledView.selected;

    }
    else {
        
        
        PackPotionOption *effect = (PackPotionOption *)[visibleEffects objectAtIndex:index];
        tiledView.tag = potionTag + index;
        tiledView.position = index;
        tiledView.isLast = [visibleEffects count] == (index+1);
        tiledView.isFirst = index==0;
        tiledView.effect = effect;
        isActive = [self isControlActive:effect];
        if(tiledView.selected != isActive)
        {
            [tiledView showAsSelected:isActive];
        }
        else
        {
            [tiledView updateLabel:isActive];
        }
    }
    BOOL shouldUseTargetOption = self.shouldUseTargetOption;
    if(shouldUseTargetOption)
    {

        PackPotionOption *o = self.currentOption;
        if(o && [o isSame:(PackPotionOption *)tiledView.effect])
        {
            BOOL createNewObject = NO;
            if(self.currentStateInfo && [self.currentStateInfo objectForKey:@"createNewObject"])
            {
                createNewObject = [[self.currentStateInfo objectForKey:@"createNewObject"] boolValue];
            }
//            DLog(@"create new object: %@  |  number of type: %d", MBOOLStr(createNewObject), [[MysticOptions current] numberOfOption:o forState:MysticOptionStateConfirmed]);
            if(createNewObject || [[MysticOptions current] numberOfOption:o forState:MysticOptionStateConfirmed] > 1)
            {
//                DLog(@"setting target option: %@", o);

                tiledView.targetOption = o;
            }
        }
        else
        {
            tiledView.targetOption = nil;
        }
    }
    else
    {
        tiledView.targetOption = nil;
    }
    
    return tiledView;
}
- (BOOL) shouldUseTargetOption;
{
    return self.currentOption != nil;
}
- (void) reuseTile:(EffectControl *)tileView
{
    NSString *idr = tileView.effect.cancelsEffect ? [NSString stringWithFormat:@"%@", identifierCancel]  : [NSString stringWithFormat:@"%@", identifier];
    if(![reusableTileSets objectForKey:idr])
    {
        [reusableTileSets setObject:[NSMutableSet set] forKey:idr];
    }
    if(tileView) [[reusableTileSets objectForKey:idr] addObject:tileView];
}
- (EffectControl *) newTiledViewForIndex:(int)index
{
    CGRect blockFrame = [self frameForTileAtIndex:index];
    
    PackPotionOption *theeffect = [visibleEffects objectAtIndex:index];
    EffectControl *tiledView = [[EffectControl alloc] initWithFrame:blockFrame effect:theeffect position:index action:theeffect.action];
    tiledView.delegate = self;
    tiledView.position = index;
    tiledView.isLast = [visibleEffects count] == (index+1);
    tiledView.isFirst = index==0;
    [tiledView showAsSelected:[self isControlActive:theeffect]];
    tiledView.tag = potionTag + index;
    tiledView.opaque = YES;
    [tiledView prepare];
    return [(EffectControl *)tiledView autorelease];
}
- (BOOL) isControlActive:(PackPotionOption *)theeffect;
{
    return [self isOptionActive:theeffect shouldSelectActiveControls:self.shouldSelectActiveControls index:NSNotFound scrollView:nil];

}

- (BOOL) isEffectControlActive:(EffectControl *)effectControl;
{
    return [self isOptionActive:effectControl.option shouldSelectActiveControls:[(MysticScrollView *)effectControl.superview shouldSelectActiveControls] index:effectControl.position scrollView:effectControl.scrollView];
}
- (BOOL) isOptionActive:(PackPotionOption *)theeffect shouldSelectActiveControls:(BOOL)ashouldSelectActiveControls index:(NSInteger)index scrollView:(id)scrollView;
{
    
    BOOL isActive = ashouldSelectActiveControls ? [theeffect isActive] : NO;
    BOOL wa = isActive;
    PackPotionOption *_currentOption;
    if(isActive)
    {
        _currentOption = [theeffect isKindOfClass:[PackPotionOption class]] ? [self currentOption:theeffect.type] : nil;
        if(_currentOption && !theeffect.showAllActiveControls && ![theeffect isSame:_currentOption])
        {
            isActive = NO;
        }
    }
    if(isActive && scrollView && [scrollView isKindOfClass:[MysticScrollView class]])
    {
        MysticScrollView *sv = scrollView;
        if(sv.shouldSelectControlBlock) isActive = sv.shouldSelectControlBlock(theeffect);
    }
    return isActive;
}

#pragma mark -
#pragma mark - Current Option

- (PackPotionOption *) currentOption:(MysticObjectType)ofType;
{
    PackPotionOption *option = nil;
    ofType = MysticTypeForSetting(ofType, option);
    
    if(self.currentStateInfo && [self.currentStateInfo objectForKey:@"object"] && [[self.currentStateInfo objectForKey:@"object"] isKindOfClass:[MysticOption class]])
    {
        option = [self.currentStateInfo objectForKey:@"object"];
        if(option && (option.type != ofType && ofType != MysticObjectTypeAll)) option = nil;
    }
    option = option ? option : [[MysticOptions current] transformingOption:ofType orUseOptionOfSameType:NO];
    return option;
}
- (PackPotionOption *) currentOption;
{
    PackPotionOption *_currentOption = nil;
    if(self.currentStateInfo && [self.currentStateInfo objectForKey:@"object"] && [[self.currentStateInfo objectForKey:@"object"] isKindOfClass:[MysticOption class]])
    {
        _currentOption = [self.currentStateInfo objectForKey:@"object"];
    }
    if(_currentOption && !_currentOption.isSelectableOption) _currentOption = nil;

    return _currentOption;
}
- (void) setCurrentOption:(PackPotionOption *)option;
{
    if(option)
    {
        [self.currentStateInfo setObject:option forKey:@"object"];
    }
    else
    {
        [self.currentStateInfo removeObjectForKey:@"object"];
    }
}
- (EffectControl *) dequeueReusableSubview:(int)index
{
    PackPotionOption *effect = [visibleEffects objectAtIndex:index];
    NSString *idr = effect.cancelsEffect ? [NSString stringWithFormat:@"%@", identifierCancel]  : [NSString stringWithFormat:@"%@", identifier];
    
    if(![reusableTileSets objectForKey:idr]) return nil;
    
    EffectControl *tileView = [[reusableTileSets objectForKey:idr] anyObject];
    if (tileView != nil) {
        // The only object retaining the view is the
        // reusableThumbViews set, so we retain/autorelease
        // it before returning it so that it's not immediately
        // deallocated when removed form the set.
        [[tileView retain] autorelease];
        [[reusableTileSets objectForKey:idr] removeObject:tileView];
        [tileView reuse];
    }
    return tileView;
}
- (void) queueReusableTileViews;
{
    for (EffectControl *view in [_currentScrollView subviews]) {
        if ([view isKindOfClass:viewClass]) {
            [self reuseTile:view];
            [view removeFromSuperview];
        }
    }
    
    _firstVisibleIndex = (int)NSIntegerMax;
    _lastVisibleIndex  = (int)NSIntegerMin;
    
    firstVisibleIndex_ = (int)NSIntegerMax;
    lastVisibleIndex_  = (int)NSIntegerMin;
}




#pragma mark -
#pragma mark - Reveal Controls

- (NSInteger) controlIndexForOption:(id)option;
{
    NSUInteger optionIndex = visibleEffects && visibleEffects.count ? [visibleEffects indexOfObject:option] : NSNotFound;
    return optionIndex != NSNotFound ? optionIndex + potionTag : optionIndex;
}
- (void) revealSelectedControl:(UIScrollView *)scrollView animate:(BOOL)animated complete:(MysticBlockSender)completeBlock;
{
    [self revealSelectedControlAtIndex:selectedIndex scrollView:scrollView animate:animated complete:completeBlock];
}
- (void) revealOption:(PackPotionOption *)option scrollView:(UIScrollView *)scrollView animate:(BOOL)animated  complete:(MysticBlockSender)completeBlock;
{
    NSUInteger optionIndex = visibleEffects && visibleEffects.count ? [visibleEffects indexOfObject:option] : NSNotFound;
    if(optionIndex != NSNotFound)
    {
        [self revealControlAtIndex:optionIndex scrollView:scrollView animate:animated complete:completeBlock];
    }
}
- (void) revealSelectedControlAtIndex:(NSUInteger)theIndex scrollView:(UIScrollView *)scrollView animate:(BOOL)animated  complete:(MysticBlockSender)completeBlock;
{
    revealingNext = NO;
    EffectControl *theControl = (EffectControl *)[scrollView viewWithTag:(potionTag+theIndex)];
    
    if(!theControl || removingControls){
        revealingNext = NO;
        return;
    }
    [self revealControlAtIndex:theIndex scrollView:scrollView animate:animated complete:completeBlock];
}
- (void) revealControlAtIndex:(NSUInteger)theIndex scrollView:(UIScrollView *)scrollView animate:(BOOL)animated  complete:(MysticBlockSender)completeBlock;
{
    EffectControl *theControl = (EffectControl *)[scrollView viewWithTag:(potionTag+theIndex)];
    selectedIndex = theIndex;

    CGRect controlFrame = [self frameForTileAtIndex:theIndex];
    
    CGRect insetVisRect = CGRectInset(scrollView.frame, controlFrame.size.width*0.5, 0);
    CGRect visibleRect = scrollView.frame;
    visibleRect.size = insetVisRect.size;
    visibleRect = insetVisRect;

    
    CGPoint offset = scrollView.contentOffset;
    visibleRect.origin = offset;

    
    visibleRect.origin.x += floorf(controlFrame.size.width*0.5f);
    visibleRect.size.width = MAX(controlFrame.size.width, visibleRect.size.width);
    
    
    if(!CGRectContainsRect(visibleRect, controlFrame))
    {

        revealingNext = theControl != nil;
        CGPoint newPoint;
        newPoint = scrollView.contentOffset;
        if(/*(theControl && theControl.isLast) || */theIndex == ([visibleEffects count]-1))
        {
            newPoint.x = controlFrame.origin.x - (scrollView.frame.size.width - (CGRectGetWidth(controlFrame)));
        }
        else if(controlFrame.origin.x < (visibleRect.origin.x + (controlFrame.size.width/2)))
        {
            CGFloat diffX = visibleRect.origin.x - CGRectGetMinX(controlFrame);
            newPoint.x = scrollView.contentOffset.x - (diffX + (controlFrame.size.width/2));
  
        }
        else if(CGRectGetMaxX(controlFrame) > (visibleRect.origin.x + visibleRect.size.width))
        {
            CGFloat diffX = CGRectGetMaxX(controlFrame) - (scrollView.contentOffset.x + scrollView.frame.size.width);
       
            newPoint.x = scrollView.contentOffset.x + (diffX + (controlFrame.size.width));
            
            
        }
        
        newPoint.x = MAX(0, newPoint.x);
        
        if(scrollView.contentSize.width > scrollView.frame.size.width)
        {
            newPoint.x = MIN(scrollView.contentSize.width - scrollView.frame.size.width, newPoint.x);
        }
        
        
        int spotsInBetween = floor(abs((int)(newPoint.x - scrollView.contentOffset.x))/controlFrame.size.width);
        
        NSTimeInterval timeDuration = spotsInBetween <= 1 ? 0.25 : spotsInBetween*0.2;
        timeDuration = MIN(0.5f, timeDuration);

        if(newPoint.x != scrollView.contentOffset.x)
        {
            
            if(animated)
            {
                [MysticUIView animateWithDuration:timeDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    scrollView.contentOffset = newPoint;
                } completion:^(BOOL finished) {
                    if(completeBlock) {
                        completeBlock(theControl);
                    }
                    revealingNext = NO;
                    removingControls = NO;
                    [self scrollViewDidScroll:scrollView];
                    
                }];
            }
            else
            {
                scrollView.contentOffset = newPoint;
                if(completeBlock) {
                    completeBlock(theControl);
                }
                revealingNext = NO;
                removingControls = NO;
                [self scrollViewDidScroll:scrollView];
                
                
            }
        }
        else
        {
            if(completeBlock) completeBlock(theControl);
            removingControls = NO;
            revealingNext = NO;
        }
        
    }
    else
    {
        revealingNext = NO;
        
        if(completeBlock) completeBlock(theControl);
    }
}






#pragma mark -
#pragma mark - Remove controls & subviews


- (void) removeOptionControls:(UIView *)parentView
{
    [self removeOptionControls:parentView except:nil];
}
- (void) removeOptionControls:(UIView *)parentView except:(NSArray *)exceptions;
{
    @autoreleasepool {
        
        
        for (UIView *subview in parentView.subviews) {
            if([subview isKindOfClass:[EffectControl class]]  && (!exceptions || ![exceptions containsObject:subview])) [subview removeFromSuperview];
        }
        if([visibleControlsSet containsObject:parentView])
        {
            [visibleControlsSet removeObject:parentView];
        }
    }
}

- (void) removeControls:(UIView *)parentView
{
    [self removeControls:parentView except:nil];
}
- (void) removeControls:(UIView *)parentView except:(NSArray *)exceptions;
{
    removingControls = YES;
    @autoreleasepool {
        for (UIView *subview in parentView.subviews) {
            if([subview isKindOfClass:[UIControl class]] && (!exceptions || ![exceptions containsObject:subview])) [subview removeFromSuperview];
        }
    }
    if([parentView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView *)parentView setContentOffset:CGPointZero];
    }
    [reusableTileSets removeAllObjects];
    [visibleViews removeAllObjects];
    if(visibleEffects) { [visibleEffects removeAllObjects]; [visibleEffects release], visibleEffects=nil; }
    _firstVisibleIndex = NSIntegerMax;
    _lastVisibleIndex = NSIntegerMin;
    removingControls = NO;
}

- (NSInteger) numberOfControls:(UIView *)parentView;
{
    NSInteger count = 0;
    @autoreleasepool {
        for (UIView *subview in parentView.subviews) {
            if([subview isKindOfClass:[UIControl class]]) count++;
        }
    }
    
    return count;
    
}

- (void) deselectControls:(UIView *)parentView;
{
    for (UIView *subview in parentView.subviews) {
        if([subview respondsToSelector:@selector(isSelected)] && [(UIButton *)subview isSelected]) [(UIButton *)subview setSelected:NO];
    }
}

- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
{
    @autoreleasepool {
        for (UIView *subview in parentView.subviews) {
            if((!exceptions || ![exceptions containsObject:subview])) [subview removeFromSuperview];
        }
    }
}
- (void) removeSubviews:(UIView *)parentView exceptClass:(Class)classException;
{
    for (UIView *subview in parentView.subviews) {
        if(![subview isKindOfClass:classException]) [subview removeFromSuperview];
    }
    
}
- (void) showCancelButtonTip;
{
    
}

- (BOOL) areControlsVisibleFor:(UIScrollView *)scrollView;
{
    return [visibleControlsSet containsObject:scrollView];
}




#pragma mark - EffectControlDelegate methods


- (void) effectControlWasSelected:(UIControl *)effectControl effect:(MysticControlObject *)effect
{
    
    
    
    
}
- (void) effectControlIsSelecting:(UIControl *)effectControl effect:(MysticControlObject *)effect
{
    
}
- (void) effectControlWasDeselected:(UIControl *)effectControl effect:(MysticControlObject *)effect
{
    
}
- (void) userCancelledEffectControl:(UIControl *)effectControl effect:(MysticControlObject *)effect
{
    
    
    
}

- (void) userFinishedEffectControlSelections:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    selectedControlTag = effectControl.tag;
    selectedIndex = [(EffectControl *)effectControl position];
    [effect setUserChoice];
    
    
}


@end

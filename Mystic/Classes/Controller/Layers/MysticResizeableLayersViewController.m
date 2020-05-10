//
//  MysticResizeableLayersViewController.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "MysticConstants.h"
#import "MysticResizeableLayersViewController.h"
#import "AppDelegate.h"
#import "UserPotion.h"
#import "MysticController.h"
#import "MysticLayerBaseView.h"
#import "MysticMenuView.h"
#import "UIView+Mystic.h"

@interface MysticResizeableLayersViewController ()
{
    BOOL showedGridOnMove, hasShownGrid;
    CGRect viewFrame;
    CGPoint startPoint;
    CGPoint endPoint, menuPoint;
    NSMutableArray *tempViews;
}
@end

@implementation MysticResizeableLayersViewController


@synthesize delegate=_delegate, selectedLayer, gridView=_gridView, shouldShowGridOnOpen, hasLayers, originalFrame, shouldAddNewLayer, enabled=_enabled, keyObjectLayer=_keyObjectLayer;

static BOOL showGridOnOpen = NO;

+ (Class) optionClass; { return [PackPotionOptionView class]; }
+ (Class) layerViewClass; { return [MysticLayerView class]; }
+ (Class) overlaysViewClass; { return [MysticOverlaysView class]; }
+ (CGRect) maxLayerBounds;
{
    return CGRectInset(CGRectSize([MysticController controller].imageFrame.size), MYSTIC_LAYERS_BOUNDS_INSET, MYSTIC_LAYERS_BOUNDS_INSET);
}
- (void) destroy;
{
    self.view.gestureRecognizers = nil;
    [(MysticOverlaysView *)self.view setController:nil];
    self.parentView = nil;
    self.delegate = nil;
    self.backgroundOverlayView = nil;
    self.layerUsingMenu = nil;
    self.layerInClipboard = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void) dealloc;
{
    [self destroy];
    [super dealloc];
    [_gridView release];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        viewFrame = CGRectMake(0, 0, [MysticUI screen].width, [MysticUI screen].height);
        [self commonInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id)delegate;
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        viewFrame = frame;
        self.delegate = delegate;
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    self.stack = [NSMutableArray array];
    self.nextLayerIndex = 0;
    showedGridOnMove = NO;
    self.enabled = YES;
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    self.gridViewIsAnimating = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}
- (Class) layerViewClass;
{
    return [[self class] layerViewClass];
}
- (void) loadView;
{

    MysticOverlaysView *__view = [[[[self class] overlaysViewClass] alloc] initWithFrame:viewFrame];
    __view.userInteractionEnabled = self.enabled;
    __view.controller = self;
    self.view = __view;
    [__view release];
    
    
    
    [self enableGestures];
    
    
    
    
}
- (void) disableGestures; { [self enableGestures:NO]; }
- (void) enableGestures; { [self enableGestures:YES]; }

- (void) enableGestures:(BOOL)enabled;
{
    self.view.userInteractionEnabled = enabled;
    if(enabled)
    {
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] autorelease];
        tap.numberOfTapsRequired = 1;
        
        UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapped:)] autorelease];
        doubleTap.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self.view addGestureRecognizer:tap];

        [self.view addGestureRecognizer:doubleTap];
        UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.view addGestureRecognizer:[longpress autorelease]];
    }
    else
    {
        self.view.gestureRecognizers = @[];
    }
    
    
}
- (void) setBackgroundOverlayView:(UIView *)backgroundOverlayView;
{
    UIColor *bgColor = nil;
    if(backgroundOverlayView && ![backgroundOverlayView isKindOfClass:[UIView class]])
    {
        bgColor = [backgroundOverlayView isKindOfClass:[UIColor class]] ? (id)backgroundOverlayView : bgColor;
        UIView *bgView = [[UIView alloc] initWithFrame:self.overlaysView.bounds];
        bgView.userInteractionEnabled = NO;
        backgroundOverlayView = [bgView autorelease];
    }

    if(backgroundOverlayView)
    {
        if(backgroundOverlayView.superview) [backgroundOverlayView removeFromSuperview];
        backgroundOverlayView.frame = self.overlaysView.bounds;
        backgroundOverlayView.backgroundColor = bgColor ? bgColor : [[UIColor colorFromHexString:@"403834"] colorWithAlphaComponent:0.6];
        [self.overlaysView addSubview:backgroundOverlayView];
        [self.overlaysView sendSubviewToBack:backgroundOverlayView];
    }
    else
    {
        if(_backgroundOverlayView) [_backgroundOverlayView removeFromSuperview];
    }
    _backgroundOverlayView = backgroundOverlayView;

}
- (CGRect) maxLayerBounds;
{
    return self.overlaysView.maxLayerBounds;
}
- (NSInteger) nextLayerIndex;
{
    _nextLayerIndex += 1;
    return _nextLayerIndex;
}
- (MysticOverlaysView *) overlaysView; { return (MysticOverlaysView *)self.view; }

- (BOOL) canBecomeFirstResponder { return YES; }

#pragma mark - Tapped

- (void) tapped:(UITapGestureRecognizer *)recognizer;
{
    if(self.layerUsingMenu) return;

    if(![self delegate:@selector(layersViewDidTap:) object:self.overlaysView])
    {
        [self delegate:@selector(overlaysViewDidTap:) object:self.overlaysView];
    }
    CGPoint touchPoint = [recognizer locationInView:self.overlaysView];
    BOOL containsTouchPoint = CGRectContainsPoint(self.overlaysView.frame, touchPoint);
    
    if(self.selectedCount)
    {
        [self deselectAll];
        if(containsTouchPoint && !self.isGridHidden)
        {
            [self hideGrid:nil animated:YES force:YES];
        }
    }
    else if(containsTouchPoint)
    {
        
        if(!self.isGridHidden)
        {
            [self hideGrid:nil animated:YES force:YES];
        }
        else
        {
            [self showGrid:nil animated:YES force:YES];
        }
    }
    [self enableOverlays];
    if(self.hasLayersInBackground)
    {
        [self moveLayersOutOfBackground];
    }
    
    
}
- (void) doubletapped:(UITapGestureRecognizer *)recognizer;
{
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self delegate:@selector(layersViewDidDoubleTap:) object:self.overlaysView];

    }
}
#pragma mark - Long Press


- (void) longPress:(UILongPressGestureRecognizer *) gesture;
{
    [self longPress:gesture layer:nil];
}
- (void) longPress:(UILongPressGestureRecognizer *) gesture layer:(id <MysticLayerViewAbstract>)layerView;
{
    if(layerView && !layerView.enabled) return;

    
    
    if ([gesture state] == UIGestureRecognizerStateBegan)
    {
        self.layerUsingMenu = layerView;
        BOOL showMenu = !layerView || layerView.selected;
        BOOL shouldContinue = layerView != nil;
        BOOL pressedSelection = layerView != nil;
        CGRect pointRect = CGRectZero;
        if(!pressedSelection)
        {
            pointRect.origin = [gesture locationInView:self.view];
        }
        else
        {
            CGPoint layerCenter = layerView.center;
            layerCenter.y -= ((layerView.bounds.size.height/2));
            layerCenter.y += MYSTIC_LAYER_MENU_POPUP_INSET_Y;
            pointRect.origin = layerCenter;
        }
        
        menuPoint = pointRect.origin;
        
        if(showMenu)
        {
            self.isMenuVisible = YES;

            UIMenuController *menuController = [UIMenuController sharedMenuController];
            NSMutableArray *_mitems = [NSMutableArray array];
            

            UIMenuItem *menuItem;
            
            
            int selectedC = self.selectedCount;
            int c = self.count;
            if(pressedSelection)
            {
                shouldContinue = !layerView.selected;
                menuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMenuTouched:)];
                [_mitems addObject:[menuItem autorelease]];
                
                if(layerView && layerView.selected)
                {
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Deselect" action:@selector(deselectMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                    
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(removeMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                    
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Debug" action:@selector(debugLayerMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                }
                
    //            menuItem = [[UIMenuItem alloc] initWithTitle:@"Cut" action:@selector(cutMenuTouched:)];
    //            [_mitems addObject:[menuItem autorelease]];
                
    //            menuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(removeMenuTouched:)];
    //            [_mitems addObject:[menuItem autorelease]];
                
                menuItem = [[UIMenuItem alloc] initWithTitle:@"\u25B2" action:@selector(moveUpMenuTouched:)];
                [_mitems addObject:[menuItem autorelease]];
                
                menuItem = [[UIMenuItem alloc] initWithTitle:@"\u25BC" action:@selector(moveDownMenuTouched:)];
                [_mitems addObject:[menuItem autorelease]];
                
                
                self.backgroundOverlayView = (id)@YES;
            }
            else
            {
                menuItem = [[UIMenuItem alloc] initWithTitle:@"Debug" action:@selector(debugMenuTouched:)];
                [_mitems addObject:[menuItem autorelease]];
                
                if(self.layerInClipboard)
                {
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Paste" action:@selector(pasteMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                }
                
                if(selectedC != c)
                {
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Select All" action:@selector(selectAllMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                }
                if(selectedC > 0)
                {
                    menuItem = [[UIMenuItem alloc] initWithTitle:@"Deselect" action:@selector(deselectMenuTouched:)];
                    [_mitems addObject:[menuItem autorelease]];
                }
                menuItem = [[UIMenuItem alloc] initWithTitle:!self.isGridHidden ? @"\u2612" : @"\u229E" action:@selector(gridMenuTouched:)];
                [_mitems addObject:[menuItem autorelease]];
            }
            
            
            
            NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
            menuController.menuItems = _mitems;
            [menuController setTargetRect:pointRect inView:self.view];
            [menuController setMenuVisible:YES animated:YES];
        }
        
        
        if(shouldContinue)
        {
            
            [layerView setSelected:!layerView.selected notify:NO];
            self.keyObjectLayer = layerView.selected ? layerView : self.selectedLayer;
            
            if(![self delegate:@selector(layerViewWillLongPress:gesture:) object:layerView object:gesture])
            {
                [self delegate:@selector(layerViewWillLongPress:) object:layerView perform:YES];
            }
        }
    }
    else if ([gesture state] == UIGestureRecognizerStateBegan) {
        if(!layerView)
        {
            [self delegate:@selector(layersViewDidLongPress:) object:self.overlaysView];
            
        }
        
        
    }
    
    
}

- (void) debugMenuTouched:(id)sender;
{
    [self printLayersStack];
}
- (void) debugLayerMenuTouched:(id)sender;
{
    MysticLayerBaseView *layer = self.selectedLayer;
    if(layer)
    {
        DLog(@"%@", layer.debugDescription);
    }
    else
    {
        DLog(@"DEBUG: No selected layer found");
    }
}
- (void) removeMenuTouched:(id)sender;
{
    NSArray *layers = self.selectedLayers;
    [self removeLayers:layers];
    [self delegate:@selector(layersView:menuRemoveTouched:) object:self object:sender];


}
- (void) deselectMenuTouched:(id)sender;
{
    if(self.layerUsingMenu)
    {
        self.layerUsingMenu.selected = NO;
    }
    else
    {
        [self deselectAll];
    }
    [self delegate:@selector(layersView:menuDeselectTouched:) object:self object:sender];
}
- (void) selectAllMenuTouched:(id)sender;
{
    [self selectAll];
    [self delegate:@selector(layersView:menuSelectAllTouched:) object:self object:sender];
}
- (void) undoMenuTouched:(id)sender;
{
    [self delegate:@selector(layersView:menuUndoTouched:) object:self object:sender];

}

- (void) gridMenuTouched:(id)sender;
{
    if(self.isGridHidden)
    {
        [self showGrid:sender animated:YES force:YES];
    }
    else
    {
        [self hideGrid:sender animated:YES force:YES];
    }
    [self delegate:@selector(layersView:menuGridTouched:) object:self object:sender];

}
- (void) cutMenuTouched:(id)sender;
{
    if(self.layerUsingMenu)
    {
        [NSTimer wait:0.15 block:^{
            [self cutLayer:self.layerUsingMenu];
        }];
    }
    [self delegate:@selector(layersView:menuCutTouched:) object:self object:sender];
}
- (void) copyMenuTouched:(id)sender;
{
    if(self.layerUsingMenu)
    {
        [self copyLayer:self.layerUsingMenu];
    }
    [self delegate:@selector(layersView:menuCopyTouched:) object:self object:sender];

}
- (void) pasteMenuTouched:(id)sender;
{
    [NSTimer wait:0.1 block:^{
        [self paste:sender];
        if(!CGPointIsZero(menuPoint) && self.layerPastedFromClipboard)
        {
            CGPoint c = self.layerPastedFromClipboard.center;
            self.layerPastedFromClipboard.center = menuPoint;
            
        }
    }];

    [self delegate:@selector(layersView:menuPasteTouched:) object:self object:sender];
    
    

}


- (void) moveUpMenuTouched:(id)sender;
{
    [self moveLayerUp:self.layerUsingMenu];
    [self delegate:@selector(layersView:menuMoveUpTouched:) object:self object:sender];
    
}

- (void) moveDownMenuTouched:(id)sender;
{
    [self moveLayerDown:self.layerUsingMenu];
    [self delegate:@selector(layersView:menuMoveDownTouched:) object:self object:sender];

    
}
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    
    BOOL canCopy = YES;
    if (selector == @selector(copyMenuTouched:)) { return canCopy; }
    if(![self respondsToSelector:selector] || ![NSStringFromSelector(selector) hasSuffix:@"MenuTouched:"]) return NO;
    return YES;
}
- (void) menuWillShow:(NSNotification *)sender;
{
    self.isMenuVisible = YES;
}

- (void) menuDidHide:(NSNotification *)sender;
{
    self.backgroundOverlayView = nil;
    __unsafe_unretained __block MysticResizeableLayersViewController *weakSelf = self;
    [NSTimer wait:0.5 block:^{
        weakSelf.isMenuVisible = NO;
        self.layerUsingMenu = nil;

    }];
}

#pragma mark - Copy & Paste
- (void) paste:(id)sender;
{
    self.layerPastedFromClipboard = nil;
    if(sender && [[sender class] conformsToProtocol:@protocol(MysticLayerViewAbstract)])
    {
        [self pasteLayer:(id)sender];
    }
    else if(self.layerInClipboard)
    {
        [self pasteLayer:self.layerInClipboard];
    }
}
- (void) cutLayer:(id <MysticLayerViewAbstract>)layerView;
{
    [self copyLayer:layerView];
    [layerView setSelected:NO notify:NO];
    [self removeLayer:layerView];
}
- (void) copyLayer:(id <MysticLayerViewAbstract>)layerView;
{
    self.layerInClipboard = layerView;
}
- (void) pasteLayer:(id <MysticLayerViewAbstract>)layerView;
{
    if(layerView)
    {
        self.layerPastedFromClipboard = [self duplicateLayer:layerView option:layerView.option];
    }
    else
    {
        self.layerPastedFromClipboard = nil;
    }
}


- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    for (MysticLayerBaseView *layer in self.layers) {
        [layer prepareForImageCapture:renderSize scale:scale finished:nil];
    }
    
    if(tempViews) [tempViews release], tempViews=nil;
    tempViews = [[NSMutableArray array] retain];
    for (UIView *subview in self.overlaysView.subviews)
        if(![subview conformsToProtocol:@protocol(MysticLayerViewAbstract)] && !subview.hidden) { [tempViews addObject:subview]; subview.hidden = YES; }
    if(finished) finished();
//    {
//        MysticWait(1, finished);
//    }
    
}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    for (MysticLayerBaseView *layer in self.layers) {
        [layer finishedImageCapture:renderSize scale:scale];
    }
    for (UIView *subview in tempViews) {
        subview.hidden = NO;
    }
    [tempViews release], tempViews=nil;
    
}
- (BOOL) hasLayers;
{
    return [self.overlays count] > 0;
}
- (BOOL) shouldShowGridOnOpen;
{
    //    return YES;
    return showGridOnOpen;
}
- (void) setShouldShowGridOnOpen:(BOOL)value;
{
    //    return;
    showGridOnOpen = value;
}

- (BOOL) shouldAddNewLayer;
{
    if(!self.overlays.count) return YES;
    for (MysticLayerView *l in self.overlays) {
        if(l.hasChanges) return NO;
    }
    return YES;
}

- (id) newestOverlay;
{
    if(!self.overlays.count) return nil;
    
    
    for (MysticLayerView *l in self.overlays) {
        if(!l.hasChanges) return (MysticLayerView *)l;
    }
    return nil;
}


- (CGFloat) contentScale;
{
    CGFloat t1 = MAX(0, self.view.transform.a != 1 ? self.view.transform.a : 0);
    CGFloat t2 = MAX(0, self.view.transform.d != 1 ? self.view.transform.d : 0);
    CGFloat t3 = MAX(t1, t2);
    CGFloat t4 = t3 != 0 ? t3 : 1.0f;
    
    return self.view.bounds.size.width/[MysticUI scaleRect:self.view.bounds scale:t4].size.width;
}
- (CGFloat) currentScale;
{
    CGFloat t1 = MAX(0, self.view.transform.a != 1 ? self.view.transform.a : 0);
    CGFloat t2 = MAX(0, self.view.transform.d != 1 ? self.view.transform.d : 0);
    CGFloat t3 = MAX(t1, t2);
    CGFloat t4 = t3 != 0 ? t3 : 1.0f;
    return t4;
}
- (BOOL) isGridHidden;
{
    return self.gridView == nil;
}
- (void) showGrid:(id)sender;
{
    [self showGrid:sender animated:NO force:NO];
}
- (void) showGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    if(!self.allowGridViewToShow && !forceIt) return;
    //    DLog(@"show grid: %@ Has Grid: %@", MBOOLStr(animated), MBOOLStr((self.gridView != nil)));
    if(sender) self.shouldShowGridOnOpen = YES;

    [self delegate:@selector(overlaysViewWillShowGrid:) object:self.overlaysView];

    if(self.gridViewIsAnimating)
    {
        if(self.gridView)
        {
            self.gridView.alpha = 0;
            [self.gridView removeFromSuperview];
            self.gridView = nil;
        }
    }
    if(!self.gridView)
    {
        
        CGFloat t5 = self.contentScale;
        
        
        self.gridView = [[[MysticGridView alloc] initWithFrame:self.view.bounds] autorelease];
        self.gridView.columns = 2;
        self.gridView.rows = 2;
        self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        //        self.gridView.blockSize = [MysticUI scaleSize:CGSizeMake(40, 40) scale:t5];
        self.gridView.dashSize = [MysticUI scaleSize:CGSizeMake(1, 4) scale:t5];
        self.gridView.alpha = 0;
        self.gridView.borderWidth = self.gridView.borderWidth*t5;
        
        [self.view addSubview:self.gridView];
        [self.view sendSubviewToBack:self.gridView];
        
        self.gridView.backgroundColor = [[UIColor mysticDarkBackgroundColor] colorWithAlphaComponent:0.45];

        [self.gridView setNeedsDisplay];
        
        __unsafe_unretained __block MysticResizeableLayersViewController *weakSelf = self;
        
        
        if(animated && self.gridView.alpha != 1.0f)
        {
            
            self.gridViewIsAnimating = YES;
            [MysticUIView animateWithDuration:0.2 animations:^{
                weakSelf.gridView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                weakSelf.gridViewIsAnimating = NO;
            }];
        }
        else if(!self.gridViewIsAnimating)
        {
            self.gridView.alpha = 1.0f;
            weakSelf.gridViewIsAnimating = NO;
        }
    }
    
    
    
    
    [self delegate:@selector(overlaysViewDidShowGrid:) object:self.overlaysView];

    if([self.delegate respondsToSelector:@selector(layersViewDidChangeGrid:isHidden:)])
    {
        [self.delegate layersViewDidChangeGrid:self.overlaysView isHidden:NO];
    }
    
    
}
- (void) toggleGrid:(id)sender;
{
    [self toggleGrid:sender animated:YES force:NO];
}
- (void) toggleGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    if(self.isGridHidden)
    {
        [self showGrid:sender animated:animated force:forceIt];
    }
    else
    {
        [self hideGrid:sender animated:animated force:forceIt];
    }
}
- (void) hideGrid:(id)sender;
{
    [self hideGrid:sender animated:NO force:NO];
}
- (void) hideGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    
    if(!self.allowGridViewToHide && !forceIt) return;
    
    
    if(sender) self.shouldShowGridOnOpen = NO;
    

    
    [self delegate:@selector(overlaysViewWillHideGrid:) object:self.overlaysView];

    if(self.gridView)
    {
        __unsafe_unretained __block MysticResizeableLayersViewController *weakSelf = self;
        __unsafe_unretained __block MysticBlock _finishedAnim = ^{
            if(weakSelf.gridView)
            {
                [weakSelf.gridView removeFromSuperview];
                weakSelf.gridView=nil;
            }
            weakSelf.gridViewIsAnimating = NO;
        };
        __unsafe_unretained __block MysticBlock finishedAnim = Block_copy(_finishedAnim);
        
        
        if(animated && self.gridView.alpha != 0.0f && !self.gridViewIsAnimating)
        {
            self.gridViewIsAnimating = YES;
            [MysticUIView animateWithDuration:0.15f animations:^
             {
                 weakSelf.gridView.alpha = 0.0f;
             }
                             completion:^(BOOL finished)
             {
                 finishedAnim();
                 Block_release(finishedAnim);
             }];
        }
        else if(!self.gridViewIsAnimating)
        {
            finishedAnim();
            Block_release(finishedAnim);
            
        }
        
        
        
    }
    
   
    [self delegate:@selector(overlaysViewDidHideGrid:) object:self.overlaysView];
    if([self.delegate respondsToSelector:@selector(layersViewDidChangeGrid:isHidden:)])
    {
        [self.delegate layersViewDidChangeGrid:self.overlaysView isHidden:YES];
    }
}
- (void) finishedMovingLayers:(NSArray *)layerViews;
{

}
- (void) moveLayers:(NSArray *)layerViews distance:(CGPoint)diffPoint;
{
    
    if(layerViews.count)
    {
        for (MysticLayerView *otherLayer in layerViews) {
            
            otherLayer.center = CGPointAdd(otherLayer.center, diffPoint);
        }
    }
}
- (void)layerViewDidBeginMoving:(MysticLayerView *)layerView;
{
    startPoint = layerView.center;
}
- (void)layerViewDidMove:(MysticLayerView *)layerView;
{
    endPoint = layerView.center;
    CGPoint diffPoint = CGPointDiff(endPoint, startPoint);
    [self moveLayers:[self selectedLayers:@[layerView]] distance:diffPoint];
    
    if(![self delegate:@selector(layerViewDidMove:) object:layerView perform:YES])
    {
   
        if(!self.gridView) {
            
            [self showGrid:nil];
        }
    }
    
    startPoint = layerView.center;


}

- (void)layerViewDidEndMoving:(MysticLayerView *)layerView;
{
    
    [self finishedMovingLayers:[self selectedLayers:@[layerView]]];
    if(![self delegate:@selector(layerViewDidEndMoving:) object:layerView perform:YES])
    {
        if(self.gridView) {
            [self hideGrid:nil animated:YES force:YES];
            [self moveLayersOutOfBackground];
        }
    }
    if(self.hasLayersInBackground)
    {
        [self moveLayersOutOfBackground];
    }
    
}
- (void)layerViewDidCancelMoving:(MysticLayerView *)layerView;
{
    [self layerViewDidEndMoving:layerView];
    
//    if(self.gridView) {
//        [self hideGrid:nil];
//    }
//    if([self.delegate respondsToSelector:@selector(layerViewDidEndTransform:)])
//    {
//        [self.delegate layerViewDidEndTransform:layerView];
//    }
}
- (void)layerViewDidClose:(MysticLayerView *)layerView
{
    [self layerViewDidClose:layerView notify:YES];
}
- (void)layerViewDidClose:(MysticLayerView *)layerView  notify:(BOOL)shouldNotify;
{

    [self delegate:@selector(layerViewDidClose:) object:layerView perform:shouldNotify];

    [self removeOverlay:layerView];

}


#pragma mark - doubleTappedLayer:
- (void) layerViewDidDoubleTap:(MysticLayerView *)layerView;
{
    [self layerViewDidDoubleTap:layerView notify:YES];
}
- (void) layerViewDidDoubleTap:(MysticLayerView *)layerView  notify:(BOOL)shouldNotify;
{
    if(!layerView.enabled && !layerView.selected) return;
    self.keyObjectLayer = layerView;
    if(!layerView.enabled) [layerView setEnabledAndKeepSelection:YES];
    if(!layerView.selected) [layerView setSelected:YES notify:NO];
    if(layerView.selected && layerView.hasHiddenControls) [layerView showControls:NO];

    [self delegate:@selector(layerViewDidDoubleTap:) object:layerView perform:shouldNotify];

//    [layerView becomeFirstResponder];
}
- (void) layerViewDidSingleTap:(MysticLayerView *)layerView;
{
    [self layerViewDidSingleTap:layerView notify:YES];
}
- (void) layerViewDidSingleTap:(MysticLayerView *)layerView notify:(BOOL)shouldNotify;
{

    if(!layerView.enabled) return;
    [layerView setSelected:!layerView.selected notify:shouldNotify];
    self.keyObjectLayer = layerView.selected ? layerView : nil;

 
    [self delegate:@selector(layerViewDidSingleTap:) object:layerView perform:shouldNotify];

}

- (void) layerViewDidSelect:(MysticLayerView *)layerView;
{
    [self layerViewDidSelect:layerView notify:YES];
}
- (void) layerViewDidSelect:(MysticLayerView *)layerView  notify:(BOOL)shouldNotify;
{

    [self delegate:@selector(layerViewDidSelect:) object:layerView perform:shouldNotify];
    MysticController *editController = (MysticController *)self.delegate;
    
    if(layerView.selected)
    {
        [self activateLayer:layerView notify:shouldNotify];
    }
    else
    {
        [self deactivateLayer:layerView notify:shouldNotify];
    }
    
}
- (void) deactivateLayer:(MysticLayerView *)layerView;
{
    [self deactivateLayer:layerView notify:YES];
}
- (void) deactivateLayer:(MysticLayerView *)layerView notify:(BOOL)shouldNotify;
{
    if(layerView.selected) [layerView setSelected:NO notify:shouldNotify];
    
   // [self deselectLayersExcept:(MysticLayerView *)layerView];
    
    self.keyObjectLayer = self.keyObjectLayer == layerView ? nil : self.keyObjectLayer;
    [self delegate:@selector(layerViewDidDeactivate:) object:layerView perform:shouldNotify];
  
}
- (void) activateLayer:(MysticLayerView *)layerView;
{
    [self activateLayer:layerView notify:YES];
}
- (void) activateLayer:(MysticLayerView *)layerView notify:(BOOL)shouldNotify;
{
//    [self.overlaysView bringSubviewToFront:layerView];
    if(!layerView.selected) [layerView setSelected:YES notify:shouldNotify];
    
    [self deselectLayersExcept:(MysticLayerView *)layerView notify:NO];
    
     [self delegate:@selector(layerViewDidActivate:) object:layerView perform:shouldNotify];
    
}
- (void) layerViewWillLongPress:(MysticLayerView *)layerView;
{
    [self layerViewWillLongPress:layerView gesture:nil];
}
- (void) layerViewWillLongPress:(MysticLayerView *)layerView gesture:(UILongPressGestureRecognizer *)gesture;
{
    [self longPress:gesture layer:layerView];

}
- (void) layerViewDidLongPress:(MysticLayerView *)layerView;
{
    [self layerViewDidLongPress:layerView gesture:nil];

}
- (void) layerViewDidLongPress:(MysticLayerView *)layerView gesture:(UILongPressGestureRecognizer *)gesture;
{
    if(!layerView.enabled) return;
    [self longPress:gesture layer:layerView];

    if(![self delegate:@selector(layerViewDidLongPress:gesture:) object:layerView object:gesture])
    {
        [self delegate:@selector(layerViewDidLongPress:) object:layerView perform:YES];
    }
    
}

//- (void) layerViewDebug:(NSString *)str;
//{
//    debug.text = str;
//}

- (void) layerViewDidBeginEditing:(MysticLayerView *)layerView;
{
    
    [self delegate:@selector(layerViewDidBeginEditing:) object:layerView perform:YES];
    
    
}



- (void) layerViewDidEndEditing:(MysticLayerView *)layerView;
{
    [self delegate:@selector(layerViewDidEndEditing:) object:layerView perform:YES];
    
}
- (BOOL) delegate:(SEL)action object:(id)obj;
{
    if(!self.delegate || ![self.delegate respondsToSelector:action]) return NO;
    [self.delegate performSelector:action withObject:obj];
    return YES;
}
- (BOOL) delegate:(SEL)action object:(id)obj object:(id)obj2;
{
    if(!self.delegate || ![self.delegate respondsToSelector:action]) return NO;
    [self.delegate performSelector:action withObject:obj withObject:obj2];
    return YES;
}
- (BOOL) delegate:(SEL)action object:(id)obj perform:(BOOL)perform;
{
    if(!perform) return NO;
    return [self delegate:action object:obj];
}
- (BOOL) delegate:(SEL)action perform:(BOOL)perform;
{
    return [self delegate:action object:self perform:perform];
}
- (BOOL) delegate:(SEL)action;
{
    return [self delegate:action object:self perform:YES];
}

- (NSArray *) selectedLayers;
{
    return [self selectedLayers:nil];
}
- (NSArray *) selectedLayers:(NSArray *)except;
{
    NSMutableArray *selections = [NSMutableArray array];
    for (MysticLayerView *layer in self.overlays) {
        if(except && except.count && [except containsObject:layer])
        {
            continue;
            
        }
        if(layer.selected) [selections addObject:layer];
        
    }
    return selections;
}
- (void) deselectAll;
{
    [self deselectLayersExcept:nil];
}
- (NSArray *) selectAll;
{
    return [self selectAll:nil];
}
- (NSArray *) selectAll:(NSArray *)except;
{
    NSMutableArray *selections = [NSMutableArray array];
    for (MysticLayerView *layer in self.overlays) {
        if(except && except.count && [except containsObject:layer])
        {
            if(layer.selected) [layer setSelected:NO notify:NO];
            continue;
            
        }
        if(!layer.selected) [layer setSelected:YES notify:NO];
        [selections addObject:layer];
        
    }
    return selections;
}



- (NSArray *) selectLayers:(NSArray *)layers;
{
    for (MysticLayerView *layer in self.overlays) {
        BOOL shouldSelect = [layers containsObject:layer];
        if(layer.selected != shouldSelect) [layer setSelected:shouldSelect notify:NO];
    }
    return layers;
}

- (void) deselectLayersExcept:(MysticLayerView *)except;
{
    [self deselectLayersExcept:except notify:YES];
}
- (void) deselectLayersExcept:(MysticLayerView *)except notify:(BOOL)shouldNotify;
{
    if(!self.count) return;
    
    BOOL deactivated = NO;
    for (MysticLayerView *z in self.layers) {
        
        BOOL didit = NO;
        BOOL f = except && except == z;
        if(!except || (z != except && z.selected))
        {
            didit = YES;
            [z setSelected:NO notify:shouldNotify];
        }
        
    }
   
    
}

#pragma mark - Set Focused Layer

- (id) keyObjectLayer;
{
    if(_keyObjectLayer && [(UIView *)_keyObjectLayer superview])
    {
        return _keyObjectLayer;
    }
    return self.selectedLayer;
}


- (void) setKeyObjectLayer:(id)layer;
{
    if(_keyObjectLayer && layer != _keyObjectLayer && [self.delegate respondsToSelector:@selector(layerViewDidLoseKeyObject:)]) [self.delegate layerViewDidLoseKeyObject:layer];
    _keyObjectLayer = layer;
    if(_keyObjectLayer && [self.delegate respondsToSelector:@selector(layerViewDidBecomeKeyObject:)]) [self.delegate layerViewDidBecomeKeyObject:layer];
}
- (BOOL) hasKeyObjectLayer; { return _keyObjectLayer != nil && [(UIView *)_keyObjectLayer superview] != nil; }
- (BOOL) isLayerKeyObject:(id)layer; { return layer && _keyObjectLayer == layer; }

- (CGFrameBounds) newOverlayFrame;
{
    CGRect frame = CGRectSize(CGSizeSquareSmall((CGSize){CGRectW(self.overlaysView.frame) * MYSTIC_DEFAULT_NEW_OVERLAY_SCALE_WIDTH, CGRectH(self.overlaysView.frame) * MYSTIC_DEFAULT_NEW_OVERLAY_SCALE_HEIGHT}));
    return (CGFrameBounds){frame,frame};
}
#pragma mark - Overlays
- (id) makeOverlay:(PackPotionOptionView *)option;
{
    return [self makeOverlay:(id)option frame:CGRectZero context:nil];
}
- (id) makeOverlay:(PackPotionOptionView *)option frame:(CGRect)newFrame context:(MysticDrawingContext **)context;
{
    numberOfOverlaysMade++;
    option = option ? option : (PackPotionOptionView *)[[[self class] optionClass] optionWithName:[NSString stringWithFormat:@"%@ Layer %lu", [self class], (unsigned long)self.overlays.count] info:nil];
    MysticLayerView *newOverlay = [[[self layerViewClass] alloc] initWithFrame:CGRectIsZero(newFrame) ? self.newOverlayFrame.frame : newFrame];
    newOverlay.layersView = (id)self.overlaysView;
    newOverlay.enabled = self.enabled;
    newOverlay.editable = YES;
    newOverlay.index = self.nextLayerIndex;
    newOverlay.tag = numberOfOverlaysMade;
    newOverlay.delegate = self;
    newOverlay.parentView = self.parentView;
    newOverlay.option = option;
    return [newOverlay autorelease];
    
}

- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option;
{
    return [self duplicateLayer:layer option:option animated:YES];
}
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option animated:(BOOL)animated;
{
    return [self duplicateLayer:layer option:option animated:animated offset:CGPointZero];
}
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option animated:(BOOL)animated offset:(CGPoint)offsetPoint;
{
    MysticLayerBaseView *clonedLayer = layer ? layer : self.keyObjectLayer;
    MysticDrawingContext *cloneContext = clonedLayer ? clonedLayer.drawContext : nil;

    MysticLayerView *newOverlay = [self makeOverlay:(id)option frame:clonedLayer.frame context:cloneContext ? &cloneContext : nil];
    CGRect newFrame = newOverlay.frame;
    [self activateLayer:newOverlay notify:NO];
    [self addOverlay:newOverlay];
    
    CGPoint c = CGPointMake(self.originalFrame.size.width/2, self.originalFrame.size.height/2);
    newOverlay.center = !CGPointIsZero(offsetPoint) ?  CGPointAdd(c, offsetPoint) : c;
    
    [self deselectLayersExcept:newOverlay];
    
    if([self.delegate respondsToSelector:@selector(layersViewDidAddLayer:)]) [self.delegate layersViewDidAddLayer:newOverlay];
    [newOverlay applyOptionsFrom:(id)clonedLayer];
    newOverlay.option = (id)layer.option;
    newOverlay.rotation = layer.rotation;
    newOverlay.alpha = layer.alpha;
    newOverlay.color = layer.color;
    self.keyObjectLayer = newOverlay;
    return newOverlay;
}

#pragma mark - Add Layer

- (void) addLayer:(id)overlay; {    [self addOverlay:overlay]; }
- (void) addOverlay:(MysticLayerBaseView *)overlay;
{
    [self.overlaysView addSubview:overlay];
    [self addToStack:(id)overlay];
    if(!overlay.shouldRedraw)
    {
        overlay.shouldRedraw = YES;
        [overlay redraw:NO];
    }
}
- (id) addNewOverlayAndMakeKeyObject:(BOOL)copyLastOverlay;
{
    self.keyObjectLayer = [self addNewOverlay:copyLastOverlay];
    return self.keyObjectLayer;
}

- (id) addNewOverlay;
{
    return [self addNewOverlay:YES];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay;
{
    PackPotionOptionView *option = (PackPotionOptionView *)[[[self class] optionClass] optionWithName:[NSString stringWithFormat:@"%@ Layer %lu", [self class], (unsigned long)self.overlays.count] info:nil];
    return [self addNewOverlay:copyLastOverlay option:option];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option;
{
    return [self addNewOverlay:copyLastOverlay option:option frame:CGRectZero];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame;
{
    return [self addNewOverlay:copyLastOverlay option:option frame:newFrame animated:YES];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame animated:(BOOL)animated;
{
    int c = self.count;
    MysticLayerBaseView *lastOverlay = copyLastOverlay ? self.lastOverlay : nil;
    MysticDrawingContext *lastContext = lastOverlay ? lastOverlay.drawContext : nil;
    MysticLayerView *newOverlay = [self makeOverlay:option frame:newFrame context:lastContext ? &lastContext : nil];
    CGFloat a = newOverlay.alpha;
    newOverlay.alpha = animated ? 0 : a;
    [self addOverlay:newOverlay];
    [self activateLayer:newOverlay notify:NO];

//    newOverlay.center = (CGPoint){self.originalFrame.size.width/2, self.originalFrame.size.height/2};
    newOverlay.center = (CGPoint){self.overlaysView.frame.size.width/2, self.overlaysView.frame.size.height/2};

    [self deselectLayersExcept:newOverlay];
    if([self.delegate respondsToSelector:@selector(layersViewDidAddLayer:)]) [self.delegate layersViewDidAddLayer:newOverlay];
    if(lastOverlay && copyLastOverlay) [newOverlay applyOptionsFrom:lastOverlay];
    if(c > 0) newOverlay.center = [self layer:(id)newOverlay centerWithOffset:[self offsetPointForLayer:newOverlay]];
    if(animated)
    {
        CGAffineTransform t = newOverlay.transform;
        newOverlay.transform = CGAffineTransformScale(newOverlay.transform, 1.25, 1.25);
        [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            newOverlay.transform = t;
            newOverlay.alpha = a;
        } completion:nil];
    }
    return newOverlay;
}

- (void) changedLayer:(MysticLayerView *)sticker; { [sticker update]; }
- (BOOL) hasSelectedNone; { return self.selectedCount == 0; }
- (BOOL) hasSelectedAll;
{
    int c = self.count;
    return c > 0 && self.selectedLayers.count == c;
}

- (id) cloneLayer:(id)layer; { return layer; }
- (NSArray *) layers; { return self.overlays; }

- (NSArray *) overlays;
{
    NSMutableArray *o = [NSMutableArray array];
    for(MysticLayerView *layerView  in self.overlaysView.subviews){
        if([layerView conformsToProtocol:@protocol(MysticLayerViewAbstract)]) [o addObject:layerView];
    }
    return o;
}
- (void) removeOverlays; { [self removeOverlays:nil]; }
- (void) removeOverlay:(id <MysticLayerViewAbstract>)layerViewOrViews; { [self removeLayer:layerViewOrViews]; }
- (void) replaceLayer:(id)layer withLayer:(id)newLayer;
{
    if(!layer || !newLayer) return;
    [self replaceLayerInStack:layer withLayer:newLayer];
}
- (void) removeLayer:(id)layerViewOrViews;
{
    NSArray *layers = [layerViewOrViews isKindOfClass:[NSArray class]] ? (id)layerViewOrViews : @[layerViewOrViews];
    for (id <MysticLayerViewAbstract> layerView in layers) {
        if(layerView && [layerView conformsToProtocol:@protocol(MysticLayerViewAbstract)])
        {
            [layerView retain];
            if([self.delegate respondsToSelector:@selector(layerViewWillRemove:)]) [self.delegate layerViewWillRemove:layerView];
            self.keyObjectLayer = self.keyObjectLayer == layerView ? nil : self.keyObjectLayer;
            [self removeFromStack:layerView];
            [layerView removeFromSuperview];
            if([self.delegate respondsToSelector:@selector(layerViewDidRemove:)]) { [self.delegate layerViewDidRemove:layerView]; }
            [layerView release];
        }
    }
}
- (void) removeLayers:(NSArray *)layers;
{
    layers = layers ? layers : self.layers;
    for (MysticLayerBaseView *layer in layers) {
        [self removeLayer:layer];
    }
}
- (void) removeOverlays:(NSArray *)layers;
{
    [self removeLayers:layers];
}
- (void) removeOverlaysExcept:(NSArray *)exceptions;
{
    [self removeSubviews:self.overlaysView except:exceptions];
}


- (NSArray *) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
{
    NSMutableArray *removed = [NSMutableArray array];
//    @autoreleasepool {

        for (UIView *subview in parentView.subviews) {
            if([subview conformsToProtocol:@protocol(MysticLayerViewAbstract)] && (!exceptions || ![exceptions containsObject:subview]))
            {
                [removed addObject:subview];
                [self removeOverlay:(id <MysticLayerViewAbstract>)subview];
            }
        }
//    }
    return removed;
}



- (PackPotionOptionView *) confirmOverlays;
{
    return [self confirmOverlaysComplete:nil];
}
- (PackPotionOptionView *) confirmOverlaysComplete:(MysticBlockObject)finished;
{
    
    PackPotionOptionView *confirmed = nil;
    if([self.overlays count])
    {
        confirmed = [[[self class] optionClass] optionWithName:@"layer" info:nil];
        [confirmed setOverlaysView:self.overlaysView];
    }
    return [self confirmOverlays:confirmed complete:finished];
    
    
}
- (PackPotionOptionView *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
{
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    [self hideGrid:nil];
    [self disableOverlays];
    MysticObjectType optionType = newOption ? newOption.type : MysticObjectTypeFont;
    PackPotionOption *oldOption = [UserPotion optionForType:optionType];
    [UserPotion removeOptionForType:optionType cancel:NO];
    if(newOption)
    {
        newOption.overlaysView = self.overlaysView;
        [newOption setUserChoice:YES finished:nil];
        if(oldOption)
        {
            [newOption applyAdjustmentsFrom:oldOption];
        }
    }
    if(complete) complete(newOption);
    return newOption;
}

- (void) cancelOverlays:(MysticBlockObject)finished;
{
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    [self hideGrid:nil];
    //[self disableOverlays];
    self.overlaysView.userInteractionEnabled = NO;
    [self removeOverlays];
    if(finished) finished(nil);
    
}

- (void) disableOverlays;
{
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    self.enabled = NO;
    self.overlaysView.userInteractionEnabled = NO;
    
    
}
- (void) enableOverlays;
{
    self.allowGridViewToHide = YES;
    self.allowGridViewToShow = YES;
    self.enabled = YES;
    if(showGridOnOpen) [self showGrid:nil];
    self.overlaysView.userInteractionEnabled = YES;
}

- (void) ignoreOverlays:(BOOL)ignore;
{
    self.enabled = !ignore;
    self.overlaysView.userInteractionEnabled = !ignore;
    self.overlaysView.hidden = ignore;
}


- (id) lastOverlay;
{
    return [self lastOverlay:NO];
}
- (id) lastOverlay:(BOOL)make;
{
    
    MysticLayerView *l = self.selectedLayer;
    if(!l)
    {
        l = [self.overlays lastObject];
    }
    if(!l && make)
    {
        l = [self addNewOverlay];
    }
    return l;
}
- (id) lastOverlayWithOption:(PackPotionOptionView *)option;
{
    
    MysticLayerView *l = self.selectedLayer;
    if(!l)
    {
        l = [self.overlays lastObject];
    }
    if(!l && option)
    {
        l = [self addNewOverlay:NO option:option];
    }
    return l;
}
- (int) count;
{
    return (int)self.overlays.count;
}
- (int) selectedCount;
{
    return (int)self.selectedLayers.count;
}
- (int) unselectedCount;
{
    return (int)(self.count - self.selectedCount);
}
- (BOOL) hasSelectedLayers;
{
    return self.selectedLayers.count > 1;
}
- (BOOL) hasSelectedLayer;
{
    return self.selectedLayer != nil;
}
- (id) selectedLayer;
{
    for (MysticLayerView *sticker in self.overlays) {
        if(sticker.selected) return sticker;
    }
    return nil;
}

- (void) setSelectedLayer:(MysticLayerView *)value
{
    value.selected = YES;
}

- (void) setEnabled:(BOOL)enabled;
{
    _enabled = enabled;
    self.view.userInteractionEnabled = enabled;
    for(MysticLayerView *layerView  in self.overlays){
        layerView.enabled = enabled;
    }
}

- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
{
    CGSize renderSize;
    
    CGRect fit = [MysticUI aspectFit:[MysticUI rectWithSize:self.overlaysView.frame.size] bounds:[MysticUI rectWithSize:bounds]];
    renderSize = fit.size;
    return [self imageByRenderingView:nil size:renderSize scale:0];
}
- (UIImage *)renderedImageWithSize:(CGSize)renderSize;
{
    return [self imageByRenderingView:nil size:renderSize scale:0];
}
- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
{
    //    NSString *t = [NSString stringWithFormat:@"render size: %2.1f", scale];
    for (UIView *subview in self.overlaysView.subviews) {
        if(![subview conformsToProtocol:@protocol(MysticLayerViewAbstract)])
        {
            subview.hidden = YES;
        }
    }
    CGRect rect = CGRectZero;
    rect.size = renderSize;
    CGSize layersViewSize = self.originalFrame.size;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldSmoothFonts(context, YES);
    CGContextSetShouldAntialias(context, YES);
    if(img)
    {
        CGContextSaveGState(context);
        CGRect irect = CGRectMake(0, 0, img.size.width, img.size.height);
        irect.origin = CGPointMake(rect.size.width/2 - irect.size.width/2, rect.size.height/2 - irect.size.height/2);
        irect.origin = CGPointZero;
        irect.size = rect.size;
        
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        
        
        CGContextDrawImage(context, irect, img.CGImage);
        CGContextRestoreGState(context);
    }
    //    CGAffineTransform trans = self.transform;
    if(layersViewSize.width != renderSize.width || layersViewSize.height != renderSize.height)
    {
        CGSize scaleSize = CGSizeMake(renderSize.width/layersViewSize.width, renderSize.height/layersViewSize.height);
        
        CGContextScaleCTM(context, scaleSize.width, scaleSize.height);
    }
    
    
    
    [self.overlaysView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    for (UIView *subview in self.overlaysView.subviews) {
        if(![subview conformsToProtocol:@protocol(MysticLayerViewAbstract)])
        {
            subview.hidden = NO;
        }
    }
    
    //    self.transform = trans;
    return resultingImage;
}


#pragma mark - Stacking
- (UIView *)viewBelowStack;
{
    return self.backgroundOverlayView ? self.backgroundOverlayView : (self.isGridHidden ? nil : self.gridView);
}
- (void) exchangeLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView;
{
    [self exchangeLayerInStack:layerView withLayer:newLayerView save:YES restack:YES];
}
- (void) exchangeLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView save:(BOOL)saveStack restack:(BOOL)restack;
{
    [self exchangeLayerAtStackPosition:[self.stack indexOfObject:layerView] withLayerAtPosition:[self.stack indexOfObject:newLayerView] save:saveStack restack:restack];
}
- (void) exchangeLayerAtStackPosition:(NSInteger)lsIndex withLayerAtPosition:(NSInteger)nsIndex;
{
    [self exchangeLayerAtStackPosition:lsIndex withLayerAtPosition:nsIndex save:YES restack:YES];
}
- (void) exchangeLayerAtStackPosition:(NSInteger)lsIndex withLayerAtPosition:(NSInteger)nsIndex save:(BOOL)saveStack restack:(BOOL)restack;
{
    if(lsIndex==NSNotFound || nsIndex == NSNotFound) return;
    NSInteger lvIndex = [self.view.subviews indexOfObject:[self.stack objectAtIndex:lsIndex]];

    NSInteger nvIndex = [self.view.subviews indexOfObject:[self.stack objectAtIndex:nsIndex]];

    NSMutableArray *s = [NSMutableArray arrayWithArray:self.stack];

//    ALLog(@"exchange layer", @[@"at index", @(lsIndex),
//                               @"with index", @(nsIndex),
//                               @"-",
//                               @"restack", MBOOL(restack),
//                               @"at view", @(lvIndex),
//                               @"new view", @(nvIndex),
//                               ]);
    
    if(lsIndex!=NSNotFound && nsIndex != NSNotFound)
    {
        [s exchangeObjectAtIndex:lsIndex withObjectAtIndex:nsIndex];
    }
    if(restack && lvIndex!=NSNotFound && nvIndex != NSNotFound)
    {
        [self.view exchangeSubviewAtIndex:lvIndex withSubviewAtIndex:nvIndex];
    }
    
    
    if(saveStack)
    {
        self.stack = s;
    }
}
- (void) replaceLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView;
{
    [self replaceLayerInStack:layerView withLayer:newLayerView save:YES restack:YES];
}
- (void) replaceLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView save:(BOOL)saveStack restack:(BOOL)restack;
{
    if(!layerView || !newLayerView) return;
    NSInteger i = [self.stack indexOfObject:layerView];
    if(i!=NSNotFound)
    {

        NSMutableArray *s = [NSMutableArray arrayWithArray:self.stack];
        
        [s replaceObjectAtIndex:i withObject:newLayerView];
        [layerView removeFromSuperview];

        [self restack:s];
        if(saveStack)
        {
            self.stack = s;
        }
    }
}
- (BOOL) hasLayersInBackground;
{
    for(id <MysticLayerViewAbstract>layerView  in self.overlays){
    
        if(layerView.isInBackground) return YES;
            
    }
    return NO;
}
- (void) moveLayersOutOfBackground;
{
    int i = 0;
    for(id <MysticLayerViewAbstract>layerView  in self.overlays){
        if(layerView.isInBackground)
        {
            i++;
            layerView.isInBackground = NO;
        }
    }
    
    if(i > 0) [self restack];

    
}
- (void) moveLayersToBackgroundExcept:(NSArray *)exceptions;
{
    exceptions = exceptions ? exceptions : @[];
    int i = 0;
    for(id <MysticLayerViewAbstract>layerView  in self.overlays){
        if([exceptions containsObject:layerView]) continue;
        layerView.isInBackground = YES;
        i++;
        [self moveLayerToBottom:layerView save:NO];
        if(![self isGridHidden])
        {
            [self.view sendSubviewToBack:(UIView *)layerView];
            [(UIView *)layerView setAlpha:layerView.previousAlpha];
        }
    }

}
- (void) moveLayerUp:(id <MysticLayerViewAbstract>)layerView;
{
    [self moveLayerUp:layerView save:YES];
}
- (void) moveLayerUp:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
{
    NSInteger i = [self.stack indexOfObject:layerView];
    if(i!=NSNotFound && i < self.stack.count - 1)
    {
        [self exchangeLayerInStack:[self.stack objectAtIndex:i+1] withLayer:layerView save:saveStack restack:YES];

    }
}
- (void) moveLayerDown:(id <MysticLayerViewAbstract>)layerView;
{
    [self moveLayerDown:layerView save:YES];
}
- (void) moveLayerDown:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
{
    NSInteger i = [self.stack indexOfObject:layerView];
    if(i!=NSNotFound && i > 0)
    {
        [self exchangeLayerInStack:[self.stack objectAtIndex:i-1] withLayer:layerView save:saveStack restack:YES];
    }

}
- (void) moveLayerToTop:(id <MysticLayerViewAbstract>)layerView;
{
    [self moveLayerUp:layerView save:YES];
}
- (void) moveLayerToTop:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
{
    [self moveLayerToStackPosition:layerView position:NSIntegerMax save:saveStack restack:NO];
    [self.view bringSubviewToFront:(id)layerView];

}
- (void) moveLayerToBottom:(id <MysticLayerViewAbstract>)layerView;
{
    [self moveLayerToBottom:layerView save:YES];
}
- (id) moveLayerToBottom:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
{
    [self moveLayerToStackPosition:layerView position:0 save:saveStack restack:NO];
    if(self.stack.count > 1 && layerView != [self.stack objectAtIndex:0])
    {
        [self.view insertSubview:(id)layerView belowSubview:[self.stack objectAtIndex:0]];
    }
    if(self.viewBelowStack)
    {
        [layerView removeFromSuperview];
        [self.view insertSubview:(id)layerView aboveSubview:self.viewBelowStack];
    }
    else
    {
        [self.view sendSubviewToBack:(id)layerView];
    }
    return layerView;
}
- (void) moveLayerToStackPosition:(id <MysticLayerViewAbstract>)layerView position:(NSInteger)stackIndex;
{
    [self moveLayerToStackPosition:layerView position:stackIndex save:YES restack:YES];
}
- (void) moveLayerToStackPosition:(id <MysticLayerViewAbstract>)layerView position:(NSInteger)stackIndex save:(BOOL)saveStack;
{
    [self moveLayerToStackPosition:layerView position:stackIndex save:saveStack restack:YES];
}
- (void) moveLayerToStackPosition:(id <MysticLayerViewAbstract>)layerView position:(NSInteger)stackIndex save:(BOOL)saveStack restack:(BOOL)restack;
{
    NSMutableArray *s = [NSMutableArray arrayWithArray:self.stack];
    stackIndex = stackIndex == NSIntegerMax ? NSIntegerMax : MIN(self.stack.count - 1,  MAX(0, stackIndex == NSNotFound ? self.stack.count - 1 : stackIndex));
    NSInteger i = [self.stack indexOfObject:layerView];
    if(i == NSNotFound) return;
    [self exchangeLayerAtStackPosition:(stackIndex == NSIntegerMax ? self.stack.count - 1 : stackIndex) withLayerAtPosition:i save:saveStack restack:restack];
}

- (void) addToStack:(id <MysticLayerViewAbstract>)layerView;
{
    if(!layerView) return;
    [self.stack addObject:layerView];
    self.overlaysView.backgroundColor = self.overlaysView.lastLayerBackgroundColor;

//    [self printLayersStack];


}
- (void) removeFromStack:(id <MysticLayerViewAbstract>)layerView;
{
    if(!layerView) return;
    [self.stack removeObject:layerView];
    self.overlaysView.backgroundColor = self.overlaysView.lastLayerBackgroundColor;

//    [self printLayersStack];
    
    
}
- (void) restack;
{
    [self restack:self.stack];
}

- (void) restack:(NSArray *)stack;
{
    stack = stack == nil ? self.stack : stack;
    if(!stack.count) return;
    
    NSMutableArray *stack2 = [NSMutableArray arrayWithArray:stack];
    NSArray *removed = [self removeSubviews:self.view except:nil];

//    
//    if(removed.count && removed.count != stack.count)
//    {
//        ALLog(@"stack counts dont match for restack. Error may occur:",@[@"Removed", MObj(removed),
//                                                                         @"Stack", MObj(stack)]);
//        
//        int i = 0;
//    }
    
    
    for (id <MysticLayerViewAbstract> layerView in stack2) {
        [self.overlaysView addSubview:(id)layerView];
    }
    self.overlaysView.backgroundColor = [self.overlaysView.lastLayerBackgroundColor colorWithAlphaComponent:0];
    self.stack = stack2;
    
}
- (id) disposableLayer:(id)layer;
{
    return nil;
}

#pragma mark - Offset Point For Layer


- (id) hasLayerAtCenterPoint:(CGPoint)p;
{
    return [self hasLayerAtCenterPoint:p withinDistance:CGPointMake(5, 5)];
}
- (id) hasLayerAtCenterPoint:(CGPoint)p withinDistance:(CGPoint)radius;
{
    int i = 0;
    id <MysticLayerViewAbstract> foundLayer = nil;
    CGRect r;
    NSMutableString *centers = [NSMutableString string];
   
    for (id <MysticLayerViewAbstract> layer in self.layers) {
        [centers appendFormat:@"\n%@", PLogStrd(layer.center, 1)];

        if(CGPointEqualToPoint(p, layer.center))
        {
            i = 1;
            foundLayer = layer;
            [centers appendFormat:@" | %d", i];
            continue;
        }
        r = CGRectMakeAroundCenter(layer.center, radius);
        if(CGRectContainsPoint(r, p))
        {
            i = 2;
            foundLayer = layer;
            [centers appendFormat:@" | %d", i];
            continue;
        }
        if(fabsf((float)(p.y - layer.center.y)) <= 10)
        {
            i = 3;
            foundLayer = layer;
            [centers appendFormat:@" | %d", i];
            continue;
        }
        if(fabsf((float)(p.x - layer.center.x )) <= 10)
        {
            i = 4;
            foundLayer = layer;
            [centers appendFormat:@" | %d", i];
            continue;
        }
    }
    return foundLayer;
}

- (CGPoint) layer:(MysticLayerBaseView *)layer centerWithOffset:(CGPoint)offsetPoint;
{
    CGRect f = [layer frameForControl:MysticLayerControlContent];
    CGPoint startCenter = layer.center;
    CGRect contentFrame = layer.contentView.frame;
    CGPoint c = layer.contentView.center;
    CGFloat a = layer.offsetHeight;
    CGPoint bc = (CGPoint){self.overlaysView.bounds.size.width/2, self.overlaysView.bounds.size.height/2};
    c = [self.overlaysView convertPoint:c fromView:layer];
    c.x += !CGPointIsZero(offsetPoint) ? offsetPoint.x : c.x >= bc.x ? c.x - (a*1.f) : c.x + (a*1.f);
    c.y += !CGPointIsZero(offsetPoint) ? offsetPoint.y : c.y >= bc.y ? c.y - a : c.y + a;
    return c;
    
}
- (CGPoint) offsetPointForLayer:(id)layerOrLayers;
{
    NSDictionary *empty = [self emptyOffsetPointForLayer:layerOrLayers];
    CGPoint p = [empty[@"point"] CGPointValue];
    if(empty[@"found"])
    {
        empty = [self emptyOffsetPointForLayer:empty[@"found"]];
        p = [empty[@"point"] CGPointValue];
    }
    return p;
}
- (NSDictionary *) emptyOffsetPointForLayer:(id)layerOrLayers;
{
    int q = 0;
    CGPoint p = [self offsetPointForLayer:layerOrLayers quadrant:&q];
    NSArray *lyrs = [layerOrLayers isKindOfClass:[NSArray class]] ? layerOrLayers : @[layerOrLayers];
    // loop through 4 quadrants and get the offset for that quadrant and check if a layer exists at that point
    int nq = q;
    BOOL foundSpot = NO;
    id nextLayerToCheck = nil;
    for (int qi = 1; qi <= 4; qi++) {
        id foundCenter = nil;
        for (id <MysticLayerViewAbstract>layer  in lyrs) {
            foundCenter = [self hasLayerAtCenterPoint:[self layer:(id)layer centerWithOffset:p]];
            if(foundCenter) break;
        }
        
        if(!foundCenter)
        {
            foundSpot = YES;
            q = nq; break;
        }
        else
        {
            nextLayerToCheck = foundCenter;
            if(qi == q) qi++;
            nq = qi;
            p = [self offsetPointForLayer:layerOrLayers quadrant:&nq];
        }
    }
    
    return !foundSpot ? @{@"point": [NSValue valueWithCGPoint:p], @"found": nextLayerToCheck} : @{@"point": [NSValue valueWithCGPoint:p]};
}


- (CGPoint) offsetPointForLayer:(id)layerOrLayers quadrant:(int *)quadrant;
{
    MysticLayerBaseView *l = [layerOrLayers isKindOfClass:[NSArray class]] ? [layerOrLayers lastObject] : layerOrLayers;
    CGRect f, b, tlb;
    CGPoint p, c, bc;
    CGFloat a = NAN;
    c = CGPointZero;
    b = self.overlaysView.bounds;
    bc = (CGPoint){b.size.width/2, b.size.height/2};
    p = bc;
    if([layerOrLayers isKindOfClass:[NSArray class]])
    {
        tlb = CGRectZero;
        tlb.origin.x = CGFLOAT_MAX;
        tlb.origin.y = CGFLOAT_MAX;
        for (l in layerOrLayers) {
            a = isnan(a) ? l.offsetHeight : MIN(a, l.offsetHeight);
            tlb.origin.x = MIN(tlb.origin.x, l.frame.origin.x);
            tlb.origin.y = MIN(tlb.origin.y, l.frame.origin.y);
            tlb.size.width = MAX(l.frame.origin.x + l.frame.size.width, tlb.size.width);
            tlb.size.height = MAX(l.frame.origin.y + l.frame.size.height, tlb.size.height);
        }
        tlb.size.width -= tlb.origin.x;
        tlb.size.height -= tlb.origin.y;
        p = (CGPoint){tlb.origin.x+tlb.size.width/2, tlb.origin.y+tlb.size.height/2};
    }
    else if([layerOrLayers isKindOfClass:[NSDictionary class]])
    {
        p = [[(NSDictionary *)layerOrLayers objectForKey:@"center"] CGPointValue];
        a = [[(NSDictionary *)layerOrLayers objectForKey:@"offsetHeight"] floatValue];
    }
    else
    {
        p = [self.overlaysView convertPoint:l.contentView.center fromView:l];
        a = l.offsetHeight;
    }
    
    int q = *quadrant;
    int nq = q;
    int qx = 0;
    int qy = 0;
    switch (q) {
        case 0:
        {
            if(p.x >= bc.x) qx = 1;
            if(p.y >= bc.y) qy = 1;
            break;
        }
        case 1:
        {
            qx = 0; qy = 0;
            break;
        }
        case 2:
        {
            qx = 1; qy = 0;
            break;
        }
        case 3:
        {
            qx = 0; qy = 1;
            break;
        }
        case 4:
        {
            qx = 1; qy = 1;
            break;
        }
        default: break;
    }
    
    if(qx == 0 && qy == 0)
    {
        nq = 1;
    }
    else if(qx == 1 && qy == 0)
    {
        nq = 2;
    }
    else if(qx == 0 && qy == 1)
    {
        nq = 3;
    }
    else if(qx == 1 && qy == 1)
    {
        nq = 4;
    }
    *quadrant = nq;
    
    c.x = qx ? -(a*1.f) : (a*1.f);
    c.y = qy ? -1*a : a;
    return c;
}

- (void) printLayersStack;
{
    [self printLayersStack:self.stack title:@"Stack"];
    [self printLayersStack:self.view.subviews title:@"Subviews"];
}
- (void) printLayersStack:(NSArray *)layerStack title:(NSString *)title;
{
    layerStack = layerStack ? layerStack : self.stack;
    NSMutableString *s = [NSMutableString stringWithFormat:@"\n\n\t\t\t%@: %d layers\n", title ? title : @"Layers",  (int)layerStack.count];
    int i = layerStack.count - 1;
    
    BOOL foundBtm = NO;
    for (i = layerStack.count - 1; i >= 0; i--) {
        id <MysticLayerViewAbstract>layerView = [layerStack objectAtIndex:i];
        BOOL isLayer = [layerView conformsToProtocol:@protocol(MysticLayerViewAbstract)];
        if(!foundBtm && !isLayer)
        {
            foundBtm = YES;
            [s appendString:@"\n"];
        }
        
        [s appendFormat:@"\n\t\t\t\t%d.  #%d:  %@   %@   %@  %d %p  %@  %@ ",
            i+1,
            isLayer ? layerView.index : 0,
            isLayer ? (!layerView.enabled ? @"disabled" : @"        ") : @"        ",
            isLayer ? (layerView.selected ? @"selected" : @"        ") : @"        ",
            isLayer ? layerView.description : NSStringFromClass([layerView class]),
            i,
            layerView,
            isLayer ? layerView.superview != nil ? @"Superview" : @"----" : @"",
            isLayer ? (layerView.hidden ? @"hidden" : @"showing") : @""
            ];
    }
    DLog(@"%@\n\n\n", s);
}

@end

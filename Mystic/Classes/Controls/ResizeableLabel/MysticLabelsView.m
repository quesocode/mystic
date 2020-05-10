//
//  MysticLabelsView.m
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLabelsView.h"
#import <QuartzCore/QuartzCore.h>
#import "MysticDotView.h"
#import "UIView+ColorOfPoint.h"
#import "UserPotion.h"
#import "MysticUser.h"
#import "AppDelegate.h"


@interface MysticLabelsView ()
{
    UILabel *debug;
    BOOL showedGridOnMove, hasShownGrid;
}

@end
@implementation MysticLabelsView

@synthesize delegate=_delegate, selectedLayer, gridView=_gridView, shouldShowGridOnOpen, hasLayers, originalFrame, shouldAddNewTextOverlay;

static BOOL showGridOnOpen = NO;

- (void) dealloc;
{
    [_gridView release];
    _delegate = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        showedGridOnMove = NO;
        // Initialization code
        self.clipsToBounds = YES;
        self.autoresizesSubviews = NO;
        self.allowGridViewToHide = YES;
        self.allowGridViewToShow = YES;
        self.gridViewIsAnimating = NO;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:gesture];

    }
    return self;
}
- (void) tapped:(UITapGestureRecognizer *)recognizer;
{
//    [self deselectLayersExcept:nil notify:NO];
    if([self.delegate respondsToSelector:@selector(layersViewDidTap:)])
    {
        [self.delegate layersViewDidTap:self];
    }
    
//    if([self.delegate respondsToSelector:@selector(layersViewDidDeselectAll:)])
//    {
//        [self.delegate layersViewDidDeselectAll:self];
//    }
}
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLabel class]])
        {
            subview.hidden = YES;
        }
    }
}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLabel class]])
        {
            subview.hidden = NO;
        }
    }
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

- (BOOL) shouldAddNewTextOverlay;
{
    if(!self.overlays.count) return YES;
    for (MysticResizeableLabel *l in self.overlays) {
        if([l.text isEqualToString:MysticDefaultFontText]) return NO;
    }
    return YES;
}

- (MysticResizeableLabel *) newestOverlay;
{
    return [self labelWithText:MysticDefaultFontText];
}
- (MysticResizeableLabel *) labelWithText:(NSString *)labelText;
{
    if(!self.overlays.count) return nil;
    

    for (MysticResizeableLabel *l in self.overlays) {
        if([l.text isEqualToString:labelText]) return (MysticResizeableLabel *)l;
    }
    return nil;
}


- (CGFloat) contentScale;
{
    CGFloat t1 = MAX(0, self.transform.a != 1 ? self.transform.a : 0);
    CGFloat t2 = MAX(0, self.transform.d != 1 ? self.transform.d : 0);
    CGFloat t3 = MAX(t1, t2);
    CGFloat t4 = t3 != 0 ? t3 : 1.0f;
    
    CGRect newBounds = [MysticUI scaleRect:self.bounds scale:t4];
    CGFloat t5 = self.bounds.size.width/newBounds.size.width;
    return t5;
}
- (CGFloat) currentScale;
{
    CGFloat t1 = MAX(0, self.transform.a != 1 ? self.transform.a : 0);
    CGFloat t2 = MAX(0, self.transform.d != 1 ? self.transform.d : 0);
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
    [self showGrid:sender animated:NO];
}
- (void) showGrid:(id)sender animated:(BOOL)animated;
{
    if(!self.allowGridViewToShow) return;
//    DLog(@"show grid: %@ Has Grid: %@", MBOOLStr(animated), MBOOLStr((self.gridView != nil)));
    if(sender) self.shouldShowGridOnOpen = YES;
    if([self.delegate respondsToSelector:@selector(layersViewWillShowGrid:)])
    {
        [self.delegate layersViewWillShowGrid:self];
    }
    
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
        
        
        self.gridView = [[[MysticGridView alloc] initWithFrame:self.bounds] autorelease];
        self.gridView.columns = 2;
        self.gridView.rows = 2;
//        self.gridView.blockSize = [MysticUI scaleSize:CGSizeMake(40, 40) scale:t5];
        self.gridView.dashSize = [MysticUI scaleSize:CGSizeMake(1, 4) scale:t5];
        self.gridView.alpha = 0;
        self.gridView.borderWidth = self.gridView.borderWidth*t5;

        [self addSubview:self.gridView];
        [self sendSubviewToBack:self.gridView];
        
        

        
        self.gridView.backgroundColor = [[UIColor mysticDarkBackgroundColor] colorWithAlphaComponent:0.45];
//        self.gridView.borderColor = [[UIColor mysticWhiteBackgroundColor] colorWithAlphaComponent:0.25];
//        self.gridView.centerBorderColor = [[UIColor mysticWhiteBackgroundColor] colorWithAlphaComponent:0.65];

//        self.layer.borderColor = [[[UIColor mysticDarkChocolateColor] darker:0.2] colorWithAlphaComponent:0.7].CGColor;
//        self.layer.borderWidth = 2;
        [self.gridView setNeedsDisplay];
        
        __unsafe_unretained __block MysticLabelsView *weakSelf = self;

        
        if(animated && self.gridView.alpha != 1.0f)
        {

            self.gridViewIsAnimating = YES;
            [MysticUIView animateWithDuration:0.3 animations:^{
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
    
    
    
    
    if([self.delegate respondsToSelector:@selector(layersViewDidShowGrid:)])
    {
        [self.delegate layersViewDidShowGrid:self];
    }
    

}
- (void) toggleGrid:(id)sender;
{
    [self toggleGrid:sender animated:YES];
}
- (void) toggleGrid:(id)sender animated:(BOOL)animated;
{
    if(self.isGridHidden)
    {
        [self showGrid:sender animated:animated];
    }
    else
    {
        [self hideGrid:sender animated:animated];
    }
}
- (void) hideGrid:(id)sender;
{
    [self hideGrid:sender animated:NO];
}
- (void) hideGrid:(id)sender animated:(BOOL)animated;
{
    if(!self.allowGridViewToHide) return;


    if(sender) self.shouldShowGridOnOpen = NO;
    
    if([self.delegate respondsToSelector:@selector(layersViewWillHideGrid:)])
    {
        [self.delegate layersViewWillHideGrid:self];
    }
    
    
    if(self.gridView)
    {
        __unsafe_unretained __block MysticLabelsView *weakSelf = self;
        __unsafe_unretained __block MysticBlock _finishedAnim = ^{
//            weakSelf.layer.borderColor = [UIColor clearColor].CGColor;
//            weakSelf.layer.borderWidth = 0;
//            weakSelf.layer.borderColor = nil;
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
            [MysticUIView animateWithDuration:0.2f animations:^
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
    
    if([self.delegate respondsToSelector:@selector(layersViewDidHideGrid:)])
    {
        [self.delegate layersViewDidHideGrid:self];
    }
}
- (void)layerViewDidBeginMoving:(MysticResizeableLabel *)layerView;
{
//    layerView.normalFrame = [MysticUI normalRect:layerView.frame bounds:self.bounds];
//    //    if(!self.gridView) { showedGridOnMove = YES; [self showGrid:nil]; }
//    DLog(@"BEGIN MOVE");
    
    
}
- (void)layerViewDidMove:(MysticResizeableLabel *)layerView;
{
//    layerView.normalFrame = [MysticUI normalRect:layerView.frame bounds:self.bounds];
//    if(!self.gridView) { showedGridOnMove = YES; [self showGrid:nil]; }
    if(!self.gridView) {
        
        [self showGrid:nil];
    }
    if([self.delegate respondsToSelector:@selector(layerViewDidTransform:)])
    {
        [self.delegate layerViewDidTransform:(id)layerView];
    }
}

- (void)layerViewDidEndMoving:(MysticResizeableLabel *)layerView;
{
//    if(self.gridView && showedGridOnMove) { showedGridOnMove=NO; [self hideGrid:nil]; }
    if(self.gridView) {
        [self hideGrid:nil];
    }
    
    if([self.delegate respondsToSelector:@selector(layerViewDidEndTransform:)])
    {
        [self.delegate layerViewDidEndTransform:(id)layerView];
    }

}
- (void)layerViewDidCancelMoving:(MysticResizeableLabel *)layerView;
{
    if(self.gridView) {
        [self hideGrid:nil];
    }
    if([self.delegate respondsToSelector:@selector(layerViewDidEndTransform:)])
    {
        [self.delegate layerViewDidEndTransform:(id)layerView];
    }
}
- (void)layerViewDidClose:(MysticResizeableLabel *)layerView
{
    [self layerViewDidClose:(id)layerView notify:YES];
}
- (void)layerViewDidClose:(MysticResizeableLabel *)layerView  notify:(BOOL)shouldNotify;
{
    [layerView removeFromSuperview];
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidClose:)])
    {
        [self.delegate layerViewDidClose:(id)layerView];
    }
    
}


#pragma mark - doubleTappedLayer:
- (void) layerViewDidDoubleTap:(MysticResizeableLabel *)layerView;
{
    [self layerViewDidDoubleTap:(id)layerView notify:YES];

}
- (void) layerViewDidDoubleTap:(MysticResizeableLabel *)layerView  notify:(BOOL)shouldNotify;
{
    [layerView setSelected:YES notify:shouldNotify];
//    [layerView becomeFirstResponder];
}
- (void) layerViewDidSingleTap:(MysticResizeableLabel *)layerView;
{
    [self layerViewDidSingleTap:(id)layerView notify:YES];
}
- (void) layerViewDidSingleTap:(MysticResizeableLabel *)layerView notify:(BOOL)shouldNotify;
{
    if(!layerView.enabled) return;
    [layerView setSelected:!layerView.selected notify:shouldNotify];

}
- (void) layerViewDidSelect:(MysticResizeableLabel *)layerView;
{
    [self layerViewDidSelect:(id)layerView notify:YES];
}
- (void) layerViewDidSelect:(MysticResizeableLabel *)layerView  notify:(BOOL)shouldNotify;
{
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidSelect:)])
    {
        [self.delegate layerViewDidSelect:(id)layerView];
    }
    
    if(layerView.selected)
    {
        [self activateLayer:layerView notify:shouldNotify];
    }
    else
    {
        [self deactivateLayer:layerView notify:shouldNotify];
    }
    
}
- (void) deactivateLayer:(MysticResizeableLabel *)layerView;
{
    [self deactivateLayer:layerView notify:YES];
}
- (void) deactivateLayer:(MysticResizeableLabel *)layerView notify:(BOOL)shouldNotify;
{
    if(layerView.selected) [layerView setSelected:NO notify:shouldNotify];
    
    [self deselectLayersExcept:(MysticResizeableLabel *)layerView];
    
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidDeactivate:)])
    {
        [self.delegate layerViewDidDeactivate:(id)layerView];
    }
    
}
- (void) activateLayer:(MysticResizeableLabel *)layerView;
{
    [self activateLayer:layerView notify:YES];
}
- (void) activateLayer:(MysticResizeableLabel *)layerView notify:(BOOL)shouldNotify;
{
    [self bringSubviewToFront:layerView];
    if(!layerView.selected) [layerView setSelected:YES notify:shouldNotify];
    
    [self deselectLayersExcept:(MysticResizeableLabel *)layerView];
    
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidActivate:)])
    {
        [self.delegate layerViewDidActivate:(id)layerView];
    }
    
}

//- (void) layerViewDebug:(NSString *)str;
//{
//    debug.text = str;
//}

- (void) layerViewDidBeginEditing:(MysticResizeableLabel *)layerView;
{
    if([self.delegate respondsToSelector:@selector(layerViewDidBeginEditing:)])
    {
        [self.delegate layerViewDidBeginEditing:(id)layerView];
    }
    
    
    
}



- (void) layerViewDidEndEditing:(MysticResizeableLabel *)layerView;
{
    if([self.delegate respondsToSelector:@selector(layerViewDidEndEditing:)])
    {
        [self.delegate layerViewDidEndEditing:(id)layerView];
    }
}





#pragma mark - Overlays

- (MysticResizeableLabel *) addNewOverlay;
{
    return [self addNewOverlay:YES];
}
- (MysticResizeableLabel *) addNewOverlay:(BOOL)copyLastOverlay;
{
    MysticResizeableLabel *lastOverlay = copyLastOverlay ? self.lastOverlay : nil;
    
    
    
    
    PackPotionOptionFontStyle *fontOption = (PackPotionOptionFontStyle *)[PackPotionOptionFontStyle optionWithName:@"Font Layer" info:nil];
    CGRect gripFrame2 = CGRectMake(50, 50, CGRectGetWidth(self.frame) * MYSTIC_DEFAULT_RESIZE_LABEL_SCALE_WIDTH, 140);
    MysticResizeableLabel *userResizableView2 = [[MysticResizeableLabel alloc] initWithFrame:gripFrame2];
    userResizableView2.tag = [self.subviews count]+1;
    userResizableView2.delegate = (id)self;
    
    UIView *parentView = [AppDelegate instance].window;
    
    userResizableView2.debugParentView = parentView;
    userResizableView2.option = fontOption;

    
    
    
    [self activateLayer:userResizableView2 notify:NO];
    [self addOverlay:userResizableView2];
//    userResizableView2.normalFrame = [MysticUI normalRect:userResizableView2.frame bounds:self.bounds];
    CGPoint c = CGPointZero;
    c.x = self.originalFrame.size.width/2;
    c.y = self.originalFrame.size.height/2;
    
    userResizableView2.center = c;
    
    userResizableView2.debug = YES;

    [self deselectLayersExcept:userResizableView2];
    
    if([self.delegate respondsToSelector:@selector(layersViewDidAddLayer:)])
    {
        [self.delegate layersViewDidAddLayer:(id)userResizableView2];
    }
    
    if(lastOverlay && copyLastOverlay)
    {
        userResizableView2.font = lastOverlay.font;
        userResizableView2.textColor = lastOverlay.textColor;
        userResizableView2.backgroundColor = lastOverlay.backgroundColor;

    }
    
    return [userResizableView2 autorelease];
}

- (void) changedLayer:(MysticResizeableLabel *)sticker;
{
    
    
    
}
- (void) deselectLayersExcept:(MysticResizeableLabel *)except;
{
    [self deselectLayersExcept:except notify:YES];
}
- (void) deselectLayersExcept:(MysticResizeableLabel *)except notify:(BOOL)shouldNotify;
{
    BOOL deactivated = NO;
    for (MysticResizeableLabel *z in self.overlays) {
        if(!except || (z != except && z.selected))
        {
//            deactivated = YES;
            [z setSelected:NO notify:shouldNotify];
//            z.selected = NO;
        }
    }
    
//    if(!deactivated && [self.delegate respondsToSelector:@selector(layerViewDidDeactivate:)])
//    {
//        [self.delegate layerViewDidDeactivate:except];
//    }
}
- (void) addOverlay:(UIView *)overlay;
{
    CGRect oframe = CGRectZero;
    oframe.size = overlay.frame.size;
    overlay.frame = oframe;
    [self addSubview:overlay];
   
}
- (NSArray *) overlays;
{
    NSMutableArray *o = [NSMutableArray array];
    for(MysticResizeableLabel *layerView  in self.subviews){
        if([layerView conformsToProtocol:@protocol(MysticLayerViewAbstract)]) [o addObject:layerView];
    }
    return o;
}
- (void) removeOverlays;
{
    [self removeOverlays:nil];
}
- (void) removeOverlays:(NSArray *)exceptions;
{

    [self removeSubviews:self except:exceptions];
}


- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
{

    @autoreleasepool {
        for (UIView *subview in parentView.subviews) {
            if((!exceptions || ![exceptions containsObject:subview]) && [subview  conformsToProtocol:@protocol(MysticLayerViewAbstract)]) [subview removeFromSuperview];
        }
    }
}



- (PackPotionOptionFontStyle *) confirmOverlays;
{
    return [self confirmOverlaysComplete:nil];
}
- (PackPotionOptionFontStyle *) confirmOverlaysComplete:(MysticBlockObject)finished;
{
    [self hideGrid:nil];
    [self disableOverlays];
    PackPotionOptionFontStyle *confirmed = nil;
    if([self.overlays count])
    {
        confirmed = [PackPotionOptionFontStyle optionWithName:@"font" info:nil];
        [confirmed setOverlaysView:(MysticOverlaysView *)self];
        confirmed.text = [self lastOverlay:NO].text;
        confirmed.viewImage = [MysticImage renderedImageWithSize:[MysticUser user].size view:self finished:nil];

    }
    return [self confirmOverlays:confirmed complete:finished];
    
    
}
- (PackPotionOptionFontStyle *) confirmOverlays:(PackPotionOptionFontStyle *)newOption complete:(MysticBlockObject)complete;
{
    MysticObjectType optionType = newOption ? newOption.type : MysticObjectTypeFontStyle;
    PackPotionOption *oldOption = [UserPotion optionForType:optionType];
    [UserPotion removeOptionForType:optionType cancel:NO];
    if(newOption)
    {
        [newOption setUserChoice:YES finished:nil];
        if(oldOption)
        {
            [newOption applyAdjustmentsFrom:oldOption];
        }
    }
    if(complete) complete(newOption);
    return newOption;
}


- (void) disableOverlays;
{
    self.userInteractionEnabled = NO;
    for(MysticResizeableLabel *layerView  in self.overlays){
        layerView.enabled = NO;
    }
    
    
    
}
- (void) enableOverlays;
{
    self.userInteractionEnabled = YES;
    if(showGridOnOpen) [self showGrid:nil];
    for(MysticResizeableLabel *layerView  in self.overlays){
         layerView.enabled = YES;
    }
    
    
    
}

- (MysticResizeableLabel *) lastOverlay;
{
    return [self lastOverlay:NO];
}
- (MysticResizeableLabel *) lastOverlay:(BOOL)make;
{
    MysticResizeableLabel *l = self.selectedLayer;
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


- (MysticResizeableLabel *) selectedLayer;
{
    for (MysticResizeableLabel *sticker in self.overlays) {
        if(sticker.selected) return sticker;
    }
    return nil;
}

- (void) setSelectedLayer:(MysticResizeableLabel *)value
{
    value.selected = YES;
}

- (void) layoutSubviews;
{
    //self.gridView.frame = self.bounds;
    
    
}

- (void) setFrame:(CGRect)frame;
{
//    CGRect oldFrame = super.frame;
    [super setFrame:frame];
    if(self.gridView)
    {
        self.gridView.frame = self.bounds;
        [self.gridView setNeedsDisplay];
    }

    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

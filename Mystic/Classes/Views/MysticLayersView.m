//
//  MysticLayersView.m
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayersView.h"
#import <QuartzCore/QuartzCore.h>
#import "MysticDotView.h"
#import "UIView+ColorOfPoint.h"
#import "UserPotion.h"


@implementation MysticLayersView


@synthesize delegate=_delegate, selectedLayer, gridView=_gridView, shouldShowGridOnOpen=_shouldShowGridOnOpen, hasLayers, originalFrame, shouldAddNewOverlay, lastSelected=_lastSelected;

static BOOL showGridOnOpen = YES;

- (void) dealloc;
{
    [_gridView release];
    _delegate = nil;
    _lastSelected = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.autoresizesSubviews = NO;
        self.allowGridViewToHide = YES;
        self.allowGridViewToShow = YES;
        self.gridViewIsAnimating = NO;
        _shouldShowGridOnOpen = YES;
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
- (BOOL) hasLayers;
{
    return [self.overlays count] > 0;
}
- (BOOL) shouldShowGridOnOpen;
{
    return _shouldShowGridOnOpen;
}
- (void) setShouldShowGridOnOpen:(BOOL)value;
{
    _shouldShowGridOnOpen = value;
}

- (BOOL) shouldAddNewOverlay;
{
    if(!self.overlays.count) return YES;
    
    return YES;
}

- (id) newestOverlay;
{
    NSArray *_overlays = [self overlays];
    return _overlays.count ? [_overlays lastObject] : nil;
}

- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLayer class]])
        {
            subview.hidden = YES;
        }
    }
}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLayer class]])
        {
            subview.hidden = NO;
        }
    }
}


- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
{
    CGSize renderSize;
    
    CGRect fit = [MysticUI aspectFit:[MysticUI rectWithSize:self.frame.size] bounds:[MysticUI rectWithSize:bounds]];
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
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLayer class]])
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
    
    
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    for (UIView *subview in self.subviews) {
        if(![subview isKindOfClass:[MysticResizeableLayer class]])
        {
            subview.hidden = NO;
        }
    }
    
    //    self.transform = trans;
    return resultingImage;
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
        self.gridView = [[[MysticGridView alloc] initWithFrame:self.bounds] autorelease];
        self.gridView.blockSize = [MysticUI scaleSize:CGSizeMake(40, 40) scale:t5];
        self.gridView.dashSize = [MysticUI scaleSize:CGSizeMake(1, 4) scale:t5];
        self.gridView.alpha = 0;
        self.gridView.borderWidth = self.gridView.borderWidth*t5;
        
        [self addSubview:self.gridView];
        [self sendSubviewToBack:self.gridView];        self.gridView.alpha = 0;
        [self addSubview:self.gridView];
        [self sendSubviewToBack:self.gridView];
        self.gridView.backgroundColor = [[UIColor mysticDarkBackgroundColor] colorWithAlphaComponent:0.45];
        self.gridView.borderColor = [[UIColor mysticWhiteBackgroundColor] colorWithAlphaComponent:0.25];
        self.gridView.centerBorderColor = [[UIColor mysticWhiteBackgroundColor] colorWithAlphaComponent:0.65];
        
        self.layer.borderColor = [[[UIColor mysticDarkChocolateColor] darker:0.2] colorWithAlphaComponent:0.7].CGColor;
        self.layer.borderWidth = MYSTIC_UI_PANEL_BORDER;
        [self.gridView setNeedsDisplay];
        
        __unsafe_unretained __block MysticLayersView *weakSelf = self;
        
        
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
        __unsafe_unretained __block MysticLayersView *weakSelf = self;
        __unsafe_unretained __block MysticBlock _finishedAnim = ^{
            weakSelf.layer.borderColor = [UIColor clearColor].CGColor;
            weakSelf.layer.borderWidth = 0;
            weakSelf.layer.borderColor = nil;
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

- (void)layerViewDidMove:(MysticResizeableLayer *)layerView;
{

}
- (void)layerViewDidClose:(MysticResizeableLayer *)layerView
{
    [self layerViewDidClose:layerView notify:YES];
}
- (void)layerViewDidClose:(MysticResizeableLayer *)layerView  notify:(BOOL)shouldNotify;
{
    DLog(@"layers layerViewDidClose: %@  notify: %@", layerView, MBOOL(shouldNotify));
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidClose:)])
    {
        [self.delegate layerViewDidClose:layerView];
    }
    _lastSelected = nil;
    [layerView removeFromSuperview];

}


#pragma mark - doubleTappedLayer:
- (void) layerViewDidDoubleTap:(MysticResizeableLayer *)layerView;
{
    [self layerViewDidDoubleTap:layerView notify:YES];
    
}
- (void) layerViewDidDoubleTap:(MysticResizeableLayer *)layerView  notify:(BOOL)shouldNotify;
{
    [layerView setSelected:YES notify:shouldNotify];
    [layerView becomeFirstResponder];
}
- (void) layerViewDidSingleTap:(MysticResizeableLayer *)layerView;
{
    [self layerViewDidSingleTap:layerView notify:YES];
}
- (void) layerViewDidSingleTap:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
{
//    DLog(@"layerViewDidSingleTap: %@  | isSelected: %@  |  enabled: %@", [layerView.option shortName], MBOOL(layerView.selected), MBOOL(layerView.enabled));
    if(!layerView.enabled || layerView.selected) return;
    
    [layerView setSelected:!layerView.selected notify:shouldNotify];
    
}
- (void)layerViewDidResize:(MysticResizeableLayer *)layerView;
{
    
}
- (void) layerViewDidSelect:(MysticResizeableLayer *)layerView;
{
    [self layerViewDidSelect:layerView notify:YES];
}
- (void) layerViewDidSelect:(MysticResizeableLayer *)layerView  notify:(BOOL)shouldNotify;
{
//    DLog(@"layerViewDidSelect: <%p>  |  notify: %@", layerView, MBOOL(shouldNotify));

    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidSelect:)])
    {
        [self.delegate layerViewDidSelect:layerView];
    }
    _lastSelected = layerView.selected ? layerView : nil;

    if(layerView.selected)
    {
        [self activateLayer:layerView notify:shouldNotify];
    }
    else
    {
        [self deactivateLayer:layerView notify:shouldNotify];
    }
    
}
- (void) deactivateLayer:(MysticResizeableLayer *)layerView;
{
    [self deactivateLayer:layerView notify:YES];
}
- (void) deactivateLayer:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
{
    if(layerView.selected) [layerView setSelected:NO notify:shouldNotify];
    
//    [self deselectLayersExcept:(MysticResizeableLayer *)layerView notify:shouldNotify];
    
    if(shouldNotify && [self.delegate respondsToSelector:@selector(layerViewDidDeactivate:)])
    {
        [self.delegate layerViewDidDeactivate:layerView];
    }
    
}
- (void) activateLayer:(MysticResizeableLayer *)layerView;
{
    [self activateLayer:layerView notify:YES];
}
- (void) activateLayer:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
{
//    DLog(@"activateLayer: <%p>", layerView);
    [self bringSubviewToFront:layerView];
    BOOL hasActivated = NO;
    if(!layerView.selected)
    {
//        hasActivated = YES;
//        DLog(@"activating but not selected: notify: %@", MBOOL(shouldNotify));
        [layerView setSelected:YES notify:shouldNotify];
        return;
    }
    [self deselectLayersExcept:(MysticResizeableLayer *)layerView notify:NO];

    _lastSelected = layerView ? layerView : nil;
    
    
    if(shouldNotify && !hasActivated && [self.delegate respondsToSelector:@selector(layerViewDidActivate:)])
    {
        [self.delegate layerViewDidActivate:layerView];
    }
    
}

//- (void) layerViewDebug:(NSString *)str;
//{
//    debug.text = str;
//}

- (void) layerViewDidBeginEditing:(MysticResizeableLayer *)layerView;
{
    if([self.delegate respondsToSelector:@selector(layerViewDidBeginEditing:)])
    {
        [self.delegate layerViewDidBeginEditing:layerView];
    }
    
    
    
}



- (void) layerViewDidEndEditing:(MysticResizeableLayer *)layerView;
{
    if([self.delegate respondsToSelector:@selector(layerViewDidEndEditing:)])
    {
        [self.delegate layerViewDidEndEditing:layerView];
    }
}

- (MysticObjectType) objectType;
{
    return MysticObjectTypeAll;
}
- (Class) optionClass;
{
    return [PackPotionOptionLayer class];
}

- (Class) layerClass;
{
    return [MysticResizeableLayer class];
}
#pragma mark - Overlays

- (id) addNewOverlay;
{
    PackPotionOption *newOption = (PackPotionOption *)[[self optionClass] optionWithName:@"Layer" info:nil];
    return [self addNewOverlay:newOption];
}
- (id) addNewOverlay:(PackPotionOption *)newOption;
{
    CGRect gripFrame2 = CGRectMake(0, 0, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame)-20);
    return [self addNewOverlay:newOption frame:gripFrame2];
}
- (id) addNewOverlay:(PackPotionOption *)newOption frame:(CGRect)frame;
{
    MysticResizeableLayer *userResizableView2 = [[[self layerClass] alloc] initWithFrame:frame];
    userResizableView2.tag = [self.subviews count]+1;
    userResizableView2.delegate = self;
    userResizableView2.borderView.borderColor = [UIColor mysticPinkColor];
    userResizableView2.rotationSnapping = YES;
    
//    CGFloat t5 = self.contentScale;
    
    userResizableView2.borderView.borderWidth = 3;
    userResizableView2.preventsPositionOutsideSuperview = NO;
    userResizableView2.preventsCustomButton = YES;
    userResizableView2.preventsResizing = NO;
    userResizableView2.minimumHeight = 10;
    userResizableView2.minimumWidth = 10;
    userResizableView2.contentScale = CGScaleWith(self.contentScale);
    userResizableView2.option = newOption;

    [self activateLayer:userResizableView2 notify:NO];
    [self addOverlay:userResizableView2];
    userResizableView2.normalFrame = [MysticUI normalRect:userResizableView2.frame bounds:self.bounds];
    CGPoint c = CGPointZero;
    c.x = self.originalFrame.size.width/2;
    c.y = self.originalFrame.size.height/2;
    
    userResizableView2.center = c;
    
    
    [self deselectLayersExcept:userResizableView2];
    
    if([self.delegate respondsToSelector:@selector(layersViewDidAddLayer:)])
    {
        [self.delegate layersViewDidAddLayer:userResizableView2];
    }
    
    return [userResizableView2 autorelease];
}

- (void) changedLayer:(MysticResizeableLayer *)sticker;
{
    
    
    
}
- (void) deselectLayersExcept:(MysticResizeableLayer *)except;
{
    [self deselectLayersExcept:except notify:YES];
}
- (void) deselectLayersExcept:(MysticResizeableLayer *)except notify:(BOOL)shouldNotify;
{
//    DLog(@"deselectLayersExcept: %@", except);
    
//    BOOL deactivated = NO;
    for (MysticResizeableLayer *z in self.overlays) {
        if(!except || (![z isEqual:except] && z.selected))
        {
//            deactivated = YES;
//            DLog(@"deselect: %@", z);

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
    for(MysticResizeableLayer *layerView  in self.subviews){
        if([layerView isKindOfClass:[self layerClass]]) [o addObject:layerView];
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
            if((!exceptions || ![exceptions containsObject:subview]) && [subview isKindOfClass:[self layerClass]])
            {
                [subview removeFromSuperview];
            }
        }
    }
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
- (PackPotionOption *) confirmOverlays;
{
    return [self confirmOverlaysComplete:nil];
}
- (PackPotionOption *) confirmOverlaysComplete:(MysticBlockObject)finished;
{
    [self hideGrid:nil];
    [self disableOverlays];
    PackPotionOptionView *confirmed = nil;
    if([self.overlays count])
    {
        NSString *newName = NSStringFromClass([self optionClass]);
        confirmed = [[self optionClass] optionWithName:newName info:nil];
        [(PackPotionOptionLayer *)confirmed setView:self];
        confirmed.viewImage = [MysticImage renderedImageWithSize:[MysticUser user].size view:self finished:nil];
    }
    return [self confirmOverlays:confirmed complete:finished];
    
    
}
- (PackPotionOption *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
{
    MysticObjectType optionType = newOption ? newOption.type : [self objectType];
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
    if(!self.userInteractionEnabled) return;

    self.userInteractionEnabled = NO;
    for(MysticResizeableLayer *layerView  in self.overlays)
    {
        if(layerView.selected) _lastSelected = layerView;
        layerView.enabled = NO;
    }
    
    
    
}
- (void) enableOverlays;
{
    [self enableOverlays:YES];
}
- (void) enableOverlays:(BOOL)activateLastSelected;
{
    if(self.userInteractionEnabled) return;
    self.userInteractionEnabled = YES;
    if(self.shouldShowGridOnOpen) [self showGrid:nil];
    
    for(MysticResizeableLayer *layerView  in self.overlays)
    {
        layerView.enabled = YES;
    }

    if(activateLastSelected && self.lastSelected && ![(MysticResizeableLayer *)self.lastSelected selected])
    {

        [self activateLayer:self.lastSelected];

    }

    
    
}

- (MysticResizeableLayer *) lastOverlay;
{
    return [self lastOverlay:NO];
}
- (MysticResizeableLayer *) lastOverlay:(BOOL)make;
{
    MysticResizeableLayer *l = self.selectedLayer;
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


- (id) selectedLayer;
{
    for (MysticResizeableLayer *sticker in self.overlays) {
        if(sticker.selected) return sticker;
    }
    return nil;
}

- (void) setSelectedLayer:(id)value
{
    
    if(value)
    {
        [(MysticResizeableLayer *)value setSelected:YES];
    }
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


@end

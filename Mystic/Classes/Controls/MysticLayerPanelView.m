//
//  MysticLayerPanelView.m
//  Mystic
//
//  Created by Me on 1/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerPanelView.h"
#import "MysticPanelObject.h"
#import "NSArray+Mystic.h"






@interface MysticLayerPanelView () <MysticTabBarDelegate>

@property (nonatomic, copy) MysticBlockBOOL finishedAnimation;
@property (nonatomic, assign) NSInteger lastSelectedSegment, lastSelectedTab;
@property (nonatomic, retain) MysticButton *revealButton;
@property (nonatomic, retain) NSMutableDictionary *animationBlockObjs;


@end
@implementation MysticLayerPanelView

@synthesize state=_state, anchor=_anchor, contentSize=_contentSize, contentView=_contentView, delegate=_delegate, enabled=_enabled, finishedAnimation=__finishedAnimation, segmentedControl=_segmentedControl, options=_options, openInset=_openInset, targetOption=_targetOption, bottomBarView=_bottomBarView, contentContainerView=_contentContainerView, leftButton=_leftButton, rightButton=_rightButton, backgroundView=_backgroundView, backgroundAlpha=_backgroundAlpha, previousState=_previousState, closedAnchor=_closedAnchor, offsetY=_offsetY, visiblePanel=_visiblePanel, panels=_panels;

- (void) dealloc;
{
    Block_release(__finishedAnimation);
    _state = MysticLayerPanelStateUnknown;
    _anchor = CGPointZero;
    _contentSize = CGSizeZero;
    [_animationBlockObjs release];
//    [_activePanelObject release];
    [_visiblePanel release];
    [_targetOption release];
    [_backgroundView release];
    [_contentView release];
    [_bottomBarView release];
    [_contentContainerView release];
    [_segmentedControl release];
    [_options release];
    [_rightButton release];
    [_leftButton release];
    [_panels release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self commonInit];
        self.anchor = frame.origin;
    }
    return self;
}

- (void) commonInit;
{
    _offsetY = 0;
    if(_panels) [_panels release];
    _panels = [[NSMutableArray array] retain];
    _panelSpacing = MYSTIC_UI_PANEL_SPACING;
    _backgroundAlpha = MYSTIC_UI_PANEL_BG_ALPHA;
    if(_animationBlockObjs) [_animationBlockObjs release];
    _animationBlockObjs = [[NSMutableDictionary dictionary] retain];
    _createNewOption = NO;
    self.openInset = 0;
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    self.lastSelectedSegment = NSNotFound;
    self.lastSelectedTab = NSNotFound;
    self.clipsToBounds = NO;
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;

    self.contentSize = CGSizeZero;

    _contentSize = CGSizeMake(self.frame.size.width, MYSTIC_UI_PANEL_HEIGHT_MIN);
    _state = MysticLayerPanelStateInit;
    _previousState = MysticLayerPanelStateUnInit;
    MysticPanelContainerView *__contentContainerView = [[MysticPanelContainerView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    __contentContainerView.autoresizesSubviews = YES;
    __contentContainerView.clipsToBounds = NO;
    __contentContainerView.userInteractionEnabled = YES;
    self.contentContainerView = __contentContainerView;
    self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.contentContainerView];
    [__contentContainerView release];
    
    
    MysticLayerPanelBottomBarView *__bottomBar = [[MysticLayerPanelBottomBarView alloc] initWithFrame:CGRectMake(0,MYSTIC_UI_PANEL_HEIGHT_DEFAULT,  self.bounds.size.width, MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT + self.panelSpacing )];
    __bottomBar.contentInsets = UIEdgeInsetsMake(self.panelSpacing, 0, 0, 0);
    self.bottomBarView = __bottomBar;
    self.bottomBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.bottomBarView.autoresizesSubviews = YES;
    self.bottomBarView.backgroundColor = [UIColor color:MysticColorTypePanelBackground];
    [__bottomBar release];
    
    
    
    CGRect backgroundFrame = CGRectMake(0, 0, self.frame.size.width, MYSTIC_UI_PANEL_HEIGHT_DEFAULT + self.bottomBarView.frame.size.height);
    
    
    UIView *__backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    self.backgroundView = __backgroundView;
    self.backgroundView.autoresizesSubviews = YES;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundView];
    [self sendSubviewToBack:self.backgroundView];
    self.blurBackground=YES;
    [__backgroundView release];

}

- (void) resetBackgroundColor;
{
    self.backgroundAlpha  = MYSTIC_UI_PANEL_BG_ALPHA;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.contentContainerView.backgroundColor = [UIColor clearColor];
}

- (void) resetDarkBackgroundColor;
{
    [self resetBackgroundColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];

}


- (void) setLeftButton:(MysticButton *)leftButton;
{
    if(_leftButton)
    {
        [_leftButton removeFromSuperview];
        [_leftButton release], _leftButton=nil;
    }
    
    if(leftButton)
    {
        _leftButton = [leftButton retain];
        CGRect f = _leftButton.frame;
        f.origin.x = 0;
        f.size.height = self.bottomBarView.contentBounds.size.height;
        f.size.width = self.bottomBarView.contentBounds.size.height;
        _leftButton.frame = f;
        [self.bottomBarView addSubview:_leftButton];
    }
}

- (void) setRightButton:(MysticButton *)button;
{
    if(_rightButton)
    {
        [_rightButton removeFromSuperview];
        [_rightButton release], _rightButton=nil;
    }
    
    if(button)
    {
        _rightButton = [button retain];
        CGRect f = _rightButton.frame;
        f.origin.x = self.bottomBarView.contentBounds.size.width - self.bottomBarView.contentBounds.size.height;
        f.size.height = self.bottomBarView.contentBounds.size.height;
        f.size.width = self.bottomBarView.contentBounds.size.height;

        _rightButton.frame = f;
        [self.bottomBarView addSubview:_rightButton];
    }
}

- (void) setBackgroundAlpha:(CGFloat)backgroundAlpha;
{
    _backgroundAlpha = backgroundAlpha;
    self.backgroundView.backgroundColor = [UIColor clearColor];


}
- (void) setTargetOption:(PackPotionOption *)option;
{
    
    
    if(_targetOption)
    {
        [_targetOption release], _targetOption=nil;
    }
    if(option)
    {
        _targetOption = [option retain];
    }
    else
    {
        [self.options removeObjectForKey:@"option"];
    }
    
    if(self.visiblePanel)
    {
        self.visiblePanel.targetOption = option;
    }
}
- (PackPotionOption *) targetOption;
{
    return _targetOption != nil ? _targetOption : [self.options objectForKey:@"option"];

}
- (void) setBottomBarView:(MysticLayerPanelBottomBarView *)__bottomBarView;
{
    if(_bottomBarView)
    {
        [_bottomBarView removeFromSuperview];
        [_bottomBarView release], _bottomBarView=nil;
    }
    _bottomBarView = [__bottomBarView retain];
    [self addSubview:_bottomBarView];
}


- (void) updateWithTargetOption:(PackPotionOption *)option;
{
    if((!option && !self.targetOption) || [self.targetOption isEqual:option]) return;
    [super updateWithTargetOption:option];
    self.targetOption = option;
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:resetSection:)])
    {
        [self.delegate layerPanel:self resetSection:self.visiblePanel];
    }
    
    
}







- (void) removeContentViewAnimated:(BOOL)animated completion:(MysticBlockBOOL)completionBlock;
{
    [self removeContentViewDuration:animated ? MYSTIC_UI_PANEL_CONTENT_TRANSITION_TIME_OUT : 0 completion:completionBlock];
}
- (void) removeContentViewDuration:(NSTimeInterval)duration completion:(MysticBlockBOOL)completionBlock;
{
    BOOL animated = duration > 0;
    if(_contentView && _contentView.alpha != 0)
    {
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel willDisappear];
        }
        if(animated)
        {
            __block MysticBlockBOOL _c = completionBlock ? Block_copy(completionBlock) : nil;
            [MysticUIView animateWithDuration:duration animations:^{
                _contentView.alpha = 0;
            } completion:^(BOOL finished) {
                
                if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
                {
                    [self.visiblePanel didDisappear];
                    [self.visiblePanel didRemoveFromSuperview];

                }
                if(_c)
                {
                    _c(finished);
                    Block_release(_c);
                }

                
            }];

        }
        else
        {
            [_contentView removeFromSuperview];
            if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
            {
                [self.visiblePanel didDisappear];
                [self.visiblePanel didRemoveFromSuperview];
            }
            [_contentView release], _contentView=nil;
            if(completionBlock)
            {
                completionBlock(YES);
            }
        }
    }
    else if(completionBlock)
    {
        completionBlock(YES);
    }
}
- (void) keepContentView:(UIView *)contentView;
{
    if(contentView)
    {
        CGRect cFrame = contentView.frame;
        cFrame.origin = CGPointZero;
        contentView.frame = cFrame;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.contentSize = cFrame.size;
    }
    
    if(_contentView)
    {
        [_contentView removeFromSuperview];
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel didDisappear];
            [self.visiblePanel didRemoveFromSuperview];
            [self.panels removeObject:self.visiblePanel];
            self.visiblePanel = nil;
        }
        [_contentView release], _contentView = nil;
    }
    
    _contentView = [contentView retain];
    
    
}
- (void) retainContentView:(UIView *)contentView;
{
    if(contentView)
    {
        CGRect cFrame = contentView.frame;
        cFrame.origin = CGPointZero;
        contentView.frame = cFrame;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.contentSize = cFrame.size;
    }
    
    if(_contentView)
    {
        [_contentView removeFromSuperview];
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel didDisappear];
            [self.visiblePanel didRemoveFromSuperview];
            [self.panels removeObject:self.visiblePanel];
            self.visiblePanel = nil;
        }
        [_contentView release], _contentView = nil;
    }
    
    _contentView = [contentView retain];
    [self.contentContainerView addSubview:_contentView];
    if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView]) [self.visiblePanel didAppear];
    [self setNeedsLayout];
    
}
- (void) replaceContentView:(UIView *)newContentView animated:(BOOL)animated completion:(MysticBlockObject)finished;
{
    [self replaceContentView:newContentView duration:animated ? MYSTIC_UI_PANEL_CONTENT_TRANSITION_TIME_IN : 0 completion:finished];
}
- (void) replaceContentView:(UIView *)newContentView duration:(NSTimeInterval)duration completion:(MysticBlockObject)finished;
{
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    __unsafe_unretained __block UIView *__newContentView = newContentView ? [newContentView retain] : nil;
    __unsafe_unretained __block MysticBlockObject __finished = finished ? Block_copy(finished) : nil;
    BOOL animated = duration > 0;
    
    [self removeContentViewDuration:(animated ? duration : 0) completion:^(BOOL active) {
        
        if(animated) __newContentView.alpha = 0;

        [weakSelf retainContentView:__newContentView];
        if(animated)
        {
            [MysticUIView animateWithDuration:duration animations:^{
                weakSelf.contentView.alpha = 1.0f;
            } completion:nil];
        }
        if(__finished)
        {
            __finished(__newContentView);
            Block_release(__finished);
            [__newContentView release];
        }
        else
        {
            [__newContentView release];

        }
    }];
    

}

- (void) replaceContentViewAndResize:(UIView *)newContentView duration:(NSTimeInterval)duration completion:(MysticBlockObject)finished;
{
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    __unsafe_unretained __block UIView *__newContentView = newContentView ? [newContentView retain] : nil;
    __unsafe_unretained __block MysticBlockObject _finished = finished ? Block_copy(finished) : nil;
    BOOL animated = duration > 0;
    
    [self removeContentViewDuration:(animated ? duration : 0) completion:^(BOOL active) {
        
        CGRect newContentFrame = CGRectZero;
        newContentFrame.size.height = __newContentView.frame.size.height;
        newContentFrame.size.width = weakSelf.frame.size.width;
        
        if(animated) __newContentView.alpha = 0;
        [weakSelf retainContentView:__newContentView];
        [__newContentView release];

        [weakSelf setContentFrame:newContentFrame animate:animated duration:duration key:@"replaceContentView" completion:^(BOOL done)
        {
            if(animated)
            {
                [MysticUIView animateWithDuration:duration animations:^{
                    weakSelf.contentView.alpha = 1.0f;
                } completion:nil];
            }
            if(_finished)
            {
                _finished(weakSelf.contentView);
                Block_release(_finished);
            }
        }];
        
        
    }];
    
    
}
- (UIView *) removeContentView;
{
    if(_contentView)
    {
        [_contentView removeFromSuperview];
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel didDisappear];
            [self.visiblePanel didRemoveFromSuperview];
            
            
            self.visiblePanel = nil;
            [self.panels removeAllObjects];
        }
        
        UIView *__contentView = [_contentView retain];
        [_contentView release], _contentView = nil;
        return [__contentView autorelease];
    }
    return nil;
}
- (void) setContentView:(UIView *)contentView;
{
    [self setContentView:contentView completion:nil];
}
- (void) setContentView:(UIView *)contentView completion:(MysticBlockObject)finished;
{
    [self setContentView:contentView animated:YES completion:finished];
    
}
- (void) setContentView:(UIView *)aNewContentView animated:(BOOL)animated completion:(MysticBlockObject)finished;
{
    CGRect ccFrame = self.contentContainerView.frame;
    if(!aNewContentView)
    {
        self.contentSize = CGSizeZero;
        ccFrame = CGRectMake(0, 0, self.bounds.size.width, MYSTIC_UI_PANEL_HEIGHT_DEFAULT);
    }
    else
    {
        
        
        CGRect cFrame = aNewContentView.frame;
        cFrame.size.width = self.bounds.size.width;
        cFrame.size.height = MAX(MYSTIC_UI_PANEL_HEIGHT_MIN, cFrame.size.height);
        aNewContentView.frame = cFrame;

        aNewContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        ccFrame.size = aNewContentView.frame.size;
        self.contentSize = aNewContentView.frame.size;
    }
    ccFrame.size.height = MAX(MYSTIC_UI_PANEL_HEIGHT_MIN, ccFrame.size.height);

    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    __unsafe_unretained __block UIView *__newContentView = aNewContentView ? [aNewContentView retain] : nil;
    __unsafe_unretained __block MysticBlockObject __finished = finished ? Block_copy(finished) : nil;
    
    
    if(_state == MysticLayerPanelStateOpen)
    {
        _state = MysticLayerPanelStateOpening;
        if(weakSelf.contentContainerView.hidden) weakSelf.contentContainerView.hidden = NO;
        if(animated)
        {
            [MysticUIView animateWithDuration:.1f animations:^
            {
                weakSelf.contentView.alpha = 0;
            } completion:^(BOOL finished)
            {
                [weakSelf setState:MysticLayerPanelStateOpen animated:animated animations:^{
                    
                } finished:^(BOOL done){
                    
                    weakSelf.previousState = MysticLayerPanelStateOpen;
                    if(__newContentView)
                    {
                        [weakSelf replaceContentView:__newContentView animated:animated completion:__finished];
                        Block_release(__finished);
                    }
                    [__newContentView release];
                }];
            }];
        }
        else
        {
            if(__newContentView)
            {
                [weakSelf replaceContentView:__newContentView animated:animated completion:__finished];
                Block_release(__finished);
            }
            [__newContentView release];
        }
        
        
    }
    else
    {
        if(__finished)
        {
            __finished(__newContentView);
            Block_release(__finished);
        }
        [__newContentView release];

    }
}
- (void) setEnabled:(BOOL)enabled;
{
    
    if(enabled)
    {
        if(self.rightButton && self.rightButton.hidden) self.rightButton.hidden = NO;
        if(self.leftButton && self.leftButton.hidden) self.leftButton.hidden = NO;
        if(self.segmentedControl && !self.segmentedControl.enabled) self.segmentedControl.enabled = YES;
        if(self.rightButton) self.rightButton.enabled = YES;
        if(self.leftButton) self.leftButton.enabled = YES;

    }
}
- (BOOL) enabled; { return YES; }

- (void) show:(MysticBlockBOOL)finished;
{
    [self setState:MysticLayerPanelStateOpen animated:YES finished:finished];
}

- (void) hide:(MysticBlockBOOL)finished;
{
    [self setState:MysticLayerPanelStateHidden animated:YES finished:finished];
}

- (BOOL) hasSectionNavigationControl;
{
    return self.segmentedControl || self.tabBar;
}

- (NSInteger) selectedControlIndex;
{
    if(self.segmentedControl)
    {
        return self.segmentedControl.selectedSegmentIndex;
    }
    else if(self.tabBar)
    {
        return self.tabBar.selectedIndex;
    }
    else if(self.replacementTabBar)
    {
        return self.replacementTabBar.selectedIndex;
    }
    return NSNotFound;
}
- (void) prepareToOpen
{
    [self prepareForState:MysticLayerPanelStateOpen];
}
- (void) prepareForState:(MysticLayerPanelState)state;
{
    if(!self.contentView && _previousState == MysticLayerPanelStateUnInit && state == MysticLayerPanelStateOpen)
    {
        _state = MysticLayerPanelStateInit;
        _previousState = MysticLayerPanelStateUnInit;
        [self buildFirstContentViewAnimated:NO complete:nil];
        
        [self setNeedsLayout];

    }
}

#pragma mark - STATE

- (void) setState:(MysticLayerPanelState)state;
{
    [self setState:state animated:YES finished:nil];
}
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated finished:(MysticBlockBOOL)finished;
{
    [self setState:state animated:animated animations:nil finished:finished];
}
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated animations:(MysticBlock)animations finished:(MysticBlockBOOL)finished;
{
    [self setState:state animated:animated duration:NAN animations:animations finished:finished];
}
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated duration:(NSTimeInterval)duration animations:(MysticBlock)animations finished:(MysticBlockBOOL)finished;
{
    [self setState:state animated:animated duration:duration animations:animations key:nil finished:finished];
}
- (void) setState:(MysticLayerPanelState)state animated:(BOOL)animated duration:(NSTimeInterval)duration animations:(MysticBlock)animations key:(NSString *)animKey finished:(MysticBlockBOOL)finished;
{
    
    self.animating = NO;
    CGRect newFrame = self.frame;
    animKey = animKey ? [@"layerPanelState-" stringByAppendingString:animKey] : @"layerPanelState";
    self.nextState = state;
    
    if(_state == state) {  if(finished) finished(YES); return; }

    [self prepareForState:state];
    if(finished)
    {
        MysticBlockObj *obj = [MysticBlockObj objectWithKey:animKey blockBOOL:finished];
        [self.animationBlockObjs setObject:obj forKey:obj.key];
        
    }
    
    _previousState = _state == MysticLayerPanelStateOpening ? _previousState : _state;
    
    if(animated)
    {
        UIViewAnimationCurve animCurve = UIViewAnimationCurveEaseOut;
        switch (state) {
            case MysticLayerPanelStateOpen:
                duration = isnan(duration) ? 0.25 : duration;
                
                break;
            case MysticLayerPanelStateHidden:
            case MysticLayerPanelStateClosed:
                animCurve = UIViewAnimationCurveEaseIn;
                duration = isnan(duration) ? 0.25 : duration;
                break;
                
            default:
                duration = isnan(duration) ? 0.25 : duration;
                break;
        }
        self.animating = YES;
        [UIView beginAnimations:animKey context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:animCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDidStopSelector:@selector(stateAnimationDidFinish:finished:context:)];
        [UIView setAnimationWillStartSelector:@selector(animationWillStart:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    else
    {
        [self animationWillStart:animKey finished:@(YES) context:nil];

    }


    newFrame = self.frame;
    switch (state) {
        case MysticLayerPanelStateClosed:
        {
            self.isHiding = YES;
            self.isShowing = NO;
            newFrame.origin = self.closedAnchor;
      
            
            break;
        }
            
            
        case MysticLayerPanelStateOpen:
        {
            self.isHiding = NO;
            self.isShowing = YES;
            CGPoint openAnchor = self.anchor;
            openAnchor.y = self.anchor.y - self.contentSize.height - self.openInset - self.bottomBarView.frame.size.height + self.offsetY;
            newFrame.origin = openAnchor;
            newFrame.size.height = self.openSize.height;
            break;
        }
            
            
        case MysticLayerPanelStateHidden:
        {
            self.isHiding = YES;
            self.isShowing = NO;
            CGPoint hiddenAnchor = self.anchor;
            hiddenAnchor.y = self.anchor.y;
            newFrame.origin = hiddenAnchor;
            newFrame.size.height = self.openSize.height;
            break;
        }
        default: break;
    }
    _state = state;

    self.frame = newFrame;
    if(animations) animations();
    
    if(animated)
    {
        [UIView commitAnimations];
    }
    else
    {
        [self animationDidStop:animKey finished:@(YES) context:nil];
    }
    [self setNeedsLayout];
}
- (CGRect) frameForState;
{
    return [self frameForState:self.state];
}
- (CGRect) frameForState:(MysticLayerPanelState)state;
{
    CGRect newFrame = self.frame;
    switch (state) {
        case MysticLayerPanelStateClosed:
        {
            self.isHiding = YES;
            self.isShowing = NO;
            newFrame.origin = self.closedAnchor;
        
            
            break;
        }
            
            
        case MysticLayerPanelStateOpen:
        {
            self.isHiding = NO;
            self.isShowing = YES;
            CGPoint openAnchor = self.anchor;
            openAnchor.y = self.anchor.y - self.contentSize.height - self.openInset - self.bottomBarView.frame.size.height + self.offsetY;
            newFrame.origin = openAnchor;
            newFrame.size.height = self.openSize.height;
            break;
        }
            
            
        case MysticLayerPanelStateHidden:
        {
            self.isHiding = YES;
            self.isShowing = NO;
            CGPoint hiddenAnchor = self.anchor;
            hiddenAnchor.y = self.anchor.y;
            newFrame.origin = hiddenAnchor;
            newFrame.size.height = self.openSize.height;
            break;
        }
        default: break;
    }
    return newFrame;
}

- (void) setContentFrame:(CGRect)contentFrame;
{
    [self setContentFrame:contentFrame animate:NO completion:nil];
}
- (void) setContentFrame:(CGRect)contentFrame animate:(BOOL)animated completion:(MysticBlockBOOL)finished;
{
    [self setContentFrame:contentFrame animate:animated duration:NAN key:nil completion:finished];
}
- (void) setContentFrame:(CGRect)contentFrame animate:(BOOL)animated duration:(NSTimeInterval)duration key:(NSString *)animKey completion:(MysticBlockBOOL)finished;
{
    if(CGRectEqualToRect(contentFrame, self.contentFrame))
    {
        if(finished)
        {
            finished(YES);
        }
        return;
    }
    animKey = animKey ? [@"setContentFrame-" stringByAppendingString:animKey] : @"setContentFrame";
    self.contentSize = contentFrame.size;
    if(animated)
    {
        _state = MysticLayerPanelStateOpening;
        [self setState:MysticLayerPanelStateOpen animated:animated duration:duration animations:nil key:animKey finished:finished];
    }
    else if(finished)
    {
       finished(YES);
    }
}


- (void)stateAnimationDidFinish:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [self animationDidStop:animationID finished:finished context:context];
}
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    self.animating = NO;
    self.isHiding = NO;
    self.isShowing = NO;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:stateDidChange:)])
    {
        [self.delegate layerPanel:self stateDidChange:self.state];
    }
    if([self.animationBlockObjs objectForKey:animationID])
    {
        MysticBlockObj *obj = [self.animationBlockObjs objectForKey:animationID];
        obj.blockBOOL([finished boolValue]);
        [self.animationBlockObjs removeObjectForKey:animationID];

    }
    
    if(self.state == MysticLayerPanelStateOpen)
    {
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel isReady];
        }
        if(self.showTabsAndSections /* && self.tabBar.selectedIndex != NSNotFound */)
        {
            [self showRevealButton];
        }
    }
    else if(self.state == MysticLayerPanelStateClosed)
    {
        [self.panels removeAllObjects];
        [self removeContentView];
//        [MysticUI printFrameOfView:self];
    }
    
    
    

}

- (void)animationWillStart:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:stateWillChange:)])
    {
        [self.delegate layerPanel:self stateWillChange:self.nextState];
    }
}




- (void) showRevealButton;
{
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;

    if(!self.revealButton)
    {
        CGSize isize = CGSizeMake(12, 12);
        MysticButton *btn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeRevealDown) size:isize color:@(MysticColorTypeSegmentControl)] target:self sel:@selector(revealTouched:)];
        UIImage *himg = [MysticImage image:@(MysticIconTypeRevealDown) size:isize color:@(MysticColorTypeSegmentControlTextColorSelected)];
        [btn setImage:himg forState:UIControlStateHighlighted];
        btn.contentMode = UIViewContentModeCenter;
        btn.hitInsets = UIEdgeInsetsMake(1, 15, 5, 15);
        self.revealButton = btn;
        
        CGRect f = self.revealButton.frame;
        f.size.height = 30;
        f.size.width = 30;
        f.origin.y = self.tabBar.frame.origin.y + self.tabBar.frame.size.height -11;
        f.origin.x = (self.bottomBarView.frame.size.width - f.size.width)/2;
        
        CGRect f2 = f;
        f2.origin.y += f.size.height;
        
        self.revealButton.frame = f;
        self.revealButton.transform  = CGAffineTransformMakeTranslation(0, f.size.height);
        [self.bottomBarView addSubview:self.revealButton];
        
        
        
        
        
    }
    else
    {

    }
    

    
    if(self.revealButton.hidden)
    {
        self.revealButton.transform  = CGAffineTransformMakeTranslation(0, self.revealButton.frame.size.height);
        self.revealButton.hidden = NO;
    }
    [MysticUIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.revealButton.transform  = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) revealTouched:(MysticButton *)sender;
{
    
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;

    
    
    CGRect of =  self.frame;
    of.origin.y -= self.offsetY;
    
    CGRect sf = self.segmentedControl.frame;
    self.revealButton.hidden = YES;
    
    
    
    self.segmentedControl.hidden = NO;
    
    

    [MysticUIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.frame = of;

    } completion:^(BOOL finished) {
        
    }];
    
    [MysticUIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.segmentedControl.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void) reset;
{
    [self reset:YES];
}
- (void) reset:(BOOL)resetOption;
{
    [self reset:resetOption removeContent:YES removeToolbar:YES];
}
- (void) reset:(BOOL)resetOption removeContent:(BOOL)shouldRemoveContent removeToolbar:(BOOL)removeToolbar;
{
    self.stopLayout = YES;
    self.autoresizesSubviews = NO;
    self.contentContainerView.autoresizesSubviews = NO;
    _state = MysticLayerPanelStateInit;
    _previousState = MysticLayerPanelStateUnInit;
    if(shouldRemoveContent && self.contentView)
    {
        [_contentView removeFromSuperview];
        if(self.visiblePanel && [self.visiblePanel.view isEqual:_contentView])
        {
            [self.visiblePanel didDisappear];
            [self.visiblePanel didRemoveFromSuperview];
        }
        [_contentView release], _contentView = nil;
    }
    if(self.segmentedControl) self.lastSelectedSegment = -2;
    if(self.tabBar) self.lastSelectedTab = -2;
    self.offsetY = 0;
    if(self.revealButton)
    {
        [self.revealButton removeFromSuperview];
        self.revealButton = nil;
    }
    if(resetOption) self.targetOption = nil;
    if(removeToolbar) for (UIView *sub in self.bottomBarView.subviews) [sub removeFromSuperview];
    if(self.tabBar) self.tabBar = nil;
    if(self.segmentedControl) self.segmentedControl = nil;
    self.autoresizesSubviews = YES;
    self.contentContainerView.autoresizesSubviews = YES;
    self.stopLayout = NO;

}

- (MysticPanelObject *)section:(NSInteger)sectionIndex;
{
    if(sectionIndex == NSNotFound) return nil;
    NSMutableDictionary *info = nil;
    
    if(self.tabBar)
    {
        MysticTabButton *selectedButton = [self.tabBar tabAtIndex:sectionIndex];
        info = selectedButton ? [NSMutableDictionary dictionaryWithDictionary:selectedButton.userInfo] : nil;
    }
    else
    {
        if(!self.options) return nil;
        
        
        
        NSArray *sections = [self.options objectForKey:@"sections"];
        if(!sections || sections.count <= sectionIndex) return nil;
        
        NSDictionary *s =  [sections objectAtIndex:sectionIndex];
        info = [NSMutableDictionary dictionaryWithDictionary:s];
//        return s ? [NSMutableDictionary dictionaryWithDictionary:s] : nil;
    }
    MysticPanelObject *panelObj = info ? [MysticPanelObject info:info] : nil;
    panelObj.panel = self;
    return panelObj;

}

- (BOOL) showTabsAndSections;
{
    if([self.options objectForKey:@"showTabsAndSections"])
    {
        return [[self.options objectForKey:@"showTabsAndSections"] boolValue];
    }
    if([self.options objectForKey:@"tabs"] && [self.options objectForKey:@"sections"])
    {
        return YES;
        
    }
    
    
    
    return NO;
}
- (void) setBottomBarHeight:(CGFloat)height;
{
    CGRect bbf = self.bottomBarView.frame;
    bbf.size.height = height > 0 ? height : MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT;
    self.bottomBarView.frame = bbf;
    [self setNeedsLayout];

}
- (void) setOptions:(NSMutableDictionary *)options;
{
    if(_options) [_options release], _options=nil;
    
    self.replacementTabBar = nil;
    self.visiblePanel = nil;
    self.targetOption = nil;
    [self.panels removeAllObjects];

    CGRect bbf = self.bottomBarView.frame;
    bbf.size.height = MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT;
    if(options[@"bottomBarHeight"])
    {
        bbf.size.height = [options[@"bottomBarHeight"] floatValue];
    }
    [self setBottomBarHeight:bbf.size.height];
    
    PackPotionOption *option = [options objectForKey:@"option"] && [[options objectForKey:@"options"] isKindOfClass:[PackPotionOption class]] ? [options objectForKey:@"option"] : nil;
    
    if(!option)
    {
        [options removeObjectForKey:@"option"];
    }
    
    
    _options = [options retain];
    
    CGFloat bgAlpha = [options objectForKey:@"backgroundAlpha"] ? [[options objectForKey:@"backgroundAlpha"] floatValue] : MYSTIC_UI_PANEL_BG_ALPHA;
    if(bgAlpha != self.backgroundAlpha) self.backgroundAlpha = bgAlpha;
    NSArray *sections = [options objectForKey:@"sections"];
    NSInteger activeSegmentIndex = [options objectForKey:@"activeSegment"] ? [[options objectForKey:@"activeSegment"] integerValue] : (self.segmentedControl ? self.segmentedControl.selectedSegmentIndex : 0);
    self.rightButton = nil;
    self.leftButton = nil;
    self.createNewOption = isM(options[@"create"]) ? [options[@"create"] boolValue] : NO;
    
    if(sections) [self setSections:sections active:activeSegmentIndex];
    NSArray *tabs = [options objectForKey:@"tabs"];
    NSInteger activeTab = [options objectForKey:@"activeTab"] ? [[options objectForKey:@"activeTab"] integerValue] : 0;

    if(tabs) [self setTabs:tabs active:activeTab];
    
    
    if([options objectForKey:@"panel"] && [[options objectForKey:@"panel"] isKindOfClass:[MysticPanelObject class]])
    {
        [self.panels addObject:[options objectForKey:@"panel"]];
        [options removeObjectForKey:@"panel"];
    }
    else if([options objectForKey:@"panel"] && [[options objectForKey:@"panel"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *topPanelInfo = [options objectForKey:@"panel"] && [[options objectForKey:@"panel"] isKindOfClass:[NSDictionary class]] ? [[options objectForKey:@"panel"] copy] : nil;
        NSMutableDictionary *newPanelInfo = [NSMutableDictionary dictionary];
        [newPanelInfo addEntriesFromDictionary:_options];
        [newPanelInfo addEntriesFromDictionary:topPanelInfo];
        [newPanelInfo removeObjectForKey:@"panel"];
        MysticPanelObject *topPanelObjFromInfo = [MysticPanelObject info:(id)newPanelInfo];

        topPanelObjFromInfo.panel = self;
        [self.panels addObject:topPanelObjFromInfo];
        [topPanelInfo release];

    }
    else
    {
        MysticPanelObject *pObj = [self topPanel];
        if(pObj) pObj.panel = self;
    }
}
- (void) setSections:(NSArray *)sections active:(NSInteger)activeSegment;
{
    if(sections.count)
    {
        self.lastSelectedSegment = NSNotFound;
        [self.options setObject:sections forKey:@"sections"];
        NSMutableArray *sectionTitles = [NSMutableArray array];
        int i = 1;
        for (NSDictionary *section in sections) {
            NSString *sectionTitle = [section objectForKey:@"title"];
            if(sectionTitle)
            {
                [sectionTitles addObject:sectionTitle];
            }
            else
            {
                UIImage *sectionImage = [section objectForKey:@"image"];
                if(sectionImage)
                {
                    [sectionTitles addObject:sectionImage];
                }
            }
            
            i++;
        }
        
        if(sectionTitles.count)
        {
            MysticSegmentedControl *__segmentedControl;
            
            if(self.segmentedControl)
            {
                self.segmentedControl = nil;

            }
            __segmentedControl = [[MysticSegmentedControl alloc] initWithItems:sectionTitles itemInfo:sections];
            
            [__segmentedControl setupWidths];
            
            [__segmentedControl addTarget:self
                                 action:@selector(segmentChanged:)
                       forControlEvents:UIControlEventValueChanged];
            __segmentedControl.selectedSegmentIndex = activeSegment;
            CGPoint nc = self.bottomBarView.contentCenter;
            nc.y = (self.bottomBarView.contentBounds.size.height/2) + MYSTIC_UI_PANEL_SEGMENTS_OFFSETY;
            CGRect sframe = __segmentedControl.frame;
            sframe.size.height = MYSTIC_UI_PANEL_SEGMENTS_HEIGHT;
            __segmentedControl.frame = sframe;
            __segmentedControl.center = nc;
            self.lastSelectedSegment = activeSegment;
            self.segmentedControl = __segmentedControl;
            
            [self.bottomBarView addSubview:self.segmentedControl];
            
            
            [__segmentedControl release];
            
            [self setNeedsLayout];
        }
    }
}

- (MysticLayerToolbar *) toolbar;
{
    return self.bottomBarView.toolbar;
}
- (void) setSegmentedControl:(MysticSegmentedControl *)control;
{
    if(!control && self.segmentedControl)
    {
        self.lastSelectedSegment = NSNotFound;
        [self.segmentedControl removeFromSuperview];
        [self.segmentedControl removeTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    }
    if(control && self.tabBar && !self.showTabsAndSections)
    {
        self.tabBar = nil;
    }
    if(_segmentedControl) [_segmentedControl release], _segmentedControl=nil;
    _segmentedControl = [control retain];
    
}

- (void) setTabBar:(MysticTabBarPanel *)control;
{
    if(!control && self.tabBar)
    {
        self.lastSelectedTab = NSNotFound;
        self.tabBar.delegate = nil;
        [self.tabBar removeFromSuperview];
    }
    if(control && self.segmentedControl && !self.showTabsAndSections)
    {
        self.segmentedControl = nil;
    }
    if(_tabBar) [_tabBar release], _tabBar=nil;
    _tabBar = [control retain];
    
}

- (void) setTabs:(NSArray *)tabs active:(NSInteger)activeTab;
{
    
    CGRect sframe = self.bottomBarView.bounds;
    self.lastSelectedTab = NSNotFound;

    
    if(tabs.count)
    {
        BOOL needsRelayout = NO;
        if(self.tabBar)
        {
            self.tabBar = nil;
            
        }
    
        if(self.segmentedControl && self.showTabsAndSections)
        {
            CGRect f = self.bottomBarView.frame;
            CGRect sf = self.segmentedControl.frame;

            CGRect f2 = f;
            f.size.height = sf.size.height + (sframe.size.height + 15) ;
            
            CGFloat r = (f.size.height - sframe.size.height) - sf.size.height;
            sf.origin.y = f.size.height - sf.size.height - r;
            sframe.size.height -= (r/2);
            self.segmentedControl.frame = sf;
            
            self.bottomBarView.frame = f;
            needsRelayout = YES;
            self.offsetY = sf.size.height + 10;
            self.segmentedControl.hidden = YES;

            
        }
        


        
        MysticTabBarPanel *panelTabBar = [[MysticTabBarPanel alloc] initWithFrame:sframe];
        panelTabBar.tabBarDelegate = self;
        panelTabBar.debug=NO;
        panelTabBar.options = tabs;
        
        panelTabBar.hidden = NO;
        panelTabBar.userInteractionEnabled = YES;
        self.lastSelectedTab = activeTab;

        [self.bottomBarView addSubview:panelTabBar];
        self.tabBar = [panelTabBar autorelease];
        if(activeTab != NSNotFound) [self.tabBar setSelectedIndex:activeTab callEvent:NO];
        if(needsRelayout)
        {
            [self relayout];
            
        }
    }
}

- (MysticPanelType) sectionType;
{
    MysticPanelObject *section = [self section:self.segmentedControl.selectedSegmentIndex];
    return section.sectionType;
}
- (void) update;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:updateSection:)])
    {
        if(self.segmentedControl)
        {
            MysticPanelObject *section = [self section:self.segmentedControl.selectedSegmentIndex];
            [self.delegate layerPanel:self updateSection:section];
        }
        else if(self.tabBar)
        {
            MysticPanelObject *section = [self section:self.tabBar.selectedIndex];
            [self.delegate layerPanel:self updateSection:section];
        }
        
        
    }
}

- (void) disable;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:disableSection:)])
    {
        MysticPanelObject *section = [self section:self.segmentedControl.selectedSegmentIndex];
        
        [self removeContentView];
        if(self.segmentedControl)
        {
            self.segmentedControl.enabled = NO;
            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
        if(self.tabBar)
        {
            self.tabBar.userInteractionEnabled = NO;
            self.tabBar.selectedIndex = NSNotFound;
        }
        self.enabled = NO;
        [self.delegate layerPanel:self disableSection:section];
    }
}

- (void) reload;
{
    [self reload:NO];
}
- (void) reload:(BOOL)resetAll;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:refreshSection:)])
    {
        MysticPanelObject *section = [self section:self.segmentedControl.selectedSegmentIndex];
        if(section)
        {
            [section setObject:@(resetAll) forKey:@"resetAll"];
        }
        MysticBlockObject f = [self.delegate layerPanel:self sectionDidChange:section];
        if(f) { f(self.contentView); Block_release(f); }

    }
}

- (void) refresh;
{
    if(!self.enabled)
    {
        if(self.segmentedControl)
        {
            self.segmentedControl.selectedSegmentIndex = self.lastSelectedSegment;
            [self segmentChanged:self.segmentedControl];
        }
        if(self.tabBar)
        {
            [self.tabBar setSelectedIndex:self.lastSelectedTab callEvent:YES];
        }
        return;
    }
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:refreshSection:)])
    {
        if(self.segmentedControl)
        {
            MysticPanelObject *section = [self section:self.segmentedControl.selectedSegmentIndex];
            [self.delegate layerPanel:self refreshSection:section];
        }
        else if(self.tabBar)
        {
            MysticPanelObject *section = [self section:self.tabBar.selectedIndex];
            [self.delegate layerPanel:self refreshSection:section];
        }
    }
    
    [self update];

}
- (void) segmentChanged:(UISegmentedControl *)sender;
{

    if(sender.selectedSegmentIndex == UISegmentedControlNoSegment) return;
    if(self.state == MysticLayerPanelStateClosed) return;
    if(sender.selectedSegmentIndex == self.lastSelectedSegment && self.contentView != nil && self.enabled) return;

    self.lastSelectedSegment = sender.selectedSegmentIndex;
    if(!self.enabled) self.enabled = YES;

    if(self.tabBar)
    {
        [self.tabBar setSelectedIndex:NSNotFound callEvent:YES];
    }
    else if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:selectedSection:)])
    {
        MysticPanelObject *section;

        if(sender.selectedSegmentIndex != UISegmentedControlNoSegment)
        {
            section = [self section:sender.selectedSegmentIndex];
        
            [self.delegate layerPanel:self selectedSection:section];
        }
        
    }
    
}



- (void) relayout;
{
//    CGRect n = self.frame;
//    
//    n.size.height = self.openSize.height;
    
    
    
//    _state = MysticLayerPanelStateOpening;
    [self setNeedsLayout];

}

- (void) rebuild;
{
    [self rebuild:self.topPanel animated:YES complete:nil];
}
- (void) rebuild:(MysticPanelObject *)section animated:(BOOL)animated complete:(MysticBlock)finished;
{
    __unsafe_unretained __block MysticBlock _finished = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    __unsafe_unretained __block MysticPanelObject *_section = [self.delegate layerPanel:self panelObjectForSection:section];
    __unsafe_unretained __block MysticLayerToolbar *toolbar = [self.bottomBarView.toolbar retain];
    __block MysticPanelObject *oldPanel = !self.visiblePanel ? nil : [self.visiblePanel retain];
    if(oldPanel) [oldPanel willDisappear];
    self.visiblePanel = _section;
    [_section prepareContainerView:self complete:nil];
    MysticAnimationTransition anim = _section.viewHasAppeared ? _section.animationTransition : MysticAnimationTransitionNormal;
    switch (anim)
    {
        case MysticAnimationTransitionHideBottom:
        {
            
            [self reset:NO removeContent:NO removeToolbar:NO];
            weakSelf.stopLayout = YES;
            weakSelf.autoresizesSubviews = NO;
            weakSelf.contentContainerView.autoresizesSubviews = NO;
            MysticAnimation *animation = [MysticAnimation animationWithDuration:0.15];
            animation.animationOptions = UIViewAnimationCurveEaseInOut;
            [animation addAnimation:^{
                toolbar.alpha = 0;
                weakSelf.contentContainerView.frame = (CGRect){0,weakSelf.bottomBarView.frame.origin.y, weakSelf.contentContainerView.frame.size.width, _section.view.frame.size.height};
            } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                weakSelf.contentContainerView.alpha = 0;
                [weakSelf.contentView removeFromSuperview];
                weakSelf.contentView = nil;
                [weakSelf.contentContainerView addSubview:_section.view];
                [weakSelf keepContentView:_section.view];
            
                [toolbar replaceItemsWithInfo:[[weakSelf class] toolbarItemsForSection:_section type:_section.optionType target:toolbar.delegate toolbar:toolbar] animated:NO];
                
                
                
                [toolbar setTitle:_section.toolbarTitle ? _section.toolbarTitle : MysticObjectTypeTitleParent(_section.optionType, MysticObjectTypeUnknown) animated:NO];
                MysticAnimation *animation2 = [MysticAnimation animationWithDuration:0.15];
                animation2.animationOptions = UIViewAnimationCurveEaseInOut;
                [animation2 addAnimation:^{
                    weakSelf.contentContainerView.alpha = 1;
                    weakSelf.contentContainerView.frame = CGRectIntegral((CGRect){0,0,weakSelf.contentContainerView.frame.size.width,  weakSelf.contentContainerView.frame.size.height});
                    weakSelf.bottomBarView.frame = (CGRect){0,weakSelf.contentContainerView.frame.size.height, weakSelf.bottomBarView.frame.size.width, _section.bottomBarHeight};
                    toolbar.alpha = 1;
                    weakSelf.frame = [weakSelf frameForState:MysticLayerPanelStateOpen];
                }];
                [animation2 animate:^(BOOL finished2, MysticAnimationBlockObject *obj2) {
                    if(oldPanel) [oldPanel release];
                    weakSelf.stopLayout = NO;
                    weakSelf.autoresizesSubviews = YES;
                    weakSelf.contentContainerView.autoresizesSubviews = YES;
                    [weakSelf.visiblePanel willAppear];
                    if(_finished) { _finished(); Block_release(_finished); }
                    [toolbar release];
                }];
            }];
            [animation animate];
            break;
        }
        default:
        {
            
            [self reset:NO removeContent:NO removeToolbar:YES];
            [self replaceContentViewAndResize:_section.view duration:0.2 completion:^(id object) {
                if(oldPanel) { [oldPanel didDisappear]; [oldPanel release]; }
                [weakSelf.visiblePanel willAppear];
                if(_finished) { _finished(); Block_release(_finished); }
                [toolbar release];
            }];
            break;
        }
    }
}


- (void) buildFirstContentViewAnimated:(BOOL)animated complete:(MysticBlock)finished;
{
    BOOL useAnimStart = YES;
    CGRect newFrame = self.frame;
    MysticPanelObject *section;
    
    if(self.hasSectionNavigationControl)
    {
        section = [self section:self.selectedControlIndex];
    }
    else
    {
        section = [self topPanelOrTab];
    }
    
    section = [self.delegate layerPanel:self panelObjectForSection:section];
    
    if(section)
    {
        __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
        
        self.visiblePanel = section;
        useAnimStart = NO;
        UIView *theView = section.view;        
        self.contentSize = theView.frame.size;
        newFrame.size.height = self.openSize.height;

        CGRect cFrame = theView.frame;
        CGRect ccFrame = self.contentContainerView.frame;
        ccFrame.origin.y = 0;
        cFrame.size.height = MAX(MYSTIC_UI_PANEL_HEIGHT_MIN, cFrame.size.height);
        theView.frame = cFrame;
        theView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        ccFrame.size = theView.frame.size;
        ccFrame.size.height = MAX(MYSTIC_UI_PANEL_HEIGHT_MIN, ccFrame.size.height);
        self.contentContainerView.frame = ccFrame;
        
        if(self.contentContainerView.hidden) self.contentContainerView.hidden = NO;
        
        [self animationWillStart:@"layerPanel" finished:@(YES) context:nil];
        
        [section prepareContainerView:self complete:nil];
        self.frame = newFrame;
        [self retainContentView:theView];
        [section willAppear];

        __block MysticBlock oldFinished = finished ? Block_copy(finished) : nil;

        if(oldFinished)
        {
            oldFinished();
            Block_release(oldFinished);
        }
        
    }
}


- (void) setTopPanel:(MysticPanelObject *)panelObj;
{
    [self setTopPanel:panelObj complete:nil];
}
- (void) setTopPanel:(MysticPanelObject *)panelObj complete:(MysticBlock)finished;
{
    panelObj.panel = self;
    if(![self.panels containsObject:panelObj]) [self.panels addObject:panelObj];
    [self rebuild:panelObj animated:YES complete:finished];
}

- (MysticPanelObject *)panelObjectAtIndex:(NSInteger)index;
{
    if(index < self.panels.count) return [self.panels objectAtIndex:index];
    return nil;
}

- (MysticPanelObject *) topPanel;
{
    MysticPanelObject *aSection = [self.panels lastObject];
    return aSection;
}
- (MysticPanelObject *) topPanelOrTab;
{
    MysticPanelObject *aSection = [self topPanel];
    if(aSection)
    {
        return aSection;
    }
    else if(self.tabBar)
    {
        return [self section:self.tabBar.selectedIndex];
    }
    else if(self.segmentedControl)
    {
        return [self section:self.segmentedControl.selectedSegmentIndex];
    }
    return nil;
    
    
}

- (void) pushPanel:(MysticPanelObject *)newPanelObject;
{
    [self pushPanel:newPanelObject complete:nil];
}
- (void) pushPanel:(MysticPanelObject *)newPanelObject complete:(MysticBlock)complete;
{
    newPanelObject.panel = self;

    if(![self.panels containsObject:newPanelObject])
    {
        [self.panels addObject:newPanelObject];
    }
    [self rebuild:newPanelObject animated:YES complete:complete];

}
- (BOOL) hasPreviousPanel;
{
    return self.panels.count > 1;
}
- (MysticPanelObject *) previousPanel;
{
    if(!self.visiblePanel) return self.panels.count > 1 ? [self panelObjectAtIndex:self.panels.count - 1] : nil;
    NSInteger i = [self.panels indexOfObject:self.visiblePanel];
    if(i != NSNotFound && i > 0)
    {
        id p = [self panelObjectAtIndex:i - 1];
        if(p && p != self.visiblePanel) return p;
    }
    return nil;
}
- (MysticPanelObject *) popToPreviousPanel;
{
    return [self popToPreviousPanel:nil];
}
- (MysticPanelObject *) popToPreviousPanel:(MysticBlock)complete;
{
    MysticPanelObject *prevPanel = self.previousPanel;
    prevPanel = prevPanel ? [prevPanel retain] : nil;
    if(!prevPanel) return nil;
    [prevPanel resetPanel];
    [self.panels removeLastObject];
    [self setTopPanel:prevPanel complete:complete];
    return [prevPanel autorelease];
}
- (void) setVisiblePanel:(MysticPanelObject *)newPanelObj;
{
    if(_visiblePanel)
    {
        [_visiblePanel release], _visiblePanel = nil;
    }
    newPanelObj.panel = self;
    _visiblePanel = newPanelObj ? [newPanelObj retain] : nil;
}


- (void) mysticTabBar:(MysticTabBar *)tabBar didSelectItem:(MysticTabButton *)item info:(id)userInfo;
{
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;
    if(self.state == MysticLayerPanelStateClosed) return;
    if(tabBar.selectedIndex == self.lastSelectedTab && self.contentView != nil && self.enabled) return;
    
    
    self.lastSelectedTab = tabBar.selectedIndex;
    if(!self.enabled) self.enabled = YES;
    
    if(self.showTabsAndSections && self.segmentedControl && CGAffineTransformEqualToTransform(self.segmentedControl.transform, CGAffineTransformIdentity) && self.lastSelectedTab != NSNotFound)
    {
        [MysticUIView animateWithDuration:0.3 animations:^{
            weakSelf.segmentedControl.transform = CGAffineTransformMakeTranslation(0, 40);

        }];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanel:selectedTabSection:)])
    {
        MysticPanelObject *section;
        
        if(tabBar.selectedIndex != NSNotFound && tabBar.selectedIndex > -1)
        {
            section = [MysticPanelObject info:item.userInfo];
            
            [self.delegate layerPanel:self selectedTabSection:section];
        }
        else
        {
            [self.tabBar revealItem:nil complete:^(id object) {
                [weakSelf hideContentView:nil];

            }];
        }
        
    }

}
- (void) tabBarDidScroll:(MysticTabBar *)tabBar;
{
    
}
- (void) setCurrentSetting:(MysticObjectType)setting;
{
    
}


- (void) hideContentView:(MysticBlock)finished;
{
    __unsafe_unretained __block MysticLayerPanelView *weakSelf = self;

    
    if(self.delegate && [self.delegate respondsToSelector:@selector(layerPanelContentWillHide:)])
    {
        [self.delegate layerPanelContentWillHide:self];
    }
    [self removeContentView];
    CGRect cf = self.contentContainerView.frame;
    cf.origin.y = self.bottomBarView.frame.origin.y;
    self.contentContainerView.frame = cf;
    self.contentContainerView.hidden = YES;
    self.bottomBarView.showBorder = NO;
    
    CGRect f = self.frame;
    
    f.size.height = self.bottomBarView.frame.size.height;
    
    f.origin.y = self.anchor.y - f.size.height;
    
    [MysticUIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = f;
    } completion:^(BOOL finisheda) {
        
//        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(layerPanelFrameChanged:state:)])
//        {
//            [weakSelf.delegate layerPanelFrameChanged:weakSelf state:weakSelf.state];
//        }
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(layerPanelContentDidHide:)])
        {
            [weakSelf.delegate layerPanelContentDidHide:weakSelf];
        }
        
        if(finished) finished();
    }];
    
}



- (CGFloat) offsetY;
{
    if(self.showTabsAndSections)
    {
        if(self.tabBar.selectedIndex == NSNotFound)
        {
            return 0;
        }
    }
    return _offsetY;
}
- (CGFloat) visibleHeight;
{
    CGFloat ay = self.anchor.y - self.contentSize.height - self.openInset - self.bottomBarView.frame.size.height + self.offsetY;
    
    return self.anchor.y - ay;
    
}
- (CGRect) contentFrame;
{
    return CGRectMake(0,0, self.frame.size.width, self.frame.size.height - self.bottomBarView.frame.size.height);
}
- (CGSize) openSize;
{
    return CGSizeMake(self.bounds.size.width, self.contentSize.height + self.bottomBarView.frame.size.height);
}

- (CGSize) contentSize;
{
    if(self.contentContainerView.hidden) return CGSizeZero;
    return _contentSize;
}


- (void) layoutSubviews;
{
    if(self.stopLayout) return;
    
    CGRect bbf = self.bottomBarView.frame;
    bbf.origin.y = self.frame.size.height - bbf.size.height;
    self.bottomBarView.frame = bbf;
    CGRect ccf = self.frame;
    ccf.origin = CGPointZero;
    ccf.size.height = ccf.size.height - bbf.size.height;
    self.contentContainerView.frame = ccf;
    self.contentView.frame = self.contentContainerView.bounds;
    
    CGRect bbf2 = self.bounds;
    bbf2.origin = self.contentContainerView.frame.origin;
    bbf2.size.height = self.bottomBarView.frame.size.height + self.contentContainerView.frame.size.height;
    
    self.backgroundView.frame = bbf2;
    [super layoutSubviews];

    
}
@end

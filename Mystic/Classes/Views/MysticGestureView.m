//
//  MysticGestureView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/26/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticGestureView.h"
#import "MysticController.h"

@implementation MysticGestureView

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}
- (void) setup;
{
    self.controller = [MysticController controller];
    self.multipleTouchEnabled=YES;
}
- (void) setupPreviousGestures;
{
    [self setupGestures:self.previousGesutreState disable:self.previousGestureDisabled];

}
- (void) disableGestures; { [self enableGestures:NO]; }
- (void) enableGestures; { [self enableGestures:YES]; }

- (void) enableGestures:(BOOL)enabled;
{
    self.controller.areGesturesEnabled = enabled;
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) gesture.enabled = enabled;
}

- (void) setupGestures:(MysticObjectType)state;
{
    [self setupGestures:state disable:NO];
}
- (void) setupGestures:(MysticObjectType)state disable:(BOOL)disableGestures;
{
    __unsafe_unretained __block MysticController *weakSelf = self.controller;
    self.controller.navigationController.toolbar.userInteractionEnabled = NO;
    self.previousGesutreState = state;
    self.previousGestureDisabled = disableGestures;
    if(state == MysticObjectTypeUnknown) state = self.controller.currentSetting;
    self.controller.imageView.scrollView.gestureDelegate=nil;
    self.controller.imageView.scrollView.longpressAction = nil;
    [self updateFrame];
    self.state = state;
    BOOL shouldPrintView = NO;
    switch (state) {
        case MysticObjectTypeSketch: disableGestures = YES; break;
        default: break;
    }
    if(disableGestures)
    {
        self.gestureRecognizers = @[];
        self.controller.imageView.scrollView.tapAction = nil;
        [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
        [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
        self.controller.imageView.scrollView.scrollEnabled = YES;
        [self.controller.imageView.scrollView resetPosition:YES];
    }
    else
    {
        switch (state) {
            case MysticObjectTypeFont:
            case MysticObjectTypeFontStyle:
            case MysticSettingChooseFont:
            case MysticSettingEditType:
            case MysticSettingEditFont:
            case MysticSettingType:
            case MysticSettingTypeNew:
            case MysticSettingShape:
            case MysticObjectTypeShape:
            case MysticObjectTypeLayerShape:
            case MysticSettingPreferences:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                self.gestureRecognizers = @[];
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                self.controller.imageView.userInteractionEnabled = YES;
                self.controller.imageView.scrollView.scrollEnabled = NO;
                self.controller.imageView.scrollView.userInteractionEnabled = YES;
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                break;
            }
            case MysticSettingAdjustColor:
            case MysticSettingEyeDropper:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(tappedImage:)] autorelease];
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedImage:)] autorelease];
                UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self.controller action:@selector(longPressedImage:)] autorelease];
                self.gestureRecognizers = @[tapGesture, panGesture, longPressGesture];
                break;
            }
            case MysticSettingVignette:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(tappedVignette:)] autorelease];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedVignette:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedVignette:)] autorelease];
                UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pinchedVignette:)] autorelease];
                self.gestureRecognizers = @[pinchGesture, panGesture, tapGesture,  doubletapGesture];

                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
   
                break;
            }
            case MysticSettingTiltShift:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(tappedTiltShift:)] autorelease];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedTiltShift:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedTiltShift:)] autorelease];
                UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pinchedTiltShift:)] autorelease];
                self.gestureRecognizers = @[pinchGesture, panGesture, tapGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                
                break;
            }
            case MysticSettingBlurCircle:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedBlurCircle:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedBlurCircle:)] autorelease];
                UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pinchedBlurCircle:)] autorelease];
                self.gestureRecognizers = @[pinchGesture, panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingBlurZoom:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedBlurZoom:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedBlurZoom:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingDistortStretch:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedDistortStretch:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedDistortStretch:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingDistortPinch:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedDistortPinch:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedDistortPinch:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingDistortSwirl:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedDistortSwirl:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedDistortSwirl:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingDistortBuldge:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedDistortBuldge:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedDistortBuldge:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingDistortGlassSphere:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedDistortSphere:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedDistortSphere:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingBlurMotion:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                shouldPrintView = YES;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *doubletapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(doubleTappedBlurMotion:)] autorelease];
                doubletapGesture.numberOfTapsRequired = 2;
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pannedBlurMotion:)] autorelease];
                self.gestureRecognizers = @[panGesture,  doubletapGesture];
                
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                self.controller.imageView.userInteractionEnabled = NO;
                break;
            }
            case MysticSettingLaunch:
            case MysticSettingNone:
            case MysticSettingNoneFromBack:
            case MysticSettingNoneFromCancel:
            case MysticSettingNoneFromConfirm:
            case MysticSettingNoneFromLoadProject:
            case MysticSettingOptions:
            case MysticSettingLayers:
            case MysticSettingShare:
            {
                self.gestureRecognizers = @[];
                self.controller.imageView.scrollView.scrollEnabled = YES;
                [self.controller.imageView.scrollView resetPosition:YES];
                self.controller.imageView.userInteractionEnabled=YES;
                self.controller.imageView.scrollView.userInteractionEnabled = YES;
                self.controller.imageView.scrollView.gestureDelegate = self.controller;
                self.controller.imageView.scrollView.longpressAction = @selector(longPress:);
                self.controller.imageView.scrollView.tapAction = @selector(tapped:);

                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeCustom];
                [self.controller.mm_drawerController
                 setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *dc, UIGestureRecognizer *gesture, UITouch *t) {
                     return NO;
//                     if(![[(MysticNavigationViewController *)dc.centerViewController visibleViewController] isEqual:weakSelf]) return NO;
//                     
//                     BOOL recognize = NO;
//                     BOOL isPan =  [gesture isKindOfClass:[UIPanGestureRecognizer class]];
//                     if(dc.openSide == MMDrawerSideNone && isPan)
//                         recognize = !(CGRectContainsPoint(weakSelf.bottomPanelView.bounds, [t locationInView:weakSelf.bottomPanelView]));
//                     if(weakSelf.imageView.scrollView.isZooming) recognize = NO;
//                     if(recognize && isPan) recognize = !(CGRectContainsPoint(weakSelf.layerPanelView.bounds, [t locationInView:weakSelf.layerPanelView]));
//                     if(recognize && isPan && weakSelf.undoRedoTools) recognize = !(CGRectContainsPoint(weakSelf.undoRedoTools.bounds, [t locationInView:weakSelf.undoRedoTools]));
//
//                     if(recognize && isPan && weakSelf.sketchView && weakSelf.sketchView.userInteractionEnabled) recognize = !(CGRectContainsPoint(weakSelf.sketchView.bounds, [t locationInView:weakSelf.sketchView]));
//                     weakSelf.currentOpenSide = dc.openSide;
////                     DLog(@"recognize: %@ -> %@", b(recognize), gesture.class);
//                     return recognize;
                 }];
                break;
            }
            case MysticObjectTypeText:
            case MysticObjectTypeTexture:
            case MysticObjectTypeFrame:
            case MysticObjectTypeLight:
            case MysticObjectTypeBadge:
            case MysticObjectTypeLayer:
            case MysticObjectTypeImage:
            case MysticObjectTypeCamLayer:
//            case MysticObjectTypeColorOverlay:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [self.controller.mm_drawerController setGestureShouldRecognizeTouchBlock:nil];
                UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(tapped:)] autorelease];
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(panned:)] autorelease];
                UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pinched:)] autorelease];
                UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self.controller action:@selector(longPress:)] autorelease];
                
                self.gestureRecognizers = @[ pinchGesture, panGesture, tapGesture, longPressGesture];
                self.controller.imageView.scrollView.scrollEnabled = NO;
                self.controller.imageView.scrollView.userInteractionEnabled = NO;
                [self.controller.imageView.scrollView resetPosition:YES];
                break;
            }
            case MysticSettingMaskLayer:
            case MysticSettingMask:
            case MysticSettingMaskFill:
            case MysticSettingMaskBrush:
            case MysticSettingMaskEmpty:
            case MysticSettingMaskErase:
            {
                self.gestureRecognizers = @[];
                self.controller.imageView.scrollView.scrollEnabled = YES;
                [self.controller.imageView.scrollView resetPosition:YES];
                self.controller.imageView.userInteractionEnabled=YES;
                self.controller.imageView.scrollView.userInteractionEnabled = YES;
                self.controller.imageView.scrollView.gestureDelegate = self.controller;
                self.controller.imageView.scrollView.longpressAction = @selector(longPress:);
                self.controller.imageView.scrollView.tapAction = @selector(tapped:);
                
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeCustom];
                [self.controller.mm_drawerController
                 setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *dc, UIGestureRecognizer *gesture, UITouch *t) {
                     return NO;
                 }];
                [self.controller.imageView.scrollView resetPosition:YES];

                break;
            }
            default:
            {
                self.controller.imageView.scrollView.tapAction = nil;
                [self.controller.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                [self.controller.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeCustom];
                [self.controller.mm_drawerController
                 setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
                     id visibleCenterController = [(MysticNavigationViewController *)drawerController.centerViewController visibleViewController];
                     if(![visibleCenterController isEqual:weakSelf]) return NO;
                     weakSelf.currentOpenSide = drawerController.openSide;
                     BOOL recognize = NO;
                     if(drawerController.openSide == MMDrawerSideNone &&
                        [gesture isKindOfClass:[UIPanGestureRecognizer class]]){
                         if(CGRectContainsPoint(weakSelf.view.bounds, [touch locationInView:weakSelf.view])
                            && !(CGRectContainsPoint(weakSelf.layerPanelView.bounds, [touch locationInView:weakSelf.layerPanelView])))
                         {
                             recognize = !(CGRectContainsPoint(weakSelf.bottomPanelView.bounds, [touch locationInView:weakSelf.bottomPanelView]));
                             if(recognize && weakSelf.labelsView && weakSelf.labelsView.userInteractionEnabled) recognize = !(CGRectContainsPoint(weakSelf.labelsView.bounds, [touch locationInView:weakSelf.labelsView]));
                             if(recognize && weakSelf.shapesView && weakSelf.shapesView.userInteractionEnabled) recognize = !(CGRectContainsPoint(weakSelf.shapesView.bounds, [touch locationInView:weakSelf.shapesView]));
                             if(recognize && weakSelf.sketchView && weakSelf.sketchView.userInteractionEnabled) recognize = !(CGRectContainsPoint(weakSelf.sketchView.bounds, [touch locationInView:weakSelf.sketchView]));
                         }
                     }
                     return recognize;
                 }];
                UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self.controller action:@selector(panned:)] autorelease];
                UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self.controller action:@selector(pinched:)] autorelease];
                UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self.controller action:@selector(longPress:)] autorelease];
                self.gestureRecognizers = @[pinchGesture, panGesture, longPressGesture];
                self.controller.imageView.scrollView.scrollEnabled = NO;
                [self.controller.imageView.scrollView setZoomScale:1 animated:YES];
                break;
            }
        }
    }
    self.userInteractionEnabled = self.gestureRecognizers.count > 0;
    self.multipleTouchEnabled=self.userInteractionEnabled;
//    DLog(@"setup gestures: %@  %@  gestures: %@", m(state), b(self.userInteractionEnabled), viewGesturesString(self));
//    PrintView(@"gestures", self);
}

- (void) updateFrame;
{
    CGFloat offsetY = 0;
    if(self.controller.addTabBar) offsetY = self.controller.addTabBar.frame.size.height;
    else if(self.controller.layerPanelView) offsetY = self.controller.layerPanelView.frame.size.height;
    else if(self.controller.bottomPanelView) offsetY = self.controller.bottomPanelView.frame.size.height;
    self.frame = CGRectYH(self.frame, 0, self.controller.view.frame.size.height -offsetY);
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
//    if([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) return NO;
    return YES;
}

@end

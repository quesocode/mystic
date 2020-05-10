//
//  WDCanvasController.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2009-2013 Steve Sprang
//

#import "OrientationViewController.h"
#import "WDActionNameView.h"
#import "WDActionSheet.h"
#import "WDBar.h"
#import "WDDocumentReplay.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "AHKActionSheet.h"

typedef enum {
    WDInterfaceModeHidden, // all adornments are hidden
    WDInterfaceModeLoading,   // only progress indicator and top bar
    WDInterfaceModePlay, // play button, unlock slider and top bar
    WDInterfaceModeEdit, // brush control, bottom bar and top bar
    WDInterfaceModeHiddenExceptToolbar,
} WDInterfaceMode;

@class WDActionNameView;
@class WDArtStoreController;
@class WDBarColorWell;
@class WDBarSlider;
@class WDCanvas;
@class WDColorBalanceController;
@class WDColorPickerController;
@class WDColorWell;
@class WDDocument;
@class WDHueSaturationController;
@class WDLayerController;
@class WDLobbyController;
@class WDMenu;
@class WDMenuItem;
@class WDPainting;
@class WDProgressView;
@class WDUnlockView;

@interface WDCanvasController : OrientationViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                                    MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate,
                                                        WDActionSheetDelegate, WDDocumentReplayDelegate, WDActionNameViewDelegate>
{
    WDBarItem           *album_;
    WDBarItem           *undo_;
    WDBarItem           *redo_;
    WDBarItem           *gear_;
    WDBarItem           *layer_;
    WDColorWell         *colorWell_;
    WDBarSlider         *brushSlider_;
    
    WDMenu              *gearMenu_;
    WDMenu              *actionMenu_;
    WDMenu              *visibleMenu_; // pointer to currently active menu
    
    UIPopoverController *popoverController_;
    
    WDLayerController   *layerController_;
    WDLobbyController   *lobbyController_;

    WDHueSaturationController   *hueController_;
    WDColorBalanceController   *balanceController_;
}

@property (nonatomic, strong) WDDocument *document;
@property (nonatomic, strong) WDDocumentReplay *replay;
@property (weak, nonatomic, readonly) WDPainting *painting;
@property (nonatomic, strong) NSDictionary *canvasSettings;
@property (nonatomic, weak) UIColor *paintColor;
@property (nonatomic, readonly) WDCanvas *canvas;
@property (nonatomic, strong) UIView *canvasContainer;
@property (nonatomic, strong) UINavigationController *brushController;
@property (nonatomic, strong) WDColorPickerController *colorPickerController;

@property (nonatomic, strong) WDActionSheet *shareSheet;
@property (nonatomic, strong) AHKActionSheet *gearSheet;

@property (nonatomic, weak) WDBar *topBar;
@property (nonatomic, weak) WDBar *bottomBar;
@property (nonatomic, strong) WDUnlockView *unlockView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) WDProgressView *progressIndicator;
@property (nonatomic, strong) NSArray *editingTopBarItems;
@property (nonatomic, assign) BOOL popoverVisible, isBuilt;
@property (nonatomic, assign) CGFloat scaleHeight, scaleWidth, scaleSizeHeight;
@property (nonatomic, readonly) BOOL runningOnPhone;
@property (nonatomic, assign) WDInterfaceMode interfaceMode;
@property (nonatomic, readonly) BOOL interfaceHidden;
@property (nonatomic, assign) BOOL hasAppearedBefore;
@property (nonatomic, assign) BOOL needsToResetInterfaceMode;
@property (nonatomic, strong) NSNumber *replayScale;

@property (nonatomic, strong) WDActionNameView *actionNameView;
@property (nonatomic, assign) BOOL wasPlayingBeforeRotation;

@property (nonatomic, strong) WDArtStoreController *artStoreController;
- (void) updateLayersButton;

- (void) updateTitle;
- (void) hidePopovers;
- (void) hideInterface:(WDInterfaceMode)mode;

- (BOOL) shouldDismissPopoverForClassController:(Class)controllerClass insideNavController:(BOOL)insideNav;
- (void) showController:(UIViewController *)controller fromBarButtonItem:(UIBarButtonItem *)barButton animated:(BOOL)animated;
- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender;
- (void) takeBrushSizeFrom:(WDBarSlider *)sender;
- (void) registerNotifications;

- (void) validateMenuItem:(WDMenuItem *)item;
- (void) validateVisibleMenuItems;

- (void) undoStatusDidChange:(NSNotification *)aNotification;
- (void) brushChanged:(NSNotification *)aNotification;

- (UIImage *) layerImage;

- (void) showInterface;
- (void) hideInterface;
- (void) showLayers:(id)sender;
- (void) showBrushPanel:(id)sender;
- (void) showGearSheet:(id)sender;
- (void) showGearMenu:(id)sender;
- (void) showSettings:(id)sender;
- (void) setBrushTool:(id)sender;
- (void) setEraserTool:(id)sender;

- (void) oneTap:(UITapGestureRecognizer *)recognizer;

- (void) undo:(id)sender;
- (void) redo:(id)sender;
- (void) setInterfaceMode:(WDInterfaceMode)inInterfaceMode force:(BOOL)force;
- (void) buildViews;

@end


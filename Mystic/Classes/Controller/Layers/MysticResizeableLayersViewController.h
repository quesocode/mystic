//
//  MysticResizeableLayersViewController.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticLayerView.h"
#import "MysticOverlaysView.h"
#import "MysticGridView.h"
#import "MysticMoveableView.h"
#import "MysticLayerViewAbstract.h"



@interface MysticResizeableLayersViewController : UIViewController <MysticLayerViewDelegate, MysticOverlaysViewDelegate>

@property (nonatomic, assign) NSInteger nextLayerIndex;

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id selectedLayer, keyObjectLayer;
@property (nonatomic, readonly) id newestOverlay;
@property (nonatomic, retain) MysticGridView *gridView;
@property (nonatomic, assign) UIView *parentView, *backgroundOverlayView;
@property (nonatomic, readonly) BOOL hasLayersInBackground;
@property (nonatomic, assign) id<MysticLayerViewAbstract> layerUsingMenu, layerPastedFromClipboard;
@property (nonatomic, retain) id<MysticLayerViewAbstract>layerInClipboard;
@property (nonatomic, retain) NSMutableArray *stack;
@property (nonatomic, readonly) MysticOverlaysView *overlaysView;
@property (nonatomic, readonly) CGFrameBounds newOverlayFrame;
@property (nonatomic, readonly) CGFloat currentScale, contentScale;
@property (nonatomic, readonly) int selectedCount, count, unselectedCount;

@property (nonatomic, assign) BOOL shouldShowGridOnOpen, shouldAddNewLayer, gridViewIsAnimating, allowGridViewToHide, allowGridViewToShow, enabled, isMenuVisible;
@property (nonatomic, readonly) BOOL hasLayers, isGridHidden, hasSelectedAll, hasSelectedNone, hasSelectedLayer, hasSelectedLayers;
@property (nonatomic, assign) CGRect originalFrame, maxLayerBounds;
@property (nonatomic, readonly) NSArray *overlays, *selectedLayers, *layers;


+ (Class) optionClass;
+ (Class) layerViewClass;
+ (CGRect) maxLayerBounds;
- (id) initWithFrame:(CGRect)frame delegate:(id)delegate;
- (void) destroy;

- (void) disableOverlays;
- (void) enableOverlays;
- (PackPotionOptionView *) confirmOverlays;
- (PackPotionOptionView *) confirmOverlaysComplete:(MysticBlockObject)finished;

- (PackPotionOptionView *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
- (BOOL) delegate:(SEL)action object:(id)obj;
- (BOOL) delegate:(SEL)action perform:(BOOL)perform;
- (BOOL) delegate:(SEL)action object:(id)obj perform:(BOOL)perform;

- (NSArray *) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeOverlays:(NSArray *)exceptions;
- (void) removeOverlay:(id <MysticLayerViewAbstract>)layerViewOrViews;

- (void) removeOverlays;
- (void) addOverlay:(UIView *)overlay;
- (MysticLayerView *) addNewOverlay:(BOOL)copyLastOverlay;
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option;
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option;
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option animated:(BOOL)animated offset:(CGPoint)ossetPoint;

- (CGPoint) offsetPointForLayer:(id)layerOrLayers;
- (NSArray *) selectLayers:(NSArray *)layers;
- (CGPoint) layer:(MysticLayerBaseView *)layer centerWithOffset:(CGPoint)offsetPoint;
- (void) deselectLayersExcept:(MysticLayerView *)except;
- (void) changedLayer:(MysticLayerView *)sticker;
- (id) addNewOverlay;
- (void) activateLayer:(MysticLayerView *)labelView;
- (id) lastOverlay;
- (id) lastOverlay:(BOOL)make;
- (id) lastOverlayWithOption:(PackPotionOptionView *)option;
- (void) showGrid:(id)sender;
- (void) showGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
- (void) hideGrid:(id)sender;
- (void) hideGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
- (void) toggleGrid:(id)sender;
- (void) toggleGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
- (id) makeOverlay:(PackPotionOptionView *)option;
- (void) cancelOverlays:(MysticBlockObject)finished;
- (id) makeOverlay:(PackPotionOptionView *)option frame:(CGRect)newFrame context:(MysticDrawingContext **)_context;
- (void) activateLayer:(MysticLayerView *)layerView notify:(BOOL)shouldNotify;
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame;
- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
- (UIImage *)renderedImageWithSize:(CGSize)renderSize;
- (void) ignoreOverlays:(BOOL)ignore;
- (void) removeLayer:(id)layerOrLayers;
- (void) replaceLayer:(id)layer withLayer:(id)newLayer;

- (void) removeLayers:(id)overlays;
- (void) addLayer:(id)overlay;
- (id) cloneLayer:(id)layer;
- (id) disposableLayer:(id <MysticLayerViewAbstract>)layer;

- (NSArray *) selectAll;
- (NSArray *) selectAll:(NSArray *)except;
- (NSArray *) selectedLayers:(NSArray *)except;
- (void) deselectAll;
- (BOOL) isLayerKeyObject:(id)layer;
- (void) moveLayers:(NSArray *)layerViews distance:(CGPoint)diffPoint;
- (void) finishedMovingLayers:(NSArray *)layerViews;
- (id) addNewOverlayAndMakeKeyObject:(BOOL)copyLastOverlay;

- (void) enableGestures:(BOOL)enabled;
- (void) disableGestures;
- (void) enableGestures;

#pragma mark - menu buttons
- (void) copyMenuTouched:(id)sender;
- (void) moveUpMenuTouched:(id)sender;
- (void) moveDownMenuTouched:(id)sender;
- (void) gridMenuTouched:(id)sender;
- (void) removeMenuTouched:(id)sender;
- (void) undoMenuTouched:(id)sender;
- (void) selectAllMenuTouched:(id)sender;
- (void) deselectMenuTouched:(id)sender;
#pragma mark - Copy & Paste
- (void) copyLayer:(id <MysticLayerViewAbstract>)layerView;
- (void) paste:(id)sender;
- (void) pasteLayer:(id <MysticLayerViewAbstract>)layerView;
- (void) cutLayer:(id <MysticLayerViewAbstract>)layerView;


#pragma mark - Stacking
- (void) exchangeLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView;
- (void) exchangeLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView save:(BOOL)saveStack restack:(BOOL)restack;

- (void) replaceLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView;

- (void) replaceLayerInStack:(id <MysticLayerViewAbstract>)layerView withLayer:(id <MysticLayerViewAbstract>)newLayerView save:(BOOL)saveStack restack:(BOOL)restack;
- (void) moveLayersOutOfBackground;
- (void) moveLayersToBackgroundExcept:(NSArray *)exceptions;

- (void) moveLayerUp:(id <MysticLayerViewAbstract>)layerView;
- (void) moveLayerUp:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
- (void) moveLayerDown:(id <MysticLayerViewAbstract>)layerView;
- (void) moveLayerDown:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
- (void) moveLayerToTop:(id <MysticLayerViewAbstract>)layerView;
- (void) moveLayerToTop:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
- (void) moveLayerToBottom:(id <MysticLayerViewAbstract>)layerView;
- (id) moveLayerToBottom:(id <MysticLayerViewAbstract>)layerView save:(BOOL)saveStack;
- (void) moveLayerToStackPosition:(id <MysticLayerViewAbstract>)layerView position:(NSInteger)stackIndex save:(BOOL)saveStack;
- (void) moveLayerToStackPosition:(id <MysticLayerViewAbstract>)layerView position:(NSInteger)stackIndex save:(BOOL)saveStack restack:(BOOL)restack;
- (void) exchangeLayerAtStackPosition:(NSInteger)lsIndex withLayerAtPosition:(NSInteger)nsIndex save:(BOOL)saveStack restack:(BOOL)restack;
- (void) exchangeLayerAtStackPosition:(NSInteger)lsIndex withLayerAtPosition:(NSInteger)nsIndex;

- (void) restack;
- (void) restack:(NSArray *)stack;
- (id) hasLayerAtCenterPoint:(CGPoint)p;

- (void) printLayersStack;

- (void) tapped:(UITapGestureRecognizer *)recognizer;
- (void) longPress:(UILongPressGestureRecognizer *) gesture;
- (void) longPress:(UILongPressGestureRecognizer *) gesture layer:(id <MysticLayerViewAbstract>)layerView;

@end





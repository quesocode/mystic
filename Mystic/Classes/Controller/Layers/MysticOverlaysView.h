//
//  MysticOverlaysView.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticView.h"

@protocol MysticOverlaysViewDelegate;

@class MysticLayerView, PackPotionOptionView, MysticResizeableLayersViewController;

@interface MysticOverlaysView : MysticView
@property (nonatomic, assign) NSInteger nextLayerIndex;

@property (nonatomic, assign) MysticResizeableLayersViewController *controller;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id selectedLayer, keyObjectLayer;
@property (nonatomic, readonly) id newestOverlay;
@property (nonatomic, assign) CGRect originalFrame, maxLayerBounds;
@property (nonatomic, readonly) UIEdgeInsets maxLayerInsets;
@property (nonatomic, assign) BOOL shouldShowGridOnOpen, shouldAddNewLayer, gridViewIsAnimating, allowGridViewToHide, allowGridViewToShow;
@property (nonatomic, readonly) BOOL hasSelectedAll, hasSelectedNone, hasSelectedLayer, hasSelectedLayers;
@property (nonatomic, readonly) NSArray *overlays, *selectedLayers, *layers;
@property (nonatomic, readonly) int selectedCount, count, unselectedCount;
@property (nonatomic, readonly) CGFloat contentScale;
@property (nonatomic, readonly) UIColor *lastLayerBackgroundColor;
@property (nonatomic, readonly) CGFrameBounds newOverlayFrame;
- (void) disableOverlays;
- (void) enableOverlays;
- (PackPotionOptionView *) confirmOverlays;
- (PackPotionOptionView *) confirmOverlaysComplete:(MysticBlockObject)finished;

- (PackPotionOptionView *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeOverlays:(NSArray *)exceptions;
- (void) removeOverlays;
- (void) addOverlay:(UIView *)overlay;
- (id) addNewOverlay:(BOOL)copyLastOverlay;

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
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option;

- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
- (UIImage *)renderedImageWithSize:(CGSize)renderSize;

- (void) removeLayer:(id)overlay;
- (void) removeLayers:(id)overlays;
- (void) addLayer:(id)overlay;
- (id) cloneLayer:(id)layer;
- (NSArray *) selectAll;
- (NSArray *) selectAll:(NSArray *)except;
- (NSArray *) selectedLayers:(NSArray *)except;
- (void) deselectAll;
- (BOOL) isLayerKeyObject:(id)layer;

@end




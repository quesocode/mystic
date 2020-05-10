//
//  MysticLayersView.h
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticResizeableLayer.h"
#import "MysticGridView.h"
#import "MysticConstants.h"
#import "MysticLayerViewAbstract.h"

@class PackPotionOptionView;

@interface MysticLayersView  : UIView <MysticLayerViewDelegate>

@property (nonatomic, assign) id <MysticLayerViewDelegate, MysticLayersViewDelegate> delegate;
@property (nonatomic, assign) id selectedLayer;
@property (nonatomic, assign) id lastSelected;

@property (nonatomic, readonly) id newestOverlay;
@property (nonatomic, retain) MysticGridView *gridView;
@property (nonatomic, assign) BOOL shouldShowGridOnOpen, shouldAddNewOverlay, gridViewIsAnimating, allowGridViewToHide, allowGridViewToShow;
@property (nonatomic, readonly) BOOL hasLayers, isGridHidden;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, readonly) Class optionClass;
@property (nonatomic, readonly) Class layerClass;
@property (nonatomic, readonly) MysticObjectType objectType;
@property (nonatomic, readonly) CGFloat currentScale, contentScale;

- (void) disableOverlays;
- (void) enableOverlays;
- (PackPotionOption *) confirmOverlays;
- (PackPotionOption *) confirmOverlaysComplete:(MysticBlockObject)finished;

- (PackPotionOption *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;

- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeOverlays:(NSArray *)exceptions;
- (void) removeOverlays;
- (NSArray *) overlays;
- (void) addOverlay:(UIView *)overlay;
- (void) deselectLayersExcept:(MysticResizeableLayer *)except;
- (void) changedLayer:(MysticResizeableLayer *)sticker;
- (id) addNewOverlay;
- (id) addNewOverlay:(PackPotionOption *)newOption;
- (id) addNewOverlay:(PackPotionOption *)newOption frame:(CGRect)frame;

- (void) activateLayer:(MysticResizeableLayer *)labelView;
- (void) activateLayer:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
- (void) deactivateLayer:(MysticResizeableLayer *)layerView;
- (void) deactivateLayer:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
- (void) enableOverlays:(BOOL)activateLastSelected;
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;

- (MysticResizeableLayer *) lastOverlay;
- (MysticResizeableLayer *) lastOverlay:(BOOL)make;
- (void) showGrid:(id)sender;
- (void) showGrid:(id)sender animated:(BOOL)animated;
- (void) hideGrid:(id)sender;
- (void) hideGrid:(id)sender animated:(BOOL)animated;
- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
- (UIImage *)renderedImageWithSize:(CGSize)renderSize;
- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
- (void) toggleGrid:(id)sender;
- (void) toggleGrid:(id)sender animated:(BOOL)animated;

@end



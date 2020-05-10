//
//  MysticResizeableLayersView.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticOverlaysView.h"
#import "MysticResizeableLayersViewController.h"
#import "MysticLayerBaseView.h"

@implementation MysticOverlaysView

@synthesize controller=_controller;

- (void) dealloc;
{
    _controller = nil;
    
    [super dealloc];
    
}


- (void) commonInit;
{
    [super commonInit];
    self.clipsToBounds = YES;
    self.autoresizesSubviews = NO;
    self.userInteractionEnabled = NO;
    self.opaque = NO;
}
- (CGFrameBounds) newOverlayFrame;
{
    return self.controller.newOverlayFrame;
}

- (BOOL) shouldAddNewLayer {                        return self.controller.shouldAddNewLayer; }
- (BOOL) shouldShowGridOnOpen {                     return self.controller.shouldShowGridOnOpen; }
- (BOOL) gridViewIsAnimating {                      return self.controller.gridViewIsAnimating; }
- (BOOL) allowGridViewToHide {                      return self.controller.allowGridViewToHide; }
- (BOOL) allowGridViewToShow {                      return self.controller.allowGridViewToShow; }
- (void) setAllowGridViewToShow:(BOOL)value {       self.controller.allowGridViewToShow = value; }
- (void) setShouldShowGridOnOpen:(BOOL)value {      self.controller.shouldShowGridOnOpen = value; }
- (void) setShouldAddNewLayer:(BOOL)value {         self.controller.shouldAddNewLayer = value; }
- (void) setGridViewIsAnimating:(BOOL)value {       self.controller.gridViewIsAnimating = value; }
- (void) setAllowGridViewToHide:(BOOL)value {       self.controller.allowGridViewToHide = value; }
- (id) delegate; {                                  return self.controller ? self.controller.delegate : nil; }
- (void) setDelegate:(id)delegate; {                [self.controller setDelegate:delegate]; }
- (CGRect) originalFrame; {                         return self.controller.originalFrame; }
- (void) setOriginalFrame:(CGRect)frame; {          [self.controller setOriginalFrame:frame]; }
- (void) setSelectedLayer:(id)selectedLayer; {      [self.controller setSelectedLayer:selectedLayer]; }

- (UIColor *) lastLayerBackgroundColor;
{
    UIColor *c = self.layers.count ? [(UIView *)self.layers.lastObject backgroundColor] : self.backgroundColor;
    if(!c && self.layers.count)
    {
        MysticLayerBaseView *layer = self.layers.lastObject;
        c = [layer.color colorWithAlphaComponent:0];
    }
    return c;
}
- (id) selectedLayer;
{
    return self.controller.selectedLayer;
}
- (void) setCenter:(CGPoint)center;
{
    
    [super setCenter:center];
    
}
- (void) setTransform:(CGAffineTransform)transform;
{
    
    [super setTransform:transform];
}
- (id) newestOverlay;
{
    return self.controller.newestOverlay;
}

- (void) disableOverlays;
{
    [self.controller disableOverlays];
}
- (void) enableOverlays;
{
    [self.controller enableOverlays];
}

- (PackPotionOptionView *) confirmOverlays;
{
    return [self.controller confirmOverlays];
}
- (PackPotionOptionView *) confirmOverlaysComplete:(MysticBlockObject)finished;
{
    return [self.controller confirmOverlaysComplete:finished];
}
- (PackPotionOptionView *) confirmOverlays:(PackPotionOptionView *)newOption complete:(MysticBlockObject)complete;
{
   return  [self.controller confirmOverlays:newOption complete:complete];
}

- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
{
    [self.controller removeSubviews:parentView except:exceptions];
}
- (void) removeOverlays:(NSArray *)exceptions;
{
    [self.controller removeOverlays:exceptions];
}
- (void) removeOverlays;
{
    [self.controller removeOverlays];
}
- (NSArray *) layers;
{
    return [self.controller layers];
}
- (NSArray *) overlays;
{
    return [self.controller overlays];
}
- (NSInteger) nextLayerIndex;
{
    return self.controller.nextLayerIndex;
}
- (int) unselectedCount;
{
    return (int)self.controller.unselectedCount;
}
- (int) count;
{
    return (int)self.controller.count;
}
- (int) selectedCount;
{
    return (int)self.controller.selectedCount;
}
- (void) addOverlay:(UIView *)overlay;
{
    [self.controller addOverlay:overlay];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay;
{
    return [self.controller addNewOverlay:copyLastOverlay];
}
- (id) cloneLayer:(id)layer;
{
    return [self.controller cloneLayer:layer];

}
- (id) keyObjectLayer;
{
    return self.controller.keyObjectLayer;
}
- (void) deselectAll;
{
    [self.controller deselectAll];
}
- (BOOL) hasSelectedNone;
{
    return self.controller.hasSelectedNone;
}
- (BOOL) hasSelectedLayer;
{
    return self.controller.hasSelectedLayer;
}
- (BOOL) hasSelectedLayers;
{
    return self.controller.hasSelectedLayers;
}
- (BOOL) hasSelectedAll;
{
    return self.controller.hasSelectedAll;
}
- (BOOL) isLayerKeyObject:(id)layer;
{
    return [self.controller isLayerKeyObject:layer];
}

- (NSArray *) selectedLayers;
{
    return [self selectedLayers:nil];
}
- (NSArray *) selectedLayers:(NSArray *)except;
{
    return [self.controller selectedLayers:except];
}
- (NSArray *) selectAll;
{
    return [self selectAll:nil];
}
- (NSArray *) selectAll:(NSArray *)except;
{
    return [self.controller selectAll:except];
}
- (void) addLayer:(id)overlay;
{
    [self.controller addLayer:overlay];
}
- (void) removeLayer:(id)overlay;
{
    [self.controller removeLayer:overlay];
}
- (void) removeLayers:(id)overlays;
{
    [self.controller removeLayers:overlays];
}
- (void) deselectLayersExcept:(MysticLayerView *)except;
{
    [self.controller deselectLayersExcept:except];
}
- (void) changedLayer:(MysticLayerView *)sticker;
{
    [self.controller changedLayer:sticker];
}
- (CGFloat) contentScale;
{
    return self.controller.contentScale;
}
- (UIEdgeInsets) maxLayerInsets;
{
    return UIEdgeInsetsMakeFrom(MYSTIC_LAYERS_BOUNDS_INSET);
}
- (CGRect) maxLayerBounds;
{
    return CGRectInset(self.bounds, MYSTIC_LAYERS_BOUNDS_INSET, MYSTIC_LAYERS_BOUNDS_INSET);
}
- (id) addNewOverlay;
{
   return  [self.controller addNewOverlay];
}
- (void) activateLayer:(MysticLayerView *)labelView;
{
    [self.controller activateLayer:labelView];
}
- (id) lastOverlay;
{
    return [self.controller lastOverlay];
}
- (id) lastOverlay:(BOOL)make;
{
    return [self.controller lastOverlay:make];
}
- (id) lastOverlayWithOption:(PackPotionOptionView *)option;
{
    return [self.controller lastOverlayWithOption:option];
}
- (void) showGrid:(id)sender;
{
    [self.controller showGrid:sender];
}
- (void) showGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    [self.controller showGrid:sender animated:animated force:forceIt];
}
- (void) hideGrid:(id)sender;
{
    [self.controller hideGrid:sender];
}
- (void) hideGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    [self.controller hideGrid:sender animated:animated force:forceIt];
}
- (void) toggleGrid:(id)sender;
{
    [self.controller toggleGrid:sender];
}
- (void) toggleGrid:(id)sender animated:(BOOL)animated force:(BOOL)forceIt;
{
    [self.controller toggleGrid:sender animated:animated force:forceIt];
}
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
{
    [self.controller finishedImageCapture:renderSize scale:scale];
}
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;
{
    [self.controller prepareForImageCapture:renderSize scale:scale finished:finished];
}
- (id) makeOverlay:(PackPotionOptionView *)option;
{
    return [self.controller makeOverlay:option];
}
- (void) cancelOverlays:(MysticBlockObject)finished;
{
    [self.controller cancelOverlays:finished];
}
- (id) makeOverlay:(PackPotionOptionFont *)option frame:(CGRect)newFrame context:(MysticDrawingContext **)_context;
{
    return [self.controller makeOverlay:option frame:newFrame context:_context];
}
- (void) activateLayer:(MysticLayerView *)layerView notify:(BOOL)shouldNotify;
{
    [self.controller activateLayer:layerView notify:shouldNotify];
}
- (id) duplicateLayer:(id <MysticLayerViewAbstract>)layer option:(PackPotionOptionView *)option;
{
    return [self.controller duplicateLayer:layer option:option];
}
- (id) addNewOverlay:(BOOL)copyLastOverlay option:(PackPotionOptionView *)option frame:(CGRect)newFrame;
{
    return [self.controller addNewOverlay:copyLastOverlay option:option frame:newFrame];
}
- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
{
    return [self.controller imageByRenderingView:img size:renderSize scale:scale];
}
- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
{
    return [self.controller renderedImageWithBounds:bounds];
}
- (UIImage *)renderedImageWithSize:(CGSize)renderSize;
{
    return [self.controller renderedImageWithSize:renderSize];
}
@end

//
//  MysticLabelsView.h
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticResizeableLabel.h"
#import "MysticGridView.h"
#import "MysticConstants.h"
#import "MysticLayerViewAbstract.h"



@interface MysticLabelsView  : UIView <MysticLayerViewDelegate>

@property (nonatomic, assign) id <MysticLayerViewDelegate, MysticLayersViewDelegate> delegate;
@property (nonatomic, assign) MysticResizeableLabel *selectedLayer;
@property (nonatomic, readonly) MysticResizeableLabel *newestOverlay;
@property (nonatomic, retain) MysticGridView *gridView;
@property (nonatomic, readonly) CGFloat currentScale, contentScale;

@property (nonatomic, assign) BOOL shouldShowGridOnOpen, shouldAddNewTextOverlay, gridViewIsAnimating, allowGridViewToHide, allowGridViewToShow;
@property (nonatomic, readonly) BOOL hasLayers, isGridHidden;
@property (nonatomic, assign) CGRect originalFrame;
- (void) disableOverlays;
- (void) enableOverlays;
- (PackPotionOptionFontStyle *) confirmOverlays;
- (PackPotionOptionFontStyle *) confirmOverlaysComplete:(MysticBlockObject)finished;

- (PackPotionOptionFontStyle *) confirmOverlays:(PackPotionOptionFontStyle *)newOption complete:(MysticBlockObject)complete;

- (void) removeSubviews:(UIView *)parentView except:(NSArray *)exceptions;
- (void) removeOverlays:(NSArray *)exceptions;
- (void) removeOverlays;
- (NSArray *) overlays;
- (void) addOverlay:(UIView *)overlay;
- (MysticResizeableLabel *) addNewOverlay:(BOOL)copyLastOverlay;

- (void) deselectLayersExcept:(MysticResizeableLabel *)except;
- (void) changedLayer:(MysticResizeableLabel *)sticker;
- (MysticResizeableLabel *) addNewOverlay;
- (void) activateLayer:(MysticResizeableLabel *)labelView;
- (MysticResizeableLabel *) lastOverlay;
- (MysticResizeableLabel *) lastOverlay:(BOOL)make;
- (void) showGrid:(id)sender;
- (void) showGrid:(id)sender animated:(BOOL)animated;
- (void) hideGrid:(id)sender;
- (void) hideGrid:(id)sender animated:(BOOL)animated;
//- (UIImage *)imageByRenderingView:(UIImage *)img size:(CGSize)renderSize scale:(CGFloat)scale;
//- (UIImage *)renderedImageWithSize:(CGSize)renderSize;
//- (UIImage *)renderedImageWithBounds:(CGSize)bounds;
- (void) toggleGrid:(id)sender;
- (void) toggleGrid:(id)sender animated:(BOOL)animated;
- (MysticResizeableLabel *) labelWithText:(NSString *)labelText;
- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;

@end


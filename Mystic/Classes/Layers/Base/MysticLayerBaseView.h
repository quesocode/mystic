//
//  MysticLayerBaseView.h
//  Mystic
//
//  Created by Me on 12/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticLayerViewAbstract.h"
#import "MysticOverlaysView.h"
#import "MysticLayerContentView.h"
#import "MysticResizeableLayerBorderView.h"
#import "MysticChoice.h"
#import "MysticTransView.h"

@class MysticDrawLayerView;

@interface MysticLayerBaseView : UIView <MysticLayerViewAbstract>
{
    CGFloat _lastAngle, _ratio, _contentViewRatio, _prevDistFromCenter;
    CGPoint _centerPoint, _touchStart, _prevResizePoint, _prevPointFromCenter, _prevResizeSupPoint;
    UITextView *_activeTarget, *_textView;
    CGRect _startBounds, _frameValue, _contentFrame;
    MysticDrawingContext *_drawContext;
    BOOL _track;
    BOOL _shouldRedraw;
    id _content;
    MysticDrawLayerView *_drawView;
    MysticTransView *_transView;
}
@property (nonatomic, assign) MysticTransView *transView;
@property (nonatomic, assign) CGFloat deltaAngle;
@property (nonatomic, assign) MysticChoice *choice;
@property (nonatomic, readonly) BOOL isRasterized;
@property (nonatomic, assign) CGRect frameValue, contentFrame, maxBounds, boundingRect;
@property (nonatomic, assign) CGScale contentScale, contentViewScale;
@property (nonatomic, assign) CGSize controlSize, targetSize;
@property (nonatomic, assign) BOOL selected, enabled, editable, rotationSnapping, preventsPositionOutsideSuperview, preventsResizing, preventsDeleting, preventsCustomButton, isKeyObject, scalesUpContent, usesBorderControl, preventsLayoutWhileResizing, ignoreSingleTap, wasSelected, wasMoving, hasHiddenControls, canHold, shouldRelayout, adjustsAspectRatioOnResize, shouldFactorOnResize, hidden, isDisposable, isInBackground, previouslyEnabled, showDropShadowWhenSelected, hasChangedShadow, showContentDropShadowWhenSelected, shouldRedraw, userResized;
@property (nonatomic, assign) UIControlState state;
@property (nonatomic, assign) MysticIconType customControlIconType;
@property (nonatomic, assign) MysticPosition alignPosition;

@property (nonatomic, assign) int index;
@property (nonatomic, assign) id <MysticLayerViewDelegate> delegate;
@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, retain) MysticLayerContentView *contentView;
@property (nonatomic, retain) MysticDrawingContext *drawContext;
@property (nonatomic, retain) MysticResizeableLayerBorderView *borderView;
@property (nonatomic, retain) NSMutableDictionary *contentInfo;
@property (nonatomic, assign) MysticLayerEffect effect;
@property (nonatomic, retain) UIColor *color, *borderColor;
@property (nonatomic, assign) MysticPosition rotatePosition, handles;
@property (nonatomic, retain) id option, content;
@property (nonatomic, assign) MysticOverlaysView *layersView;
@property (nonatomic, assign) CGFloat minimumHeight, minimumWidth, rotation, scale, borderWidth, ratio, contentViewRescale, resizeScaleFactor, minimumRotationChange, previousAlpha, minWidthNoScale, minHeightNoScale;

@property (nonatomic, copy) MysticBlockLayerView selectBlock, editingBlock, editedBlock, movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock;
@property (strong, nonatomic) MysticButton *resizingControl, *deleteControl, *customControl;
@property (nonatomic, assign) UIEdgeInsets borderInset, contentInset, globalInset, controlInset, addedInsets;
@property (nonatomic, readonly) UIEdgeInsets layerInsets, totalContentInsets;
@property (nonatomic, retain) UIImageView *rasterImageView;
@property (nonatomic, readonly) CGSize rasterSize;
@property (nonatomic, assign) MysticDrawLayerView *drawView;
@property (nonatomic, assign) MysticPosition position;
@property (nonatomic, assign) MysticObjectType type;

- (void) commonInit;
- (id)   initWithFrame:(CGRect)frame scale:(CGFloat)scale;
- (id) initWithFrame:(CGRect)frame contentFrame:(CGRect)contentFrame scale:(CGFloat)scale context:(MysticDrawingContext *)context;
- (void) redraw:(BOOL)layout;
- (UIEdgeInsets) insetsForControl:(MysticLayerControl)controlType;
- (void) layoutControls:(MysticLayerControl)controlTypes;
- (void) hideControls:(BOOL)animated;
- (void) showControls:(BOOL)animated;
- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;
- (void) setNewBounds:(CGRect)bounds;
- (void) update;
- (void) setKeyObject;
- (void) loseKeyObject;
- (void) rasterize;
- (void) rasterize:(CGFloat)scale;
- (UIImage *) rasterImage:(CGFloat)scale;
- (void) unRasterize;
- (void) reset;
- (void) transformSize:(CGFloat)amount;
- (void) changeRotation:(CGFloat)change;
- (void) doubleTapped;
- (void) setEnabledAndKeepSelection:(BOOL)enabled;
- (void) relayoutSubviews;
- (void) setContent:(id)content color:(UIColor *)color;
- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void) setButton:(MysticLayerControl)type image:(UIImage*)image;
- (void) endDraw:(CGRect)rect;
- (void) setContent:(id)content updateView:(id)theView;
- (void) setContentFrameAndLayout:(CGRect)contentFrame;
- (CGRect) contentFrameInset:(CGRect)frame;
- (void) animateBorderOut:(MysticBlockAnimationFinished)completion;
- (void) animateBorderIn:(MysticBlockAnimationFinished)completion;
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (BOOL) delegate:(SEL)action;
- (UIEdgeInsets) remainderContentInsetsFrom:(UIEdgeInsets)ins;
- (UIEdgeInsets) increaseContentInsets:(UIEdgeInsets)contentInsets;
- (CGRect) boundsForContentFrame:(CGRect)contentFrame;
- (UIEdgeInsets) resetContentInsets;


+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)context scale:(CGFloat)scale;
+ (CGRect) frameForContentBounds:(CGRect)contentBounds scale:(CGFloat)scale;
+ (CGPoint) originForContentFrame:(CGRect)contentFrame scale:(CGFloat)_scale;
+ (UIEdgeInsets) contentInsetsForScale:(CGFloat)_scale;
- (CGRect) frameForControl:(MysticLayerControl)controlType;
- (CGFrameBounds) contentSize:(MysticChoice *)choice adjust:(BOOL)adjust;
- (CGRect) boundsInset:(BOOL)useOriginal;

@end

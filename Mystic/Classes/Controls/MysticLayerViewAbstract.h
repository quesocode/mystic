//
//  MysticLayerViewAbstract.h
//  Mystic
//
//  Created by Me on 10/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "MysticConstants.h"

#ifndef Mystic_MysticLayerViewAbstract_h
#define Mystic_MysticLayerViewAbstract_h
@class MysticButton, PackPotionOptionView, PackPotionOption, MysticLabelsView, MysticLayerView, MysticOverlaysView, MysticResizeableLayerBorderView, MysticOverlaysView, MysticLayerContentView, MysticOverlaysView, MysticAttrString, MysticChoice;
@protocol MysticLayerViewDelegate;


@protocol MysticLayerViewAbstract <NSObject>


@optional
@property (nonatomic, assign) CGScale contentScale;
@property (nonatomic, assign) CGRect frame, bounds, frameValue;
@property (nonatomic, assign) CGSize controlSize, targetSize;
@property (nonatomic, assign) BOOL selected, enabled, editable, rotationSnapping, preventsPositionOutsideSuperview, preventsResizing, preventsDeleting, preventsCustomButton, focused, scalesUpContent, usesBorderControl, preventsLayoutWhileResizing, ignoreSingleTap, wasSelected, wasMoving, hasHiddenControls, canHold, adjustsAspectRatioOnResize, shouldRelayout, hidden, isDisposable,isInBackground, previouslyEnabled, userResized;
@property (nonatomic, assign) int index;
@property (nonatomic, readonly) BOOL isRasterized;
@property (nonatomic, assign) id <MysticLayerViewDelegate> delegate;
@property (nonatomic, assign) MysticOverlaysView *layersView;
@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) MysticIconType customControlIconType;
@property (nonatomic, retain) MysticLayerContentView *contentView;
@property (nonatomic, retain) MysticResizeableLayerBorderView *borderView;
@property (nonatomic, assign) MysticLayerEffect effect;
@property (nonatomic, retain) UIColor *color, *borderColor;
@property (nonatomic, assign) MysticPosition rotatePosition, handles, alignPosition;
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, retain) id option, content;
@property (nonatomic, readonly) CGSize rasterSize;
@property (nonatomic, assign) CGFloat offsetHeight;
@property (nonatomic, assign) CGFloat minimumHeight, minimumWidth, rotation, alpha, scale, snapOffset, fontSize, borderWidth, resizeScaleFactor, minimumRotationChange, ratio, previousAlpha;
@property (nonatomic, copy) MysticBlockLayerView editingBlock;
@property (nonatomic, copy) MysticBlockLayerView editedBlock;
@property (nonatomic, copy) MysticBlockLayerView selectBlock;
@property (nonatomic, copy) MysticBlockLayerView movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock;
@property (strong, nonatomic) MysticButton *resizingControl, *deleteControl, *customControl;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) UIControlState state;
@property (nonatomic, retain) NSString *text, *subText;
@property (nonatomic, assign) CGFloat lineHeight, lineHeightScale, textSpacing, lineSpacing;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) UIEdgeInsets borderInset, contentInset, globalInset, controlInset;
@property (nonatomic, retain) MysticAttrString *attributedText;
@property (nonatomic, assign) CGRect boundingRect;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, retain) UIImageView *rasterImageView;

- (id) initWithFrame:(CGRect)frame scale:(CGFloat)scale;
- (void) hideControls:(BOOL)animated;
- (void) showControls:(BOOL)animated;
- (void) rasterize:(CGFloat)scale;
- (UIImage *) rasterImage;
- (UIImage *) rasterImage:(CGFloat)scale;
- (void) unRasterize;
- (void) rasterize;
- (void) setKeyObject;
- (void) loseKeyObject;
- (void) showControls:(MysticLayerControl)controlTypes animated:(BOOL)animated;
- (void) hideControls:(MysticLayerControl)controlTypes animated:(BOOL)animated;
- (void) layoutControls;
- (void) relayoutSubviews;
- (UIView *) superview;
- (void) commonInit;
- (void) loadView;
- (void) reset;
- (void) removeFromSuperview;
- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;
- (void) update;
- (void) transformSize:(CGFloat)percent;
- (void) changeRotation:(CGFloat)change;
- (void) doubleTapped;
- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void) setEnabledAndKeepSelection:(BOOL)enabled;
- (void) setButton:(MysticLayerControl)type image:(UIImage*)image;
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (BOOL) delegate:(SEL)action;
- (void) redraw;
- (void) redraw:(BOOL)layout;
- (BOOL) rebuildContext;
- (BOOL) replaceContent:(MysticChoice *)choice adjust:(BOOL)adjust scale:(CGSize)scale;
- (CGRect) frameForControl:(MysticLayerControl)controlType bounds:(CGRect)boundRect;

@required

- (void) finishedImageCapture:(CGSize)renderSize scale:(CGScale)scale;
- (void) prepareForImageCapture:(CGSize)renderSize scale:(CGScale)scale finished:(MysticBlock)finished;

@end

@protocol MysticLayerViewDelegate <NSObject>

@required

@optional

- (void)layerViewDidSelect:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidMove:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidBeginMoving:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidEndMoving:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidCancelMoving:(id <MysticLayerViewAbstract>)layerView;


- (void)layerViewDidResize:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidRotate:(id <MysticLayerViewAbstract>)layerView;

- (void)layerViewDidActivate:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidDeactivate:(id <MysticLayerViewAbstract>)layerView;

- (void)layerViewDidActivate:(id <MysticLayerViewAbstract>)layerView notify:(BOOL)shouldNotify;
- (void)layerViewDidDeactivate:(id <MysticLayerViewAbstract>)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidSelect:(id <MysticLayerViewAbstract>)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidDoubleTap:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidSingleTap:(id <MysticLayerViewAbstract>)layerView;

- (void)layerViewDidDoubleTap:(id <MysticLayerViewAbstract>)layerView notify:(BOOL)shouldNotify;
- (void)layerViewDidSingleTap:(id <MysticLayerViewAbstract>)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidBecomeKeyObject:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidLoseKeyObject:(id <MysticLayerViewAbstract>)layerView;

- (void)layerViewWillRemove:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidRemove:(id <MysticLayerViewAbstract>)layerView;



- (void)layerViewDidBeginEditing:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDebug:(NSString *)str;

- (void)layerViewDidEndEditing:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidClose:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidClose:(id <MysticLayerViewAbstract>)layerView  notify:(BOOL)shouldNotify;

- (void)layerViewWillLongPress:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewWillLongPress:(id <MysticLayerViewAbstract>)layerView gesture:(UILongPressGestureRecognizer *)gesture;
- (void)layerViewDidLongPress:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidLongPress:(id <MysticLayerViewAbstract>)layerView gesture:(UILongPressGestureRecognizer *)gesture;

- (void)layerViewDidCustomButtonTap:(id <MysticLayerViewAbstract>)layerView;

- (void)layerViewDidTransform:(id <MysticLayerViewAbstract>)layerView;
- (void)layerViewDidEndTransform:(id <MysticLayerViewAbstract>)layerView;

@end




@protocol MysticLayersViewDelegate <NSObject>


@required
@optional
- (void)layersViewDidTap:(id)layersView;
- (void)layersViewDidAddLayer:(id <MysticLayerViewAbstract>)layerView;
- (void)layersViewDidConfirm:(id)layersView;
- (void)layersViewDidShowGrid:(id)layersView;
- (void)layersViewDidHideGrid:(id)layersView;
- (void)layersViewWillShowGrid:(id)layersView;
- (void)layersViewWillHideGrid:(id)layersView;
- (void)layersViewDidDeselectAll:(id)layersView;
- (void)layersViewDidChangeGrid:(id)layersView isHidden:(BOOL)hidden;
- (void)layersViewDidLongPress:(id)layersView;
@end



@protocol MysticOverlaysViewDelegate <NSObject>
@required
@optional

- (void)overlaysViewDidTap:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewDidAddOverlay:(id <MysticLayerViewAbstract>)layerView;
- (void)overlaysViewDidConfirm:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewDidShowGrid:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewDidHideGrid:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewWillShowGrid:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewWillHideGrid:(MysticOverlaysView *)overlaysView;
- (void)overlaysViewDidDeselectAll:(MysticOverlaysView *)overlaysView;



@end

#endif

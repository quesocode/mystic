//
//  MysticMoveableView.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticView.h"
#import "Mystic.h"
#import "MysticResizeableLayer.h"
#import "MysticLayers.h"

@class MysticLayerView;



@protocol MysticLayerViewDelegate;


typedef void (^MysticResizeLayerViewBlock)(id <MysticLayerViewAbstract>layer);


@interface MysticMoveableView : MysticView <MysticLayerViewAbstract>

@property (nonatomic, assign) BOOL enabled, selected, editable, snapping, canResize, canRotate;
@property (nonatomic, assign) MysticSnapPosition snapPosition;
@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) CGFloat snapOffset;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) UIEdgeInsets borderInset, contentInset, globalInset;

@property (nonatomic, retain) MysticLayerContentView *contentView;
@property (retain, nonatomic) MysticButton *resizingControl;
@property (retain, nonatomic) MysticButton *deleteControl;
@property (retain, nonatomic) MysticButton *customControl;
@property (nonatomic, retain) MysticResizeableLayerBorderView *borderView;
@property (nonatomic) BOOL rotationSnapping, ignoreSingleTap;
@property (nonatomic) BOOL preventsLayoutWhileResizing;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic, assign) CGFloat minimumHeight, minimumWidth, rotation, scale;

@property (assign, nonatomic) id <MysticLayerViewDelegate> delegate;
@property (retain, nonatomic) PackPotionOption *option;
@property (nonatomic, assign) CGScale contentScale;
@property (nonatomic, assign) CGSize controlSize;

@property (nonatomic, copy) MysticResizeLayerViewBlock editingBlock;
@property (nonatomic, copy) MysticResizeLayerViewBlock editedBlock;
@property (nonatomic, copy) MysticResizeLayerViewBlock selectBlock;
@property (nonatomic, copy) MysticResizeLayerViewBlock movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock;


- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void) changeRotation:(CGFloat)change;
- (void) transformSize:(CGFloat)amount;

- (void) doubleTapped;
- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;


@end





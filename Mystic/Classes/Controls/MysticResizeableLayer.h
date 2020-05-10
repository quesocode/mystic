//
//  MysticResizeableLayer.h
//  Mystic
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayers.h"


@protocol MysticResizeableLayerDelegate;
@class MysticResizeableLayer, PackPotionOption;

typedef void (^MysticResizeLayerBlock)(MysticResizeableLayer *layer);


@interface MysticResizeableLayer : MysticView <MysticLayerViewAbstract>

@property (nonatomic, retain) id option;
@property (nonatomic) CGFloat rotation;
- (void) changeRotation:(CGFloat)change;
- (void) transformSize:(CGFloat)amount;


@property (retain, nonatomic) MysticButton *resizingControl;
@property (retain, nonatomic) MysticButton *deleteControl;
@property (retain, nonatomic) MysticButton *customControl;
@property (nonatomic, copy) MysticResizeLayerBlock editingBlock;
@property (nonatomic, copy) MysticResizeLayerBlock editedBlock;
@property (nonatomic, copy) MysticResizeLayerBlock selectBlock;
@property (nonatomic, copy) MysticResizeLayerBlock movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock;

@property (nonatomic, retain) MysticResizeableLayerBorderView *borderView;

@property (nonatomic, assign) BOOL selected, enabled;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL rotationSnapping;
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic, readonly) BOOL isDefault;
@property (nonatomic, assign) CGFloat minimumHeight, minimumWidth;


@property (nonatomic, assign) CGScale contentScale;
@property (nonatomic, assign) CGSize controlSize;
@property (nonatomic) CGRect normalFrame, contentNormalFrame;
@property (nonatomic, retain) MysticLayerContentView *contentView;

//@property (nonatomic, retain) UIView *inputAccessory;
@property (nonatomic, assign) id <MysticLayerViewDelegate> delegate;

- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustmomHandle;
- (void)hideCustomHandle;
- (void) resize;


- (void)setButton:(MysticLayerControl)type image:(UIImage*)image;
@end






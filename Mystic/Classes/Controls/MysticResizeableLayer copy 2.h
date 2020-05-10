//
//  MysticResizeableLayer.h
//  Mystic
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticResizeableLayerBorderView.h"

@protocol MysticResizeableLayerDelegate;
@class MysticResizeableLayer, PackPotionOption;

typedef void (^MysticResizeLayerBlock)(MysticResizeableLayer *layer);
typedef enum {
    MYSTICLAYER_BUTTON_NULL,
    MYSTICLAYER_BUTTON_DEL,
    MYSTICLAYER_BUTTON_RESIZE,
    MYSTICLAYER_BUTTON_CUSTOM,
    MYSTICLAYER_BUTTON_MAX
} MYSTICLAYER_BUTTONS;

@interface MysticResizeableLayer : UIView

@property (nonatomic, retain) id option;
@property (nonatomic) CGFloat rotation;
- (void) changeRotation:(CGFloat)change;
- (void) transformSize:(CGFloat)amount;



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
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

@property (nonatomic, assign) CGFloat contentScale;
@property (nonatomic, assign) CGSize controlSize;
@property (nonatomic) CGRect normalFrame, contentNormalFrame;
@property (nonatomic, assign) UIView *contentView;

//@property (nonatomic, retain) UIView *inputAccessory;
@property (strong, nonatomic) id <MysticResizeableLayerDelegate> delegate;

- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustmomHandle;
- (void)hideCustomHandle;
- (void) resize;


- (void)setButton:(MYSTICLAYER_BUTTONS)type image:(UIImage*)image;
@end


@protocol MysticResizeableLayerDelegate <NSObject>
@required
@optional
- (void)layerViewDidActivate:(MysticResizeableLayer *)layerView;
- (void)layerViewDidDeactivate:(MysticResizeableLayer *)layerView;

- (void)layerViewDidActivate:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
- (void)layerViewDidDeactivate:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidSelect:(MysticResizeableLayer *)layerView;
- (void)layerViewDidSelect:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidDoubleTap:(MysticResizeableLayer *)layerView;
- (void)layerViewDidSingleTap:(MysticResizeableLayer *)layerView;

- (void)layerViewDidDoubleTap:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;
- (void)layerViewDidSingleTap:(MysticResizeableLayer *)layerView notify:(BOOL)shouldNotify;

- (void)layerViewDidResize:(MysticResizeableLayer *)layerView;

- (void)layerViewDidMove:(MysticResizeableLayer *)layerView;

- (void)layerViewDidBeginMoving:(MysticResizeableLayer *)layerView;
- (void)layerViewDidEndMoving:(MysticResizeableLayer *)layerView;
- (void)layerViewDidCancelMoving:(MysticResizeableLayer *)layerView;

- (void)layerViewDidBeginEditing:(MysticResizeableLayer *)layerView;
- (void) layerViewDebug:(NSString *)str;

- (void)layerViewDidEndEditing:(MysticResizeableLayer *)layerView;
- (void)layerViewDidClose:(MysticResizeableLayer *)layerView;
- (void)layerViewDidClose:(MysticResizeableLayer *)layerView  notify:(BOOL)shouldNotify;

#ifdef MYSTICLABEL_LONGPRESS
- (void)layerViewDidLongPressed:(MysticResizeableLayer *)layerView;
#endif
- (void)layerViewDidCustomButtonTap:(MysticResizeableLayer *)layerView;
@end




//
//  MysticResizeableLabelOld.h
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticCGLabel.h"
#import "MysticResizeableLayerBorderView.h"
#import "MysticLayers.h"
#import "MysticConstants.h"

@protocol MysticResizeableLabelDelegate;
@class MysticResizeableLabelOld, PackPotionOptionFont, MysticAttrString;


typedef void (^MysticResizeLabelBlock)(MysticResizeableLabelOld *label);





@interface MysticResizeableLabelOld : UIView <MysticLayerViewAbstract>
@property (nonatomic, assign) int index;
@property (nonatomic, retain) MysticCGLabel *label;
@property (nonatomic, assign) MysticLayerEffect effect;
@property (nonatomic, readonly) CGRect contentBounds, originalFrame;
@property (nonatomic, assign) CGRect actualFrame, outerFrame, contentFrame;
@property (nonatomic, assign) UIEdgeInsets borderInset, contentInset, globalInset;

@property (nonatomic, retain) UIColor *color;

@property (nonatomic, retain) PackPotionOptionFont *option;
@property (nonatomic, copy) MysticResizeLabelBlock editingBlock;
@property (nonatomic, copy) MysticResizeLabelBlock editedBlock;
@property (nonatomic, copy) MysticResizeLabelBlock selectBlock;
@property (nonatomic, copy) MysticResizeLabelBlock movedBlock, longPressBlock, singleTapBlock, doubleTapBlock, deleteBlock, customTapBlock, keyboardWillShowBlock, keyboardWillHideBlock;
@property (nonatomic, retain) MysticAttrString *attributedText;
@property (nonatomic, assign) MysticOverlaysView *layersView;
@property (nonatomic, retain) MysticLayerContentView *contentView;

@property (nonatomic, retain) NSString *defaultText;
@property (nonatomic, retain) MysticResizeableLayerBorderView *borderView;
@property (nonatomic, retain) NSString *text, *subText;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic) CGFloat minimumFontSize, fontSize, rotation, lineHeight, lineHeightScale, textSpacing, lineSpacing;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL selected, enabled, editable, hasHiddenControls, preventsLayoutWhileResizing;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL rotationSnapping;
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic, readonly) BOOL isDefault;
@property (nonatomic) CGFloat minimumWidth, minimumHeight;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGScale contentScale;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) CGSize controlSize;
@property (nonatomic) CGRect normalFrame, labelNormalFrame;
//@property (nonatomic, retain) UIView *inputAccessory;
@property (assign, nonatomic) id <MysticLayerViewDelegate> delegate;
@property (nonatomic, assign) MysticPosition rotatePosition, alignPosition;

@property (strong, nonatomic) MysticButton *resizingControl;
@property (strong, nonatomic) MysticButton *deleteControl;
@property (strong, nonatomic) MysticButton *customControl;
- (id)initWithFrame:(CGRect)frame scale:(CGFloat)scale;
- (id)initWithFrame:(CGRect)frame contentFrame:(CGRect)contentFrame scale:(CGFloat)scale;

- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void)hideDelHandle;
- (void)showDelHandle;
- (void) transformSize:(CGFloat)amount;
- (void) changeRotation:(CGFloat)change;
- (void) doubleTapped;

- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustmomHandle;
- (void)hideCustomHandle;
- (void)setButton:(MysticLayerControl)type image:(UIImage*)image;
- (void) setFontSize:(CGFloat)fontSize;
- (void) updateWithEffect:(MysticLayerEffect)effect;
- (void) hideControls:(BOOL)animated;
- (void) showControls:(BOOL)animated;

@end




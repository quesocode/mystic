//
//  MysticResizableLabel.h
//  Mystic
//
//  Created by Me on 3/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "FDLabelView.h"
#import "MysticLayerViewAbstract.h"

@class MysticResizeableLabel, PackPotionOptionFont;


@protocol MysticResizeableLabelDelegate;






@interface MysticResizeableLabel : FDLabelView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) PackPotionOptionFont *option;
@property (strong, nonatomic) id <MysticLayerViewDelegate> delegate;


- (void) setSelected:(BOOL)selected notify:(BOOL)shouldNotify;
- (void) changeRotation:(CGFloat)change;
- (void) transformSize:(CGFloat)amount;
- (void) update;
@end












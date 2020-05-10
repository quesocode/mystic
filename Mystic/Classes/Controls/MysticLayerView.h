//
//  MysticLayerView.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticMoveableView.h"
#import "PackPotionOptionView.h"
#import "MysticOverlaysView.h"




@protocol MysticLayerViewDelegate;




@interface MysticLayerView : MysticMoveableView <MysticLayerViewAbstract>

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL debug, hasChanges;
@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, retain) PackPotionOptionView *option;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, readonly) CGRect contentBounds, originalFrame;
@property (nonatomic, assign) MysticLayerEffect effect;
@property (nonatomic, readonly) MysticOverlaysView *overlaysView;
- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)otherLayerView;
- (void) update;
- (void) updateWithEffect:(MysticLayerEffect)effect;

@end


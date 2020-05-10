//
//  MysticGestureView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/26/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticCommon.h"

@class MysticController;

@interface MysticGestureView : UIView

@property (nonatomic, assign) MysticController *controller;
@property (nonatomic, assign) MysticObjectType previousGesutreState;
@property (nonatomic, assign) BOOL previousGestureDisabled;
@property (nonatomic, assign) MysticObjectType state;
- (void) setupGestures:(MysticObjectType)state disable:(BOOL)disableGestures;
- (void) enableGestures:(BOOL)enabled;
- (void) setupGestures:(MysticObjectType)state;
- (void) enableGestures;
- (void) disableGestures;
- (void) setupPreviousGestures;
- (void) updateFrame;

@end

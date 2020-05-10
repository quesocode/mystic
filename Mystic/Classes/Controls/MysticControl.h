//
//  MysticControl.h
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"

@interface MysticControl : UIControl

@property (nonatomic, assign) MysticToolType toolType;
@property (nonatomic, assign) BOOL cancelsEvents;
@property (nonatomic, assign) CGFloat value, incrementSize, maximumValue, minimumValue, defaultValue;


- (void) commonInit;
- (void) setEmpty;
- (void) resetValue;

@end

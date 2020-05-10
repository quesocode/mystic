//
//  MysticDrawView.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/27/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticChoice.h"

@class MysticLayerBaseView;

@interface MysticDrawView : UIView

@property (nonatomic, copy) MysticDrawBlock drawBlock;
@property (nonatomic, assign) CGRect renderRect;
@property (nonatomic, assign) MysticLayerBaseView *layerView;
@property (nonatomic, retain) MysticChoice *choice;
@property (nonatomic, assign) BOOL shouldDraw;

@end

//
//  MysticRotateScaleToolbar.h
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticMoveToolbar.h"

@interface MysticRotateScaleToolbar : MysticMoveToolbar

+ (NSArray *) defaultItemsWithDelegate:(id)delegate;
+ (MysticRotateScaleToolbar *) toolbarWithFrame:(CGRect)frame;


@end

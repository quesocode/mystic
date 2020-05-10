//
//  MysticBottomLipView.h
//  Mystic
//
//  Created by travis weerts on 6/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticBottomLipView : UIView

@property (nonatomic) BOOL showLip;
@property (nonatomic, assign) MysticBorderStyle borderStyle;

@property (nonatomic, assign) CGFloat rightOffset, leftOffset, radius, leftBgOffset, rightBgOffset;

@property (nonatomic, retain) UIColor *underneathColor, *leftBackgroundColor, *rightBackgroundColor;
- (void) reset;
- (void) clear;
@end

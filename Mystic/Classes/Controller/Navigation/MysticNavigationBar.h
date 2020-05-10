//
//  NavigationBar.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"



@interface MysticNavigationBar : UINavigationBar

@property (nonatomic, assign) NavigationBarBorderStyle borderStyle;
@property (nonatomic, assign) MysticColorType backgroundColorStyle, drawColorStyle;

@property (nonatomic, assign) BOOL customLayout, isShowing, isHiding;
@property (nonatomic, assign) CGFloat height;
- (void) commonInit;

@end

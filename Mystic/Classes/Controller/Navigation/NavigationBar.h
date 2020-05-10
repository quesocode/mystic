//
//  NavigationBar.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"



@interface NavigationBar : UINavigationBar

@property (nonatomic, assign) NavigationBarBorderStyle borderStyle;
@property (nonatomic, assign) MysticColorType backgroundColorStyle;
@property (nonatomic, assign) BOOL customLayout, isShowing, isHiding;

- (void) commonInit;

@end

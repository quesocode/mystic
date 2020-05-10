//
//  NavigationViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NavigationBar.h"
#import "MysticBasicNavigationController.h"

@class MysticToolbar;


@interface NavigationViewController : MysticBasicNavigationController;

@property (nonatomic, readonly) NavigationBar *navigationBar;

@end

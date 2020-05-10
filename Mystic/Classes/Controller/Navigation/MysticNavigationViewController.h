//
//  NavigationViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticNavigationBar.h"
#import "MysticBasicNavigationController.h"


@class MysticToolbar;


@interface MysticNavigationViewController : MysticBasicNavigationController
@property (nonatomic, readonly) MysticNavigationBar *navigationBar;
@property (nonatomic, assign) BOOL hidesToolbar;

+ (id) newNavigation;
+ (id) newNavigationWithController:(UIViewController *)viewController;

@end

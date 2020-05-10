//
//  MysticDrawerNavViewController.h
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NavigationViewController.h"

@interface MysticDrawerNavViewController : NavigationViewController
@property (nonatomic, assign) UIViewController *rootViewController;
+ (id) mainController;
+ (id) mainMenuController;
+ (id) mainLayersController;
+ (id) mainLayersController:(UIViewController *)currentLayersController;

- (UIViewController *) loadSection:(NSInteger)section;
- (UIViewController *) loadSection:(NSInteger)section animated:(BOOL)animated;


@end

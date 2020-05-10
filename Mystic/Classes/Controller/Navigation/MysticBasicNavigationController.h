//
//  MysticBasicNavigationController.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticNavigationBar.h"

@interface MysticBasicNavigationController : UINavigationController

@property (nonatomic, readonly) BOOL willNavigationBarBeVisible;

- (void) setup;

- (NSInteger) indexOfViewControllerWithClass:(Class)vcClass;
- (BOOL) containsViewControllerOfClass:(Class)vcClass;
- (id) viewControllerOfClass:(Class)vcClass;
- (void) hideNavigationBar:(BOOL)hide duration:(NSTimeInterval)duration complete:(MysticBlock)finished;
- (void) hideNavigationBar:(BOOL)hide duration:(NSTimeInterval)duration setHidden:(BOOL)si complete:(MysticBlock)finished;

@end

//
//  MysticTabBarProtocol.h
//  Mystic
//
//  Created by Travis on 10/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticConstants.h"

#ifndef Mystic_MysticTabBarProtocol_h
#define Mystic_MysticTabBarProtocol_h

@class MysticTabBar, MysticTabButton;

@protocol MysticTabBarDelegate <NSObject>

@required

- (void) tabBarDidScroll:(MysticTabBar *)tabBar;
- (void) setCurrentSetting:(MysticObjectType)setting;
- (void) mysticTabBar:(MysticTabBar *)tabBar didSelectItem:(MysticTabButton *)item info:(id)userInfo;

@optional

- (BOOL) mysticTabBar:(MysticTabBar *)tabBar isItemActive:(MysticTabButton *)item;

@end

#endif

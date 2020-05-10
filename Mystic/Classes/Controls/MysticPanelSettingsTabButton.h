//
//  MysticPanelSettingsTabButton.h
//  Mystic
//
//  Created by Me on 3/25/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPanelTabButton.h"
#import "MysticTabBadgeView.h"

@interface MysticPanelSettingsTabButton : MysticPanelTabButton


@property (nonatomic, retain) MysticTabBadgeView *badge;
@property (nonatomic, retain) UIView *activeView;

- (void) setActive:(BOOL)isActive animated:(BOOL)animated;

@end

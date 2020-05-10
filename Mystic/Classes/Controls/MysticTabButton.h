//
//  MysticTabButton.h
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "SubBarButton.h"
#import "MysticTabBadgeView.h"

@interface MysticTabButton : SubBarButton

@property (nonatomic, retain) MysticTabBadgeView *badge;


- (void) showBadge:(BOOL)animated;
- (void) hideBadge:(BOOL)animated;
- (void) setActive:(BOOL)isActive animated:(BOOL)animated;

@end



@interface MysticTabButtonBackgroundView : SubBarButtonBackgroundView


@end
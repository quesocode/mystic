//
//  MysticTabBadgeView.h
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticTabBadgeView : UILabel

@property (nonatomic, assign) BOOL useCheckmark;
@property (nonatomic, assign) NSInteger badgeCount;

- (void) setBadgeCount:(NSInteger)badgeCount animated:(BOOL)animated;

@end

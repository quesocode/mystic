//
//  MysticPanelSubView.h
//  Mystic
//
//  Created by Me on 2/10/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticSlider.h"
#import "MysticScrollView.h"
#import "MysticTabBar.h"

@interface MysticPanelSubView : MysticView
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) MysticTabBar * tabBar;
@property (nonatomic, assign) MysticScrollView * scrollView;
@property (nonatomic, assign) MysticSlider * slider;

- (id) initWithFrame:(CGRect)frame name:(NSString *)name;

@end

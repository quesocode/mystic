//
//  MysticPanelSubView.m
//  Mystic
//
//  Created by Me on 2/10/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPanelSubView.h"
@interface MysticPanelSubView ()
{
    
}
@end
@implementation MysticPanelSubView
- (void) dealloc;
{
    [_name release];
    if(_slider) _slider=nil;
    if(_tabBar) _tabBar=nil;
    if(_scrollView) _scrollView=nil;
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame name:(NSString *)name;
{
    self = [super initWithFrame:frame];
    if(self) self.name = name;
    return self;
}
- (MysticTabBar *) tabBar;
{
    if(_tabBar) return _tabBar;
    _tabBar= [self viewWithClass:[MysticTabBar class]];
    return _tabBar;
}
- (MysticScrollView *) scrollView;
{
    if(_scrollView) return _scrollView;
    _scrollView= [self viewWithClass:[MysticScrollView class]];
    return _scrollView;
}
- (MysticSlider *) slider;
{
    if(_slider) return _slider;
    _slider= [self viewWithClass:[MysticScrollView class]];
    return _slider;
}
@end

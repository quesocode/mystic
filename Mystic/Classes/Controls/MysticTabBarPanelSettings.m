//
//  MysticTabBarPanelSettings.m
//  Mystic
//
//  Created by Me on 3/24/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabBarPanelSettings.h"
#import "MysticPanelSettingsTabButton.h"


@implementation MysticTabBarPanelSettings

- (Class) tabButtonClass;
{
    return [MysticPanelSettingsTabButton class];
}

- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsZero;
    return UIEdgeInsetsMakeFrom(2);

    return UIEdgeInsetsMake(MYSTIC_UI_SUB_BTN_ICON_OFFSET_TOP, MYSTIC_UI_SUB_BTN_ICON_OFFSET_LEFT, MYSTIC_UI_SUB_BTN_ICON_OFFSET_BOTTOM, MYSTIC_UI_SUB_BTN_ICON_OFFSET_RIGHT);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.insets = UIEdgeInsetsMake(3, 0, 0, 0);
        self.tabLayoutStyle = MysticLayoutStyleFlexible;
        self.layoutOrigin = (CGPoint){7,0};
        self.buttonPadding = UIEdgeInsetsMake(0, 0, 0, 0);

//        self.debug = YES;

    }
    return self;
}
//- (BOOL) debug;
//{
//    return YES;
//}
- (void) loadView;
{
    
}
- (MysticScrollViewRevealStyle) revealStyle;
{
    return MysticScrollViewRevealStyleCenter;
}

- (void) updateDisplayForTab:(MysticTabButton *)tab animated:(BOOL)animated;
{

    if(!tab) return;
    
    BOOL activate = [self.tabBarDelegate mysticTabBar:self isItemActive:tab];
    if(tab.active != activate) [tab setActive:activate animated:animated];
}
- (void) setNeedsDisplay;
{
    [self setNeedsDisplayIgnore:nil animated:YES];
}
- (void) setNeedsDisplayIgnore:(id)ignoreTab animated:(BOOL)animated;
{
    
    BOOL tbr = self.tabBarDelegate && [self.tabBarDelegate respondsToSelector:@selector(mysticTabBar:isItemActive:)];
    if(tbr)
    {
        for (MysticTabButton *btn in self.tabs)
        {

            if(ignoreTab && [btn isEqual:ignoreTab])
            {

                continue;
            }
            BOOL activate = [self.tabBarDelegate mysticTabBar:self isItemActive:btn];
            
            
            
            [btn setActive:activate animated:animated];

        }
        [self setNeedsDisplay:animated ignore:YES];

    }
    else
    {
        [self setNeedsDisplay:animated];
    }
}



- (void) tabBarButtonTouched:(MysticPanelSettingsTabButton *)button;
{
    [super tabBarButtonTouched:button];
    [self setNeedsDisplayIgnore:button animated:YES];
}

@end

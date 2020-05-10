//
//  MysticTabBarPanel.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabBarPanel.h"
#import "MysticPanelTabButton.h"

@implementation MysticTabBarPanel

- (Class) tabButtonClass;
{
    return [MysticPanelTabButton class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tag = MysticViewTypeTabBarPanel;
        self.tabLayoutStyle = MysticLayoutStyleFlexible;
        self.insets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_TABBAR_INSET_TOP, MYSTIC_UI_PANEL_TABBAR_INSET_LEFT, MYSTIC_UI_PANEL_TABBAR_INSET_BOTTOM, MYSTIC_UI_PANEL_TABBAR_INSET_RIGHT);
        self.layoutOrigin = CGPointZero;

//        self.debug = YES;
    }
    return self;
}
- (void) loadView;
{
    
}
//- (BOOL) preventsScrollOnHide;
//{
//    return NO;
//}

- (BOOL) lookForActiveOptions; { return NO; }

- (BOOL) showTitles; { return YES; }
- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsMake(MYSTIC_UI_SUB_BTN_ICON_OFFSET_TOP, MYSTIC_UI_SUB_BTN_ICON_OFFSET_LEFT, MYSTIC_UI_SUB_BTN_ICON_OFFSET_BOTTOM, MYSTIC_UI_SUB_BTN_ICON_OFFSET_RIGHT);
}




@end

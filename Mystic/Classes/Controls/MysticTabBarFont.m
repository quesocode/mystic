//
//  MysticTabBarFont.m
//  Mystic
//
//  Created by Me on 12/1/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabBarFont.h"
#import "MysticTabBarFontButton.h"
#import "MysticController.h"

@implementation MysticTabBarFont

- (Class) tabButtonClass;
{
    return [MysticTabBarFontButton class];
}

- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsZero;
//    return UIEdgeInsetsMakeFrom(2);
//    
//    return UIEdgeInsetsMake(MYSTIC_UI_SUB_BTN_ICON_OFFSET_TOP, MYSTIC_UI_SUB_BTN_ICON_OFFSET_LEFT, MYSTIC_UI_SUB_BTN_ICON_OFFSET_BOTTOM, MYSTIC_UI_SUB_BTN_ICON_OFFSET_RIGHT);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.tag = MysticViewTypeTabBarFont;
        self.tabLayoutStyle = MysticLayoutStyleDefault;
        self.insets = UIEdgeInsetsMake(0, MYSTIC_UI_PANEL_TABBAR_FONT_INSET_LEFT, 0, MYSTIC_UI_PANEL_TABBAR_FONT_INSET_RIGHT);
        self.layoutOrigin = (CGPoint){0,0};
//        self.debug = YES;
        self.autoSelection = NO;
        
    }
    return self;
}
- (id) customizeTab:(MysticTabBarFontButton *)tab info:(NSDictionary *)info;
{
    if(info[@"border"] && [info[@"border"] integerValue] != MysticPositionUnknown)
    {
        MysticTabBarFontButtonBackgroundView *bg = (id)tab.bgView;
        bg.borderPosition = [info[@"border"] integerValue];
        bg.borderWidth = MYSTIC_UI_PANEL_BORDER;
        bg.borderInsets = UIEdgeInsetsMake(-MYSTIC_UI_PANEL_BORDER, 0, -MYSTIC_UI_PANEL_BORDER, 0);
        bg.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
        bg.showBorder = YES;
        
        if(bg.borderPosition == MysticPositionRight)
        {
            UIEdgeInsets i = tab.contentInsets;
            i.right = bg.borderWidth*2;
            tab.contentInsets = i;
        }
    }
    return tab;
}

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
    BOOL activate = (self.tabBarDelegate && [self.tabBarDelegate respondsToSelector:@selector(mysticTabBar:isItemActive:)]) ? [self.tabBarDelegate mysticTabBar:self isItemActive:tab] : NO;
    if(tab.active != activate) [tab setActive:activate animated:animated];
}
- (void) setNeedsDisplay;
{
    [self setNeedsDisplayIgnore:nil animated:YES];
}
- (void) setNeedsDisplayIgnore:(id)ignoreTab animated:(BOOL)animated;
{
    if(self.tabBarDelegate && [self.tabBarDelegate respondsToSelector:@selector(mysticTabBar:isItemActive:)])
    {
        for (MysticTabButton *btn in self.tabs)
        {
            if(ignoreTab && [btn isEqual:ignoreTab]) continue;
            [btn setActive:[self.tabBarDelegate mysticTabBar:self isItemActive:btn] animated:animated];
        }
        [self setNeedsDisplay:animated ignore:YES];
    }
    else
    {
        [self setNeedsDisplay:animated];
    }
}



- (void) tabBarButtonTouched:(MysticTabBarFontButton *)button;
{
    [super tabBarButtonTouched:button];
    [self setNeedsDisplayIgnore:button animated:YES];
}

- (void) setNeedsDisplay:(BOOL)animated ignore:(BOOL)ignore;
{
    if(ignore) return [super setNeedsDisplay];

    MysticController *controller = (id)self.tabBarDelegate;
    NSArray *selectedLayers = controller.labelsView.selectedLayers;
    BOOL hasNone = selectedLayers.count == 0;
    BOOL hasAll = controller.labelsView.hasSelectedAll;
    BOOL moveSelected = [self isTabOfTypeSelected:MysticSettingFontMove];
    moveSelected = NO;
    
    for (MysticTabButton *btn in self.tabs) {
        BOOL disable = NO;
        
        switch (btn.type) {
            case MysticSettingFontAdd:
            {
                disable = moveSelected;
                break;
            }
            case MysticSettingFontEdit:
            {
                disable = hasNone || selectedLayers.count > 1 || moveSelected;
                break;
            }
            case MysticSettingFontStyle:
            case MysticSettingFontDelete:
            {
                disable = hasNone || moveSelected;
                break;
            }
            case MysticSettingFontMove:
            {
                disable = hasNone;
                [btn showAsSelected:!disable && [self.tabBarDelegate mysticTabBar:self isItemActive:btn]];
                break;
            }
            case MysticSettingFontSelect:
            {
                disable = moveSelected;
                [btn showAsSelected:hasAll];
                break;
            }
            case MysticSettingFontClone:
            {
                disable = hasNone || moveSelected;
                break;
            }
            case MysticSettingFontColor:
            {
                disable = hasNone || moveSelected;
                break;
            }
             default:
            {
                break;
            }
        }
        btn.enabled = !disable;
    }
}

@end

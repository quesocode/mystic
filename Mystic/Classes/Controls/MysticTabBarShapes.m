//
//  MysticTabBarShapes.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticTabBarShapes.h"
#import "MysticTabBarShapeButton.h"
#import "MysticController.h"


@implementation MysticTabBarShapes


- (Class) tabButtonClass;
{
    return [MysticTabBarShapeButton class];
}

- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsZero;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.tag = MysticViewTypeTabBarShape;
        self.tabLayoutStyle = MysticLayoutStyleDefault;
        self.insets = UIEdgeInsetsMake(0, MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_LEFT, 0, MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_RIGHT);
        self.layoutOrigin = (CGPoint){0,0};
        self.autoSelection = NO;
        
    }
    return self;
}
- (id) customizeTab:(MysticTabBarShapeButton *)tab info:(NSDictionary *)info;
{
    if(info[@"border"] && [info[@"border"] integerValue] != MysticPositionUnknown)
    {
        MysticTabBarShapeButtonBackgroundView *bg = (id)tab.bgView;
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



- (void) tabBarButtonTouched:(MysticTabBarShapeButton *)button;
{
    [super tabBarButtonTouched:button];
    [self setNeedsDisplayIgnore:button animated:YES];
}


- (void) setNeedsDisplay:(BOOL)animated ignore:(BOOL)ignore;
{
    if(ignore) return [super setNeedsDisplay];
    
    MysticController *controller = (id)self.tabBarDelegate;
    NSArray *selectedLayers = controller.shapesController.selectedLayers;
    BOOL hasNone = selectedLayers.count == 0;
    BOOL hasAll = controller.shapesController.hasSelectedAll;
    BOOL moveSelected = [self isTabOfTypeSelected:MysticSettingShapeMove];
    moveSelected = NO;
    BOOL alignSelected = [self isTabOfTypeSelected:MysticSettingShapeAlign];
    for (MysticTabButton *btn in self.tabs) {
        BOOL disable = NO;
        
        switch (btn.type) {
            case MysticSettingShapeAdd:
            {
                disable = moveSelected || alignSelected;
                break;
            }
            case MysticSettingShapeAlign:
            {
                disable = hasNone || moveSelected;
                [btn showAsSelected:!disable && [self.tabBarDelegate mysticTabBar:self isItemActive:btn]];

                break;
            }
            case MysticSettingShapeEdit:
            case MysticSettingShapeColor:
            case MysticSettingShapeClone:
            case MysticSettingShapeStyle:
            case MysticSettingShapeDelete:
            {
                disable = hasNone || moveSelected || alignSelected;
                break;
            }
            case MysticSettingShapeMove:
            {
                disable = hasNone || alignSelected;
                [btn showAsSelected:!disable && [self.tabBarDelegate mysticTabBar:self isItemActive:btn]];
                break;
            }
            case MysticSettingShapeSelect:
            {
                disable = moveSelected || alignSelected;
                [btn showAsSelected:!disable && hasAll];
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


@implementation MysticTabBarShapesAlign


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _numberOfVisibleTabs = 6;
        self.tag = MysticViewTypeTabBarShapeAlign;
        self.tabLayoutStyle = MysticLayoutStyleFixed;
//        self.insets = UIEdgeInsetsMake(0, MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_LEFT, 0, MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_RIGHT);
//        self.layoutOrigin = (CGPoint){0,0};
//        self.autoSelection = NO;
        
    }
    return self;
}
- (BOOL) showTitles; { return NO; }

- (CGFloat) numberOfVisibleTabs;
{
    return 6;
}

@end
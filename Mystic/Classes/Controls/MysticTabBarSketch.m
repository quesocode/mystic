//
//  MysticTabBarSketch.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/29/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticTabBarSketch.h"
#import "MysticCommon.h"

@implementation MysticTabBarSketch

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
        
        self.tag = MysticViewTypeTabBarPanelSketch;
        self.tabLayoutStyle = MysticLayoutStyleFlexible;
        self.insets = UIEdgeInsetsMake(0, MYSTIC_UI_PANEL_TABBAR_FONT_INSET_LEFT, 0, MYSTIC_UI_PANEL_TABBAR_FONT_INSET_RIGHT);
        self.layoutOrigin = (CGPoint){0,0};
        //        self.debug = YES;
        self.autoSelection = NO;
        
    }
    return self;
}
- (id) customizeTab:(MysticTabButton *)tab info:(NSDictionary *)info;
{
    if(tab.type == MysticSettingSketchLayers)
    {
        NSUInteger index = 2;
        
        UILabel *layersLabel = [tab viewWithTag:1235345];
        if(!layersLabel)
        {
            layersLabel = [[[UILabel alloc] initWithFrame:CGRectXY(tab.bounds, 0, 1)] autorelease];
            layersLabel.tag =1235345;
            layersLabel.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.00];
            layersLabel.font = [MysticFont gothamBold:12];
            layersLabel.textAlignment = NSTextAlignmentCenter;
            layersLabel.backgroundColor = UIColor.clearColor;
            layersLabel.userInteractionEnabled = NO;
            [tab addSubview:layersLabel];
        }
        layersLabel.text = [NSString stringWithFormat:@"%d", (int)index];
    }
    return tab;
}
- (BOOL) showTitles; { return NO; }
@end

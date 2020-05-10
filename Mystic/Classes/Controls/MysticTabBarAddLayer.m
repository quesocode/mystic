//
//  MysticTabBarAddLayer.m
//  Mystic
//
//  Created by Me on 7/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabBarAddLayer.h"

@implementation MysticTabBarAddLayer

- (void) dealloc;
{
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showActiveTypes = YES;
        self.insets = UIEdgeInsetsMake(0, 0, 4, 4);
        self.buttonPadding = UIEdgeInsetsMake(0, 5, 0, 5);
        self.layoutOrigin = CGPointMake(0, 0);
//        self.layoutStyle = MysticLayoutStyleFlexible;
//        self.debug = YES;

    }
    return self;
}
- (CGFloat) numberOfVisibleTabs; { return 5.6; }
- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsMake(MYSTIC_UI_SUBBTN_ADD_OFFSET_TOP, MYSTIC_UI_SUBBTN_ADD_OFFSET_LEFT, MYSTIC_UI_SUBBTN_ADD_OFFSET_BOTTOM, MYSTIC_UI_SUBBTN_ADD_OFFSET_RIGHT);
}

- (void) loadView;
{
    
}

- (id) customizeTab:(MysticTabButton *)button info:(NSDictionary *)info;
{
//    button.backgroundColor = [UIColor hex:@"242422"];

    return button;
}


@end

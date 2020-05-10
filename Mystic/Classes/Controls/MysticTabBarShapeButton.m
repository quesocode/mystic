//
//  MysticTabBarShapeButton.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticTabBarShapeButton.h"

@implementation MysticTabBarShapeButton


+ (CGFloat) maxImageHeight;
{
    return 23.0f;
    
}
+ (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}
+ (UIFont *) labelFont;
{
    return [MysticUI gothamBold:MYSTIC_UI_TABBAR_TITLE_FONTSIZE];
}

- (Class) backgroundViewClass;
{
    return [MysticTabBarShapeButtonBackgroundView class];
}
- (BOOL) adjustsImageWhenHighlighted; { return NO; }

- (id)initWithFrame:(CGRect)frame showTitle:(BOOL)showTitle;
{
    self = [super initWithFrame:frame showTitle:showTitle];
    if (self) {
        
        self.contentMode = UIViewContentModeCenter;
        self.allowSelect = YES;
        
    }
    return self;
}
- (CGFloat) titleIconSpacing;
{
    return 6;
}

- (CGFloat) maxImageHeight;
{
    return [[self class] maxImageHeight];
}

- (void) setAlpha:(CGFloat)alpha;
{
    if([(MysticTabBarShapeButtonBackgroundView *)self.bgView showBorder])
    {
        self.imageView.alpha = alpha;
        self.titleLabel.alpha = alpha;
    }
    else
    {
        [super setAlpha:alpha];
    }
}


@end


@implementation MysticTabBarShapeButtonBackgroundView
@end
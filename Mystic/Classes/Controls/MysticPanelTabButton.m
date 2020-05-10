//
//  MysticPanelTabButton.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPanelTabButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation MysticPanelTabButton

+ (UIFont *) labelFont;
{
    return [MysticUI gothamBold:MYSTIC_UI_TABBAR_TITLE_FONTSIZE];
}

- (BOOL) adjustsImageWhenHighlighted; { return NO; }

- (Class) backgroundViewClass;
{
    return [MysticPanelTabButtonBackgroundView class];
}

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
+ (CGFloat) maxImageHeight;
{
    return 25.0f;

}
- (CGFloat) maxImageHeight;
{
    return [[self class] maxImageHeight];
}
+ (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsMake(7, 7, 7, 7);

}

- (UIEdgeInsets) contentInsets;
{
    return [[self class] contentInsets];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@interface MysticPanelTabButtonBackgroundView ()
{
    
}
@end

@implementation MysticPanelTabButtonBackgroundView

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.showDots = NO;
    }
    return self;
}


@end

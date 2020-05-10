//
//  MysticDrawerNavigationBar.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "NavigationBar.h"
#import "MysticDrawerNavigationBar.h"

@implementation MysticDrawerNavigationBar

+ (void) initialize;
{
    [[MysticDrawerNavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [MysticUI gothamLight:MYSTIC_UI_DRAWER_NAV_TEXTSIZE_SMALL], UITextAttributeFont,
                                                                    [UIColor color:MysticColorTypeDrawerNavBarText], UITextAttributeTextColor,
                                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                    [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                    nil]];
    
    [[MysticDrawerNavigationBar appearance] setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
    [[MysticDrawerNavigationBar appearance] setTintColor:[UIColor color:MysticColorTypeDrawerNavBar]];

}
- (void) commonInit;
{
    self.borderStyle = NavigationBarBorderStyleNone;
    self.backgroundColorStyle = MysticColorTypeDrawerNavBar;
//    self.customLayout = NO;

}

- (CGSize)sizeThatFits:(CGSize)size {
    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
    //    CGSize newSize = CGSizeMake([MysticUI size].width, 50);
    CGSize newSize = CGSizeMake(self.superview.frame.size.width, 50);
    
    return newSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Make items on navigation bar vertically centered.
    //    CGFloat offsetY = -1.0;
    int i = 0;
    for (UIView *subview in self.subviews) {
        i++;
        if (subview == [[self.topItem rightBarButtonItem] customView]) {
            
            CGRect newRightButtonRect = CGRectMake(self.bounds.size.width - subview.frame.size.width - MYSTIC_NAVIGATION_BTN_MARGIN,
                                                   (self.bounds.size.height - subview.frame.size.height) / 2,
                                                   subview.frame.size.width,
                                                   subview.frame.size.height);
            [subview setFrame:newRightButtonRect];
        } else if (subview == [[self.topItem leftBarButtonItem] customView]) {
            
            CGRect newLeftButtonRect = CGRectMake(MYSTIC_NAVIGATION_BTN_MARGIN,
                                                  (self.bounds.size.height - subview.bounds.size.height) / 2,
                                                  subview.frame.size.width,
                                                  subview.frame.size.height);
            [subview setFrame:newLeftButtonRect];
        }else if (subview == [self.topItem titleView]) {
            
//            CGRect newTitleViewRect = CGRectMake(subview.frame.origin.x,
//                                                 (self.bounds.size.height - subview.bounds.size.height) / 2,
//                                                 subview.frame.size.width,
//                                                 subview.frame.size.height);
//            [subview setFrame:newTitleViewRect];
        }
    }
    //
    //    UINavigationItem* item = [self topItem]; // (Current navigation item)
    //
    //    [item.titleView setCenter:CGPointMake(self.bounds.size.width / 2.0f, (self.bounds.size.height / 2.0f) + offsetY)];
    
    
}

@end

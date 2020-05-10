//
//  MysticCategoryButton.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticCategoryButton.h"
#import "MysticColor.h"

@implementation MysticCategoryButton

//- (UIColor *) titleColorForState:(UIControlState)state;
//{
//    switch (state) {
//
//        case UIControlStateHighlighted:
//        case UIControlStateSelected:
//            return [UIColor color:MysticColorTypeWhite];
//            
//        default:
//            break;
//    }
//    return [UIColor color:MysticColorTypeBottomBarBackground];
//
//}
+ (id) buttonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    return [super buttonWithTitle:[title uppercaseString] target:target sel:action];
}
+ (id) buttonWithTitle:(NSString *)title action:(MysticBlock)action;
{
    return [super buttonWithTitle:[title uppercaseString] action:action];
}
+ (id) buttonWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    return [super buttonWithTitle:[title uppercaseString] senderAction:action];
}
- (void) dealloc;
{
    [_pack release];
    [super dealloc];
}
- (CGFloat) padding;
{
    return 6;
}
- (void) commonInit;
{
    [super commonInit];
    [self.titleLabel setFont:[MysticFont font:MYSTIC_UI_CATEGORY_FONTSIZE]];
    [self setTitleColor:[UIColor hex:@"6B5F57"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateSelected];
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state;
{
    [super setTitle:[title uppercaseString] forState:state];
}

+ (CGFloat) buttonHeight; { return 42; }


@end

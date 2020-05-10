//
//  MysticSubSettingButton.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/26/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticSubSettingButton.h"
#import "MysticColor.h"

@implementation MysticSubSettingButton

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


- (void) commonInit;
{
    [super commonInit];
    [self.titleLabel setFont:[MysticFont fontBold:MYSTIC_UI_SUBSETTINGS_FONTSIZE]];
    [self setTitleColor:[UIColor hex:@"4e4640"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateSelected];
}

- (CGFloat) padding;
{
    return 19;
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state;
{
    [super setTitle:[title uppercaseString] forState:state];
}

@end

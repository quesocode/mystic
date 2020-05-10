//
//  MysticAlignButton.m
//  Mystic
//
//  Created by Me on 3/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticAlignButton.h"

@implementation MysticAlignButton

- (void) commonInit;
{
    [super commonInit];
    self.minToggleState = MysticAlignPositionTopLeft;
    self.maxToggleState = MysticAlignPositionBottomRight;
    self.defaultToggleState = textAlignment(NSTextAlignmentCenter);
    self.toolType = MysticToolTypeAlign;
    self.iconStyle = MysticIconTypeImage;
    self.contentMode = UIViewContentModeCenter;
    self.iconColor = [MysticColor color:@(MysticColorTypeWhite)];
    self.iconSize = CGSizeMake(MYSTIC_UI_FONT_TOOL_ICONSIZE, MYSTIC_UI_FONT_TOOL_ICONSIZE);
    self.toggleState = MysticAlignPositionCenter;
    self.nextToggleState = MysticAlignPositionTopLeft;
    self.startToggleState = MysticAlignPositionCenter;
    
    
    [self setNeedsDisplay];
    
}

- (void) updateIconImage;
{
    [super updateIconImage];
    if(self.minToggleState <= MysticAlignPositionNone)
    {
        [self setIconImage:[MysticImage image:@(MysticIconTypePositionNone) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionNone];
    }

    [self setIconImage:[MysticImage image:@(MysticIconTypePositionTopLeft) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionTopLeft];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionTop) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionTop];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionTopRight) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionTopRight];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionLeft) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionLeft];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionCenter) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionCenter];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionRight) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionRight];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionBottomLeft) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionBottomLeft];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionBottom) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionBottom];
    [self setIconImage:[MysticImage image:@(MysticIconTypePositionBottomRight) size:self.iconSize color:self.iconColor] forState:MysticAlignPositionBottomRight];
    
}

@end

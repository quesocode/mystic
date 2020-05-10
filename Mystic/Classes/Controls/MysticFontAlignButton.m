//
//  MysticFontAlignButton.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticFontAlignButton.h"

@interface MysticFontAlignButton ()
{
    BOOL readyToUpdateIcons;
}


@end
@implementation MysticFontAlignButton


- (void) commonInit;
{
    readyToUpdateIcons = NO;
    [super commonInit];
    
    self.iconSize = CGSizeMake(MYSTIC_UI_FONT_TOOL_ICONSIZE, MYSTIC_UI_FONT_TOOL_ICONSIZE);
    self.contentMode = UIViewContentModeCenter;
    self.iconColor = [MysticColor color:@(MysticColorTypeWhite)];
    self.iconStyle = MysticIconTypeImage;
    self.toolType = MysticToolTypeTextAlign;

    self.minToggleState = textAlignment(NSTextAlignmentCenter);
    self.maxToggleState = textAlignment(MysticTextAlignmentRight);
    self.defaultToggleState = textAlignment(NSTextAlignmentCenter);
    
    readyToUpdateIcons = YES;
    [self updateIconImage];
    self.toggleState = self.defaultToggleState;
    
}

- (NSTextAlignment) textAlignment;
{
    return textAlignmentValue(self.toggleState);
}

- (void) updateIconImage;
{
    if(!readyToUpdateIcons) return;
    [super updateIconImage];
    [self setIconImage:[MysticImage image:@(MysticIconTypeAlignLeft) size:self.iconSize color:self.iconColor] forState:textAlignment(NSTextAlignmentLeft)];
    [self setIconImage:[MysticImage image:@(MysticIconTypeAlignCenter) size:self.iconSize color:self.iconColor] forState:textAlignment(NSTextAlignmentCenter)];
    [self setIconImage:[MysticImage image:@(MysticIconTypeAlignRight) size:self.iconSize color:self.iconColor] forState:textAlignment(NSTextAlignmentRight)];
    if(self.maxToggleState >= textAlignment(NSTextAlignmentJustified))
    {
        [self setIconImage:[MysticImage image:@(MysticIconTypeAlignJustified) size:self.iconSize color:self.iconColor] forState:textAlignment(NSTextAlignmentJustified)];
    }
    if(self.maxToggleState >= textAlignment(MysticTextAlignmentFill))
    {
        [self setIconImage:[MysticImage image:@(MysticIconTypeAlignFill) size:self.iconSize color:self.iconColor] forState:textAlignment(MysticTextAlignmentFill)];
    }
    if(self.maxToggleState >= textAlignment(MysticTextAlignmentJustifiedRight))
    {
        [self setIconImage:[MysticImage image:@(MysticIconTypeAlignJustifiedRight) size:self.iconSize color:self.iconColor] forState:textAlignment(MysticTextAlignmentJustifiedRight)];
    }
}

@end

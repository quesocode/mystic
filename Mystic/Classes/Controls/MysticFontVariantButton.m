//
//  MysticFontVariantButton.m
//  Mystic
//
//  Created by Me on 3/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticFontVariantButton.h"

@implementation MysticFontVariantButton


- (void) commonInit;
{
    [super commonInit];
    self.minToggleState = 0;
    self.maxToggleState = 3;
    self.defaultToggleState = self.minToggleState;
    self.toolType = MysticToolTypeFontVariant;
    self.iconStyle = MysticIconTypeImage;
    self.contentMode = UIViewContentModeCenter;
    self.iconColor = [MysticColor color:@(MysticColorTypeWhite)];
    self.iconSize = CGSizeMake(MYSTIC_UI_FONT_TOOL_ICONSIZE_FONT, MYSTIC_UI_FONT_TOOL_ICONSIZE_FONT);
    self.toggleState = self.minToggleState;
    
    [self setNeedsDisplay];
    
}

- (void) setupWithFont:(UIFont *)font;
{
    
}

- (void) updateIconImage;
{
    [super updateIconImage];
    
    [self setIconImage:[MysticImage image:@(MysticIconTypeFontNormal) size:self.iconSize color:self.iconColor] forState:0];
    [self setIconImage:[MysticImage image:@(MysticIconTypeFontBold) size:self.iconSize color:self.iconColor] forState:1];
    [self setIconImage:[MysticImage image:@(MysticIconTypeFontItalic) size:self.iconSize color:self.iconColor] forState:2];
    [self setIconImage:[MysticImage image:@(MysticIconTypeFontBoldItalic) size:self.iconSize color:self.iconColor] forState:3];


    
    for (int i = self.minToggleState; i <= self.maxToggleState; i++) {
        
    }
}

@end

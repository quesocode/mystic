//
//  UIFont+Mystic.m
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "UIFont+Mystic.h"

@implementation UIFont (Mystic)

- (NSInteger) numberOfFontsInFamily;
{
    return [[UIFont fontNamesForFamilyName:self.familyName] count];
}
- (NSIndexSet *) styleSet;
{
    NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
    NSString *f = nil;
    MysticFontStyle fi = MysticFontStyleNormal;
    
    for (NSInteger x=fi; x < MysticFontStyleCondensed+1; x++) {
        if([self fontNameWithStyle:x]) [is addIndex:x];

    }
    
    return is;
}
- (NSInteger) numberOfStyledFontsInFamily;
{
    NSInteger x = 0;
    if(self.regularFontName) x++;
    if(self.boldFontName) x++;
    if(self.boldItalicFontName) x++;
    if(self.italicFontName) x++;
    if(self.lightFontName) x++;
    return x;
}
- (NSString *) fontNameWithStyle:(MysticFontStyle)style;
{
    NSString *f = nil;
    switch (style) {
        case MysticFontStyleBold:
            f = [self boldFontName];
            break;
        case MysticFontStyleBoldItalic:
            f = [self boldItalicFontName];
            break;
        case MysticFontStyleItalic:
            f = [self italicFontName];
            break;
        case MysticFontStyleNormal:
            f = [self regularFontName];
            break;
        case MysticFontStyleLight:
            f = [self lightFontName];
            break;
        default: break;
    }
    return f;
}
- (UIFont *) fontWithStyle:(MysticFontStyle)style;
{
    NSString *f = [self fontNameWithStyle:style];
    
    f = f ? f : self.fontName;
    return [UIFont fontWithName:f size:self.pointSize];
}

- (NSString *) boldFontName;
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:self.familyName];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([upperCaseFontName rangeOfString:@"BOLD"].location != NSNotFound &&
            ([upperCaseFontName rangeOfString:@"ITALIC"].location == NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location == NSNotFound)) {
            return fontName;
        }
        if ([upperCaseFontName rangeOfString:@"BLACK"].location != NSNotFound &&
            ([upperCaseFontName rangeOfString:@"ITALIC"].location == NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location == NSNotFound)) {
            return fontName;
        }
        if ([upperCaseFontName rangeOfString:@"HEAVY"].location != NSNotFound &&
            ([upperCaseFontName rangeOfString:@"ITALIC"].location == NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location == NSNotFound)) {
            return fontName;
        }
        if ([upperCaseFontName rangeOfString:@"MEDIUM"].location != NSNotFound &&
            ([upperCaseFontName rangeOfString:@"ITALIC"].location == NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location == NSNotFound)) {
            return fontName;
        }
    }
    return nil;
}

- (NSString *) lightFontName;
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:self.familyName];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([upperCaseFontName rangeOfString:@"LIGHT"].location != NSNotFound) {
            return fontName;
        }
    }
    return nil;
}
- (NSString *) regularFontName;
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:self.familyName];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([upperCaseFontName rangeOfString:@"REGULAR"].location != NSNotFound || [upperCaseFontName rangeOfString:@"CLASSIC"].location != NSNotFound || [upperCaseFontName rangeOfString:@"INLINE"].location != NSNotFound) {
            return fontName;
        }
    }
    
    NSString *f = [self.familyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([f isEqualToString:upperCaseFontName]) {
            return fontName;
        }
    }
    
    return nil;
}

- (NSString *) italicFontName;
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:self.familyName];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([upperCaseFontName rangeOfString:@"ITALIC"].location != NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location != NSNotFound) {
            return fontName;
        }
    }
    return nil;
}

- (NSString *) boldItalicFontName;
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:self.familyName];
    for (NSString *fontName in fontNames) {
        NSString *upperCaseFontName = [fontName uppercaseString];
        if ([upperCaseFontName rangeOfString:@"BOLD"].location != NSNotFound &&
            ([upperCaseFontName rangeOfString:@"ITALIC"].location != NSNotFound || [upperCaseFontName rangeOfString:@"OBLIQUE"].location != NSNotFound)) {
            return fontName;
        }
    }
    return nil;
}

@end

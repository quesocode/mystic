//
//  UIFont+Mystic.h
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticFont.h"

@interface UIFont (Mystic)
- (NSIndexSet *) styleSet;
- (NSInteger) numberOfFontsInFamily;
- (NSInteger) numberOfStyledFontsInFamily;
- (UIFont *) fontWithStyle:(MysticFontStyle)style;
- (NSString *) boldFontName;
- (NSString *) regularFontName;
- (NSString *) italicFontName;
- (NSString *) boldItalicFontName;
- (NSString *) lightFontName;
- (NSString *) fontNameWithStyle:(MysticFontStyle)style;

@end

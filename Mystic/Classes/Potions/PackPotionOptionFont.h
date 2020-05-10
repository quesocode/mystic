//
//  PackPotionOptionFont.h
//  Mystic
//
//  Created by Travis on 8/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "PackPotionOptionView.h"

@class PackPotionOptionColor, MysticLabelsView;

@interface PackPotionOptionFont : PackPotionOptionView

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *fontFamily, *fontName;
@property (nonatomic, assign) CGFloat fontSize, spacing, lineHeight, lineHeightScale;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, retain) NSAttributedString *attributedString;

@property (nonatomic, assign) UILabel *viewLabel;
@property (nonatomic, assign) MysticTextAlignment textAlignment;
@property (nonatomic) MysticFontStyle fontStyle;
@property (nonatomic, assign) NSInteger colorIndex, fontIndex;
@property (nonatomic, retain) PackPotionOptionFont *fontOption;

- (UIView *) renderView;

+ (UIFont *) defaultFont;

@end

//
//  PackPotionOptionFontStyle.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "MysticLayerBaseView.h"
#import "PackPotionOptionFont.h"

@class MysticFontStyleView;

@interface PackPotionOptionFontStyle : PackPotionOptionFont

@property (nonatomic, retain) MysticLayerBaseView* view;
@property (nonatomic, assign) NSArray *fonts;
@property (nonatomic, retain) PackPotionOptionFontStyle *fontStyleOption;

@end

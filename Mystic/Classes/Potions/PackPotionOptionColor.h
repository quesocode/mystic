//
//  PackPotionOptionColor.h
//  Mystic
//
//  Created by travis weerts on 1/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOption.h"

@interface PackPotionOptionColor : PackPotionOption
@property (nonatomic) BOOL isPicker;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) MysticColorType colorType;
@property (nonatomic, assign) MysticObjectType objectType;
@property (nonatomic, assign) MysticOptionColorType optionType;
@property (nonatomic, assign) CGSize selectedSize, unselectedSize;
@property (nonatomic, assign) CGFloat borderWidth;
@end

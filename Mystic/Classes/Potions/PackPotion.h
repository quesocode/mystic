//
//  PackPotion.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@class PackPotionOptionText, PackPotionOptionFrame, PackPotionOptionTexture, PackPotionOptionFilter, PackPotionOptionLight, MysticPack, PackPotionOptionMask, PackPotionOption, PackPotionOptionBadge, PackPotionOptionColor;

@interface PackPotion : MysticControlObject

@property (nonatomic, assign) MysticPack *pack;
@property (nonatomic, retain) NSDictionary *info;
@property (nonatomic, assign) NSArray *textOptions;
@property (nonatomic, assign) NSArray *frameOptions;
@property (nonatomic, assign) NSArray *maskOptions;
@property (nonatomic, assign) NSArray *textureOptions;
@property (nonatomic, assign) NSArray *filterOptions;
@property (nonatomic, assign) NSArray *lightOptions;
@property (nonatomic, assign) NSArray *badgeOptions;
@property (nonatomic, assign) NSArray *textColorOptions;
@property (nonatomic, assign) NSArray *badgeColorOptions;
@property (nonatomic, assign) NSArray *frameBackgroundColorOptions;
@property (nonatomic, assign) float defaultColorAlpha;
@property (nonatomic, assign) float defaultBrightness;
@property (nonatomic, assign) float defaultExposure;
@property (nonatomic, assign) float defaultGamma;

@property (nonatomic, assign) PackPotionOptionText *defaultTextOption;
@property (nonatomic, assign) PackPotionOptionFrame *defaultFrameOption;
@property (nonatomic, assign) PackPotionOptionMask *defaultMaskOption;
@property (nonatomic, assign) PackPotionOptionTexture *defaultTextureOption;
@property (nonatomic, assign) PackPotionOptionFilter *defaultFilterOption;
@property (nonatomic, assign) PackPotionOptionLight *defaultLightOption;
@property (nonatomic, assign) PackPotionOptionBadge *defaultBadgeOption;
@property (nonatomic, assign) PackPotionOptionColor *defaultBadgeColorOption;
@property (nonatomic, assign) PackPotionOptionColor *defaultTextColorOption;
@property (nonatomic, assign) PackPotionOptionColor *defaultFrameBackgroundColorOption;

+ (PackPotion *) potionWithName:(NSString *)name info:(NSDictionary *)info;
- (PackPotionOption *) optionForType:(MysticObjectType)optionType tag:(NSString *)withTag;

@end

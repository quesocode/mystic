//
//  PackPotionOptionBlend.h
//  Mystic
//
//  Created by travis weerts on 9/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOption.h"

@interface PackPotionOptionBlend : PackPotionOption

@property (nonatomic, assign) MysticFilterType blend, newBlendingType;
@property (nonatomic, assign) MysticObjectType targetType;
@end

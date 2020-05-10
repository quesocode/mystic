//
//  PackPotionOptionCollectionItem.h
//  Mystic
//
//  Created by Me on 6/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionLayer.h"
#import "MysticCollectionItem.h"

@interface PackPotionOptionCollectionItem : PackPotionOptionLayer

@property (nonatomic, retain) MysticCollectionItem *item;

+ (id) optionWithItem:(MysticCollectionItem *)theItem;
@end

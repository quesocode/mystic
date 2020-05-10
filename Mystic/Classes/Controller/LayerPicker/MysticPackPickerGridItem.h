//
//  MysticPackPickerGridItem.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionItem.h"
#import "Mystic.h"

@interface MysticPackPickerGridItem : MysticCollectionItem
@property (nonatomic, retain) MysticPack *pack;
@property (nonatomic, retain) PackPotionOption *option;

@end

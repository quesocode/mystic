//
//  MysticPackPickerDataSourceGrid.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewDataSource.h"

@class PackPotionOption, MysticPack;
@interface MysticPackPickerDataSourceGrid : MysticCollectionViewDataSource

@property (nonatomic, retain) NSArray *packTypes, *packs;
@property (nonatomic, assign) MysticOptionTypes optionTypes, packOptionTypes;
@property (nonatomic, assign) BOOL hasSpecialPack;

- (NSIndexPath *) indexPathForPack:(MysticPack *)pack;
- (NSIndexPath *) indexPathForOption:(PackPotionOption *)option;


@end

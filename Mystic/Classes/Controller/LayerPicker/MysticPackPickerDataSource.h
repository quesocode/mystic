//
//  MysticPackPickerDataSource.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewDataSource.h"
#import "Mystic.h"

@interface MysticPackPickerDataSource : MysticCollectionViewDataSource

@property (nonatomic, assign) MysticOptionTypes optionTypes, packOptionTypes;
@property (nonatomic, retain) NSArray *packTypes, *packs;
@property (nonatomic, assign) BOOL hasSpecialPack;

@end

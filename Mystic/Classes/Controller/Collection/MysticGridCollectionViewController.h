//
//  MysticGridCollectionViewController.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewController.h"

@interface MysticGridCollectionViewController : MysticCollectionViewController
@property (nonatomic, assign) MysticGridSize gridSize;
+ (MysticGridSize) gridSize;

@end

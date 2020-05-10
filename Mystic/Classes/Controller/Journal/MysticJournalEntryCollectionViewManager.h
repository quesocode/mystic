//
//  MysticJournalEntryCollectionViewManager.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticJournalEntryDataSource.h"

@interface MysticJournalEntryCollectionViewManager : NSObject <UICollectionViewDataSource,UICollectionViewDelegate>
@property (retain,nonatomic) UICollectionView *collectionView;
@property (nonatomic, assign) id <UIScrollViewDelegate>scrollViewDelegate;
@property (strong, nonatomic) MysticJournalEntryDataSource *dataSource;
@property (assign, nonatomic) MysticJournalEntry *journalEntry;

@end

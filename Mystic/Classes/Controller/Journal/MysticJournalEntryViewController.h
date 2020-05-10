//
//  MysticJournalEntryViewController.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"
#import "MysticJournalEntryCollectionViewManager.h"
#import "MysticJournalEntry.h"

@interface MysticJournalEntryViewController : MysticViewController <UIScrollViewDelegate>
@property (retain,nonatomic) MysticJournalEntryCollectionViewManager *collectionViewManager;
@property (assign, nonatomic) MysticJournalEntry *journalEntry;

@end

//
//  MysticJournalEntryDataSource.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticJournalEntry.h"
#import "MysticJournalBlock.h"

@interface MysticJournalEntryDataSource : NSObject

@property (nonatomic, readonly) MysticJournalEntry *parentItem;
- (NSInteger) numberOfSections;
- (NSInteger) numberOfItemsForSection:(NSInteger)section;

- (MysticJournalBlock *) itemAtIndexPath:(NSIndexPath *)indexPath;
- (MysticJournalEntry *) sectionAtIndex:(NSInteger)section;

- (void) setJournalEntry:(MysticJournalEntry *)entry;

@end

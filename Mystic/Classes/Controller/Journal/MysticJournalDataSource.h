//
//  MysticJournalDataSource.h
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticJournalEntry.h"
#import "MysticJournalBlock.h"

@interface MysticJournalDataSource : NSObject

- (NSString *) imageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) numberOfSections;
- (NSString *) titleForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) numberOfItemsForSection:(NSInteger)section;

- (MysticJournalEntry *) itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *) sectionAtIndex:(NSInteger)section;
- (void) reloadData;
- (void) reloadData:(MysticBlockObjObjBOOL)finished;
- (void) reloadData:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
+ (void) clearCache;
@end

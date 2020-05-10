//
//  MysticJournalEntryDataSource.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalEntryDataSource.h"

@interface MysticJournalEntryDataSource ()
{
    MysticJournalEntry *_item;
}
@end

@implementation MysticJournalEntryDataSource

- (NSInteger) numberOfSections;
{
    return 1;
}
- (NSInteger) numberOfItemsForSection:(NSInteger)section;
{
    return _item.blocks.count;
}
- (MysticJournalBlock *) itemAtIndexPath:(NSIndexPath *)indexPath;
{
    return [_item.blocks objectAtIndex:indexPath.item];
}
- (MysticJournalEntry *) sectionAtIndex:(NSInteger)section;
{
    return (id)_item;
}
- (void) setJournalEntry:(MysticJournalEntry *)entry;
{
    if(_item)
    {
        [_item release], _item = nil;
    }
    _item = [entry retain];
}
- (MysticJournalEntry *) parentItem;
{
    return _item;
}


@end

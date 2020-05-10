//
//  MysticJournalDataSource.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalDataSource.h"
#import "MysticDictionaryDownloader.h"


@interface MysticJournalDataSource ()
{
    NSMutableArray *_items;
    BOOL hasBeenLoaded;
}
@end
@implementation MysticJournalDataSource

- (void) dealloc;
{
    [_items release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        hasBeenLoaded = NO;
        _items = [[NSMutableArray array] retain];
    }
    return self;
}
- (NSDictionary *) sectionAtIndex:(NSInteger)section;
{
    return _items.count > section ? [_items objectAtIndex:section] : nil;
}
- (NSArray *) itemsForSection:(NSInteger)section;
{
    NSDictionary *sectionObj = [self sectionAtIndex:section];
    return [sectionObj objectForKey:@"items"] ? [sectionObj objectForKey:@"items"] : @[];
    
}
- (MysticJournalEntry *) itemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *sectionItems = [self itemsForSection:indexPath.section];
    return sectionItems.count > indexPath.item ? [sectionItems objectAtIndex:indexPath.item] : nil;
}
- (NSString *) imageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self itemAtIndexPath:indexPath].imageURLString;
    
}
- (NSInteger) numberOfSections;
{
    return _items.count;
}
- (NSInteger) numberOfItemsForSection:(NSInteger)section;
{
    return [self itemsForSection:section].count;
}
- (NSString *) titleForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self itemAtIndexPath:indexPath].title;
}
+ (void) clearCache;
{
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL]];
}
- (void) reloadData;
{
    [self reloadData:nil];
}
- (void) reloadData:(MysticBlockObjObjBOOL)finished;
{
    [self reloadData:nil complete:finished];
}
- (void) reloadData:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    hasBeenLoaded = NO;
    [_items removeAllObjects];
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"journal" ofType:@"plist"] ;
    
    __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL]];
    __unsafe_unretained __block MysticJournalDataSource *weakSelf = self;
    [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL] orDictionary:cachedPath state:^(id data, MysticDataState dataState) {
        
    
        BOOL success = !(dataState & MysticDataStateError);
        
        NSArray *theItems = [weakSelf itemsFromDictionary:data];
        if(dataState & MysticDataStateComplete)
        {
            if(__finished)
            {
                __finished(theItems, nil, success);
                Block_release(__finished);
            }
        }
    }];
}
- (NSArray *) items;
{
    return [NSArray arrayWithArray:_items];
}
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo;
{
    if(!hasBeenLoaded && itemsInfo)
    {
        hasBeenLoaded = YES;
        int _row = 0;
        int _section = 0;
        NSArray *sectionsArray = [itemsInfo objectForKey:@"sections"];
        
        for (NSDictionary *section in sectionsArray)
        {
            NSMutableArray *__items = [NSMutableArray array];
            NSArray *itemsArray = [section objectForKey:@"items"];
            for (NSDictionary *itemDict in itemsArray) {
                [__items addObject:[MysticJournalEntry itemWithDictionary:itemDict indexPath:[NSIndexPath indexPathForRow:_row inSection:_section]]];
                _row++;
            }
            
            [_items addObject:@{@"items":[NSArray arrayWithArray:__items]}];
            _section++;
        }
    }
    return [NSArray arrayWithArray:_items];
}
@end

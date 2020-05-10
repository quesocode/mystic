//
//  MysticCollectionViewDataSource.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewDataSource.h"

@interface MysticCollectionViewDataSource ()
{
    
    
}
@end
@implementation MysticCollectionViewDataSource

+ (Class) collectionItemClass;
{
    return [MysticCollectionItem class];
}

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticCollectionViewCell";
    return cellIdentifier;
}

+ (NSString *) sectionHeaderCellIdentifier;
{
    static NSString *cellIdentifier2=@"MysticCollectionViewCellHeader";
    return cellIdentifier2;
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    return [MysticCollectionViewCell class];
}



- (void) dealloc;
{
//    DLog(@"CollectionDataSource dealloc: %@", [self class]);
    if(_items) [_items release];
    _controller = nil;
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _itemRange = MysticCollectionRangeUnknown;
        hasBeenLoaded = NO;
//        _items = [[NSMutableArray alloc] init];
        self.items = [NSMutableArray array];
    }
    return self;
}
- (NSDictionary *) sectionAtIndex:(NSInteger)section;
{
    return self.items.count > section ? [self.items objectAtIndex:section] : nil;
}
- (NSArray *) itemsForSection:(NSInteger)section;
{
    NSDictionary *sectionObj = [self sectionAtIndex:section];
    return [sectionObj objectForKey:@"items"] ? [sectionObj objectForKey:@"items"] : @[];
    
}
- (id) itemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *sectionItems = [self itemsForSection:indexPath.section];
    return sectionItems.count > indexPath.item ? [sectionItems objectAtIndex:indexPath.item] : nil;
}
- (NSString *) imageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return [(MysticCollectionItem *)[self itemAtIndexPath:indexPath] imageURLString];
    
}
- (NSArray *) filteredData:(NSArray *)unfilteredItems;
{
    return unfilteredItems ? unfilteredItems : @[];
}
- (BOOL) sectionIsToolbarAtIndex:(NSInteger)section;
{
    NSDictionary *sectionInfo = [self sectionAtIndex:section];
    return [sectionInfo objectForKey:@"toolbar"] ? [[sectionInfo objectForKey:@"toolbar"] boolValue] : NO;
}
- (NSInteger) numberOfSections;
{
    return self.items.count;
}
- (NSInteger) numberOfItemsForSection:(NSInteger)section;
{
    return [self itemsForSection:section].count;
}
- (NSString *) titleForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return [(MysticCollectionItem *)[self itemAtIndexPath:indexPath] title];
}

+ (NSString *) dataSourceURL;
{
    return nil;
}
+ (void) clearCache;
{
    if(![self dataSourceURL]) return;
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:[self dataSourceURL]]];
}

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    [self reloadData:startBlock ready:onReady complete:finished];
}


- (void) reloadData;
{
    [self reloadData:nil complete:nil];
}
- (void) reloadData:(MysticBlockObjObjBOOL)finished;
{
    [self reloadData:nil complete:finished];
}
- (void) reloadData:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    [self reloadData:startBlock ready:nil complete:finished];
}
- (void) reloadData:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady complete:(MysticBlockObjObjBOOL)finished;
{
    [self reloadDataWithKeys:nil start:startBlock complete:finished];
}

- (void) reloadDataInRange:(MysticCollectionRange)range start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    self.itemRange = range;
    [self reloadData:startBlock complete:finished];
}
- (void) reloadDataInRange:(MysticCollectionRange)range keys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    self.itemRange = range;
    [self reloadDataWithKeys:keys start:startBlock complete:finished];
}


- (void) reloadDataWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{
    hasBeenLoaded = NO;
    [self.items removeAllObjects];
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"journal" ofType:@"plist"] ;
    
    __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL]];
    __unsafe_unretained __block MysticCollectionViewDataSource *weakSelf = self;
    __unsafe_unretained __block NSArray *weakKeys = keys ? [keys retain] : nil;
    
    [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL] orDictionary:cachedPath start:startBlock complete:^(NSDictionary *itemsDict, NSURL *url, NSURL* url2, BOOL success) {
        
        NSArray *theItems = [weakSelf itemsFromDictionary:itemsDict keys:weakKeys];
        [weakKeys release];
        if(__finished)
        {
            __finished(theItems, url, success);
            Block_release(__finished);
        }
    }];
    
}
- (id) itemWithTag:(NSString *)lookupTag info:(NSDictionary *)itemInfo;
{
    return nil;
}
- (id) itemWithTag:(NSString *)lookupTag;
{
    return [self itemWithTag:lookupTag info:nil];
}
- (NSArray *) itemsWithKeys:(NSArray *)keys dataBlock:(MysticBlockData)finished;
{
    return nil;
}
- (NSArray *) itemsWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
{

    hasBeenLoaded = NO;
    [self.items removeAllObjects];
    
    NSString *cachedPath = [[NSBundle mainBundle] pathForResource:@"journal" ofType:@"plist"] ;
    
    __unsafe_unretained __block MysticBlockObjObjBOOL __finished = finished ? Block_copy(finished) : nil;
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL]];
    __unsafe_unretained __block MysticCollectionViewDataSource *weakSelf = self;
    __unsafe_unretained __block NSArray *weakKeys = keys ? [keys retain] : nil;

    NSDictionary *rData = [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:MYSTIC_JOURNAL_DATA_URL] orDictionary:cachedPath start:startBlock complete:^(NSDictionary *itemsDict, NSURL *url, NSURL* url2, BOOL success) {
        
        NSArray *theItems = [weakSelf itemsFromDictionary:itemsDict keys:weakKeys];
        [weakKeys release];
        if(__finished)
        {
            __finished(theItems, url, success);
            Block_release(__finished);
        }
    }];
    
    return [weakSelf itemsFromDictionary:rData keys:keys];
}

//- (void) setItems:(NSArray *)items;
//{
//    [_items removeAllObjects];
//    [self.items addObjectsFromArray:items];
//}

- (void) addItem:(id)item;
{
    if(item) [self.items addObject:item];
}

//- (NSArray *) items;
//{
//    return [NSArray arrayWithArray:[super items]];
//}
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo;
{
    return [self itemsFromDictionary:itemsInfo keys:nil range:MysticCollectionRangeUnknown];
}
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo range:(MysticCollectionRange)range;
{
    return [self itemsFromDictionary:itemsInfo keys:nil range:range];
}
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo keys:(NSArray *)keys;
{
    return [self itemsFromDictionary:itemsInfo keys:keys range:MysticCollectionRangeUnknown];

}
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo keys:(NSArray *)keys range:(MysticCollectionRange)range;
{
    if(!hasBeenLoaded && itemsInfo)
    {

        hasBeenLoaded = YES;
        NSArray *sectionsArray = [itemsInfo objectForKey:@"sections"];
        int _row = 0;
        int _section = 0;
        
        for (NSDictionary *section in sectionsArray)
        {
            NSMutableArray *__items = [NSMutableArray array];
            
            NSArray *itemsArray = [section objectForKey:@"items"];
            for (NSDictionary *itemDict in itemsArray) {
                MysticCollectionItem *item = [[[self class] collectionItemClass] itemWithDictionary:itemDict indexPath:[NSIndexPath indexPathForRow:_row inSection:_section]];
                if(!item.enabled) continue;
                [__items addObject:item];
                _row++;
            }
            
            [self.items addObject:@{@"items":[NSArray arrayWithArray:__items]}];
            _section++;
        }
    }
    return [NSArray arrayWithArray:self.items];
}


    


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self numberOfItemsForSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self numberOfSections];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MysticCollectionViewCell *cell;
    MysticCollectionItem *item = [self itemAtIndexPath:indexPath];
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:[[self class] cellIdentifier] forIndexPath:indexPath];
    
//    ALLog(@"cell for item", @[@"indexPath", [NSString stringWithFormat:@"%d x %d", indexPath.section, indexPath.row],
//                              @"cell", MObj(cell),
//                              @"item", MObj(item),]);
    
    if(cell)
    {
        cell.collectionItem = item;
    }
    
    
    
    
    return cell;
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *v = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    return [v autorelease];
}


@end
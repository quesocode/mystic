//
//  MysticCollectionViewDataSource.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticCollectionItem.h"
#import "MysticCollectionViewCell.h"
#import "MysticDictionaryDownloader.h"

@class MysticCollectionViewController;

@interface MysticCollectionViewDataSource : NSObject <UICollectionViewDataSource>
{
    BOOL hasBeenLoaded;
    NSMutableArray *_items;
}
@property (nonatomic, assign) MysticCollectionViewController *controller;
@property (nonatomic, assign) MysticCollectionFilter filters;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) MysticCollectionRange itemRange;

- (NSString *) imageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) numberOfSections;
- (NSString *) titleForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) numberOfItemsForSection:(NSInteger)section;

- (id) itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *) sectionAtIndex:(NSInteger)section;
- (BOOL) sectionIsToolbarAtIndex:(NSInteger)section;
- (id) itemWithTag:(NSString *)lookupTag info:(NSDictionary *)itemInfo;
- (id) itemWithTag:(NSString *)lookupTag;

- (void) reloadData;
- (void) reloadData:(MysticBlockObjObjBOOL)finished;
- (void) reloadData:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady complete:(MysticBlockObjObjBOOL)finished;



- (void) reloadDataInRange:(MysticCollectionRange)range start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;

- (void) reloadDataInRange:(MysticCollectionRange)range keys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;


- (void) reloadDataWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;


- (NSArray *) itemsWithKeys:(NSArray *)keys start:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
- (NSArray *) itemsWithKeys:(NSArray *)keys dataBlock:(MysticBlockData)finished;


+ (void) clearCache;
- (void) addItem:(id)item;
- (NSArray *) filteredData:(NSArray *)unfilteredItems;
+ (Class) collectionItemClass;
+ (Class) cellClassForIdentifier:(NSString *)identifier;

+ (NSString *) cellIdentifier;
+ (NSString *) sectionHeaderCellIdentifier;

+ (NSString *) dataSourceURL;
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo;
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo keys:(NSArray *)keys;
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo keys:(NSArray *)keys range:(MysticCollectionRange)range;
- (NSArray *) itemsFromDictionary:(NSDictionary *)itemsInfo range:(MysticCollectionRange)range;



@end

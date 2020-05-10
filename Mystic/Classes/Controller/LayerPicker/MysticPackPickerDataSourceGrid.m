//
//  MysticPackPickerDataSourceGrid.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerDataSourceGrid.h"
#import "MysticPackPickerGridCell.h"
#import "MysticPackPickerGridItem.h"
#import "MysticPackPickerGridCellSectionHeader.h"
#import "Mystic.h"
#import "MysticCollectionViewLayout.h"
#import "MysticCollectionViewSectionToolbarHeader.h"
#import "MysticPackPickerGridCellBlend.h"
#import "MysticPackPickerViewController.h"

@interface MysticPackPickerDataSourceGrid()
{
    BOOL foundToolbar;
    NSInteger numSections;
}

@property (nonatomic, readonly) MysticPackPickerViewController *packController;
@end

@implementation MysticPackPickerDataSourceGrid


+ (Class) collectionItemClass;
{
    return [MysticPackPickerGridItem class];
}

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticPackPickerGridCell";
    return cellIdentifier;
}

+ (NSString *) sectionHeaderCellIdentifier;
{
    static NSString *cellIdentifier2=@"MysticPackPickerGridCellHeader";
    return cellIdentifier2;
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    if([identifier isEqualToString:[[self class] sectionHeaderCellIdentifier]])
    {
        return [MysticPackPickerGridCellSectionHeader class];
    }
    
    return [identifier hasSuffix:@"Blend"] ? [MysticPackPickerGridCellBlend class] : [MysticPackPickerGridCell class];
}


- (void) dealloc;
{
    [_packTypes release];
    [_packs release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        numSections = NSNotFound;
        _hasSpecialPack = NO;
    }
    return self;
}

- (MysticPackPickerViewController *) packController;
{
    return (id)self.controller;
}


- (NSInteger) numberOfSections;
{
    if(numSections == NSNotFound)
    {
        numSections = (self.filters & MysticCollectionFilterUserRecent) ? 2 : [MysticOptionsDataSource numberOfPacksOfType:(self.packTypes.count > 1 ? self.optionTypes : self.packOptionTypes)] + 1;
    }
    return numSections;
}

- (NSInteger) numberOfItemsForSection:(NSInteger)section;
{
    if(section == 0 || self.packTypes.count == 0) return 0;
    if(self.filters & MysticCollectionFilterUserRecent)
    {
        return [[MysticUser user] numberOfItemsUsedRecentlyForType:[[self.packTypes lastObject] integerValue]];
    }
    
    if(numSections == 2)
    {
        
        
        return [MysticOptionsDataSource numberOfItemsForSection:section-1 type:self.optionTypes];
        
        
    }
    
    return [MysticOptionsDataSource numberOfItemsForSection:section-1 type:(self.packTypes.count > 1 ? self.optionTypes : self.packOptionTypes)];
    
}

- (NSIndexPath *) indexPathForPack:(MysticPack *)pack;
{
    int i = 0;
    for (NSDictionary *itms in self.items) {
        if(itms[@"pack"] && [itms[@"pack"] isEqualToString:pack.name])
        {
            return [NSIndexPath indexPathForItem:0 inSection:i];
        }
        i++;
    }
    return nil;
}

- (NSIndexPath *) indexPathForOption:(PackPotionOption *)option;
{
    int i = 0;

    for (NSDictionary *itms in self.items) {
        if(itms[@"pack"] && itms[@"items"])
        {
            int i2 = 0;

            for (MysticPackPickerGridItem *itm in itms[@"items"]) {
                if([itm.option isSame:option])
                {
                    return [NSIndexPath indexPathForItem:i2 inSection:i];

                }
                i2++;
            }
        }
        i++;
    }
    return nil;
}

//- (void) reloadData:(MysticBlockObjBOOL)startBlock complete:(MysticBlockObjObjBOOL)finished;
//{

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    __unsafe_unretained __block MysticPackPickerDataSourceGrid *weakSelf = self;
    if(startBlock) startBlock(nil, NO);
//    if(onReady)
//    {
//        onReady(collectionView);
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
    
        int _item = 0;
        int _section = 1;
        [weakSelf.items removeAllObjects];
        weakSelf.packs = nil;

        NSMutableArray *unfilteredItems = [NSMutableArray array];
//        NSMutableDictionary *usedItems = [[NSMutableDictionary alloc] init];
        NSMutableArray *__items;
        if(weakSelf.packTypes.count == 0)
        {
            weakSelf.packTypes = [Mystic mainObjectTypes];
            
        }
        
        
        
        if(weakSelf.packTypes.count)
        {


            if(weakSelf.filters & MysticCollectionFilterUserRecent)
            {
                NSMutableArray *recentItems = [NSMutableArray array];
                NSMutableArray *allPackItems = [NSMutableArray array];
                NSMutableArray *usedItemsOfTypes = [NSMutableArray array];
                __items = [NSMutableArray array];

                weakSelf.packs = [MysticOptionsDataSource packsWithType:weakSelf.optionTypes];
                for (MysticPack *pack in weakSelf.packs)
                {
                    for (PackPotionOption *option in pack.packOptions) {
                        
                        [allPackItems addObject:@{@"pack":pack, @"option":option}];
                    }
                }
                
                for (NSNumber *topicTypeObj in weakSelf.packTypes)
                {
                    [usedItemsOfTypes addObjectsFromArray:[[MysticUser user] itemsUsedRecentlyForType:(MysticObjectType)[topicTypeObj integerValue]]];
                }
                

                for (NSString *usedItemTag in usedItemsOfTypes) {
                    for (NSDictionary *optionPackItem in allPackItems) {

                        PackPotionOption *option = [optionPackItem objectForKey:@"option"];
                        if([option.tag isEqualToString:usedItemTag])
                        {
                            [recentItems addObject:optionPackItem];

                            break;
                        }
                    }
                }
                
                for (NSDictionary *optionPackItem in recentItems)
                {
                    PackPotionOption *option = [optionPackItem objectForKey:@"option"];

//                    if([usedItems objectForKey:option.tag]) continue;
                    
                    MysticPack *pack = [optionPackItem objectForKey:@"pack"];
                    NSMutableDictionary *itemInfo = [NSMutableDictionary dictionaryWithDictionary:pack.info];
                    
                    [itemInfo setObject:MyLocalStr(@"RECENT") forKey:@"sectionTitle"];
                    MysticPackPickerGridItem *item = [[MysticPackPickerGridItem alloc] initWithDictionary:itemInfo indexPath:[NSIndexPath indexPathForRow:_item inSection:_section]];
                    if(!item.enabled)
                    {
                        [item release];
                        continue;
                    }

                    item.pack = pack;
                    item.option = option;
                    [item prepare];
                    [__items addObject:item];
                    [item release];
                    _item++;
                }
                
                
                [unfilteredItems addObject:@{@"items":[NSArray arrayWithArray:__items], @"pack": @"recent"}];

            }
            else
            {
          
               
                
                self.packs = [MysticOptionsDataSource packsWithType:(weakSelf.packTypes.count > 1 ? weakSelf.optionTypes : weakSelf.packOptionTypes)];
                
                
                MysticPack *pack;
                for (MysticPack *pack in weakSelf.packs)
                {
                    
                    _item = 0;
                    __items = [NSMutableArray array];
                    
                    NSString *packName = pack.title;
                    for (PackPotionOption *option in pack.packOptions)
                    {
                        
                        NSMutableDictionary *itemInfo = [NSMutableDictionary dictionaryWithDictionary:pack.info];
                        
                        [itemInfo setObject:packName forKey:@"sectionTitle"];
                        MysticPackPickerGridItem *item = [[MysticPackPickerGridItem alloc] initWithDictionary:itemInfo indexPath:[NSIndexPath indexPathForRow:_item inSection:_section]];
                        
                        if(!item.enabled)
                        {
                            [item release];
                           continue;
                        }
                        
                        item.pack = pack;
                        item.option = option;
                        [item prepare];
                        [__items addObject:item];
                        [item release];
                        _item++;
                    }
                    [unfilteredItems addObject:@{@"items":[NSArray arrayWithArray:__items], @"pack": pack.name}];
                    _section++;
    
                }
                
                
            }
                
            
        }
        [weakSelf.items addObjectsFromArray:[weakSelf filteredItems:unfilteredItems]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(finished) finished(weakSelf.items, nil, NO);
        });
        
    });
}

- (NSArray *) packs;
{
    if(!_packs)
    {
        if(self.filters & MysticCollectionFilterUserRecent)
        {

            
            _packs = [[MysticOptionsDataSource packsWithType:self.optionTypes] retain];
            
        }
        else
        {
            _packs = [[MysticOptionsDataSource packsWithType:(self.packTypes.count > 1 ? self.optionTypes : self.packOptionTypes)] retain];
        }
        if(_packs.count)
        {
            MysticPack* firstPack = [_packs objectAtIndex:0];
            self.hasSpecialPack = firstPack.isSpecial;
            
        }
    }
    
    return _packs;
}

- (NSArray *) filteredItems:(NSArray *)unfilteredItems;
{
    NSMutableArray *sections = [NSMutableArray array];
    if(unfilteredItems && unfilteredItems.count)
    {
        
        if(self.filters & MysticCollectionFilterUserRecent)
        {
            NSMutableArray *bigArray = [NSMutableArray array];
            for (NSDictionary *sectionObj in unfilteredItems)
            {
                [bigArray addObjectsFromArray:[sectionObj objectForKey:@"items"]];
            }
            sections = [NSMutableArray arrayWithArray:@[@{@"toolbar": @YES},
                                                        @{@"items":[NSArray arrayWithArray:bigArray]}
                                                        ]];
        }
        else
        {
            sections = [NSMutableArray arrayWithArray:@[@{@"toolbar": @YES}]];
            [sections addObjectsFromArray:unfilteredItems];
                        
        }
    }
    return sections.count ? sections : @[@{@"toolbar":@YES}];
}

- (id) itemMatchesFilters:(PackPotionOption *)item filters:(MysticCollectionFilter)filts
{
    if(filts & MysticCollectionFilterNone || filts & MysticCollectionFilterAll)
    {
        return item;
    }
    else if(filts & MysticCollectionFilterUserRecent)
    {
        item = [[MysticUser user] hasUsedItemRecently:item] ? item : nil;
    }
    return item;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MysticPackPickerGridCell *cell;
    MysticPackPickerGridItem *item = [self itemAtIndexPath:indexPath];
    
    NSString *theId = [[self class] cellIdentifier];
    if([item.option isKindOfClass:[PackPotionOptionText class]])
    {
        theId = [theId stringByAppendingString:@"Blend"];
    }

    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:theId forIndexPath:indexPath];
    if(cell)
    {
        cell.collectionItem = item;
        if([item.option isSame:self.packController.selectedOption])
        {
            cell.selected = YES;
            [cell didSelect:nil animated:NO];
        }
        
    }
    
    
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;

    MysticPackPickerGridItem *item = [self itemAtIndexPath:indexPath];

    if (kind == UICollectionElementKindSectionHeader)
    {
        if(indexPath.section == 0)
        {
            NSDictionary *sectionInfo = [self sectionAtIndex:indexPath.section];
            if([self sectionIsToolbarAtIndex:indexPath.section])
            {
                MysticCollectionViewSectionToolbarHeader *sectionHeaderView;
                sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[MysticCollectionViewSectionToolbarHeader cellIdentifier] forIndexPath:indexPath];
                sectionHeaderView.info = sectionInfo;
                sectionHeaderView.delegate = (id<MysticCollectionToolbarDelegate>) collectionView.delegate;
                reusableview = sectionHeaderView;
                foundToolbar = YES;
            }

            
        }
        if(!reusableview)
        {
            MysticPackPickerGridCellSectionHeader *sectionHeaderView;
            sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[[self class] sectionHeaderCellIdentifier] forIndexPath:indexPath];
            sectionHeaderView.topBorderWidth = [(MysticCollectionViewLayout *)collectionView.collectionViewLayout sectionHeaderTopBorderWidth];
            if(!item)
            {
                NSString *sectTitle = (self.filters & MysticCollectionFilterUserRecent) ? MyLocalStr(@"RECENT") : nil;
                if(!sectTitle)
                {
                    if([self numberOfSections] > 1 && indexPath.section < 2)
                    {
                        MysticObjectType objType = (MysticObjectType)[[self.packTypes lastObject] integerValue];
                        sectTitle = MyLocalStr([MysticSettings settingForKey:[NSString stringWithFormat:@"%@_featured_title", MysticObjectTypeKey(objType)] default:@"FEATURED"]);
                    }
                    else
                    {
                        sectTitle = MysticObjectTypeTitleParent((MysticObjectType)[[self.packTypes lastObject] integerValue], nil);
                    }
                    
                }
                if(sectTitle)
                {
                    item = [[[MysticPackPickerGridItem alloc] initWithDictionary:@{@"sectionTitle": sectTitle} indexPath:indexPath] autorelease];
                }
            }
            sectionHeaderView.collectionItem = item;
            sectionHeaderView.indexPath = indexPath;
            sectionHeaderView.trackTouch = YES;
            sectionHeaderView.delegate = (id<MysticCollectionToolbarDelegate, MysticPackPickerGridCellSectionHeaderDelegate>) collectionView.delegate;
            if(indexPath.section == 1) {
                sectionHeaderView.showBorder = NO;
            }
            reusableview = sectionHeaderView;

        }
    
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        MysticPackPickerGridCellSectionHeader *sectionHeaderView;
        sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[[self class] sectionHeaderCellIdentifier] forIndexPath:indexPath];
        reusableview = sectionHeaderView;
    }
    return reusableview;
}

- (void) setPackTypes:(NSArray *)packTypes;
{
    numSections = NSNotFound;
    if(_packTypes) [_packTypes release], _packTypes = nil;
    _packTypes = [packTypes retain];
    
    self.optionTypes = _packTypes ? MysticOptionTypesWithArray(_packTypes) : MysticOptionTypeNone;

    [MysticOptionsDataSource preload:(_packTypes.count > 1 ? self.optionTypes : self.packOptionTypes)];
    
}

- (void) setOptionTypes:(MysticOptionTypes)optionTypes;
{
    _optionTypes = optionTypes;
    _packOptionTypes = optionTypes | MysticOptionTypeShowFeaturedPack | MysticOptionTypeShowFeaturedPackTop;
}


@end

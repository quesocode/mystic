//
//  MysticPackPickerDataSource.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerDataSource.h"
#import "MysticPackPickerCell.h"
#import "MysticPackPickerItem.h"
#import "MysticPackPickerCellSectionHeader.h"
#import "MysticPackPickerViewController.h"
#import "MysticCollectionViewLayout.h"
#import "MysticCollectionViewSectionToolbarHeader.h"

@interface MysticPackPickerDataSource()
{
    BOOL foundToolbar;
    NSInteger numSections;
}

@property (nonatomic, readonly) MysticPackPickerViewController *packController;
@end


@implementation MysticPackPickerDataSource

+ (Class) collectionItemClass;
{
    return [MysticPackPickerItem class];
}

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticPackPickerCell";
    return cellIdentifier;
}

+ (NSString *) sectionHeaderCellIdentifier;
{
    static NSString *cellIdentifier2=@"MysticPackPickerCellSectionHeader";
    return cellIdentifier2;
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    if([identifier isEqualToString:[[self class] sectionHeaderCellIdentifier]])
    {
        return [MysticPackPickerCellSectionHeader class];
    }
    return [MysticPackPickerCell class];
}



- (void) dealloc;
{
    MysticOptionTypes theTypes =  (self.packTypes.count > 1 ? self.optionTypes : self.packOptionTypes);
    [MysticOptionsDataSource removePackCache];
    [MysticOptionsDataSource removeAllCacheObjectsForType:theTypes];
    
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
    return 2;
}

- (NSInteger) numberOfItemsForSection:(NSInteger)section;
{
    if(section == 0 || self.packTypes.count == 0) return 0;
    

    return self.packs.count;

    
}

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    
    __unsafe_unretained __block MysticPackPickerDataSource *weakSelf = self;
    if(startBlock) startBlock(nil, NO);
//    if(onReady)
//    {
//        onReady(collectionView);
//    }
    
    __unsafe_unretained __block NSMutableArray *_wItems = [self.items retain];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        int _item = 0;
        int _section = 1;
        weakSelf.packs = nil;
        [_wItems removeAllObjects];
        [_wItems addObject:@{@"toolbar": @YES}];
        
        if(self.packTypes.count == 0) weakSelf.packTypes = [Mystic mainObjectTypes];
        if(self.packTypes.count)
        {
            NSMutableArray *__items = [[NSMutableArray alloc] init];

            for (MysticPack *pack in weakSelf.packs) {
                MysticPackPickerItem *item = [[MysticPackPickerItem alloc] initWithDictionary:pack.info indexPath:[NSIndexPath indexPathForItem:_item inSection:_section]];
                if(!item.enabled)
                {
                    [item release];
                     continue;
                }
                item.pack = pack;
                [__items addObject:item];
                [item release];
                _item++;
                
            }
            

            [_wItems addObject:@{@"items":[NSArray arrayWithArray:__items]}];
            [__items release];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(finished) finished(_wItems, nil, NO);
            [_wItems release];
        });
        
    });
}

- (NSArray *) packs;
{
    if(!_packs)
    {
        _packs = [[MysticOptionsDataSource packsWithType:(self.packTypes.count > 1 ? self.optionTypes : self.packOptionTypes)] retain];
        if(_packs.count)
        {
            MysticPack* firstPack = [_packs objectAtIndex:0];
            self.hasSpecialPack = firstPack.isSpecial;
            
        }
    }
    
    return _packs;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    MysticPackPickerItem *item = [self itemAtIndexPath:indexPath];
    
    
    if (kind == UICollectionElementKindSectionHeader) {
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
            }
            
            
        }
        if(!reusableview)
        {
            MysticPackPickerCellSectionHeader *sectionHeaderView;
            sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[[self class] sectionHeaderCellIdentifier] forIndexPath:indexPath];
            sectionHeaderView.topBorderWidth = [(MysticCollectionViewLayout *)collectionView.collectionViewLayout sectionHeaderTopBorderWidth];
            sectionHeaderView.collectionItem = item;
            if(indexPath.section == 1) {
                sectionHeaderView.showBorder = NO;
            }
            reusableview = sectionHeaderView;
            
        }
        
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        MysticPackPickerCellSectionHeader *sectionHeaderView;
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
    _packOptionTypes = optionTypes | MysticOptionTypeShowFeaturedPack;
}


@end

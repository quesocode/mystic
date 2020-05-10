//
//  MysticAlbumDataSource.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAlbumDataSource.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MysticAssetCollectionCell.h"
#import "NSArray+Mystic.h"
#import "MysticCollectionViewSectionToolbarHeader.h"
#import "MysticCollectionViewLayout.h"
#import "MysticCollectionViewCellSectionHeader.h"
#import "Mystic.h"
#import "MysticCustomImagePickerController.h"


static NSString *backgroundsTitle = @"BACKDROPS";
static NSString *libraryTitle = @"PHOTOS";
static NSString *colorsTitle = @"COLORS";


@interface MysticAlbumDataSource ()

@property (nonatomic, retain) NSMutableArray *assets, *groups;
@property (nonatomic, retain) ALAssetsLibrary *library;
@end
@implementation MysticAlbumDataSource

+ (NSString *) cellIdentifier;
{
    static NSString *cellIdentifier=@"MysticCollectionViewCellAsset";
    return cellIdentifier;
}

+ (Class) collectionItemClass;
{
    return [MysticAssetCollectionItem class];
}

+ (NSString *) sectionHeaderCellIdentifier;
{
    static NSString *cellIdentifier2=@"MysticCollectionSectionUnderHeader";
    return cellIdentifier2;
}

+ (Class) cellClassForIdentifier:(NSString *)identifier;
{
    if([identifier isEqualToString:[[self class] sectionHeaderCellIdentifier]])
    {
        return [MysticCollectionSectionUnderHeader class];
    }
    return [MysticAssetCollectionCell class];
}

- (void) dealloc;
{
    [_assets release];
    [_library release];
    [_groups release];
    [_album release];
    [super dealloc];
    
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        self.reversePhotos = NO;
        self.reverseAlbums = NO;
    }
    return self;
}

- (void) reloadDataInCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)startBlock ready:(MysticBlockObject)onReady  complete:(MysticBlockObjObjBOOL)finished;
{
    self.assets = [NSMutableArray array];
    __unsafe_unretained __block MysticBlockObjObjBOOL _finished = finished ? Block_copy(finished) : nil;
    __unsafe_unretained __block MysticAlbumDataSource *weakSelf = self;
    [self requestPermissions:^(NSNumber *statusObj, BOOL active) {
        __block NSInteger status = statusObj.integerValue;
        if(!active) { if(_finished) { _finished(weakSelf.items, @(status), NO); Block_release(_finished); } return; }
        
        __block MysticBlockAssetsGroup __groupBlock = Block_copy(^(ALAssetsGroup *group, MysticBlockObjObjBOOL f){
            [group enumerateAssetsWithOptions:self.reversePhotos ? NSEnumerationReverse : 0
                                   usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
             {
                 if(alAsset) { [weakSelf.assets addObject:alAsset]; return; }
                 [weakSelf createItemsFromAssets];
                 if(f) { f(weakSelf.items, @(status), YES); Block_release(f); }
             }];
        });
        
        self.library = [[[ALAssetsLibrary alloc] init] autorelease];
        if(self.album) { __groupBlock(self.album, _finished); Block_release(__groupBlock); return; }
        
        [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
         {
             if(!group) { Block_release(__groupBlock); return; }
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             if ([group numberOfAssets] > 0) __groupBlock(group, _finished);
         }
         failureBlock: ^(NSError *error)
         {
             if(_finished) { _finished(weakSelf.items, @(status), NO); Block_release(_finished); }
             Block_release(__groupBlock);
         }];
    }];
    
}
- (void)requestPermissions:(MysticBlockObjBOOL)block
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusAuthorized: block(@(status), YES); break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus)
             {
                 if (authorizationStatus == PHAuthorizationStatusAuthorized) block(@(authorizationStatus), YES);
                 else block(@(authorizationStatus), NO);
             }];
            break;
        }
        default: block(@(status), NO); break;
    }
}
- (void) createItemsFromAssets;
{
    NSMutableArray *itms = [NSMutableArray array];
    int x = 0;
    for (ALAsset *asset in self.assets) {
        MysticAssetCollectionItem *i = [MysticAssetCollectionItem itemWithDictionary:nil indexPath:[NSIndexPath indexPathForRow:x inSection:1]];
        if(!i.enabled) continue;
        i.asset = asset;
        [itms addObject:i];
        x++;
    }

    [self setItems:[NSMutableArray arrayWithArray:@[@{@"items": itms}]]];

}




- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
//    MysticAssetCollectionItem *item = [self itemAtIndexPath:indexPath];
    
    
    if (kind == UICollectionElementKindSectionHeader) {
        if(indexPath.section == 0)
        {
            NSDictionary *sectionInfo = [self sectionAtIndex:indexPath.section];
            if([self sectionIsToolbarAtIndex:indexPath.section])
            {
//                MysticCustomImagePickerController *imagePicker = (id)collectionView.delegate;
                NSArray *theItems = @[];
                
                MysticCollectionViewSectionToolbarHeader *sectionHeaderView;
                sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[MysticCollectionViewSectionToolbarHeader cellIdentifier] forIndexPath:indexPath];
                sectionHeaderView.info = sectionInfo;
                sectionHeaderView.delegate = (id<MysticCollectionToolbarDelegate>) collectionView.delegate;
                sectionHeaderView.items = theItems;
                reusableview = sectionHeaderView;
            }
            
            
        }
        if(!reusableview)
        {
            MysticCollectionViewCellSectionHeader *sectionHeaderView;
            sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[[self class] sectionHeaderCellIdentifier] forIndexPath:indexPath];

            sectionHeaderView.title = /*self.album ? [(NSString *)[self.album valueForProperty:ALAssetsGroupPropertyName] uppercaseString] :*/ @"ALBUMS";
            sectionHeaderView.backgroundColor = [UIColor hex:@"151515"];
            [sectionHeaderView.button addTarget:collectionView.delegate action:@selector(albumsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

            reusableview = sectionHeaderView;
            
        }
        
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        MysticCollectionViewCellSectionHeader *sectionHeaderView;
        sectionHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[[self class] sectionHeaderCellIdentifier] forIndexPath:indexPath];
        reusableview = sectionHeaderView;
    }
    return reusableview;
}

- (void) albums:(MysticBlockObjObjBOOL)block;
{
    self.groups = [NSMutableArray array];
    __unsafe_unretained __block MysticBlockObjObjBOOL _finished = block ? Block_copy(block) : nil;
    __unsafe_unretained __block MysticAlbumDataSource *weakSelf = self;
    
    [self requestPermissions:^(NSNumber *statusObj, BOOL active) {
        __block NSInteger status = statusObj.integerValue;
        if(!active) { if(_finished) { _finished(weakSelf.items, @(status), NO); Block_release(_finished); } return; }
        
        weakSelf.library = [[[ALAssetsLibrary alloc] init] autorelease];
        [weakSelf.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
         {
             if(group)
             {
                 [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                 if ([group numberOfAssets] > 0)
                 {
                     if(!weakSelf.reverseAlbums) [weakSelf.groups insertObject:group atIndex:0];
                     else [weakSelf.groups addObject:group];
                 }
             }
             else if(_finished)
             {
                 _finished(weakSelf.groups, @(status), YES);
                 Block_release(_finished);
             }
         }
         failureBlock: !_finished ? nil : ^(NSError *error)
         {
             _finished(weakSelf.groups, @(status), NO);
             Block_release(_finished);
         }];
    }];
}


@end

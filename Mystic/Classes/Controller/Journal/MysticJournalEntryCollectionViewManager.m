//
//  MysticJournalEntryCollectionViewManager.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalEntryCollectionViewManager.h"
#import "UIImageView+WebCache.h"
#import "MysticJournalEntryCollectionViewCell.h"
#import "MysticJournalEntryCollectionHeaderView.h"



@interface MysticJournalEntryCollectionViewManager()
@property (strong,nonatomic) UINib *cellNib;
@property (strong,nonatomic) UINib *sectionHeaderNib;

@end


@implementation MysticJournalEntryCollectionViewManager


- (void)setCollectionView:(UICollectionView *)collectionView;
{
    
    if(_collectionView)
    {
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
        [_collectionView release], _collectionView=nil;
        
    }
    _collectionView=[collectionView retain];
    if (_collectionView) {
        [self initCollectionView:collectionView];
    }
}

- (void) setJournalEntry:(MysticJournalEntry *)journalEntry;
{
    MysticJournalEntryDataSource *dataStore = [[MysticJournalEntryDataSource alloc] init];
    [dataStore setJournalEntry:journalEntry];
    self.dataSource = dataStore;
    [dataStore release];
}
- (void)initCollectionView:(UICollectionView *)collectionView{
    collectionView.dataSource=self;
    collectionView.delegate=self;
    [self registerCellsForCollectionView:collectionView];
    [self registerSectionHeaderForCollectionView:collectionView];
    [collectionView reloadData];
    
}
#pragma mark - Cells
- (UINib *)cellNib{
    if (!_cellNib) {
        _cellNib = [UINib nibWithNibName:@"MysticJournalEntryCollectionViewCell" bundle:nil];;
    }
    return _cellNib;
}
- (UINib *)sectionHeaderNib{
    if (!_sectionHeaderNib) {
        _sectionHeaderNib = [UINib nibWithNibName:@"MysticJournalEntryCollectionHeaderView" bundle:nil];
    }
    return _sectionHeaderNib;
}
- (void)registerCellsForCollectionView:(UICollectionView *)collectionView{
    [collectionView registerNib:self.cellNib forCellWithReuseIdentifier:@"MysticJournalEntryCollectionViewCell"];
}
- (void)registerSectionHeaderForCollectionView:(UICollectionView *)collectionView{
    [collectionView registerNib:self.sectionHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MysticJournalEntryCollectionHeaderView"];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource numberOfItemsForSection:section];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MysticJournalEntryCollectionViewCell *cell;
    MysticJournalBlock *item = [self.dataSource itemAtIndexPath:indexPath];

    static NSString *cellIdentifier=@"MysticJournalEntryCollectionViewCell";
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    switch (item.type) {
        case MysticJournalBlockTypeImage:
        {
            cell.title = [self.dataSource.parentItem.title uppercaseString];
            [self downloadImageForCell:cell indexPath:indexPath complete:nil];
            break;
        }
        case MysticJournalBlockTypeText:
        {
            cell.text = item.text;

            break;
        }
        default:
            break;
    }
    

    
    
    return cell;
}


- (void) downloadImageForCell:(MysticJournalEntryCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath complete:(void (^)(UIImage *image, NSError *error, SDImageCacheType cacheType))finished;
{
    MysticJournalBlock *item = [self.dataSource itemAtIndexPath:indexPath];
    
    __unsafe_unretained __block MysticJournalCollectionViewCell *weakCell = cell;
    __unsafe_unretained __block MysticJournalEntryCollectionViewManager *weakSelf = self;
    __unsafe_unretained __block NSIndexPath*__indexPath = [indexPath retain];
    [cell.imageView setImageWithURL:item.imageURL placeholderImage:Nil options:SDWebImageLowPriority progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         
     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
         

     }];
}




- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    MysticJournalEntryCollectionHeaderView *sectionHeaderView;
    static NSString *viewIdentifier=@"MysticJournalEntryCollectionHeaderView";
    sectionHeaderView=[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:viewIdentifier forIndexPath:indexPath];
    NSString *sectionHeaderTitle=[NSString stringWithFormat:@"Section %ld",(long)indexPath.section];
    
    sectionHeaderView.titleLabel.text=sectionHeaderTitle;
    sectionHeaderView.titleLabel.textColor=[UIColor whiteColor];
    sectionHeaderView.backgroundColor=[UIColor blackColor];
    
    
    
    return sectionHeaderView;
}
#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    MysticJournalBlock *item = [self.dataSource itemAtIndexPath:indexPath];
    
    switch (item.type) {
        case MysticJournalBlockTypeImage:
        {
            return CGSizeMake(self.collectionView.bounds.size.width, 160);
        }
        case MysticJournalBlockTypeText:
        {
            return CGSizeMake(self.collectionView.bounds.size.width, item.size.height ? item.size.height : 300);
            
        }
        default:
            break;
    }

    return CGSizeMake(self.collectionView.bounds.size.width, 160);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section == 0)
    {
        return CGSizeMake(collectionView.bounds.size.width, 0);
    }
    return CGSizeMake(self.collectionView.bounds.size.width, 60);
}



#pragma mark - Did Select Item

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"did select item at index: section: %ld item: %ld", (long)indexPath.section, (long)indexPath.item);
}




#pragma mark - scroll view delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if(self.scrollViewDelegate)
    {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}
@end



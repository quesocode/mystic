//
//  MysticJournalCollectionView.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionViewManager.h"
#import "MysticJournalCollectionViewCell.h"
#import "MysticJournalCollectionHeaderView.h"
#import "MysticConstants.h"


static NSUInteger const kNumberOfSections = 5;
static NSUInteger const kNumberItemsPerSection = 10;


@interface MysticJournalCollectionViewManager()
@property (strong,nonatomic) UINib *cellNib;
@property (strong,nonatomic) UINib *sectionHeaderNib;
@property (strong, nonatomic) MysticJournalDataSource *dataSource;
@property (strong, nonatomic) NSMutableArray *cellsWithDownloadedImages, *cellsToFadeIn;

@end


@implementation MysticJournalCollectionViewManager

- (id) init;
{
    self = [super init];
    if(self)
    {
        [MysticJournalDataSource clearCache];
        self.shouldAnimate = NO;
        self.dataSource = [[[MysticJournalDataSource alloc] init] autorelease];
        self.cellsWithDownloadedImages = [NSMutableArray array];
    }
    return self;
}
- (void)setCollectionView:(UICollectionView *)collectionView;
{
    [self setCollectionView:collectionView start:nil finish:nil];
}
- (void)setCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;
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
        __unsafe_unretained __block MysticJournalCollectionViewManager *weakSelf = self;
        __unsafe_unretained __block MysticBlockObjObjBOOL __finished = onFinish ? Block_copy(onFinish) : nil;
        [self.dataSource reloadData:onStart complete:^(NSDictionary *items, NSURL *sourceURL, BOOL downloaded) {
            
            [weakSelf.collectionView reloadData];
            if(__finished)
            {
                __finished(items, sourceURL, downloaded);
                Block_release(__finished);
            }
        }];
    }
}
- (void)initCollectionView:(UICollectionView *)collectionView{
    collectionView.dataSource=self;
    collectionView.delegate=self;
    [self registerCellsForCollectionView:collectionView];
    [self registerSectionHeaderForCollectionView:collectionView];
    
}
#pragma mark - Cells
- (UINib *)cellNib{
    if (!_cellNib) {
        _cellNib = [UINib nibWithNibName:@"MysticJournalCollectionViewCell" bundle:nil];;
    }
    return _cellNib;
}
- (UINib *)sectionHeaderNib{
    if (!_sectionHeaderNib) {
        _sectionHeaderNib = [UINib nibWithNibName:@"MysticJournalCollectionHeaderView" bundle:nil];
    }
    return _sectionHeaderNib;
}
- (void)registerCellsForCollectionView:(UICollectionView *)collectionView{
    [collectionView registerNib:self.cellNib forCellWithReuseIdentifier:@"MysticJournalCollectionViewCell"];
}
- (void)registerSectionHeaderForCollectionView:(UICollectionView *)collectionView{
    [collectionView registerNib:self.sectionHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MysticJournalCollectionHeaderView"];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource numberOfItemsForSection:section];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MysticJournalCollectionViewCell *cell;
    
    
    static NSString *cellIdentifier=@"MysticJournalCollectionViewCell";
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    MysticJournalEntry *item = [self.dataSource itemAtIndexPath:indexPath];
    cell.title = [item.title uppercaseString];
//    ALLog(@"cell for item:", @[@"index", [NSString stringWithFormat:@"{%d, %d}", indexPath.section, indexPath.item],
//                               @"visible", MBOOL([[self.collectionView indexPathsForVisibleItems] containsObject:indexPath]),
//                               @"should anim", MBOOL(self.shouldAnimate),
//                               @"has been added", MBOOL(cell.hasBeenAdded),
//                               @"cell should anim", MBOOL(cell.shouldAnimate),
//                               ]);

    [self downloadImageForCell:cell indexPath:indexPath complete:nil];

    return cell;
}


- (void) downloadImageForCell:(MysticJournalCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath complete:(void (^)(UIImage *image, NSError *error, SDImageCacheType cacheType))finished;
{
    MysticJournalEntry *item = [self.dataSource itemAtIndexPath:indexPath];

    __unsafe_unretained __block MysticJournalCollectionViewCell *weakCell = cell;
    __block BOOL shouldFadeIn = self.shouldAnimate && ![self.cellsWithDownloadedImages containsObject:indexPath];
    __unsafe_unretained __block MysticJournalCollectionViewManager *weakSelf = self;
    __unsafe_unretained __block NSIndexPath*__indexPath = [indexPath retain];
    [cell.imageView setImageWithURL:item.imageURL placeholderImage:Nil options:SDWebImageLowPriority progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         
     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
         [weakSelf.cellsWithDownloadedImages addObject:__indexPath];

//         DLog(@"should animate image view: %@", MBOOL(shouldFadeIn));

//         if(shouldFadeIn)
//         {
//             [UIView animateWithDuration:1 animations:^{
//                 weakCell.imageView.alpha = 1;
//             }];
//         }
     }];
}

- (void) fadeInItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger i = [self.collectionView.indexPathsForVisibleItems indexOfObject:indexPath];
    if(i!=NSNotFound)
    {
        MysticJournalCollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndex:i];
        if(cell.imageView.alpha < 1)
        {
            [UIView animateWithDuration:1 animations:^{
                cell.imageView.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    MysticJournalCollectionHeaderView *sectionHeaderView;
    static NSString *viewIdentifier=@"MysticJournalCollectionHeaderView";
    sectionHeaderView=[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:viewIdentifier forIndexPath:indexPath];
    NSString *sectionHeaderTitle=[NSString stringWithFormat:@"Section %ld",(long)indexPath.section];
    if (![self shouldStickHeaderToTopInSection:indexPath.section]) {
        sectionHeaderTitle=[sectionHeaderTitle stringByAppendingString:@" (should not stick to top)"];
    }
    sectionHeaderView.titleLabel.text=sectionHeaderTitle;
    sectionHeaderView.titleLabel.textColor=[UIColor whiteColor];
    sectionHeaderView.backgroundColor=[UIColor blackColor];
    
    
    
    return sectionHeaderView;
}
#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section%2==0) {
        return CGSizeMake(self.collectionView.bounds.size.width, 160);

//        return CGSizeMake((self.collectionView.bounds.size.width/2), 150);
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
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"did select item at index: section: %d item: %d", indexPath.section, indexPath.item);
    
    [self.delegate manager:self collectionView:collectionView didSelectItem:[self.dataSource itemAtIndexPath:indexPath] atIndexPath:indexPath];
    
}



#pragma mark - PDKTStickySectionHeadersCollectionViewLayoutDelegate
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section{
    // Every section multiple of 3 doesn't stick to top
    return NO;
    return (section>0 && section%3==0)?NO:YES;
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
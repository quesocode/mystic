//
//  MysticCollectionViewController.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"
#import "MysticCollectionItem.h"
#import "MysticCollectionViewCell.h"
#import "MysticCollectionViewDataSource.h"
#import "MysticCollectionViewLayout.h"

@interface MysticCollectionViewController : MysticViewController < UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MysticCollectionViewLayoutDelegate>

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) id<UICollectionViewDataSource> dataSource;
@property (nonatomic, assign) CGSize itemSize, itemCenterSize, remainderSize;
@property (nonatomic) CGPoint lastContentOffset;
@property (nonatomic) CGFloat scrollDirectionThreshold, scrollDirectionThresholdChange;
@property (nonatomic, assign) MysticScrollDirection scrollDirection, lastDirection;
@property (nonatomic, readonly) BOOL scrollThresholdMet;
@property (nonatomic, assign) BOOL ignoreScroll;

+ (CGSize) itemSize;
+ (CGFloat) lineSpacing;
+ (CGFloat) itemSpacing;
+ (Class) dataSourceClass;
- (void) initCollectionView:(UICollectionView *)collectionView;
- (void) initCollectionView:(UICollectionView *)collectionView offset:(CGFloat)offsetHeight;
- (void) prepareData:(MysticBlock)preparedBlock;
- (void) reloadCollection;
- (void) refreshCollection;
- (void) refreshCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;
- (void) collectionViewWillRefresh:(UICollectionView *)collectionView;

- (void) collectionViewDidRefresh:(UICollectionView *)collectionView;
- (void)registerCellsForCollectionView:(UICollectionView *)collectionView;
- (void)registerSupplementaryViewsForCollectionView:(UICollectionView *)collectionView;
- (UICollectionView *) createCollectionView;
- (MysticCollectionViewLayout *) createCollectionLayout;

@end

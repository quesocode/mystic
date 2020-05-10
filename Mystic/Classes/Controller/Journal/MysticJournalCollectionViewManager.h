//
//  MysticJournalCollectionView.h
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDKTStickySectionHeadersCollectionViewLayout.h"
#import "MysticConstants.h"
#import "MysticJournalDataSource.h"

@protocol MysticJournalCollectionViewManagerDelegate;

@interface MysticJournalCollectionViewManager : NSObject<UICollectionViewDataSource,UICollectionViewDelegate,PDKTStickySectionHeadersCollectionViewLayoutDelegate>
@property (retain,nonatomic) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) id <UIScrollViewDelegate>scrollViewDelegate;
@property (nonatomic, assign) id <MysticJournalCollectionViewManagerDelegate>delegate;

- (void)setCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;

@end


@protocol MysticJournalCollectionViewManagerDelegate <NSObject>

- (void) manager:(MysticJournalCollectionViewManager *)manager collectionView:(UICollectionView *)collectionView didSelectItem:(MysticJournalEntry *)item  atIndexPath:(NSIndexPath *)indexPath;

@end

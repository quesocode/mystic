//
//  MysticCollectionViewController.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewController.h"
#import "MysticUI.h"
#import "UIColor+Mystic.h"
#import "MysticCollectionView.h"

@interface MysticCollectionViewController ()


@end

@implementation MysticCollectionViewController

+ (CGFloat) lineSpacing;
{
    return 0;
}
+ (CGFloat) itemSpacing;
{
    return 0;
}
+ (CGSize) itemSize;
{
    return CGSizeZero;
}

+ (Class) dataSourceClass;
{
    return [MysticCollectionViewDataSource class];
}


- (void) dealloc;
{
    [_collectionView release];
    [super dealloc];

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _itemSize = [[self class] itemSize];
        _remainderSize = CGSizeZero;
        
    }
    return self;
}
- (MysticCollectionViewLayout *) createCollectionLayout;
{
    MysticCollectionViewLayout *collectionLayout = [[MysticCollectionViewLayout alloc] init];
    return [collectionLayout autorelease];
}
- (UICollectionView *) createCollectionView;
{
    UICollectionViewFlowLayout *collectionLayout = [self createCollectionLayout];
    MysticCollectionView *collectionView = [[MysticCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionLayout];
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    collectionView.backgroundColor = self.view.backgroundColor;

    return [collectionView autorelease];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollDirection = MysticScrollDirectionNone;
    self.scrollDirectionThreshold = 50;
    self.view.backgroundColor = [UIColor color:MysticColorTypeCollectionBackground];
    self.collectionView = [self createCollectionView];
    
    [self loadCollectionView:self.collectionView start:nil finish:nil];
//    [self becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
//    [super scrollViewWillBeginDragging:scrollView];
    self.ignoreScroll = NO;
    self.scrollDirectionThresholdChange = 0;
    self.lastContentOffset = scrollView.contentOffset;
}
- (BOOL) scrollThresholdMet;
{
    return self.scrollDirectionThresholdChange >= self.scrollDirectionThreshold;
}
- (void) prepareData:(MysticBlock)preparedBlock;
{
    if(preparedBlock) preparedBlock();
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)setCollectionView:(UICollectionView *)collectionView;
{
//    [self setCollectionView:collectionView start:nil finish:nil];
    if(_collectionView)
    {
        [_collectionView removeFromSuperview];
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
        [_collectionView release], _collectionView=nil;
        
    }
    _collectionView=[collectionView retain];
    [self.view addSubview:_collectionView];

}

- (void)loadCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;
{
    if (collectionView) {
        
        __unsafe_unretained __block MysticBlockObjBOOL __onStart = onStart ? Block_copy(onStart) : nil;
        __unsafe_unretained __block MysticBlockObjObjBOOL __onFinish = onFinish ? Block_copy(onFinish) : nil;
        __unsafe_unretained __block MysticCollectionViewController *weakSelf = self;
        __unsafe_unretained __block UICollectionView *__collectionView = [collectionView retain];

        [self initCollectionView:collectionView];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [weakSelf refreshCollectionView:__collectionView start:__onStart finish:__onFinish];
            
            if(__onStart) Block_release(__onStart);
            if(__onFinish) Block_release(__onFinish);

            [__collectionView release];

        });
    }
}


- (void) initCollectionView:(UICollectionView *)collectionView;
{
    [self initCollectionView:collectionView offset:0];
}
- (void) initCollectionView:(UICollectionView *)collectionView offset:(CGFloat)offsetHeight;
{
    collectionView.dataSource = self.dataSource;
    collectionView.delegate = self;
    [self registerCellsForCollectionView:collectionView];
    [self registerSupplementaryViewsForCollectionView:collectionView];
    collectionView.contentOffset = CGPointMake(0, offsetHeight);

}

- (void) reloadCollection;
{
    [self.collectionView reloadData];
}

- (void) refreshCollection;
{
    [self refreshCollectionView:self.collectionView start:nil finish:nil];
}

- (void) refreshCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;
{
    
    if (collectionView && collectionView.dataSource) {
        __unsafe_unretained __block UICollectionView *__collectionView = collectionView;
        __unsafe_unretained __block MysticCollectionViewController *weakSelf = self;
        __unsafe_unretained __block MysticBlockObjObjBOOL __finished = onFinish ? Block_copy(onFinish) : nil;
        [weakSelf collectionViewWillRefresh:__collectionView];
        
        MysticCollectionRange collectionRange = MysticCollectionRangeMakeWithCollectionView(collectionView);
        
        [(MysticCollectionViewDataSource *)collectionView.dataSource reloadDataInCollectionView:collectionView start:onStart ready:^(UICollectionView *theCollectionView) {
            dispatch_async(dispatch_get_main_queue(), ^{ [theCollectionView reloadData]; });

        } complete:^(NSDictionary *items, NSURL *sourceURL, BOOL downloaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [__collectionView reloadData];
                [weakSelf collectionViewDidRefresh:__collectionView];
                if(__finished)
                {
                    __finished(items, sourceURL, downloaded);
                    Block_release(__finished);
                }

            });
        }];
    }
}

- (void) collectionViewWillRefresh:(UICollectionView *)collectionView;
{
    
}
- (void) collectionViewDidRefresh:(UICollectionView *)collectionView;
{
    
}


- (void)registerCellsForCollectionView:(UICollectionView *)collectionView
{
    NSString *theId = [[[self class] dataSourceClass] cellIdentifier];
    [collectionView registerClass:[[[self class] dataSourceClass] cellClassForIdentifier:theId] forCellWithReuseIdentifier:theId];
}
- (void)registerSupplementaryViewsForCollectionView:(UICollectionView *)collectionView
{
    
}






#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    

    return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return [[self class] itemSpacing];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return [[self class] lineSpacing];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    return CGSizeMake(self.collectionView.bounds.size.width, 0);
}

- (BOOL) canBecomeFirstResponder; { return YES; }

#pragma mark - Did Select Item


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    
}

#pragma nark - Mystic Collection Layout Delegate

- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section; { return YES; }

- (BOOL)shouldHeaderDragInSection:(NSUInteger)section; { return YES; }

@end

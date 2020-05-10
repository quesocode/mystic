//
//  MysticGridCollectionViewController.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticGridCollectionViewController.h"

@interface MysticGridCollectionViewController ()
@end

@implementation MysticGridCollectionViewController

+ (CGFloat) lineSpacing;
{
    return 0;
}
+ (CGFloat) itemSpacing;
{
    return 0;
}
+ (UIEdgeInsets) gridContentInsets;
{
    //    return UIEdgeInsetsMake(0, 0, 10, 0);
    return UIEdgeInsetsMake([[self class] lineSpacing], [[self class] lineSpacing], [[self class] lineSpacing], [[self class] lineSpacing]);
}
+ (MysticGridSize) gridSize;
{
    return (MysticGridSize){NSNotFound, 4};
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void) viewDidLoad;
{
    [super viewDidLoad];
    self.gridSize = [[self class] gridSize];
    self.collectionView.contentInset = [[self class] gridContentInsets];

}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    //    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(self.hidesBottomBarWhenPushed) [self.navigationController setToolbarHidden:YES animated:NO];
    
}

- (void) setGridSize:(MysticGridSize)gridSize;
{
    _gridSize = gridSize;


    if(CGSizeEqualToSize(self.itemSize, CGSizeZero))
    {
        UIEdgeInsets i = [[self class] gridContentInsets];
        CGFloat itemSpacing = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:0];
        CGFloat itemsSpacingWidth = (itemSpacing * (_gridSize.columns - 1));
        CGFloat insetItemsSpacingWidth = itemsSpacingWidth + i.left + i.right;
        CGFloat bWidth = self.view.frame.size.width - insetItemsSpacingWidth;
        CGFloat rWidth = bWidth;
        
        
        
        CGFloat bHeight = self.view.frame.size.height - i.top - i.bottom - (self.navigationController && !self.navigationController.navigationBarHidden ? self.navigationController.navigationBar.frame.size.height : 0);

        CGFloat dWidth = (rWidth / (CGFloat)_gridSize.columns);
        CGFloat rHeight = _gridSize.rows == NSNotFound ? dWidth : ((bHeight - ([self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:0] * ((CGFloat)_gridSize.rows - 1))) / (CGFloat)_gridSize.rows);
        CGFloat width = floorf(dWidth);
        CGFloat height = floorf(rHeight);
        
        CGFloat remainderWidth = rWidth - (width * _gridSize.columns);
        CGFloat remainderHeight =0;
        
        CGRect rect = CGRectSize(CGSizeMake(width, height));
        CGSize nrect = CGRectIntegral(rect).size;
//        CGSize boundsSize = (CGSize){bWidth,bHeight};

//        CGSize totalSize = (CGSize){rWidth,rHeight};
        self.itemSize = nrect;
        if(remainderWidth > 0)
        {
            CGSize nrect2 = nrect;
            nrect2.width += remainderWidth;
            self.itemCenterSize = nrect2;
            self.remainderSize = CGSizeMake(remainderWidth, remainderHeight);
        }
        
//        ALLog(@"set item size", @[@"grid", [NSString stringWithFormat:@"%2.1f x %2.1f", gridSize.columns, gridSize.rows],
//                                  @"frame", SLogStr(self.view.frame.size),
//                                  @"insets", NSStringFromUIEdgeInsets(i),
//                                  @"item spacing", @(itemSpacing),
//                                  @"item spacing width", @(itemsSpacingWidth),
//                                  @"item spacing + insets", @(insetItemsSpacingWidth),
//                                  @"bounds rect", SLogStr(boundsSize),
//                                  @"total rect", SLogStr(totalSize),
//                                  @"int rect", SLogStr(rect.size),
//                                  @"item size", SLogStr(self.itemSize),
//                                  @"item center size", SLogStr(self.itemCenterSize),
//                                  @"remainder", @(remainderWidth),
//                                  ]);
        
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(!CGSizeEqualToSize(CGSizeZero, self.remainderSize))
    {
//        DLog(@"size for item: %d, %d == %@", indexPath.section, indexPath.row, MBOOL((indexPath.row%(int)self.gridSize.columns==0)));
        if ((indexPath.row%(int)self.gridSize.columns==0)) {
            return self.itemCenterSize;
        }
    }
    return self.itemSize;
}

@end

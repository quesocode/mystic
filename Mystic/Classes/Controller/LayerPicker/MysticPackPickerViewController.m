//
//  MysticPackPickerViewController.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerViewController.h"
#import "MysticPackPickerDataSource.h"
#import "MysticPackPickerDataSourceGrid.h"
#import "MysticNavigationViewController.h"
#import "MysticPackPickerItem.h"
#import "MysticPackPickerGridItem.h"
#import "MysticCollectionViewSectionToolbarHeader.h"
#import "MysticPackPickerGridCell.h"
#import "PulldownMenu.h"

@interface MysticPackPickerViewController () <MysticCollectionToolbarDelegate, PulldownMenuDelegate>
{
    NSMutableDictionary *dataSources;
}

@property (nonatomic, assign) BOOL firstLoad, configWasUpdated, pullDownSetup;
@property (nonatomic, assign) PulldownMenu * pulldownMenu;
@property (nonatomic, retain) UIView *pullOverView;
@property (nonatomic, assign) MysticButton *leftButton, *rightButton;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@end

@implementation MysticPackPickerViewController

+ (Class) dataSourceClass;
{
    return [MysticPackPickerDataSource class];
}

+ (CGFloat) lineSpacing;
{
    return 0;
}
+ (CGFloat) itemSpacing;
{
    return 0;
}

- (void) dealloc;
{
    
    self.indicator = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.pullOverView = nil;
    self.pulldownMenu = nil;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_cancelBlock) Block_release(_cancelBlock);
    if(_selectedBlock) Block_release(_selectedBlock);
    

    [_selectedOption release], _selectedOption = nil;
    [dataSources release], dataSources = nil;
    [_packTypes release], _packTypes = nil;
    [_selectedPack release], _selectedPack=nil;
    [_selectIndexPath release], _selectIndexPath=nil;
    [super dealloc];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layout:(MysticLayoutStyle)layoutStyle types:(NSArray *)theTypes;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configUpdated:) name:@"MysticConfigUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configWillUpdate:) name:@"MysticConfigWillDownloadUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDidUpdate:) name:@"MysticConfigFinishUpdated" object:nil];

        
        
        // Custom initialization
        _layoutStyle = layoutStyle;
        dataSources = [[NSMutableDictionary alloc] init];
        self.packTypes = theTypes;
        self.firstLoad = YES;
        self.layoutStyle = layoutStyle;
        self.configWasUpdated = NO;
        self.pullDownSetup = NO;
        self.shouldTrack = NO;
        self.indicator = nil;
        self.hidesBottomBarWhenPushed = NO;
        self.navigationItem.hidesBackButton = YES;
        [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeBlack;
        [self.navigationController setToolbarHidden:YES animated:NO];
        

    }
    return self;
}
- (void) configWillUpdate:(NSNotification *)notification;
{
    self.pullDownSetup = NO;
    [self.pulldownMenu reload];
    [self showIndicator];
    
}

- (void) configDidUpdate:(NSNotification *)notification;
{
    [self hideIndicator];
    
}

- (void) configUpdated:(NSNotification *)notification;
{
    self.configWasUpdated = YES;
    
    if(!self.firstLoad)
    {
        [self checkConfigUpdate];
    }
}

- (void) checkConfigUpdate;
{
//    ALLog(@"MysticPackPickerViewController: the config was updated", @[@"first", MBOOL(self.firstLoad),
//                                                                       @"did update", MBOOL(self.configWasUpdated),]);
    if(self.configWasUpdated)
    {
        __unsafe_unretained __block MysticPackPickerViewController *weakSelf = self;
        self.configWasUpdated = NO;
//        [NSTimer wait:0.5 block:^{
            [weakSelf refreshCollection];
            
//        }];
    }
}



- (void) prepareData:(MysticBlock)preparedBlock;
{
    if(preparedBlock) preparedBlock();
}



- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    
    __unsafe_unretained __block MysticPackPickerViewController *weakSelf = self;

    CGSize icnSize = (CGSize){30,30};
    CGFloat p = (MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT - icnSize.height)/2;
    

    
    BOOL useBackBtn = [self.navigationController.viewControllers indexOfObject:self] > 1 ? YES : NO;
    UIImage *img = nil;
    if(self.layoutStyle != MysticLayoutStyleList && self.layoutStyle != MysticLayoutStyleListToGrid)
    {
        if(useBackBtn)
        {
            MysticIconType leftIconType = useBackBtn || self.layoutStyle == MysticLayoutStyleGrid ? MysticIconTypeToolLeft :  MysticIconTypeSkinnyMenu;
            img = [MysticImage image:@(leftIconType) size:icnSize color:@(MysticColorTypeCollectionToolbarIcon)];
            MysticBarButton *leftButton = [MysticBarButton buttonWithImage:img action:^(id sender) {
                [weakSelf collectionToolbar:nil didSelect:sender type:MysticToolTypeList];
            }];
            leftButton.hitInsets = UIEdgeInsetsMake(13, 13, 13, 13);
            leftButton.frame = (CGRect){p, p, icnSize.width, icnSize.height};
            self.leftButton = leftButton;
        }
        self.pullOverView = [[[UIView alloc] initWithFrame:CGRectMake(0, MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT)] autorelease];
        self.pullOverView.alpha = 0;
        self.pullOverView.userInteractionEnabled = NO;
        self.pullOverView.backgroundColor = [UIColor hex:@"222221"];
        
        [self.view insertSubview:self.pullOverView aboveSubview:self.collectionView];
        
        
        
        self.pulldownMenu = [[[PulldownMenu alloc] initWithView:self.view] autorelease];
        self.pulldownMenu.handleHeight = MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT;
        self.pulldownMenu.backgroundColor = [UIColor color:MysticColorTypeCollectionToolbarBackground];
        self.pulldownMenu.closeOffset = MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT;
        //    self.pulldownMenu.topMarginLandscape = 50;
        self.pulldownMenu.cellColor = [UIColor color:MysticColorTypeCollectionToolbarBackground];
        self.pulldownMenu.cellSelectedColor = [UIColor color:MysticColorTypePink];
        //    self.pulldownMenu.cellSelectedColor = [UIColor color:MysticColorTypeCollectionSectionHeaderBackground];
        self.pulldownMenu.cellTextColor = [UIColor color:MysticColorTypeCollectionSectionHeaderText];
        self.pulldownMenu.cellFont = [MysticUI gothamLight:15];
        self.pulldownMenu.delegate = self;
         
        
    }
    
    UIImage *img2 = [MysticImage image:@(MysticIconTypeSkinnyX) size:icnSize color:@(MysticColorTypeCollectionToolbarIcon)];
    MysticBarButton *rightButton = [MysticBarButton buttonWithImage:img2 action:^(id sender) {
        [weakSelf collectionToolbar:nil didCancel:sender];
    }];
    rightButton.frame = (CGRect){self.view.frame.size.width - p - icnSize.width, p, icnSize.width, icnSize.height};
    rightButton.hitInsets = UIEdgeInsetsMake(13, 13, 13, 13);
    self.rightButton = rightButton;
    [self.view addSubview:self.rightButton];
    
    if(self.leftButton)
    {
        [self.view addSubview:self.leftButton];
    }
    if(self.pulldownMenu)
    {
        UIView *hView = [[[UIView alloc] initWithFrame:(CGRect){0,0, self.view.frame.size.width , MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT}] autorelease];
        if(useBackBtn && img)
        {
            MysticBarButton *leftButton2 = [MysticBarButton buttonWithImage:img action:^(id sender) {
                //[weakSelf collectionToolbar:nil didSelect:sender type:MysticToolTypeList];
                [weakSelf togglePullDown];
            }];
            leftButton2.hitInsets = UIEdgeInsetsMake(13, 13, 13, 13);

            leftButton2.frame = (CGRect){p, p, icnSize.width, icnSize.height};
            
            //[hView addSubview:leftButton2];
            
            
            
            
        }
        
        MysticBarButton *rightButton2 = [MysticBarButton buttonWithImage:img2 action:^(id sender) {
            //[weakSelf collectionToolbar:nil didCancel:sender];
            [weakSelf togglePullDown];
        }];
        rightButton2.hitInsets = UIEdgeInsetsMake(13, 13, 13, 13);

        rightButton2.frame = (CGRect){self.view.frame.size.width - p - icnSize.width, p, icnSize.width, icnSize.height};
        [hView addSubview:rightButton2];
        
        
        self.pulldownMenu.handleContentView = hView;
        [self.view addSubview:self.pulldownMenu];
        
    }
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    if([self.collectionView indexPathsForSelectedItems].count)
    {
        [self.collectionView deselectItemAtIndexPath:[[self.collectionView indexPathsForSelectedItems] lastObject] animated:YES];
    }
}

- (void) setLayoutStyle:(MysticLayoutStyle)layoutStyle;
{
    [self setLayoutStyle:layoutStyle refresh:NO];
}
- (void) setLayoutStyle:(MysticLayoutStyle)layoutStyle refresh:(BOOL)shouldRefresh;
{
    
    _layoutStyle = layoutStyle;
    self.itemSize = CGSizeZero;
    self.itemCenterSize = CGSizeZero;
    self.remainderSize = CGSizeZero;
    [self setGridSize:[[self class] gridSize]];
    
    if(shouldRefresh)
    {
        [(MysticPackPickerDataSource *)self.dataSource setPackTypes:self.packTypes];
        [self initCollectionView:self.collectionView offset:0];
        [self refreshCollection];
    }
    
}





- (void) setGridSize:(MysticGridSize)gridSize;
{
    switch (self.layoutStyle) {
        case MysticLayoutStyleList:
        case MysticLayoutStyleListToGrid:
            gridSize = (MysticGridSize){5.25, 1};
            break;
        case MysticLayoutStyleGrid:
            gridSize = (MysticGridSize){NSNotFound, 2};
            break;
        default: break;
    }
    [super setGridSize:gridSize];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) titleTouched:(id)sender;
{
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}
- (void) backButtonTouched:(id)sender;
{
    if(self.delegate)
    {
        [self.delegate packPickerDidCancel:(id)self];
    }
}

- (void) layoutStyleButtonTouched:(id)sender;
{
    MysticLayoutStyle newLayout = MysticLayoutStyleUnknown;
    switch (self.layoutStyle) {
        
        case MysticLayoutStyleList:
        case MysticLayoutStyleListToGrid:
        {
            newLayout = MysticLayoutStyleGrid;
            break;
        }
        case MysticLayoutStyleGrid:
        default:
        {
            newLayout = MysticLayoutStyleList;
            break;
        }
    }
    
    [self setLayoutStyle:newLayout refresh:YES];
}

- (UICollectionViewFlowLayout *) createCollectionLayout;
{
    MysticCollectionViewLayout *collectionLayout = [super createCollectionLayout];
    collectionLayout.sectionHeaderTopBorderWidth = 4;
    return collectionLayout;
}

- (id <UICollectionViewDataSource>) dataSource;
{
    NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)_layoutStyle];
    MysticPackPickerDataSource *dataSource = [dataSources objectForKey:dataSourceKey];
    if(!dataSource)
    {
        switch (self.layoutStyle) {
            case MysticLayoutStyleGrid:
                dataSource = (id)[[MysticPackPickerDataSourceGrid alloc] init];
                dataSource.controller = self;
                
                break;
            case MysticLayoutStyleListToGrid:
            case MysticLayoutStyleList:
            {
                
                dataSource = [[MysticPackPickerDataSource alloc] init];
                dataSource.controller = self;

                break;
            }
            
            default: break;
        }
        dataSource.packTypes = self.packTypes;
        dataSource.filters = self.filters;
        if(dataSource) [dataSources setObject:dataSource forKey:dataSourceKey];
        return [dataSource autorelease];
    }
    return dataSource;
}

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView
{
    MysticCollectionViewDataSource *dataSource = self.dataSource;
    Class dataSourceClass = [dataSource class];
    NSString *theId = [dataSourceClass cellIdentifier];
    NSString *blendId = [theId stringByAppendingString:@"Blend"];
    [collectionView registerClass:[dataSourceClass cellClassForIdentifier:theId] forCellWithReuseIdentifier:theId];
    [collectionView registerClass:[dataSourceClass cellClassForIdentifier:blendId] forCellWithReuseIdentifier:blendId];

}

- (void) registerSupplementaryViewsForCollectionView:(UICollectionView *)collectionView;
{
    [collectionView registerClass:[MysticCollectionViewSectionToolbarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[MysticCollectionViewSectionToolbarHeader cellIdentifier]];
    
    switch (self.layoutStyle) {
        case MysticLayoutStyleGrid:
        {
            MysticCollectionViewDataSource *dataSource = self.dataSource;
            Class dataSourceClass = [dataSource class];
            NSString *theId = [dataSourceClass sectionHeaderCellIdentifier];
            [collectionView registerClass:[dataSourceClass cellClassForIdentifier:theId] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:theId];
            break;
        }
            
        default: break;
    }
    

}

- (void) setCollectionView:(UICollectionView *)collectionView;
{
    CGFloat toolBarHeight = [self collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:0].height;
    collectionView.contentOffset = CGPointMake(0, toolBarHeight);

    [super setCollectionView:collectionView];
    collectionView.clipsToBounds = YES;
    collectionView.contentOffset = CGPointMake(0, toolBarHeight);
}

- (void) initCollectionView:(UICollectionView *)collectionView;
{
    [self initCollectionView:collectionView offset:-1];
}

- (void) initCollectionView:(UICollectionView *)collectionView offset:(CGFloat)offsetHeight;
{
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    CGFloat toolBarHeight = offsetHeight < 0 ? [self collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:0].height : offsetHeight;
    [super initCollectionView:collectionView offset:toolBarHeight];

    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if(self.layoutStyle == MysticLayoutStyleList || self.layoutStyle == MysticLayoutStyleListToGrid) return section == 0 ? CGSizeMake(collectionView.frame.size.width, MYSTIC_SECTION_HEADER_HEIGHT) : CGSizeMake(0, 0);
    CGSize s = CGSizeZero;
    s.width = collectionView.frame.size.width;
    switch (section) {
        case 0:
            s.height = MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT;
            break;
        case 1:
            s.height = MYSTIC_SECTION_HEADER_HEIGHT;
            break;
            
        default:
            s.height = MYSTIC_SECTION_HEADER_HEIGHT + [(MysticCollectionViewLayout *) collectionViewLayout sectionHeaderTopBorderWidth];
            break;
    }
    return s;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.layoutStyle == MysticLayoutStyleList || self.layoutStyle == MysticLayoutStyleListToGrid ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 0, section ? 20 : 0, 0);
}

- (void) setPackTypes:(NSArray *)packTypes;
{
    if(_packTypes)
    {
        [_packTypes release];
        _packTypes = nil;
    }
    _packTypes = packTypes ? [packTypes retain] : nil;
    [(MysticPackPickerDataSource *)self.dataSource setPackTypes:packTypes];

}

- (BOOL)shouldHeaderDragInSection:(NSUInteger)section;
{
    return section > 1;
}
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section;
{
    return section != 0;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __unsafe_unretained __block MysticPackPickerViewController *weakSelf = self;
    
    MysticPackPickerGridCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(_cell)
    {
        
        [_cell didDeselect:^(MysticPackPickerGridCell *cell, BOOL success) {

        }];
    }
}

- (void) collectionViewDidSelectHeader:(UIView *)header sender:(id)sender atIndexPath:(NSIndexPath *)indexPath;
{

    switch (self.layoutStyle) {
        case MysticLayoutStyleGrid:
        {
            MysticCollectionViewLayout *collectionLayout = (id)self.collectionView.collectionViewLayout;
            if(header.frame.origin.y == self.collectionView.contentOffset.y || header.frame.origin.y == self.collectionView.contentOffset.y - collectionLayout.sectionHeaderTopBorderWidth)
            {
                if(!self.pullDownSetup)
                {
                    [self setupPullDownMenu];
                }
                [self togglePullDown];
            }
            break;
        }
            
        default: break;
    }
    
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __unsafe_unretained __block MysticPackPickerViewController *weakSelf = self;

    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    MysticPackPickerGridCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(_cell)
    {
        
        [_cell didSelect:^(MysticPackPickerGridCell *cell, BOOL success) {
            
    
            switch (weakSelf.layoutStyle)
            {
                case MysticLayoutStyleGrid:
                {
                    MysticPackPickerGridItem *item = [(MysticCollectionViewDataSource *)weakSelf.collectionView.dataSource itemAtIndexPath:indexPath];
                    if(weakSelf.selectedBlock)
                    {
                        weakSelf.selectedBlock(item.pack, item.option, YES);
                        weakSelf.selectedBlock = nil;
                    }
                    else if(weakSelf.delegate)
                    {
                        [weakSelf.delegate packPicker:weakSelf didSelectPack:item.pack option:item.option];
                    }
                    break;
                }
                case MysticLayoutStyleListToGrid:
                {
                    
                    
                    MysticPackPickerItem *item = [(MysticCollectionViewDataSource *)weakSelf.collectionView.dataSource itemAtIndexPath:indexPath];

                    
                    MysticPackPickerViewController *nextGridController = [[MysticPackPickerViewController alloc] initWithNibName:nil bundle:nil layout:MysticLayoutStyleGrid types:self.packTypes];
                    nextGridController.delegate = self.delegate;
                    nextGridController.selectionType = self.selectionType;
                    nextGridController.selectedBlock = self.selectedBlock;
                    nextGridController.selectedOption = self.selectedOption;
                    nextGridController.selectedPack = item.pack;
                    [self.navigationController pushViewController:nextGridController animated:YES];
                    [nextGridController release];
                    
                    break;
                }
                    
                default:
                {
                    
                    
                    MysticPackPickerItem *item = [(MysticCollectionViewDataSource *)weakSelf.collectionView.dataSource itemAtIndexPath:indexPath];
                    if(weakSelf.selectedBlock)
                    {
                        weakSelf.selectedBlock(item.pack, nil, YES);
                        weakSelf.selectedBlock = nil;
                    }
                    else if(weakSelf.delegate)
                    {
                        [weakSelf.delegate packPicker:weakSelf didSelectPack:item.pack];
                    }
                    break;
                }
            }
            
        }];
    }
    
        
    
    
}

- (void) setFilters:(MysticCollectionFilter)filters;
{
    _filters = filters;
    [(MysticCollectionViewDataSource *)self.dataSource setFilters:filters];
}
#pragma mark - Collection Toolbar Delegate

- (void) collectionToolbar:(MysticCollectionViewSectionToolbarHeader *)toolbar didCancel:(id)sender;
{
    [self backButtonTouched:nil];
}
- (void) collectionToolbar:(MysticCollectionViewSectionToolbar *)toolbar didTouch:(MysticBarButton *)sender type:(MysticToolType)toolType;
{
    BOOL shouldRefresh = NO;
    MysticLayoutStyle newLayout = self.layoutStyle;
    MysticCollectionViewDataSource *dSource = self.dataSource;
    dSource.filters = dSource.filters & ~ MysticCollectionFilterUserRecent;

    switch (toolType)
    {
        case MysticToolTypeCancel:
        {

            [self collectionToolbar:toolbar didCancel:sender];
        
            break;
        }
        case MysticToolTypeList:
        {
//            newLayout = MysticLayoutStyleList;
//            shouldRefresh = self.layoutStyle!=newLayout;
            shouldRefresh = YES;

            break;
        }
        case MysticToolTypeAll:
        {
            newLayout = MysticLayoutStyleGrid;
            shouldRefresh = YES;

//            shouldRefresh = self.layoutStyle!=newLayout;
            break;
        }
        case MysticToolTypeRecents:
        {
            newLayout = MysticLayoutStyleGrid;
            shouldRefresh = YES;
            dSource.filters |= MysticCollectionFilterUserRecent;
            break;
        }
            
        default: break;
    }
    
    [self setLayoutStyle:newLayout refresh:shouldRefresh];
}
- (void) collectionToolbar:(MysticCollectionViewSectionToolbar *)toolbar didSelect:(MysticBarButton *)sender type:(MysticToolType)toolType;
{
    
    switch (toolType)
    {
        case MysticToolTypeCancel:
        {
            
            [self collectionToolbar:toolbar didCancel:sender];
            
            break;
        }
        case MysticToolTypeList:
        {
            if(self.navigationController.viewControllers.count > 2)
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            else  if(self.layoutStyle == MysticLayoutStyleGrid)
            {
                NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                
                MysticPackPickerViewController *nextGridController = [[MysticPackPickerViewController alloc] initWithNibName:nil bundle:nil layout:MysticLayoutStyleListToGrid types:self.packTypes];
                nextGridController.delegate = self.delegate;
                nextGridController.selectionType = self.selectionType;
                nextGridController.selectedBlock = self.selectedBlock;
//                nextGridController.selectedOption = self.selectedOption;
                nextGridController.selectedPack = nil;
                [vcs insertObject:nextGridController atIndex:1];
                [nextGridController release];
                [self.navigationController setViewControllers:vcs animated:NO];
                [self.navigationController popViewControllerAnimated:YES];

                
                
                break;
            }

            break;
        }
        
            
        default: break;
    }

}



- (void) collectionViewDidRefresh:(UICollectionView *)collectionView;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super collectionViewDidRefresh:collectionView];
        
        [self setupPullDownMenu];
        [self checkConfigUpdate];
        
        if(self.firstLoad)
        {
            CGFloat toolBarHeight = [self collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:0].height;
            collectionView.contentOffset = CGPointMake(0, toolBarHeight);
            self.firstLoad = NO;
            
            if(self.selectedOption && [self.dataSource respondsToSelector:@selector(indexPathForOption:)])
            {
                NSIndexPath *selectedPath = [(MysticPackPickerDataSourceGrid *)self.dataSource indexPathForOption:self.selectedOption];
                if(selectedPath)
                {
                    [self.collectionView scrollToItemAtIndexPath:selectedPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                }
            }
            else if(self.selectedPack && [self.dataSource respondsToSelector:@selector(indexPathForPack:)])
            {
                NSIndexPath *selectedPath = [(MysticPackPickerDataSourceGrid *)self.dataSource indexPathForPack:self.selectedPack];

                if(selectedPath)
                {
                    [self menuItemSelected:[NSIndexPath indexPathForItem:selectedPath.section inSection:0] hidePullDown:NO animated:NO];

                }
            }
            
            
        }
    });
}

//- (PulldownMenu *) pulldownMenu;
//{
//    return nil;
//}
- (void) togglePullDown;
{
    
    [self pullDownAnimated:!self.pulldownMenu.fullyOpen change:YES animated:self.pulldownMenu.animationDuration];
    [self.pulldownMenu animateDropDown];
}
- (void) setupPullDownMenu;
{
//    return;
//    if(self.pullDownSetup)
//    {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{

        NSArray *pTypes = [(MysticPackPickerDataSource *)self.dataSource packTypes];
        NSInteger menuSection = 0;
        NSMutableArray *orderedPTypes = [NSMutableArray array];
        for (MysticPack *pack in [(MysticPackPickerDataSourceGrid *)self.dataSource packs] ) {
            if(![orderedPTypes containsObject:@(pack.groupType)])
            {
                [orderedPTypes addObject:@(pack.groupType)];
            }
            
        }
        NSInteger numberOfItems = 0;
        NSInteger numberOfRows = 0;
        
        for (NSNumber *packType in orderedPTypes) {
            
            MysticObjectType groupType = (MysticObjectType)[packType integerValue];
            NSString *titleStr = [MysticObjectTypeTitleParent(groupType, -2) uppercaseString];
            NSRange strRange = NSMakeRange(0, [titleStr length]);
            
            
            NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:NSLocalizedString(titleStr, nil) ];
            [str setCharacterSpacing:3];
            [str setFont:[MysticUI gothamBook:12] range:strRange];
            [str setTextColor:[UIColor color:MysticColorTypeCollectionSectionHeaderText] range:strRange];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentLeft;
            
            [style setLineSpacing:3];
            [str addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:strRange];
            
            [style release];
            NSMutableDictionary *groupInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"title": str, @"header": @YES, @"section": @(menuSection)}];
            NSMutableArray *groupItems = [NSMutableArray array];
            NSInteger numberOfPackItems = 0;
            NSInteger groupRows = numberOfRows;
            for (MysticPack *pack in [(MysticPackPickerDataSourceGrid *)self.dataSource packs] ) {
                
                if(pack.groupType != groupType) continue;
                
                
                NSInteger itemCount = pack.numberOfItems;
                numberOfPackItems += itemCount;
                numberOfItems += itemCount;
                
                NSString *titleStr = [pack.name uppercaseString];
                NSRange strRange = NSMakeRange(0, [titleStr length]);
                
                
                NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:NSLocalizedString(titleStr, nil) ];
                [str setCharacterSpacing:2];
                [str setFont:[MysticUI gothamMedium:13] range:strRange];
                [str setTextColor:[UIColor color:MysticColorTypeCollectionSectionHeaderTextLight] range:strRange];
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.alignment = NSTextAlignmentLeft;
                
                [style setLineSpacing:2];
                [str addAttribute:NSParagraphStyleAttributeName
                            value:style
                            range:strRange];
                
                [style release];
                CGFloat packRows = ((float)ceilf(((float)itemCount)/2.0));
                [groupItems addObject:@{@"title": str,
                                        @"header": @NO,
                                        @"section": @(menuSection),
                                        @"itemCount": @(numberOfItems - itemCount),
                                        @"rows": @(numberOfRows),
                                        @"packRows": @(packRows),
                                        @"textColor": [UIColor color:MysticColorTypeCollectionSectionHeaderTextLight]}];
                numberOfRows += packRows;
                menuSection++;
            }
            [groupInfo setObject:@(groupItems.count) forKey:@"packCount"];
            [groupInfo setObject:@(numberOfItems) forKey:@"itemCount"];
            [groupInfo setObject:@(groupRows) forKey:@"rows"];
            [groupInfo setObject:@(numberOfPackItems) forKey:@"packItemCount"];
            [groupInfo setObject:[UIColor hex:@"50504e"] forKey:@"textColor"];
            
            [self.pulldownMenu insertButton:(id)groupInfo];
            for (NSDictionary *groupItem in groupItems) {
                [self.pulldownMenu insertButton:(id)groupItem];
            }
            
        }
    
    
        self.pullDownSetup = YES;

        [self.pulldownMenu loadMenu];
//
//    });
}


- (void) showIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.color = [UIColor color:MysticColorTypeCollectionToolbarIcon];
    indicator.frame = (CGRect){0, -MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT, self.collectionView.frame.size.width,  MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT};
//    indicator.backgroundColor = [UIColor color:MysticColorTypeCollectionToolbarBackground];
    indicator.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:indicator belowSubview:self.rightButton];
    [indicator startAnimating];
    //    [self.view bringSubviewToFront:indicator];
    self.indicator = indicator;
    [self.collectionView setContentOffset:CGPointMake(0, MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT) animated:YES];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.userInteractionEnabled = NO;
    
    [MysticUIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT);
        self.indicator.frame = (CGRect){0, 0, indicator.frame.size.width, indicator.frame.size.height};
    } completion:^(BOOL finished) {
//        CGRect cf = self.collectionView.frame;
//        cf.size.height -= MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT;
//        self.collectionView.frame = cf;
//        self.collectionView.contentInset = UIEdgeInsetsMake(-MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT, 0, 0, 0);
//        self.collectionView.contentOffset = CGPointZero;
    }];
}

- (void) hideIndicator;
{
    if(self.indicator)
    {

        [MysticUIView animateWithDuration:0.4 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.indicator.frame = (CGRect){0, -self.indicator.frame.size.height, self.indicator.frame.size.width, self.indicator.frame.size.height};
            self.collectionView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            [self.indicator removeFromSuperview];
            self.indicator = nil;
            [self.collectionView setContentOffset:(CGPoint){0, MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT} animated:YES];
            
            if(!self.collectionView.scrollEnabled) self.collectionView.scrollEnabled = YES;
            self.collectionView.userInteractionEnabled = YES;
            
            
        }];
        
    }
}

-(void)menuItemSelected:(NSIndexPath *)indexPath
{
    [self menuItemSelected:indexPath hidePullDown:YES animated:YES];
    
}
-(void)menuItemSelected:(NSIndexPath *)indexPath hidePullDown:(BOOL)forceHide animated:(BOOL)animated;
{
    if(forceHide)
    {
        [self pullDownAnimated:NO change:YES animated:self.pulldownMenu.animationDuration];
        [self.pulldownMenu animateDropDown];
    }
    NSDictionary *section = [self.pulldownMenu sectionAtIndexPath:indexPath];

    NSInteger indexSection = [self.pulldownMenu sectionForItemAtIndexPath:indexPath];
    NSIndexPath *packIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexSection];
    
    CGFloat offsetY = [section[@"rows"] floatValue] * self.itemSize.height;
    offsetY += (56.0f*(float)(indexSection+1)) + (24.0f * (float)indexSection);
//    ALLog(@"menu item selected", @[@"indexPath", MObj(indexPath),
//                                   @"packIndexPath", MObj(packIndexPath),
//                                   @"offset", @(offsetY),
//                                   @"itemSize", SLogStr(self.itemSize),
//                                   @"rows", MObj(section[@"rows"]),
//                                   @"item half", @(ceilf([section[@"itemCount"] floatValue]/2.0)),
//                                   @"section", MObj(section)]);


    [self.collectionView setContentOffset:CGPointMake(0, offsetY) animated:animated];
    
//    [self.pulldownMenu.menuList deselectRowAtIndexPath:indexPath animated:YES];

   
    
}
-(void)pullDownAnimated:(BOOL)open;
{
    [self pullDownAnimated:open change:NO animated:self.pulldownMenu.animationDuration];
}
-(void)pullDownAnimated:(BOOL)open change:(BOOL)changeIt animated:(NSTimeInterval)dur;
{
    BOOL isAnimated = dur > 0;
    if (open)
    {
        if(!self.pullDownSetup)
        {
            [self setupPullDownMenu];
        }
        self.pulldownMenu.hidden = NO;
        self.pulldownMenu.userInteractionEnabled = YES;
        self.pulldownMenu.alpha = 1;
        self.collectionView.scrollEnabled = NO;
        self.collectionView.userInteractionEnabled = NO;
        self.pullOverView.userInteractionEnabled = YES;
        if(changeIt)
        {
            self.pullOverView.alpha = 0;

            MysticBlock animBlock = ^{
                self.pullOverView.alpha = 0.4;
                self.collectionView.alpha = 0.1;
                
            };
            
            if(isAnimated)
            {
                [MysticUIView animateWithDuration:dur animations:animBlock];
            }
            else
            {
                animBlock();
            }
        }

    }
    else
    {
        self.collectionView.scrollEnabled = YES;
        self.collectionView.userInteractionEnabled = YES;
        self.pullOverView.userInteractionEnabled = NO;
        if(changeIt)
        {
            MysticBlock animBlock = ^{
                self.pullOverView.alpha = 0;
                self.collectionView.alpha = 1;

                
            };
            if(isAnimated)
            {
                [MysticUIView animateWithDuration:dur animations:animBlock completion:^(BOOL finished) {
                    self.pulldownMenu.userInteractionEnabled = NO;
                    [MysticUIView animateWithDuration:0.25 animations:^{
                        self.pulldownMenu.alpha = 0;
                    } completion:^(BOOL finished) {
                        //self.pulldownMenu.hidden = YES;

                    }];

                }];
            }
            else
            {
                animBlock();
            }
        }
        else
        {
//            self.pulldownMenu.hidden = YES;
            self.pulldownMenu.userInteractionEnabled = NO;

            [MysticUIView animateWithDuration:0.25 animations:^{
                self.pulldownMenu.alpha = 0;
            } completion:^(BOOL finished) {
                //self.pulldownMenu.hidden = YES;
                
            }];
        }
//        NSLog(@"Pull down menu closed!");
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.layoutStyle == MysticLayoutStyleGrid)
    {
        return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    if(![(MysticPackPickerDataSource *)self.dataSource hasSpecialPack])
    {
        CGSize s = [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];;
        s.height = MYSTIC_LIST_PACK_HEIGHT;
        return s;
    }
    return (CGSize){self.itemSize.width, indexPath.item == 0 && indexPath.section == 1 ? MYSTIC_LIST_SPECIAL_PACK_HEIGHT : MYSTIC_LIST_PACK_HEIGHT};
    
}


@end

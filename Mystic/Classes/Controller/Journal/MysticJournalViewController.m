//
//  MysticJournalViewController.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalViewController.h"
#import "MysticJournalCollectionViewManager.h"
#import "MysticNavigationViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticJournalEntryViewController.h"
#import "MysticView.h"
#import "MysticDrawerNavViewController.h"
//#import "MysticCache.h"

@interface MysticJournalViewController () <MysticJournalCollectionViewManagerDelegate>
{

    NSInteger _prevNabBarStyle;
}
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain,nonatomic) MysticJournalCollectionViewManager *collectionViewManager;
@end

@implementation MysticJournalViewController

- (void) dealloc;
{
    [_collectionView release];
    [_collectionViewManager release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        _collectionViewManager = [[MysticJournalCollectionViewManager alloc]init];
        _collectionViewManager.scrollViewDelegate = self;
        _collectionViewManager.delegate = self;

        MysticView *tView = [[MysticView alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
        tView.stickToPoint = CGPointMake(CGPointUnknown.x, 0);
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = [MYSTIC_JOURNAL_TITLE uppercaseString];
        l.textColor = [UIColor color:MysticColorTypeNavBarText];
        l.font = [MysticUI gothamBold:14];
        l.tag = MysticPositionCenter;
        [tView addSubview:l];
        self.navigationItem.titleView = tView;
        [tView release];
        [l release];
        self.navigationItem.hidesBackButton = YES;
        
        
        CGSize leftBtnIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_LAYERS, MYSTIC_NAVBAR_ICON_HEIGHT_LAYERS);
        MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] target:self sel:@selector(backButtonTouched:)];
        leftBarButton.tag = MysticViewTypeLayers;
        
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] forState:UIControlStateHighlighted];
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] forState:UIControlStateSelected];
        leftBarButton.frame = CGRectMake(0, 0, 53, 60);
        leftBarButton.position = MysticPositionLeft;
        leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        MysticBarButtonItem *barItem = [[MysticBarButtonItem alloc] initWithCustomView:leftBarButton];
        self.navigationItem.leftBarButtonItem = barItem;
        [barItem release];

        [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeNavBar;

    }
    return self;
}


- (void) backButtonTouched:(id)sender;
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self hideNavBar:NO duration:-1 delay:0 complete:^(BOOL active) {
        
    }];
    
    [(MysticDrawerNavViewController *)self.mm_drawerController.leftDrawerViewController loadSection:MysticDrawerSectionMain];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _prevNabBarStyle = [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle;
    self.collectionView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    __unsafe_unretained __block MysticJournalViewController *weakSelf = self;
    [self.collectionViewManager setCollectionView:self.collectionView start:^(id obj, BOOL downloading) {
        
//        if(downloading)
//        {
//            UILabel *label = [(MysticView *)weakSelf.navigationItem.titleView viewWithClass:[UILabel class]];
//            label.text = @"UPDATING...";
//            
//        }
        
    } finish:^(id obj, id obj2, BOOL downloading) {
        if(downloading)
        {
            [NSTimer wait:1 block:^{
                UILabel *label = [(MysticView *)weakSelf.navigationItem.titleView viewWithClass:[UILabel class]];
                label.text = [MYSTIC_JOURNAL_TITLE uppercaseString];
            }];
            
        }
    }];
	// Do any additional setup after loading the view.

}

- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeJournalNavBar;
    [(MysticNavigationBar *)self.navigationController.navigationBar setBorderStyle:NavigationBarBorderStyleNone];
    if(!self.shouldTrack)
    {
        self.shouldTrack = YES;
        [self resetScrollViewTracking];
        if([self shouldScrollViewHideNavBar:self.collectionView])
        {
            
            [self hideNavBar:YES duration:0.1 delay:0 complete:nil];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    self.collectionViewManager.shouldAnimate = YES;
    

}

- (void) viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
//    
//    ALLog(@"will disappear", @[@"contains", MBOOL([self.navigationController.viewControllers containsObject:self]),
//                               @"controllers", self.navigationController.viewControllers]);
    if(![self.navigationController.viewControllers containsObject:self])
    {
        [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = _prevNabBarStyle;
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MysticJournalCollectionViewManager Delegate

- (void) manager:(MysticJournalCollectionViewManager *)manager collectionView:(UICollectionView *)collectionView didSelectItem:(MysticJournalEntry *)item  atIndexPath:(NSIndexPath *)indexPath;
{
//    DLog(@"did select item: #%d Blocks: %d", indexPath.item, item.blocks.count);
    __unsafe_unretained __block MysticJournalViewController *weakSelf = self;
    MysticJournalEntryViewController *controller = [[MysticJournalEntryViewController alloc] initWithNibName:@"MysticJournalEntryViewController" bundle:nil];
    controller.shouldTrack = NO;

    [weakSelf.navigationController pushViewController:controller animated:YES];
    controller.journalEntry = item;
    
    [self hideNavBar:NO track:NO duration:0 delay:0 complete:^(BOOL active)
    {
        [(MysticJournalEntryViewController *)weakSelf.navigationController.visibleViewController setShouldTrack:YES];
    }];
    [controller release];

    
}


@end

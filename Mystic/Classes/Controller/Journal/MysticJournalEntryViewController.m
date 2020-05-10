//
//  MysticJournalEntryViewController.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalEntryViewController.h"
#import "MysticNavigationViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticView.h"



@interface MysticJournalEntryViewController ()
{
    MysticJournalEntry *_item;
}
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation MysticJournalEntryViewController

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
        
        
        _collectionViewManager = [[MysticJournalEntryCollectionViewManager alloc]init];
        _collectionViewManager.scrollViewDelegate = self;
        
        self.navigationItem.hidesBackButton = YES;
        

        CGSize leftBtnIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_LAYERS, MYSTIC_NAVBAR_ICON_HEIGHT_LAYERS);
        MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeBack) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] target:self sel:@selector(backButtonTouched:)];
        leftBarButton.tag = MysticViewTypeLayers;
        
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeBack) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] forState:UIControlStateHighlighted];
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeBack) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] forState:UIControlStateSelected];
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
//    __unsafe_unretained __block MysticJournalEntryViewController *weakSelf = self;
//    [self hideNavBar:NO track:NO duration:-1 delay:0 complete:^(BOOL active) {
//
//    }];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
//    __unsafe_unretained __block MysticJournalEntryViewController *weakSelf = self;
//    [self.collectionViewManager setCollectionView:self.collectionView start:^(id obj, BOOL downloading) {
//        
//        if(downloading)
//        {
//            UILabel *label = [(MysticView *)weakSelf.navigationItem.titleView viewWithClass:[UILabel class]];
//            label.text = @"UPDATING...";
//            
//        }
//        
//    } finish:^(id obj, id obj2, BOOL downloading) {
//        if(downloading)
//        {
//            [NSTimer wait:1 block:^{
//                UILabel *label = [(MysticView *)weakSelf.navigationItem.titleView viewWithClass:[UILabel class]];
//                label.text = [MYSTIC_JOURNAL_TITLE uppercaseString];
//            }];
//            
//        }
//    }];
	// Do any additional setup after loading the view.
    
}

- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor fromHex:@"fffdf3"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
    if(_item)
    {
        [self.collectionViewManager setCollectionView:self.collectionView];
    }
}

- (void) setJournalEntry:(MysticJournalEntry *)journalEntry;
{
    
    [self.collectionViewManager setJournalEntry:journalEntry];
    _item = [journalEntry retain];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
//
//  MysticDrawerMenuViewController.m
//  Mystic
//
//  Created by Me on 2/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDrawerMenuViewController.h"
#import "MysticDrawerViewController.h"
#import "MysticNavigationViewController.h"
#import "MysticGalleryViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticMainMenuViewCell.h"
#import "MysticLayerTableViewCell.h"
#import "NSArray+Mystic.h"
#import "MysticBarButton.h"
#import "MysticEffectsManager.h"
#import "MysticActionSheet.h"
#import "AppDelegate.h"
#import "MysticController.h"
#import "UserPotion.h"
#import "MysticDrawerListViewController.h"
#import "UIScrollView+APParallaxHeader.h"
#import "RFRateMe.h"
#import "UIAlertView+NSCookbook.h"
#import "ABX.h"
#import "MysticStoreViewController.h"

@interface MysticDrawerMenuViewController () <APParallaxViewDelegate>

@end

@implementation MysticDrawerMenuViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}


- (void) commonInit;
{
    [super commonInit];
    self.title = @"";

//    self.title = NSLocalizedString(@"Mystic", nil);
    __unsafe_unretained __block MysticDrawerMenuViewController *weakSelf = self;
    weakSelf.hidesBottomBarWhenPushed = YES;
    MMDrawerController *drawers = (MMDrawerController *)[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;
    MysticNavigationViewController *nav = (MysticNavigationViewController *)drawers.centerViewController;
    if([[nav.viewControllers objectAtIndex:0] isKindOfClass:[MysticController class]] && [nav.visibleViewController isEqual:[nav.viewControllers objectAtIndex:0]])
    {
        
        MysticBarButton *button = (MysticBarButton *)[MysticBarButton button:[MysticImage image:@(MysticIconTypeToolRight) size:CGSizeMake(30, 30) color:@(MysticColorTypeDrawerNavBarButton)] action:^(MysticBarButton *sender) {
            [weakSelf rightNavButtonTouched:sender];
            
            
        }];
        button.contentMode = UIViewContentModeCenter;
        [self.navigationItem setRightBarButtonItem:[MysticBarButtonItem buttonItem:button] animated:NO];
    
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.title = NSLocalizedString(@"MYSTIC", nil);
}

- (void) leftNavButtonTouched:(id)sender;
{
    
}

- (void) rightNavButtonTouched:(id)sender;
{
    MysticDrawerViewController * controller = [[[MysticDrawerViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}
- (void) viewDidLoad;
{
    [super viewDidLoad];
    CGRect viewFrame = CGRectMake(0, 0, MYSTIC_UI_DRAWER_LEFT_WIDTH, self.view.frame.size.height);
    self.view.frame = viewFrame;
    self.tableView.frame = viewFrame;
    
    MysticImage *img = [MysticImage image:@"shape-logo-small-stroke" size:(CGSize){42,42} color:[UIColor hex:@"443939"]];
    [self.tableView addParallaxWithImage:img andHeight:120 andShadow:NO];
    self.tableView.parallaxView.imageView.contentMode = UIViewContentModeCenter;
    self.tableView.parallaxView.delegate = self;
    self.tableView.parallaxView.frame = CGRectMake(0, 0, viewFrame.size.width, 120);
    
    self.view.backgroundColor = [UIColor color:MysticColorTypeDrawerMainBackground];
    self.tableView.backgroundColor = self.view.backgroundColor;
    MysticButton *heart = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeHeart) size:(CGSize){20, 20} color:@(MysticColorTypePink)] target:self sel:@selector(sendLove:)];
    heart.frame = CGRectMake(0, 0, 40, 40);
    heart.center = CGPointMake(self.view.center.x, [MysticUI screen].height - 40);
    heart.hitInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [self.view addSubview:heart];
    
    
//    MysticButton *settingsBtn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeSettings) size:(CGSize){15, 15} color:[UIColor hex:@"605252"]] target:self sel:@selector(openSettings)];
//    settingsBtn.frame = CGRectMake(0, 0, 40, 40);
//    settingsBtn.center = CGPointMake(self.view.center.x - 60, [MysticUI screen].height - 40);
//    settingsBtn.hitInsets = UIEdgeInsetsMake(15, 15, 15, 15);
//    [self.view addSubview:settingsBtn];
    
    
//    MysticButton *tipsBtn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeTips) size:(CGSize){15, 15} color:[UIColor hex:@"605252"]] target:self sel:@selector(openTips)];
//    tipsBtn.frame = CGRectMake(0, 0, 40, 40);
//    tipsBtn.center = CGPointMake(self.view.center.x + 60, [MysticUI screen].height - 40);
//    tipsBtn.hitInsets = UIEdgeInsetsMake(15, 15, 15, 15);
//    [self.view addSubview:tipsBtn];
    
    [self.view setNeedsLayout];
}
- (void) viewWillAppear:(BOOL)animated;
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    CGRect viewFrame = CGRectMake(0, 0, MYSTIC_UI_DRAWER_LEFT_WIDTH, self.view.frame.size.height);
    self.view.frame = viewFrame;
    [self.view setNeedsLayout];
    [self.tableView reloadData];

}

- (void) sendLove:(id)sender;
{
//    DLog(@"love sent");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We Love You Too!!", @"")
                                                        message:[NSString stringWithFormat:@"Wanna spread some love? Take a moment and rate Mystic in the App Store."]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"No thanks", @"")
                                              otherButtonTitles:NSLocalizedString(@"Rate it now", @""),NSLocalizedString(@"Remind me later",@""), nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        switch (buttonIndex) {
            case 0:
                
           
                
                break;
            case 1:
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFRateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MYSTIC_WEB_ADDRESS]];
                
                break;
            case 2:
            {
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"RFStartDate"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RFRemindMeLater"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                break;
            }
        }
    }];
}
- (void)parallaxView:(APParallaxView *)view willChangeFrame:(CGRect)frame;
{
    if([MysticController controller])
    {
        [[MysticController controller] drawerScrolled:self.tableView.contentOffset];
    }
}

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame;
{
    
}
- (void) initData;
{
    
    __unsafe_unretained __block  MysticDrawerMenuViewController *weakSelf = self;
    
    PackPotionOption *option;
   
    
    
    
    
    
    NSMutableArray *theRows = [NSMutableArray array];
    NSDictionary *projectItem = nil;
    MMDrawerController *drawers = (MMDrawerController *)[(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;

    [theRows addObjectsFromArray:@[
                                   @{@"title": @"NEW",
                                     @"CellClass": [MysticMainMenuViewCell class],
                                     @"titleColor": [UIColor color:MysticColorTypePink],
                                     @"titleFont": [MysticFont fontMedium:11],
                                     @"target": weakSelf,
                                     @"action": @"newProject",
                                     @"closeDrawer": @NO,
                                     },
//                                   @{@"title": MYSTIC_JOURNAL_TITLE,
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleFont": [MysticFont fontMedium:11],
//
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"closeDrawer": @NO,
//                                     @"target": weakSelf,
//                                     @"action": @"journal"
//                                     },
                                   
//                                   @{@"title": @"the PEOPLE'S ART",
//                                     @"titleFont": [MysticFont fontMedium:11],
//
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"target": weakSelf,
//                                     @"action": @"peoplesArt",
//                                     @"closeDrawer": @NO,
//
//                                     },
                                   
                                   @{@"title": @"COMMUNITY",
                                     @"titleFont": [MysticFont fontMedium:11],
                                     @"CellClass": [MysticMainMenuViewCell class],
                                     @"titleColor": [UIColor hex:@"efe0d0"],
                                     @"target": weakSelf,
                                     @"action": @"community",
                                     @"closeDrawer": @NO,
                                     },
                                   
//                                   @{@"title": @"TUTORIALS",
//                                     @"titleFont": [MysticFont fontMedium:11],
//                                     
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"target": weakSelf,
//                                     @"action": @"tutorials",
//                                     @"closeDrawer": @NO,
//                                     
//                                     },
                                   
//                                   @{@"title": @"GET MORE ART...",
//                                     @"titleFont": [MysticFont fontMedium:11],
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"target": weakSelf,
//                                     @"action": @"store",
//                                     @"closeDrawer": @NO,
//                                     },
//                                   
                                   
//                                   @{@"title": @"SETTINGS",
//                                     @"titleFont": [MysticFont fontMedium:11],
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"target": weakSelf,
//                                     @"action": @"openSettings",
//                                     @"closeDrawer": @NO,
//                                     },
                                   
//                                   @{@"title": @"HELP",
//                                     @"titleFont": [MysticFont fontMedium:11],
//                                     
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"target": weakSelf,
//                                     @"action": @"openHelp",
//                                     @"closeDrawer": @NO,
//                                     
//                                     },
//
//                                   @{@"title": @"Update",
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"b3aa9c"],
//                                     @"target": weakSelf,
//                                     @"action": @"openBeta",
//                                     @"closeDrawer": @NO,
//                                     
//                                     },
                                   
//                                   @{@"title": @"SYNC",
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"efe0d0"],
//                                     @"titleFont": [MysticFont fontMedium:11],
//
//                                     @"target": weakSelf,
//                                     @"action": @"sync",
//                                     @"closeDrawer": @NO,
//                                     
//                                     },
                                   
//                                   @{@"title": @"SUBMIT BUG",
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"605252"],
//                                     @"titleFont": [MysticFont fontMedium:11],
//                                     
//                                     @"target": weakSelf,
//                                     @"action": @"submitBug",
//                                     @"closeDrawer": @YES,
//                                     
//                                     },
                                   
                                   
//                                   @{@"title": @"Feedback",
//                                     @"CellClass": [MysticMainMenuViewCell class],
//                                     @"titleColor": [UIColor hex:@"b3aa9c"],
//                                     @"target": weakSelf,
//                                     @"action": @"feedback",
//                                     @"closeDrawer": @NO,
//                                     
//                                     },
                                   
                                   ]];
    
    self.sections = @[@{@"rows": theRows}];
}
- (void) sync;
{
    __unsafe_unretained __block  MysticDrawerMenuViewController *weakSelf = self;

    __unsafe_unretained __block  NSIndexPath *s = [[weakSelf.tableView indexPathForSelectedRow] retain];
    if(s)
    {
        UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:s];
        cell.textLabel.text = @"SYNCING...";
    }
    [MysticCache clearAll];

    [[Mystic core] updateConfigUsingForce:YES start:^(BOOL startingDownload) {
        
        if(s)
        {
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:s];
            cell.textLabel.text = @"...";
        }
        
        
        
    } complete:^(BOOL success) {
        
        
        if(s)
        {
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:s];
            cell.textLabel.text = success ? @"Done!" : @"Error";
            
            [NSTimer wait:1 block:^{
                cell.textLabel.text = @"SYNC";
                [s release];
                [weakSelf.tableView deselectRowAtIndexPath:s animated:YES];

            }];
            
        }
        
        
        
        
        
    }];
}
- (void) openBeta;
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://testflightapp.com"]];

}
- (void) feedback;
{
}
- (void) peoplesArt;
{
    [MysticAlert comingSoon];

}
- (void) openSettings;
{
    __unsafe_unretained __block  MysticDrawerMenuViewController *weakSelf = self;

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openSettingsAnimated:YES complete:^{
        
        [weakSelf.tableView deselectRowAtIndexPath:[[weakSelf.tableView indexPathsForSelectedRows] lastObject]  animated:NO];
        
        
    }];
}

- (void) openTips;
{
    
    [ABXFAQsViewController showFromController:[AppDelegate instance].window.rootViewController hideContactButton:YES contactMetaData:nil initialSearch:nil];
    
    
    return;
//    
//    __unsafe_unretained __block  MysticDrawerMenuViewController *weakSelf = self;
//    
//    [MysticAlert comingSoon];
//
//    [weakSelf.tableView deselectRowAtIndexPath:[[weakSelf.tableView indexPathsForSelectedRows] lastObject]  animated:NO];
//        
        
}

- (void) submitBug;
{
    [ABXFeedbackViewController showFromController:[AppDelegate instance].window.rootViewController placeholder:@"Describe the bug you found here..." email:nil metaData:@{ @"Bug Report" : @YES } image:nil];
    
    return;
    
}


- (void) aboutMystic
{
    NSString *url = @"http://mysti.ch/story";
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openLink:url];
}
- (void) inspiration;
{
    [MysticAlert comingSoon];
}
- (void) community;
{
    NSString *userMsg = NSLocalizedString(@"You're about to view a Mystic Gallery in the Instagram app. Do you want to continue?", nil);
    
    [MysticAlert ask:@"Open in Instagram?" message:userMsg yes:^(id object, id o2) {
        [MysticInstagramAPI openTagInInstagram:MYSTIC_API_INSTAGRAM_TAG];

    } no:nil options:nil];

}

- (void) store;
{
//    [MysticAlert comingSoon];
    [[AppDelegate instance] showStore:MysticStoreTypeDefault completion:nil];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    cell.selected = NO;
}

- (void) openHelp;
{
    [MysticAlert comingSoon];
}

- (void) tutorials;
{
    [MysticAlert comingSoon];
}

- (void) newProject;
{
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.mm_drawerController.centerViewController;
    

    
    if([[nav.viewControllers objectAtIndex:0] isKindOfClass:NSClassFromString(@"MysticIntroViewController")])
    {
        if(![nav.visibleViewController isEqual:[nav.viewControllers objectAtIndex:0]])
        {
            [nav popToRootViewControllerAnimated:NO];
            
        }
        [self.mm_drawerController
         closeDrawerAnimated:YES
         completion:^(BOOL finished) {
             if(finished)
             {
                 
             }
         }];
    }
    else
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate newProject];
    }
}
- (void) backToProject;
{
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.mm_drawerController.centerViewController;
    

    [nav popToRootViewControllerAnimated:NO];
    
    [self.mm_drawerController
     closeDrawerAnimated:YES
     completion:^(BOOL finished) {
         if(finished)
         {
             
         }
     }];
}
- (void) journal;
{
    [MysticAlert comingSoon];
    
//    switch ([MysticUser user].appVersion) {
//        case MysticVersionLight:
//        {
//            [MysticAlert notice:@"Coming Soon" message:@"More on this coming real soon..." action:nil options:nil];
//            
//            return;
//        }
//            
//        default:
//            break;
//    }
//    
//    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.mm_drawerController.centerViewController;
//    
//    BOOL popTo = YES;
//    MysticJournalViewController *journalVC = [nav viewControllerOfClass:[MysticJournalViewController class]];
//    if(journalVC == nil)
//    {
//        popTo = NO;
//        journalVC = [[[MysticJournalViewController alloc] initWithNibName:@"MysticJournalViewController" bundle:nil] autorelease];
//    }
//    __unsafe_unretained __block  MysticDrawerMenuViewController *weakSelf = self;
//
//    journalVC.onViewDidAppear = ^(MysticJournalViewController *vc, BOOL animated)
//    {
//        [NSTimer wait:0.1 block:^{
//            
//        
//        [weakSelf.mm_drawerController
//         closeDrawerAnimated:YES
//         completion:^(BOOL finished) {
//             if(finished)
//             {
//                 
//             }
//         }];
//        }];
//    };
//    
//    if(popTo)
//    {
//        [nav popToViewController:journalVC animated:NO];
//        journalVC.onViewDidAppear(journalVC, NO);
//    }
//    else
//    {
//        [nav pushViewController:journalVC animated:NO];
//    }

    
    
}




@end

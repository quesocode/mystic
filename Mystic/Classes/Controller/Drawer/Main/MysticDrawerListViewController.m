//
//  MysticDrawerListViewController.m
//  Mystic
//
//  Created by Me on 12/3/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticDrawerListViewController.h"
#import "AppDelegate.h"
#import "MysticController.h"
#import "MMDrawerController.h"

@interface MysticDrawerListViewController ()

@end

@implementation MysticDrawerListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MysticNavigationViewController *nav = (MysticNavigationViewController *)[(MMDrawerController *)app.window.rootViewController centerViewController];
    if([nav containsViewControllerOfClass:[MysticController class]] && ![nav.visibleViewController isKindOfClass:[MysticController class]])
    {
        [nav popToViewController:[nav viewControllerOfClass:[MysticController class]] animated:NO];
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
}

@end

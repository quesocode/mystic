//
//  MysticPickerRootViewController.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticPickerRootViewController.h"

@interface MysticPickerRootViewController ()

@end

@implementation MysticPickerRootViewController

- (id) init;
{
    self = [super init];
    if(self)
    {
//        self.navigationItem.title = NSLocalizedString(@"Choose", nil);
        self.hidesBottomBarWhenPushed = YES;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}
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
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void) reset;
{
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface MysticAssetPickerViewController ()

@end

@implementation MysticAssetPickerViewController

@end

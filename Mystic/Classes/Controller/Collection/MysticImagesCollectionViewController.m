//
//  MysticImagesCollectionViewController.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticImagesCollectionViewController.h"
#import "MysticNavigationViewController.h"

@interface MysticImagesCollectionViewController ()

@end

@implementation MysticImagesCollectionViewController

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
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (MysticGridSize) gridSize;
{
    return (MysticGridSize){4, 1};
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

    
//    [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeTranslucentNavBar;
//
//    
//    
//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController setToolbarHidden:YES animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

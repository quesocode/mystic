//
//  LaunchScreenViewController.m
//  Mystic
//
//  Created by Me on 11/20/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLaunchScreenViewController.h"

@interface MysticLaunchScreenViewController ()

@end

@implementation MysticLaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
//    self.imageView.image = [UIImage imageNamed:[UIImage_Launch getLaunchImageName]];
//    [self.imageView setImage:[UIImage imageNamed:[UIImage getLaunchImageName]];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_imageView release];
    [super dealloc];
}
@end

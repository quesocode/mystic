//
//  ABXNavigationController.m
//  Realtime
//
//  Created by Stuart Hall on 11/06/2014.
//  Copyright (c) 2014 Stuart Hall. All rights reserved.
//

#import "ABXNavigationController.h"

@interface ABXNavigationController ()

@end

@implementation ABXNavigationController

- (id) initWithRootViewController:(UIViewController *)rootViewController;
{
    self = [super initWithRootViewController:rootViewController];
    if(self)
    {
        self.navigationBar.barTintColor = [UIColor color:MysticColorTypeBackgroundBlack];
        self.navigationBar.tintColor = [UIColor color:MysticColorTypePink];
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = NO;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.barTintColor = [UIColor color:MysticColorTypeBackgroundBlack];
    self.navigationBar.tintColor = [UIColor color:MysticColorTypePink];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end

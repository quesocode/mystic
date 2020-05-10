//
//  MysticDrawerNavViewController.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticDrawerNavViewController.h"
#import "MysticDrawerViewController.h"
#import "MysticDrawerMenuViewController.h"
#import "MysticNavigationToolbar.h"
#import "MysticLayersViewController.h"
#import "MysticController.h"


@interface MysticDrawerNavViewController ()
{
    UIToolbar *t;
}
@end



@implementation MysticDrawerNavViewController
@synthesize rootViewController;

+ (id) mainController;
{
    UIViewController * drawer=nil;
    MysticDrawerNavViewController *drawerNav;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController" owner:nil options:nil] lastObject];
        drawer = [[MysticDrawerViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
    } else {
        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController_iPad" owner:nil options:nil] lastObject];
        drawer = [[MysticDrawerViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];

    }
    drawerNav.viewControllers = [NSArray arrayWithObject:drawer];
    [drawer release];
    return drawerNav;
}

+ (id) mainLayersController;
{
    return [[self class] mainLayersController:nil];
}
+ (id) mainLayersController:(UIViewController *)currentLayersController;
{
    UIViewController * drawer=nil;
//    MysticDrawerNavViewController *drawerNav;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController" owner:nil options:nil] lastObject];
        drawer = [[MysticLayersViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
    } else {
//        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController_iPad" owner:nil options:nil] lastObject];
        drawer = [[MysticLayersViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
        
    }
    return [drawer autorelease];
//    drawerNav.viewControllers = [NSArray arrayWithObject:drawer];
//    [drawer release];
//    return drawerNav;
}


+ (id) mainMenuController;
{
    UIViewController * drawer=nil;
//    MysticDrawerNavViewController *drawerNav;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController" owner:nil options:nil] lastObject];
        drawer = [[MysticDrawerMenuViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
    } else {
//        drawerNav = [[[NSBundle mainBundle] loadNibNamed:@"MysticDrawerNavViewController_iPad" owner:nil options:nil] lastObject];
        drawer = [[MysticDrawerMenuViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
        
    }
    return [drawer autorelease];
//
//    drawerNav.viewControllers = [NSArray arrayWithObject:drawer];
//    [drawer release];
//    return drawerNav;
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
    
    self.view.layer.cornerRadius = 0;
    
	// Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor hex:@"1f1a17"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *) rootViewController;
{
    if(!self.viewControllers.count) return nil;
    return [self.viewControllers objectAtIndex:0];
}
- (void) setRootViewController:(UIViewController *)viewController;
{
    [self setViewControllers:@[viewController]];
}


- (UIViewController *) loadSection:(NSInteger)section;
{
    return [self loadSection:section animated:NO];
}

- (UIViewController *) loadSection:(NSInteger)section animated:(BOOL)animated;
{
    MysticTableViewController * controller = (id)self.visibleViewController;
    
    
    NSArray *controllers;
    
    switch (section) {
        case MysticDrawerSectionLayers:
        {
            if(!controller || ![controller isKindOfClass:[MysticDrawerViewController class]])
            {
                controller = [[[MysticDrawerViewController alloc] initWithNibName:nil bundle:nil] autorelease];
                controllers = @[controller];
            }
            
            
            break;
        }
        case MysticDrawerSectionMain:
        {
            if(!controller || ![controller isKindOfClass:[MysticDrawerMenuViewController class]])
            {
                controller = [[[MysticDrawerMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
                controllers = @[controller];
                
            }
            
            
            break;
        }
        
        default:
            controller = (id)self;
            controllers = self.viewControllers;
            break;
    }
    
    if(![controller isEqual:self])
    {
        self.viewControllers = controller ? @[controller] : @[];
        [self popToRootViewControllerAnimated:animated];
    }
    [controller reload];
    [controller scrollToSection:section animated:animated];
    
    
    return controller;
}


//- (UIToolbar *) toolbar;
//{
//    if(!t)
//    {
//        t = [[MysticNavigationToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-150, self.view.frame.size.width, 50)];
//        t.translucent = NO;
//        t.layer.borderColor = [UIColor red].CGColor;
//        t.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
//        
//        [self.view addSubview:t];
//    }
//    
//    return t;
//}

@end

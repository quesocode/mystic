//
//  NavigationViewController.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MysticNavigationViewController.h"
#import "MysticNavigationToolbar.h"
#import "MysticConstants.h"

@interface MysticNavigationViewController ()
{
    UIToolbar *t;
    BOOL _hideToolBar;
}
@end

@implementation MysticNavigationViewController

@dynamic navigationBar;

+ (id) newNavigation;
{
    return [self newNavigationWithController:nil];
}
+ (id) newNavigationWithController:(UIViewController *)viewController;
{

    
    MysticNavigationViewController *nav;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        
    }
    nav.viewControllers = @[viewController ? viewController : [[[UIViewController alloc] init] autorelease]];
//    nav.view.backgroundColor = [UIColor blueColor];
    return [nav retain];

//
//    nav2 = [[[self class] alloc] initWithRootViewController:viewController ? viewController : [[[UIViewController alloc] init] autorelease]];
//
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//
//        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nav2 options:nil] lastObject];
//        nav.hidesToolbar = YES;
//        
//    } else {
//        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nav2 options:nil] lastObject];
//        nav.hidesToolbar = YES;
//        
//    }
//    [nav2 autorelease];
//    return nav;
}


- (void) dealloc;
{
    if(t) [t release], t=nil;
    [super dealloc];

}

- (void) setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
{
    if(t && hidden)
    {
        [t removeFromSuperview];
        [t release];
        t = nil;
    }
    
    _hideToolBar = hidden;

}
- (id) init;
{
    return [super init];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{

    
    _hidesToolbar = YES;
    return [super initWithCoder:aDecoder];
}

- (void) setHidesToolbar:(BOOL)hidesToolbar;
{
    if(_hidesToolbar != hidesToolbar)
    {
        _hidesToolbar = hidesToolbar;

        if(hidesToolbar && t)
        {
            [t removeFromSuperview];
            [t release];
            t = nil;
        }
        else
        {
            [self.view setNeedsDisplay];
            [self.view setNeedsLayout];
            [self toolbar];
        }
    }
}

//
//
- (UIToolbar *) toolbar;
{
    if(_hidesToolbar)
    {
        UIToolbar *t2 = [super toolbar];
        t2.hidden = YES;
        return t2;
    }
//    if(_hideToolBar) return nil;
    if(!t)
    {
        t = [[MysticNavigationToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-MYSTIC_NAVBAR_HEIGHT, self.view.frame.size.width, MYSTIC_NAVBAR_HEIGHT)];
        t.translucent = NO;
        
        
        [self.view addSubview:t];
    }
    
    return t;
}



@end

//
//  MysticBasicNavigationController.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBasicNavigationController.h"
#import "MysticConstants.h"
#import "MysticNavigationBar.h"
#import "MysticColor.h"

@interface MysticBasicNavigationController ()

@end

@implementation MysticBasicNavigationController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
        
    }
    return self;
}

- (void) setup;
{
    self.wantsFullScreenLayout = YES;

}
- (id) viewControllerOfClass:(Class)vcClass;
{
    for (UIViewController *vc in self.viewControllers) {
        if([vc isKindOfClass:vcClass])
        {
            return vc;
        }
    }
    return nil;
}
- (BOOL) containsViewControllerOfClass:(Class)vcClass;
{
    return [self indexOfViewControllerWithClass:vcClass] != NSNotFound;
}
- (NSInteger) indexOfViewControllerWithClass:(Class)vcClass;
{
    NSInteger foundVc = NSNotFound;
    NSInteger i = 0;
    for (UIViewController *vc in self.viewControllers) {
        if([vc isKindOfClass:vcClass])
        {
            foundVc = i;
            break;
        }
        i++;
    }
    return foundVc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor hex:@"303030"];
    self.view.clipsToBounds = YES;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }

    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)prefersStatusBarHidden; { return YES; }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setNavigationBarHidden:(BOOL)navigationBarHidden;
{
    [super setNavigationBarHidden:navigationBarHidden];
    self.navigationBar.userInteractionEnabled = !navigationBarHidden;

}

-(void) setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
{
    [super setNavigationBarHidden:navigationBarHidden animated:animated];
    self.navigationBar.userInteractionEnabled = !navigationBarHidden;
    
}


- (BOOL) willNavigationBarBeVisible;
{
    MysticNavigationBar *navBar = (id)self.navigationBar;
    return (!navBar.isShowing) || navBar.isHiding ? NO : YES;
}

- (void) hideNavigationBar:(BOOL)hide duration:(NSTimeInterval)duration complete:(MysticBlock)finished;
{
    [self hideNavigationBar:hide duration:duration setHidden:YES complete:finished];
}
- (void) hideNavigationBar:(BOOL)hide duration:(NSTimeInterval)duration setHidden:(BOOL)si complete:(MysticBlock)finished;
{
//    DDLogWarn(@"hideNavigationBar: %@", MBOOL(hide));
    MysticNavigationBar *navBar = (id)self.navigationBar;
    __unsafe_unretained __block MysticBlock _finished = finished ? Block_copy(finished) : nil;
    duration = duration < 0 ? (hide ? MYSTIC_HIDEBARS_DURATION : MYSTIC_SHOWBARS_DURATION) : duration;
    if(hide)
    {
        self.navigationBar.userInteractionEnabled = NO;

        navBar.isHiding = YES;
        navBar.isShowing = NO;
//        if(!self.willNavigationBarBeVisible)
//        {
        
            __unsafe_unretained __block MysticBasicNavigationController *weakSelf = self;
            CGRect nf = weakSelf.navigationBar.frame;
        
        
            nf.origin.y = -nf.size.height;
        
            if(CGRectEqualToRect(nf, weakSelf.navigationBar.frame))
            {
                if(_finished)
                {
                    _finished();
                    Block_release(_finished);
                }
                return;
            }

            [MysticUIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                weakSelf.navigationBar.frame = nf;
            } completion:^(BOOL finishedAnimation) {
                
                if(si) self.navigationBarHidden = YES;
//                navBar.isHiding = NO;
                if(_finished)
                {
                    _finished();
                    Block_release(_finished);
                }
                
            }];
//        }
//        else
//        {
//            if(_finished)
//            {
//                _finished();
//                Block_release(_finished);
//            }
//        }
    }
    else
    {
        self.navigationBar.userInteractionEnabled = YES;

//        if(self.willNavigationBarBeVisible)
//        {
            __unsafe_unretained __block MysticBasicNavigationController *weakSelf = self;
            CGRect nf = weakSelf.navigationBar.frame;
            nf.origin.y = 0;
            navBar.isShowing = YES;
            navBar.isHiding = NO;

        if(CGRectEqualToRect(nf, weakSelf.navigationBar.frame))
        {
            if(_finished)
            {
                _finished();
                Block_release(_finished);
            }
            return;
        }
        
            [MysticUIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.navigationBar.frame = nf;
            } completion:^(BOOL finishedAnimation) {
                
                if(si) self.navigationBarHidden = NO;
                navBar.isShowing = YES;

                if(_finished)
                {
                    _finished();
                    Block_release(_finished);
                }
                
            }];
//        }
//        else
//        {
//            navBar.isHiding = NO;
//            navBar.isShowing = YES;
//            if(_finished)
//            {
//                _finished();
//                Block_release(_finished);
//            }
//        }
    }
}


@end

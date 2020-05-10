//
//  MysticViewController.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"
#import "UIView+Mystic.h"

#define kNavBarHeight                       60
#define kNavBarPosY                         30

#define kNavBarDefaultPosition              CGPointMake(160, 30)
#define kScrollViewBackUpThreshold          30
#define kScrollViewScrollDownThreshold      200

@interface MysticViewController ()
{
    CGFloat _scrollViewContentOffsetYThreshold;
    CGFloat _scrollViewLastContentOffset;
    CGFloat _scrollViewPrevContentOffset;
    NSInteger _prevNabBarStyle;
    BOOL _navBarRevealing;
}
@end

@implementation MysticViewController

- (void) dealloc;
{
    [_closeButton release];
    Block_release(_onViewDidAppear);
    Block_release(_onViewDidDisappear);
    Block_release(_onViewWillAppear);
    Block_release(_onViewWillDisappear);
    [super dealloc];

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _hidesNavBarOnScroll = YES;
        _shouldTrack = YES;
        self.title = @"";
        [self resetScrollViewTracking];
    }
    return self;
}


- (IBAction)closeTouched:(id)sender
{
    if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:^{

        }];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    if(self.onViewWillAppear)
    {
        self.onViewWillAppear(self, animated);
        self.onViewWillAppear = nil;
    }
}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    if(self.onViewDidAppear)
    {
        self.onViewDidAppear(self, animated);
        self.onViewDidAppear = nil;
    }
}

- (void) viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    if(self.onViewDidDisappear)
    {
        self.onViewDidDisappear(self, animated);
        self.onViewDidDisappear = nil;
    }
}

- (void) viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    if(self.onViewWillDisappear)
    {
        self.onViewWillDisappear(self, animated);
        self.onViewWillDisappear = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) resetScrollViewTracking;
{
    _scrollViewContentOffsetYThreshold = kScrollViewScrollDownThreshold;
    _scrollViewLastContentOffset = -1;
}

- (void)scrollViewDidScroll:(UIScrollView*)aScrollView
{
    
//    if(!_hidesNavBarOnScroll || _navBarRevealing || !self.shouldTrack) { return;  _scrollViewPrevContentOffset = aScrollView.contentOffset.y; }
    CALayer *layer = self.navigationController.navigationBar.layer;
    
    CGFloat contentOffsetY = aScrollView.contentOffset.y;
    CGFloat mh = aScrollView.contentSize.height - aScrollView.frame.size.height;
    
    
    if (contentOffsetY > _scrollViewContentOffsetYThreshold) {
        
        if(contentOffsetY < kScrollViewScrollDownThreshold + 70)
        {
            if(layer.position.y < kNavBarPosY)
            {
                layer.position = CGPointMake(layer.position.x,
                                             kNavBarPosY - MIN((contentOffsetY - kScrollViewScrollDownThreshold), kNavBarHeight));
            }
        }
        else
        {
            
            
            if(layer.position.y <= -kNavBarPosY && contentOffsetY < mh)
            {
                if(contentOffsetY < _scrollViewLastContentOffset - kScrollViewBackUpThreshold)
                {
                    if(contentOffsetY < _scrollViewPrevContentOffset)
                    {
                        _navBarRevealing = YES;
                        _scrollViewContentOffsetYThreshold = contentOffsetY + 5;
                        [self hideNavBar:NO track:YES duration:-1 delay:0.05 complete:nil];

                    }
                }
                if(_scrollViewLastContentOffset < 0 || contentOffsetY > _scrollViewLastContentOffset)
                {
                    _scrollViewLastContentOffset = contentOffsetY;
                }
                
            }
            else
            {
                if(contentOffsetY > _scrollViewLastContentOffset + kScrollViewBackUpThreshold && layer.position.y > -kNavBarPosY)
                {
                    if(contentOffsetY > _scrollViewPrevContentOffset)
                    {
                        _navBarRevealing = YES;
                        _scrollViewContentOffsetYThreshold = contentOffsetY + 5;
                        [self hideNavBar:YES track:YES duration:-1 delay:0.05 complete:nil];
                        
                    }
                }
                _scrollViewLastContentOffset = contentOffsetY;
            }
        }
        //        }
        
    }
    else if(contentOffsetY < mh)
    {
        
        _scrollViewContentOffsetYThreshold = kScrollViewScrollDownThreshold;
        layer.position = kNavBarDefaultPosition;  // then don't do any of this fancy scrolling stuff
    }
    
    _scrollViewPrevContentOffset = contentOffsetY;
    
}

- (void) hideNavBar:(BOOL)hide duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)complete;
{
    duration = duration < 0 ? 0.5 : duration;
    delay = delay < 0 ? 0 : delay;
    CALayer *layer = self.navigationController.navigationBar.layer;
    
    if(duration == 0)
    {
        layer.position = CGPointMake(layer.position.x, hide ? -1 * kNavBarDefaultPosition.y : kNavBarDefaultPosition.y);
        if(complete) complete(YES);
        return;
    }
    
    UIViewAnimationOptions theOption = hide ? UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut;
    
    __unsafe_unretained __block MysticBlockBOOL __finished = complete ? Block_copy(complete) : nil;
    [MysticUIView animateWithDuration:0.5 delay:delay options:theOption animations:^{
        layer.position = CGPointMake(layer.position.x, hide ? -1 * kNavBarDefaultPosition.y : kNavBarDefaultPosition.y);
    } completion:^(BOOL finished) {
        
        _navBarRevealing = NO;
        if(__finished)
        {
            __finished(finished);
            Block_release(__finished);
        }
    }];
}
- (void) hideNavBar:(BOOL)hide track:(BOOL)shouldTrack duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)complete;
{
    self.shouldTrack = shouldTrack;
    [self hideNavBar:hide duration:duration delay:delay complete:complete];
}

- (BOOL) shouldScrollViewHideNavBar:(UIScrollView *)aScrollView;
{
    
    CGFloat contentOffsetY = aScrollView.contentOffset.y;
    CGFloat mh = aScrollView.contentSize.height - aScrollView.frame.size.height;
    
    
    if (contentOffsetY > kScrollViewScrollDownThreshold) {
        

            
        return YES;
        
    }
    else if(contentOffsetY < mh)
    {
        
        return NO;
    }
    return NO;
}

@end

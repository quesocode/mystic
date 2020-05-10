//
//  RecipesViewController.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecipesViewController.h"
#import "ShareViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "TitleBarButton.h"
#import "TitleView.h"


@interface RecipesViewController ()
{
    MBProgressHUD *HUD;
    NSUInteger currentPotionIndex;
    TitleBarButton *settingsButton;
    UIImageView *choosePotion;
    BOOL started;
}

@end


@implementation RecipesViewController

@synthesize imageView, photoView, info=_info, imageBackgroundView, photoBackView, bottomBar, imageToolBar, potionInfoLabel, potionNameLabel, pageControl, controlScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil images:(NSArray *)userInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        currentPotionIndex = 0;
        _info = userInfo ? [[NSMutableArray arrayWithArray:userInfo] retain] : nil;
        self.title = @"Choose Potion";
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 50, 36);
        UIImage *backNormal = [UIImage imageNamed:@"button-bg.png"];
        if([backNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6)];
        }
        UIImage *backHighlighted = [UIImage imageNamed:@"button-bg-highlighted.png"];
        if([backHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6)];
        }
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [backButton setBackgroundImage:backNormal forState:UIControlStateNormal];
        [backButton setBackgroundImage:backHighlighted forState:UIControlStateHighlighted];
        [backButton setImage:[UIImage imageNamed:@"camera-highlighted.png"] forState:UIControlStateNormal];
        //[backButton setImage:[UIImage imageNamed:@"camera-highlighted.png"] forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBackButtonBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = customBackButtonBar;
        self.navigationItem.hidesBackButton = YES;
        [customBackButtonBar release];
        UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardButton.frame = CGRectMake(0, 0, 50, 33);
        UIImage *forwardNormal = [UIImage imageNamed:@"forward-normal.png"];
        if([forwardNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14)];
        }
        UIImage *forwardHighlighted = [UIImage imageNamed:@"forward-highlighted.png"];
        if([forwardHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14)];
        }
        [forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
        [forwardButton setBackgroundImage:forwardNormal forState:UIControlStateNormal];
        [forwardButton setBackgroundImage:forwardHighlighted forState:UIControlStateHighlighted];
        [forwardButton setImage:[UIImage imageNamed:@"check-normal.png"] forState:UIControlStateNormal];
        [forwardButton setImage:[UIImage imageNamed:@"check-highlighted.png"] forState:UIControlStateHighlighted];
        [forwardButton addTarget:self action:@selector(forwardButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customForwardButtonBar = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
        self.navigationItem.rightBarButtonItem = customForwardButtonBar;
        [customForwardButtonBar release];
        TitleView *titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 126, 50)];
        
        settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingsButton.frame = CGRectMake(33, 7, 59, 36);
        UIImage *settingsNormal = [UIImage imageNamed:@"button-bg.png"];
        if([settingsNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            settingsNormal = [settingsNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            settingsNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        }
        UIImage *settingsHighlighted = [UIImage imageNamed:@"button-bg-highlighted.png"];
        if([settingsHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            settingsHighlighted = [settingsHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            settingsHighlighted = [settingsHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        }
        [settingsButton setBackgroundImage:settingsNormal forState:UIControlStateNormal];
        [settingsButton setBackgroundImage:settingsHighlighted forState:UIControlStateHighlighted];
        [settingsButton setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        [settingsButton setImage:[UIImage imageNamed:@"edit-settings.png"] forState:UIControlStateNormal];
        //[settingsButton setImage:[UIImage imageNamed:@"settings-highlighted.png"] forState:UIControlStateHighlighted];
        [settingsButton addTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        settingsButton.enabled = NO;
        settingsButton.hidden = YES;
        [titleView addSubview:settingsButton];
        
        choosePotion = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 126, 50)];
        choosePotion.image = [UIImage imageNamed:@"choose-potion.png"];
        [titleView addSubview:choosePotion];
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 314, 314)];
    imgView.backgroundColor = [UIColor blackColor];
    self.imageView = imgView;
    
    if(self.info)
    {
        [UserPotion potion].sourceImage = [[self.info lastObject] objectForKey:@"UIImagePickerControllerOriginalImage"];
        self.info = nil;
    }
    [self.photoView addSubview:self.imageView];
    [imgView release];
    
    [self.pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view from its nib.
    
    
    
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadControls:[Mystic core].packs type:MysticObjectTypePack scrollView:self.controlScrollView sender:nil completed:^(BOOL controlsVisible){
        
    }];
    if([UserPotion potion].finalImage)
    {
        self.imageView.image = [UserPotion potion].finalImage;
    }
    else
    {

        [UserPotion render:self.imageView.bounds.size complete:^(UIImage *image, NSIndexSet *levels, NSIndexSet *cachedLevels) {
            self.imageView.image = image;

            
        }];
    }

}
- (void) viewDidAppear:(BOOL)animated
{
    
}
- (void) viewDidDisappear:(BOOL)animated
{
    self.imageView.image = nil;
    [super removeOptionControls:self.controlScrollView];
}

- (void) reloadImage
{
    started = NO;
    
    [UserPotion render:self.imageView.bounds.size start:^{
        if(HUD)
        {
            [MBProgressHUD hideHUDForView:self.photoView animated:NO];
        }
        HUD = [MBProgressHUD showHUDAddedTo:self.photoView animated:YES];
        started = YES;
    } complete:^(UIImage *image, NSIndexSet *levels, NSIndexSet *cachedLevels) {
        self.imageView.image = image;
        if(started)
        {
            [MBProgressHUD hideHUDForView:self.photoView animated:YES];
        }
    }];
}

- (void) setInfo:(NSMutableArray *)info
{
    if(_info) [_info release], _info=nil;
    _info = [info retain];
    if(self.info)
    {
        [UserPotion potion].sourceImage = [[_info lastObject] objectForKey:@"UIImagePickerControllerOriginalImage"];
        //self.info = nil;
    }
//    [self reloadImage];
}

- (void) pageControlChanged:(id)sender
{
    [self choosePotion:[[[UserPotion potion].pack.potions allValues] objectAtIndex:self.pageControl.currentPage]];
}

- (void) backButtonTouched:(id)sender
{
    [UserPotion reset];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //[self choosePack:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    [appDelegate openCam:nil animated:YES];
}

- (void) forwardButtonTouched:(id)sender
{
    ShareViewController *viewController = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void) settingsButtonTouched:(id)sender
{
    SettingsViewController *viewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
{
    MysticPack *pack = [UserPotion potion].pack;
    if(pack.numberOfPotions > 1)
    {
        if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
        {
            if(currentPotionIndex < pack.numberOfPotions-1)
            {
                [self choosePotion:[[pack.potions allValues] objectAtIndex:currentPotionIndex+1]];
                currentPotionIndex++;
                self.pageControl.currentPage = currentPotionIndex;
            }
        }
        else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight && currentPotionIndex > 0)
        {
            [self choosePotion:[[pack.potions allValues] objectAtIndex:currentPotionIndex-1]];
            currentPotionIndex--;
            self.pageControl.currentPage = currentPotionIndex;
        }
    }
    
}




- (IBAction)infoTouched:(id)sender;
{

    [UIView animateWithDuration:0.15 animations:^{
        self.photoView.layer.transform = CATransform3DMakeRotation(M_PI_2,0.0,1.0,0.0); //flip halfway
    } completion:^(BOOL finished) {
        [self.imageBackgroundView removeFromSuperview];
        // Add your new views here
        [self.photoView addSubview:self.photoBackView];
        [UIView animateWithDuration:0.15 animations:^{
            self.photoView.layer.transform = CATransform3DMakeRotation(M_PI,0.0,0.0,0.0); //finish the flip
        } completion:^(BOOL finished) {
            // Flip completion code here
        }];
    }];
    
}
- (IBAction)closeInfoTouched:(id)sender;
{
    [UIView animateWithDuration:0.15 animations:^{
        self.photoView.layer.transform = CATransform3DMakeRotation(M_PI_2,0.0,1.0,0.0); //flip halfway
    } completion:^(BOOL finished) {
        [self.photoBackView removeFromSuperview];
        // Add your new views here
        [self.photoView addSubview:self.imageBackgroundView];
        [UIView animateWithDuration:0.15 animations:^{
            self.photoView.layer.transform = CATransform3DMakeRotation(M_PI,0.0,0.0,0.0); //finish the flip
        } completion:^(BOOL finished) {
            // Flip completion code here
        }];
    }];
}






#pragma mark - Choose Potion Pack


- (void) choosePack:(MysticPack *)pack;
{
    currentPotionIndex = 0;
    self.pageControl.hidden = pack && pack.numberOfPotions > 1 ? NO : YES;
    self.pageControl.numberOfPages = pack==nil ? 0 : pack.numberOfPotions;
    self.pageControl.currentPage = 0;
    [UserPotion potion].pack = pack;
    [self choosePotion:(pack ? pack.defaultPotion : nil)];
}


#pragma mark - Choose Potion

- (void) choosePotion:(PackPotion *)potion;
{
    settingsButton.enabled = potion ? YES : NO;
    settingsButton.hidden = potion ? NO : YES;
    choosePotion.hidden = !settingsButton.hidden;
    self.potionNameLabel.text = potion ? potion.name : @"";
    self.potionInfoLabel.text = potion ? (potion.desc ? potion.desc : potion.pack.desc) : @"";
    [UserPotion potion].potion = potion;
    [self reloadImage];
}






#pragma mark - EffectControlDelegate methods




- (void) userFinishedEffectControlSelections:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    
    [super userFinishedEffectControlSelections:effectControl effect:effect];
    switch (effect.type) {
        case MysticObjectTypePack:
            [self choosePack:(effectControl.selected ? (MysticPack *)effect : nil)];
            break;
        case MysticObjectTypePotion:
            [self choosePotion:(effectControl.selected ? (PackPotion *)effect : nil)];
            break;
            
        default:
            break;
    }
    
}







#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

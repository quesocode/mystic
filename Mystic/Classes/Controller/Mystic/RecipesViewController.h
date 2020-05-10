//
//  RecipesViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "Mystic.h"
#import "EffectControl.h"
#import "ImageControlsViewController.h"

@interface RecipesViewController : ImageControlsViewController <EffectControlDelegate>

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, retain) IBOutlet UIView *photoView;
@property (nonatomic, retain) IBOutlet UIView *photoBackView;
@property (nonatomic, retain) IBOutlet UIScrollView *controlScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIView *bottomBar;
@property (nonatomic, retain) IBOutlet UIView *imageToolBar;
@property (nonatomic, retain) IBOutlet UIImageView *imageBackgroundView;

@property (nonatomic, retain) IBOutlet UILabel *potionNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *potionInfoLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *info;




- (id)initWithNibName:(NSString *)nibNameOrNil images:(NSArray *)userInfo;


- (IBAction)infoTouched:(id)sender;
- (IBAction)closeInfoTouched:(id)sender;

- (void) choosePack:(MysticPack *)pack;
- (void) choosePotion:(PackPotion *)potion;
- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

@end

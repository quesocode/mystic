//
//  SettingsViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticSlider.h"
#import "GPUImage.h"
#import "Mystic.h"
#import "EffectControl.h"
#import "ImageControlsViewController.h"
#import "BottomToolbar.h"



@interface SettingsViewController : ImageControlsViewController <EffectControlDelegate>

@property (nonatomic, retain) IBOutlet UIView *photoView;
@property (nonatomic, retain) IBOutlet UIImageView *imageBackgroundView;
@property (nonatomic, retain) IBOutlet UIScrollView *controlScrollView;
@property (nonatomic, retain) IBOutlet UIView *bottomBar;
@property (nonatomic, retain) IBOutlet UIView *imageToolBar;
@property (nonatomic, retain) IBOutlet BottomToolbar *sliderView;
@property (nonatomic, retain) IBOutlet BottomToolbar *bottomToolbar;
@property (nonatomic, retain) IBOutlet MysticSlider *slider;
@property (nonatomic, retain) IBOutlet  UIImageView *imageView;


-(IBAction)sliderValueChanged:(UISlider *)sender;
- (void) reloadImage;

@end

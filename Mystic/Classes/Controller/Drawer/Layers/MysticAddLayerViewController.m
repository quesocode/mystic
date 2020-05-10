//
//  MysticAddLayerViewController.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticAddLayerViewController.h"

@interface MysticAddLayerViewController ()

@end

@implementation MysticAddLayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"CHOOSE";
        self.navigationItem.leftBarButtonItem = [MysticUI backButtonItemWithTarget:self action:@selector(back:)];
        self.navigationItem.hidesBackButton = YES;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) back:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) reload;
{
    __unsafe_unretained __block  MysticAddLayerViewController *weakSelf = self;
    
    PackPotionOption *option;
    
    UIColor *titleColor = [UIColor color:MysticColorTypeDrawerText];
    UIColor *iconColor = [UIColor color:MysticColorTypeDrawerIcon];
//    UIColor *indicatorColor = [UIColor color:MysticColorTypeDrawerAccessory];
    
    
    NSArray *commonStuff = @[
                         @{@"title": @"Text",
                           @"image": @"iconMask-text.png",
                           @"color": iconColor,
                           @"titleColor": titleColor,
                           @"closeDrawer": @YES,
                           @"state": @(MysticSettingType),
                           },
                         @{@"title": @"Designs",
                           @"image": @"iconMask-mystic.png",
                           @"color": iconColor,
                           @"titleColor": titleColor,
                           @"closeDrawer": @YES,
                           @"state": @(MysticSettingDesign),
                           },
                         @{@"title": @"Frames",
                           @"image": @"iconMask-frames.png",
                           @"color": iconColor,
                           @"titleColor": titleColor,
                           @"closeDrawer": @YES,
                           @"state": @(MysticSettingFrame),
                           },
                         @{@"title": @"Textures",
                           @"image": @"iconMask-textures.png",
                           @"color": iconColor,
                           @"titleColor": titleColor,
                           @"closeDrawer": @YES,
                           @"state": @(MysticSettingTexture),
                           },
                         @{@"title": @"Lights",
                           @"image": @"iconMask-lights.png",
                           @"color": iconColor,
                           @"titleColor": titleColor,
                           @"closeDrawer": @YES,
                           @"state": @(MysticSettingLighting),
                           },
                         
                         
                         ];
    
    NSArray *specialStuff = @[
                              @{@"title": @"Writing",
                                @"image": @"iconMask-writeOnCam.png",
                                @"color": iconColor,
                                @"titleColor": titleColor,
                                @"closeDrawer": @YES,
                                @"state": @(MysticSettingCamLayer),
                                },
                             @{@"title": @"Symbols",
                               @"image": @"iconMask-triangleShare.png",
                               @"color": iconColor,
                               @"titleColor": titleColor,
                               @"closeDrawer": @YES,
                               @"state": @(MysticSettingBadge),
                               @"pack": @"symbols"

                               },
                             @{@"title": @"Marks",
                               @"image": @"iconMask-marks.png",
                               @"color": iconColor,
                               @"titleColor": titleColor,
                               @"closeDrawer": @YES,
                               @"state": @(MysticSettingBadge),
                               @"pack": @"explore"

                               },
                              @{@"title": @"Borders",
                                @"image": @"iconMask-borders.png",
                                @"color": iconColor,
                                @"titleColor": titleColor,
                                @"closeDrawer": @YES,
                                @"state": @(MysticSettingBadge),
                                @"pack": @"borders"
                                },
                              @{@"title": @"Custom",
                                @"image": @"iconMask-camEye.png",
                                @"color": iconColor,
                                @"titleColor": titleColor,
                                @"closeDrawer": @YES,
                                @"state": @(MysticSettingCamLayer),
                                },
                             
                             
                             
                             
                             ];
    
    
    
    
    
    
    self.sections = @[
                      @{@"title": @"Photo Art",
                        @"rows": commonStuff,
                        },
                      @{@"title": @"Special Ingredients",
                        @"rows": specialStuff,
                        },
                      ];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60.f;
}

@end

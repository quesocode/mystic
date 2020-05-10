//
//  LaunchedViewController.h
//  Mystic
//
//  Created by Me on 11/20/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticLaunchedViewController : UIViewController
@property (nonatomic, retain) UIImageView *defaultImageView;




- (void) dismissDefaultImage:(MysticBlockAnimationComplete)finished;

- (UIImage*)defaultImageForOrientation:(UIDeviceOrientation) orientation resultingOrientation:(UIDeviceOrientation *)imageOrientation idiom:(UIUserInterfaceIdiom*) imageIdiom;

-(void)rotateDefaultImageViewToOrientation: (UIInterfaceOrientation)newOrientation;

@end

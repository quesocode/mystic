//
//  OrientationViewController.m
//  Brushes
//
//  Created by Travis A. Weerts on 4/20/16.
//  Copyright © 2016 Taptrix, Inc. All rights reserved.
//

#import "OrientationViewController.h"

@implementation OrientationViewController

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
{
    if(size.height > size.width) self.orientation = UIInterfaceOrientationPortrait;
    else self.orientation = UIInterfaceOrientationLandscapeLeft;
    self.orientationSize = size;
}

@end

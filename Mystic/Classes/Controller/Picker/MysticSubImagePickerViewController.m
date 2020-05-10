//
//  MysticSubImagePickerViewController.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSubImagePickerViewController.h"

@interface MysticSubImagePickerViewController ()

@end

@implementation MysticSubImagePickerViewController

- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    switch (self.sourceType) {
        case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
            break;
            
        default: break;
    }
}

- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    switch (self.sourceType) {
        case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
            break;
            
        default: break;
    }
}


@end

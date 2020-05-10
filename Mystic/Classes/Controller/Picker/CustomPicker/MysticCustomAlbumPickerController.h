//
//  MysticCustomAlbumPickerController.h
//  Mystic
//
//  Created by Me on 5/2/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"

@interface MysticCustomAlbumPickerController : MysticViewController

@property (nonatomic, assign) id<UIImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, assign) BOOL allowsEditing;

@end

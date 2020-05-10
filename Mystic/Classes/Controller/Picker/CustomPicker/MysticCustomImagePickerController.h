//
//  MysticCustomImagePickerController.h
//  Mystic
//
//  Created by Me on 5/2/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticGridCollectionViewController.h"

@interface MysticCustomImagePickerController : MysticGridCollectionViewController

@property (nonatomic, assign) id<UIImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) MysticBackgroundType backgroundType;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, assign) BOOL allowsEditing;
@property (nonatomic, retain) ALAssetsGroup *album;
@end

//
//  MysticImagePickerControllerViewController.h
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "ZCImagePickerController.h"
#import "ZCAssetTablePicker.h"
#import "ZCAlbumPickerController.h"

@class MysticImagePickerViewController;

@protocol MysticImagePickerControllerDelegate <ZCImagePickerControllerDelegate>

@optional
- (void)mysticImagePickerController:(MysticImagePickerViewController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)mysticImagePickerControllerDidCancel:(MysticImagePickerViewController *)imagePickerController;

@end


@interface MysticImagePickerViewController : ZCImagePickerController <ZCImagePickerControllerDelegate>

@end



@interface MysticAssetTablePicker : ZCAssetTablePicker

@end

@interface MysticAlbumPickerController : ZCAlbumPickerController

@end

//
//  MysticImagePickerControllerViewController.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticImagePickerViewController.h"

@interface MysticImagePickerViewController ()
{
    id<MysticImagePickerControllerDelegate> __customDelegate;
}
@end

@implementation MysticImagePickerViewController

- (void) setImagePickerDelegate:(id<ZCImagePickerControllerDelegate>)imagePickerDelegate;
{
    [super setImagePickerDelegate:self];
    __customDelegate = (id<MysticImagePickerControllerDelegate>)imagePickerDelegate;
}
- (void)zcImagePickerController:(ZCImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info;
{
    if(__customDelegate && [__customDelegate respondsToSelector:@selector(mysticImagePickerController:didFinishPickingMediaWithInfo:)])
    {
        [__customDelegate mysticImagePickerController:self didFinishPickingMediaWithInfo:info];
    }
}
- (void)zcImagePickerControllerDidCancel:(ZCImagePickerController *)imagePickerController;
{
    if(__customDelegate && [__customDelegate respondsToSelector:@selector(mysticImagePickerControllerDidCancel:)])
    {
        [__customDelegate mysticImagePickerControllerDidCancel:self];
    }
}

@end

@implementation MysticAssetTablePicker


@end


@implementation MysticAlbumPickerController


@end
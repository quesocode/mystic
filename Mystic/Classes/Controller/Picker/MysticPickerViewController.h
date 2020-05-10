//
//  MysticPickerViewController.h
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticCameraControlsView.h"
#import "MysticNavigationViewController.h"
#import "PECropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MysticPickerRootViewController.h"
#import "MysticSubImagePickerViewController.h"
#import "Mystic-Swift.h"


@class MysticPickerViewController;

@protocol MysticPickerViewControllerDelegate <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@optional
- (void)mysticImagePickerController:(MysticPickerViewController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)mysticImagePickerControllerDidCancel:(MysticPickerViewController *)imagePickerController;
- (void) imagePickerController: (UIImagePickerController *) picker
         didFinishPickingAlbum: (ALAssetsGroup *) group;
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo finished:(MysticBlockObject)finishedBlock;

@end


@interface MysticPickerViewController : MysticNavigationViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MysticCameraControlsDelegate, MysticPickerViewControllerDelegate>
@property (nonatomic, readonly) BOOL hasCameraInStack;
@property (nonatomic, assign) BOOL allowsEditing;
@property (nonatomic, assign) MysticPickerSourceType sourceType;
@property (nonatomic, assign) MysticPickerSourceType currentSourceType, lastSourceType;
@property (nonatomic, assign) SEL didFinishSelector;
@property (nonatomic, assign) id<MysticPickerViewControllerDelegate>delegate;
@property (nonatomic, assign) id<MysticPickerViewControllerDelegate>imagePickerDelegate;
@property (nonatomic, retain) UIImagePickerController *imagePicker;

- (id) initWithNibName:(NSString *)nibNameOrNil sourceType:(MysticPickerSourceType)startSourceType delegate:(id)newDelegate;
- (UIViewController *) controllerForSource:(MysticPickerSourceType)sourceType;
- (void) setup;
- (void) setupWithSource:(MysticPickerSourceType)sourceType;

- (UIViewController *) present:(MysticPickerSourceType)sourceType animated:(BOOL)animated finished:(MysticBlock)finished;
- (UIViewController *) present:(MysticPickerSourceType)sourceType viewController:(UIViewController *)viewController animated:(BOOL)animated finished:(MysticBlock)finished;

- (MysticPickerSourceType) controllerTypeForSourceType:(MysticPickerSourceType)asourceType;
- (void) viewDidPresent:(BOOL)animated;
- (void) finished;

@end

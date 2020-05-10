//
//  PECropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PECropViewController : UIViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSDictionary *media;

@property (nonatomic) BOOL keepingCropAspectRatio, fromCamera;
@property (nonatomic) CGFloat cropAspectRatio;

@property (nonatomic) CGRect cropRect;

- (id) initFromCamera:(BOOL)isFromCam;
- (void)cancel:(id)sender;
- (void)done:(id)sender;
@end

@protocol PECropViewControllerDelegate <NSObject>

@optional
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage info:(NSDictionary *)info;

- (void)cropViewControllerDidCancel:(PECropViewController *)controller;

@end

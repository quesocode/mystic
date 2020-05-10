//
//  MysticCameraControlsView.h
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "DDExpandableButton.h"

@class MysticCameraControlsView;

@protocol MysticCameraControlsDelegate <NSObject>

@optional
- (void) cameraControlsWantsToChooseFromLibrary:(MysticCameraControlsView *)cameraControls;
- (void) cameraControlsTakePhoto:(MysticCameraControlsView *)cameraControls;
- (void) cameraControlsToggleFlash:(MysticCameraControlsView *)cameraControls flashMode:(UIImagePickerControllerCameraFlashMode)flashMode;
- (void) cameraControlsWantsToPastePhoto:(MysticCameraControlsView *)cameraControls;
- (void) cameraControlsToggleDevice:(MysticCameraControlsView *)cameraControls device:(UIImagePickerControllerCameraDevice)device;
- (void) cameraControlsDidAppear:(MysticCameraControlsView *)cameraControls;

@end


@interface MysticCameraControlsView : UIView

@property (nonatomic, retain) DDExpandableButton *flashButton, *deviceButton;
@property (nonatomic, retain) UIButton *shutterButton, *albumButton, *pasteButton, *infoButton;
@property (nonatomic, assign) UIView *blackoutView;
@property (nonatomic, retain) UIView *bottomPanelView;
@property (nonatomic, retain) UIImageView *pasteImageView, *albumImageView, *infoImageView;
@property (nonatomic, assign) id<MysticCameraControlsDelegate>delegate;
- (void) addBlackoutView:(UIView *)blackoutView;

- (void) finishedCapture;
@end

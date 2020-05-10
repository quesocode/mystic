//
//  MysticCameraControlsView.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticCameraControlsView.h"
#import "UIView+Mystic.h"

#import "RTSpinKitView.h"
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <Photos/Photos.h>

#else
//#error Your SDK is too old for Photos Framework! Need at least 8.0.
#endif
@interface MysticCameraControlsView ()
{
    ALAssetsGroup *albumGroup;
}

@end
@implementation MysticCameraControlsView

@synthesize bottomPanelView, shutterButton, albumButton, pasteButton, infoButton;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        self.autoresizesSubviews = NO;

        // Initialization code
        CGRect bottomPanelFrame = CGRectMake(0, frame.size.height - (MYSTIC_CAM_CONTROLS_BOTTOM_BAR_HEIGHT), frame.size.width, MYSTIC_CAM_CONTROLS_BOTTOM_BAR_HEIGHT);
        
        self.bottomPanelView = [[UIView alloc] initWithFrame:bottomPanelFrame];
        self.bottomPanelView.backgroundColor = [UIColor color:MysticColorTypeBackgroundCameraControls];
        
        CGSize photoControlSize = CGSizeZero;
        photoControlSize.height = bottomPanelFrame.size.height - MYSTIC_CAM_CONTROLS_PADDING*2;
        photoControlSize.width = photoControlSize.height + 6;
        
        CGRect shutterFrame = CGRectMake(self.bottomPanelView.frame.size.width/2 - MYSTIC_CAM_CONTROLS_SHUTTER_HEIGHT/2, self.bottomPanelView.frame.size.height/2 - MYSTIC_CAM_CONTROLS_SHUTTER_HEIGHT/2, MYSTIC_CAM_CONTROLS_SHUTTER_HEIGHT, MYSTIC_CAM_CONTROLS_SHUTTER_HEIGHT);
        self.shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shutterButton.frame = shutterFrame;
        [self.shutterButton setImage:[MysticImage image:@(MysticIconTypeShutter) size:(CGSize){40,40} color:@(MysticColorTypeShutter)] forState:UIControlStateNormal];
        [self.shutterButton setImage:[MysticImage image:@(MysticIconTypeShutter) size:(CGSize){40,40} color:@(MysticColorTypeShutterHighlighted)] forState:UIControlStateHighlighted];
        [self.shutterButton setImage:[MysticImage image:@(MysticIconTypeShutter) size:(CGSize){40,40} color:@(MysticColorTypeShutterDisabled)] forState:UIControlStateDisabled];
        [self.shutterButton addTarget:self action:@selector(shutterTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGRect albumFrame = CGRectMake(self.bottomPanelView.frame.size.width - photoControlSize.width - MYSTIC_CAM_CONTROLS_PADDING, MYSTIC_CAM_CONTROLS_PADDING, photoControlSize.width, photoControlSize.height);
        self.albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.albumButton setImage:[MysticImage image:@(MysticIconTypeLibrary) size:(CGSize){25,25} color:@(MysticColorTypeLibrary)] forState:UIControlStateNormal];
        [self.albumButton setImage:[MysticImage image:@(MysticIconTypeLibrary) size:(CGSize){25,25} color:@(MysticColorTypeLibraryHighlighted)] forState:UIControlStateHighlighted];

        self.albumButton.frame = albumFrame;
        self.albumButton.alpha = 1.0f;
        self.albumButton.layer.cornerRadius = MYSTIC_CAM_CONTROLS_RADIUS;
//        self.albumButton.titleLabel.font = [MysticUI gothamBold:MYSTIC_CAM_CONTROLS_BUTTON_FONTSIZE];
//        self.albumButton.backgroundColor = [[self.bottomPanelView.backgroundColor lighter:0.2] colorWithAlphaComponent:MYSTIC_CAM_CONTROLS_BUTTON_ALPHA];
        [self.albumButton addTarget:self action:@selector(albumTouched:) forControlEvents:UIControlEventTouchUpInside];

        
        CGRect pasteFrame = albumFrame;
        pasteFrame.origin.x  = albumFrame.origin.x - pasteFrame.size.width - MYSTIC_CAM_CONTROLS_RADIUS;
        self.pasteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.pasteButton.frame = pasteFrame;
        self.pasteButton.alpha = 0.0f;
        self.pasteButton.layer.cornerRadius = MYSTIC_CAM_CONTROLS_RADIUS;
        self.pasteButton.titleLabel.font = self.albumButton.titleLabel.font;
//        self.pasteButton.backgroundColor = self.albumButton.backgroundColor;
        [self.pasteButton addTarget:self action:@selector(pasteTouched:) forControlEvents:UIControlEventTouchUpInside];

        CGRect infoFrame = CGRectMake(MYSTIC_CAM_CONTROLS_PADDING, MYSTIC_CAM_CONTROLS_PADDING, photoControlSize.width, photoControlSize.height);
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.infoButton.frame = infoFrame;
        self.infoButton.alpha = 1.0f;
        self.infoButton.layer.cornerRadius = MYSTIC_CAM_CONTROLS_RADIUS;
        self.infoButton.titleLabel.font = self.albumButton.titleLabel.font;
//        self.infoButton.backgroundColor = self.albumButton.backgroundColor;
        [self.infoButton addTarget:self action:@selector(infoTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoButton setImage:[MysticImage image:@(MysticIconTypeCameraInfo) size:(CGSize){25,25} color:@(MysticColorTypeCameraInfo)] forState:UIControlStateNormal];
        [self.infoButton setImage:[MysticImage image:@(MysticIconTypeCameraInfo) size:(CGSize){25,25} color:@(MysticColorTypeCameraInfoHighlighted)] forState:UIControlStateHighlighted];
        
        DDExpandableButton *torchModeButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(10.0f, 10.0f)
                                                                               leftTitle:[UIImage imageNamed:@"Flash-default.png"]
                                                                                 buttons:[NSArray arrayWithObjects:@"Auto", @"On", @"Off", nil]];
        [torchModeButton addTarget:self action:@selector(toggleFlashlight:) forControlEvents:UIControlEventValueChanged];
        [torchModeButton setVerticalPadding:MYSTIC_CAM_CONTROLS_EXPANDABLE_BUTTON_VERT_PADDING];
        [torchModeButton updateDisplay];
        [torchModeButton setSelectedItem:0];
        self.flashButton = torchModeButton;
        torchModeButton = nil;
        
        UIImage *camSwitch = [UIImage imageNamed:@"camera-switch-black.png"];
        DDExpandableButton *deviceModeButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(frame.size.width - 90.0f, 10.0f)
                                                                              leftTitle:nil
                                                                                buttons:[NSArray arrayWithObjects:camSwitch,camSwitch, nil]];
        [deviceModeButton addTarget:self action:@selector(toggleDevice:) forControlEvents:UIControlEventValueChanged];
        [deviceModeButton setVerticalPadding:MYSTIC_CAM_CONTROLS_EXPANDABLE_BUTTON_VERT_PADDING];
        [deviceModeButton updateDisplay];
        [deviceModeButton setSelectedItem:0];
        [deviceModeButton setToggleMode:YES];

        self.deviceButton = deviceModeButton;
        torchModeButton = nil;
        
        [self addSubview:self.deviceButton];
        [self addSubview:self.flashButton];
        
        
        
        
        [self.bottomPanelView addSubview:self.shutterButton];
        [self.bottomPanelView addSubview:self.albumButton];
        [self.bottomPanelView addSubview:self.infoButton];

        
        self.pasteImageView = [[UIImageView alloc] initWithFrame:self.pasteButton.frame];
        self.pasteImageView.userInteractionEnabled = NO;
        self.pasteImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.pasteImageView.layer.cornerRadius = MYSTIC_CAM_CONTROLS_RADIUS;
        self.pasteImageView.clipsToBounds = YES;
        [self.bottomPanelView insertSubview:self.pasteImageView belowSubview:self.pasteButton];
        

        
        [self addSubview:self.bottomPanelView];
        
        [NSTimer wait:0.25 block:^{
            [self setupInfoBtn];
            [self setupPastePhoto];
            if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsDidAppear:)]) [self.delegate cameraControlsDidAppear:self];
        }];
        
    }
    return self;
}

- (void) setupAlbumPhoto
{
    self.albumImageView.alpha = 0.0;

    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if(status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted)
    {
        DLog(@"User not allowed to use albums");
        return;
    }
    __unsafe_unretained __block MysticCameraControlsView* weakSelf = self;
    [MysticLibrary fetchLastCameraRollAsset:^(id object, id collectionOrGroup, id fetchOptions) {

        if([object isKindOfClass:[ALAsset class]] && collectionOrGroup)
        {
            [weakSelf performSelectorOnMainThread:@selector(loadAlbumImage:) withObject:[UIImage imageWithCGImage:[(ALAssetsGroup *)collectionOrGroup posterImage]] waitUntilDone:YES];

        }
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

        else if(usingIOS8() && [object isKindOfClass:NSClassFromString(@"PHAsset")])
        {
            PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
            requestOptions.version = PHImageRequestOptionsVersionCurrent;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            
            [[PHImageManager defaultManager] requestImageForAsset:object targetSize:weakSelf.albumImageView.frame.size contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                if(result)
                {
                    [weakSelf loadAlbumImage:result];
                }
            }];
        }
#endif

    }];

}

- (void) addBlackoutView:(UIView *)theView;
{
    
    [self insertSubview:theView belowSubview:self.bottomPanelView];
    self.blackoutView = theView;
}

- (void) loadAlbumImage:(UIImage *)groupPoster;
{
    __unsafe_unretained MysticCameraControlsView *weakSelf = self;
    weakSelf.albumImageView.image = groupPoster;
    weakSelf.albumButton.alpha = 0.0f;
    [weakSelf.albumButton setTitle:NSLocalizedString(@"Photos", nil) forState:UIControlStateNormal];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MysticUIView animateWithDuration:MYSTIC_CAM_CONTROLS_IMAGEVIEW_DURATION animations:^{
            weakSelf.albumImageView.alpha = MYSTIC_CAM_CONTROLS_IMAGEVIEW_ALPHA;
            weakSelf.albumButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if(!finished) return ;
            
        }];
    });
}

- (void) setupInfoBtn
{
    __unsafe_unretained MysticCameraControlsView *weakSelf = self;
    weakSelf.infoImageView.alpha = 1;
    

}

- (void) setupPastePhoto
{
    __unsafe_unretained MysticCameraControlsView *weakSelf = self;
    weakSelf.pasteImageView.alpha = 0.0f;
    
    NSData *imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"public.jpeg"];
    if(imageData)
    {
        weakSelf.pasteButton.alpha = 0.0f;
        [weakSelf.pasteButton setTitle:NSLocalizedString(@"Paste", nil) forState:UIControlStateNormal];
        UIImage *pastie = [UIImage imageWithData:imageData];
        weakSelf.pasteImageView.image = pastie;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MysticUIView animateWithDuration:MYSTIC_CAM_CONTROLS_IMAGEVIEW_DURATION animations:^{
                weakSelf.pasteImageView.alpha = MYSTIC_CAM_CONTROLS_IMAGEVIEW_ALPHA;
                weakSelf.pasteButton.alpha = 1.0f;
                weakSelf.infoImageView.alpha = MYSTIC_CAM_CONTROLS_IMAGEVIEW_ALPHA;
                weakSelf.infoButton.alpha = 1.0f;
            } completion:^(BOOL finished) {
                if(!finished) return ;
                
            }];
        });
        

    }
    else
    {
        [weakSelf.pasteButton setTitle:NSLocalizedString(@"Empty",nil) forState:UIControlStateNormal];
        weakSelf.pasteImageView.hidden = YES;
        

    }
    
}

- (void)toggleFlashlight:(DDExpandableButton *)sender
{
    UIImagePickerControllerCameraFlashMode flashMode = UIImagePickerControllerCameraFlashModeAuto;
	switch (sender.selectedItem) {
        case 0:
            flashMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
        case 1:
            flashMode = UIImagePickerControllerCameraFlashModeOn;
            break;
        case 2:
            flashMode = UIImagePickerControllerCameraFlashModeOff;
            break;
        default: break;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsToggleFlash:flashMode:)])
    {
        [self.delegate cameraControlsToggleFlash:self flashMode:flashMode];
    }
    
}

- (void)toggleDevice:(DDExpandableButton *)sender
{
    UIImagePickerControllerCameraDevice device = UIImagePickerControllerCameraDeviceRear;
	switch (sender.selectedItem) {
        case 1:
            device = UIImagePickerControllerCameraDeviceFront;
            break;
        default:
            device = UIImagePickerControllerCameraDeviceRear;
            break;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsToggleDevice:device:)])
    {
        [self.delegate cameraControlsToggleDevice:self device:device];
    }
    
}


- (void) albumTouched:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsWantsToChooseFromLibrary:)])
    {
        [self.delegate cameraControlsWantsToChooseFromLibrary:self];
    }
}

- (void) pasteTouched:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsWantsToPastePhoto:)])
    {
        [self.delegate cameraControlsWantsToPastePhoto:self];
    }
}

- (void) shutterTouched:(id)sender;
{
    self.shutterButton.enabled = NO;

    RTSpinKitView *activity = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce color:[UIColor blackColor]];
    
    
    activity.center = CGPointMake(self.shutterButton.bounds.size.width/2, self.shutterButton.bounds.size.height/2);
    activity.tag = MysticViewTypeHUD;
    [self.shutterButton addSubview:activity];
    [activity startAnimating];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraControlsTakePhoto:)])
    {
        [self.delegate cameraControlsTakePhoto:self];
    }
}

- (void) finishedCapture;
{
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[self.shutterButton viewWithTag:MysticViewTypeHUD];
    if(activity)
    {
        [activity removeFromSuperview];
    }
    self.shutterButton.enabled = YES;
    
}



- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews) {
        if(CGRectContainsPoint(subview.frame, point)) return YES;
        
    }
    
    return NO;
}


@end

//
//  MysticPickerViewController.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//


#import "MysticPickerViewController.h"
#import "NavigationBar.h"
#import "MysticNavigationToolbar.h"
#import "MBProgressHUD.h"
#import "MysticSubImagePickerViewController.h"
#import "MysticBarButtonItem.h"
#import "MysticCustomImagePickerController.h"
#import "MysticCustomAlbumPickerController.h"

#ifdef MYSTIC_CAMERA_MODE

static BOOL ignoreAvailability = NO;

#else
static BOOL ignoreAvailability = NO;

#endif



@interface MysticPickerViewController ()
{
    UIView* iris_;
    MysticIrisState irisState;
}

@property (nonatomic, retain) MysticCameraControlsView *camControlsView;
@property (nonatomic, retain) UIView *blackoutView;

@end

@implementation MysticPickerViewController

@dynamic delegate;
@synthesize imagePicker=_imagePicker, imagePickerDelegate=_imagePickerDelegate, camControlsView=_camControlsView;

static SEL kIrisSelector;
static NSString* kIrisViewClassName;



- (void) dealloc;
{

    self.delegate = nil;
    self.imagePickerDelegate = nil;
    [_imagePicker release];
    [super dealloc];

}
- (id) initWithNibName:(NSString *)nibNameOrNil sourceType:(MysticPickerSourceType)startSourceType delegate:(id)newDelegate;
{
    self = [self initWithNibName:nibNameOrNil bundle:nil];
    if(self)
    {
        self.sourceType = startSourceType;
        self.imagePickerDelegate = newDelegate;
        
        [self present:startSourceType animated:NO finished:nil];
    }
    return self;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
        
    }
    return self;
}


- (void) setup;
{
    self.toolbarHidden = YES;
    [self setupWithSource:MysticPickerSourceTypeUnknown];
}
- (void) setupWithSource:(MysticPickerSourceType)source;
{
    kIrisViewClassName = @"PLCameraIrisAnimationView";
    kIrisSelector = NSSelectorFromString(@"animateIrisOpen");
    self.wantsFullScreenLayout = YES;
    self.navigationBarHidden = YES;
    self.navigationBar.userInteractionEnabled = NO;
    self.allowsEditing = YES;
    self.delegate = self;
    self.sourceType = source;
    self.toolbarHidden=YES;
    
    [self refresh];
    switch (source) {
        case MysticPickerSourceTypeCameraOrPhotoLibrary:
        case MysticPickerSourceTypeCamera:
        {
            MysticPickerRootViewController *firstViewController = [[MysticPickerRootViewController alloc] init];
            self.viewControllers = @[firstViewController];
            
            [firstViewController release];
            break;
        }
            
        default: break;
    }
    
    
}






- (void) refresh;
{
    irisState = MysticIrisStateUnknown;
    
}




- (MysticPickerRootViewController *) rootViewController;
{
    return self.viewControllers.count ? [self.viewControllers objectAtIndex:0] : nil;
}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    switch (self.currentSourceType) {
        case MysticPickerSourceTypeCamera:
        {
            irisState = MysticIrisStateOpened;
            break;
        }
        default: break;
    }
    
    
    
}

- (void) viewDidPresent:(BOOL)animated;
{
    //
    //    switch (self.currentSourceType) {
    //        case MysticPickerSourceTypeCamera:
    //        {
    //
    //            [NSTimer wait:0.3 block:^{
    //
    //
    //            }];
    //            break;
    //        }
    //        default: break;
    //    }
}
- (UIViewController *) present:(MysticPickerSourceType)asourceType animated:(BOOL)animated finished:(MysticBlock)finished;
{
    return [self present:asourceType viewController:self.visibleViewController animated:animated finished:finished];
}
- (UIViewController *) present:(MysticPickerSourceType)asourceType viewController:(UIViewController *)viewController animated:(BOOL)animated finished:(MysticBlock)finished;
{
    UIViewController *source = [self controllerForSource:asourceType];

    if(source)
    {
        source.hidesBottomBarWhenPushed = YES;
        MysticPickerSourceType returnType = asourceType;
        if([source isKindOfClass:[MysticSubImagePickerViewController class]] && [(MysticSubImagePickerViewController *)source sourceType] == UIImagePickerControllerSourceTypeCamera)
        {
            returnType = MysticPickerSourceTypeCamera;
        }
        else if([source isKindOfClass:[MysticSubImagePickerViewController class]] && [(MysticSubImagePickerViewController *)source sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            returnType = MysticPickerSourceTypePhotoLibrary;
        }
        else if([source isKindOfClass:[MysticSubImagePickerViewController class]] && [(MysticSubImagePickerViewController *)source sourceType] == UIImagePickerControllerSourceTypeSavedPhotosAlbum)
        {
            returnType = MysticPickerSourceTypeAlbum;
        }
        
        if([source isKindOfClass:[CameraViewController class]]) returnType = MysticPickerSourceTypeCamera;
  
        switch (returnType) {
                
            case MysticPickerSourceTypeCamera:
            {
                self.currentSourceType =returnType;

#ifdef MYSTIC_CAMERA_MODE
                
                
                UIImagePickerController *sourcePicker = (UIImagePickerController *)source;
                [viewController addChildViewController:sourcePicker];
                [viewController.view addSubview:sourcePicker.view];
                [sourcePicker didMoveToParentViewController:viewController];
#else
                
                
                //                [self setNavigationBarHidden:YES animated:NO];
                [source.view sizeToFit];
                
                UIImagePickerController *sourcePicker = (UIImagePickerController *)source;
                MysticCameraControlsView *controlsView = [[MysticCameraControlsView alloc] initWithFrame:[MysticUI frame]];
                sourcePicker.cameraOverlayView = controlsView;
                
                controlsView.delegate = self;
                self.camControlsView = controlsView;
                [viewController addChildViewController:sourcePicker];
                
                
                [viewController.view addSubview:sourcePicker.view];
                
                [sourcePicker didMoveToParentViewController:viewController];
                [controlsView release];
                
                
                
                controlsView = nil;
#endif
                break;
            }
            case MysticPickerSourceTypePhotoLibrary:
            {
                
                self.currentSourceType =returnType;
                UINavigationController *nav = (UINavigationController *)viewController;
          
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                
                [nav pushViewController:source animated:animated];
                break;
            }
            case MysticPickerSourceTypeAlbum:
            {
                
                self.currentSourceType =returnType;
                UINavigationController *nav = (UINavigationController *)viewController;
            
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                
                [nav pushViewController:source animated:animated];
                
                
                break;
            }
                
            default: break;
        }
    }
    if(finished) finished();
    return source;
}


- (UIViewController *) controllerForSource:(MysticPickerSourceType)sourceType;
{
    UIViewController *controller = nil;
    switch (sourceType) {
        case MysticPickerSourceTypeCameraOrPhotoLibrary:
        {
            if (!ignoreAvailability && (([MysticSubImagePickerViewController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypeCamera] == NO)
                || (self.imagePickerDelegate == nil)))
                return [self controllerForSource:MysticPickerSourceTypePhotoLibrary];
            
            return [self controllerForSource:MysticPickerSourceTypeCamera];
        }
        case MysticPickerSourceTypeCamera:
        {
            if (!ignoreAvailability && (([MysticSubImagePickerViewController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypeCamera] == NO)
                || (self.imagePickerDelegate == nil)))
                break;
            
#ifdef MYSTIC_CAMERA_MODE
    
            CameraViewController *camcontroller = [[CameraViewController alloc] init];
            camcontroller.delegate = self;
            camcontroller.finished = ^(UIImage *img, CameraViewController *cam)
            {
                if(img) [(MysticPickerViewController *)cam.delegate imagePickerController:(id)cam.delegate didFinishPickingMediaWithInfo:@{UIImagePickerControllerOriginalImage: img}];
            };
            camcontroller.close = ^(CameraViewController *cam)
            {
                [(MysticPickerViewController *)cam.delegate imagePickerControllerDidCancel:(id)cam.delegate];
            };
            camcontroller.album = ^(CameraViewController *cam)
            {
                [(MysticPickerViewController *)cam.delegate cameraControlsWantsToChooseFromLibrary:nil];
            };

                controller  = camcontroller;
    

#else
            MysticSubImagePickerViewController *cameraUI = [[MysticSubImagePickerViewController alloc] init];
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            // Displays a control that allows the user to choose picture or
            // movie capture, if both are available:
            cameraUI.mediaTypes = [[[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil] autorelease];
            cameraUI.allowsEditing = NO;
            cameraUI.showsCameraControls = NO;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                CGRect frame = [MysticUI frame];
                if(frame.size.height > 480.0f)
                {
                    //extraHeight = 20.0f;
                    CGFloat cy = frame.size.height / 480.0f;
                    CGAffineTransform camTrans = CGAffineTransformIdentity;
                    camTrans = CGAffineTransformConcat(camTrans, CGAffineTransformMakeScale(cy, cy));
                    
                    cameraUI.cameraViewTransform = camTrans;
                }
                
            }
            
            cameraUI.delegate = self;
            cameraUI.navigationBarHidden = YES;
            cameraUI.toolbarHidden = YES;
            cameraUI.wantsFullScreenLayout = YES;
            self.imagePicker = cameraUI;
            controller = [cameraUI retain];
            [cameraUI release];
#endif
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            break;
        }
        case MysticPickerSourceTypePhotoLibrary:
        {
            if (!ignoreAvailability && (([MysticSubImagePickerViewController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypePhotoLibrary] == NO)
                || (self.imagePickerDelegate == nil))) break;
            MysticCustomImagePickerController *viewController = [[MysticCustomImagePickerController alloc] initWithNibName:nil bundle:nil];
            viewController.delegate = self;
            viewController.allowsEditing = NO;
            self.imagePicker = (id)viewController;
            controller = [viewController retain];
            [viewController release];
            break;
        }
        case MysticPickerSourceTypeAlbum:
        {
            if (!ignoreAvailability && (([MysticSubImagePickerViewController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
                || (self.imagePickerDelegate == nil)))
                break;
            BOOL hasAccess = NO;
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            switch (status)
            {
                case PHAuthorizationStatusAuthorized: hasAccess = YES; break;
                case PHAuthorizationStatusNotDetermined:
                default: break;
            }
            
            if(!hasAccess)
            {
                self.imagePicker = nil;
                [MysticAlert notice:@"Access Denied" message:@"You need to authorize Mystic to access your photo library. To do this, goto Settings > Mystic." action:nil options:nil];
                return nil;
            }
            MysticCustomAlbumPickerController *viewController = [[MysticCustomAlbumPickerController alloc] initWithNibName:nil bundle:nil];
            viewController.delegate = self;
            viewController.allowsEditing = NO;
            
            self.imagePicker = (id)viewController;
            controller = [viewController retain];
            [viewController release];
            break;
        }
        default:
        {
            self.imagePicker = nil;
            controller = nil;
            break;
        }
    }
    return [controller autorelease];
}

- (MysticPickerSourceType) controllerTypeForSourceType:(MysticPickerSourceType)asourceType;
{
    switch (asourceType) {
        case MysticPickerSourceTypeCameraOrPhotoLibrary:
        {
            if (!ignoreAvailability && (([MysticSubImagePickerViewController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypeCamera] == NO)
                || (self.imagePickerDelegate == nil)))
                return MysticPickerSourceTypePhotoLibrary;
            
            return MysticPickerSourceTypeCamera;
        }
        default:
        {
            
            break;
        }
    }
    return asourceType;
}

#pragma mark - Iris
- (void)requestPermissions:(MysticBlockBOOL)block
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
            block(YES);
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus)
             {
                 if (authorizationStatus == PHAuthorizationStatusAuthorized)
                 {
                     block(YES);
                 }
                 else
                 {
                     block(NO);
                 }
             }];
            break;
        }
        default:
            block(NO);
            break;
    }
}

- (UIView *) findIrisView:(UIView *)parentView;
{
    UIView *_foundIris = nil;
    for (UIView* aview in parentView.subviews) {
        if ([kIrisViewClassName isEqualToString:[[aview class] description]]) {
            // It will be hidden by 'self.showsCameraControls = NO'.
            aview.hidden = false;
            // Extra precautions - as this is undocumented.
            if ([aview respondsToSelector:kIrisSelector]) {
                iris_ = aview;
                _foundIris = aview;
                
            }
            break;
        }
        
        if(aview.subviews.count)
        {
            _foundIris = [self findIrisView:aview];
            if(_foundIris) break;
        }
    }
    return _foundIris;
}

- (void) animateIrisOpen {
    irisState = MysticIrisStateOpened;
    if (iris_) {
        iris_.hidden = NO;
        [iris_ performSelector:kIrisSelector];
        
    }
}

- (void) animateIrisClose {
    irisState = MysticIrisStateClosed;
    if (iris_) {
        
    }
}









#pragma mark - MysticCameraControls Delegate


- (void) cameraControlsTakePhoto:(MysticCameraControlsView *)cameraControls;
{
    if(self.camControlsView)
    {
        UIView *blackOutView = [[UIView alloc] initWithFrame:self.view.frame];
        blackOutView.backgroundColor = [UIColor blackColor];
        //        [self.view insertSubview:blackOutView belowSubview:self.camControlsView];
        [cameraControls addBlackoutView:blackOutView];
        
        self.blackoutView = blackOutView;
        [blackOutView release];
    }
    if(self.imagePicker)
    {
        if(self.imagePicker.sourceType != UIImagePickerControllerSourceTypeCamera)
        {
            PickerLog(@"MysticPickerViewController ERROR: Source type must be UIImagePickerControllerSourceTypeCamera. Current Source Type = %d", self.imagePicker.sourceType);
            return;
        }
        [self.imagePicker takePicture];
        [self animateIrisOpen];
    }
}


- (void) cameraControlsWantsToChooseFromLibrary:(MysticCameraControlsView *)cameraControls;
{
    MysticCustomImagePickerController *assetPicker = (id)[self controllerForSource:MysticPickerSourceTypePhotoLibrary];
    //    MysticAssetPickerViewController *assetPicker = [[MysticAssetPickerViewController alloc] init];
    //    self.sourceType = MysticPickerSourceTypeAlbum;
    //    [self present:self.sourceType viewController:assetPicker animated:NO finished:nil];
    [self viewDidPresent:NO];
    self.currentSourceType = MysticPickerSourceTypePhotoLibrary;
    
    [self pushViewController:assetPicker animated:YES];
    //    [assetPicker release];
}


- (void) cameraControlsDidAppear:(MysticCameraControlsView *)cameraControls;
{
    if(iris_ && !iris_.hidden && irisState != MysticIrisStateOpened)
    {
        [self animateIrisOpen];
    }
}



- (void) cameraControlsWantsToPastePhoto:(MysticCameraControlsView *)cameraControls;
{
    
    NSData *imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"public.jpeg"];
    if(imageData)
    {
        UIImage *image = [UIImage imageWithData:imageData];
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        [workingDictionary setObject:ALAssetTypePhoto forKey:@"UIImagePickerControllerMediaType"];
        [workingDictionary setObject:image forKey:@"UIImagePickerControllerOriginalImage"];
        [workingDictionary setObject:image forKey:UIImagePickerControllerEditedImage];
        [workingDictionary setObject:image forKey:UIImagePickerControllerOriginalImage];
        [workingDictionary setObject:[NSValue valueWithCGRect:CGRectZero] forKey:UIImagePickerControllerCropRect];
        [self.delegate imagePickerController:(id)self didFinishPickingMediaWithInfo:workingDictionary];
        [workingDictionary release];
        
    }
    else
    {
        
        [MysticAlert notice:@"No Image Found" message:@"Try copying & pasting your image again." action:^(id object, id o2) {
            
        } options:@{@"button":@"OK"}];
        
    }
}
- (void) cameraControlsToggleDevice:(MysticCameraControlsView *)cameraControls device:(UIImagePickerControllerCameraDevice)device;
{
    if(self.imagePicker && [MysticSubImagePickerViewController isCameraDeviceAvailable:device])
    {
        self.imagePicker.cameraDevice = device;
    }
}
- (void) cameraControlsToggleFlash:(MysticCameraControlsView *)cameraControls flashMode:(UIImagePickerControllerCameraFlashMode)flashMode;
{
    if(self.imagePicker  && [MysticSubImagePickerViewController isFlashAvailableForCameraDevice:self.imagePicker.cameraDevice])
    {
        self.imagePicker.cameraFlashMode = flashMode;
    }
}
- (id) cameraController;
{
    for (UIViewController *c in self.viewControllers) {
        if([c isKindOfClass:[UIImagePickerController class]])
        {
            UIImagePickerController *cc = (UIImagePickerController *)c;
            if(cc.sourceType == UIImagePickerControllerSourceTypeCamera)
            {
                return cc;
            }
        }
    }
    return nil;
}
- (BOOL) hasCameraInStack;
{
    return [self cameraController] != nil;
}

#pragma mark - UIImagePickerController Delegate

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    BOOL fromCamera = [[self.viewControllers lastObject] isKindOfClass:[UIImagePickerController class]];
    
    fromCamera = self.hasCameraInStack;
    if(fromCamera)
    {
        self.currentSourceType = self.sourceType;
        self.imagePicker = [self cameraController];
        [self popViewControllerAnimated:YES];
        return;
    }
    if(self.imagePickerDelegate && [self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
    {
        [self.imagePickerDelegate imagePickerControllerDidCancel:picker];
    }
    //    [picker release];
    self.imagePicker = nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) returnInfo
{
    
    __unsafe_unretained __block  MysticPickerViewController *weakSelf = self;
    NSArray *returnArrayInfo = nil;
    NSDictionary *info = nil;
    if([returnInfo isKindOfClass:[NSDictionary class]])
    {
        returnArrayInfo = [NSArray arrayWithObject:returnInfo];
        info = returnInfo;
    }
    else if([returnInfo isKindOfClass:[NSArray class]])
    {
        returnArrayInfo = (NSArray *)returnInfo;
        info = [returnArrayInfo lastObject];
    }
    
    if(self.allowsEditing && self.currentSourceType != MysticPickerSourceTypeCropper)
    {
        __unsafe_unretained __block  MysticPickerViewController *weakSelf = self;
        
        
        
        UIImage *sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        UIImage *useImage = editedImage ? editedImage : sourceImage;
        
        
        [MysticImage constrainImage:useImage toSize:[MysticImage maximumImageSize] withQuality:1 finished:^(UIImage * constrainedImage) {
            
            
            NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionaryWithDictionary:info];
            
            [workingDictionary setObject:constrainedImage forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:constrainedImage forKey:UIImagePickerControllerEditedImage];
            
            
            if([info objectForKey:UIImagePickerControllerReferenceURL])
                [workingDictionary setObject:[info objectForKey:UIImagePickerControllerReferenceURL] forKey:UIImagePickerControllerReferenceURL];
            if([info objectForKey:UIImagePickerControllerMediaURL])
                [workingDictionary setObject:[info objectForKey:UIImagePickerControllerMediaURL] forKey:UIImagePickerControllerMediaURL];
            
            if([info objectForKey:UIImagePickerControllerCropRect])
                [workingDictionary setObject:[info objectForKey:UIImagePickerControllerCropRect] forKey:UIImagePickerControllerCropRect];
            
            BOOL fromCamera = [[weakSelf.viewControllers lastObject] isKindOfClass:[UIImagePickerController class]];
            
            
            UIImage *sourceImage = [workingDictionary objectForKey:UIImagePickerControllerOriginalImage];
            PECropViewController *cropperController = [[PECropViewController alloc] initFromCamera:fromCamera];
            cropperController.delegate = weakSelf;
            cropperController.image = sourceImage;
            cropperController.media = workingDictionary;
            //            cropperController.title = MysticObjectTypeTitle(MysticSettingCrop, nil);
            
            weakSelf.currentSourceType =MysticPickerSourceTypeCropper;
            //            if(weakSelf.navigationController) [(MysticNavigationViewController *)weakSelf.navigationController navigationBar].backgroundColorStyle = MysticColorTypeCollectionNavBarBackground;
            //            [weakSelf setNavigationBarHidden:NO animated:YES];
            [weakSelf pushViewController:cropperController animated:YES];
            
            [cropperController release];
            
            if(self.camControlsView)
            {
                [self.camControlsView finishedCapture];
            }
            if(self.blackoutView)
            {
                [MysticUIView animateWithDuration:0.2 delay:0.3 options:nil animations:^{
                    
                    weakSelf.blackoutView.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    [weakSelf.blackoutView removeFromSuperview];
                    weakSelf.blackoutView = nil;
                }];
            }
            
        }];
        return;
    }
    
    //    DLog(@" running final image picker finished delegate method");
    
    if(self.imagePickerDelegate && [self.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
    {
        [self.imagePickerDelegate imagePickerController:picker didFinishPickingMediaWithInfo:(id)info];
    }
    //    [picker release];
    self.imagePicker = nil;
    if(self.blackoutView)
    {
        [MysticUIView animateWithDuration:0.2 animations:^{
            weakSelf.blackoutView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf.blackoutView removeFromSuperview];
            weakSelf.blackoutView = nil;
        }];
    }
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
         didFinishPickingAlbum: (ALAssetsGroup *) group;
{
    MysticCustomImagePickerController *viewController = (id)[self controllerForSource:MysticPickerSourceTypePhotoLibrary];
    
    if(viewController)
    {
        viewController.album = group;
    }
    
    [self pushViewController:viewController animated:YES];
    
    
    
}


#pragma mark - pecropviewcontroller delegate

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    
    //    controller.delegate = nil;
    
    //    BOOL fromCamera = [[self.viewControllers lastObject] isKindOfClass:[UIImagePickerController class]];
    //    ALLog(@"crop cancelled", @[@"from camera", MBOOL(fromCamera),
    //                               @"controller from cam", MBOOL(controller.fromCamera),
    //                               @"controllers", MObj(self.viewControllers),]);
    //    if(fromCamera)
    //    {
    //        switch (self.sourceType) {
    //            case MysticPickerSourceTypeCamera:
    //            case MysticPickerSourceTypeCameraOrPhotoLibrary:
    //                [self imagePickerControllerDidCancel:(id)self];
    //                return;
    //
    //            default:
    //                break;
    //        }
    //    }
    
    //    if([self.rootViewController respondsToSelector:@selector(reset)])
    //    {
    //        [self.rootViewController reset];
    //    }
    
    
    //    [self present:self.sourceType animated:NO finished:nil];
    //    [self viewDidPresent:NO];
    self.currentSourceType = self.sourceType;
    [self popViewControllerAnimated:YES];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)image info:(NSDictionary *)info;
{
    
    SEL didFinish = self.didFinishSelector ? self.didFinishSelector : @selector(imagePickerController:didFinishPickingMediaWithInfo:);
    NSAssert(image != nil, @"Picker Cropper didFinishCroppingImage: nil image");
    if(!image) return;
    
    if(self.imagePickerDelegate && [self.imagePickerDelegate respondsToSelector:didFinish])
    {
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        
        CGRect crop = CGRectZero;
        crop.size = image.size;
        
        info = info ? info : [NSDictionary dictionary];
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] initWithDictionary:info];
        [workingDictionary setObject:ALAssetTypePhoto forKey:UIImagePickerControllerMediaType];
        if(image) [workingDictionary setObject:image forKey:UIImagePickerControllerEditedImage];
        if(image) [workingDictionary setObject:image forKey:UIImagePickerControllerOriginalImage];
        [workingDictionary setObject:[NSValue valueWithCGRect:crop] forKey:UIImagePickerControllerCropRect];
        
        
        [returnArray addObject:workingDictionary];
        
        [workingDictionary release];
        
        if([NSStringFromSelector(didFinish) isEqualToString:@"imagePickerController:didFinishPickingMediaWithInfo:finished:"])
        {
            [self.imagePickerDelegate imagePickerController:(id)self didFinishPickingMediaWithInfo:returnArray finished:nil];
        }
        else
        {
            [self.imagePickerDelegate performSelector:didFinish withObject:self withObject:returnArray];
        }
        [returnArray release];
        
        //        controller.delegate = nil;
        
    }
    
    
    
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    UIImagePickerControllerSourceType sourceType;
    BOOL hideControls = NO;
    BOOL hideNav = NO;
    
    
    if(![[UIApplication sharedApplication] isStatusBarHidden]) [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        
        PickerLog(@"UIImagePickerController will show: %d | %@", navigationController.viewControllers.count, viewController);
        sourceType = [(MysticSubImagePickerViewController*)navigationController sourceType];
        NSString *newTitle = @"Albums";
        BOOL isFirst = YES;
        if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary || sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) isFirst = [viewController.navigationItem.title isEqualToString:@"Photos"];
        else if(sourceType == UIImagePickerControllerSourceTypeCamera) hideControls = NO;
        UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
        
    }
    else if([navigationController isKindOfClass:[self class]])
    {
        if(self.viewControllers.count >= 1) hideNav = NO;
        
        if ([viewController isKindOfClass:[UIImagePickerController class]]) {
            sourceType = [(MysticSubImagePickerViewController*)viewController sourceType];
            if(sourceType == UIImagePickerControllerSourceTypeCamera)
            {
                hideNav = YES;
                hideControls = NO;
            }
        }
        
        //        [self setNavigationBarHidden:hideNav animated:YES];
        
    }
    //    ALLog(@"UIImagePickerController willShowViewController:", @[@"nav", MObj(navigationController),
    //                                                                @"Show", MObj(viewController),
    //                                                                @"Root", MObj([self.viewControllers objectAtIndex:0]),
    //                                                                @"Nav Delegate", MObj(navigationController.delegate),
    //                                                                @"Hide Nav", MBOOL(hideNav),]);
    //    ALLog(@"MysticPickerViewController willShowViewController #2:", @[@"Hide Nav", MBOOL(hideNav),
    //                                                                      @"Hide Controls", MBOOL(hideControls),
    //                                                                      @"Controls", MObj(self.camControlsView),
    //                                                                      @"Controller", MObj(viewController),
    //                                                                      @"Number of Nav Controllers", @(navigationController.viewControllers.count),
    //                                                                      ]);
    
    
    
    
    
    
}


- (void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(![[UIApplication sharedApplication] isStatusBarHidden])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    
}
- (void) setCurrentSourceType:(MysticPickerSourceType)currentSourceType;
{
    self.lastSourceType = _currentSourceType;
    _currentSourceType = currentSourceType;
}
- (UINavigationController *) navigationController;
{
    return self;
}

- (void) finished;
{
    for (UIViewController *vc in self.viewControllers) {
        if([vc respondsToSelector:@selector(setDelegate:)])
        {
            [vc performSelector:@selector(setDelegate:) withObject:nil];
        }
    }
}
//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
//{
//    MysticPickerViewControllerAnimation *obj = [[MysticPickerViewControllerAnimation alloc] init];
//    PickerLog(@"return: %@", obj);
//    return obj;
//}

@end

//
//  PECropViewController.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PECropViewController.h"
#import "PECropView.h"
#import "Mystic.h"
#import "MysticIcon.h"
#import "MysticAlert.h"

#import "NavigationViewController.h"
#import "NavigationBar.h"
#import "MysticNavigationViewController.h"
#import "MysticBarButtonItem.h"
#import "MysticBackgroundView.h"
#import "AHKActionSheet.h"
#import "MysticTipView.h"

@interface PECropViewController () <UIActionSheetDelegate>

@property (nonatomic) PECropView *cropView;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) BOOL donePressed;

@property (nonatomic, strong) MysticLayerToolbar *layerToolbar;

@end

@implementation PECropViewController

@synthesize media;

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"PEPhotoCropEditor" withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:bundleURL];
    });
    
    return bundle;
}

static inline NSString *PELocalizedString(NSString *key, NSString *comment)
{
    return [[PECropViewController bundle] localizedStringForKey:key value:nil table:@"Localizable"];
}

- (void) dealloc;
{
    self.delegate = nil;
    self.layerToolbar.delegate = nil;
    self.layerToolbar = nil;
    
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _fromCamera = YES;
        self.title = nil;
    }
    return self;
}
- (id) initFromCamera:(BOOL)isFromCam;
{
    self = [self init];
    if(self)
    {
        _fromCamera = isFromCam;
    }
    return self;
}

- (void) setDelegate:(id)delegate;
{
    _delegate = delegate;
    
}
- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor hex:@"151515"];
    CGRect cf = contentView.frame;
    cf.origin.y = -.5* MYSTIC_NAVBAR_HEIGHT;
    self.cropView = [[PECropView alloc] initWithFrame:cf];
   [contentView addSubview:self.cropView];
    self.view = contentView;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.donePressed = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    

    
    
    self.navigationItem.hidesBackButton = YES;
    self.hidesBottomBarWhenPushed = YES;
    

    CGSize leftBtnIconSize = CGSizeMake(9, 15);
    MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:[UIColor colorWithRed:0.40 green:0.39 blue:0.38 alpha:1.00]] target:self sel:@selector(cancel:)];
    leftBarButton.tag = MysticViewTypeButtonBack;
    [leftBarButton setImage:[MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarHighlighted]] forState:UIControlStateHighlighted];
    
    leftBarButton.frame = CGRectMake(0, 0, 53, 60);
    leftBarButton.buttonPosition = MysticPositionLeft;
    leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);

    MysticBarButtonItem *lbarItem = [[MysticBarButtonItem alloc] initWithCustomView:leftBarButton];
    lbarItem.width = leftBarButton.frame.size.width;


    
    CGSize rightBtnIconSize = CGSizeMake(19, 15);
    MysticBarButton *rightBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:rightBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] target:self sel:@selector(done:)];
    rightBarButton.tag = MysticViewTypeButtonForward;
    
    [rightBarButton setImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:rightBtnIconSize color:[UIColor color:MysticColorTypeNavBarIcon]] forState:UIControlStateHighlighted];
    
    rightBarButton.frame = CGRectMake(0, 0, 53, 60);
    rightBarButton.buttonPosition = MysticPositionRight;
    rightBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
    MysticBarButtonItem *rbarItem = [[MysticBarButtonItem alloc] initWithCustomView:rightBarButton];
    rbarItem.width = rightBarButton.frame.size.width;
    
    

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *staticSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    staticSpace.width = -15.f;
    UIBarButtonItem *constrainButton = [MysticUI buttonItemWithTitle:PELocalizedString(@"SIZE", nil) target:self sel:@selector(constrain:)];
    MysticButton *btn = (MysticButton *)constrainButton.customView;
    UIColor *d = [[UIColor fromHex:@"86756B"] darker:0.3];
//    [btn setImage:[MysticImage image:@(MysticIconTypeAccessoryUp) size:(CGSize){12,7} color:d] forState:UIControlStateNormal];
    btn.titleLabel.font = [MysticFont fontMedium:13];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [btn setTitleColor:[UIColor mysticWhiteBackgroundColor] forState:UIControlStateNormal];
    [btn setTitleColor:d forState:UIControlStateHighlighted];
    CGSize sizeIconSize = (CGSize){11,6};
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[MysticImage image:@(MysticIconTypeAccessoryUp) size:sizeIconSize color:[UIColor colorWithRed:0.40 green:0.39 blue:0.38 alpha:1.00]]];
    imgView.userInteractionEnabled = NO;
    imgView.contentMode = UIViewContentModeScaleToFill;
    imgView.frame = CGRectMake(btn.frame.size.width/2 - 6,2.5,12,5);
    btn.clipsToBounds = NO;
    [btn addSubview:imgView];
    
//    btn.imageAlignment = MysticAlignPositionTop;
//    btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    
    
    UIBarButtonItem *flipH = [MysticUI buttonItemWithTitle:nil target:self sel:@selector(flipHorizontal:)];
    btn = (MysticButton *)flipH.customView;
    [btn setImage:[MysticImage image:@(MysticIconTypeToolFlipHorizontal) size:(CGSize){24,24} color:[UIColor mysticWhiteBackgroundColor]] forState:UIControlStateNormal];
    [btn setImage:[MysticImage image:@(MysticIconTypeToolFlipHorizontalRight) size:(CGSize){24,24} color:[UIColor mysticWhiteBackgroundColor]] forState:UIControlStateSelected];
    btn.titleLabel.font = [MysticFont fontMedium:13];
    [btn setTitleColor:[UIColor mysticWhiteBackgroundColor] forState:UIControlStateNormal];
    [btn setTitleColor:d forState:UIControlStateHighlighted];
    
    UIBarButtonItem *flipV = [MysticUI buttonItemWithTitle:nil target:self sel:@selector(flipVertical:)];
    btn = (MysticButton *)flipV.customView;
    [btn setImage:[MysticImage image:@(MysticIconTypeToolFlipVertical) size:(CGSize){24,24} color:[UIColor mysticWhiteBackgroundColor]] forState:UIControlStateNormal];
    [btn setImage:[MysticImage image:@(MysticIconTypeToolFlipVerticalBottom) size:(CGSize){24,24} color:[UIColor mysticWhiteBackgroundColor]] forState:UIControlStateSelected];
    btn.titleLabel.font = [MysticFont fontMedium:13];
    [btn setTitleColor:[UIColor mysticWhiteBackgroundColor] forState:UIControlStateNormal];
    [btn setTitleColor:d forState:UIControlStateHighlighted];
    
    
    
    
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:@[staticSpace, lbarItem,  flexibleSpace, flipH, flexibleSpace, constrainButton, flexibleSpace, flipV, flexibleSpace, rbarItem, staticSpace] delegate:self height:self.navigationController.navigationBar.frame.size.height];
    toolbar.useLayout = NO;
    toolbar.backgroundColor = [UIColor colorWithType:MysticColorTypeTabBarBackground];
    toolbar.margin = 0;
    toolbar.userInteractionEnabled = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - toolbar.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height);
    self.layerToolbar = toolbar;

    [self.view addSubview:toolbar];
    self.cropView.image = self.image;
//    [MysticTipView tip:@"cropsize" inView:self.view targetView:self.layerToolbar hideAfter:10 delay:1 animated:YES];

}
- (void) flipVertical:(MysticButton *)sender;
{
    sender.selected = !sender.selected;
    self.cropView.flipVertical = sender.selected;
}
- (void) flipHorizontal:(MysticButton *)sender;
{
    sender.selected = !sender.selected;
    self.cropView.flipHorizontal = sender.selected;

}
- (void) viewWillAppear:(BOOL)animated;
{
//    [(MysticNavigationBar *)self.navigationController.navigationBar setBackgroundColorStyle:MysticColorTypeNavBarTranslucentAndColor];
   if([(MysticNavigationViewController *)self.navigationController willNavigationBarBeVisible]) [(MysticNavigationViewController *)self.navigationController hideNavigationBar:YES duration:-1 setHidden:NO complete:nil];
//    self.navigationController.navigationBar.translucent = YES;
//    [UIView animateWithDuration:0.35 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.navigationController.toolbar.transform = CGAffineTransformIdentity;
//        
//    } completion:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

    if (self.cropAspectRatio != 0) {
        self.cropAspectRatio = self.cropAspectRatio;
    }
    if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
        self.cropRect = self.cropRect;
    }
    
    self.keepingCropAspectRatio = self.keepingCropAspectRatio;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation { return YES; }

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.cropView.image = image;
}

- (void)cancel:(id)sender;
{
    DLog(@"cancel crop: %p", self.layerToolbar);
    //self.navigationController.toolbarHidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)]) {
        [self.delegate cropViewControllerDidCancel:self];
    }
}

- (void)done:(id)sender;
{
    self.donePressed = YES;
//    [self.navigationController setToolbarHidden:YES animated:NO];

//    self.navigationController.toolbarHidden = YES;
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:info:)]) {
        [self.delegate cropViewController:self didFinishCroppingImage:self.cropView.croppedImage info:self.media];
    }
    else if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:)]) {
        [self.delegate cropViewController:self didFinishCroppingImage:self.cropView.croppedImage];
    }
}

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio;
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio
{
    _cropAspectRatio = cropAspectRatio;
    self.cropView.cropAspectRatio = self.cropAspectRatio;
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    
    CGRect cropViewCropRect = self.cropView.cropRect;
    cropViewCropRect.origin.x += cropRect.origin.x;
    cropViewCropRect.origin.y += cropRect.origin.y;
    
    CGSize size = CGSizeMake(fminf(CGRectGetMaxX(cropViewCropRect) - CGRectGetMinX(cropViewCropRect), CGRectGetWidth(cropRect)),
                             fminf(CGRectGetMaxY(cropViewCropRect) - CGRectGetMinY(cropViewCropRect), CGRectGetHeight(cropRect)));
    cropViewCropRect.size = size;
    self.cropView.cropRect = cropViewCropRect;
}

- (void)constrain:(id)sender
{
    [MysticTipViewManager hideAll];
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    actionSheet.cancelButtonTitle = @"CANCEL";
    actionSheet.title = @"CHOOSE SIZE";
    actionSheet.cancelButtonImage = [MysticImageIcon image:@(MysticIconTypeToolHide) size:(CGSize){11, 7} color:[UIColor hex:@"6C5F58"]];
    actionSheet.cancelButtonImageHighlighted = [MysticImageIcon image:@(MysticIconTypeToolHide) size:(CGSize){11, 7} color:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]];
    actionSheet.cancelOnTapEmptyAreaEnabled = @YES;
    actionSheet.forceFitButtons = @YES;
    actionSheet.blurTintColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.85];
    actionSheet.blurRadius = 20.0f;
    actionSheet.buttonHeight = 46.0f;
    actionSheet.titleHeight = 34;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.buttonTextCenteringEnabled = @YES;
    actionSheet.animationDuration = 0.25f;
    actionSheet.buttonBackgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.65];
    actionSheet.cancelButtonBackgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:1];

//    actionSheet.cancelButtonBackgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.04 alpha:1];
    actionSheet.separatorColor = [UIColor colorWithRed:0.19 green:0.19 blue:0.19 alpha:1];
    actionSheet.selectedBackgroundColor = [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00];
    UIFont *defaultFont = [MysticFont gotham:11.0f];
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSKernAttributeName: @(3.0),
                                          NSForegroundColorAttributeName : [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1.00] };
    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                  NSForegroundColorAttributeName : [UIColor grayColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : [MysticFont gothamMedium:11.0f],
                                                NSKernAttributeName: @(3.0),
                                                NSForegroundColorAttributeName : [UIColor colorWithRed:0.87 green:0.26 blue:0.28 alpha:1.00] };
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    actionSheet.titleTextAttributes = @{ NSFontAttributeName : [MysticFont gothamMedium:10.0f],
                                         NSKernAttributeName: @(2.0),
                                         NSParagraphStyleAttributeName: paragraph,
                                         NSForegroundColorAttributeName : [UIColor colorWithRed:0.42 green:0.37 blue:0.35 alpha:1.00] };
    __unsafe_unretained __block PECropViewController *weakSelf = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"ORIGINAL",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:0];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SQUARE",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:1];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"3 ✕ 2",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:2];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"3 ✕ 5",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:3];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"4 ✕ 3",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:4];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"4 ✕ 6",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:5];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"5 ✕ 7",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:6];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"8 ✕ 10",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:7];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"16 ✕ 9",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:8];
    }];
    NSMutableDictionary *customAttr = [NSMutableDictionary dictionaryWithDictionary:actionSheet.buttonTextAttributes];
    [customAttr setObject:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *customTitle = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"CUSTOM",nil) attributes:customAttr];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CUSTOM",nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender) {
        [weakSelf actionSheet:(id)sender clickedButtonAtIndex:9];
    }];
    [actionSheet show];
//    
//    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                   delegate:self
//                                          cancelButtonTitle:PELocalizedString(@"Cancel", nil)
//                                     destructiveButtonTitle:nil
//                                          otherButtonTitles:
//                        PELocalizedString(@"Original", nil),
//                        PELocalizedString(@"Square", nil),
//                        PELocalizedString(@"3 x 2", nil),
//                        PELocalizedString(@"3 x 5", nil),
//                        PELocalizedString(@"4 x 3", nil),
//                        PELocalizedString(@"4 x 6", nil),
//                        PELocalizedString(@"5 x 7", nil),
//                        PELocalizedString(@"8 x 10", nil),
//                        PELocalizedString(@"16 x 9", nil),
//                        PELocalizedString(@"Custom...", nil),
//                        nil];
//    [self.actionSheet showFromRect:self.layerToolbar.frame inView:self.view animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet
willDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    actionSheet.userInteractionEnabled = NO;

}
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 9:
        {

            MysticAlert *a = [MysticAlert input:@"Custom Size" message:[NSString stringWithFormat:@"Enter Width & Height\n(max: %2.0f x %2.0f)", [MysticUser user].maximumRenderSize.width,[MysticUser user].maximumRenderSize.height]  action:^(id obj1, MysticAlert* alert) {
                
                NSString *width = [alert inputAtIndex:0].text;
                NSString *height = [alert inputAtIndex:1].text;
                CGFloat w = MIN(MAX(100.0, [width floatValue]), [MysticUser user].maximumRenderSize.width);
                CGFloat h = MIN(MAX(100.0, [height floatValue]), [MysticUser user].maximumRenderSize.height);
                CGRect cropRect = self.cropView.cropRect;
                cropRect.size = CGSizeMake(w,h);
                self.cropView.cropRect = cropRect;
                self.cropView.returnSize = cropRect.size;
                
                
            } cancel:^(id obj1, id obj2) {
                
            } inputs:@[@{@"placeholder":@"Width", @"type":@(UIKeyboardTypeNumberPad)}, @{@"placeholder":@"Height", @"type":@(UIKeyboardTypeNumberPad)}] options:nil];
            a.presentingController = self;
            [a show];
            break;
        }
        default:
            break;
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL keepCropAspect = YES;
    if (buttonIndex == 0) {
        CGRect cropRect = self.cropView.cropRect;
        CGSize size = self.cropView.image.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat ratio;
        if (width < height) {
            ratio = width / height;
            cropRect.size = CGSizeMake(CGRectGetHeight(cropRect) * ratio, CGRectGetHeight(cropRect));
        } else {
            ratio = height / width;
            cropRect.size = CGSizeMake(CGRectGetWidth(cropRect), CGRectGetWidth(cropRect) * ratio);
        }
        self.cropView.cropRect = cropRect;
        keepCropAspect = NO;
//        [self.cropView.scrollView setZoomScale:1 animated:YES];
//        [self.cropView resetTransformAndZoom];
    } else if (buttonIndex == 1) {
        self.cropView.cropAspectRatio = 1.0f;
    } else if (buttonIndex == 2) {
        self.cropView.cropAspectRatio = 2.0f / 3.0f;
    } else if (buttonIndex == 3) {
        self.cropView.cropAspectRatio = 3.0f / 5.0f;
    } else if (buttonIndex == 4) {
        CGFloat ratio = 3.0f / 4.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetWidth(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    } else if (buttonIndex == 5) {
        self.cropView.cropAspectRatio = 4.0f / 6.0f;
    } else if (buttonIndex == 6) {
        self.cropView.cropAspectRatio = 5.0f / 7.0f;
    } else if (buttonIndex == 7) {
        self.cropView.cropAspectRatio = 8.0f / 10.0f;
    } else if (buttonIndex == 8) {
        CGFloat ratio = 9.0f / 16.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetWidth(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    
    } else if (buttonIndex == 9) {
        [self actionSheet:(id)actionSheet didDismissWithButtonIndex:9];
//        [actionSheet dismissWithClickedButtonIndex:9 animated:NO];

        
    }

    self.keepingCropAspectRatio = keepCropAspect;

}

@end

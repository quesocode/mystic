//
//  MysticIntroViewController.m
//  Mystic
//
//  Created by Me on 11/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "MysticIntroViewController.h"
#import "MysticButton.h"
#import "MysticPickerViewController.h"
#import "MBProgressHUD.h"
#import "MysticController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticNavigationViewController.h"
#import "MysticBackgroundView.h"
#import "MysticMainDrawerViewController.h"
#import "MysticDrawerMenuViewController.h"
#import "AppDelegate.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "NSArray+Mystic.h"
#import "MysticDictionaryDownloader.h"
#import "MysticCustomImagePickerController.h"
#import "MysticLayerTableViewCell.h"
#import "MysticLibrary.h"
#import "UserPotion.h"
#import "ABX.h"


@interface MysticIntroViewController () <OHAttributedLabelDelegate, UIImagePickerControllerDelegate>
{
    CGRect oAvFrane;
    CGRect oBgFrane;
    NSTimer *hintTimer, *retryTimer;
    NSInteger currentHintIndex, nextHintIndex;
    
}

@property (retain, nonatomic) IBOutlet UIImageView *artworkView;
@property (retain, nonatomic) IBOutlet MysticButton *albumButton;
@property (retain, nonatomic) IBOutlet MysticButton *cameraButton;
@property (retain, nonatomic) IBOutlet MysticBackgroundView *backgroundView;
@property (retain, nonatomic) NSMutableArray *assets;
@property (retain, nonatomic) OHAttributedLabel *hintLabel;
@property (retain, nonatomic) NSArray *hints;
@property (retain, nonatomic) NSString *hintLink;
@property (readonly, nonatomic) MysticDrawerMenuViewController * drawer;
@property (nonatomic, retain) MysticController *viewController;
@property (nonatomic, retain) MBProgressHUD* hud;
@property (nonatomic, retain) UIView *promptView;

@end

@implementation MysticIntroViewController


- (void)dealloc
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:nil];
    [_backgroundView release];
    [_cameraButton release];
    [_albumButton release];
    [_hintLabel release];
    [_artworkView release];
    [_hud release];
    [_hintLink release];
    [_hints release];
    [hintTimer release], hintTimer = nil;
    [_viewController release];
    [_promptView release];
    [_assets release];
    if(retryTimer) {
        [retryTimer invalidate];
        [retryTimer release], retryTimer=nil;
    }
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentHintIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    
    
    __unsafe_unretained __block MysticIntroViewController *weakSelf = self;
    
    [super viewDidLoad];
    
    weakSelf.backgroundView.backgroundType = MysticBackgroundTypeLight;
    // Do any additional setup after loading the view from its nib.
    [self.mm_drawerController setGestureCompletionBlock:nil];
    [self.mm_drawerController setDrawerVisualStateBlock:nil];
    self.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.mm_drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
    self.hidesBottomBarWhenPushed = YES;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    
    
    CGSize leftBtnIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_LAYERS, MYSTIC_NAVBAR_ICON_HEIGHT_LAYERS);
    MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] target:self sel:@selector(backButtonTouched:)];
    leftBarButton.tag = MysticViewTypeLayers;
    
    [leftBarButton setImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] forState:UIControlStateHighlighted];
    [leftBarButton setImage:[MysticImage image:@(MysticIconTypeMenu) size:leftBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] forState:UIControlStateSelected];
    leftBarButton.frame = CGRectMake(0, 0, 53, 51);
    leftBarButton.buttonPosition = MysticPositionLeft;
    leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
    MysticBarButtonItem *barItem = [[MysticBarButtonItem alloc] initWithCustomView:leftBarButton];
    [self.navigationItem setLeftBarButtonItem:barItem animated:YES];
    [barItem release];
    
    CGSize rightBtnIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_SETTINGS, MYSTIC_NAVBAR_ICON_HEIGHT_SETTINGS);
    
    
//    MysticBarButton *rightBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeCogBorder) size:rightBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconDark]] target:self sel:@selector(rightButtonTouched:)];
//    rightBarButton.tag = MysticViewTypeButton2;
//    
//    [rightBarButton setImage:[MysticImage image:@(MysticIconTypeCogBorder) size:rightBtnIconSize color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] forState:UIControlStateHighlighted];
//    rightBarButton.frame = CGRectMake(0, 0, 53, 51);
//    rightBarButton.buttonPosition = MysticPositionRight;
//    barItem = [[MysticBarButtonItem alloc] initWithCustomView:rightBarButton];
//    [self.navigationItem setRightBarButtonItem:barItem animated:YES];
//    [barItem release];
    
    
    [(MysticNavigationBar *)self.navigationController.navigationBar setBackgroundColorStyle:MysticColorTypeClear];
    self.navigationController.navigationBarHidden = NO;
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController
     setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
         return NO;
     }];
    
    
    NSString *bundledHintsPath = [[NSBundle mainBundle] pathForResource:@"hints" ofType:@"plist"] ;
    [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:MYSTIC_HINTS_URL] orDictionary:bundledHintsPath state:^(NSDictionary *hintsD2, MysticDataState dstate) {
        
        if(dstate & MysticDataStateNew)
        {
            nextHintIndex = [hintsD2 objectForKey:@"intro-next"] ? [[hintsD2 objectForKey:@"intro-next"] integerValue] : NSNotFound;
            weakSelf.hints = [hintsD2 objectForKey:@"intro"];
        }
        //        if(dstate & MysticDataStateFinish && !(dstate & MysticDataStateCachedLocal))
        //        {
        //            [weakSelf release];
        //        }
        
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(albumDoubleTapped:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.albumButton addGestureRecognizer:tapGesture];
    [tapGesture release];
    self.navigationController.navigationBarHidden = NO;
    oAvFrane = self.artworkView.frame;
    oBgFrane = self.backgroundView.frame;
    
    
    OHAttributedLabel *hint = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 80, self.view.frame.size.width - 30, 80)];
    hint.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    hint.numberOfLines = 0;
    hint.backgroundColor = [UIColor clearColor];
    hint.onlyCatchTouchesOnLinks = NO;
    hint.delegate = self;
    hint.allowGesture = YES;
    hint.textColor = [UIColor color:MysticColorTypeIntroHint] ;
    NSDictionary *h = self.hints && self.hints.count ? [self.hints objectAtIndex:currentHintIndex] : nil;
    hint.attributedText = h ? [self hintWithString:h] : nil;
    hint.alpha = 0;
    hint.centerVertically = YES;
    self.hintLabel = hint;
    [self.view addSubview:self.hintLabel];
    [hint release];
    
}

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo;
{
    [self hintTapped:attributedLabel];
    return NO;
}

- (void) stopHints;
{
    if(hintTimer)
    {
        [hintTimer invalidate];
        [hintTimer release];
        hintTimer = nil;
    }
}
- (void) startNextHintTimer;
{
    if(hintTimer)
    {
        [hintTimer invalidate];
        [hintTimer release];
        hintTimer = nil;
    }
    if(!hintTimer)
    {
        hintTimer = [[NSTimer scheduledTimerWithTimeInterval:7.5 target:self selector:@selector(showNextHint:) userInfo:nil repeats:NO] retain];
    }
}


- (void) showNextHint:(id)sender;
{
    DLog(@"showing next intro hint");
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = self;
    [MysticUIView animateWithDuration:0.65 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.hintLabel.alpha = 0;
    } completion:^(BOOL finished) {
        if(!finished){
            //            [weakSelf release];
            return;
        }
        weakSelf.hintLabel.attributedText = [weakSelf nextHint];
        [MysticUIView animateWithDuration:0.5 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.hintLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if(!finished){
                //                [weakSelf release];
                return;
            }
            //[weakSelf startNextHintTimer];
            //            [weakSelf release];
            
        }];
    }];
}


- (NSAttributedString *) nextHint;
{
    NSDictionary *next = nil;
    if(nextHintIndex != NSNotFound && nextHintIndex < self.hints.count)
    {
        next = [self.hints objectAtIndex:nextHintIndex];
        currentHintIndex = nextHintIndex;
        nextHintIndex = NSNotFound;
        return [self hintWithString:next];
    }
    
    NSDictionary *hint = [[self hints] objectAtRandomIndexExcept:currentHintIndex];
    currentHintIndex = [[hint objectForKey:@"index"] integerValue];
    return [self hintWithString:[hint objectForKey:@"value"]];
}

- (NSAttributedString *) hintWithString:(NSDictionary *)hintObj;
{
    NSString *msg = [hintObj objectForKey:@"text"];
    NSString *hintTitle = [hintObj objectForKey:@"title"] && ![[hintObj objectForKey:@"title"] isEqualToString:@""] ? [hintObj objectForKey:@"title"] : @"HINT";
    
    hintTitle = [NSString stringWithFormat:@"- %@ -", hintTitle];
    
    NSString *h = [hintTitle stringByAppendingFormat:@"\n%@", msg];
    
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:h];
    [str setCharacterSpacing:0.8];
    [str setFont:[MysticUI gothamMedium:10]];
    NSRange hintRange = [h rangeOfString:hintTitle];
    [str setFont:[MysticUI gothamBold:10] range:hintRange];
    [str setTextColor:[UIColor color:MysticColorTypeIntroHint]];
    [str setTextColor:[[UIColor color:MysticColorTypeIntroHint] lighter:0.2] range:hintRange];
    NSInteger strLength = [h length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    [style setLineSpacing:4];
    
    [str addAttribute:NSParagraphStyleAttributeName
                value:style
                range:NSMakeRange(0, strLength)];
    [style release];
    
    style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    [style setLineSpacing:6];
    
    [str addAttribute:NSParagraphStyleAttributeName
                value:style
                range:hintRange];
    [style release];
    
    if([hintObj objectForKey:@"link"] && ![[hintObj objectForKey:@"link"] isEqualToString:@""])
    {
        self.hintLink = [hintObj objectForKey:@"link"];
        
    }
    else
    {
        self.hintLink = nil;
        
    }
    
    
    return str;
}


- (void) hintTapped:(id)sender;
{
    
    if(!self.hintLink)
    {
        if(hintTimer)
        {
            [hintTimer invalidate];
            [hintTimer release];
            hintTimer = nil;
        }
        [self showNextHint:nil];
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.hintLink] sourceApplication:nil annotation:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    //    [hintTimer invalidate];
    //    [hintTimer release];
    //    hintTimer = nil;
    [self stopHints];
    [self setBackgroundView:nil];
    [self setCameraButton:nil];
    [self setAlbumButton:nil];
    [self setArtworkView:nil];
    [self setHintLabel:nil];
    [super viewDidUnload];
}
- (void) viewUnload {
    
    
    [self stopHints];
//    [self.albumButton removeTarget:nil action:@selector(albumButtonTouched:) forControlEvents:self.albumButton.allControlEvents];
    self.albumButton.gestureRecognizers = nil;
    [self.albumButton removeFromSuperview];
//    [self.cameraButton removeTarget:nil action:@selector(cameraButtonTouched:) forControlEvents:self.cameraButton.allControlEvents];
    [self.cameraButton removeFromSuperview];
    [self setBackgroundView:nil];
    [self setCameraButton:nil];
    [self setAlbumButton:nil];
    [self setArtworkView:nil];
    [self setHintLabel:nil];
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeClear;
    [(MysticNavigationBar *)self.navigationController.navigationBar setBorderStyle:NavigationBarBorderStyleNone];
    
    self.navigationController.navigationBarHidden = NO;
    self.cameraButton.titleLabel.font = [MysticFont gothamBold:14];
    self.albumButton.titleLabel.font = self.cameraButton.titleLabel.font;
    self.cameraButton.titleLabel.textColor = [UIColor color:MysticColorTypeIntroButtonText];
    self.albumButton.titleLabel.textColor = [UIColor color:MysticColorTypeIntroButtonText];
    
    CGRect imvFrame = self.backgroundView.frame;
    CGRect aframe = self.artworkView.frame;
    CGRect camFrame = self.cameraButton.frame;
    CGRect albFrame = self.albumButton.frame;
    
    if(self.navigationController.navigationBarHidden || self.navigationController.navigationBar.translucent)
    {
        
        imvFrame.size.height = [MysticUI screen].height;
        imvFrame.origin.y = oBgFrane.origin.y;
        aframe.origin.y = oAvFrane.origin.y +(self.navigationController.navigationBar.frame.size.height/2) ;
        
        
    }
    else if(!self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.translucent)
    {
        imvFrame.origin = oBgFrane.origin;
        imvFrame.origin.y = -self.navigationController.navigationBar.frame.size.height;
        aframe.origin.y =  oAvFrane.origin.y /*+ self.navigationController.navigationBar.frame.size.height */;
    }
    albFrame.origin.y = aframe.origin.y + aframe.size.height + -30;
    camFrame.origin.y = aframe.origin.y + aframe.size.height + -30;
    
    self.artworkView.frame = aframe;
    self.backgroundView.frame = imvFrame;
    self.albumButton.frame = albFrame;
    self.cameraButton.frame = camFrame;
    
    if(self.hintLabel)
    {
        self.hintLabel.alpha = 0;
        self.hintLabel.transform = CGAffineTransformMakeTranslation(0, 50);
    }
    
}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
#ifdef MYSTIC_USE_LAUNCH_PHOTO_NEW_PROJECT
    
    [self loadPhoto:[UIImage imageNamed:@"launchPhoto.jpg"]];
    
#else
    
    self.albumButton.enabled = YES;
    self.cameraButton.enabled = YES;
    if(self.promptView) return;
    
    
    
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = self;
    NSDictionary *lastProject = [MysticUser user].lastProject;
    NSString *lastProjectName = [MysticUser user].lastProjectName;
    NSString *currentProjectName = [MysticUser user].currentProjectName;
    if(lastProject)
    {
        NSString *projectPath = [[[MysticCache projectCache].diskCachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[MysticUser user].lastProjectName];
        NSString *lImg = lastProject[@(MysticProjectKeyImageThumbPath)] ? lastProject[@(MysticProjectKeyImageThumbPath)] : lastProject[@(MysticProjectKeyImageResizedPath)];
        NSString *pImgPath = !lImg ? nil : [projectPath stringByAppendingPathComponent:lImg];
        if(!lImg || ![[NSFileManager defaultManager] fileExistsAtPath:pImgPath]) lastProject = nil;
    }
    
    if(!lastProject)
    {
        [MysticUIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.hintLabel.alpha = 1;
            weakSelf.hintLabel.transform = CGAffineTransformIdentity;
            
        } completion:nil];
    }
    else [weakSelf loadLastProject];
    
    [weakSelf showNotification];
#endif
}

- (void) showNotification;
{
    
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = self;
    
    // Fetch the notifications, there will only ever be one
    [ABXNotification fetchActive:^(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        
        //        ALLog(@"fetched active", @[@"notifications", MObj(notifications),
        //                                   @"responsecode", @(responseCode),
        //                                   @"httpCode", @(httpCode),
        //                                   @"error", MObj(error),]);
        
        if (responseCode ==  ABXResponseCodeSuccess) {
            if (notifications.count > 0) {
                ABXNotification *notification = [notifications firstObject];
                
                if (![notification hasSeen]) {
                    // Show the view
                    [ABXNotificationView show:notification.message
                                   actionText:notification.actionLabel
                                    closeText:notification.actionLabel && notification.actionLabel.length > 0 ? @"CLOSE" : @"CLOSE"
                              backgroundColor:[[UIColor hex:@"1E1C1B"] colorWithAlphaComponent:0.98]
                                    textColor:[UIColor hex:@"E8DAC8"]
                                  buttonColor:[UIColor hex:@"e8566b"]
                                 inController:weakSelf.navigationController
                                  actionBlock:^(ABXNotificationView *view) {
                                      // Open the URL
                                      // Here you could open it in your internal UIWebView or route accordingly
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.actionUrl]];
                                      [notification markAsSeen];
                                  } dismissBlock:^(ABXNotificationView *view) {
                                      // Here you can mark it as seen if you
                                      // don't want it to appear again
                                      [notification markAsSeen];
                                  }];
                    
                    //                    if (complete) {
                    //                        complete(YES);
                    //                    }
                    
                    return;
                }
            }
        }
        
        
        //        if (complete) {
        //            complete(NO);
        //        }
    }];
}


- (void) viewWillDisappear:(BOOL)animated;
{
    [self stopHints];
    [super viewWillDisappear:animated];
    
}

- (void) backButtonTouched:(id)sender;
{
    
    MysticDrawerNavViewController *drawerNav = (MysticDrawerNavViewController *)self.mm_drawerController.leftDrawerViewController;
    
    
    MysticDrawerMenuViewController *menuController = self.drawer;
    
    if(!menuController || ![menuController isKindOfClass:[MysticDrawerMenuViewController class]])
    {
        menuController = [[[MysticDrawerMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        
        drawerNav.viewControllers = @[menuController];
        [drawerNav popToRootViewControllerAnimated:NO];
    }
    
    [self toggleDrawerSide:MMDrawerSideLeft completion:nil];
    
}



- (void) rightButtonTouched:(id)sender;
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openSettingsAnimated:YES complete:nil];
}

- (void) toggleDrawerSide:(MMDrawerSide)openSide completion:(MysticBlockBOOL)finished;
{
    
    [self.mm_drawerController toggleDrawerSide:openSide animated:YES completion:finished];
}

- (id) drawer;
{
    return self.mm_drawerController.leftDrawerViewController;
}


- (IBAction)cameraButtonTouched:(MysticButton *)sender
{
    sender.enabled = NO;
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypeCameraOrPhotoLibrary complete:nil];
    }
    else
    {
        [MysticAlert notice:@"No Camera" message:@"Your device doesn't have a camera, so you'll have to choose a photo from your album instead." action:^(id object, id o2) {
            [weakSelf albumButtonTouched:sender];
            
        } options:@{@"button":@"Choose Photo"}];
    }
}
- (IBAction)albumButtonTouched:(MysticButton *)sender
{
    [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypePhotoLibrary complete:nil];
}


- (void) albumDoubleTapped:(UITapGestureRecognizer *)sender;
{
    if (sender.state == UIGestureRecognizerStateEnded) [self loadLastPhoto];
}



- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
{
        __unsafe_unretained __block MysticIntroViewController *weakSelf = self;
        MysticPermissionType permType = sourceType != MysticPickerSourceTypePhotoLibrary ? MysticPermissionTypeCamera : MysticPermissionTypePhotos;
        mdispatch(^{
            weakSelf.navigationController.navigationBar.hidden = YES;
            [MysticPermissionView showInView:weakSelf.view type:permType animated:YES complete:^(MysticPermissionView *permissionView, id statusObj, BOOL success) {
                weakSelf.permissionView = permissionView;
                if(!success) {   return; }
                MysticBlockBOOL presentBlock = ^(BOOL f){
                    mdispatch(^{
                        weakSelf.navigationController.navigationBar.hidden = NO;
                        MysticPickerViewController *picker ;
                        
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController" owner:nil options:nil] lastObject];
                        } else {
                            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController_iPad" owner:nil options:nil] lastObject];
                        }
                        [picker setupWithSource:sourceType];
                        picker.sourceType = sourceType;
                        picker.imagePickerDelegate = (delegate ? delegate : weakSelf);
                        weakSelf.modalPresentationStyle = UIModalPresentationFullScreen;
                        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                        UIViewController *p = [picker present:picker.sourceType viewController:picker animated:NO finished:nil];
                        __unsafe_unretained __block  MysticPickerViewController *weakPicker = picker;
                        [weakSelf.navigationController presentViewController:picker animated:animated completion:^{
                            [weakPicker viewDidPresent:animated]; if(finished) finished();
                            weakSelf.permissionView = nil;
                        }];
                        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
                    });
                };
                
                if(weakSelf.permissionView) [weakSelf.permissionView hide:YES complete:presentBlock];
                else presentBlock(YES);
            }];
        });
}
- (void) closeCam:(void (^)())finished;
{
    self.cameraButton.enabled = YES;
    self.albumButton.enabled = YES;
    @autoreleasepool {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        __unsafe_unretained __block  MysticPickerViewController *picker = nil;
        picker = (MysticPickerViewController *)self.presentedViewController;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if(finished) finished();
        }];
    }
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo
{
    [self imagePickerController:picker didFinishPickingMediaWithInfo:returnInfo finished:nil];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo finished:(MysticBlockObject)finishedBlock;
{

    if(!returnInfo)
    {
        [self imagePickerControllerDidCancel:picker];
        return;
    }
    if([picker respondsToSelector:@selector(imagePickerDelegate)])
    {
        MysticPickerViewController *pp = (id)picker;
        [(MysticPickerViewController *)picker setImagePickerDelegate:nil];
        [(MysticPickerViewController *)picker setDelegate:nil];
        
    }
    NSArray *info = nil;
    if([returnInfo isKindOfClass:[NSDictionary class]]) info = [NSArray arrayWithObject:returnInfo];
    else if([returnInfo isKindOfClass:[NSArray class]]) info = (NSArray *)returnInfo;
    
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = [self retain];
    __unsafe_unretained __block MysticController *viewController;
    __unsafe_unretained __block MysticBlock _finished = finishedBlock ? Block_copy(finishedBlock) : nil;
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:picker.navigationController.view];
    
    hud.blurView.dynamic = YES;
    hud.removeFromSuperViewOnHide = YES;
    hud.underlyingView = picker.navigationController.view;
    hud.labelText = NSLocalizedString(@"mystifying", nil);
    [picker.navigationController.view addSubview:hud];
    [picker.navigationController.view bringSubviewToFront:hud];
    
    [hud show:YES];
    
    weakSelf.hud = hud;
    [hud release];
    
    
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
    } else {
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
    }
    
    
    [self.viewController info:[NSMutableArray arrayWithArray:info] ready:^(MysticController *editController){
        
        if(weakSelf.navigationController.presentedViewController)
        {
            __unsafe_unretained __block  MysticIntroViewController *weakSelf2 = [weakSelf retain];
            
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                
                if(weakSelf2.navigationController.viewControllers.count > 1)
                {
                    weakSelf2.navigationController.viewControllers = @[[weakSelf2.navigationController.viewControllers lastObject]];
                    
                }
                
                
                
                if(_finished)
                {
                    _finished(editController);
                    Block_release(_finished);
                }
                
                [weakSelf viewUnload];
                [weakSelf2 autorelease];
                [[MysticUser user] clearLastProject];

                
            }];
            
            [weakSelf release];
            
        }
        else
        {
            if(_finished)
            {
                _finished(editController);
                Block_release(_finished);
                
            }
            if(weakSelf.navigationController.viewControllers.count > 1)
            {
                weakSelf.navigationController.viewControllers = @[[weakSelf.navigationController.viewControllers lastObject]];
                
            }
            [weakSelf viewUnload];
            [weakSelf autorelease];
            [[MysticUser user] clearLastProject];

        }
        
        
    }];
    retryTimer = [[NSTimer repeat:3 block:^{
        
        weakSelf.hud.userInteractionEnabled = NO;
        [retryTimer invalidate];
        [retryTimer release];
        retryTimer = nil;
        [weakSelf.hud hide:YES];
        
    }] retain];
    [self showEditViewController];
}

- (void) showEditViewController;
{
    __unsafe_unretained __block  MysticIntroViewController *weakSelf = [self retain];
    __unsafe_unretained __block MysticNavigationViewController *nav = [(MysticNavigationViewController *)self.navigationController retain];
    
    
    
    [self.viewController setInfo:nil finished:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            weakSelf.navigationController.navigationBarHidden = NO;
            [nav.navigationBar setBackgroundColorStyle:MysticColorTypeClear];
            nav.navigationBar.height = MYSTIC_NAVBAR_HEIGHT_NORMAL;
            
            [nav pushViewController:weakSelf.viewController animated:nav.presentedViewController ? NO : YES];
            __unsafe_unretained __block MysticIntroViewController *weakSelf2 = [weakSelf retain];
            
            [weakSelf.viewController setupDrawerState];
            [weakSelf.hud setCompletionBlock:^{
                [weakSelf2.viewController runViewIsReady];
                weakSelf2.viewController = nil;
                weakSelf2.hud = nil;
                [weakSelf2 release];
            }];
            [weakSelf.hud hide:YES];
            [retryTimer invalidate];
            [retryTimer release];
            retryTimer = nil;
            [nav release];
            [weakSelf release];
            
            
        });
    }];
    
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([picker respondsToSelector:@selector(imagePickerDelegate)])
    {
        MysticPickerViewController *pp = (id)picker;
        [(MysticPickerViewController *)picker setImagePickerDelegate:nil];
        [(MysticPickerViewController *)picker setDelegate:nil];
        
    }
    self.cameraButton.enabled = YES;
    self.albumButton.enabled = YES;
    if((id)picker != self)
    {
        [self closeCam:nil];
    }
    
}

- (void) loadPhoto:(UIImage *)image;
{
    __unsafe_unretained __block MysticIntroViewController *weakSelf = [self retain];
    
    @autoreleasepool {
        
        __unsafe_unretained __block UIImage *__image = image ? [image retain] : nil;
        
        MysticBlockObject imageBlock = ^(UIImage *img)
        {
            
            if(!img) img = __image;
            if(!img)
            {
                [weakSelf imagePickerController:(id)weakSelf didFinishPickingMediaWithInfo:@{}];
                [weakSelf albumButtonTouched:weakSelf.albumButton];
                if(__image) [__image release];
                return;
            }
            NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            [workingDictionary setObject:img forKey:UIImagePickerControllerEditedImage];
            
            [weakSelf imagePickerController:(UIImagePickerController *)weakSelf didFinishPickingMediaWithInfo:(id)@[workingDictionary]];
            
            if(__image) [__image release];
            [weakSelf release];
            
        };
        
        if(usingIOS8())
        {
            imageBlock(__image);
        }
        else
        {
            [MysticImage constrainImage:__image toSize:[MysticImage maximumImageSize] withQuality:1 finished:imageBlock];
        }
        
    }
    
}


- (void) loadLastPhoto;
{
    __unsafe_unretained __block MysticIntroViewController *weakSelf = [self retain];
    @autoreleasepool {
        [MysticLibrary fetchLastCameraRollPhoto:^(id obj, id obj2) {
            __unsafe_unretained __block UIImage *__image = obj ? [obj retain] : nil;
            __unsafe_unretained __block id __obj2 = obj2 ? [obj2 retain] : nil;
            MysticBlockObject imageBlock = ^(UIImage *img)
            {
                img = !img ? __image : img;
                if(!img)
                {
                    [weakSelf imagePickerController:(id)weakSelf didFinishPickingMediaWithInfo:@{}];
                    [weakSelf albumButtonTouched:weakSelf.albumButton];
                    if(__image) [__image release];
                    if(__obj2) [__obj2 release];
                    return;
                }
                [weakSelf imagePickerController:(UIImagePickerController *)weakSelf didFinishPickingMediaWithInfo:(id)@[@{UIImagePickerControllerOriginalImage:img, UIImagePickerControllerEditedImage:img}]];
                if(__image) [__image release];
                if(__obj2) [__obj2 release];
                [weakSelf release];
            };
            if(usingIOS8()) imageBlock(__image);
            else [MysticImage constrainImage:__image toSize:[MysticImage maximumImageSize] withQuality:1 finished:imageBlock];
        }];
    }
}


- (void) loadLastProject;
{
    if(self.promptView) return;
    NSDictionary *lastProject = [MysticUser user].lastProject;

    NSString *projectPath = [[[MysticCache projectCache].diskCachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[MysticUser user].lastProjectName];
    NSString *lImg = lastProject[@(MysticProjectKeyImageThumbPath)] ? lastProject[@(MysticProjectKeyImageThumbPath)] : lastProject[@(MysticProjectKeyImageResizedPath)];
    NSString *pImgPath = !lImg ? nil : [projectPath stringByAppendingPathComponent:lImg];
    
    
    if(!lImg || ![[NSFileManager defaultManager] fileExistsAtPath:pImgPath]) return;
    __unsafe_unretained __block MysticIntroViewController *weakSelf = self;
    if(!self.promptView)
    {
        MysticLayerTableViewCell *cell = [[MysticLayerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reloadproj"];
        cell.frame = CGRectMake(0, 0, [MysticUI screen].width, 80);
        cell.backgroundView.backgroundColor = [UIColor color:MysticColorTypePink];
        cell.textLabel.text = @"Reload last project?";
        cell.detailTextLabel.text = @"You didn't save it";
        cell.textLabel.textColor = [UIColor hex:@"eee9d9"];
        cell.textLabel.font = [MysticFont fontMedium:13];
        cell.detailTextLabel.font = [MysticFont fontMedium:10];
        cell.detailTextLabel.textColor = [UIColor hex:@"36322f"];
        cell.imageViewControl.hidden = YES;
        cell.imageViewBackground.hidden = YES;
        cell.imageView.image = [UIImage imageWithContentsOfFile:pImgPath];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.userInteractionEnabled = NO;
        MBorder(cell.imageView, [UIColor hex:@"eee9d9"], 2);
        MysticButton *b = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:(CGSize){32,32} color:cell.textLabel.textColor] target:self sel:@selector(confirmedLoadLastProject:)];
        b.frame = cell.frame;
        b.imageEdgeInsets = UIEdgeInsetsMake(0, [MysticUI screen].width - 70, 0, 0);
        UIView *c = [[MysticView alloc] initWithFrame:CGRectMake(0, [MysticUI screen].height, [MysticUI screen].width, 80)];
        [c addSubview:cell];
        [c addSubview:b];
        c.userInteractionEnabled = YES;
        [cell autorelease];
        self.promptView = [c autorelease];
        [self.view addSubview:self.promptView];
    }
    self.navigationController.toolbar.userInteractionEnabled = NO;
    if(self.promptView && self.promptView.frame.origin.y >=[MysticUI screen].height )
    {
        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.promptView.transform = CGAffineTransformMakeTranslation(0, -self.promptView.frame.size.height);
        }];
    }
}

- (void) confirmedLoadLastProject:(id)sender;
{
    [self loadProject:[MysticUser user].lastProject];
}

- (void) loadProject:(NSDictionary *)projectDict;
{

    
    NSString *projectPath = [[[MysticCache projectCache].diskCachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[MysticUser user].lastProjectName];

    NSString *imgPath = [projectDict objectForKey:@(MysticProjectKeyImageSrcPath)];
    imgPath = !imgPath ? nil : [projectPath stringByAppendingPathComponent:projectDict[@(MysticProjectKeyImageSrcPath)]];
    
    // copy all old files to new project folder
    NSError *copyError = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:projectPath toPath:[UserPotionManager projectPath] error:&copyError]) {
        DLog(@"Error copying files: %@", [copyError localizedDescription]);
    }
    
    if(!imgPath) return;
    UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
    if(!img) return;
    __unsafe_unretained __block NSDictionary *__projectDict = [projectDict retain];
    [self imagePickerController:(UIImagePickerController *)self didFinishPickingMediaWithInfo:(id)@[@{UIImagePickerControllerOriginalImage:img, UIImagePickerControllerEditedImage:img}] finished:^(MysticController *editController){
        [MysticOptions loadProject:__projectDict finished:^(MysticOptions *theOptions, BOOL active) {
            if(!active) return;
            [UserPotion useCurrentHistoryItem];
            
            [editController revealPlaceholderImage:[UserPotion potion].sourceImageResized duration:0];
            [MysticOptions reset];
            [editController setState:MysticSettingNone animated:NO complete:nil];
            [editController setNeedsDisplay];
            
//            [editController reload:@"Loading..." hudDelay:0.5 complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
//                [editController setState:MysticSettingNone animated:NO complete:nil];
//                [editController setNeedsDisplay];
//            }];
        }];
        [__projectDict release];
    }];
}





@end

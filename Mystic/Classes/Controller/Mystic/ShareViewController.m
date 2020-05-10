//
//  ShareViewController.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "NavigationViewController.h"
#import "MysticBackgroundView.h"

#import <AWSiOSSDK/AmazonEndpoints.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ShareViewController.h"
#import "MysticViewController.h"
#import "TitleBarButton.h"
#import "DEFacebookComposeViewController.h"
#import "AppDelegate.h"
#import "TitleView.h"
#import "EditPhotoViewController.h"
#import "MysticLabel.h"
#import "MysticPreferencesViewController.h"
#import "MysticWebViewController.h"
#import "MysticImage.h"
#import "MysticUI.h"
#import "NavigationBar.h"
#import "UserPotion.h"


static NSTimeInterval kHideHUDDelay = 0.4;
static CGSize saveSize, facebookSize, tweetSize, emailSize, copySize, openSize, internetSize;

@interface ShareViewController ()
{
    MBProgressHUD *HUD;
    BOOL uploaded;
    UIImage *_previewImage;
    BOOL copyTags;
}

@property (retain, nonatomic) UIImageView *photoView;

@end

@implementation ShareViewController

@synthesize photoView, cpyButton, saveButton, emailButton, tweetButton, facebookButton, openButton, dic, uniqueHash=_uniqueHash, s3, uploadURL=_uploadURL, link=_link, project=_project, recipe=_recipe, shareImage=_shareImage;

- (void)dealloc {
    [_shareImage release];
    [_previewImage release];
    [s3 release];
    [_project release];
    [_recipe release];
    [photoView release];
    [_shareControlsView release];
    [_pinButton release];
    [_photoLabel release];
    [cpyButton release];
    [saveButton release];
    [emailButton release];
    [tweetButton release];
    [facebookButton release];
    [openButton release];
    [_uniqueHash release];
    [_uploadURL release];
    [dic release];
    [_link release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_lipView release];
    [_tagsLabel release];
    [_postcardButton release];
    [super dealloc];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil image:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)img;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __unsafe_unretained __block ShareViewController *weakSelf = self;
        _shareImage = [img retain];
        _previewImage = [img retain];
        // Custom initialization
        internetSize = CGSizeMake(612/[Mystic scale], 612/[Mystic scale]);
        self.s3 = [[[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] autorelease];
        //self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_1];
        uploaded = NO;
        [self preferencesDidClose:nil];

        
        MysticBarButtonItem *rightBarItem = [MysticBarButtonItem moreButtonItem:self action:@selector(shareTouched:)];
        [self.navigationItem setRightBarButtonItem:rightBarItem animated:YES];

        
        MysticBarButton *leftButton = (MysticBarButton *)[MysticBarButton button:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(40, 40) color:@(MysticColorTypeNavBarIcon)] action:^(MysticBarButton *sender) {
            
            [weakSelf backButtonTouched:sender];
            
            
        }];
        
        
//        MysticBarButtonItem *bbItem = [MysticUI backButtonItemWithTarget:self action:@selector(backButtonTouched:)];
        
        self.navigationItem.leftBarButtonItem = [MysticBarButtonItem item:leftButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownloadingLayerImage:) name:MysticEventStartDownloadingLayerImage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedDownloadingLayerImage:) name:MysticEventFinishedDownloadingLayerImage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadingLayerImage:) name:MysticEventDownloadingLayerImage object:nil];
        
        
//        
//        MysticLabel *btmLabel = [[MysticLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//        btmLabel.text = @"Share";
//        btmLabel.inNavBar = YES;
        self.title = @"Share";
        self.navigationItem.title = @"Share";
//        [btmLabel release];
        
        
        
        
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shareControlsView.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    self.view.backgroundColor = [UIColor color:MysticColorTypeBackgroundGray];
    self.lipView.underneathColor = self.shareControlsView.backgroundColor;
    self.lipView.backgroundColor = [[UIColor color:MysticColorTypeBackgroundGray] darker:0.02];
    
    //    self.view.backgroundColor = [UIColor mysticWhiteBackgroundColor];
    
    
    self.photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.view.frame), self.photoLabel.frame.origin.y-15)] autorelease];
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    if(_previewImage)
    {
        self.photoView.image = _previewImage;
    }
    
    
    self.photoView.clipsToBounds=YES;
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.photoView addGestureRecognizer:gr];
    self.photoView.userInteractionEnabled = YES;
    [self.view insertSubview:self.photoView belowSubview:self.photoLabel];
    [gr release];
    [MysticEffectsManager clearMemory];
    
    UILongPressGestureRecognizer *gr2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tagsLongPress:)];
    [self.tagsLabel addGestureRecognizer:gr2];
    self.tagsLabel.numberOfLines = 1;
    
    
    MysticBackgroundView *bgView = [[MysticBackgroundView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    [bgView release];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.shareControlsView.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    
    self.view.backgroundColor = [UIColor color:MysticColorTypeBackgroundGray];
    self.lipView.underneathColor = self.shareControlsView.backgroundColor;
    self.lipView.backgroundColor = [[UIColor color:MysticColorTypeBackgroundGray] darker:0.02];
    //
    //    self.lipView.underneathColor = self.shareControlsView.backgroundColor;
    //    self.lipView.backgroundColor = [[UIColor mysticWhiteBackgroundColor] darker:0.05];
    
    
    self.photoView.frame = CGRectMake(70, 5, CGRectGetWidth(self.view.frame), self.photoLabel.frame.origin.y-15);
    [(NavigationBar *)self.navigationController.navigationBar setBorderStyle:NavigationBarBorderStyleBottom];
    [UIView animateWithDuration:0.3 delay:0.025 options:UIViewAnimationCurveEaseOut animations:^{
        self.photoView.frame = CGRectMake(0, 5, self.photoView.frame.size.width, self.photoView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    NSString *hashtags = [MysticEffectsManager currentOptions].hashTags;
    
    hashtags = hashtags ? [@"#MysticApp " stringByAppendingString:hashtags] : @"#MysticApp";
    
    NSArray *h = [hashtags componentsSeparatedByString:@" "];
    
    hashtags = [h componentsJoinedByString:@"  "];
    self.tagsLabel.text = hashtags;
    self.tagsLabel.highlightedTextColor = [UIColor mysticPinkColor];
    self.tagsLabel.textColor = [UIColor color:MysticColorTypeWhite];
    self.photoLabel.textColor = [[UIColor color:MysticColorTypeWhite] colorWithAlphaComponent:0.6];

}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];

    
}


- (UIImage *) shareImage;
{
    return _shareImage ? _shareImage : _previewImage;
}

- (void) setShareImage:(UIImage *)shareImage;
{
    
    if(_shareImage) [_shareImage release], _shareImage=nil;
    _shareImage = [shareImage retain];
    self.photoView.image = shareImage;
    
    CGRect lrect = CGRectMake(self.view.frame.size.width-60, self.photoLabel.frame.origin.y, 50, self.photoLabel.frame.size.height);
    UILabel *shareReadyLabel = [[UILabel alloc] initWithFrame:lrect];
    shareReadyLabel.font = self.photoLabel.font;
    shareReadyLabel.text = @"READY!";
    shareReadyLabel.textAlignment = NSTextAlignmentRight;
    shareReadyLabel.textColor = self.photoLabel.textColor;
    shareReadyLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:shareReadyLabel];
    [shareReadyLabel release];

    
    
}

- (void) shareTouched:(id)sender;
{
    UIActionSheet *sheet;
//    NSString *sharePotionStr = [Mystic isRiddleAnswer:MysticChiefPassword] ? @"Feature Potion" : @"Share Potion";
    if(self.recipe)
    {
//        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Over", @"Save Potion", @"Share Project",  nil];
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Over", nil];

        sheet.tag = 1110;
    }
    else
    {
//        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Over", @"Save Potion", sharePotionStr, @"Share Project",  nil];
        
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Over",   nil];

        sheet.tag = 1111;
    }
    
    
    [sheet showInView:self.view];
    [sheet release];
}

- (void) shareProject;
{
    if(!self.project)
    {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"Creating Project...";
        HUD.dimBackground = YES;
        
            
        
        
            
            [UserPotion saveAndUploadProject:nil image:self.shareImage finished:^(MysticProject *aproject, BOOL success) {
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                HUD.mode = MysticProgressHUDModeCustomView;
                HUD.delegate = self;
                HUD.labelText = @"Project Created!";
                [HUD hide:NO];
                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message", @"Email", @"Facebook", @"Tweet", @"Copy Link", nil];
                sheet.tag = 1112;
                [sheet showInView:self.view];
                self.project = aproject;
            }];
            
    }
    else
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message", @"Email", @"Facebook", @"Tweet", @"Copy Link", nil];
        sheet.tag = 1112;
        [sheet showInView:self.view];
    }
}

- (void) sharePotion;
{
    
    
    if(self.recipe)
    {
        return;
    }
//    
//    [MysticAlert show:title message:alertMessage action:^(id object) {
//        
//    } cancel:^(id object) {
//        
//    } options:@{@"button": confirmTitle, @"cancelTitle":cancel}];
//
    
    [MysticAlert input:NSLocalizedString(@"Share Potion", nil) message:NSLocalizedString(@"What do you want to call it?", nil) action:^(id object, MysticAlert *alert) {
        NSString *pname = [alert.firstInput.text lowercaseString];
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = [Mystic isRiddleAnswer:MysticChiefPassword] ? NSLocalizedString(@"Featuring Potion...", nil) : NSLocalizedString(@"Sharing Potion...", nil);
        HUD.dimBackground = YES;
        
        
        [UserPotion saveAndUploadRecipe:pname image:self.shareImage finished:^(MysticProject *aproject, BOOL success) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MysticProgressHUDModeCustomView;
            HUD.delegate = self;
            HUD.labelText = [Mystic isRiddleAnswer:MysticChiefPassword] ? NSLocalizedString(@"Potion Featured!", nil) : NSLocalizedString(@"Potion Shared!", nil);
            [HUD hide:NO];
            
            self.recipe = aproject;
        }];
    } cancel:^(id object, MysticAlert *alert) {
        
    } inputs:@[@"Type Name..."] options:@{@"controller": self, @"cancelTitle": @"Cancel", @"button": @"Share"}];
    
    
}

- (void) savePotion;
{
    
    
    if(self.recipe)
    {
        return;
    }
//    [MysticAlert show:@"Save Potion" message:(NSString *) action:<#^(id object)ok#> cancel:<#^(id object)cancel#> options:<#(NSDictionary *)#>]
    
    [MysticAlert input:NSLocalizedString(@"Save Potion", nil) message:NSLocalizedString(@"What do you want to call it?", nil) action:^(id object, MysticAlert *alert) {
        NSString *pname = [alert.firstInput.text lowercaseString];
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Saving Potion...", nil);
        HUD.dimBackground = YES;
        
        
        [[MysticUser user] savePotion:pname image:self.shareImage finished:^(MysticProject *aproject, BOOL success) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MysticProgressHUDModeCustomView;
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"Saved!", nil);
            [HUD hide:NO];
            
            self.recipe = aproject;
        }];
    } cancel:^(id object, MysticAlert *alert) {
        
    } inputs:@[@"Type Name..."] options:@{@"controller": self, @"cancelTitle": @"Cancel", @"button": @"Save"}];
    
    
    
    
    
    
    
}


- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
//    const NSUInteger shareTag;
//    const NSUInteger projectTag;
    
    switch (actionSheet.tag) {
        case 1110:
        {
            switch (buttonIndex) {
                case 0:
                    // new photo
                    [self forwardButtonTouched:nil];
                    
                    break;
                case 1:
                {
                    [self savePotion];
                    break;
                }
                case 2:
                {
                    [self shareProject];
                    break;
                }
                
                default:
                    break;
            }
            
            break;
        }
        case 1111:
        {
            switch (buttonIndex) {
                case 0:
                    // new photo
                    [self forwardButtonTouched:nil];
                    
                    break;
                case 1:
                {
                    [self savePotion];
                    break;
                }
                case 2:
                {
                    [self sharePotion];
                    break;
                }
                case 3:
                {
                    [self shareProject];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1112:
        {
            switch (buttonIndex) {
                case 0:
                {
                    // new photo
                    // message photo
                    [self messageProject];
                    break;
                }
                case 1:
                {
                    // email photo
                    [self emailProject];
                    break;
                }
                case 2:
                {
                    [self postProject];
                    // facebook photo
                    break;
                }
                case 3:
                {
                    [self tweetProject];
                    // tweet photo
                    break;
                }
                case 4:
                {
                     [UIPasteboard generalPasteboard].string = self.project.shareURL;
                    // tweet photo
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
        {
//            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
            break;
        }
            
    }
    
}



- (void) logoTouched:(id)sender
{
    MysticViewController *viewController = [[MysticViewController alloc] initWithNibName:@"MysticViewController" bundle:nil];
    if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }
    else
    {
        [self presentModalViewController:viewController animated:YES];
    }
    
    [viewController release];
}

- (void) viewDidUnload;
{
    self.photoView.image = nil;
    self.shareImage = nil;
    self.uniqueHash = nil;
    [self setPhotoView:nil];
    [self setShareControlsView:nil];
    [self setPinButton:nil];
    [self setPhotoLabel:nil];
    [self setTagsLabel:nil];
    [self setPostcardButton:nil];
    [super viewDidUnload];
}

- (void) viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
//    self.photoView.image = nil;
//    self.shareImage = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void) startDownloadingLayerImage:(NSNotification *)notification;
{
//    DLog(@"start downloading layer image");
    if(!HUD)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        HUD.completionBlock = NULL;
        HUD.dimBackground = YES;
        
        [HUD show:YES];
    }
    
    [HUD setMode:MysticProgressHUDModeAnnularDeterminate];
    HUD.progress = 0.0f;
    
}
- (void) downloadingLayerImage:(NSNotification *)notification;
{
    NSDictionary *userInfo = notification.userInfo;
    if(HUD)
    {
        CGFloat ds = (CGFloat)[[userInfo objectForKey:@"downloaded"] floatValue];
        CGFloat ts = (CGFloat)[[userInfo objectForKey:@"total"] floatValue];
        HUD.progress = (CGFloat)(ds/ts);
    }
}
- (void) finishedDownloadingLayerImage:(NSNotification *)notification;
{
//    DLog(@"finished downloading layer image");
    if(HUD)
    {
        HUD.progress = 1.0f;
        [HUD setMode:MysticProgressHUDModeIndeterminate];

        
    }
}

- (void) tagsLongPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    copyTags = YES;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        self.tagsLabel.highlighted = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        //        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Crop" action:@selector(menuItemClicked:)];
        //        UIMenuItem *mergeMenuItem = [[UIMenuItem alloc] initWithTitle:@"Merge" action:@selector(mergeItemClicked:)];
        
        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
        //        [menuController setMenuItems:[NSArray arrayWithObjects:/*resetMenuItem,*/ mergeMenuItem, nil]];
        
        CGPoint p = [gestureRecognizer locationInView:self.view];
        
        CGSize s = [self.tagsLabel.text sizeWithFont:self.tagsLabel.font constrainedToSize:self.tagsLabel.frame.size];
        
        p.x = self.tagsLabel.frame.origin.x + s.width/2;
        
        CGRect pointRect = CGRectMake(p.x, p.y, 0.0f, 0.0f);
        
        [menuController setTargetRect:pointRect inView:self.view];
        [menuController setMenuVisible:YES animated:YES];
        //        [resetMenuItem release];
        //        [mergeMenuItem release];
    }
}

- (void) menuDidHide:(NSNotification *)notification;
{
    copyTags = NO;
    self.tagsLabel.highlighted = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void) longPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
//        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Crop" action:@selector(menuItemClicked:)];
        
//        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
//        [menuController setMenuItems:[NSArray arrayWithObjects:resetMenuItem, mergeMenuItem, nil]];
        CGRect pointRect = CGRectMake([gestureRecognizer view].center.x, [gestureRecognizer view].center.y, 0.0f, 0.0f);
        
        [menuController setTargetRect:pointRect inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        //[resetMenuItem release];
    }
}

- (void) copy:(UIMenuController *) sender {
    // called when copy clicked in menu
    if(copyTags)
    {
        NSString *hashtags = self.tagsLabel.text;
        
//        hashtags = [[h componentsJoinedByString:@" "] stringByAppendingString:@" #mystic"];
        
        
        
         [UIPasteboard generalPasteboard].string = hashtags;
        
        
    }
    else
    {
        [self copyImage:nil];
    }
}


- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


- (void) backButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) forwardButtonTouched:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate newProject];
    
    
}

- (void) settingsButtonTouched:(id)sender
{
    MysticPreferencesViewController *preferencesViewController = [[MysticPreferencesViewController alloc] initWithNibName:@"MysticPreferencesViewController" bundle:nil];
    preferencesViewController.delegate = self;
    if([self.navigationController respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self.navigationController presentViewController:preferencesViewController animated:YES completion:^{
            
            
        }];
    }
    else
    {
        [self.navigationController presentModalViewController:preferencesViewController animated:YES];
    }
    [preferencesViewController release];
    
    
}

- (void) preferencesDidClose:(MysticPreferencesViewController *)preferencesViewController;
{
    CGSize outputSize = [MysticPreferencesViewController exportImageSize];
    
    saveSize = outputSize;
    facebookSize = outputSize;
    tweetSize = outputSize;
    emailSize = outputSize;
    copySize = outputSize;
    openSize = outputSize;
    
//    
//    if([MysticPreferencesViewController usingHighQuality])
//    {
//
//        
//        CGSize outputSize = CGSizeMake(3000/[Mystic scale], 3000/[Mystic scale]);
//        
//        if([MysticUI isIPhone5])
//        {
//            outputSize = CGSizeMake(2048/[Mystic scale], 2048/[Mystic scale]);
//        }
//        
//        saveSize = outputSize;
//        facebookSize = outputSize;
//        tweetSize = outputSize;
//        emailSize = outputSize;
//        copySize = outputSize;
//        openSize = outputSize;
//        
//    }
//    else
//    {
////        DLog(@"low quality");
//        
//        CGSize outputSize = CGSizeMake(612/[Mystic scale], 612/[Mystic scale]);
//        
//        saveSize = outputSize;
//        facebookSize = outputSize;
//        tweetSize = outputSize;
//        emailSize = outputSize;
//        copySize = outputSize;
//        openSize = outputSize;
//    }
}


#pragma mark - Copy




- (IBAction)copyImage:(id)sender;
{
    copyTags = NO;
    [[UIPasteboard generalPasteboard] setData:UIImageJPEGRepresentation(self.shareImage, 1.0)
                            forPasteboardType:@"public.jpeg"];
}


#pragma mark - Save

- (IBAction)save:(id)sender;
{
    if(![MysticPreferencesViewController usingMysticAlbum])
    {
        [self saveToPhotoAlbum:sender];
        return;
    }

    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"Saving";
    HUD.dimBackground = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *finalImage = self.shareImage;
            [[Mystic sharedLibrary] saveImage:finalImage toAlbum:@"Mystic" withCompletionBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                
                    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                    HUD.mode = MysticProgressHUDModeCustomView;
                    HUD.delegate = self;
                    HUD.labelText = @"Saved";
                    

                    [HUD hide:YES afterDelay:kHideHUDDelay];
                });
                
                
                
                if (error!=nil) {
                    NSLog(@"Big error: %@", [error description]);
                }
                
                [self uploadImage:finalImage finished:^(NSURL *uploadedImageURL){
                    //                    DLog(@"finished uploading image");
                } failed:nil];
            }];
            
    });
}

- (IBAction)saveToPhotoAlbum:(id)sender;
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"Saving";
    HUD.dimBackground = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(self.shareImage,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            
    });
}

- (void) image: (UIImage *) anImage
didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo
{
    if(error)
    {
        
        return;
    }
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.mode = MysticProgressHUDModeCustomView;
    HUD.delegate = self;
	HUD.labelText = @"Saved";
    [self uploadImage:anImage finished:^(NSURL *uploadedImageURL){
        
    } failed:nil];
    [NSTimer wait:kHideHUDDelay block:^{
        [HUD hide:YES];
    }];
}

#pragma mark - Email

- (IBAction)email:(id)sender;
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"mystifying";
    HUD.dimBackground = YES;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Do something...
        if(![MFMailComposeViewController canSendMail])
        {
            [HUD hide:YES];
            return;
        }
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        
        [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:emailSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * emailImage) {

        

            emailer.mailComposeDelegate = self;
            [emailer setSubject:[[MysticEffectsManager currentOptions] message:@"Mystic Photo" prefix:nil type:MysticShareTypeEmailSubject]];
            
            NSString *emailBody = [[MysticEffectsManager currentOptions] message:nil prefix:nil type:MysticShareTypeEmail];
            
            if(emailBody) [emailer setMessageBody:emailBody isHTML:NO];
            
            NSString *emailTo = [[MysticEffectsManager currentOptions] message:nil prefix:nil type:MysticShareTypeEmailTo];
            
            if(emailTo) [emailer setToRecipients:[NSArray arrayWithObject:emailTo]];
            
            [emailer addAttachmentData:UIImageJPEGRepresentation(emailImage,1) mimeType:@"jpg" fileName:[NSString stringWithFormat:@"MysticImage-%2.0f.jpg", [NSDate timeIntervalSinceReferenceDate]]];
            
            [HUD hide:YES];
            if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
            {
                [self presentViewController:emailer animated:YES completion:^{
                    
                }];
            }
            else
            {
                [self presentModalViewController:emailer animated:YES];
            }
            
            [self uploadImage:emailImage finished:^(NSURL *uploadedImageURL){
                
            } failed:nil];
            
            [emailer release];
            
        }];
    });
    
}

- (void)emailProject;
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"mystifying";
    HUD.dimBackground = YES;
    
    
    // Do something...
    if(![MFMailComposeViewController canSendMail])
    {
        [HUD hide:YES];
        return;
    }
    MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
    UIImage *emailImage = [MysticEffectsManager renderedImage];
    
    emailer.mailComposeDelegate = self;
    [emailer setSubject:NSLocalizedString(@"Remix my MYSTIC", nil)];
    
    
    
    [emailer setMessageBody:[NSString stringWithFormat:@"To remix my MYSTIC, click this link: %@", self.project.shareURL] isHTML:NO];
    [emailer addAttachmentData:UIImageJPEGRepresentation(emailImage,1) mimeType:@"jpg" fileName:[NSString stringWithFormat:@"MysticProject-%2.0f.jpg", [NSDate timeIntervalSinceReferenceDate]]];
    
    [HUD hide:YES];
    if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self presentViewController:emailer animated:YES completion:^{
            
        }];
    }
    else
    {
        [self presentModalViewController:emailer animated:YES];
    }
    
    
    
    [emailer release];
    
}


- (void)messageProject;
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"mystifying";
    HUD.dimBackground = YES;
    
    
        // Do something...
        if(![MFMessageComposeViewController canSendText])
        {
            [HUD hide:YES];
            return;
        }
        MFMessageComposeViewController *emailer = [[MFMessageComposeViewController alloc] init];
    
            emailer.messageComposeDelegate = self;
            emailer.body = [NSString stringWithFormat:@"remix my MYSTIC: %@", self.project.shareURL];
            
            
            
            //[emailer setMessageBody:[UserPotion potion].currentTag isHTML:YES];
            
            [HUD hide:YES];
            if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
            {
                [self presentViewController:emailer animated:YES completion:^{
                    
                }];
            }
            else
            {
                [self presentModalViewController:emailer animated:YES];
            }
            
           
            
            [emailer release];
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            //DLog(@"eemail dismissed");
        }];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                         message:NSLocalizedString(@"Email failed to send. Please try again.", nil)
                                                        delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] autorelease];
		[alert show];
    }
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            //DLog(@"eemail dismissed");
        }];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Tweet


- (IBAction)tweet:(id)sender;
{
    
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"mystifying";
        HUD.dimBackground = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do something...
            [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:tweetSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * twitterImage) {

            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                
                    TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
                    
                    NSString *tweetText = [[MysticEffectsManager currentOptions] message:@" " prefix:nil type:MysticShareTypeTwitter];

                    NSString *messageLink = [[MysticEffectsManager currentOptions] message:@"http://mysti.ch" prefix:nil type:MysticShareTypeLink];
                    
                    NSString *hashTags = [[self.tagsLabel.text componentsSeparatedByString:@"  "] componentsJoinedByString:@" "];
                    
                    tweetText = [tweetText stringByAppendingFormat:@" %@", hashTags];
                    
                    [vc setInitialText:tweetText];
                    
                    // Adding an Image
                    [vc addImage:twitterImage];
                    
                    
                    
                    [vc addURL:[NSURL URLWithString:messageLink]];
                    
                    
                    
                    // Setting a Completing Handler
                    [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                        [self dismissModalViewControllerAnimated:YES];
                        if(result == TWTweetComposeViewControllerResultCancelled)
                        {
                            
                        }
                        else if(result == TWTweetComposeViewControllerResultDone)
                        {
                            
                        }
                    }];
                    if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
                    {
                        [self presentViewController:vc animated:YES completion:^{
                            [HUD hide:YES];
                        }];
                    }
                    else
                    {
                        [self presentModalViewController:vc animated:YES];
                        [HUD hide:YES];
                    }
                    // Display Tweet Compose View Controller Modally
                    [vc release];
                });
                
                [self uploadImage:twitterImage finished:^(NSURL *uploadedImageURL){
                    
                } failed:nil];
            }];
            
            
        });
        
    } else {
        // Show Alert View When The Application Cannot Send Tweets
        NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
        [alertView show];
        
    }
}

- (void)tweetProject;
{
    
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"mystifying";
        HUD.dimBackground = YES;
        UIImage *twitterImage = [MysticEffectsManager renderedImage];
        
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // Do something...
            
            
        dispatch_async(dispatch_get_main_queue(), ^{

                // Initialize Tweet Compose View Controller
                TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
                
                
                [vc setInitialText:@"remix my MYSTIC"];
                
                // Adding an Image
                [vc addImage:twitterImage];
                
                
                if(self.project.shareURL) [vc addURL:[NSURL URLWithString:self.project.shareURL]];
                
                
                
                // Setting a Completing Handler
                [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                    [self dismissModalViewControllerAnimated:YES];
                    if(result == TWTweetComposeViewControllerResultCancelled)
                    {
                        
                    }
                    else if(result == TWTweetComposeViewControllerResultDone)
                    {
                        
                    }
                }];
                if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
                {
                    [self presentViewController:vc animated:YES completion:^{
                        [HUD hide:YES];
                    }];
                }
                else
                {
                    [self presentModalViewController:vc animated:YES];
                    [HUD hide:YES];
                }
                // Display Tweet Compose View Controller Modally
                [vc release];
                
                
        });
        
    } else {
        // Show Alert View When The Application Cannot Send Tweets
        NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
        [alertView show];
        
    }
}


#pragma mark - Facebook post

- (IBAction)post:(UIButton *)sender;
{
    // First attempt: Publish using the Facenook Share dialog
    
    if(![Mystic useNativeShare] || ![Mystic trackDiagnostics] /*|| [MysticPreferencesViewController photosArePrivate]*/)
    {
        [self publishWithMysticFBDialog];
        return;
    }
    [self publishWithShareDialog:^(BOOL openedShareDialog) {
        
        if (!openedShareDialog) {
            if(HUD) [HUD hide:NO];
            [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:facebookSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * renderImage) {

            
                BOOL displayedNativeDialog = [self publishWithOSIntegratedShareDialog:renderImage];
                
                
                // Third fallback: Publish using either the Graph API or the Feed dialog
                if (!openedShareDialog && !displayedNativeDialog) {
                    [self publishWithMysticFBDialog];
                }
                
                [self uploadImage:renderImage finished:^(NSURL *uploadedImageURL){
                    
                } failed:nil];
                
            }];
        }
    }];
    
    
    
    
    
            
    
    
}

- (BOOL) publishWithShareDialog:(MysticBlockBOOL)finished; {
    
    
    
    
    
    
    
    NSString *objectURL = [self mysticURLString];
    NSString *imageURL = [self imageURLString];
    //
    //
    //    DLog(@"Image Object: %@", imageURL);
    //
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:objectURL];
    params.picture = [NSURL URLWithString:imageURL];
    
    params.name = @"photo";
    params.caption = nil;
//    params.description = @" ";
    
    BOOL canIt = [FBDialogs canPresentShareDialogWithParams:params];
    [params release];
    if(!canIt) { if(finished) finished(NO); return canIt; }
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.mystic.EditPhotoViewControllerRenderQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"mystifying";
        HUD.dimBackground = YES;
        
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        
        dispatch_async(queue, ^{
            
            
            
            // Do something...
            CGSize newSize = [MysticUI scaleSize:[UserPotion potion].renderSize bounds:CGSizeMake(800, 800)];
            [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:newSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * renderImage) {

                
                NSData *imageData = UIImageJPEGRepresentation(renderImage, 0.7);
    //            renderImage = [UIImage imageWithData:imageData];
                
                NSDictionary *uploadParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                              imageData,@"data",
                                              [NSString stringWithFormat:@"%@_l.jpg", self.uniqueHash], @"filename",
                                              @"file", @"name",
                                              @"image/jpeg", @"mime",
                                              nil];
                
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        objectURL, @"url",
                                        imageURL, @"photo",
                                        [self folderName], @"group",
                                        [MysticPreferencesViewController photosArePrivate] ? @"YES" : @"NO", @"private",
                                        nil];
                
                if(HUD) [HUD setMode:MysticProgressHUDModeAnnularDeterminate];
                [MysticAPI upload:@"/photo/upload" params:params upload:uploadParams progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                    
                    
                    if(HUD)
                    {
                        
                        CGFloat ds = (CGFloat)totalBytesWritten;
                        CGFloat ts = (CGFloat)totalBytesExpectedToWrite;
                        HUD.progress = (CGFloat)(ds/ts);
                    }
                    
                    
                } complete:^(NSDictionary *results, NSError *error) {
                    
                        
                        if(error)
                        {
                            HUD.labelText = @"Error";
                            if(finished) finished(NO);
                            return;
                        }
                        HUD.labelText = @"Uploaded";
                        
                        self.link = [results objectForKey:@"link"];
                        NSArray* images = @[@{@"url": renderImage, @"user_generated" : @"true" }];
                    
                    
                    
                    id<FBGraphObject> photoObject = [FBGraphObject openGraphObjectForPostWithType:@"__mystic__:photo"
                                                                                            title:@"photo"
                                                                                            image:imageURL
                                                                                              url:self.link
                                                                                      description:@" "];
                    
                    
                    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                    [action setObject:photoObject forKey:@"photo"];
                    [action setObject:images forKey:@"image"];
                    
                    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                                            actionType:@"__mystic__:make"
                                                            previewPropertyName:@"photo"
                                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     if(error) {
                                                                         
                                                                         
                                                                         [self handleAPICallError:error];
                                                                         if(HUD)
                                                                         {
                                                                             HUD.labelText = @"Error";
                                                                             [NSTimer wait:kHideHUDDelay+1.5 block:^{
                                                                                 [HUD hide:YES];
                                                                             }];
                                                                         }
                                                                         
                                                                     } else {
                                                                             if(HUD)
                                                                             {
                                                                                 HUD.delegate = self;
                                                                                 
                                                                                 if([[results objectForKey:@"completionGesture"] isEqualToString:@"cancel"])
                                                                                 {
                                                                                     HUD.labelText = nil;
                                                                                     [HUD hide:NO];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     HUD.labelText = @"Posted";
                                                                                     HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                                                                                     HUD.mode = MysticProgressHUDModeCustomView;
                                                                                     
                                                                                     [NSTimer wait:kHideHUDDelay+1.5 block:^{
                                                                                         [HUD hide:YES];
                                                                                     }];
                                                                                 }
                                                                                 
                                                                                 
                                                                             }
                                                                             if(finished) finished(YES);
                                                                         
                                                                     }
                                                                });
                                                             }];
                    
                    
                    
                }];
            }];
        });
            
    });
    
    return YES;
    
    
}

- (void) publishWithMysticFBDialog;
{
    dispatch_async(dispatch_get_main_queue(), ^{

     HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
     HUD.delegate = self;
     HUD.labelText = @"mystifying";
     HUD.dimBackground = YES;
        
    });
     
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         // Do something...
         //facebookSize
         [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:facebookSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * facebookImage) {

             
              
              self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
         
          dispatch_async(dispatch_get_main_queue(), ^{
              
              DEFacebookComposeViewController * compose = [[DEFacebookComposeViewController alloc] init];
              
              [compose setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
                  
                  if([compose isKindOfClass:[DEFacebookComposeViewController class]])
                  {
                      [self.navigationController dismissModalViewControllerAnimated:YES];
                  }
                  
                  switch (result) {
                      case DEFacebookComposeViewControllerResultCancelled:
                          break;
                      case DEFacebookComposeViewControllerResultDone:
                          
                          break;
                  }
              }];
              
              NSString *facebookText = [[MysticEffectsManager currentOptions] message:@"made with " prefix:nil type:MysticShareTypeFacebook];
              
              NSString *messageLink = [[MysticEffectsManager currentOptions] message:@"http://mysti.ch" prefix:nil type:MysticShareTypeLink];
              
              
              facebookText = [facebookText stringByAppendingFormat:@" %@", messageLink];
              
              NSString *hashTags = [[self.tagsLabel.text componentsSeparatedByString:@"  "] componentsJoinedByString:@" "];
              
              facebookText = [facebookText stringByAppendingFormat:@" %@", hashTags];
              
              [compose setInitialText:facebookText];

              
              [compose addImage:facebookImage];
              if([compose isKindOfClass:[DEFacebookComposeViewController class]])
              {
                  compose.userFromViewController = self.navigationController;
              }
              if([self.navigationController respondsToSelector:@selector(presentViewController:animated:completion:)])
              {
                 

                  [HUD hide:YES];
                  [self.navigationController presentViewController:compose animated:YES completion:^{
                      
                  }];
                      
                  
              }
              else
              {
                  [self.navigationController presentModalViewController:compose animated:YES];
                  [HUD hide:YES];
              }
              [compose release];
                                 });
         }];
     });
}



- (void) postProject;
{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"mystifying";
    HUD.dimBackground = YES;
    
        // Do something...
        

        
        UIImage *facebookImage = self.shareImage;
        
             self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
             
             DEFacebookComposeViewController * compose = [[DEFacebookComposeViewController alloc] init];
             
             [compose setCompletionHandler:^(DEFacebookComposeViewControllerResult result) {
                 
                 if([compose isKindOfClass:[DEFacebookComposeViewController class]])
                 {
                     [self.navigationController dismissModalViewControllerAnimated:YES];
                 }
                 
                 switch (result) {
                     case DEFacebookComposeViewControllerResultCancelled:
                         break;
                     case DEFacebookComposeViewControllerResultDone:
                         
                         break;
                 }
             }];
             [compose setInitialText:[NSString stringWithFormat:@"remix my MYSTIC: %@", self.project.shareURL]];
             
             
             [compose addImage:facebookImage];
             if([compose isKindOfClass:[DEFacebookComposeViewController class]])
             {
                 compose.userFromViewController = self.navigationController;
             }
             if([self.navigationController respondsToSelector:@selector(presentViewController:animated:completion:)])
             {
                 [HUD hide:YES];
                 [self.navigationController presentViewController:compose animated:YES completion:^{
                     
                 }];
             }
             else
             {
                 [self.navigationController presentModalViewController:compose animated:YES];
                 [HUD hide:YES];
             }
             [compose release];
             
}


- (void) publishWithWebDialog; {
    // Put together the dialog parameters
    
}

/*
 * Helper method to parse URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return [params autorelease];
}

- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                }
                                                //For this example, ignore errors (such as if user cancels).
                                            }];
    } else {
        action();
    }
    
}
- (NSString *) folderName;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return folderName ? folderName : PICTURE_USER_UPLOADS;
}
- (NSString *) mysticURLString;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return [NSString stringWithFormat:@"http://mysti.ch/i/%@%@", (folderName ? [NSString stringWithFormat:@"%@/", folderName] : @""), self.uniqueHash];
}

- (NSString *) mysticPhotoArtURLString;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return [NSString stringWithFormat:@"http://my.mysti.ch/art/%@%@", (folderName ? [NSString stringWithFormat:@"%@/", folderName] : @""), self.uniqueHash];
}

- (NSString *) imageURLString;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return [NSString stringWithFormat:@"http://i.mysti.ch/%@/%@_l.jpg", (folderName ? folderName : PICTURE_USER_UPLOADS), self.uniqueHash];
}

- (NSString *) thumbnailURLString;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return [NSString stringWithFormat:@"http://i.mysti.ch/%@/%@_s.jpg", (folderName ? folderName : PICTURE_USER_UPLOADS), self.uniqueHash];
}

- (NSString *) facebookOGPURLString;
{
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : nil;
    return [NSString stringWithFormat:@"http://mysti.ch/ogp/%@%@", (folderName ? [NSString stringWithFormat:@"%@/", folderName] : @""), self.uniqueHash];
}



// Helper method to handle errors during API calls
- (void)handleAPICallError:(NSError *)error
{
    // Some Graph API errors are retriable. For this sample, we will have a simple
    // retry policy of one additional attempt.
    if (error.fberrorCategory == FBErrorCategoryRetry ||
        error.fberrorCategory == FBErrorCategoryThrottling) {
        // We also retry on a throttling error message. A more sophisticated app
        // should consider a back-off period.
        
        
    }
    
    // People can revoke post permissions on your app externally so it
    // can be worthwhile to request for permissions again at the point
    // that they are needed. This sample assumes a simple policy
    // of re-requesting permissions.
    if (error.fberrorCategory == FBErrorCategoryPermissions) {
        NSLog(@"Re-requesting permissions");
        // Recovery tactic: Ask for required permissions.
//        [self requestPermissionCallAPI];
        return;
    }
    
    NSString *alertTitle, *alertMessage;
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else {
        DLog(@"Unknown error: %d", (int)error.fberrorCategory);
        DLog(@"Message: %@", error.fberrorUserMessage);
        DLog(@"Unexpected error posting to open graph: %@", error);
        alertTitle = @"Unknown error";
        alertMessage = @"Unable to post to Facebook. Please try again later.";
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}




- (BOOL) publishWithOSIntegratedShareDialog:(UIImage *)renderedImage {
    
    
    NSString *facebookText = [[MysticEffectsManager currentOptions] message:@"made with " prefix:nil type:MysticShareTypeFacebook];
    
    NSString *messageLink = [[MysticEffectsManager currentOptions] message:@"http://mysti.ch" prefix:nil type:MysticShareTypeLink];
    
    
    NSString *hashTags = [[self.tagsLabel.text componentsSeparatedByString:@"  "] componentsJoinedByString:@" "];
    
    facebookText = [facebookText stringByAppendingFormat:@" %@", hashTags];
    
    BOOL canIt = [FBDialogs
            presentOSIntegratedShareDialogModallyFrom:self.navigationController
            initialText:facebookText
            image:renderedImage
            url:[NSURL URLWithString:messageLink]
            handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                // Only show the error if it is not due to the dialog
                // not being supported, otherwise ignore because our fallback
                // will show the share view controller.
                if ([[error userInfo][FBErrorDialogReasonKey]
                     isEqualToString:FBErrorDialogNotSupported]) {
                    return;
                }
                if (error) {
                    //[self showAlert:[self checkErrorMessage:error]];
                    DLog(@"ios native: error: %@", error);
                } else if (result == FBNativeDialogResultSucceeded) {
                    //[self showAlert:@"Posted successfully."];
                    
                    DLog(@"fb success!!");
                }
            }];
    if(canIt)
    {
        if(HUD) [HUD hide:NO];
    }
    return canIt;
}







#pragma mark - Open in... Instagram

- (IBAction)open:(id)sender;
{
     dispatch_async(dispatch_get_main_queue(), ^{
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            HUD.delegate = self;
            HUD.labelText = @"mystifying";
            HUD.dimBackground = YES;
         
     });
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Do something...
        [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:openSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * instaImage) {

        
        // openSize
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagramImage.ig"];
            NSString *error = nil;
            NSData *imageData = UIImageJPEGRepresentation(instaImage, 1);
            
            
            
            if(imageData) {
                [imageData writeToFile:jpgPath atomically:YES];
            }
            else {
                DLog(@"Error : %@",error);
                [error release];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[[NSString alloc] initWithFormat:@"file://%@", jpgPath] autorelease]];
                
                NSString *messageText = [[MysticEffectsManager currentOptions] message:@"made with " prefix:nil type:MysticShareTypeFacebook];
                
                
                
                
                NSString *hashTags = [[self.tagsLabel.text componentsSeparatedByString:@"  "] componentsJoinedByString:@" "];
                
                messageText = [messageText stringByAppendingFormat:@" %@", hashTags];
                if(![MysticPreferencesViewController photosArePrivate])
                {
                    messageText = [@"\n\n\n\n" stringByAppendingString:messageText];
                }
                
                self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
                self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
                self.dic.annotation = [NSDictionary dictionaryWithObject:messageText forKey:@"InstagramCaption"];
                self.dic.UTI = @"com.instagram.photo";
                [self.dic presentOpenInMenuFromRect:self.view.frame    inView: self.view animated: YES ];
                [igImageHookFile release];
                
            });
            
            
            [self uploadImage:instaImage finished:^(NSURL *uploadedImageURL){
                
            } failed:nil];
            
        }];
            
            
    });
}

- (IBAction)pinImage:(id)sender {
    

    
     dispatch_async(dispatch_get_main_queue(), ^{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = @"mystifying";
    HUD.dimBackground = YES;
         
     });
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Do something...
        
        //internetSize
        
        [MysticImage constrainImage:self.shareImage toSize:[MysticUI scaleSize:internetSize scale:[Mystic scale]] withQuality:1 finished:^(UIImage * renderImage) {

            
            if(HUD) HUD.labelText = @"Uploading";
            
            [self uploadImage:renderImage finished:^(NSURL *uploadedImageURL){
                NSString *htmlString = [self generatePinterestHTMLForURL:uploadedImageURL];
                //    NSLog(@"Generated HTML String:%@", htmlString);
                
                
                UINib*      aNib = [[UINib nibWithNibName:@"NavigationViewController" bundle:nil] retain];
                NSArray*    topLevelObjs = [aNib instantiateWithOwner:self options:nil];
                NavigationViewController *nav = [[topLevelObjs lastObject] retain];
                [aNib release];
                
                
                
                
                MysticWebViewController *webViewController = [[MysticWebViewController alloc] initWithNibName:@"MysticWebViewController" bundle:nil];
                webViewController.htmlString = htmlString;
                webViewController.showSpinner = YES;
                
                webViewController.navigationItem.rightBarButtonItem = [MysticUI closeButtonItem:^{
                    [self.navigationController dismissModalViewControllerAnimated:YES];
                }];
                
                
                nav.viewControllers = [NSArray arrayWithObject:webViewController];
                [webViewController release];
                
                [self.navigationController presentModalViewController:nav animated:YES];
                [nav release];
                [HUD hide:YES];
                
            } failed:^(NSError *error){
                
                [MysticAlert notice:@"Error" message:@"We were unable to upload your image for pinterest. Please try again later." action:nil options:nil];
                
                [HUD hide:NO];
            }];
        }];
    });
}

- (NSString*) generatePinterestHTMLForURL:(NSURL*)url {
    NSString *description = @"Mystic Image";
    
    // Generate urls for button and image
    NSString *sUrl = [url absoluteString];
//    NSLog(@"URL:%@", sUrl);
    NSString *protectedUrl = ( NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,( CFStringRef)sUrl, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
//    NSLog(@"Protected URL:%@", protectedUrl);
    NSString *imageUrl = [NSString stringWithFormat:@"\"%@\"", sUrl];
    NSString *buttonUrl = [NSString stringWithFormat:@"\"http://pinterest.com/pin/create/button/?url=www.mysti.ch&media=%@&description=%@\"", protectedUrl, description];
    [protectedUrl release];
    NSMutableString *htmlString = [[NSMutableString alloc] initWithCapacity:1000];
    [htmlString appendFormat:@"<html> <body>"];
    
    [htmlString appendFormat:@"<p align=\"center\"><img width=\"300px\" height = \"300px\" src=%@></img></p>", imageUrl];
    [htmlString appendFormat:@"<p align=\"center\"><a href=%@ class=\"pin-it-button\" count-layout=\"horizontal\"><img border=\"0\" src=\"http://assets.pinterest.com/images/PinExt.png\" title=\"Pin It\" /></a></p>", buttonUrl];
    [htmlString appendFormat:@"<script type=\"text/javascript\" src=\"//assets.pinterest.com/js/pinit.js\"></script>"];
    [htmlString appendFormat:@"</body> </html>"];
    return [htmlString autorelease];
}


#pragma mark - Postcard

- (IBAction)postcard:(id)sender;
{
    
}
/*
- (IBAction)postcard:(id)sender;
{
    
    UIImage *newShareImage = [self.shareImage copy];
    ILog(@"post card image", newShareImage);
    SYSincerelyController *controller = [[SYSincerelyController alloc] initWithImages:[NSArray arrayWithObject:newShareImage]
                                                                              product:SYProductTypePostcard
                                                                       applicationKey:MYSTIC_API_SINCERELY_KEY
                                                                             delegate:self];
    
    if (controller) {
        [self presentViewController:controller animated:YES completion:NULL];
        [controller release];
    }
    [newShareImage release];
}
 

- (void)sincerelyControllerDidFinish:(SYSincerelyController *)controller {
 
     // * Here I know that the user made a purchase and I can do something with it
 
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sincerelyControllerDidCancel:(SYSincerelyController *)controller {
 
     // * Here I know that the user hit the cancel button and they want to leave the Sincerely controller
 
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sincerelyControllerDidFailInitiationWithError:(NSError *)error {
 
    // * Here I know that incorrect inputs were given to initWithImages:product:applicationKey:delegate;
 
    
    DLog(@"MYSTIC Postcard Error: %@", error);
}
 
 */


- (NSString *) uniqueHash;
{
    if(!_uniqueHash)
    {
        NSString *theudid = @"";
        if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)])
        {
            theudid = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]];
        }
        float timestamp = (float) [[NSDate date] timeIntervalSince1970];
        _uniqueHash = [[NSString stringWithFormat:@"myi%@", [Mystic md5:[NSString stringWithFormat:@"%@%@%2.2f", theudid, [[UIDevice currentDevice] name], timestamp]]] retain];
    }
    return _uniqueHash;
}
- (void)uploadImage:(UIImage *)image finished:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
{
    [self uploadImage:image tag:nil finished:finished failed:failed];
}
- (void)uploadImage:(UIImage *)image tag:(NSString *)tag finished:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
{

    if(![Mystic trackDiagnostics])
    {
        if(finished) finished(@"http://mysti.ch");
        return;
    }
    NSString *folderName = [UserPotion optionForType:MysticObjectTypeText] && [UserPotion optionForType:MysticObjectTypeText].folderName && ![[UserPotion optionForType:MysticObjectTypeText].folderName isEqualToString:@""] ? [UserPotion optionForType:MysticObjectTypeText].folderName : PICTURE_USER_UPLOADS;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@%@.jpg", folderName, self.uniqueHash, (tag ? [NSString stringWithFormat:@"_%@", tag] : @"")];
    NSString *imgURL = [NSString stringWithFormat:@"http://i.mysti.ch/%@", filePath];
    
    if(uploaded && _uploadURL && [_uploadURL isEqualToString:imgURL])
    {
//        DLog(@"already uploaded: %@", _uploadURL);
        if(finished) finished(_uploadURL);
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.95);
        // Upload image data.  Remember to set the content type.
        
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:filePath inBucket:PICTURE_BUCKET] autorelease];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        por.cannedACL = [S3CannedACL publicRead];
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(putObjectResponse.error != nil)
            {
                if(failed) failed(putObjectResponse.error);
                uploaded = NO;
            }
            else
            {
                    uploaded = YES;
                
                _uploadURL = [imgURL retain];
                if(finished)
                {
                    finished([NSURL URLWithString:imgURL]);
                }
                //[self uploadedImageURL:finished failed:failed];
                //[self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void) uploadedImageURL:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
{
//    DLog(@"getting URL: %@", self.uniqueHash);
    
    if(HUD) HUD.labelText = @"Getting Link";
    
    // Set the content type so that the browser will treat the URL as an image.
    S3ResponseHeaderOverrides *override = [[[S3ResponseHeaderOverrides alloc] init] autorelease];
    override.contentType = @"image/jpeg";
    
    // Request a pre-signed URL to picture that has been uplaoded.
    S3GetPreSignedURLRequest *gpsur = [[[S3GetPreSignedURLRequest alloc] init] autorelease];
    gpsur.key                     = self.uniqueHash;
    gpsur.bucket                  = PICTURE_BUCKET;
    gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    
    // Get the URL
    NSError *error;
    NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
    
    if(url == nil)
    {
        if(error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"Error: %@", error);
                //[self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                if(failed) failed(error);
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Display the URL in Safari
            //[[UIApplication sharedApplication] openURL:url];
            if(finished) finished(url);
        });
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {

}


#pragma mark - Download





@end

//
//  AppDelegate.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "MysticNavigationViewController.h"
#import "MysticController.h"
#import "AHAlertView.h"
#import "MBProgressHUD.h"
#import "MysticWebViewController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MysticMainDrawerViewController.h"
#import "MysticCache.h"
#import "MysticCacheImage.h"
#import "MysticIntroViewController.h"
#import "MysticNavigationBar.h"
#import "NavigationBar.h"
#import "MysticSettingsController.h"
#import "MysticFontStylesViewController.h"
#import "MysticDrawerViewController.h"
#import "MysticCache.h"
#import "MysticLaunchedViewController.h"
#import "ABX.h"
#import "MysticLogger.h"
#import "MysticEffectsManager.h"
#import "UserPotion.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Mystic-Swift.h"
#import "MysticStoreViewController.h"

#ifdef DEBUG
//#import "FLEXManager.h"

#endif
#import "MysticTipView.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"


@interface AppDelegate ()
{
    BOOL asktoupdate, oktocheckupdate;
    NSTimeInterval lastCheckedForUpdateTimeInterval;
}
@property (nonatomic, assign) BOOL autoUpdating, hasCheckedForUpdateAtLeastOnce;
@property (nonatomic, retain) NSTimer *launchTimer;
@end

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 */
void HandleExceptions(NSException *exception) {
    DLog(@"CRASH: Mystic Exception: %@", exception.reason);
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 */
void SignalHandler(int sig) {
    DLog(@"CRASH: Mystic Signal Handler: %d", sig);
    // Save application data on crash
}

+ (AppDelegate *) instance;
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate;
}


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    DLog(@"Launch Options2: %@", launchOptions);

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    [MysticTipViewManager resetTips];
#endif
//    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];

    RMStoreKeychainPersistence *_persistor = [[RMStoreKeychainPersistence alloc] init];
    [RMStore defaultStore].transactionPersistor = _persistor;
    
    
    // Standard lumberjack initialization
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [MysticLogger setupLogger];
    MysticLogger *mLogger = [[MysticLogger alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:mLogger];
    
    
    NSString *appKey = @"1q2oc5fqtvemxfw";
    NSString *appSecret = @"4zq7punnr5wthk5";
    
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:kDBRootAppFolder];
    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:session];
    
    
    
    NSString *scaleStr = @"75%";
    float sc = [MysticUser getf:Mk_SCALE];
    if(sc <= 0) scaleStr = @"Off";
    else if(sc < 1) scaleStr = @"25%";
    else if(sc == 1) scaleStr = @"33%";
    else if(sc == 1.5) scaleStr = @"50%";
    else if(sc >= 3) scaleStr = @"100%";
 
    uint64_t freeSpace = getFreeDiskspace(YES);

    ALLog(@"Mystic", @[
                      @"Config", [MysticCache cacheDirectoryPath].localFilePath,
                      @"Build", @((int)MysticBuildNumber()),
                      @"Speed", [[[MysticUser get:Mk_TIME] stringValue] suffix:@" x"],
                      @"Sim Scale", scaleStr,
                      @"Fee space", [NSString stringWithFormat:@"%llu MiB",  freeSpace],
#ifdef DEBUG
                      @"Debug", MBOOL(YES),
#endif
#ifdef MYSTIC_LOAD_NEWEST_SHADER
                      @"Load Latest Shader", MBOOL(YES),
#endif
                      LINE,
                      @"Screen", [NSString stringWithFormat:@"@%1.0fx  |  %@px", [[UIScreen mainScreen] scale], SLogStr([[UIScreen mainScreen] bounds].size)],
                      @"Max Image", SLogStr([MysticUser user].maximumRenderSize),
                      @"Last Project", MObj([MysticUser user].lastProjectName),
                      launchOptions ? @" - " : @"#end",
                      @"Launch Options", MObj(launchOptions),
                      
                                          ]);
    

    if(!usingIOS8())
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
#ifdef MYSTIC_START_WITH_FRESH_CACHE
    
    [MysticCache clearAll];
    
    //
#else
    
    [MysticCache prepareCachesForLaunch];
    [MysticCache prepareCachesForNewProject];
#endif
    

#pragma mark - AppBotX
    
    [[ABXApiClient instance] setApiKey:@"65c2e8d731db6cb71f0c005f784fa9fee8d1e818"];
    

    
#pragma mark - Facebook
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
#pragma mark - Start
    
    
    asktoupdate = NO;
    oktocheckupdate = NO;
    self.skipReloadLastProject = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor hex:@"303030"];


    // Override point for customization after application launch.
    
    MysticNavigationViewController *nav;
#ifdef DEBUG
#ifdef MYSTIC_USE_SAMPLE_PROJECT
    
    __block MysticController *_viewController = nil;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
        
        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
        
        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    }
    
#else
    
#ifdef MYSTIC_USE_LAST_PHOTO
    
    __block MysticController *_viewController = nil;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
        
        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
        
        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    }
    
    
    
#else
#ifdef MYSTIC_USE_LAUNCH_PHOTO
    
    __block MysticController *_viewController = nil;

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];

        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        _viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];

        nav.viewControllers = [NSArray arrayWithObject:_viewController];
        
    }



#else
    MysticIntroViewController *viewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil]] ;

    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil] ];

    }
#endif
#endif
#endif
#else
    MysticIntroViewController *viewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil]] ;
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil] ];
        
    }
#endif
    nav.delegate = self;
    
    
    UIViewController * leftDrawerNav = [MysticMainDrawerViewController mainMenuController];
    

    MMDrawerController * _drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:nav
                                             leftDrawerViewController:leftDrawerNav
                                             rightDrawerViewController:nil];
    _drawerController.showsShadow = NO;
    [_drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2.5]];
    [_drawerController setMaximumLeftDrawerWidth:MYSTIC_UI_DRAWER_LEFT_WIDTH];
    [_drawerController setMaximumRightDrawerWidth:MYSTIC_UI_DRAWER_RIGHT_WIDTH];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    
    self.window.rootViewController = _drawerController;
    [[self class] applyAppearanceSettings];
    loadFonts();

    
    [self.window makeKeyAndVisible];
    
 
    [Mystic setLastCheckedForUpdate:lastCheckedForUpdateTimeInterval];
    
    [MysticOptionsDataSource shared];
    if(![MysticUser remembers:@(MysticUserRememberBetaVersion)])
    {
        [MysticUser remember:@(MysticUserRememberBetaVersion) as:@(MysticBuildNumber())];
    }
    [self setupData];

#ifdef DEBUG
#ifdef MYSTIC_USE_SAMPLE_PROJECT
    [self loadProject:[MysticUser projectFromFilePath:[[NSBundle mainBundle] pathForResource:@"sample_project" ofType:@"plist"]]];
#else
    
    #ifdef MYSTIC_USE_LAST_PHOTO
    
    [self loadLastPhoto];
    #else

    
    #ifdef MYSTIC_USE_LAUNCH_PHOTO

    [self loadPhoto:[UIImage imageNamed:MYSTIC_USE_LAUNCH_PHOTO]];
    
    #endif
#endif
#endif
#endif
    
    if(freeSpace <= 250)
    {
        MysticWait(1, ^{
            [MysticAlert notice:@"Bummer!" message:@"It looks like you don't have that much storage space left on your device, so Mystic might act a little buggy. \n\nTry clearing up some storage space if Mystic is messing up." action:nil options:nil];
        });
    }
    
    return YES;

}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    MysticNavigationViewController *nav;
    
    MysticIntroViewController *viewController;
    BOOL openCam = [shortcutItem.localizedTitle isEqualToString:@"Take Photo"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil]] ;
        
    } else {
        nav = [[[NSBundle mainBundle] loadNibNamed:@"MysticNavigationViewController_iPad" owner:nil options:nil] lastObject];
        nav.hidesToolbar = YES;
        nav.viewControllers = [NSArray arrayWithObject:[[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil] ];
        
    }

    nav.delegate = self;
    UIViewController * leftDrawerNav = [MysticMainDrawerViewController mainMenuController];
    
    
    MMDrawerController * _drawerController = [[MMDrawerController alloc]
                                              initWithCenterViewController:nav
                                              leftDrawerViewController:leftDrawerNav
                                              rightDrawerViewController:nil];
    _drawerController.showsShadow = NO;
    [_drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2.5]];
    [_drawerController setMaximumLeftDrawerWidth:MYSTIC_UI_DRAWER_LEFT_WIDTH];
    [_drawerController setMaximumRightDrawerWidth:MYSTIC_UI_DRAWER_RIGHT_WIDTH];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    
    self.window.rootViewController = _drawerController;
    [[self class] applyAppearanceSettings];
    loadFonts();
    
    
    [self.window makeKeyAndVisible];
    
    
    [Mystic setLastCheckedForUpdate:lastCheckedForUpdateTimeInterval];
    
    [MysticOptionsDataSource shared];
    if(![MysticUser remembers:@(MysticUserRememberBetaVersion)]) [MysticUser remember:@(MysticUserRememberBetaVersion) as:@(MysticBuildNumber())];
    [self setupData];
    
    
    [self openCam:self animated:NO mode:MysticSettingImageShortcut source:openCam?MysticPickerSourceTypeCameraOrPhotoLibrary:MysticPickerSourceTypePhotoLibrary complete:nil];
        
    
}


- (void) loadProject:(NSDictionary *)p;
{
    DLog(@"load project");
    if(!p) return [self loadPhoto:[UIImage imageNamed:@"launchPhoto.jpg"]];

    __block NSDictionary *projectDict = [[NSDictionary alloc] initWithDictionary:p];
    UIImage * constrainedImage = [UIImage imageNamed:@"launchPhoto.jpg"];
    if(constrainedImage)
    {
        [[MysticUser user] clearLastProject];
        __block __weak NSArray *info = [NSArray arrayWithObject:@{UIImagePickerControllerOriginalImage: constrainedImage}];
        __block __weak AppDelegate *weakSelf = self;
        __block __weak MysticController *editController = [self.navigationController.viewControllers lastObject];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.window];
        hud.removeFromSuperViewOnHide = YES;
        hud.labelText = NSLocalizedString(@"mystifying", nil);
        [self.window addSubview:hud];
        [self.window bringSubviewToFront:hud];
        self.hud = hud;
        [hud show:YES];
        [editController info:info ready:nil];
        [editController info:nil ready:^(MysticController *_editController) {
            [[UserPotion potion] preparePhoto:[_editController.photoInfo lastObject] previewSize:[MysticUI screen] reset:YES finished:^(CGSize size, UIImage *preparedPhoto, NSString *imageFilePath){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    editController.previewSize = size;
                    if([MysticOptions current]) [[MysticOptions current] setNeedsRender];
                    [editController setState:MysticSettingNoneFromLoadProject animated:YES complete:^{ }];
                });
            }];
            
        }];

        [MysticOptions loadProject:projectDict finished:^(MysticOptions *theOptions, BOOL active) {
            if(active)
            {
                [[MysticOptions current] setHasChanged:YES changeOptions:YES];
                [[MysticOptions current] enable:MysticRenderOptionsBuildFromGroudUp];
                [[MysticOptions current] enable:MysticRenderOptionsSource];
                [[MysticOptions current] enable:MysticRenderOptionsSaveState];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.navigationController ) [self.navigationController setToolbarHidden:YES animated:NO];
                    weakSelf.navigationController.navigationBarHidden = NO;
                    [weakSelf.navigationController.navigationBar setBackgroundColorStyle:MysticColorTypeClear];
                    weakSelf.navigationController.navigationBar.height = MYSTIC_NAVBAR_HEIGHT_NORMAL;
                    if(![weakSelf.navigationController.viewControllers containsObject:editController]) weakSelf.navigationController.viewControllers = @[editController];
                    [editController setupDrawerState];
                    [weakSelf.hud setCompletionBlock:^{
                        [editController runViewIsReady];
                        weakSelf.hud = nil;
                    }];
                    [weakSelf.hud hide:YES];
                });
            }
        }];
    }
}
- (void) loadLastPhoto;
{
    __block __weak AppDelegate *weakSelf = self;
    @autoreleasepool {
        [MysticLibrary fetchLastCameraRollPhoto:^(id obj, id obj2) {
            __unsafe_unretained __block UIImage *__image = obj ? obj : nil;
            __unsafe_unretained __block id __obj2 = obj2 ? obj2 : nil;
            MysticBlockObject imageBlock = ^(UIImage *img)
            {
                img = !img ? __image : img;
                if(!img) return;
                [weakSelf loadPhoto:img];
            };
            if(usingIOS8()) imageBlock(__image);
            else [MysticImage constrainImage:__image toSize:[MysticImage maximumImageSize] withQuality:1 finished:imageBlock];
        }];
    }
}
- (void) loadPhoto:(UIImage *)image;
{
    __unsafe_unretained __block AppDelegate *weakSelf = self;
    @autoreleasepool
    {
        __unsafe_unretained __block UIImage *__image = image ? image : nil;
        MysticBlockObject imageBlock = ^(UIImage *constrainedImage)
        {
            constrainedImage = !constrainedImage ? __image : constrainedImage;
            if(!constrainedImage) return [weakSelf imagePickerController:(id)weakSelf didFinishPickingMediaWithInfo:@{}];
            [weakSelf imagePickerController:(UIImagePickerController *)weakSelf didFinishPickingMediaWithInfo:(id)@[@{UIImagePickerControllerOriginalImage: constrainedImage, UIImagePickerControllerEditedImage: constrainedImage}] finished:nil];
        };
        if(usingIOS8()) imageBlock(__image);
        else [MysticImage constrainImage:__image toSize:[MysticImage maximumImageSize] withQuality:1 finished:imageBlock];
    }
}
    

-(void)onSlashScreenDone:(NSTimer *)operation{
    
    MysticLaunchedViewController * vc =  (id)self.window.rootViewController;
    __unsafe_unretained __block MysticLaunchedViewController *_vc = (id)self.window.rootViewController;
    __unsafe_unretained __block NSTimer *_op = self.launchTimer;
    __unsafe_unretained __block MMDrawerController * _dc = _op.userInfo[@"controller"];
    [_vc dismissDefaultImage:nil];
    MMDrawerController * _drawerController = _op.userInfo[@"controller"];
    [self.window.rootViewController.view removeFromSuperview];
    self.window.rootViewController = _drawerController;
    [self.window makeKeyAndVisible];
    [_op invalidate];
}
- (void) newProject;
{
    [self newProjectConfirmed:nil];
}
- (void) newProjectConfirmed:(MysticBlockBOOLComplete)confirmedBlock;
{
    __unsafe_unretained __block AppDelegate *weakSelf = self;
    __unsafe_unretained __block MysticBlockBOOLComplete _confirmed = confirmedBlock ? confirmedBlock : nil;
    [MysticAlert ask:@"Start Over?" message:@"Are you sure you want to start a new project? All of your changes will be lost." yes:^(id obj1, id obj2) {
        MysticBlock nextStep = ^{
            [[MysticUser user] clearLastProject];
            [AppDelegate instance].skipReloadLastProject = YES;
            [weakSelf setupNewProject:YES];
        };
        if(_confirmed)
        {
            _confirmed(YES, nextStep);
        }
        else
        {
            nextStep();
            
        }
    } no:^(id obj1, id obj2) {
        if(_confirmed)
        {
            _confirmed(NO, nil);
        }
    } options:@{@"destruct": @YES}];
    
    
    
}

- (void) setupNewProject:(BOOL)animated;
{
    [MysticCache prepareCachesForNewProject];
    __unsafe_unretained __block AppDelegate *weakSelf = self;
    
    MysticIntroViewController *viewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil];
    } else {
        viewController = [[MysticIntroViewController alloc] initWithNibName:@"MysticIntroViewController" bundle:nil];
    }
    MysticNavigationViewController *nav = (MysticNavigationViewController *)weakSelf.drawerController.centerViewController;
    nav.navigationBar.height = MYSTIC_NAVBAR_HEIGHT;
    [MysticController controller:nil];
    [nav setViewControllers:@[viewController] animated:animated];
    if(weakSelf.drawerController.openSide != MMDrawerSideNone)
    {
        [weakSelf.drawerController closeDrawerAnimated:animated completion:^(BOOL finished) {
            
            if(finished)
            {
                UIViewController * leftDrawerNav = [MysticMainDrawerViewController mainMenuController];
                [weakSelf.drawerController setLeftDrawerViewController:leftDrawerNav];
            }
            
            
        }];
    }
    else
    {
        UIViewController * leftDrawerNav = [MysticMainDrawerViewController mainMenuController];
        [weakSelf.drawerController setLeftDrawerViewController:leftDrawerNav];
    }
    
    
}

- (MysticNavigationViewController *) navigationController;
{
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.drawerController.centerViewController;
    return nav;
}

- (UIViewController *)visibleController;
{
    return self.navigationController.visibleViewController;
}

- (void) openSettings;
{
    [self openSettingsAnimated:YES complete:nil];
}
- (void) openSettingsAnimated:(BOOL)animated complete:(MysticBlock)finished;
{
    MysticSettingsController *preferencesViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        preferencesViewController  = [[MysticSettingsController alloc] initWithNibName:@"MysticSettingsController" bundle:nil];
    }
    else
    {
        preferencesViewController  = [[MysticSettingsController alloc] initWithNibName:@"MysticSettingsController" bundle:nil];
    }
    
    
    preferencesViewController.delegate = self;
    preferencesViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.window.rootViewController presentViewController:preferencesViewController animated:animated completion:finished];

}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
 
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}



- (MMDrawerController *) drawerController;
{
     return (MMDrawerController *)self.window.rootViewController;
     
}


+ (void) applyAppearanceSettings;
{
    [MysticAlert setupAppearance];
    
    

    
    [[MysticNavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [MysticUI gothamLight:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                          [MysticColor color:@(MysticColorTypeNavBarText)], UITextAttributeTextColor,
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          nil]];
    
    
    [[NavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [MysticUI gothamLight:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                              [MysticColor color:@(MysticColorTypeNavBarText)], UITextAttributeTextColor,
                                                              [UIColor clearColor], UITextAttributeTextShadowColor,
                                                              [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                              nil]];
    [[MysticNavigationBar appearance] setTintColor:[MysticColor color:@(MysticColorTypeNavBar)]];
    [[NavigationBar appearance] setTintColor:[MysticColor color:@(MysticColorTypeNavBar)]];
    [[UINavigationBar appearance] setTintColor:[MysticColor color:@(MysticColorTypeNavBar)]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MysticFont fontBold:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                        [MysticColor color:@(MysticColorTypeNavBarText)], UITextAttributeTextColor,
                                                        [UIColor clearColor], UITextAttributeTextShadowColor,
                                                        [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                        nil]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor hex:@"1E1C1B"]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MysticFont font:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                          [UIColor color:MysticColorTypePink], UITextAttributeTextColor,
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MysticFont font:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                          [UIColor color:MysticColorTypeWhite], UITextAttributeTextColor,
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          nil] forState:UIControlStateHighlighted];
    
   [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setTranslucent:NO];
//    [[UISearchBar appearance] setBarStyle:UIBarStyleBlack];
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:0.24 green:0.2 blue:0.2 alpha:1]];
    [[UISearchBar appearance] setTintColor:[UIColor color:MysticColorTypePink]];
    [[UISearchBar appearance] setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    UIColor *sTxtColor = [UIColor colorWithRed:1 green:0.99 blue:0.96 alpha:1];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                sTxtColor, NSForegroundColorAttributeName,
                                                                                                [MysticFont gothamBook:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                                                                nil]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTypingAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                [MysticFont font:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                                                                sTxtColor, NSForegroundColorAttributeName,
                                                                                                nil]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [MysticFont font:MYSTIC_UI_NAVBAR_FONTSIZE], UITextAttributeFont,
                                                          [UIColor colorWithRed:0.42 green:0.37 blue:0.35 alpha:1], UITextAttributeTextColor,
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          nil] forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}



- (void) openCam:(id)delegate animated:(BOOL)animated;
{
    [self openCam:delegate animated:animated complete:nil];
}
- (void) openCam:(id)delegate animated:(BOOL)animated complete:(void (^)())finished;
{
    [self openCam:delegate animated:animated mode:MysticObjectTypeImage complete:finished];
}
- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode;
{
    [self openCam:delegate animated:animated mode:mode complete:nil];
}
//static MysticPickerViewController *picker;
- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode complete:(void (^)())finished;
{
    [self openCam:delegate animated:animated mode:mode source:MysticPickerSourceTypeCameraOrPhotoLibrary complete:finished];
}
- (void) openCam:(id)delegate source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
{
    [self openCam:delegate animated:YES mode:MysticObjectTypeImage source:sourceType complete:finished];
}
- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
{
    @autoreleasepool {
        
        MysticPickerViewController *picker ;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController" owner:nil options:nil] lastObject];
        } else {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController_iPad" owner:nil options:nil] lastObject];
        }
        [picker setup];
        picker.sourceType = sourceType;
//        if(mode == MysticSettingImageShortcut)
//        {
//            picker.didFinishSelector = @selector(imagePickerController:didFinishPickingMediaWithInfo:finished:);
//        }
        picker.imagePickerDelegate = (delegate ? delegate : self);
        
        self.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        [picker present:picker.sourceType viewController:picker animated:NO finished:nil];
        if([self.window.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            __block __weak MysticPickerViewController *weakPicker = picker;
            [self.window.rootViewController presentViewController:picker animated:animated completion:^{
                [weakPicker viewDidPresent:animated];
                if(finished) finished();
            }];
        }
        else
        {
            [self.window.rootViewController presentModalViewController:picker animated:animated];
            [picker viewDidPresent:animated];
            if(finished) finished();
        }
        
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    }
}
- (void) closeCam:(void (^)())finished;
{
    @autoreleasepool {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        
        __block __weak MysticPickerViewController *picker = nil;
        
        BOOL animated = YES;
        if([self.window.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            picker = (MysticPickerViewController *)self.window.rootViewController.presentedViewController;
            [self.window.rootViewController dismissViewControllerAnimated:animated completion:^{
                if(finished) finished();
            }];
        }
        else
        {
            picker = (MysticPickerViewController *)self.window.rootViewController.modalViewController;
            [self.window.rootViewController dismissModalViewControllerAnimated:animated];
            if(finished) finished();
        }
        
        
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingProject:(NSDictionary *)projectInfo
{
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.drawerController.centerViewController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = NSLocalizedString(@"opening project", nil);
    
    [nav popToRootViewControllerAnimated:NO];
    
    
    
    MysticController *recipesController = [nav.viewControllers objectAtIndex:0];
    [recipesController openProject:[MysticProject project:projectInfo] complete:^(id obj, BOOL success) {

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.window animated:YES];
            [self closeCam:nil];
        });
        
    }];

    
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)returnInfo finished:(MysticBlockObject)finishedBlock;
{
    if(!returnInfo) { [self imagePickerControllerDidCancel:picker]; return; }
    if([picker respondsToSelector:@selector(imagePickerDelegate)])
    {
        MysticPickerViewController *pp = (id)picker;
        [(MysticPickerViewController *)picker setImagePickerDelegate:nil];
        [(MysticPickerViewController *)picker setDelegate:nil];
    }
    NSArray *info = nil;
    if([returnInfo isKindOfClass:[NSDictionary class]]) info = [NSArray arrayWithObject:returnInfo];
    else if([returnInfo isKindOfClass:[NSArray class]]) info = (NSArray *)returnInfo;
    __block __weak AppDelegate *weakSelf = self;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.window];
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = NSLocalizedString(@"mystifying", nil);
    [self.window addSubview:hud];
    [self.window bringSubviewToFront:hud];
    self.hud = hud;
    [hud show:YES];
    [[MysticUser user] clearLastProject];
    MysticController *vc = nil;
    if(![[self.navigationController.viewControllers lastObject] isKindOfClass:[MysticController class]])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            vc = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
        } else {
            vc = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
        }
    }
    __block __weak MysticController *_viewController = vc ? (id)vc : (id)[self.navigationController.viewControllers lastObject];

    BOOL containsController = [weakSelf.navigationController.viewControllers containsObject:_viewController];
    [_viewController info:[NSMutableArray arrayWithArray:info] ready:finishedBlock];
    [_viewController setInfo:nil reset:YES finished:^{
        mdispatch(^{
            weakSelf.navigationController.navigationBarHidden = NO;
            [weakSelf.navigationController.navigationBar setBackgroundColorStyle:MysticColorTypeClear];
            weakSelf.navigationController.navigationBar.height = MYSTIC_NAVBAR_HEIGHT_NORMAL;
            if(!containsController) weakSelf.navigationController.viewControllers = @[_viewController];
            [_viewController setupDrawerState];
            [weakSelf.hud setCompletionBlock:^{
                [_viewController runViewIsReady];
                weakSelf.hud = nil;
            }];
            [weakSelf.hud hide:YES];
        });
    }];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.drawerController.centerViewController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = NSLocalizedString(@"mystifying", nil);
    __unsafe_unretained __block AppDelegate *weakSelf = self;
    MysticController *editController;
    for (UIViewController *c in nav.viewControllers) if([c isKindOfClass:[MysticController class]]) { editController = (id)c; break; }
    
    [[MysticUser user] clearLastProject];
    MysticController *vc = nil;
    if(!editController)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            editController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
        } else {
            editController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
        }
        self.navigationController.viewControllers = @[editController];
    }
    
    
    mdispatch(^{
        [editController setInfo:[NSMutableArray arrayWithArray:info] reset:YES finished:^{
            [MBProgressHUD hideHUDForView:self.window animated:YES];
            [weakSelf closeCam:nil];
        }];
    });
    mdispatch(^{ [nav popToRootViewControllerAnimated:NO]; });
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeCam:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MysticWillResignActive" object:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    return;

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

    oktocheckupdate = YES;
    asktoupdate = (([NSDate timeIntervalSinceReferenceDate] - lastCheckedForUpdateTimeInterval) >= kConfigCacheExpirationTime);
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    [FBSDKAppEvents activateApp];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MysticDidBecomeActive" object:nil];
//
//#ifdef MYSTIC_MAKE_CONFIG_LOCAL
    
    if(!self.hasDownloadedConfig && (([Mystic hasCacheExpired] || !self.hasCheckedForUpdateAtLeastOnce) && [MysticUser user].autoUpdate && !self.autoUpdating))
    {
        __unsafe_unretained __block AppDelegate *weakSelf = self;
        weakSelf.autoUpdating = YES;
        weakSelf.hasCheckedForUpdateAtLeastOnce = YES;
        [[Mystic core] updateConfig:^(BOOL startingDownload) {
            
            if(!startingDownload) return;
            
            
            
        } complete:^(BOOL success) {
            weakSelf.hasDownloadedConfig = YES;
            weakSelf.autoUpdating = NO;
            if(!success) return;
            
            
            
            
            
        }];
    }
//#endif
   
}

#pragma mark - Open Store

- (MysticStoreViewController *) showStore:(MysticStoreType)storeType completion:(MysticBlock)finished;
{
    return [self showStore:storeType product:nil download:NO setup:nil purchased:nil completion:finished];
}
- (MysticStoreViewController *) showStore:(MysticStoreType)storeType product:(NSString *)productID download:(BOOL)download completion:(MysticBlock)finished;
{
    return [self showStore:storeType product:productID download:download setup:nil purchased:nil completion:finished];
}
- (MysticStoreViewController *) showStore:(MysticStoreType)storeType product:(NSString *)productID download:(BOOL)download setup:(MysticBlockObject)setup purchased:(MysticBlockObjBOOL)purchased completion:(MysticBlock)finished;
{
    MysticStoreViewController *store = [[MysticStoreViewController alloc] init];
    store.storeType = storeType;
    store.onPurchased = purchased;
    store.focusOnProductID = productID;
    store.shouldDownloadFocusedProduct = download;
    store.modalPresentationStyle = UIModalPresentationOverFullScreen;
    store.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(setup) setup(store);
    [self.window.rootViewController presentViewController:store animated:YES completion:finished];
    return store;
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook openURL

void uncaughtExceptionHandler(NSException *exception) {
    
//    NSString *crashString = [NSString stringWithFormat:@"Crash info: %@ \nStack: %@", exception, [exception callStackSymbols]];
//    
//    // Internal error reporting
//    DLog(@"%@", crashString);
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation; {
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            if (self.performAfterDropboxLoginBlock) {
                self.performAfterDropboxLoginBlock();
                self.performAfterDropboxLoginBlock = nil;
            }
        }
        return YES;
    }
    
    if([url.absoluteString hasPrefix:@"tel:"]) return NO;
    BOOL wasHandled = NO;
    if([url isFileURL] && ([[url pathExtension] caseInsensitiveCompare:@"jpg"] == NSOrderedSame || [[url pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame))
    {
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        __block __strong UIImage *img = [[UIImage alloc] initWithData:data];
        
        if(!img) return NO;
        
        
        
        __unsafe_unretained __block AppDelegate *weakSelf = self;
        MysticBlock presentFile;
        
        if([self.navigationController.viewControllers.lastObject isKindOfClass:[MysticController class]])
        {
            presentFile = ^{
                [[MysticUser user] clearLastProject];
                __unsafe_unretained __block MysticController *_viewController = (id)self.navigationController.viewControllers.lastObject;
                
                [_viewController info:[NSMutableArray arrayWithArray:@[@{UIImagePickerControllerOriginalImage: img}]] ready:^(MysticController *editController){
                    
                }];
                
                
                [_viewController setInfo:nil reset:YES finished:^{
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [_viewController setupDrawerState];
                        
                        [NSTimer wait:2 block:^{
                            [_viewController runViewIsReady];
                        }];
                        
                        
                    });
                }];
                
                

            };
        }
        else
        {
            presentFile = ^{
                [[MysticUser user] clearLastProject];
                
                MysticController *_viewController = nil;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    _viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
                } else {
                    _viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
                }
                
                
                
                
                [_viewController info:[NSMutableArray arrayWithArray:@[@{UIImagePickerControllerOriginalImage: img}]] ready:^(MysticController *editController){
                    
                    
                    if(weakSelf.navigationController.viewControllers.count > 1)
                    {
                        weakSelf.navigationController.viewControllers = @[[weakSelf.navigationController.viewControllers lastObject]];
                        
                    }

                    
                    
                }];
                
                __block __weak MysticController *__vc = _viewController;
                
                [_viewController setInfo:nil finished:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.navigationController.navigationBarHidden = NO;
                        [weakSelf.navigationController.navigationBar setBackgroundColorStyle:MysticColorTypeClear];
                        weakSelf.navigationController.navigationBar.height = MYSTIC_NAVBAR_HEIGHT_NORMAL;
                        
                        [weakSelf.navigationController pushViewController:__vc animated:NO];
                        
                        [__vc setupDrawerState];
                        
                        [NSTimer wait:2 block:^{
                            [__vc runViewIsReady];
                        }];
                        
                        
                    });
                }];
            

            };
        }
        
        if(self.navigationController.presentedViewController)
        {
            [self.navigationController dismissViewControllerAnimated:NO completion:presentFile];
        }
        else
        {
            presentFile();
        }
    }
    else
    {
    
        NSDictionary *queryStringDictionary = [self parseURLParams:[url absoluteString]];
        NSString *targetURL = [queryStringDictionary objectForKey:@"target_url"];
        NSString *state = [queryStringDictionary objectForKey:@"state"];
        
        wasHandled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation
         ];
        
        
        if(state)
        {
            wasHandled = [self handleState:[state lowercaseString] options:queryStringDictionary url:[url absoluteString]] || wasHandled ? YES : NO;
        }
        else if(targetURL)
        {
            [self openLink:targetURL];
            
        }
        else if([[url absoluteString] hasPrefix:@"http"])
        {
            [self openLink:[url absoluteString]];
        }
    }
    return wasHandled;
}
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
{
    DLog(@"app received remote notification: %@", userInfo);
//    if (application.applicationState == UIApplicationStateInactive) {
//        // The application was just brought from the background to the foreground,
//        // so we consider the app as having been "opened by a push notification."
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//    
//    
//    [PFPush handlePush:userInfo];
//    
//    if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
////        NSLog(@"Notification recieved by running app");
//    }
//    else{
////        NSLog(@"App opened from Notification");
//    }
    
    
    if([userInfo objectForKey:@"mystic"])
    {
        NSDictionary *note = [userInfo objectForKey:@"mystic"];
        if([note objectForKey:@"url"])
        {
            [self openLink:[note objectForKey:@"url"]];
        }
        else if([note objectForKey:@"state"])
        {
            [self handleState:[note objectForKey:@"state"] options:note url:nil];
        }
    }
    
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
}

- (BOOL) handleState:(NSString *)stateString options:(NSDictionary *)options url:(NSString *)urlStr;
{
//    DLog(@"handling state: %@ url: %@\r\n\r\n%@", stateString, urlStr, options);
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.drawerController.centerViewController;
    
    MysticController *controller = (MysticController *)[nav.viewControllers objectAtIndex:0];
    if([stateString isEqualToString:@"writeoncam"])
    {
        [controller.navigationController dismissModalViewControllerAnimated:NO];
        [controller.navigationController popToRootViewControllerAnimated:NO];
        controller.currentSetting = MysticSettingCamLayer;
        return YES;
    }
    else if([stateString isEqualToString:@"text"])
    {
        [controller.navigationController dismissModalViewControllerAnimated:NO];
        [controller.navigationController popToRootViewControllerAnimated:NO];
        controller.currentSetting = MysticSettingText;
        return YES;
    }
    else if([stateString isEqualToString:@"none"])
    {
        [controller.navigationController dismissModalViewControllerAnimated:NO];
        [controller.navigationController popToRootViewControllerAnimated:NO];
        controller.currentSetting = MysticSettingNone;
        return YES;
    }
    else if([stateString isEqualToString:@"project"])
    {
        NSString *projectId = [options objectForKey:@"project"];
        NSString *projectUrl = [options objectForKey:@"project_url"];
        if(projectUrl)
        {
            
            [NSTimer wait:0.1 block:^{
                [MysticProject openProjectWithUrl:projectUrl info:options complete:^(id obj, BOOL success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [controller openProject:obj complete:^(id obj, BOOL success) {
                        }];
                    });
                }];
            }];
                
            
            return YES;
        }
        else if(projectId)
        {
            
            [MysticProject openProjectWithId:projectId info:options complete:^(id obj, BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            }];
            return YES;
        }
        
    }
    return NO;
}

- (void) openLink:(NSString *)targetURL;
{
    MysticBlock openWebSite = ^{
        MysticWebViewController *webController;
        
        
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            webController = [[MysticWebViewController alloc] initWithNibName:@"MysticWebViewController" bundle:nil];
        }
        else
        {
            webController = [[MysticWebViewController alloc] initWithNibName:@"MysticWebViewController_iPad" bundle:nil];
        }
        
        
        webController.url = targetURL;
        webController.showHeader = YES;
        if([self.window.rootViewController respondsToSelector:@selector(presentedViewController)])
        {
            [self.window.rootViewController presentViewController:webController animated:YES completion:^{
                
            }];
        }
        else
        {
            [self.window.rootViewController presentModalViewController:webController animated:YES];
        }
    };
    if([self.window.rootViewController respondsToSelector:@selector(presentedViewController)] && self.window.rootViewController.presentedViewController)
    {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            openWebSite();
        }];
    }
    else if(self.window.rootViewController.modalViewController)
    {
        [self.window.rootViewController dismissModalViewControllerAnimated:NO];
        openWebSite();
    }
    else
    {
        openWebSite();
    }
}


- (NSDictionary*)parseURLParams:(NSString *)url {
    
    NSArray *c = [url componentsSeparatedByString:@"#"];
    if([c count] < 2)
    {
        c = [url componentsSeparatedByString:@"?"];
    }
    if([c count] < 2) return [NSDictionary dictionary];
    
    NSString *query = [c objectAtIndex:1];
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}


//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//    
//    // attempt to extract a token from the url
//    return [FBSession.activeSession handleOpenURL:url];
//}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DataLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MysticModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MysticModel.sqlite"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MysticModelImport" ofType:@"sqlite"]];
        
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            DataLog(@"Oops, could copy preloaded data");
        }
    }
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DataLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}


- (void) setupData;
{
//#ifdef MYSTIC_MAKE_CONFIG_LOCAL
//    [MysticConfigManager manager].data = [[MysticConfigManager manager] fileData:nil useDefaultAsBackUp:YES];
//#endif
#ifdef MYSTIC_BETA
    if(MYSTIC_BETA < 1) return;
    [MysticAPI get:@"build/current?format=json" params:nil complete:^(NSDictionary *results, NSError *error) {
        if(error) return;
        if(results && isM(results[@"build_number"])) [MysticAPI setBuildNumber:[results[@"build_number"] integerValue]];
        id old = nil;
        
#ifdef MYSTIC_ASK_TO_UPDATE
        
        if([MysticAPI buildNumber] > MysticBuildNumber() && ![MysticUser remembers:@(MysticUserRememberBetaVersion) as:@([MysticAPI buildNumber]) old:&old])
        {
            if(!old || [old integerValue] < [MysticAPI buildNumber])
            {
                [MysticAlert show:@"Download New Version" message:@"There is a new Beta version available. You should download it now. Ok?" action:^(id object, id o2) {
                    [MysticUser forget:@(MysticUserRememberBetaVersion)];
                    NSString *url = isM(results[@"beta_download_url"]) ? results[@"beta_download_url"] : [@"http://backstage.mysti.ch/download/beta/" stringByAppendingFormat:@"%d", (int)[MysticAPI buildNumber]];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                } cancel:^(id object, id o2) {
                    [MysticUser remember:@(MysticUserRememberBetaVersion) as:@([MysticAPI buildNumber])];
                } options:@{@"button": @"Download", @"cancelTitle": @"Later"}];
            }
            
        }
#endif
        
        
        
    }];
#endif
    
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Navigation Delegate
- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
//    DLog(@"main nav will show: %@", viewController);
}
- (void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
//    DLog(@"nav did show: %@", viewController);
}

#pragma mark - DropBox

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    
}
- (void) unlinkDropbox
{
    if (![[DBSession sharedSession] isLinked]) {
        return;
    }
    
    NSString *title = NSLocalizedString(@"Unlink Dropbox", @"Unlink Dropbox");
    NSString *message = NSLocalizedString(@"Are you sure you want to unlink your Dropbox account?", @"Are you sure you want to unlink your Dropbox account?");
    
    NSString *unlinkButtonTitle = NSLocalizedString(@"Unlink", @"Title of Unlink button");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Title of Cancel button");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:unlinkButtonTitle, cancelButtonTitle, nil];
    alertView.cancelButtonIndex = 1;
    
    [alertView show];
}

@end

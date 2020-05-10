


//
//  AppDelegate.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MysticConstants.h"
#import "MysticPickerViewController.h"
#import "MBProgressHUD.h"
#import <DropboxSDK/DropboxSDK.h>

@class MMDrawerController, MysticStoreViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MysticPickerViewControllerDelegate, DBSessionDelegate>


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong) MysticNavigationViewController *navigationController;
@property (readonly, strong) UIViewController *visibleController;
@property (assign, nonatomic) BOOL skipReloadLastProject, hasDownloadedConfig;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) MMDrawerController *drawerController;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, copy) void (^performAfterDropboxLoginBlock)(void);

+ (AppDelegate *) instance;
+ (void) applyAppearanceSettings;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) openSettings;
- (void) openSettingsAnimated:(BOOL)animated complete:(MysticBlock)finished;

- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode;
- (void) openCam:(id)delegate animated:(BOOL)animated;
- (void) openCam:(id)delegate animated:(BOOL)animated complete:(void (^)())finished;
- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode complete:(void (^)())finished;
- (void) openCam:(id)delegate source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;

- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;

- (void) closeCam:(void (^)())finished;
- (void) openLink:(NSString *)targetURL;
- (BOOL) handleState:(NSString *)stateString options:(NSDictionary *)options url:(NSString *)urlStr;
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;
- (void) newProject;
- (void) setupNewProject:(BOOL)animated;
- (void) newProjectConfirmed:(MysticBlockBOOLComplete)confirmedBlock;

- (void) unlinkDropbox;
- (MysticStoreViewController *) showStore:(MysticStoreType)storeType completion:(MysticBlock)finished;
- (MysticStoreViewController *) showStore:(MysticStoreType)storeType product:(NSString *)productID download:(BOOL)download completion:(MysticBlock)finished;
- (MysticStoreViewController *) showStore:(MysticStoreType)storeType product:(NSString *)productID download:(BOOL)download setup:(MysticBlockObject)setup purchased:(MysticBlockObjBOOL)purchased completion:(MysticBlock)finished;

@end

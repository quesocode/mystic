//
//  MysticIntroViewController.m
//  Mystic
//
//  Created by Me on 11/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticIntroProjectViewController.h"
#import "MysticButton.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MysticPickerViewController.h"
#import "MBProgressHUD.h"
#import "MysticController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticNewProjectViewController.h"
#import "MysticMyProjectsViewController.h"
#import "MysticNavigationViewController.h"

@interface MysticIntroProjectViewController ()

@property (retain, nonatomic) IBOutlet MysticButton *albumButton;
@property (retain, nonatomic) IBOutlet MysticButton *cameraButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation MysticIntroProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController
     setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
         return NO;
     }];
    self.cameraButton.titleLabel.font = [MysticUI gothamBold:14];
    self.albumButton.titleLabel.font = self.cameraButton.titleLabel.font;
    self.navigationController.navigationBarHidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundImageView release];
    [_cameraButton release];
    [_albumButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [self setCameraButton:nil];
    [self setAlbumButton:nil];
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    self.albumButton.enabled = YES;
    self.cameraButton.enabled = YES;
}
- (IBAction)cameraButtonTouched:(MysticButton *)sender
{

    MysticNewProjectViewController *controller = [[[MysticNewProjectViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
}
- (IBAction)albumButtonTouched:(MysticButton *)sender
{
    MysticMyProjectsViewController *controller = [[[MysticMyProjectsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [self.navigationController pushViewController:controller animated:YES];
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
        picker.imagePickerDelegate = (delegate ? delegate : self);
        
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        [picker present:picker.sourceType viewController:picker animated:NO finished:nil];
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            __unsafe_unretained __block  MysticPickerViewController *weakPicker = picker;
            [self presentViewController:picker animated:animated completion:^{
                [weakPicker viewDidPresent:animated];
                if(finished) finished();
            }];
        }
        else
        {
            [self presentModalViewController:picker animated:animated];
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
        
        __unsafe_unretained __block  MysticPickerViewController *picker = nil;

        BOOL animated = YES;
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            picker = (MysticPickerViewController *)self.presentedViewController;
            NavLog(@"Close Cam: %@  |  Controllers: %d  %@", picker, picker.viewControllers.count, picker.viewControllers);
            [self dismissViewControllerAnimated:animated completion:^{
                //                [picker finished];
                if(finished) finished();
            }];
        }
        else
        {
            picker = (MysticPickerViewController *)self.modalViewController;
            NavLog(@"Close Cam: %@  |  Controllers: %d  %@", picker, picker.viewControllers.count, picker.viewControllers);
            [self dismissModalViewControllerAnimated:animated];
            //            [picker finished];
            if(finished) finished();
        }
        
        
    }
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    __unsafe_unretained __block  MysticIntroProjectViewController *weakSelf = self;
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.navigationController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"mystifying", nil);
    
    MysticController *viewController;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
    } else {
        viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController info:[NSMutableArray arrayWithArray:info] ready:^(MysticController *editController){
            [editController setInfo:nil finished:^{
                editController.photoInfo = nil;
                [weakSelf.navigationController setViewControllers:@[editController] animated:NO];
            }];
        }];
        
        weakSelf.navigationController.navigationBarHidden = NO;
        [nav pushViewController:viewController animated:NO];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf closeCam:nil];
        
        
    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [nav popToRootViewControllerAnimated:NO];
//    });
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeCam:^{
        
    }];
}
@end

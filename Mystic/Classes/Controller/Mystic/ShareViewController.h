//
//  ShareViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticAPI.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "MysticPhotoContainerView.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import "MysticButtonGridView.h"
#import "MysticBottomLipView.h"
#import "MysticEffectsManager.h"
//#import <ShipLib/ShipLib.h>


@interface ShareViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, MysticProgressHUDDelegate>

@property (retain, nonatomic) IBOutlet UIButton *postcardButton;
@property (retain, nonatomic) IBOutlet UILabel *tagsLabel;
@property (retain, nonatomic) IBOutlet MysticBottomLipView *lipView;
@property (retain, nonatomic) IBOutlet UILabel *photoLabel;
@property (nonatomic, retain) MysticProject *project, *recipe;
@property (retain, nonatomic) IBOutlet UIView *shareControlsView;
@property (nonatomic, retain) IBOutlet UIButton *cpyButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIButton *tweetButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UIButton *openButton;
@property (retain, nonatomic) IBOutlet UIButton *pinButton;
@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (nonatomic, retain) NSString *uniqueHash, *link;
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) NSString *uploadURL;
@property (nonatomic, retain) UIImage *shareImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)img;

- (IBAction)pinImage:(id)sender;

- (IBAction)copyImage:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)email:(id)sender;
- (IBAction)tweet:(id)sender;
- (IBAction)post:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)postcard:(id)sender;
- (IBAction)saveToPhotoAlbum:(id)sender;
- (void)tweetProject;
- (void) postProject;
- (void)emailProject;
- (void)messageProject;


- (void)uploadImage:(UIImage *)image finished:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
- (void) uploadedImageURL:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
- (NSString *) mysticURLString;
- (NSString *) mysticPhotoArtURLString;
- (NSString *) imageURLString;
- (NSString *) folderName;
- (NSString *) thumbnailURLString;
- (NSString *) facebookOGPURLString;
- (void)uploadImage:(UIImage *)image tag:(NSString *)tag finished:(MysticBlockSender)finished failed:(MysticBlockSender)failed;
@end

//
//  MysticIntroViewController.h
//  Mystic
//
//  Created by Me on 11/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "PECropViewController.h"
#import "MysticPermissionView.h"

@interface MysticIntroViewController : UIViewController
{
    

}
@property (nonatomic, assign) MysticPermissionView *permissionView;


- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
- (void) closeCam:(void (^)())finished;
- (void) showNotification;
@end

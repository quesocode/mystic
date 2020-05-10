//
//  MysticIntroViewController.h
//  Mystic
//
//  Created by Me on 11/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticIntroProjectViewController : UIViewController

- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
- (void) closeCam:(void (^)())finished;

@end

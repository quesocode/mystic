//
//  MysticLayersViewController.h
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTableViewController.h"

@interface MysticLayersViewController : MysticTableViewController

@property (assign, nonatomic) BOOL shouldHideToolbar;

- (void) takePhoto;
- (void) takePhotoAndReload;

- (void) choosePhoto;
- (void) choosePhotoAndReload;

- (void) removeOptionAndGoBack:(PackPotionOption *)option;
- (void) removeOption:(PackPotionOption *)option;



@end

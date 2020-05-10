//
//  MysticSettingsController.h
//  Mystic
//
//  Created by Travis A. Weerts on 5/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticNavigationBar.h"
#import "Mystic-Swift.h"

@interface MysticSettingsCell : UITableViewCell
@property (nonatomic, assign) UIView *extraControl;
- (void) commonInit;
@end
@interface MysticClearView : UIView

@end
@interface MysticSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource, SwitcherChangeValueDelegate>
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet MysticNavigationBar *navBar;
@property (nonatomic, assign) id delegate;
@property (retain, nonatomic) IBOutlet UIView *restoreView;
@property (retain, nonatomic) IBOutlet UIImageView *restoreImageView;


@end

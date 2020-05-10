
//
//  MysticTableViewController.h
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "BVReorderTableView.h"

@interface MysticTableViewController : UITableViewController <UITableViewDataSource, ReorderTableViewDelegate>
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, assign) UITableViewStyle mTableViewStyle;
@property (nonatomic, assign) BOOL showLastBorder, showFirstBorder;
@property (nonatomic) BOOL shouldRerenderOnClose;

- (void) initData;
- (void) saveOrder;
- (void) drawerClosed;
- (void) drawerOpened;

- (void) reload;
- (void) commonInit;
- (UIViewController *) loadSection:(NSInteger)section;
- (UIViewController *) loadSection:(NSInteger)section animated:(BOOL)animated;

- (void) scrollToSectionWithTitle:(NSString *)title;
- (void) scrollToSection:(NSInteger)section animated:(BOOL)animated;
- (NSDictionary *) section:(NSInteger)section;
- (NSDictionary *) sectionRow:(NSIndexPath *) indexPath;
- (NSArray *) sectionRows:(NSIndexPath *) indexPath;
- (NSArray *) sectionVisibleRows:(NSIndexPath *)indexPath;
- (void) editing:(BOOL)editing;
- (void) updateNavBar;
- (void) reorderSection:(NSInteger)section rows:(NSArray *)newRows;
- (void) emptyData;

@end

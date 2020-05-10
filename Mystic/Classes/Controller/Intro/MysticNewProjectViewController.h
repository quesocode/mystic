//
//  MysticNewProjectViewController.h
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticNewProjectViewController : UIViewController

@property (nonatomic, retain) NSArray *sections;

- (NSDictionary *) section:(NSInteger)section;
- (NSDictionary *) sectionRow:(NSIndexPath *) indexPath;
- (NSArray *) sectionRows:(NSIndexPath *) indexPath;

@end

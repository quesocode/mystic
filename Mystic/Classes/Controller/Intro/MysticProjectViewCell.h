//
//  MysticProjectViewCell.h
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"

@interface MysticProjectViewCell : UITableViewCell

@property (nonatomic, assign) id delegate;

- (void) loadTemplates:(NSArray *)templates;
@end

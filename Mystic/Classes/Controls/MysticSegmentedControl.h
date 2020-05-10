//
//  MysticSegmentedControl.h
//  Mystic
//
//  Created by Me on 1/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"

@interface MysticSegmentedControl : UISegmentedControl

@property (nonatomic, retain) NSArray *itemsInfo;
- (void) setupWidths;
- (NSDictionary *) itemInfoAtIndex:(NSInteger)atIndex;
- (id) initWithItems:(NSArray *)items itemInfo:(NSArray *)theInfo;

@end

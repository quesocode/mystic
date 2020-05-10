//
//  MysticToolbar.h
//  Mystic
//
//  Created by travis weerts on 3/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticToolbar : UIToolbar

@property (nonatomic, assign) BOOL white;
@property (nonatomic, readonly) id selectedItem;
@property (nonatomic, readonly) id selectedButton;

- (id) itemWithTag:(NSInteger)itemTag;
- (NSInteger) indexOfItemWithTag:(NSInteger)itemTag;

//- (void) printFrame;

@end

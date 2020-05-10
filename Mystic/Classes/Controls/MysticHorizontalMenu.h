//
//  MysticHorizontalMenu.h
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticScrollView.h"

@class MysticHorizontalMenu;

@protocol MysticHorizontalMenuDelegate <NSObject>

@optional

- (void) mysticHorizontalMenu:(MysticHorizontalMenu *)menu buttonTouchedAtIndex:(NSInteger)index;
- (void) mysticHorizontalMenu:(MysticHorizontalMenu *)menu indexChanged:(NSInteger)index;

@end

@interface MysticHorizontalMenu : UIView

@property (nonatomic, retain) MysticButton *leftButton, *rightButton;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) UIFont *font;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, retain) id <MysticHorizontalMenuDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)menuItems;
- (NSDictionary *) itemAtIndex:(NSInteger) index;

- (void) next;
- (void) previous;
- (void) gotoIndex:(NSInteger)index;

@end

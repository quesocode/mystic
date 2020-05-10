//
//  MysticSearchBar.m
//  Mystic
//
//  Created by Me on 3/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import "Mystic.h"
#import "MysticSearchBar.h"

@implementation MysticSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    self.placeholder = @"Search";
    self.tintColor = [UIColor color:MysticColorTypeDrawerToolbarSearch];
    self.translucent = YES;
    self.searchBarStyle = UISearchBarStyleMinimal;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

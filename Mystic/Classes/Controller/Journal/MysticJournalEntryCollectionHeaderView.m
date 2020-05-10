//
//  MysticJournalEntryCollectionHeaderView.m
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalEntryCollectionHeaderView.h"
#import "Mystic.h"

@implementation MysticJournalEntryCollectionHeaderView

@synthesize titleLabel=_titleLabel;

- (void)awakeFromNib{
    [super awakeFromNib];
    [self commonStyle];
}

- (void) dealloc;
{
    [_titleLabel release];
    [super dealloc];
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
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    UILabel *l = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel = [l autorelease];
    [self addSubview:self.titleLabel];
    [self commonStyle];
}

- (void) commonStyle;
{
    self.titleLabel.font = [MysticUI gothamLight:17];
    
}

@end

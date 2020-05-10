//
//  MysticJournalCollectionHeaderView.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionHeaderView.h"
#import "Mystic.h"

@implementation MysticJournalCollectionHeaderView


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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

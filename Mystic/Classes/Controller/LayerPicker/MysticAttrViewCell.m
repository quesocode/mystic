//
//  MysticAttrViewCell.m
//  Mystic
//
//  Created by Me on 7/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAttrViewCell.h"

@implementation MysticAttrViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        OHAttributedLabel *t = [[OHAttributedLabel alloc] initWithFrame:CGRectInset(self.bounds, 20, 0)];
        t.centerVertically = YES;
        t.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        t.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:t];
        self.titleLabel = [t autorelease];
    }
    return self;
}

//- (void)awakeFromNib
//{
//    // Initialization code
//    [super awakeFromNib];
//
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

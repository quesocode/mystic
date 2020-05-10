//
//  MysticProjectViewCell.m
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticProjectViewCell.h"

@implementation MysticProjectViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadTemplates:(NSArray *)templates;
{
    
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *bgColor = [[UIColor hex:@"1e1e1e"] colorWithAlphaComponent:0.5];
    [bgColor setFill];
    
    CGContextFillRect(context, rect);
    
    
    
    // Drawing code
}

@end

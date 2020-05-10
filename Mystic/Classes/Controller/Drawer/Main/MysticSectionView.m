//
//  MysticSectionView.m
//  Mystic
//
//  Created by Travis on 10/15/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSectionView.h"
#import "Mystic.h"


@implementation MysticSectionView

@synthesize label, text;

+ (CGFloat) height;
{
    return MYSTIC_UI_TABLE_SECTION_HEIGHT;
}
- (void) dealloc;
{
    [label release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor color:MysticColorTypeDrawerSection];
        
        CGRect labelFrame = CGRectInset(frame, 8,4);
        
        UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        sectionTitleLabel.backgroundColor = self.backgroundColor;
        sectionTitleLabel.textColor = [UIColor color:MysticColorTypeDrawerSectionText];
        sectionTitleLabel.font = [MysticUI gothamBold:11];
        sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.label = sectionTitleLabel;
        [self addSubview:sectionTitleLabel];
        [sectionTitleLabel release];
    }
    return self;
}
- (void) setText:(NSString *)value;
{
    self.label.text = value;
}
- (NSString *) text;
{
    return self.label.text;
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

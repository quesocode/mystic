//
//  MysticJournalCollectionViewCell.m
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionViewCell.h"
#import "Mystic.h"
#import "MysticJournalCollectionViewLayoutAttributes.h"
#import <OHAttributedLabel/NSAttributedString+Attributes.h>

@interface MysticJournalCollectionViewCell ()
{
    BOOL __hasBeenAdded;
}

@end

@implementation MysticJournalCollectionViewCell

@synthesize titleLabel=_titleLabel, imageView=_imageView;

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
        [self commonStyle];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonStyle];
    }
    return self;
}



- (void) commonStyle;
{
    __hasBeenAdded = NO;
    self.backgroundColor = [UIColor color:MysticColorTypeJournalCellBackground];
    self.titleLabel.font = [MysticUI gothamBold:18];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = UITextAlignmentRight;
    self.titleLabel.textColor = [UIColor color:MysticColorTypeJournalCellTitle];
    self.titleLabel.centerVertically = YES;
    self.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    MBorder(self, nil, 1);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    __hasBeenAdded = NO;
    self.titleLabel.text = @"";
//    self.titleLabel.frame = self.contentView.bounds;
    self.imageView.image = nil;
//    self.imageView.frame = self.contentView.bounds;
//    self.imageView.alpha = 0;
}

- (void) setTitle:(NSString *)title;
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:[NSLocalizedString(title, nil) uppercaseString] ];
    [str setCharacterSpacing:1.8];
    [str setFont:[MysticUI gothamBold:18]];
    [str setTextColor:[UIColor color:MysticColorTypeJournalCellTitle]];
//    [str setTextAlignment:kCTRightTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
    NSInteger strLength = [title length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentRight;
//    style.lineBreakMode = NSLineBreakByWordWrapping;
    [style setLineSpacing:10];
    [str addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, strLength)];
    self.titleLabel.attributedText = str;
    self.titleLabel.centerVertically = YES;
    [style release];
}

- (BOOL) hasBeenAdded;
{
    return __hasBeenAdded;
}
- (void)applyLayoutAttributes:(MysticJournalCollectionViewLayoutAttributes *)layoutAttributes;
{
    [super applyLayoutAttributes:layoutAttributes];
    __hasBeenAdded = layoutAttributes.hasBeenAdded;
//    DLog(@"applyLayoutAttributes: cell (%d,%d) been added before: %@", layoutAttributes.indexPath.section, layoutAttributes.indexPath.item, MBOOL(__hasBeenAdded));

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

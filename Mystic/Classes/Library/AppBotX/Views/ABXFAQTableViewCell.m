//
//  ABXFAQTableViewCell.m
//  Sample Project
//
//  Created by Stuart Hall on 15/06/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXFAQTableViewCell.h"

#import "NSString+ABXSizing.h"
#import "ABXFaq.h"
#import "MysticColor.h"
#import "UIFont+Mystic.h"

@interface ABXFAQTableViewCell ()

@property (nonatomic, strong) UILabel *questionLabel;

@property (nonatomic, strong) ABXFaq *faq;

@end

@implementation ABXFAQTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor color:MysticColorTypeWhite];
        // Text
        self.backgroundView = bgView;
        self.backgroundColor = bgView.backgroundColor;
        self.questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, CGRectGetWidth(self.bounds) - 45, 0)];
        self.questionLabel.textColor = [UIColor color:MysticColorTypeBlack];
        self.questionLabel.font = [MysticFont font:13];
        self.questionLabel.numberOfLines = 0;
        self.questionLabel.backgroundColor = bgView.backgroundColor;
        [self.contentView addSubview:self.questionLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r = self.questionLabel.frame;
    r.size.height = [_faq.question heightForWidth:CGRectGetWidth(self.bounds) - 45
                                          andFont:[ABXFAQTableViewCell font]];
    r.size.width = CGRectGetWidth(self.bounds) - 45;
    self.questionLabel.frame = r;
}

- (void)setFAQ:(ABXFaq*)faq
{
    _faq = faq;
    self.questionLabel.text = faq.question;
    [self setNeedsLayout];
}

+ (UIFont*)font
{
    static dispatch_once_t onceToken;
    static UIFont *font = nil;
    dispatch_once(&onceToken, ^{
        font = [UIFont systemFontOfSize:15];
    });
    return font;
}

+ (CGFloat)heightForFAQ:(ABXFaq*)faq withWidth:(CGFloat)width
{
    return [faq.question heightForWidth:width - 45 andFont:[self font]] + 40;
}

@end

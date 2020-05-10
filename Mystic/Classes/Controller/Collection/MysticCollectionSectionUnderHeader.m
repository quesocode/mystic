//
//  MysticCollectionSectionUnderHeader.m
//  Mystic
//
//  Created by Me on 5/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionSectionUnderHeader.h"
#import "Mystic.h"

@implementation MysticCollectionSectionUnderHeader

- (void) dealloc;
{
    [_button release];
    [_titleLabel release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        CGSize leftBtnIconSize = CGSizeMake(9, 15);

        MysticImage *leftArrow = [MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:@(MysticColorTypeCollectionToolbarIcon)];
        MysticImage *leftArrow2 = [MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:@(MysticColorTypeCollectionToolbarIconHighlighted)];
        
        _button = [[MysticBarButton alloc] initWithFrame:self.bounds];
        _button.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [_button setImage:leftArrow forState:UIControlStateNormal];
        [_button setImage:leftArrow2 forState:UIControlStateHighlighted];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _button.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.autoresizingMask = _button.autoresizingMask;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [MysticFont font:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.textColor = [UIColor color:MysticColorTypeCollectionToolbarText];
        _titleLabel.highlightedTextColor = [UIColor color:MysticColorTypeCollectionToolbarTextHighlighted];
        
        [self.contentView addSubview:_button];
        [self.contentView addSubview:_titleLabel];
        [self setNeedsLayout];
    }
    return self;
}
- (void) setTitle:(NSString *)buttonTitle;
{
    if (buttonTitle)
    {
        self.button.frame = self.bounds;
        self.titleLabel.frame = self.bounds;
        self.titleLabel.text = buttonTitle;
        [self setNeedsLayout];
    }
    else
    {
        
    }
}

//- (void) setFrame:(CGRect)frame;
//{
//    [super setFrame:frame];
//}

//- (void) layoutSubviews;
//{
//    [super layoutSubviews];
//    CGSize size = [self.button.titleLabel.text sizeWithFont:self.button.font];
//    CGRect f = self.bounds;
//    CGFloat x = ((f.size.width - size.width)/2);
//    x = x - 37;
//    x = 0;
//    _button.titleEdgeInsets = UIEdgeInsetsMake(0, x, 0, 0);
//}


@end

//
//  MysticCollectionViewCellSectionHeader.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewCellSectionHeader.h"
#import "Mystic.h"


@interface MysticCollectionViewCellSectionHeader ()
{
    
}

@end


@implementation MysticCollectionViewCellSectionHeader

- (void) dealloc;
{
    [super dealloc];
    [_titleLabel release];
    [_indexPath release];
    [_button release];
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
    self.backgroundColor = [UIColor color:MysticColorTypeCollectionSectionHeaderBackground];
    
    
    
    self.titleLabel = [[[OHAttributedLabel alloc] initWithFrame:self.bounds] autorelease];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.centerVertically = YES;
    _showBorder = YES;
    _topBorderWidth = 2;
    [self addSubview:self.titleLabel];
    
}

- (void) setTrackTouch:(BOOL)trackTouch;
{
    if(trackTouch)
    {
        if(!self.button)
        {
            self.button = [[[MysticButton alloc] initWithFrame:self.bounds] autorelease];
            self.button.backgroundColor = [UIColor clearColor];
            [self.button addTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self insertSubview:self.button aboveSubview:self.titleLabel];
        }
    }
    else
    {
        if(self.button)
        {
            [self.button removeFromSuperview];
            [self.button removeTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void) didTouch:(id)sender;
{
    
}

- (void) setTitle:(NSString *)titleStr;
{
    NSRange strRange = NSMakeRange(0, [titleStr length]);
    
    
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:NSLocalizedString(titleStr, nil) ];
    [str setCharacterSpacing:MYSTIC_UI_PICKER_HEADER_CHAR_SPACING];
    [str setFont:[MysticUI gothamBook:MYSTIC_UI_PICKER_HEADER_FONTSIZE] range:strRange];
    
    [str setTextColor:[UIColor color:MysticColorTypeCollectionSectionHeaderText] range:strRange];

    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
//    [style setLineSpacing:3];
    [str addAttribute:NSParagraphStyleAttributeName
                value:style
                range:strRange];
    
    [style release];
    
    self.titleLabel.attributedText = str;
}



- (void) prepareForReuse;
{
    _showBorder = YES;
    self.titleLabel.attributedText = nil;
    
}
- (void) setCollectionItem:(MysticCollectionItem *)collectionItem;
{
    

    if(collectionItem.indexPath.section == 0)
    {
        self.showBorder = NO;
        [self setNeedsDisplay];
    }
    else
    {
        self.showBorder = YES;
    }
    
}

- (void) setShowBorder:(BOOL)showBorder;
{
    _showBorder = showBorder;
    CGRect newFrame =   self.titleLabel.frame;
    newFrame.origin.y = (showBorder ? self.topBorderWidth : 0);
    newFrame.size.height = self.frame.size.height - (showBorder ? self.topBorderWidth : 0);
    self.titleLabel.frame = newFrame;
    
}



- (void) drawRect:(CGRect)rect;
{
    //    [super drawRect:rect];
    if(!_showBorder) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = self.topBorderWidth;
    UIColor *borderColor = [UIColor color:MysticColorTypeCollectionSectionBackground];
    //    borderColor =[UIColor red];
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    
    CGRect borderRect = (CGRect){0, borderWidth/2, rect.size.width, borderWidth};
    
    CGContextMoveToPoint(context, borderRect.origin.x, borderRect.origin.y);
    CGContextAddLineToPoint(context, borderRect.size.width, borderRect.origin.y);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextStrokePath(context);
    
}

@end

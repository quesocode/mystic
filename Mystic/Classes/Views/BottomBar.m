//
//  BottomBar.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "BottomBar.h"
#import "Mystic.h"
#import <QuartzCore/QuartzCore.h>

@interface BottomBar ()
{
    UILabel *titleLabel;
}

@end
@implementation BottomBar

@synthesize title=_title;

static CGFloat titleLabelHeight = 12.0f;

- (void) dealloc
{
    if(titleLabel) [titleLabel release], titleLabel=nil;
    [super dealloc];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

//        self.clipsToBounds = NO;
//        self.autoresizesSubviews = NO;
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.clipsToBounds = NO;
        self.autoresizesSubviews = NO;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.title = title;
    }
    return self;
}

- (NSString *) title
{
    return !titleLabel ? nil : titleLabel.text;
}
- (void) setTitle:(NSString *)mytitle
{
    return;
//    
//    if(!mytitle || [mytitle isEqualToString:@""])
//    {
//        if(titleLabel)
//        {
//            [titleLabel removeFromSuperview];
//            [titleLabel release];
//            titleLabel = nil;
//        }
//        return;
//    }
//    
//    mytitle = [mytitle uppercaseString];
//    CGFloat titlePadding = 0;
//    UIFont *labelFont = [MysticUI gothamBold:12];
//    CGRect labelFrame = CGRectMake(0, -4, CGRectGetWidth(self.frame), titleLabelHeight);
//    
//    CGSize lsize = [mytitle sizeWithFont:labelFont];
////    lsize.width += 2;
//    labelFrame.size = lsize;
//    labelFrame.size.height = titleLabelHeight;
//    
//    
//    
//    double nDots = ceil((labelFrame.size.width + titlePadding)/7);
//    
//    nDots+=1;
//    
//    
//    
//    CGFloat newW = (CGFloat)nDots *7.0f;
//    
//    labelFrame.size.width = newW > labelFrame.size.width ? newW : newW;
//    
//    double nTots = ceil(self.frame.size.width/7);
//    
//    double dDots = floor((nTots-nDots)/2);
//    
//
//    labelFrame.origin.x = (CGFloat)ceil(dDots*7);
//    
//    if(!titleLabel)
//    {
//
//        titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
//
//        titleLabel.font = labelFont;
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        titleLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-footer-label-tile.png"]];
//        titleLabel.textColor = [UIColor colorWithRed:(CGFloat)22/255 green:(CGFloat)22/255 blue:(CGFloat)22/255 alpha:0.9];
//        titleLabel.shadowColor = [UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)94/255 blue:(CGFloat)93/255 alpha:0.9];
//        titleLabel.shadowOffset = CGSizeMake(0, 1);
//        titleLabel.numberOfLines = 1;
//        [self addSubview:titleLabel];
//    }
//    titleLabel.frame = labelFrame;
//    titleLabel.text = mytitle;
}


@end

//
//  MysticProjectSectionView.m
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticProjectSectionView.h"
#import "UIColor+Mystic.h"

@implementation MysticProjectSectionView

@synthesize text, label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect lFrame = frame;
        lFrame.origin.x = 10;
        lFrame.size.width -= lFrame.origin.x;
        UILabel *alabel = [[UILabel alloc] initWithFrame:lFrame];
        alabel.font = [UIFont boldSystemFontOfSize:13];
        alabel.textAlignment = NSTextAlignmentLeft;
        alabel.textColor = [UIColor hex:@"c19156"];
        alabel.backgroundColor = [UIColor clearColor];
        self.label = alabel;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:alabel];
        [alabel release];
    }
    return self;
}

- (NSString *) text;
{
    return self.label.text;
}
- (void) setText:(NSString *)someText;
{
    self.label.text = someText;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *bgColor = [[UIColor hex:@"1e1e1e"] colorWithAlphaComponent:0.5];
    [bgColor setFill];
    
    CGContextFillRect(context, rect);
    
    UIColor *lineColor = [[UIColor hex:@"6c5f59"] colorWithAlphaComponent:0.5];
    [lineColor setFill];
    
    CGRect lineRect = rect;
    lineRect.origin.y = rect.size.height - 1;
    lineRect.size.height = 1;
    CGContextFillRect(context, lineRect);

    // Drawing code
}


@end

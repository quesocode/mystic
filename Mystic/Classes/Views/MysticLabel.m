//
//  MysticLabel.m
//  Mystic
//
//  Created by travis weerts on 1/30/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLabel.h"
#import "UIColor+Mystic.h"
#import "MysticUI.h"

@interface MysticLabel ()
{
    UILabel *topLabel;
}
@end

@implementation MysticLabel

@synthesize inNavBar=_inNavBar, verticalAlignment=verticalAlignment_;

- (void) dealloc
{
    if(topLabel) [topLabel release], topLabel=nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews=YES;
        CGRect dframe = frame;
        dframe.origin.y = -0.5;
        dframe.origin.x = -0.5;
//        topLabel = [[UILabel alloc] initWithFrame:dframe];
        self.font = [MysticUI gothamLight:22];
        //self.textColor = [UIColor colorWithRed:174.0f/255.0f green:76.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
        self.textColor = [UIColor mysticChocolateColor];
        self.verticalAlignment = VerticalAlignmentMiddle;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.inNavBar = NO;
        self.clipsToBounds = NO;
        self.duration = 0.15;
//        topLabel.font = [UIFont fontWithName:@"ThirstyRoughBolOne" size:22];
//        topLabel.textColor = [UIColor mysticWhiteColor];
//        topLabel.textAlignment = self.textAlignment;
//        topLabel.backgroundColor = [UIColor clearColor];
//        topLabel.clipsToBounds=NO;
//        [self addSubview:topLabel];
        
    }
    return self;
}

- (BOOL) clipsToBounds { return NO; }


- (void) setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
//    topLabel.textAlignment = textAlignment;
}


- (void) setFrame:(CGRect)frame
{
    if(self.inNavBar)
    {
        
        CGRect cframe = self.frame;
        cframe.size.width = CGRectGetWidth(frame);
        cframe.origin.x = CGRectGetMinX(frame);
        [super setFrame:cframe];
        return;
    }
    
    [super setFrame:frame];
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
    verticalAlignment_ = verticalAlignment;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.size.height = 22;
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
//    textRect.origin.y+=5;
    return textRect;
}

- (CGRect) bounds
{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect dframe = self.bounds;
    if(CGSizeEqualToSize(requestedRect.size, CGSizeZero)) return;
    CGRect actualRect = [self textRectForBounds:dframe limitedToNumberOfLines:self.numberOfLines];
//    CGRect newframe = actualRect;
//    newframe.size.width = CGRectGetWidth(self.frame);
//    newframe.size.height = 30;
//    //newframe.origin.x = actualRect.origin.x - 0.5;
//    newframe.origin.x = -0.5;
//    newframe.origin.y = actualRect.origin.y - 4.5;
    
//    topLabel.frame = newframe;
    if(CGSizeEqualToSize(actualRect.size, CGSizeZero)) return;
    [super drawTextInRect:actualRect];
}

@end

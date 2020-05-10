//
//  MysticEditableLabel.m
//  Mystic
//
//  Created by travis weerts on 8/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticEditableLabel.h"

@interface MysticEditableLabel ()
{
    BOOL _active;
    UIView *debugView;
}
@end

@implementation MysticEditableLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.text = @"double tap to edit";
        self.font= [PackPotionOptionFont defaultFont];
        self.clipsToBounds = NO;
        self.autoresizesSubviews = NO;

        [self addSubview:debugView];
        _active = NO;
    }
    return self;
}
- (BOOL) isFirstResponder;
{
     return _active;
}
- (BOOL) becomeFirstResponder;
{
//    DLog(@"become active: %@", self.text);
    _active = YES;
    
//    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    
    return _active;
}

- (CGFloat) fontSize;
{
    return [self.font pointSize];
}


- (BOOL) resignFirstResponder;
{
//    DLog(@"become inactive: %@", self.text);
    _active = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    return YES;
}
- (void) setText:(NSString *)text;
{
    [super setText:text];
    self.numberOfLines = self.numberOfBreaks;
}
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
}
- (CGRect) resize:(CGSize)newSize;
{
//    SLog(@"label.resize:", newSize);
    return self.frame;
}

- (CGSize) refresh;
{

        CGRect frame = self.frame;
    return [self refresh:frame];
    
}
- (CGSize) refresh:(CGRect)frame;
{
//    FLog(@"refreshing to frame", frame);
//        CGFloat newHeight = [self lineHeightInRect:frame];
        CGFloat nfontsize = frame.size.height;
    
        
        
        UIFont *nf = [self.font fontWithSize:frame.size.height*2];
        CGSize size = [self.text sizeWithFont:nf minFontSize:10 actualFontSize:&nfontsize forWidth:frame
                       .size.width lineBreakMode:NSLineBreakByWordWrapping];
       
    
//    DLog(@"BEFORE fontSize: point: %2.2f line: %2.2f", self.font.pointSize, self.font.lineHeight);
    
        self.font = [self.font fontWithSize:nfontsize];
    
//    DLog(@"fontSize: point: %2.2f line: %2.2f", self.font.pointSize, self.font.lineHeight);
    debugView.frame = CGRectMake(0, 0, size.width, size.height);
    debugView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    
//    DLog(@"number of lines: %d", self.numberOfLines);
        return size;
        
    
}

- (CGFloat) lineHeightInRect:(CGRect)frame;
{
    return frame.size.height/self.numberOfBreaks;
}
- (NSInteger) numberOfBreaks;
{
    return [[self.text componentsSeparatedByCharactersInSet:
             [NSCharacterSet newlineCharacterSet]] count];
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

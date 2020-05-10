//
//  WDLabel.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2008-2013 Steve Sprang
//

#import "WDLabel.h"
#import "MysticCommon.h"
#import "MysticAttrString.h"

#define kLabelCornerRadius 9.0f

@implementation WDLabel

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    rect = CGRectInset(rect, 8.0f, 8.0f);
    CGContextSetShadow(ctx, CGSizeMake(0, 2), 4);
    
    [[UIColor colorWithWhite:0.0f alpha:0.5f] set];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kLabelCornerRadius];
    [path fill];
    
//    [[UIColor whiteColor] set];
//    path.lineWidth = 2;
//    [path stroke];
    
    [super drawRect:rect];
}

@end

@implementation MysticMessage

- (instancetype) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = UIColor.redColor.CGColor;
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.backgroundColor = UIColor.clearColor;
    [self addSubview:label];
    self.label = label;
    self.layer.cornerRadius = kLabelCornerRadius;
    self.clipsToBounds = YES;
//    self.layer.masksToBounds = YES;
    self.autoresizesSubviews = NO;
    return self;
}
- (void) setText:(id)text;
{
//    DLog(@"set text: %@", text);
    text = [[MysticAttrString string:text style:MysticStringStyleMessage] attrString];
    if([text isKindOfClass:[NSAttributedString class]]) self.label.attributedText = text;
    else self.label.text = text;
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    CGRect nf = CGRectZero;
    nf.size = self.bounds.size;
    self.blurView.frame = nf;
    self.label.frame = CGRectAddXY(nf, 5,0);

//    PrintView(@"size", self);

}
- (void) sizeToFit;
{
    [self.label sizeToFit];
    self.bounds = self.label.bounds;
    CGRect nf = CGRectZero;
    nf.size = self.bounds.size;
    self.blurView.frame = nf;
    
}
@end

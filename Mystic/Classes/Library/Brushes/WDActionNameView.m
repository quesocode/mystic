//
//  WDActionNameView.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDActionNameView.h"
#import "MysticFont.h"
#import "MysticAttrString.h"

#define kWDActionNameFadeDelay          0.666f
#define kWDActionNameFadeOutDuration    0.2f
#define kWDActionNameCornerRadius       9

@implementation WDActionNameView

@synthesize titleLabel;
@synthesize messageLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:.85];
    self.autoresizesSubviews = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CALayer *layer = self.layer;
    layer.cornerRadius = kWDActionNameCornerRadius;
    
    frame = CGRectInset(self.bounds, 10, 5);
    frame.size.height /= 2;
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [MysticFont gotham:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = nil;
    titleLabel.opaque = NO;
    titleLabel.textColor =[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00];
    [self addSubview:titleLabel];
    
    frame = CGRectOffset(frame, 0, CGRectGetHeight(frame));
    self.messageLabel = [[UILabel alloc] initWithFrame:frame];
    messageLabel.font = [MysticFont gotham:11];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = nil;
    messageLabel.opaque = NO;
    messageLabel.textColor = [UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:0.75];
    messageLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:messageLabel];
    
    return self;
}

- (void) startFadeOut:(id)obj;
{
    if (delegate) [delegate fadingOutActionNameView:self];
    
    [UIView animateWithDuration:kWDActionNameFadeOutDuration animations:^{
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (delegate) [delegate fadedOutActionNameView:self];
    }];
}
- (void) setTitle:(NSString *)title message:(NSString *)message;
{
    titleLabel.text = !title ? nil : NSLocalizedString(title, nil).uppercaseString;
    messageLabel.text = !message ? nil : NSLocalizedString(message, nil).uppercaseString;
    [self setNeedsLayout];
//    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [self performSelector:@selector(startFadeOut:) withObject:nil afterDelay:kWDActionNameFadeDelay];
}
- (void) setUndoActionName:(NSString *)undoActionName
{
    titleLabel.text = NSLocalizedString(@"UNDO", @"Undo");
    messageLabel.text = undoActionName.uppercaseString;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startFadeOut:) withObject:nil afterDelay:kWDActionNameFadeDelay];
    [self setNeedsLayout];
}

- (void) setRedoActionName:(NSString *)redoActionName
{
    titleLabel.text = NSLocalizedString(@"REDO", @"Redo");
    messageLabel.text = redoActionName.uppercaseString;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startFadeOut:) withObject:nil afterDelay:kWDActionNameFadeDelay];
    [self setNeedsLayout];
}

- (void) setConnectedDeviceName:(NSString *)deviceName
{
    titleLabel.text = NSLocalizedString(@"CONNECTED", @"Connected");
    messageLabel.text = deviceName.uppercaseString;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startFadeOut:) withObject:nil afterDelay:kWDActionNameFadeDelay];
    [self setNeedsLayout];
}

- (void) setDisconnectedDeviceName:(NSString *)deviceName;
{
    titleLabel.text = NSLocalizedString(@"DISCONNECTED", @"Disconnected");
    messageLabel.text = deviceName.uppercaseString;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startFadeOut:) withObject:nil afterDelay:kWDActionNameFadeDelay];
    [self setNeedsLayout];
}

- (void) layoutSubviews;
{
    CGRect frame = CGRectInset(CGRectMake(0, 0, kMysticImageMessageWidth,kMysticImageMessageHeight), 10, 5);
    frame.size.height = 35;
    BOOL hasTitle = self.titleLabel.text != nil;
    BOOL hasMsg = self.messageLabel.text != nil;
    CGRect titleFrame = frame;
    CGRect msgFrame = frame;
    if(hasTitle && hasMsg) msgFrame = CGRectOffset(titleFrame, 0, CGRectGetHeight(titleFrame));
    CGFloat minY = MIN(CGRectGetMinY(titleFrame), CGRectGetMinY(msgFrame));
    CGFloat maxY = MAX(CGRectGetMaxY(titleFrame), CGRectGetMaxY(msgFrame));
    self.bounds = CGRectMake(0, 0, self.bounds.size.width, maxY-minY + 10);
    self.titleLabel.frame = titleFrame;
    self.messageLabel.frame = msgFrame;
}

@end


//
//  WDStylusTableCell.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDStylusTableCell.h"
#import "UIImage+Additions.h"
#import "MysticCommon.h"
#import "MysticImage.h"

@implementation WDStylusTableCell

@synthesize stylusData;

- (UIImage *) batteryImageWithPercentage:(float)percentage
{
    if (percentage < 0.0) {
        return nil;
    }
    
    UIBezierPath *path = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 28), NO, 0.0f);
    
    // semi transparent white fill of the battery base
    CGRect baseBounds = CGRectMake(0, 3, 15, 25);
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(baseBounds, 1.0, 1.0) cornerRadius:1];
    [self.backgroundColor set];
    [path fill];
    
    // draw the battery's current capacity
    CGRect capacityBounds = CGRectInset(baseBounds, 2, 2);
    float height = floor(capacityBounds.size.height * percentage);
    capacityBounds.origin.y += (capacityBounds.size.height - height);
    capacityBounds.size.height = height;
    
    if (percentage > 0.10f) {
        [[UIColor color:MysticColorTypeGreen] set];
//        [[UIColor colorWithRed:0 green:0.6f blue:0.2 alpha:1] set];
    } else {
//        [[UIColor colorWithRed:0.8f green:0 blue:0 alpha:1] set];
        [[UIColor color:MysticColorTypeRed] set];

    }
    
    path = [UIBezierPath bezierPathWithRect:capacityBounds];
    [path fill];
    
    // draw a border around the battery
    [[UIColor colorWithRed:0.84 green:0.82 blue:0.76 alpha:1.00] set];
    
    // main body
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(baseBounds, 0.5, 0.5) cornerRadius:1];
    path.lineWidth = 1;
    [path stroke];
    
    // cap
//    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(CGRectMake(4, 1, 7, 3), 0.5, 0.5) cornerRadius:1];
//    [path fill];
  
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void) setStylusData:(WDStylusData *)inStylusData
{
    stylusData = inStylusData;
    
    self.textLabel.text = stylusData.productName;
    self.textLabel.textColor = [UIColor colorWithRed:0.84 green:0.82 blue:0.76 alpha:1.00];
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.27 green:0.25 blue:0.23 alpha:1.00];

    if (stylusData.type != WDNoStylus) {
        self.detailTextLabel.text = stylusData.connected ? NSLocalizedString(@"Connected", @"Connected") :
        NSLocalizedString(@"Disconnected", @"Disconnected");
    } else {
        self.detailTextLabel.text = NSLocalizedString(@"Simulated Pressure", @"Simulated Pressure");
    }
    
    if (stylusData.batteryLevel) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[self batteryImageWithPercentage:stylusData.batteryLevel.floatValue]];
    } else {
        self.accessoryView = nil;
    }
    
    if (inStylusData.type == [WDStylusManager sharedStylusManager].mode) {
        self.imageView.image = [MysticIcon iconForType:MysticIconTypeConfirm size:(CGSize){MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM} color:[UIColor colorWithRed:0.96 green:0.35 blue:0.42 alpha:1.00]];
    } else {
        self.imageView.image = [MysticImage backgroundImageWithColor:[UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00] size:(CGSize){MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM}];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (!self) {
        return nil;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
    self.indentationWidth = 0;
    self.preservesSuperviewLayoutMargins = NO;
    self.backgroundColor=[UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00];
    self.contentView.backgroundColor=self.backgroundColor;
    return self;
}

@end

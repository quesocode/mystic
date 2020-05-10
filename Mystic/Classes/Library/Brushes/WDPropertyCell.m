//
//  WDPropertyCell.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDProperty.h"
#import "WDPropertyCell.h"
#import "MysticAttrString.h"

@implementation WDPropertyCell

@synthesize slider;
@synthesize title;
//@synthesize value;
//@synthesize decrement;
//@synthesize increment;

@synthesize property;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) awakeFromNib;
{
    self.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.00];
    self.contentView.backgroundColor = self.backgroundColor;
    self.indentationWidth = 0;
    self.preservesSuperviewLayoutMargins = NO;
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
    self.slider = [MysticSlider sliderWithFrame:(CGRect){30,20, [MysticUI screen].width-60, 40}];
    self.slider.thumbSize = CGSizeMake(20,20);
    self.slider.lowerHandleHidden = YES;
    self.slider.defaultValue = 0;
    [self.slider addTarget:self action:@selector(takeValueFrom:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.slider];
    [super awakeFromNib];
}
- (void) updateInterfaceElements
{
    slider.value = property.value;
//    
//    if (property.percentage) {
//        value.text = [NSString stringWithFormat:@"%d%%", (int) roundf(property.value * property.conversionFactor)];
//    } else {
//        value.text = [NSString stringWithFormat:@"%d", (int) roundf(property.value * property.conversionFactor)];
//    }
//
//    increment.enabled = property.canIncrement;
//    decrement.enabled = property.canDecrement;
}

- (void) propertyChanged:(NSNotification *)aNotification
{
    [self updateInterfaceElements];
}

- (void) setProperty:(WDProperty *)aProperty
{
    property = aProperty;
    title.attributedText = [[MysticAttrString string:property.title.uppercaseString style:MysticStringStyleBrushPropertyTitle] attrString];
    
    // set min/max before setting the value
    slider.minimumValue = property.minimumValue;
    slider.maximumValue = property.maximumValue;
    slider.value = property.value;

    [self updateInterfaceElements];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(propertyChanged:)
                                                 name:WDPropertyChangedNotification
                                               object:aProperty];
}

- (IBAction) takeValueFrom:(UISlider *)sender
{
    self.property.value = sender.value;
}

- (IBAction)increment:(id)sender
{
    [property increment];
}

- (IBAction)decrement:(id)sender
{
    [property decrement];
}

- (void) layoutSubviews;
{
    [super layoutSubviews];
    self.title.center = CGPointMake(self.frame.size.width/2, self.title.center.y);
    self.slider.frame = (CGRect){30,20, self.frame.size.width-60, 40};
}
@end

//
//  MysticControl.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticControl.h"

@implementation MysticControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
//    self.maximumValue = (CGFloat)NSIntegerMax;
//    self.minimumValue = (CGFloat)NSIntegerMin;
    
    _maximumValue = MYSTIC_MAX_FLOAT;
    _minimumValue = MYSTIC_MIN_FLOAT;

    
    self.toolType = MysticToolTypeUnknown;
    self.cancelsEvents = NO;
}
- (void) setEmpty;
{
    
}
- (void) resetValue;
{
    self.value = self.defaultValue;
    
}
- (void) setValue:(CGFloat)value;
{
    CGFloat f = _value;
    CGFloat svalue = value;
    svalue = self.maximumValue != MYSTIC_MAX_FLOAT ? MIN(self.maximumValue, svalue) : svalue;
    svalue = self.minimumValue != MYSTIC_MIN_FLOAT ? MAX(self.minimumValue, svalue) : svalue;
    _value = svalue;
    if(f != _value)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    
}

- (void) sendActionsForControlEvents:(UIControlEvents)controlEvents;
{
    if(self.cancelsEvents) return;
    [super sendActionsForControlEvents:controlEvents];
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

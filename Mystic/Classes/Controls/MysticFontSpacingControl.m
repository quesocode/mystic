//
//  MysticFontSpacingControl.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontSpacingControl.h"

@implementation MysticFontSpacingControl

@dynamic incrementSize;

- (void) dealloc;
{
    [_label release];
    [_leftButton release];
    [_rightButton release];
    [super dealloc];
}

- (MysticIconType) plusIconType; { return MysticIconTypeToolRightCenter; }
- (MysticIconType) minusIconType; { return MysticIconTypeToolLeftCenter; }
- (CGFloat) minimumValue; { return -10; }
- (CGFloat) labelFontSize; { return 16; }
- (CGFloat) maximumValue; { return 10; }
- (CGFloat) defaultValue; { return 0; }
- (CGFloat) emptyValue; { return 0; }
- (CGFloat) incrementSize; { return 1; }
- (BOOL) allowLoop; { return NO; }
- (MysticToolType) toolType; { return MysticToolTypeFontSize; }
- (NSTimeInterval) incrementInterval; { return MYSTIC_HOLD_INTERVAL_MEDIUM; }
- (NSString *) labelFormatString; { return @"%2.0f"; }



- (void) commonInit;
{
    [super commonInit];

    CGFloat buttonInset = -5;

    __unsafe_unretained __block MysticFontSpacingControl *weakSelf = self;
    CGSize buttonFrameSize = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
//    CGSize buttonSize = buttonFrameSize;
    CGSize iconSize = (CGSize){30,30};

    MysticButton * minusButton = [MysticButton buttonWithImage:[MysticImage image:@(self.minusIconType) size:iconSize color:@(MysticColorTypeSizeControlIcon)] target:nil sel:nil];
    minusButton.continueOnHold = YES;
    minusButton.holdingInterval = self.incrementInterval;

    [minusButton addTarget:self action:@selector(decreaseDown:) forControlEvents:UIControlEventTouchDown];
    [minusButton addTarget:self action:@selector(decrease:) forControlEvents:UIControlEventTouchUpInside];

    
    MysticButton * plusButton = [MysticButton buttonWithImage:[MysticImage image:@(self.plusIconType) size:iconSize color:@(MysticColorTypeSizeControlIcon)] target:nil sel:nil];
    plusButton.continueOnHold = YES;
    plusButton.holdingInterval = self.incrementInterval;
    [plusButton addTarget:self action:@selector(increaseDown:) forControlEvents:UIControlEventTouchDown];
    [plusButton addTarget:self action:@selector(increase:) forControlEvents:UIControlEventTouchUpInside];

    
    CGRect labelFrame = self.bounds;

    MysticAnimatedLabel *label = [[MysticAnimatedLabel alloc] initWithFrame:labelFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor color:MysticColorTypeSizeControlTextDisabled];
    label.highlightedTextColor = [UIColor color:MysticColorTypeSizeControlText];
    label.font = [UIFont boldSystemFontOfSize:self.labelFontSize];
    label.userInteractionEnabled = NO;


    self.label = [label autorelease];
    self.leftButton = [minusButton autorelease];
    self.rightButton = [plusButton autorelease];
    self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, buttonInset, 0, 0);
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, buttonInset);
    self.leftButton.frame = CGRectMake(0, 0, buttonFrameSize.width, buttonFrameSize.height);
    self.rightButton.frame = CGRectMake(self.bounds.size.width - buttonFrameSize.width, 0, buttonFrameSize.width, buttonFrameSize.height);
    
    
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.leftButton.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    self.rightButton.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    self.label.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    super.value = self.defaultValue;
    
    [self setValueText:super.value animated:NO];

    
}
- (void) increase:(id)sender;
{
    [self increase];
}
- (void) decrease:(id)sender;
{
    [self decrease];
}
- (void) increaseDown:(id)sender;
{
    [self setValue:(self.value + self.incrementSize) animated:NO];
}
- (void) decreaseDown:(id)sender;
{
    [self setValue:(self.value - self.incrementSize) animated:NO];

}
- (void) increase;
{
    self.value += self.incrementSize;
}

- (void) decrease;
{
    self.value -= self.incrementSize;
    
}


- (void) setValue:(CGFloat)value;
{
    [self setValue:value animated:YES];
}
- (void) setValue:(CGFloat)value animated:(BOOL)animated;
{
    if((value < self.minimumValue || value > self.maximumValue) && !self.allowLoop) return;
    
    value = value < self.minimumValue ? self.defaultValue : value;
    value = value > self.maximumValue ? self.defaultValue : value;

    CGFloat f = super.value;
    
    super.value = value;
    self.label.highlighted = YES;

    if(f != super.value)
    {
        [self setValueText:super.value animated:animated];
    }
    
}
- (CGFloat) formatValue:(CGFloat)newValue;
{
    return newValue;
}
- (NSString *)formatValueString:(CGFloat)newValue;
{
    CGFloat formattedValue = [self formatValue:newValue];
//    NSNumber *n = [NSNumber numberWithFloat:formattedValue];
    return [NSString stringWithFormat:self.labelFormatString, formattedValue];
}
- (void) setValueText:(CGFloat)value animated:(BOOL)animated;
{
    animated = self.cancelsEvents ? NO : animated;
    self.label.highlighted = YES;
    [self.label setText:[self formatValueString:value] animated:animated];
}

- (void) setEmpty;
{
    [self resetValue];
    self.label.highlighted = NO;
    [self.label setText:[self formatValueString:self.emptyValue] animated:NO];
    
    
}
- (void) setEnabled:(BOOL)enabled;
{
    [super setEnabled:enabled];
    self.leftButton.enabled = enabled;
    self.rightButton.enabled = enabled;
    
}
- (void) setLeftButton:(MysticButton *)button;
{
    if(_leftButton)
    {
        [_leftButton removeFromSuperview];
        [_leftButton release], _leftButton=nil;
    }
    if(button)
    {
        _leftButton = [button retain];
        _leftButton.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;

        [self addSubview:_leftButton];
    }
}
- (void) setRightButton:(MysticButton *)button;
{
    if(_rightButton)
    {
        [_rightButton removeFromSuperview];
        [_rightButton release], _rightButton=nil;
    }
    if(button)
    {
        _rightButton = [button retain];
        _rightButton.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;

        [self addSubview:_rightButton];
    }
}
- (void) setLabel:(MysticAnimatedLabel *)label;
{
    if(_label)
    {
        [_label removeFromSuperview];
        [_label release], _label=nil;
    }
    if(label)
    {
        _label = [label retain];
        _label.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        [self addSubview:_label];
    }
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

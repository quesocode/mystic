//
//  MysticFontSizeControl.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontSizeControl.h"

@implementation MysticFontSizeControl


- (MysticIconType) plusIconType; { return MysticIconTypeToolPlus; }
- (MysticIconType) minusIconType; { return MysticIconTypeToolMinus; }
- (CGFloat) minimumValue; { return 1; }
- (CGFloat) maximumValue; { return 1000; }
- (CGFloat) defaultValue; { return MYSTIC_DEFAULT_FONTSIZE; }
- (CGFloat) incrementSize; { return 1; }
- (BOOL) allowLoop; { return NO; }
- (NSTimeInterval) incrementInterval; { return MYSTIC_HOLD_INTERVAL_NORMAL; }
- (NSString *) labelFormatString; { return @"%2.0f"; }

- (MysticToolType) toolType; { return MysticToolTypeFontSize; }



/*
- (void) dealloc;
{
    [_label release];
    [_leftButton release];
    [_rightButton release];
    [super dealloc];
}


- (void) commonInit;
{

    [super commonInit];
    self.toolType = MysticToolTypeFontSize;
    self.minimumValue = 1;
    self.maximumValue = 1000;
    self.defaultValue = MYSTIC_DEFAULT_FONTSIZE;
    self.incrementSize = 1;
    CGFloat buttonInset = -5;
    __unsafe_unretained __block MysticFontSizeControl *weakSelf = self;
    CGSize buttonFrameSize = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
    CGSize buttonSize = buttonFrameSize;
    CGSize iconSize = (CGSize){30,30};
    MysticButton * plusButton = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolPlus) size:iconSize color:@(MysticColorTypeSizeControlIcon)] target:nil sel:nil];
    plusButton.continueOnHold = YES;
    plusButton.holdingInterval = MYSTIC_HOLD_INTERVAL_SLOW;
    plusButton.contentMode = UIViewContentModeCenter;

    
    
    [plusButton addTarget:self action:@selector(increase:) forControlEvents:UIControlEventTouchUpInside];
    [plusButton addTarget:self action:@selector(increaseDown:) forControlEvents:UIControlEventTouchDown];

    
    MysticButton * minusButton = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolMinus) size:iconSize color:@(MysticColorTypeSizeControlIcon)] target:nil sel:nil];
    minusButton.continueOnHold = YES;
    minusButton.holdingInterval = MYSTIC_HOLD_INTERVAL_SLOW;

    minusButton.contentMode = UIViewContentModeCenter;
    [minusButton addTarget:self action:@selector(decrease:) forControlEvents:UIControlEventTouchUpInside];
    [minusButton addTarget:self action:@selector(decreaseDown:) forControlEvents:UIControlEventTouchDown];


    CGRect labelFrame = self.bounds;
    
    MysticAnimatedLabel *label = [[MysticAnimatedLabel alloc] initWithFrame:labelFrame];
    label.textColor = [UIColor color:MysticColorTypeSizeControlTextDisabled];
    label.highlightedTextColor = [UIColor color:MysticColorTypeSizeControlText];
    label.font = [UIFont boldSystemFontOfSize:[label.font pointSize]];
    label.clipsToBounds = NO;
    label.textAlignment = NSTextAlignmentCenter;
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
- (void) increaseDown:(id)sender;
{
    [self setValue:(self.value + self.incrementSize) animated:NO];
}
- (void) decreaseDown:(id)sender;
{
    [self setValue:(self.value - self.incrementSize) animated:NO];
    
}
- (void) increase:(id)sender;
{
    [self increase];
}
- (void) decrease:(id)sender;
{
    [self decrease];
}
- (void) increase;
{
    self.value += self.incrementSize;
}
- (void) decrease;
{

    self.value -= self.incrementSize;

}
- (void) resetValue;
{
    super.value = self.defaultValue;
    
}
- (void) setValue:(CGFloat)value;
{
    [self setValue:value animated:YES];
}
- (void) setValue:(CGFloat)value animated:(BOOL)animated;
{
    value = value <= 0 ? self.defaultValue : roundf(value);
    CGFloat f = super.value;
    super.value = value;
    if(f != super.value)
    {
        [self setValueText:super.value animated:animated];
    }
    
}

- (void) setValueText:(CGFloat)value animated:(BOOL)animated;
{
    animated = self.cancelsEvents ? NO : animated;
    self.label.highlighted = YES;

    NSNumber *n = [NSNumber numberWithInt:(int)value];
    [self.label setText:[NSString stringWithFormat:@"%@", n] animated:animated];

}
- (void) setEnabled:(BOOL)enabled;
{
    [super setEnabled:enabled];
    self.leftButton.enabled = enabled;
    self.rightButton.enabled = enabled;
    
}
- (void) setEmpty;
{
    [self resetValue];

    self.label.highlighted = NO;
    [self.label setText:@"0" animated:NO];
    

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

*/

@end

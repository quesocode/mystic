//
//  MysticColorButton.m
//  Mystic
//
//  Created by Travis A. Weerts on 3/29/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticColorButton.h"
#import "MysticImage.h"
#import "MysticController.h"
#import "MysticUtility.h"

@implementation MysticColorButtonColorView



@end
@interface MysticColorButton ()

@property(nonatomic, readonly) CGRect colorViewFrame;

@end
@implementation MysticColorButton

@synthesize color=_color, hideActiveColor=_hideActiveColor;

+ (instancetype) colorButton:(UIColor *)color title:(NSString *)title option:(id)option action:(MysticBlockColorButton)action;
{
    CGSize iconSize = (CGSize){25,25};
    MysticColorButton *btn = [[self class] buttonWithImage:[MysticImage image:@(MysticIconTypeToolColor) size:iconSize color:@(MysticColorTypeUnknown)]  senderAction:^(MysticColorButton *sender) {
        __unsafe_unretained __block MysticColorButton *_sender = sender;
        [[MysticController controller] showColorInput:sender.option title:sender.inputTitle color:sender.color finished:^(UIColor *newColor, id c2, CGPoint p, MysticThreshold t, int i, id obj2, BOOL success) {
            _sender.color = newColor;
            if(_sender.colorAction) _sender.colorAction(_sender, newColor, obj2, success);
        }];
    }];
    btn.iconSize = iconSize;
    btn.option = option;
    btn.colorAction = action;
    btn.inputTitle = title;
    btn.color = color;
    return btn;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self) [self commonInit];
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self) [self commonInit];
    return self;
}
- (void) commonInit;
{
    [super commonInit];
    _hideActiveColor = YES;
    self.contentMode = UIViewContentModeCenter;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.autoresizesSubviews=NO;
}
- (void) setColor:(UIColor *)color;
{
    if(_color) { [_color release],_color=nil; }
    if(color) _color = [color retain];
    if(!_color || self.hideActiveColor)
    {
        if(self.colorView) { [self.colorView removeFromSuperview]; self.colorView=nil; }
        return;
    }
    if(!self.colorView)
    {
        MysticColorButtonColorView *v = [[MysticColorButtonColorView alloc] initWithFrame:self.colorViewFrame];
        v.layer.cornerRadius = CGRectH(v.frame)/2;
        v.userInteractionEnabled = NO;
        self.colorView = [v autorelease];
        [self addSubview:self.colorView];
    }
    else self.colorView.frame = self.colorViewFrame;
    self.colorView.backgroundColor = [[color displayColor] alpha:1];
}
- (void) setDefaultColor:(UIColor *)defaultColor;
{
    if(_defaultColor) [_defaultColor release], _defaultColor=nil;
    if(defaultColor) _defaultColor = [defaultColor retain];
    if(_color) self.color = _color;
}
- (BOOL) hideActiveColor; { return _hideActiveColor || (!_color && !_defaultColor) || [_color isEqualToColor:_defaultColor]; }
- (void) setHideActiveColor:(BOOL)hideActiveColor;
{
    _hideActiveColor = hideActiveColor;
    if(hideActiveColor && self.colorView) { [self.colorView removeFromSuperview]; self.colorView=nil; }
    else if(!hideActiveColor && !self.colorView && _color) self.color = _color;
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.colorView.frame = self.colorViewFrame;
}
- (CGRect) colorViewFrame;
{
    CGFloat colorViewSize = 6;
    CGPoint c = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
    CGRect f;
    switch (self.contentMode) {
        case UIViewContentModeTopRight:
            f = (CGRect){c.x + (self.iconSize.width/2)+2, c.y - (self.iconSize.height/2) - 4, colorViewSize,colorViewSize}; break;
        case UIViewContentModeBottomRight:
            f = (CGRect){c.x + (self.iconSize.width/2), c.y + (self.iconSize.height/2) + 2, colorViewSize,colorViewSize}; break;
        case UIViewContentModeBottomLeft:
            f = (CGRect){c.x - (self.iconSize.width/2), c.y + (self.iconSize.height/2) + 2, colorViewSize,colorViewSize}; break;
        case UIViewContentModeTopLeft:
            f = (CGRect){c.x - (self.iconSize.width/2), c.y - (self.iconSize.height/2) - 2, colorViewSize,colorViewSize}; break;
        case UIViewContentModeCenter:
        default:  f = (CGRect){c.x -colorViewSize/2, c.y - colorViewSize/2, colorViewSize,colorViewSize}; break;
    }
    return f;
}
- (void) dealloc;
{
    [super dealloc];
    if(_colorView) [_colorView release],_colorView=nil;
    if(_defaultColor) [_defaultColor release];
    if(_color) [_color release];
    if(_colorAction) Block_release(_colorAction);
    [_inputTitle release];
    [_option release];
}

@end

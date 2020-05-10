//
//  MysticToggleButton.m
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticToggleButton.h"
#import "MysticIcon.h"
#import "MysticColor.h"
#import "MysticUI.h"
#import "MysticImageView.h"

@interface MysticToggleButton ()
{
    NSInteger __nextToggleState;
    SEL setImageAction;
}
@property (nonatomic, retain) MysticImageView *toggleImageView;
@property (nonatomic, retain) NSMutableDictionary  *colors;


@end
@implementation MysticToggleButton

@synthesize toggleState=_toggleState, maxToggleState=_maxToggleState, minToggleState=_minToggleState, allowLoop=_allowLoop, iconStyle=_iconStyle, iconImage=_iconImage, iconColorType=_iconColorType, toggleIndex=_toggleIndex, stopToggleState, onToggle=_onToggle, otherState =_otherState, defaultToggleState=_defaultToggleState, iconColor=_iconColor, iconSize=_iconSize, nextToggleState=_nextToggleState, startToggleState=_startToggleState;

- (void) dealloc;
{
    [_iconImage release];
    [_toggleIndex release];
    [_iconColor release];
    [_iconColorSelected release];
    [_iconColorHighlighted release];
    [_iconColorDisabled release];
    [_colors release];
    [_toggleImageView release];
    [_icons release];
    _onToggleAction = nil;
    _onToggleTarget = nil;
//    self.onToggle = nil;
    if(_onToggle)
    {
        Block_release(_onToggle);
        _onToggle = nil;
    }
    [super dealloc];
}
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
    [super commonInit];
    _maxToggleState = MysticToggleStateOn;
    _minToggleState = MysticToggleStateOff;
    _toggleState = MysticToggleStateOff;
    _defaultToggleState = _toggleState;
    _startToggleState = NSNotFound;
    __nextToggleState = NSNotFound;
    _hasToggled = NO;
    self.nextToggleState = NSNotFound;
    _animateImageDuration = 0;
    _otherState = NSIntegerMin;
    _allowLoop = YES;
    setImageAction = @selector(setImage:);
    _iconColorType = MysticColorTypeAuto;
    self.icons = [NSMutableDictionary dictionary];
    self.colors = [NSMutableDictionary dictionary];
    self.toggleImageView = [[[MysticImageView alloc] initWithFrame:self.bounds] autorelease];
    self.toggleImageView.userInteractionEnabled = NO;
    self.toggleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.toggleImageView.contentMode = self.contentMode;
    [self addSubview:self.toggleImageView];
}
- (void) setContentMode:(UIViewContentMode)contentMode;
{
    [super setContentMode:contentMode];
    self.toggleImageView.contentMode = contentMode;
}
- (NSInteger) defaultValue;
{
    return _defaultToggleState;
}
- (NSInteger) value;
{
    return self.toggleState;
}

- (void) setValue:(NSInteger)newValue;
{
    [self setToggleState:newValue];
}
- (void) setDefaultValue:(NSInteger)v;
{
    self.defaultToggleState = v;
}
- (MysticToggleState) runOnToggle;
{
    self.onToggle(self);
    if(self.onToggleAction && [self.onToggleTarget respondsToSelector:self.onToggleAction])
        [self.onToggleTarget performSelector:self.onToggleAction withObject:self];
    return self.toggleState;
}
- (BOOL) on;
{
    return self.toggleState != self.minToggleState;
}
- (void) setOnToggle:(MysticBlockSender)val;
{
    if(_onToggle) Block_release(_onToggle);
    _onToggle = Block_copy(val);
    [self handleControlEvent:UIControlEventTouchUpInside withBlockSender:^(MysticToggleButton *toggler){
        [toggler toggle];
    }];
}
- (void) finishedOnToggle;
{
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
- (void) setToggleIndex:(NSIndexSet *)val;
{
    _toggleIndex = [val retain];
    if(_toggleIndex && [_toggleIndex count])
    {
        self.minToggleState = [_toggleIndex firstIndex];
        self.maxToggleState = [_toggleIndex lastIndex]+1;
    }
    
}
- (void) setStopToggleState:(NSInteger)v
{
    self.maxToggleState = v-1;
}


- (MysticToggleState) toggle;
{
    MysticToggleState nToggleState = _toggleIndex ? [_toggleIndex indexGreaterThanIndex:_toggleState] : _toggleState+1;
    if(self.nextToggleState != NSNotFound)
    {
        nToggleState = self.nextToggleState;
        self.nextToggleState = NSNotFound;
    }
    else nToggleState = (NSInteger)nToggleState == NSNotFound ? _toggleState+1 : nToggleState;
    self.toggleState = nToggleState;
    return [self runOnToggle];
}
- (int) numberOfToggleStates;
{
    return (int)self.icons.count;
}
- (void) reset;
{
    [self setToggleState:_minToggleState];
}

- (void) setNextToggleState:(NSInteger)value;
{
    if(__nextToggleState == NSNotFound) __nextToggleState = value;
    _nextToggleState = value;
}
- (NSInteger) realStartToggleState;
{
    if(self.startToggleState != NSNotFound && __nextToggleState != NSNotFound)
        self.nextToggleState = __nextToggleState;
    return self.startToggleState != NSNotFound ? self.startToggleState : self.minToggleState;
}
- (void) setToggleStateAndTrigger:(MysticToggleState)toggleState;
{
    [self setToggleState:toggleState trigger:YES];
}
- (void) setToggleState:(MysticToggleState)toggleState;
{
    [self setToggleState:toggleState trigger:NO];
}
- (void) setToggleState:(MysticToggleState)toggleState trigger:(BOOL)trigger;
{
    MysticToggleState newState = toggleState;
    if(toggleState != self.otherState)
    {
        if(newState < _minToggleState) newState = _allowLoop ? _maxToggleState : _minToggleState;
        else if (newState > _maxToggleState) newState = _allowLoop ? [self realStartToggleState] : _maxToggleState;
    }
    if(newState != _toggleState || newState == self.otherState)
    {
        _previousToggleState = _toggleState;
        _toggleState = newState;
        if(!trigger) {
            [self setNeedsDisplay];
            [self setNeedsLayout];
        }
        else if(_previousToggleState != _toggleState) [self runOnToggle];
    }
}
- (void) setIconImage:(UIImage *)iconImage;
{
    [self setIconImage:iconImage forState:self.minToggleState];
    
    _iconStyle = MysticIconTypeImage;
}
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (UIColor *) colorWithType:(MysticColorType)type;
{
    MysticColorType newType = type;
    CGFloat alpha = 1;
    switch (newType){
        case MysticColorTypeBlack:
        case MysticColorTypeBackgroundBlack:
            newType = MysticColorTypeBackgroundBrown;
            break;
        case MysticColorTypeWhite:
        case MysticColorTypeBackgroundWhite:
            newType = MysticColorTypeBackgroundGray;
            alpha = 0.5;
            break;
            
        default: break;
    }
    return [[MysticColor colorWithType:newType] colorWithAlphaComponent:alpha];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect2:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.iconStyle) {
        case MysticIconTypeImage:
        {
            UIImage *img = [self iconForState:self.toggleState];
            CGContextTranslateCTM(context, 0, rect.size.height);
            CGContextScaleCTM(context, 1, -1);
            CGRect irect = CGRectWithContentMode(CGRectSize(img.size), rect, self.contentMode);
            CGContextDrawImage(context, irect, img.CGImage);
            break;
        }
        case MysticIconTypeImageMask:
        {

            MysticColorType tc = [self colorTypeForState:self.toggleState];
            if(tc == MysticColorTypeAuto && self.selectedColorType != MysticColorTypeUnknown)
            {
                tc = self.iconColorType;
            }
            MysticColorType toggleColor = tc == MysticColorTypeAuto ? self.iconColorType : tc;
            
            
            
            UIColor *color = [self colorWithType:toggleColor];
            
            UIImage *img = [self iconForState:self.toggleState];
            CGRect irect = CGRectMake(0, 0, img.size.width, img.size.height);
          

            [MysticImage draw:img color:color rect:irect bounds:rect context:context contentMode:self.contentMode];
            
            break;
        }
        case MysticIconTypeNone:
            break;
            
        default: break;
    }
    
}
- (void) setIconColorType:(MysticColorType)iconColorType forState:(NSInteger)state;
{
    [self.colors setObject:[NSNumber numberWithInteger:iconColorType] forKey:[NSNumber numberWithInteger:state]];
    if([self.colors count] > 1)
    {
        self.iconStyle = MysticIconTypeImageMask;
    }
//    if(state > self.maxToggleState) self.maxToggleState = state;
//    if(state < self.minToggleState) self.minToggleState = state;
}
- (MysticColorType) colorTypeForState:(NSInteger)state;
{
    if((self.selected || super.state == UIControlStateSelected) && self.selectedColorType != MysticColorTypeAuto)
    {
        return self.selectedColorType;
    }
    NSNumber *n = [self.colors objectForKey:[NSNumber numberWithInteger:state]];
    if(!n && (state-1) >= self.minToggleState)
    {
        int c = state-1 - self.minToggleState;
        int x = state-1;
        for (int i=0; i<c; i++) {
            x = x -i;
            n = [self.colors objectForKey:[NSNumber numberWithInteger:x]];
            if(n){  return [n integerValue]; }
        }
    }
    return n ? [n integerValue] : self.iconColorType;
}
- (void) setImage:(UIImage *)image forState:(UIControlState)state;
{
    [self setIconImage:image forState:state];
}
- (void) setIconImage:(id)iconImage forState:(NSInteger)state;
{
    if(iconImage) [self.icons setObject:iconImage forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *) imageForState:(NSInteger)astate;
{
    return nil;
}

- (UIImage *) iconForState:(NSInteger)state;
{
    UIImage *img = [self.icons objectForKey:[NSNumber numberWithInteger:state]];
    return img ? img : [self.icons objectForKey:[NSNumber numberWithInteger:self.minToggleState]];
}


- (void) setSelectedColorType:(MysticColorType)selectedColorType;
{
    [super setSelectedColorType:selectedColorType];
    if(super.selectedColorType != MysticColorTypeAuto) self.iconStyle = MysticIconTypeImageMask;
}

- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}


- (void) setMaxToggleState:(NSInteger)value;
{
    if(self.maxToggleState == value) return;
    _maxToggleState = value;
    [self updateIconImage];
}

- (void) setIconSize:(CGSize)value;
{
    if(CGSizeEqualToSize(value, self.iconSize)) return;
    _iconSize = value;
    [self updateIconImage];
}
- (void) setIconColor:(UIColor *)value;
{
    if(_iconColor) [_iconColor release], _iconColor=nil;
    _iconColor = value ? [value retain] : nil;
    [self updateIconImage];
}
- (void) updateIconImage;
{
    [self setNeedsLayout];
}
- (void) setAnimateImageDuration:(NSTimeInterval)animateImageDuration;
{
//    BOOL ch = _animateImageDuration != animateImageDuration;
    _animateImageDuration = animateImageDuration;
    self.animateToggleImages = animateImageDuration != 0;
}
- (void) setAnimateToggleImages:(BOOL)animateToggleImages;
{
//    BOOL ch = _animateToggleImages != animateToggleImages;
    _animateToggleImages = animateToggleImages;
    self.toggleImageView.animateImage = animateToggleImages;
    if(_animateToggleImages && _animateImageDuration == 0) _animateImageDuration = -1;
    self.toggleImageView.duration = _animateImageDuration;
    setImageAction = !animateToggleImages ? @selector(setImage:) : @selector(fadeToImage:);
//    if(ch) [self layoutSubviews];
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    self.toggleImageView.frame = self.bounds;
    if(!self.icons || self.icons.count == 0) return;
    UIImage *img = [self iconForState:self.toggleState];
    if(img && ![self.toggleImageView.image isEqual:img]) [self.toggleImageView performSelector:setImageAction withObject:img];
}
@end

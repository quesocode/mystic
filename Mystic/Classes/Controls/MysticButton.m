//
//  MysticButton.m
//  Mystic
//
//  Created by travis weerts on 3/7/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticButton.h"
#import "MysticColor.h"
#import "MysticUI.h"

@interface MysticButtonBlockCallingObject : NSObject
@property (copy, nonatomic) ActionBlock block;
@property (copy, nonatomic) MysticBlockSender senderBlock, holdBlock, doubleTapBlock;
@end

@implementation MysticButtonBlockCallingObject
@synthesize block = _block, senderBlock=_senderBlock, holdBlock=_holdBlock, doubleTapBlock=_doubleTapBlock;

- (void)dealloc {
    //    DLog(@"dealloc mystic button");
    //    Block_release(_block);
    //    Block_release(_holdBlock);
    //    Block_release(_senderBlock);
    self.block=nil;
    self.holdBlock=nil;
    self.senderBlock=nil;
    self.doubleTapBlock = nil;
    [super dealloc];
}

- (void)callblock  {
    self.block();
}

- (void)callSenderBlock:(id)sender  {
    self.senderBlock(sender);
}

- (void)callHoldBlock:(id)sender  {
    self.holdBlock(sender);
}
- (void)callDoubleTapBlock:(id)sender  {
    self.doubleTapBlock(sender);
}
@end

@interface MysticButton ()
{
    BOOL removedUserActionTarget;
}
@property (nonatomic, retain) MysticButtonBlockCallingObject *blockObject, *senderBlockObject, *holdBlockObject, *doubleTapBlockObject;
@property (nonatomic, assign) BOOL holdingDown, stopHoldingAction, ranHoldingDownOnce, userCausedActionSet;
@property (nonatomic, assign) SEL holdingAction, holdingTargetAction, holdingTouchUpAction, holdingTargetDownAction, holdingEndedAction;
@property (nonatomic, assign) id holdingTarget, holdingTouchUpTarget, holdingTargetDown, holdingEndedTarget;
@property (nonatomic, retain) NSTimer *holdingTimer, *holdingDelayTimer;
@end

@implementation MysticButton

@synthesize holdBlockObject=_holdBlockObject, senderBlockObject=_senderBlockObject, blockObject=_blockObject, doubleTapBlockObject=_doubleTapBlockObject, selectedColorType=_selectedColorType, selectedBackgroundColor=_selectedBackgroundColor, normalBackgroundColor=_normalBackgroundColor, canSelect=_canSelect, buttonPosition=_buttonPosition, hitInsets=_hitInsets, toolType=_toolType, continueOnHold=_continueOnHold, holdingInterval=_holdingInterval, stopHoldingAction=_stopHoldingAction, holdingDelay=_holdingDelay, touchUpCancelsDown=_touchUpCancelsDown;

-(void) dealloc{
    [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_borderControlStates release];
    [_senderBlockObject release];
    [_normalBackgroundColor release];
    [_selectedBackgroundColor release];
    [_holdBlockObject release];
    [_blockObject release];
    [_doubleTapBlockObject release];
    [_buttonWidthStates release];
    [_touchTarget release];
    _touchAction = nil;
    _holdingTarget=nil;
    if(_stateBlock) Block_release(_stateBlock);
    _touchEvents = UIControlEventApplicationReserved;
    [super dealloc];
}


- (id) init;
{
    self = [super init];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
    removedUserActionTarget = NO;
    _ignoreUserActions = YES;
    _userCausedActionSet = NO;
    _resetsUserAction = YES;
    _userSelected = NO;
    _userCausedAction = NO;
    _touchUpCancelsDown = NO;
    _selectedColorType = MysticColorTypeUnknown;
    _canSelect = YES;
    _stopHoldingAction = NO;
    _hitInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _toolType = MysticToolTypeUnknown;
    _holdingInterval = 1/15;
    _holdingDelay = 0.2f;
    _positionOffset = CGPointZero;
    if(_borderControlStates)
    {
        [_borderControlStates release];
    }
    _borderControlStates = [[NSMutableDictionary alloc] init];
    if(_buttonWidthStates)
    {
        [_buttonWidthStates release];
    }
    _buttonWidthStates = [[NSMutableDictionary alloc] init];

    _padding = 10;

}
- (void) setImageAlignment:(MysticAlignPosition)imageAlignment;
{
    switch (imageAlignment) {
        case MysticAlignPositionLeft:
            self.transform = CGAffineTransformIdentity;
            self.titleLabel.transform = CGAffineTransformIdentity;
            self.imageView.transform = CGAffineTransformIdentity;
            break;
        case MysticAlignPositionRight:
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            break;
        default:
            break;
    }
}
- (void) setHitInsets:(UIEdgeInsets)hitInsets;
{
    UIEdgeInsets insets = hitInsets;
    insets.top = -1*hitInsets.top;
    insets.bottom = -1*hitInsets.bottom;
    insets.left = -1*hitInsets.left;
    insets.right = -1*hitInsets.right;
    _hitInsets = insets;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, _hitInsets);
    return CGRectContainsPoint(bounds, point);
}

+ (id)buttonWithType:(UIButtonType)buttonType;
{
    MysticButton *button = (MysticButton *)[super buttonWithType:buttonType];
    [button commonInit];
    button.canSelect = YES;
    button.selectedColorType = MysticColorTypeUnknown;
    return button;
    
    
}

- (void) setContinueOnHold:(BOOL)continuousPress;
{
    if(!_continueOnHold && continuousPress)
    {
        _continueOnHold = continuousPress;
        self.holdingAction = nil;
        self.holdingDown = NO;
    
    }
    _continueOnHold = continuousPress;

    if(!continuousPress)
    {
        [self removeTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
}
- (void) removeFromSuperview;
{
    if(self.touchTarget)
    {
        [self removeTarget:self.touchTarget action:self.touchAction forControlEvents:self.touchEvents];
    }
    if(self.holdingTarget)
    {
        [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self removeTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchUpInside];
        self.holdingTarget = nil;
        self.holdingTargetAction = nil;
    }
    if(self.holdingEndedTarget)
    {
        self.holdingEndedTarget = nil;
        self.holdingEndedAction = nil;
    }
    if(self.holdingTouchUpTarget)
    {
        self.holdingTouchUpTarget = nil;
        self.holdingTouchUpAction = nil;
    }
    if(self.holdingTargetDown)
    {
        self.holdingTargetDown = nil;
        self.holdingTargetDownAction = nil;
    }
    [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];

//    for (id target in self.allTargets) {
//        [self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
//    }
    [super removeFromSuperview];
}
- (void) removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    [super removeTarget:target action:action forControlEvents:controlEvents];
    if([target isEqual:self.touchTarget])
    {
        self.touchTarget = nil;
    }
}
- (void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    if(self.continueOnHold)
    {
        if(controlEvents & UIControlEventTouchDown)
        {
            self.holdingTargetDownAction = action;
            self.holdingTargetDown = target;
            
            if(!self.holdingTarget)
            {
                self.holdingTargetAction = action;
                self.holdingTarget = target;
                [self removeTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchDown];
                [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
                
                [super addTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [super addTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
                [super addTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchDown];
            }
            
            return;
        }
        if(controlEvents & UIControlEventEditingDidEnd)
        {
            self.holdingEndedAction = action;
            self.holdingEndedTarget = target;
            
            
            
            return;
        }
        if(controlEvents & UIControlEventTouchDownRepeat)
        {
            self.holdingTargetAction = action;
            self.holdingTarget = target;
            [self removeTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchDown];
            [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
            [self removeTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
            
            [super addTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpInside];
            [super addTarget:self action:@selector(continuousTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
            [super addTarget:self action:@selector(continuousTouchDown:) forControlEvents:UIControlEventTouchDown];
            return;
        }
        if(controlEvents & UIControlEventTouchUpInside || controlEvents & UIControlEventTouchUpOutside)
        {
            self.touchUpCancelsDown = YES;
            self.holdingTouchUpAction = action;
            self.holdingTouchUpTarget = target;
            return;
        }
    }
    

    
    
    if(!self.touchTarget && ![self isKindOfClass:[MysticBarButton class]])
    {
        self.touchAction = action;
        self.touchTarget = target;
        self.touchEvents = controlEvents;
    
        [super addTarget:self action:@selector(defaultAction:) forControlEvents:controlEvents];
    }
    else
    {
        [super addTarget:target action:action forControlEvents:controlEvents];
        
        if(self.touchTarget && self.touchEvents != controlEvents && !removedUserActionTarget)
        {
            removedUserActionTarget = YES;
            [super removeTarget:self action:@selector(defaultAction:) forControlEvents:self.touchEvents];
            [super addTarget:self.touchTarget action:self.touchAction forControlEvents:self.touchEvents];
        }
    }
    
    
    
}
- (void) run;
{
    [self defaultAction:self];
}
- (void) defaultAction:(id)sender;
{
    
    if(self.touchTarget)
    {
        self.userCausedActionSet = YES;
        [self.touchTarget performSelector:self.touchAction withObject:sender];
    }
}
- (void) continuousTouchDown:(id)sender;
{
    self.holdingDelayTimer = [NSTimer scheduledTimerWithTimeInterval:self.holdingDelay target:self selector:@selector(continuousTouchDownAfterDelay) userInfo:nil repeats:NO];
    if(!self.touchUpCancelsDown) [self runHoldingDownSingleAction];
    
}
- (void) continuousTouchDownAfterDelay;
{
    if(self.holdingDelayTimer)
    {
        [self.holdingDelayTimer invalidate];
        self.holdingDelayTimer = nil;
    }
    self.holdingAction = @selector(runHoldingAction);
    self.holdingDown = YES;
}


- (void) runHoldingDownSingleAction;
{
    if(self.holdingTargetDown && self.holdingTargetDownAction && !self.ranHoldingDownOnce)
    {
        [self.holdingTargetDown performSelector:self.holdingTargetDownAction withObject:self];
        self.ranHoldingDownOnce = YES;

    }


}
- (void) runHoldingAction;
{
    if(self.holdingDown && self.holdingTarget && self.holdingTargetAction && self.highlighted)
    {
        [self.holdingTarget performSelector:self.holdingTargetAction withObject:self];
    }
    else
    {
        self.holdingDown = NO;
    }
}

- (void) continuousTouchUp:(id)sender;
{
    self.userCausedActionSet = YES;
    
    if(self.holdingDelayTimer)
    {
        [self.holdingDelayTimer invalidate];
        self.holdingDelayTimer = nil;
        if(self.holdingTouchUpTarget)
        {
            [self.holdingTouchUpTarget performSelector:self.holdingTouchUpAction withObject:self];
        }
        
    }
    
    
    
    self.ranHoldingDownOnce = NO;
    self.stopHoldingAction = YES;
    self.holdingDown = NO;
    if(self.holdingEndedTarget)
    {
        [self.holdingEndedTarget performSelector:self.holdingEndedAction withObject:self];
    }
    
    
}

- (void) setHoldingInterval:(NSTimeInterval)holdingInterval;
{
    _holdingInterval = holdingInterval;
    if(_holdingInterval <= 0)
    {
        self.holdingDown = NO;
        self.continueOnHold = NO;
    }
    else
    {
        self.continueOnHold = YES;
    }
}
- (BOOL) hasUserCausedAction;
{
    return self.userCausedAction;
}
- (void) setHoldingDown:(BOOL)value
{
//    if(value==_holdingDown) return;
    _holdingDown = value;
    if(self.holdingTimer)
    {
        [self.holdingTimer invalidate];
        self.holdingTimer = nil;
    }
    if(_holdingDown)
    {
        self.holdingTimer = [NSTimer scheduledTimerWithTimeInterval:self.holdingInterval target:self selector:self.holdingAction userInfo:nil repeats:YES];
        
    }
    else
    {
        self.holdingAction=nil;
    }
}


- (void) setSelected:(BOOL)selected;
{
    [self setSelected:selected resetUser:self.resetsUserAction];
}
- (void) setSelected:(BOOL)selected resetUser:(BOOL)shouldResetUser;
{
    [super setSelected:selected];
    if(selected && self.selectedBackgroundColor)
        self.backgroundColor = self.selectedBackgroundColor;
    else if(!selected && self.selectedBackgroundColor)
        self.backgroundColor = self.normalBackgroundColor;

    if(selected && !self.highlighted && self.borderControlStates[@(UIControlStateSelected)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateSelected)] CGColor];
    else if(!selected && !self.highlighted && self.borderControlStates[@(UIControlStateNormal)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateNormal)] CGColor];
    else if(self.highlighted && self.borderControlStates[@(UIControlStateHighlighted)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateHighlighted)] CGColor];
    
    CGFloat newWidth = MYSTIC_FLOAT_UNKNOWN;
    if(selected && !self.highlighted && self.enabled && self.buttonWidthStates[@(UIControlStateSelected)])
        newWidth = [self.buttonWidthStates[@(UIControlStateSelected)] floatValue];
    else if(!selected && !self.highlighted && self.enabled && self.buttonWidthStates[@(UIControlStateNormal)])
        newWidth = [self.buttonWidthStates[@(UIControlStateNormal)] floatValue];
    else if(self.highlighted && self.enabled && self.buttonWidthStates[@(UIControlStateHighlighted)])
        newWidth = [self.buttonWidthStates[@(UIControlStateHighlighted)] floatValue];
    else if(!self.enabled && self.buttonWidthStates[@(UIControlStateDisabled)])
        newWidth = [self.buttonWidthStates[@(UIControlStateDisabled)] floatValue];
    if(newWidth != MYSTIC_FLOAT_UNKNOWN) self.bounds = CGRectWidth(self.bounds, newWidth);
    
    
    
    if(shouldResetUser)
    {
        self.userCausedAction = self.userCausedActionSet;
        if(self.userCausedAction) self.userSelected = selected;
    }
    
    self.userCausedActionSet = NO;
    if(self.stateBlock) self.stateBlock(self);
}

- (void) setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    if(self.stateBlock) self.stateBlock(self);
    if(highlighted && self.borderControlStates[@(UIControlStateHighlighted)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateHighlighted)] CGColor];
    else if(!highlighted && self.selected && self.borderControlStates[@(UIControlStateSelected)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateSelected)] CGColor];
    else if(self.borderControlStates[@(UIControlStateNormal)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateNormal)] CGColor];
    
    CGFloat newWidth = MYSTIC_FLOAT_UNKNOWN;
    if(highlighted && self.buttonWidthStates[@(UIControlStateHighlighted)])
        newWidth = [self.buttonWidthStates[@(UIControlStateHighlighted)] floatValue];
    else if(!highlighted && self.selected && self.buttonWidthStates[@(UIControlStateSelected)])
        newWidth = [self.buttonWidthStates[@(UIControlStateSelected)] floatValue];
    else if(!highlighted && !self.enabled && self.buttonWidthStates[@(UIControlStateDisabled)])
        newWidth = [self.buttonWidthStates[@(UIControlStateDisabled)] floatValue];
    else if(self.borderControlStates[@(UIControlStateNormal)])
        newWidth = [self.buttonWidthStates[@(UIControlStateNormal)] floatValue];
    if(newWidth != MYSTIC_FLOAT_UNKNOWN) self.frameAndCenter = CGRectWidth(self.bounds, newWidth);



}
- (void) setEnabled:(BOOL)enabled;
{
    [super setEnabled:enabled];
    
    if(enabled && !self.selected && self.borderControlStates[@(UIControlStateNormal)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateNormal)] CGColor];
    else if(!enabled && !self.selected && self.borderControlStates[@(UIControlStateDisabled)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateDisabled)] CGColor];
    else if(self.selected && self.borderControlStates[@(UIControlStateSelected)])
        self.layer.borderColor = [(UIColor *)self.borderControlStates[@(UIControlStateSelected)] CGColor];
    
    CGFloat newWidth = MYSTIC_FLOAT_UNKNOWN;
    if(enabled && !self.selected && self.buttonWidthStates[@(UIControlStateNormal)])
        newWidth = [self.buttonWidthStates[@(UIControlStateNormal)] floatValue];
    else if(!enabled && !self.selected && self.buttonWidthStates[@(UIControlStateDisabled)])
        newWidth = [self.buttonWidthStates[@(UIControlStateDisabled)] floatValue];
    else if(self.selected && self.buttonWidthStates[@(UIControlStateSelected)])
        newWidth = [self.buttonWidthStates[@(UIControlStateSelected)] floatValue];
    
    if(newWidth != MYSTIC_FLOAT_UNKNOWN) self.frameAndCenter = CGRectWidth(self.bounds, newWidth);

    
    if(self.stateBlock) self.stateBlock(self);
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    if(!self.normalBackgroundColor && (!self.selected || !self.selectedBackgroundColor))
    {
        self.normalBackgroundColor = backgroundColor;
    }
}
- (UIColor *) textColor;
{
    return [self titleColorForState:self.state];
}
- (void) setTextColor:(UIColor *)textColor;
{
    [self setTitleColor:textColor forState:UIControlStateNormal];

}

- (NSTextAlignment) textAlignment;
{
    return self.titleLabel.textAlignment;
}
- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
    self.titleLabel.textAlignment = textAlignment;
}
- (UIFont *) font;
{
    return self.titleLabel.font;
}
- (void) setFont:(UIFont *)font;
{
    [self.titleLabel setFont:font];
}
- (id) handleControlEvent:(UIControlEvents)event
                               withBlock:(ActionBlock) action
{
    
    
    if(!action)
    {
        self.blockObject=nil;
        [self removeTarget:self action:NULL forControlEvents:event];
        return self;
    }
    MysticButtonBlockCallingObject *obj = [[MysticButtonBlockCallingObject alloc] init];
    obj.block = action;
    self.blockObject = obj;
    [obj release];
    
    Block_release(action);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
    return self;
}

- (id) handleControlEvent:(UIControlEvents)event
                         withBlockSender:(MysticBlockSender) action
{
    if(!action)
    {
        self.senderBlockObject=nil;
        [self removeTarget:self action:@selector(callActionSenderBlock:) forControlEvents:event];
        return self;
    }
    
    MysticButtonBlockCallingObject *obj = [[MysticButtonBlockCallingObject alloc] init];
    obj.senderBlock = action;
    self.senderBlockObject = obj;
    [obj release];
    [self addTarget:self action:@selector(callActionSenderBlock:) forControlEvents:event];
    return self;
}

- (id) handleDoubleTapEvent:(MysticBlockSender) action;
{
    if(!action)
    {
        self.gestureRecognizers = nil;
        return self;
    }
    
    MysticButtonBlockCallingObject *obj = [[MysticButtonBlockCallingObject alloc] init];
    obj.doubleTapBlock = action;
    self.doubleTapBlockObject = obj;
    [obj release];
    Block_release(action);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callDoubleTapBlock:)];
    gesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:gesture];
    [gesture release];
    return self;
}
- (id) handleTouchAndHoldForDuration:(NSTimeInterval)duration action:(MysticBlockSender)action;
{
    if(!action)
    {
        self.gestureRecognizers = nil;
        return self;
    }
    
    MysticButtonBlockCallingObject *obj = [[MysticButtonBlockCallingObject alloc] init];
    obj.holdBlock = action;
    self.holdBlockObject = obj;
    [obj release];
    
    
    Block_release(action);
    UILongPressGestureRecognizer *longPress_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callHoldActionSenderBlock:)];
    [longPress_gr setMinimumPressDuration:duration]; // triggers the action after 2 seconds of press
    [self addGestureRecognizer:longPress_gr];
    [longPress_gr release];
    return self;
}

-(void) callHoldActionSenderBlock:(id)sender{
    [self.holdBlockObject callHoldBlock:self];
}

-(void) callActionSenderBlock:(id)sender{
    [self.senderBlockObject callSenderBlock:self];
}

- (void) tap;
{
    if(self.senderBlockObject) [self callActionSenderBlock:self];
    if(self.blockObject) [self callActionBlock:nil];
    if(self.allTargets.count) [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void) callActionBlock:(id)sender{
    [self.blockObject callblock];
}

-(void) callDoubleTapBlock:(id)sender{
    [self.doubleTapBlockObject callDoubleTapBlock:self];
}

- (void) setBackgroundColor:(id)backgroundColor forState:(UIControlState)forState;
{
    if(!backgroundColor) return;
    
    MysticImage *bgImg = (MysticImage *)[self backgroundImageForState:forState];
    if(bgImg && [bgImg isKindOfClass:[MysticImage class]] && bgImg.tag && [bgImg.tag isEqualToString:ColorToString([MysticColor color:backgroundColor])])
    {
        return;
    }
    
    
    bgImg = [MysticImage backgroundImageWithColor:backgroundColor];
    if(bgImg) { [self setBackgroundImage:bgImg forState:forState]; }
}
- (void) setStateBlock:(MysticBlockButton)stateBlock;
{
    if(_stateBlock) Block_release(_stateBlock),_stateBlock=nil;
    if(stateBlock) _stateBlock=Block_copy(stateBlock);
    if(_stateBlock) _stateBlock(self);
}
- (void) setBorderColor:(id)borderColor forState:(UIControlState)forState;
{
    id key = @(forState);
    [self.borderControlStates setObject:borderColor forKey:key];
    UIColor *b = nil;
    if(forState == UIControlStateNormal && !self.selected && !self.highlighted) b = borderColor;
    else if(forState == UIControlStateHighlighted && self.highlighted) b = borderColor;
    else if(forState == UIControlStateSelected && self.selected) b = borderColor;
    else if(forState == UIControlStateDisabled && !self.enabled) b = borderColor;
    if(!b) return;
    self.layer.borderWidth = MAX(self.layer.borderWidth,1);
    self.layer.borderColor = b.CGColor;
}
- (void) setWidth:(CGFloat)width forState:(UIControlState)forState;
{
    id key = @(forState);
    [self.buttonWidthStates setObject:@(width) forKey:key];
    NSNumber *b = nil;
    if(forState == UIControlStateNormal && !self.selected && !self.highlighted) b = @(width);
    else if(forState == UIControlStateHighlighted && self.highlighted) b = @(width);
    else if(forState == UIControlStateSelected && self.selected) b = @(width);
    else if(forState == UIControlStateDisabled && !self.enabled) b = @(width);
    if(!b) return;
    CGRect newBounds = self.bounds;
    newBounds.size.width = b.floatValue;
    self.bounds = newBounds;
}
- (void) sendActionsForControlEvents:(UIControlEvents)controlEvents;
{
    if(self.cancelsEvents) return;
    [super sendActionsForControlEvents:controlEvents];
}
- (void) clear;
{
    self.senderBlockObject=nil;
    self.holdBlockObject=nil;
    self.blockObject=nil;
    self.doubleTapBlockObject=nil;
}
#pragma mark - Class Methods



+ (instancetype)backButton:(MysticBlockSender)action;
{
    MysticImage *img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img action:action];
    [button setImage:imgHighlighted forState:UIControlStateHighlighted];
//    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    button.frame = CGRectMake(0, 0, 50, button.frame.size.height);
    return button;
}
+ (instancetype) forwardButton:(MysticBlockSender)action;
{
    MysticImage *img = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img action:action];
    [button setImage:imgHighlighted forState:UIControlStateHighlighted];
//    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    button.frame = CGRectMake(0, 0, 50, button.frame.size.height);
    return button;
}


+ (instancetype) backButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    // back button
    MysticButton *backButton = [[self class] buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 33);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    
    UIImage *backNormal = [UIImage imageNamed:@"button-back-bg.png"];
    if([backNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    UIImage *backHighlighted = [UIImage imageNamed:@"button-back-bg-highlighted.png"];
    if([backHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    
    [backButton setBackgroundImage:backNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backHighlighted forState:UIControlStateHighlighted];
    if(image) [backButton setImage:image forState:UIControlStateNormal];
    if(target) [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

+ (instancetype) backButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    // back button
    MysticButton *backButton = [[self class] buttonWithType:UIButtonTypeCustom];
    title = NSLocalizedString(title, nil);

    /*
     
     UIImage *backNormal = [UIImage imageNamed:@"button-back-bg.png"];
     if([backNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
     {
     backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
     }
     else
     {
     backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
     }
     UIImage *backHighlighted = [UIImage imageNamed:@"button-back-bg-highlighted.png"];
     if([backHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
     {
     backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
     }
     else
     {
     backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
     }
     
     [backButton setBackgroundImage:backNormal forState:UIControlStateNormal];
     [backButton setBackgroundImage:backHighlighted forState:UIControlStateHighlighted];
     
     */
    
    MysticImage *img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_BACK, MYSTIC_NAVBAR_ICON_HEIGHT_BACK) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_BACK, MYSTIC_NAVBAR_ICON_HEIGHT_BACK) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    
    [backButton setImage:imgHighlighted forState:UIControlStateNormal];
    [backButton setImage:img forState:UIControlStateHighlighted];
    
    CGSize imgSize = img.size;
    
    if(target) [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setTitleColor:[UIColor mysticPinkColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor mysticChocolateColor] forState:UIControlStateHighlighted];
    backButton.titleLabel.font = [MysticUI gotham:15];
    CGSize size = CGSizeMake(MAX(50.0f, imgSize.width), 33.0f);
    if(title) size = [title sizeWithFont:backButton.titleLabel.font];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 12, 0, 0);
    backButton.frame = CGRectMake(0, 0, size.width + imgSize.width + insets.left, 33.0f);
    [backButton setTitleEdgeInsets:insets];
    if(title) [backButton setTitle:title forState:UIControlStateNormal];
    
    
    return backButton;
}



+ (instancetype) confirmButton:(MysticBlockSender) action;
{
    MysticImage *img = [MysticImage image:@(MysticIconTypeConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM) color:[UIColor color:MysticColorTypeNavBarIconConfirm]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM) color:[UIColor color:MysticColorTypeNavBarIconConfirmHighlighted]];
    
    MysticButton *btn = [[self class] clearButtonWithImage:img senderAction:action];
    [btn setImage:imgHighlighted forState:UIControlStateHighlighted];
    
    
    CGRect f = btn.frame;
    f.size.width = 41.0f;
    btn.frame = f;
    return btn;
}
+ (instancetype) cancelButton:(MysticBlockSender) action;
{
    
    MysticImage *img = [MysticImage image:@(MysticIconTypeCancel) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL) color:[UIColor color:MysticColorTypeNavBarIconCancel]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeCancel) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL) color:[UIColor color:MysticColorTypeNavBarIconCancelHighlighted]];
    
    
    MysticButton *btn = [[self class] clearButtonWithImage:img senderAction:action];
    [btn setImage:imgHighlighted forState:UIControlStateHighlighted];
    return btn;
}

+ (instancetype) cancelButtonWithTarget:(id)target sel:(SEL)action;
{
    
    MysticImage *img = [MysticImage image:@(MysticIconTypeCancel) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL) color:[UIColor color:MysticColorTypeNavBarIconCancel]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeCancel) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL) color:[UIColor color:MysticColorTypeNavBarIconCancelHighlighted]];
    
    
    MysticButton *btn = [[self class] clearButtonWithImage:img target:target sel:action];
    [btn setImage:imgHighlighted forState:UIControlStateHighlighted];
    return btn;
}
+ (instancetype) buttonWithImage:(UIImage *)image action:(ActionBlock)action;
{
    MysticButton *btn = [[self class] buttonWithImage:image target:nil sel:nil];
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    return btn;
}

+ (instancetype) buttonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
{
    MysticButton *btn = [[self class] buttonWithImage:image target:nil sel:nil];
    
    [btn handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    return btn;
}





+ (UIImage *) buttonBgImageNamed:(NSString *)imageName;
{
    UIImage *btnImg = [UIImage imageNamed:imageName];
    if([btnImg respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        btnImg = [btnImg resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        btnImg = [btnImg resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,16, 19)];
    }
    return btnImg;
}

+ (instancetype) button:(id)titleOrImg target:(id)target sel:(SEL)action;
{
    if([titleOrImg isKindOfClass:[NSAttributedString class]])
    {
        MysticButton *b = [[self class] buttonWithAttrStr:(id)titleOrImg senderAction:nil];
        [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        return b;
    }
    if([titleOrImg isKindOfClass:[NSString class]]) return [[self class] buttonWithTitle:titleOrImg target:target sel:action];
    return [[self class] buttonWithImage:titleOrImg target:target sel:action];
}
+ (instancetype) button:(id)titleOrImg action:(MysticBlockSender)action;
{
    if([titleOrImg isKindOfClass:[NSAttributedString class]] || [titleOrImg isKindOfClass:[MysticAttrString class]]) return [[self class] buttonWithAttrStr:(id)titleOrImg senderAction:action];

    if([titleOrImg isKindOfClass:[NSString class]]) return [[self class] buttonWithTitle:titleOrImg senderAction:action];
    return [[self class] buttonWithImage:titleOrImg senderAction:action];
}


+ (instancetype) forwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    // forward button
    MysticButton *forwardButton = [[self class] buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 50, 33);
    
    UIImage *forwardNormal = [UIImage imageNamed:@"button-forward-bg.png"];
    //UIImage *forwardNormal = hasChanges ? [UIImage imageNamed:@"button-forward-blue-bg.png"] : [UIImage imageNamed:@"button-forward-bg.png"];
    if([forwardNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    UIImage *forwardHighlighted = [UIImage imageNamed:@"button-forward-bg-highlighted.png"];
    if([forwardHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    [forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
    [forwardButton setBackgroundImage:forwardNormal forState:UIControlStateNormal];
    [forwardButton setBackgroundImage:forwardHighlighted forState:UIControlStateHighlighted];
    if(image) [forwardButton setImage:image forState:UIControlStateNormal];
    if(target) [forwardButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return forwardButton;
}

+ (instancetype) blueForwardButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    // forward button
    MysticButton *forwardButton = [[self class] buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 50, 33);
    
    UIImage *forwardNormal = [UIImage imageNamed:@"button-forward-blue-bg.png"];
    if([forwardNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        forwardNormal = [forwardNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    UIImage *forwardHighlighted = [UIImage imageNamed:@"button-forward-blue-bg-highlighted.png"];
    if([forwardHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 14) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        forwardHighlighted = [forwardHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15, 19, 16, 26)];
    }
    [forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
    [forwardButton setBackgroundImage:forwardNormal forState:UIControlStateNormal];
    [forwardButton setBackgroundImage:forwardHighlighted forState:UIControlStateHighlighted];
    if(image) [forwardButton setImage:image forState:UIControlStateNormal];
    if(target) [forwardButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return forwardButton;
}

+ (instancetype) forwardButtonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    MysticButton *forwardButton = [[self class] buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(0, 0, 60, 33);
    
    [forwardButton setImage:[UIImage imageNamed:@"forward-arrow.png"] forState:UIControlStateNormal];
    [forwardButton setImage:[UIImage imageNamed:@"forward-arrow-highlighted.png"] forState:UIControlStateHighlighted];
    
    if(target) [forwardButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [forwardButton setTitleColor:[UIColor mysticDarkChocolateColor] forState:UIControlStateNormal];
    [forwardButton setTitleColor:[UIColor mysticPinkColor] forState:UIControlStateHighlighted];
    forwardButton.titleLabel.font = [MysticUI gothamBold:14];
    CGSize size = CGSizeMake(50.0f, 33.0f);
    if(title)
    {
        size = [title sizeWithFont:forwardButton.titleLabel.font];
    }
    forwardButton.frame = CGRectMake(0, 0, size.width + 33, 33.0f);
    
    [forwardButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -9, 0, 30)];
    [forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, forwardButton.frame.size.width-30, 0, 0)];
    
    if(title)
    {
        [forwardButton setTitle:title forState:UIControlStateNormal];
    }
    
    return forwardButton;
}



+ (void) resizeButton:(MysticButton *)button;
{
    CGRect bFrame = button.frame;
    CGSize size = bFrame.size;
    NSString *title = [button titleForState:UIControlStateNormal];
    if(title)
    {
        size = [title sizeWithFont:button.titleLabel.font];
    }
    bFrame.size.width = size.width + (button.padding*2);
    bFrame.size.height = MAX(size.height, bFrame.size.height);
    button.frame = bFrame;
}

+ (instancetype) confirmButtonWithTarget:(id)target sel:(SEL)action;
{
    
    MysticButton *btn = [[self class] buttonWithImage:[MysticImage image:@(MysticIconTypeConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]] target:target sel:action];
    CGRect f = btn.frame;
    f.size.width = 48.0f;
    btn.frame = f;
    return btn;
}

//+ (instancetype) cancelButtonWithTarget:(id)target sel:(SEL)action;
//{
//    MysticButton *btn = [[self class] buttonWithImage:[UIImage imageNamed:@"cancel-button.png"] target:target sel:action];
//    CGRect f = btn.frame;
//    f.size.width = 48.0f;
//    btn.frame = f;
//    return btn;
//}

+ (instancetype) blueButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    UIImage *cancelNormal = [UIImage imageNamed:@"button-blue-bg.png"];
    if([cancelNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    }
    UIImage *cancelHighlighted = [UIImage imageNamed:@"button-blue-bg-highlighted.png"];
    if([cancelHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    }
    
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(0, 0, 48.0f, [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [confirmButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:cancelHighlighted forState:UIControlStateHighlighted];
    if(image) [confirmButton setImage:image forState:UIControlStateNormal];
    if(target) [confirmButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return confirmButton;
}

+ (instancetype) buttonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    //    UIImage *cancelNormal = [UIImage imageNamed:@"button-bg.png"];
    //    if([cancelNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    //    {
    //        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    //    }
    //    else
    //    {
    //        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    //    }
    //    UIImage *cancelHighlighted = [UIImage imageNamed:@"button-bg-highlighted.png"];
    //    if([cancelHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    //    {
    //        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    //    }
    //    else
    //    {
    //        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    //    }
    
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    CGRect bFrame = CGRectMake(0, 0, 52.0f, [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [confirmButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    //    [confirmButton setBackgroundImage:cancelHighlighted forState:UIControlStateHighlighted];
    if(image)
    {
        [confirmButton setImage:image forState:UIControlStateNormal];
        bFrame.size.width = image.size.width + 4;
//        bFrame.size.height = MAX(bFrame.size.height, image.size.height);
    }
    if(target) [confirmButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = bFrame;
    return confirmButton;
}

+ (instancetype) whiteButtonWithTitle:(NSString *)title action:(ActionBlock)action;
{
    UIImage *cancelNormal = [UIImage imageNamed:@"button-white-bg.png"];
    if([cancelNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        cancelNormal = [cancelNormal resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    }
    UIImage *cancelHighlighted = [UIImage imageNamed:@"button-white-bg-highlighted.png"];
    if([cancelHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(6,6,6, 6) resizingMode:UIImageResizingModeStretch];
    }
    else
    {
        cancelHighlighted = [cancelHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(15,19,15, 19)];
    }
    
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitleColor:[UIColor mysticTitleDarkColor] forState:UIControlStateNormal];
    [confirmButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [confirmButton setTitleShadowColor:[UIColor mysticReallyLightGrayColor] forState:UIControlStateHighlighted];
    confirmButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    confirmButton.titleLabel.font = [MysticUI gotham:11];
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    if(title)
    {
        size = [title sizeWithFont:confirmButton.titleLabel.font];
    }
    confirmButton.frame = CGRectMake(0, 0, size.width + (confirmButton.padding*2), [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [confirmButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:cancelHighlighted forState:UIControlStateHighlighted];
    
    if(title) [confirmButton setTitle:title forState:UIControlStateNormal];
    if(action) [confirmButton handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    return confirmButton;
}
+ (instancetype) buttonWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    title = NSLocalizedString(title, nil);
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    confirmButton.titleLabel.font = [MysticUI gotham:16];
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    [confirmButton setTitleColor:[UIColor mysticPinkColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor mysticChocolateColor] forState:UIControlStateHighlighted];
    [confirmButton setTitleColor:[UIColor mysticWhiteBackgroundColor] forState:UIControlStateSelected];
    [confirmButton commonInit];
    if(title) size = [title sizeWithFont:confirmButton.titleLabel.font];
    confirmButton.frame = CGRectMake(0, 0, size.width + (confirmButton.padding*2), [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    if(title) [confirmButton setTitle:title forState:UIControlStateNormal];
    if(target) [confirmButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return confirmButton;
}
+ (CGFloat) buttonHeight; { return 36; }

+ (instancetype) buttonWithAttrStr:(NSAttributedString *)title senderAction:(MysticBlockSender)action;
{
    title = [title isKindOfClass:[MysticAttrString class]] ? [(MysticAttrString *)title attrString] : title;
    MysticButton *btn = [[self class] buttonWithType:UIButtonTypeCustom];
    if([title.string containsString:@"\n"]) btn.titleLabel.numberOfLines=0;
    [btn setAttributedTitle:title forState:UIControlStateNormal];
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    [btn commonInit];
    if(title) size = title.size;
    btn.frame = CGRectMake(0, 0, size.width + (btn.padding*2), [[self class] buttonHeight]);
    if(action) [btn handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    return btn;
}
+ (instancetype) buttonWithAttrStr:(NSAttributedString *)title target:(id)target action:(SEL)action;
{
    title = [title isKindOfClass:[MysticAttrString class]] ? [(MysticAttrString *)title attrString] : title;
    MysticButton *btn = [[self class] buttonWithType:UIButtonTypeCustom];
    if([title.string containsString:@"\n"]) btn.titleLabel.numberOfLines=0;
    [btn setAttributedTitle:title forState:UIControlStateNormal];
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    [btn commonInit];
    if(title) size = title.size;
    btn.frame = CGRectMake(0, 0, size.width + (btn.padding*2), [[self class] buttonHeight]);
//    if(action) [btn handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


+ (instancetype) buttonWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    title = NSLocalizedString(title, nil);

    
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    confirmButton.titleLabel.font = [MysticUI gotham:16];
    if([title containsString:@"\n"]) confirmButton.titleLabel.numberOfLines=0;
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    [confirmButton setTitleColor:[UIColor mysticPinkColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor mysticChocolateColor] forState:UIControlStateHighlighted];
    [confirmButton commonInit];

    if(title)
    {
        size = [title sizeWithFont:confirmButton.titleLabel.font];
    }
    confirmButton.frame = CGRectMake(0, 0, size.width + (confirmButton.padding*2), [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //[confirmButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    //[confirmButton setBackgroundImage:cancelHighlighted forState:UIControlStateHighlighted];
    
    if(title) [confirmButton setTitle:title forState:UIControlStateNormal];
    if(action) [confirmButton handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    return confirmButton;
}

+ (instancetype) buttonWithTitle:(NSString *)title action:(MysticBlock)action;
{
    title = NSLocalizedString(title, nil);

    
    MysticButton *confirmButton = [[self class] buttonWithType:UIButtonTypeCustom];
    confirmButton.titleLabel.font = [MysticUI gotham:16];
    if([title containsString:@"\n"]) confirmButton.titleLabel.numberOfLines=0;
    CGSize size = CGSizeMake(40, [[self class] buttonHeight]);
    [confirmButton setTitleColor:[UIColor mysticPinkColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor mysticChocolateColor] forState:UIControlStateHighlighted];
    [confirmButton commonInit];

    if(title)
    {
        size = [title sizeWithFont:confirmButton.titleLabel.font];
    }
    confirmButton.frame = CGRectMake(0, 0, size.width + (confirmButton.padding*2), [[self class] buttonHeight]);
    [confirmButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //[confirmButton setBackgroundImage:cancelNormal forState:UIControlStateNormal];
    //[confirmButton setBackgroundImage:cancelHighlighted forState:UIControlStateHighlighted];
    
    if(title) [confirmButton setTitle:title forState:UIControlStateNormal];
    if(action) [confirmButton handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    return confirmButton;
}

+ (instancetype) clearButtonWithImage:(UIImage *)image target:(id)target sel:(SEL)action;
{
    MysticButton *button = [[self class] buttonWithImage:image target:target sel:action];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return button;
}




+ (instancetype) clearButtonWithImage:(UIImage *)image action:(ActionBlock)action;
{
    return [[[self class] clearButtonWithImage:image target:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlock:action];
}

+ (instancetype) clearButtonWithImage:(UIImage *)image senderAction:(MysticBlockSender)action;
{
    return [[[self class] clearButtonWithImage:image target:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
}

+ (instancetype) moreSettingsButtonWithTarget:(id)target sel:(SEL)action;
{
    return [[self class] downArrowButtonWithTarget:target sel:action];
}
+ (instancetype) dotsButtonWithTarget:(id)target sel:(SEL)action;
{
    // back button
    MysticButton *moreSettingsButton = [[self class] buttonWithImage:[UIImage imageNamed:@"more-settings-black.png"] target:target sel:action];
    [moreSettingsButton setBackgroundImage:[moreSettingsButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateSelected];
    return moreSettingsButton;
}

+ (instancetype) downArrowButtonWithTarget:(id)target sel:(SEL)action;
{
    // back button
    MysticButton *moreSettingsButton = [[self class] buttonWithImage:[UIImage imageNamed:@"arrow-down-black.png"] target:target sel:action];
    [moreSettingsButton setBackgroundImage:[moreSettingsButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateSelected];
    return moreSettingsButton;
}


+ (instancetype) slideOutButtonWithTarget:(id)target sel:(SEL)action;
{
    return [[self class] buttonWithImage:[UIImage imageNamed:@"slide-out-black.png"] target:target sel:action];
}

+ (instancetype) slideOutButton:(ActionBlock)action;
{
    return [[[self class] slideOutButtonWithTarget:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlock:action];
}

+ (instancetype) camButtonWithTarget:(id)target sel:(SEL)action;
{
    return [[self class] buttonWithImage:[UIImage imageNamed:@"back-cam-black.png"] target:target sel:action];
}

+ (instancetype) camButton:(ActionBlock)action;
{
    return [[[self class] camButtonWithTarget:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlock:action];
}

+ (instancetype) closeButtonWithTarget:(id)target sel:(SEL)action;
{
    MysticButton *btn = [[self class] clearButtonWithImage:[UIImage imageNamed:@"cancel-circle-gray.png"] target:target sel:action];
    [btn setImage:[UIImage imageNamed:@"cancel-circle-pink.png"] forState:UIControlStateHighlighted];
    return btn;
}

+ (instancetype) closeButton:(ActionBlock)action;
{
    return [[[self class] closeButtonWithTarget:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlock:action];
}

+ (instancetype) switchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
{
    MysticButton *button = [[self class] buttonWithImage:offImage target:target sel:action];
    
    if(onImage)
    {
        [button setImage:onImage forState:UIControlStateSelected];
    }
    [button setBackgroundImage:[button backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateSelected];
    button.selected = isOn;
    
    return button;
    
}

+ (instancetype) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage target:(id)target sel:(SEL)action;
{
    MysticButton *button = [[self class] clearButtonWithImage:offImage target:target sel:action];
    
    if(onImage)
    {
        [button setImage:onImage forState:UIControlStateSelected];
    }
    button.selected = isOn;
    
    return button;
    
}

+ (instancetype) clearSwitchButtonTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
{
    MysticButton *button = [[self class] clearButtonWithImage:offImage target:nil sel:nil];
    [button handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    
    if(onImage)
    {
        [button setImage:onImage forState:UIControlStateSelected];
    }
    button.selected = isOn;
    
    return button;
    
}


+ (instancetype) buttonWithIconType:(MysticIconType)iconType color:(id)colorObj target:(id)target action:(SEL)action;
{
//    UIColor *color = [MysticColor color:colorObj];
    UIImage *img = [MysticImage image:@(iconType) size:CGSizeMake(60, 60) color:colorObj];
    return [[self class] clearButtonWithImage:img target:target sel:action];
}

+ (instancetype) buttonWithIconType:(MysticIconType)iconType color:(id)colorObj action:(MysticBlockSender)action;
{
    UIColor *color;
    NSMutableArray *colors = [NSMutableArray array];
    if(colorObj)
    {
        if([colorObj isKindOfClass:[NSArray class]] && [(NSArray *)colorObj count])
        {
            [colors addObjectsFromArray:(NSArray *)colorObj];
            colorObj = [(NSArray *)colorObj objectAtIndex:0];

        }
        else
        {
            [colors addObject:colorObj];
        }
    }
    UIImage *img = [MysticImage image:@(iconType) size:CGSizeMake(60, 60) color:[MysticColor color:colorObj]];
    MysticButton *button = [[self class] clearButtonWithImage:img senderAction:action];
    button.tag = iconType;
    if(colors.count > 1)
    {
        for (int i = 1; i < colors.count; i++)
        {
            colorObj = [colors objectAtIndex:i];
            if([colorObj isKindOfClass:[NSNumber class]] && [colorObj integerValue] == MysticColorTypeUnknown)
            {
                continue;
            }
            img = [MysticIcon iconForType:iconType color:[MysticColor color:colorObj] image:img];
            switch (i) {
                case 1:
                    [button setImage:img forState:UIControlStateHighlighted];
                    break;
                case 2:
                    [button setImage:img forState:UIControlStateSelected];
                    break;
                case 3:
                    [button setImage:img forState:UIControlStateDisabled];
                    break;
                case 4:
                    [button setImage:img forState:UIControlStateApplication];
                    break;
                default: break;
            }
        }
    }
    return button;
}

+ (instancetype) moreButton:(MysticBlockSender)action;
{
    MysticButton *button = [[self class] moreButton:nil action:nil];
    [button handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    return button;
}
+ (instancetype) moreButton:(id)target action:(SEL)action;
{
    MysticImage *dotsImage = [MysticImage image:@(MysticIconTypeDots) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:@(MysticColorTypeNavBarIcon)];
    MysticImage *dotsImageHighlighted = [MysticImage image:@(MysticIconTypeDots) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:@(MysticColorTypeNavBarIconHighlighted)];
    
    MysticButton *button = [MysticUI clearButtonWithImage:dotsImage target:target sel:action];
    [button setImage:dotsImageHighlighted forState:UIControlStateHighlighted];
    return button;
}
@end


@implementation MysticButtonSelectable

- (BOOL) canSelect; { return YES; }


@end

@implementation MysticButtonBorderAlign


@end

//
//  MysticTransformButton.m
//  Mystic
//
//  Created by Me on 2/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTransformButton.h"
#import "Mystic.h"

@implementation  MysticButtonTransform : MysticButton

@end


@interface MysticTransformButton ()




@end


@implementation MysticTransformButton

@synthesize button=_button, bg=_bg;

+ (id) buttonWithType:(UIButtonType)type  underlyingView:(UIView *)underlyingView;
{
    MysticTransformButton *button = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, MYSTIC_UI_TOOLS_TOOL_SIZE, MYSTIC_UI_TOOLS_TOOL_SIZE) underlyingView:underlyingView];
    
    
    return [button autorelease];
}

- (void) dealloc;
{
    [_button release];
    [_bg release];
    [super dealloc];
    
    
}

- (id)initWithFrame:(CGRect)frame underlyingView:(UIView *)underlyingView;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2;
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];

        self.opaque = NO;

        UIVisualEffectView *effect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effect.frame = self.bounds;
        effect.userInteractionEnabled = NO;
        self.bg = [effect autorelease];
        [self addSubview:self.bg];
        
        MysticButtonTransform *__button = [MysticButtonTransform buttonWithType:UIButtonTypeCustom];
        __button.frame = self.bounds;
        __button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        __button.backgroundColor = [[UIColor colorWithType:MysticColorTypeTransformToolBackground] colorWithAlphaComponent:0.0];
        __button.continueOnHold = YES;
        __button.holdingInterval = 0.035f;
        __button.canSelect = YES;
        __button.adjustsImageWhenHighlighted = NO;
        __button.hitInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        __button.contentMode = UIViewContentModeCenter;
        __button.userInteractionEnabled = YES;
        [__button setBackgroundColor:[[UIColor color:MysticColorTypePink] alpha:0.7] forState:UIControlStateHighlighted];
        __button.highlighted = NO;
        
        [self addSubview:__button];
        self.button = __button;

    }
    return self;
}
- (void) removeFromSuperview;
{

    
    [self.button removeFromSuperview];
    [self.bg removeFromSuperview];

    [super removeFromSuperview];
    self.button = nil;
    self.bg = nil;
}
- (BOOL) selected; { return self.button.selected; }
- (void) setSelected:(BOOL)selected; { [self.button setSelected:selected]; }

- (void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}
- (void) removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    [self.button removeTarget:target action:action forControlEvents:controlEvents];
}
- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)forState;
{
    [self.button setBackgroundColor:backgroundColor forState:forState];

}
- (void) setBackgroundImage:(UIImage *)bgImage forState:(UIControlState)state;
{
    [self.button setBackgroundImage:bgImage forState:state];
}
- (void) setImage:(UIImage *)bgImage forState:(UIControlState)state;
{
    [self.button setImage:bgImage forState:state];
}



- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    return CGRectContainsPoint(CGRectMake(-50.0, -50.0,
                                          self.bounds.size.width + 50.0*2,
                                          self.bounds.size.height + 50.0*2), point);
}

- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.layer.cornerRadius = frame.size.width/2;
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

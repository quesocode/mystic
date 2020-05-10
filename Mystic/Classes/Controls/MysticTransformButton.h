//
//  MysticTransformButton.h
//  Mystic
//
//  Created by Me on 2/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

//#import "MysticButton.h"
#import <QuartzCore/QuartzCore.h>

#import "MysticToolBlurView.h"
#import "MysticButton.h"

@interface MysticButtonTransform : MysticButton

@end


@interface MysticTransformButton : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) UIVisualEffectView *bg;
@property (nonatomic, retain) MysticButtonTransform *button;

+ (id) buttonWithType:(UIButtonType)type  underlyingView:(UIView *)underlyingView;
- (id)initWithFrame:(CGRect)frame underlyingView:(UIView *)underlyingView;

- (void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void) setBackgroundImage:(UIImage *)bgImage forState:(UIControlState)state;
- (void) setImage:(UIImage *)bgImage forState:(UIControlState)state;
- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)forState;
@end

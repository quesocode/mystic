//
//  MysticToggleButton.h
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticBarButton.h"

@interface MysticToggleButton : MysticBarButton

@property (nonatomic, assign) MysticToggleState toggleState, toggleStateAndTrigger, previousToggleState;

@property (nonatomic, assign) NSInteger maxToggleState, minToggleState, stopToggleState, otherState, defaultToggleState, defaultValue, nextToggleState, startToggleState;
@property (nonatomic, retain) NSMutableDictionary *icons;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) MysticColorType iconColorType;
@property (nonatomic, assign) MysticIconType iconStyle;
@property (nonatomic, assign) CGSize iconSize;
@property (nonatomic, retain) UIColor *iconColor, *iconColorSelected, *iconColorHighlighted, *iconColorDisabled;
@property (nonatomic, retain) UIImage *iconImage;
@property (nonatomic, retain) NSIndexSet *toggleIndex;
@property (nonatomic, assign) BOOL allowLoop, animateToggleImages, hasToggled;
@property (nonatomic, readonly) BOOL on;
@property (nonatomic, readonly) int numberOfToggleStates;
@property (nonatomic, assign) id onToggleTarget;
@property (nonatomic, assign) SEL onToggleAction;
@property (nonatomic, copy) MysticBlockSender onToggle;
@property (nonatomic, assign) NSTimeInterval animateImageDuration;
- (MysticToggleState) toggle;
- (void) reset;
- (MysticToggleState) runOnToggle;
- (void) setIconImage:(UIImage *)iconImage forState:(NSInteger)state;
- (void) setIconColorType:(MysticColorType)iconColorType forState:(NSInteger)state;
- (UIImage *) iconForState:(NSInteger)state;
- (UIImage *) imageForState:(NSInteger)astate;
- (void) updateIconImage;
- (void) finishedOnToggle;
@end

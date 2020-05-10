//
//  MysticFontSpacingControl.h
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticControl.h"
#import "MysticLabel.h"

@interface MysticFontSpacingControl : MysticControl

@property (nonatomic, assign) MysticIconType plusIconType, minusIconType;
@property (nonatomic, assign) CGFloat incrementSize, labelFontSize, emptyValue;
@property (nonatomic, assign) NSTimeInterval incrementInterval;
@property (nonatomic, assign) BOOL allowLoop;
@property (nonatomic, retain) MysticAnimatedLabel *label;
@property (nonatomic, retain) MysticButton *leftButton, *rightButton;
@property (nonatomic, readonly) NSString *labelFormatString;
- (void) increase;
- (void) decrease;
- (CGFloat) formatValue:(CGFloat)newValue;
- (void) setValueText:(CGFloat)value animated:(BOOL)animated;

@end

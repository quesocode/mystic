 //
//  MysticButtonBrush.h
//  Mystic
//
//  Created by Travis A. Weerts on 2/29/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticButton.h"

@interface MysticButtonBrush : MysticButton
@property (nonatomic, assign) BOOL ignoreFeather, ignoreOpacity, ignoreColor;
@property (nonatomic, assign) CGFloat feather, size, opacity;
@property (nonatomic, assign) MysticBrush brush;
@property (nonatomic, assign) MysticBrushType type;
@property (nonatomic, assign) MysticBrushSetting setting;
@property (nonatomic, retain) UIColor *color, *displayColor;
@property (nonatomic, assign) MysticAlignPosition brushButtonPosition;

+ (instancetype) brushButtonWithSetting:(MysticBrushSetting)setting brush:(MysticBrush)brush color:(UIColor *)color displayColor:(UIColor *)displayColor action:(MysticBlockSender)action;
+ (instancetype) brushButtonWithSetting:(MysticBrushSetting)setting brush:(MysticBrush)brush color:(UIColor *)color displayColor:(UIColor *)displayColor target:(id)target action:(SEL)action;

@end

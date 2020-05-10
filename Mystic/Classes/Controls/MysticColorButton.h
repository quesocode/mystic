//
//  MysticColorButton.h
//  Mystic
//
//  Created by Travis A. Weerts on 3/29/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticButton.h"

@interface MysticColorButtonColorView : UIView

@end
@interface MysticColorButton : MysticButton
@property (nonatomic, retain) UIColor *color, *defaultColor;
@property (nonatomic, retain) NSString *inputTitle;
@property (nonatomic, retain) PackPotionOption *option;
@property (nonatomic, retain) MysticColorButtonColorView *colorView;
@property (nonatomic, copy) MysticBlockColorButton colorAction;
@property (nonatomic, assign) CGSize iconSize;
@property (nonatomic, assign) BOOL hideActiveColor;
+ (instancetype) colorButton:(UIColor *)color title:(NSString *)title option:(id)option action:(MysticBlockColorButton)action;


@end

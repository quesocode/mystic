//
//  MysticRadialGradientLayer.h
//  Mystic
//
//  Created by Travis A. Weerts on 3/1/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MysticRadialGradientView : UIView

@property (nonatomic, retain) UIColor *color1, *color2;
@property (nonatomic, assign) CGFloat feather;

@end

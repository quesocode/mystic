//
//  MysticBlurBackgroundView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticBlurBackgroundView : UIView
@property (nonatomic, assign) BOOL  blurBackground;
@property (nonatomic, retain) UIColor *originalBackgroundColor;
@property (nonatomic, retain) UIVisualEffectView *blurView;
@property (nonatomic, assign) CGFloat backgroundColorAlpha;
- (instancetype) commonInit;

@end

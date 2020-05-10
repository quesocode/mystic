//
//  MysticIndicatorView.h
//  Mystic
//
//  Created by Travis A. Weerts on 8/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticIndicatorView : UIView

@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) NSTimeInterval duration, delay;
@property (nonatomic, assign) UIView *topView, *bottomView;
@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, assign) UIEdgeInsets insets;
- (void) animateToView:(UIView *)subview animated:(BOOL)animated complete:(MysticBlockBOOL)completion;



@end

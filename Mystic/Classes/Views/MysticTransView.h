//
//  MysticTransView.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/15/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticDrawView.h"
#import "MysticRectView.h"
#import "MysticDrawPathView.h"

@class MysticContentViewFill, MysticContentViewBorder;

@interface MysticTransContentView : UIView
- (void) setBounds:(CGRect)bounds layoutSubviews:(BOOL)layoutSubviews;
@end

@interface MysticTransView : UIView
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) MysticTransContentView *contentView;
@property (nonatomic, assign) MysticDrawView *drawView;
@property (nonatomic, assign) MysticContentViewBorder *borderView;
@property (nonatomic, assign) MysticContentViewFill *fillView;
@property (nonatomic, assign) BOOL shouldUpdateContent;
@property (nonatomic, readonly) CGRect innerFrame;
@property (nonatomic, assign) CGRect newFrame;
@property (nonatomic, readonly) BOOL hasDrawView, hasContentView, hasImageView, hasFillView, hasBorderView;
- (void) resetContent;
- (void) updateLayout;
- (void) updateLayout:(BOOL)layoutSubviews;

@end

@interface MysticContentViewBorder : MysticDrawPathBorderView


@end

@interface MysticContentViewFill : MysticDrawPathFillView


@end

@interface MysticContentViewMask : MysticDrawPathFillView


@end


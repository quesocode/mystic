//
//  MysticScrollHeaderView.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticView.h"

@class MysticScrollHeaderView, MysticScrollView;

@protocol MysticScrollHeaderViewDelegate <NSObject>

- (void) scrollHeader:(MysticScrollHeaderView *)headerView didTouchItem:(id)sender;

@end
@interface MysticScrollHeaderView : MysticView

@property (nonatomic, assign) MysticScrollView *scrollView;
@property (nonatomic, assign) id<MysticScrollHeaderViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval visibleDelay, animateInDuration, animateOutDuration;
@property (nonatomic, assign) UIEdgeInsets originalInsets;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGFloat visibleThreshold;
+ (id) headerViewWithScrollView:(MysticScrollView *)scrollView frame:(CGRect)hFrame;

+ (id) headerViewWithScrollView:(MysticScrollView *)scrollView;
- (void) updatePosition:(CGPoint)offset scrollView:(MysticScrollView *)scrollView;

@end

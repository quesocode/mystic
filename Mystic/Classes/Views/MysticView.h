//
//  MysticView.h
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@class MysticGradient;

@interface MysticView : UIView

@property (nonatomic, assign) CGPoint positionOffset;
@property (nonatomic, assign) BOOL isShowing, isHiding, debug;
@property (nonatomic, readonly) BOOL willBeVisible, hasBackgroundGradient;
@property (nonatomic, assign) CGPoint stickToPoint;
- (void) commonInit;
- (id) viewWithClass:(Class)viewClass;
- (NSDictionary *) viewsWithClass:(Class)viewClass;

- (id) reuseableSubViewExcept:(NSArray *)exceptions subviews:(NSArray **)returnSubs matching:(MysticBlockReturnsBOOL)reuseControlBlock;
- (void) removeSubviews:(NSArray *)trashViews;

- (void) fadeSubviews:(NSArray *)theViews hidden:(BOOL)fadeOut duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlockObject)viewAnimationBlock complete:(MysticBlock)finished;
- (void) removeBackgroundGradient;
- (void) setBackgroundGradient:(NSArray *)gradientColors locations:(NSArray *)gradientLocations;
- (void) setBackgroundGradient:(MysticGradient *)gradient;


@end

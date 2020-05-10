//
//  MysticTouchView.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/26/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticTouchView : UIView

@property (nonatomic, assign) CGPoint startPoint, originalPoint, endPoint, changePoint, totalChangePoint, currentPoint;
@property (nonatomic, copy) MysticBlockTouch touchBegan, touchMoved, touchEnded, touchCancelled;
@property (nonatomic, copy) MysticBlockTouchTap tap;
@property (nonatomic, copy) MysticBlockTouchDoubleTap doubleTap;
- (void) updateGestures;

@end

//
//  MysticRectView.h
//  Mystic
//
//  Created by Travis A. Weerts on 11/16/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticRectView : UIView

@property (nonatomic, retain) id border;
@property (nonatomic, retain) NSString *viewInfo;
@property (nonatomic, readonly) NSString *classString;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) UIView *fromView;
@property (nonatomic, retain) id color;
@property (nonatomic, assign) int depth;
+ (id) viewWithFrame:(CGRect)frame border:(id)borderWidth color:(id)color;
- (BOOL) hasColor:(id)color;

@end
@interface MysticLayerRect : CAShapeLayer

@end

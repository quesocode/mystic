//
//  BottomToolbar.h
//  Mystic
//
//  Created by travis weerts on 1/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"

@interface BottomToolbar : UIView
@property (nonatomic, retain) UIColor *borderColor, *originalBackgroundColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIEdgeInsets borderInsets, contentInsets;
@property (nonatomic, assign) BOOL showBorder, drawBorderIntegral, debug;
@property (nonatomic, assign) MysticPosition borderPosition, borderAnchorPosition;
@property (nonatomic) BOOL dashed;
@property (nonatomic) CGRect contentBounds;
@property (nonatomic) CGSize dashSize;
@property (nonatomic) CGPoint contentCenter, borderOffset;
@property (nonatomic, assign) BOOL  blurBackground;

@end

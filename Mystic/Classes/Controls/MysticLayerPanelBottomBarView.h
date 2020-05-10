//
//  MysticLayerPanelBottomBarView.h
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"

@class MysticLayerToolbar;

@interface MysticLayerPanelBottomBarView : UIView

@property (nonatomic, readonly) MysticLayerToolbar *toolbar;
@property (nonatomic, assign) BOOL dashed, showBorder;
@property (nonatomic, assign) CGSize dashSize;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) MysticPosition borderPosition;
@property (nonatomic, assign) CGRect contentBounds;
@property (nonatomic, assign) CGPoint contentCenter;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@end

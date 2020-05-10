//
//  MysticResizeableLabelBorderView.h
//  MysticResizableLabel
//
//  Created by travis weerts on 8/15/13.
//  Copyright (c) 2013 Mystic. All rights reserved.
//

#import "MysticConstants.h"
#import <UIKit/UIKit.h>

@interface MysticResizeableLayerBorderView : UIView;


@property (nonatomic, retain) UIColor *borderColor, *handleSlitColor;
@property (nonatomic) BOOL handlesHidden, dashed;
@property (nonatomic, assign) MysticPosition handlePostions;
@property (nonatomic) CGFloat borderWidth, handleScale;
@property (nonatomic, readonly) CGRect innerRect;
@end


@interface  MysticResizeableLabelBorderView : MysticResizeableLayerBorderView;

@end
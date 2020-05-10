//
//  MysticLayerContentView.h
//  Mystic
//
//  Created by Me on 12/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticTypedefs.h"

@protocol MysticLayerViewAbstract;


@interface MysticLayerContentView : UIView
{
    BOOL _initialized;
    BOOL _frameIsSetForTheFirstTime;
    BOOL _layoutFrameSet;
    
}

@property (nonatomic, assign) UIView *view, *layoutView;
@property (nonatomic, assign) BOOL shouldScale, adjustsAspectRatioOnResize;
@property (nonatomic, assign) id <MysticLayerViewAbstract> layerView;
@property (nonatomic, readonly) CGRect originalFrame;
@property (nonatomic, assign) CGRect contentBounds, layoutFrame;
@property (nonatomic) CGFloat ratio, minimumWidth, minimumHeight, scale;
@property (nonatomic) CGSize targetSize;
@property (nonatomic, assign) CGScale transformScale;
- (void) setNewFrame:(CGRect)frame layout:(CGRect)layoutFrame;

- (void) scale:(CGFloat)newScale;
- (CGRect) adjustedBounds:(CGRect)newBounds;
- (void) setNewFrame:(CGRect)frame;

@end

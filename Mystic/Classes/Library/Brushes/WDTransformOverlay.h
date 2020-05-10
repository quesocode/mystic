//
//  WDTransformOverlay.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2010-2013 Steve Sprang
//


#import <UIKit/UIKit.h>
#import "MysticLayerToolbar.h"

@class WDCanvas, WDTransformNavigationBar;

@interface WDTransformOverlay : UIControl <UIGestureRecognizerDelegate> {
    CGAffineTransform           transform_;
    float                       initialScale_;
    float                       initialAngle_;
    MysticLayerToolbar          *toolbar_;
    WDTransformNavigationBar    *navbar_;
}

@property (nonatomic, weak) WDCanvas *canvas;
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^acceptBlock)(void);
@property (nonatomic, readonly) CGAffineTransform alignedTransform;
@property (nonatomic) BOOL horizontalFlip;
@property (nonatomic) BOOL verticalFlip;
@property (nonatomic) NSString *prompt;
@property (nonatomic) NSString *title;
@property (nonatomic) BOOL showToolbar;

- (CGAffineTransform) configureInitialPhotoTransform;

@end

@interface WDTransformNavigationBar : UINavigationBar

@end
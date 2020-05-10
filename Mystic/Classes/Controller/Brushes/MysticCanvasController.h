//
//  MysticCanvasController.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/21/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "WDCanvasController.h"
#import "WDDocument.h"
#import "WDPaintingManager.h"
#import "MysticCommon.h"
#import "WDCanvas.h"
#import "WDPainting.h"
#import "MysticSlider.h"
@class MysticController;
@class MysticCanvasSliderDisplay;

@interface MysticCanvasController : WDCanvasController
@property (nonatomic, assign) MysticController *controller;
@property (nonatomic, assign) MysticSliderBrush *brushOpacitySlider, *brushWeightSlider;
@property (nonatomic, assign) MysticCanvasSliderDisplay *sliderDisplay;
@property (nonatomic, readonly) BOOL hasSketched;
@property (nonatomic, readonly) UIImage *image;
- (void) createDocument:(UIImage *)sourceImage size:(CGSize)size finished:(MysticBlockObject)finished;
- (void) deleteDocument;
- (void) setupView;
- (void) close;
- (void) destroyControls;

@end

@interface MysticCanvasSliderDisplay : UIView

@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UIImageView *brushView;
- (void) update:(NSString *)str mode:(int)mode value:(float)value;

@end

//#import <UIKit/UIKit.h>
//#import "MysticCommon.h"
//
//
//@interface MysticCanvasController : UIViewController
//
//@end

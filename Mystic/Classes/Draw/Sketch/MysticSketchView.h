//
//  MysticSketchView.h
//  Mystic
//
//  Created by Travis A. Weerts on 3/4/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MysticTypedefs.h"
#import "MysticConstants.h"



@interface MysticSketchView : UIControl

@property (assign) MysticSketchToolType toolType;
@property (strong,nonatomic) UIColor* drawColor, *color2;
@property (assign) CGFloat drawWidth;
@property (assign) CGFloat drawOpacity;
@property (assign) CGFloat airBrushFlow;
@property (assign) MysticSketchToolType setting;
- (void) clearToColor:(UIColor*)color;

- (UIImage*) getSketch;
- (void) setSketch:(UIImage*)sketch;

@end

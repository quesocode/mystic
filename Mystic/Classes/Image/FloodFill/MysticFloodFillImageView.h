//
//  FloodFillImageView.h
//  ImageFloodFilleDemo
//
//  Created by chintan on 11/07/13.
//  Copyright (c) 2013 ZWT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+FloodFill.h"

@interface MysticFloodFillImageView : UIImageView
@property int tolerance;
@property (strong, nonatomic)  UIColor *newcolor;
@property (assign, nonatomic) BOOL continuous, antialias, makeMask;
@property (assign, nonatomic) CGFloat smooth;
- (void) replaceWith:(UIColor *)color at:(CGPoint)tpoint tolerance:(int)t antialias:(BOOL)antialias smooth:(CGFloat)smooth continous:(BOOL)continuous;

@end

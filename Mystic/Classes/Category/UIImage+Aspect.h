//
//  UIImage+Aspect.h
//  Mystic
//
//  Created by travis weerts on 12/8/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Aspect)

- (UIImage *)imageScaledToSize:(CGSize)size;
- (CGRect) imageFrame;
- (UIImage*)imageByCroppingToRect:(CGRect)aperture;
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation;
@end

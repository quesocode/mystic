//
//  MysticFillFilter.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/17/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticOneInputFilter.h"

@interface MysticFillFilter : GPUImageFilter
{
    GLint toleranceUniform;
    GLint smoothingUniform;
    GLint colorToReplaceUniform;
    
    GLint texelWidthUniform, texelHeightUniform;
    
    CGFloat texelWidth, texelHeight;
    BOOL hasOverriddenImageSizeFactor;
}

// The texel width and height determines how far out to sample from this texel. By default, this is the normalized width of a pixel, but this can be overridden for different effects.
@property(readwrite, nonatomic) CGFloat texelWidth;
@property(readwrite, nonatomic) CGFloat texelHeight;

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat tolerance, smoothing;
@property(nonatomic, assign) UIColor *targetColor;

@end

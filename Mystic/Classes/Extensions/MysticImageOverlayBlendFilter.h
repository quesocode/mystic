//
//  MysticImageOverlayBlendFilter.h
//  Mystic
//
//  Created by travis weerts on 4/26/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MysticImageOverlayBlendFilter : GPUImageTwoInputFilter
{
GLint colorToReplaceUniform, thresholdSensitivityUniform, smoothingUniform, invertColorUniform, opacityUniform;
}

/** The threshold sensitivity controls how similar pixels need to be colored to be replaced
 
 The default value is 0.3
 */
@property(readwrite, nonatomic) GLfloat thresholdSensitivity;

/** The degree of smoothing controls how gradually similar colors are replaced in the image
 
 The default value is 0.1
 */
@property(readwrite, nonatomic) GLfloat smoothing;

@property(readwrite, nonatomic) GLfloat opacity;

@property(readwrite, nonatomic) BOOL inverted;

/** The color to be replaced is specified using individual red, green, and blue components (normalized to 1.0).
 
 The default is green: (0.0, 1.0, 0.0).
 
 @param redComponent Red component of color to be replaced
 @param greenComponent Green component of color to be replaced
 @param blueComponent Blue component of color to be replaced
 */
- (void)setColorToReplaceRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
- (void) invert:(BOOL)inverted;

- (BOOL) isMysticBlendFilter;
@end

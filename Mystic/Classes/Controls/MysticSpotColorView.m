//
//  MysticSpotColorView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticSpotColorView.h"
#import "UIColor+Mystic.h"
#import "MysticUtility.h"


@implementation MysticSpotColorView

@synthesize color=_color, color3=_color3,color2=_color2, oldColor2=_oldColor2, oldColor3=_oldColor3, oldColor=_oldColor, closeness=_closeness, closeness2=_closeness2, closeness3=_closeness3, contrast=_contrast, contrast2=_contrast2, contrast3=_contrast3, makeMask=_makeMask;
- (void) setup;
{
    [super setup];
    self.backgroundColor = [UIColor greenColor];
    self.oldColor = [UIColor redColor];
    self.color = [UIColor blackColor];
    self.closeness = 0.22;
    self.contrast = 0.2;
    self.closeness2 = 0.0;
    self.contrast2 = 1.0;
    self.closeness3 = 0.0;
    self.contrast3 = 1.0;
    self.noise = 0.05;
    self.bias = 1.0;
    
    _mode = 0;
    self.sharpness = 0.4;
    _makeMask = YES;
}
- (UIColor *) color; { return _makeMask ? [UIColor blackColor] : _color; }
- (UIColor *) color2; { return _makeMask ? [UIColor blackColor] : _color2; }
- (UIColor *) color3; { return _makeMask ? [UIColor blackColor] : _color3; }
- (UIImage *) updateFilters:(BOOL)andDisplay save:(BOOL)save;
{
    NSMutableArray *filters = [NSMutableArray array];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISpotColor"];
    if(filter)
    {
        
        CIColor *old = self.oldColor.CIColor;
        CIColor *new = self.color.CIColor;
        CIColor *old2 = !self.oldColor2 ? old : self.oldColor2.CIColor;
        CIColor *new2 = !self.color2 ? new : self.color2.CIColor;
        CIColor *old3 = !self.oldColor3 ? old : self.oldColor3.CIColor;
        CIColor *new3 = !self.color3 ? new : self.color3.CIColor;

        [filter setDefaults];
        [filter setValue:old forKey: @"inputCenterColor1"];
        [filter setValue:new forKey: @"inputReplacementColor1"];
        [filter setValue:old2 forKey: @"inputCenterColor2"];
        [filter setValue:new2 forKey: @"inputReplacementColor2"];
        [filter setValue:old3 forKey: @"inputCenterColor3"];
        [filter setValue:new3 forKey: @"inputReplacementColor3"];

        
        [filter setValue:@(self.closeness) forKey: @"inputCloseness1"];
        [filter setValue:@(self.contrast) forKey: @"inputContrast1"];
        
        [filter setValue:@(self.closeness2) forKey: @"inputCloseness2"];
        [filter setValue:@(self.contrast2) forKey: @"inputContrast2"];
        
        [filter setValue:@(self.closeness3) forKey: @"inputCloseness3"];
        [filter setValue:@(self.contrast3) forKey: @"inputContrast3"];
        //
        //
        //        //---------------------------- picked up a blue jacket total, including all the shadows, a near perfect mask of a fairly blue jacket all ranges  ---------------------------
        //        [filter setValue:[CIColor colorWithRed:0.01 green:0.165 blue:1.0] forKey: @"inputCenterColor1"];
        //        [filter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] forKey: @"inputReplacementColor1"];
        //        [filter setValue:@(0.86) forKey: @"inputCloseness1"];
        //        [filter setValue:@(1.0) forKey: @"inputContrast1"];
        //
        //        //---------------------------- did not need this input but experimenting and left it in to add other changes,  same with below experiments  ---------------------------
        //        [filter setValue:[CIColor colorWithRed:0.01 green:0.165 blue:1.0] forKey: @"inputCenterColor2"];
        //        [filter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] forKey: @"inputReplacementColor2"];
        //        [filter setValue:@(0.86) forKey: @"inputCloseness2"];
        //        [filter setValue:@(1.0) forKey: @"inputContrast2"];
        //
        //        [filter setValue:[CIColor colorWithRed:1.0 green:0.5 blue:0.5] forKey: @"inputCenterColor3"];
        //        [filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey: @"inputReplacementColor3"];
        //        [filter setValue:@(0.99) forKey: @"inputCloseness3"];
        //        [filter setValue:@(0.99) forKey: @"inputContrast3"];
        
        [filters addObject:filter];
    }
    if(self.mode == 1 || self.mode > 4)
    {
        filter = [CIFilter filterWithName:@"CIConvolution3X3"];
        const double g = 1.;
        const CGFloat weights[] = { 1*g, 0, -1*g,
            2*g, 0, -2*g,
            1*g, 0, -1*g};
        [filter setValue:[CIVector vectorWithValues:weights count:9] forKey: @"inputWeights"];
        [filter setValue:@(self.bias) forKey:@"inputBias"];
        [filters addObject:filter];

        
    }
    if(self.mode == 2 || self.mode >= 4)
    {
        filter = [CIFilter filterWithName:@"CIMedianFilter"];
        [filters addObject:filter];
        
    }
    if(self.mode == 3 || self.mode >= 4)
    {
        filter = [CIFilter filterWithName:@"CINoiseReduction"];
        [filter setValue:@(self.noise) forKey: @"inputNoiseLevel"];
        [filter setValue:@(self.sharpness) forKey: @"inputSharpness"];

        [filters addObject:filter];
    }

    // Allocate memory
    //    float minHueAngle = 0.41;
    //    float maxHueAngle = 0.65;
    //    float centerHueAngle = minHueAngle + (maxHueAngle - minHueAngle)/2.0;
    //    float destCenterHueAngle = 1.0/3.0;
    //
    //    const unsigned int size = 64;
    //    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    ////    float *cubeData = (float *) malloc ( cubeDataSize );
    ////    float rgb[3], hsv[3], newRGB[3];
    ////
    ////    size_t offset = 0;
    ////    for (int z = 0; z < size; z++)
    ////    {
    ////        rgb[2] = ((double) z) / size; // blue value
    ////        for (int y = 0; y < size; y++)
    ////        {
    ////            rgb[1] = ((double) y) / size; // green value
    ////            for (int x = 0; x < size; x++)
    ////            {
    ////                rgb[0] = ((double) x) / size; // red value
    ////                rgbToHSV(rgb, hsv);
    ////
    ////                if (hsv[0] < minHueAngle || hsv[0] > maxHueAngle)
    ////                    memcpy(newRGB, rgb, sizeof(newRGB));
    ////                else
    ////                {
    ////                    hsv[0] = destCenterHueAngle + (centerHueAngle - hsv[0]);
    ////                    hsvToRGB(hsv, newRGB);
    ////                }
    ////
    ////                cubeData[offset]   = newRGB[0];
    ////                cubeData[offset+1] = newRGB[1];
    ////                cubeData[offset+2] = newRGB[2];
    ////                cubeData[offset+3] = 1.0;
    ////
    ////                offset += 4;
    ////            }
    ////        }
    ////    }
    //
    //    float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
    //    float rgb[3], hsv[3],  newRGB[3], *c = cubeData;
    //
    //    // Populate cube with a simple gradient going from 0 to 1
    ////    for (int z = 0; z < size; z++){
    ////        rgb[2] = ((double)z)/(size-1); // Blue value
    ////        for (int y = 0; y < size; y++){
    ////            rgb[1] = ((double)y)/(size-1); // Green value
    ////            for (int x = 0; x < size; x ++){
    ////                rgb[0] = ((double)x)/(size-1); // Red value
    ////                // Convert RGB to HSV
    ////                // You can find publicly available rgbToHSV functions on the Internet
    ////                rgbToHSV(rgb, hsv);
    ////                // Use the hue value to determine which to make transparent
    ////                // The minimum and maximum hue angle depends on
    ////                // the color you want to remove
    //////                float alpha = (hsv[0] > minHueAngle && hsv[0] < maxHueAngle) ? 0.0f: 1.0f;
    ////
    ////                if (hsv[0] < minHueAngle || hsv[0] > maxHueAngle)
    ////                {
    ////                    c[0] = rgb[0];
    ////                    c[1] = rgb[1];
    ////                    c[2] = rgb[2];
    ////                    c[3] = 1.0;
    ////                    c += 4;
    ////                }
    ////                else
    ////                {
    //////                    hsv[0] = destCenterHueAngle + (centerHueAngle - hsv[0]);
    //////                    hsvToRGB(hsv, newRGB);
    ////                    c[0] = 0.0;
    ////                    c[1] = 0.0;
    ////                    c[2] = 0.0;
    ////                    c[3] = 1.0;
    ////                    c += 4;
    ////                }
    ////
    ////
    ////                // Calculate premultiplied alpha values for the cube
    //////                c[0] = rgb[0] * alpha;
    //////                c[1] = rgb[1] * alpha;
    //////                c[2] = rgb[2] * alpha;
    //////                c[3] = alpha;
    //////                c += 4; // advance our pointer into memory for the next color value
    ////            }
    ////        }
    ////    }
    //
    //    for (int z = 0; z < size; z++){
    //        rgb[2] = ((double)z)/(size-1); // Blue value
    //        for (int y = 0; y < size; y++){
    //            rgb[1] = ((double)y)/(size-1); // Green value
    //            for (int x = 0; x < size; x ++){
    //                rgb[0] = ((double)x)/(size-1); // Red value
    //                // Convert RGB to HSV
    //                // You can find publicly available rgbToHSV functions on the Internet
    //                rgbToHSV(rgb, hsv);
    //                // Use the hue value to determine which to make transparent
    //                // The minimum and maximum hue angle depends on
    //                // the color you want to remove
    //                if(hsv[0] > minHueAngle && hsv[0] < maxHueAngle)
    //                {
    //                    c[0] = 0.0;
    //                    c[1] = 1.0;
    //                    c[2] = 0.0;
    //
    //
    //
    //                }
    //                else
    //                {
    //                    c[0] = 0.0;
    //                    c[1] = 0.0;
    //                    c[2] = 0.0;
    //
    //
    //                }
    ////                float alpha = (hsv[0] > minHueAngle && hsv[0] < maxHueAngle) ? 1.0f: 0.0f;
    ////                // Calculate premultiplied alpha values for the cube
    ////                c[0] = rgb[0] * alpha;
    ////                c[1] = rgb[1] * alpha;
    ////                c[2] = rgb[2] * alpha;
    //                c[3] = 1.0;
    //                c += 4; // advance our pointer into memory for the next color value
    //            }
    //        }
    //    }
    //    
    //    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    //    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    //    [colorCube setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    //    [colorCube setValue:data forKey:@"inputCubeData"];
    //
    //    [filters addObject:colorCube];
    
    
    if(filters.count) self.filters = filters;
    return andDisplay || save ? [self display:save] : nil;
}
- (void) nextMode;
{
    int m = self.mode;
    m++;
    if(m >4)
    {
        m = 0;
    }
    _mode = m;
}
@end

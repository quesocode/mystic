//
//  MysticImageOverlayBlendFilter.m
//  Mystic
//
//  Created by travis weerts on 4/26/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticImageOverlayBlendFilter.h"


NSString *const kMysticOverlayBlendFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform float thresholdSensitivity;
 uniform float smoothing;
 uniform float opacity;
 uniform vec3 colorToReplace;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     

     

     
     
     
     vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     textureColor2 = vec4(textureColor2.r,textureColor2.g,textureColor2.b, 1.0);
     float d = distance(vec2(colorToReplace.r, colorToReplace.r), vec2(textureColor2.r, textureColor2.r));

     vec4  textureColor = textureColor2;

     float blendValue = smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, d);
     
     textureColor = vec4(textureColor.rgb, d);


     
     
     
     
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     mediump vec4 overlay = textureColor;
  
         mediump float ra;
         if (2.0 * base.r < base.a) {
             ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
         }
    
         else {
             ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
             

         }
         
         mediump float ga;
         if (2.0 * base.g < base.a) {
             ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
         }
     
         else {
             ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
         }
         
         mediump float ba;
         if (2.0 * base.b < base.a) {
             ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
         }
         
         else {
             ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
         }
         
         mediump vec4 overlayColor = vec4(ra, ga, ba, 1.0);
     float na = textureColor.a - (1.0 - opacity);
     if(na < 0.0)
     {
         na = 0.0;
     }
     
        overlayColor = vec4(mix(base.rgb, overlayColor.rgb, na), base.a);
     

     gl_FragColor = overlayColor;
     
      
      
     
 }
 );

@implementation MysticImageOverlayBlendFilter

@synthesize thresholdSensitivity = _thresholdSensitivity;
@synthesize smoothing = _smoothing;
@synthesize inverted=_inverted;
     @synthesize opacity=_opacity;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kMysticOverlayBlendFragmentShaderString]))
    {
		return nil;
    }
    
    thresholdSensitivityUniform = [filterProgram uniformIndex:@"thresholdSensitivity"];
    smoothingUniform = [filterProgram uniformIndex:@"smoothing"];
    colorToReplaceUniform = [filterProgram uniformIndex:@"colorToReplace"];
    invertColorUniform = [filterProgram uniformIndex:@"invertColor"];
    opacityUniform = [filterProgram uniformIndex:@"opacity"];
    //self.thresholdSensitivity = 0.15;
    //self.smoothing = (1.0 - self.thresholdSensitivity)- self.thresholdSensitivity;
    
    self.thresholdSensitivity = 0.1;
    self.smoothing =0.8;
    
    
    self.inverted = NO;
    self.opacity = 1.0;
    [self setColorToReplaceRed:0.0 green:0.0 blue:0.0];
    
    return self;
}

#pragma mark -
#pragma mark Accessors
//setBackgroundColorRed:0 green:1.0f blue:0.0f alpha:1.0f];

- (void) setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
{
    [super setBackgroundColorRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    [self setColorToReplaceRed:redComponent green:greenComponent blue:blueComponent];
}
- (void)setColorToReplaceRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 colorToReplace = {redComponent, greenComponent, blueComponent};
    
    [self setVec3:colorToReplace forUniform:colorToReplaceUniform program:filterProgram];
}

- (void)setThresholdSensitivity:(float)newValue;
{
    _thresholdSensitivity = newValue;
    
    [self setFloat:_thresholdSensitivity forUniform:thresholdSensitivityUniform program:filterProgram];
}

- (void) setOpacity:(GLfloat)opacity
{
    _opacity = opacity;
    [self setFloat:_opacity forUniform:opacityUniform program:filterProgram];
}
- (void)setSmoothing:(float)newValue;
{
    _smoothing = newValue;
    
    [self setFloat:_smoothing forUniform:smoothingUniform program:filterProgram];
}

- (void) invert:(BOOL)inverted;
{
    if(!(inverted != _inverted))
    {
    //const CGFloat *componentColors = CGColorGetComponents(oldColor.CGColor);
    
        
//        [self setColorToReplaceRed:(1.0-colorToReplace.one) green:(1.0-colorToReplace.two) blue:(1.0-colorToReplace.three)];
//    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
//                                               green:(1.0 - componentColors[1])
//                                                blue:(1.0 - componentColors[2])
//                                               alpha:componentColors[3]];
    }
    
    
    _inverted = inverted;
//    [self setFloat:(inverted ? 1.0 : 0) forUniform:invertColorUniform program:filterProgram];
    
    
}

- (BOOL) isMysticBlendFilter; { return YES; }

@end

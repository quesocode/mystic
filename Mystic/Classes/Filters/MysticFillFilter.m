//
//  MysticFillFilter.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/17/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticFillFilter.h"
#import "UIColor+Mystic.h"

NSString *const kGPUImageFillVertexShaderString = SHADER_STRING
(
  attribute vec4 position;
  attribute vec4 inputTextureCoordinate;
  
  uniform float texelWidth;
  uniform float texelHeight;
  
  varying vec2 textureCoordinate;
  varying vec2 leftTextureCoordinate;
  varying vec2 rightTextureCoordinate;
  
  varying vec2 topTextureCoordinate;
  varying vec2 topLeftTextureCoordinate;
  varying vec2 topRightTextureCoordinate;
  
  varying vec2 bottomTextureCoordinate;
  varying vec2 bottomLeftTextureCoordinate;
  varying vec2 bottomRightTextureCoordinate;
  
  void main()
  {
      gl_Position = position;
      
      vec2 widthStep = vec2(texelWidth, 0.0);
      vec2 heightStep = vec2(0.0, texelHeight);
      vec2 widthHeightStep = vec2(texelWidth, texelHeight);
      vec2 widthNegativeHeightStep = vec2(texelWidth, -texelHeight);
      
      textureCoordinate = inputTextureCoordinate.xy;
      leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
      rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
      
      topTextureCoordinate = inputTextureCoordinate.xy - heightStep;
      topLeftTextureCoordinate = inputTextureCoordinate.xy - widthHeightStep;
      topRightTextureCoordinate = inputTextureCoordinate.xy + widthNegativeHeightStep;
      
      bottomTextureCoordinate = inputTextureCoordinate.xy + heightStep;
      bottomLeftTextureCoordinate = inputTextureCoordinate.xy - widthNegativeHeightStep;
      bottomRightTextureCoordinate = inputTextureCoordinate.xy + widthHeightStep;
  }
  );


NSString *const kGPUImageFillFragmentShaderString = SHADER_STRING
(
 precision highp float;
 uniform sampler2D inputImageTexture;

 varying highp vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform lowp float tolerance;
 uniform lowp float smoothing;
 uniform mediump vec3 colorToReplace;

 void main()
 {
     lowp vec4 color = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 colorUp = texture2D(inputImageTexture, topTextureCoordinate);
     lowp vec4 colorDown = texture2D(inputImageTexture, bottomTextureCoordinate);
     lowp vec4 colorLeft = texture2D(inputImageTexture, leftTextureCoordinate);
     lowp vec4 colorRight = texture2D(inputImageTexture, rightTextureCoordinate);

     float d = distance(color.rgb, colorToReplace);
     float dU = distance(colorUp.rgb, colorToReplace);
     float dD = distance(colorDown.rgb, colorToReplace);
     float dL = distance(colorLeft.rgb, colorToReplace);
     float dR = distance(colorRight.rgb, colorToReplace);

//     gl_FragColor = vec4(colorToReplace.rgb,1.0);
//
//     gl_FragColor =
//     gl_FragColor = colorRight;

     if(d <= tolerance)
     {
         color = vec4(vec3(d),1.0);
     }
     else if(dU <= tolerance)
     {
         color = vec4(1.0,0.0,0.0,1.0);
     }
     else if(dD <= tolerance)
     {
         color = vec4(0.0,1.0,0.0,1.0);
     }
     else if(dL <= tolerance)
     {
         color = vec4(0.0,0.0,1.0,1.0);
     }
     else if(dR <= tolerance)
     {
         
         color = vec4(0.0,0.0,1.0,1.0);
     }
     else
     {
         color = vec4(1.0,1.0,1.0,1.0);
     }
     gl_FragColor = color;
 }
 );


@implementation MysticFillFilter

@synthesize tolerance = _tolerance;
@synthesize texelWidth = _texelWidth;
@synthesize texelHeight = _texelHeight;

#pragma mark -
#pragma mark Initialization

- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageFillVertexShaderString fragmentShaderFromString:kGPUImageFillFragmentShaderString])) return nil;
    
    toleranceUniform = [filterProgram uniformIndex:@"tolerance"];
    self.tolerance = 0.25;
    smoothingUniform = [filterProgram uniformIndex:@"smoothing"];
    self.smoothing = 0.4;
    colorToReplaceUniform = [filterProgram uniformIndex:@"colorToReplace"];
    
    texelWidthUniform = [filterProgram uniformIndex:@"texelWidth"];
    texelHeightUniform = [filterProgram uniformIndex:@"texelHeight"];
    hasOverriddenImageSizeFactor = NO;

    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setTolerance:(CGFloat)newValue;
{
    _tolerance = newValue;
    [self setFloat:_tolerance forUniform:toleranceUniform program:filterProgram];
}

- (void)setSmoothing:(CGFloat)newValue;
{
    _smoothing = newValue;
    [self setFloat:_smoothing forUniform:smoothingUniform program:filterProgram];
}
- (void) setTargetColor:(UIColor *)targetColor;
{
    if(!targetColor) return;
    [self setVec3:(GPUVector3){targetColor.red, targetColor.green, targetColor.blue} forUniform:colorToReplaceUniform program:filterProgram];
}


- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
//    DLog(@"setup filter size:  %@    %@", b(hasOverriddenImageSizeFactor), s(filterFrameSize));
    if (!hasOverriddenImageSizeFactor)
    {
        _texelWidth = 1.0 / filterFrameSize.width;
        _texelHeight = 1.0 / filterFrameSize.height;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext setActiveShaderProgram:filterProgram];
            if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
            {
                glUniform1f(texelWidthUniform, _texelHeight);
                glUniform1f(texelHeightUniform, _texelWidth);
            }
            else
            {
                glUniform1f(texelWidthUniform, _texelWidth);
                glUniform1f(texelHeightUniform, _texelHeight);
            }
        });
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setTexelWidth:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelWidth = newValue;
    
    [self setFloat:_texelWidth forUniform:texelWidthUniform program:filterProgram];
}

- (void)setTexelHeight:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _texelHeight = newValue;
    
    [self setFloat:_texelHeight forUniform:texelHeightUniform program:filterProgram];
}
@end

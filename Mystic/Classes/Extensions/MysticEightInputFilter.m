//
//  MysticEightInputFilter.m
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticEightInputFilter.h"


NSString *const kMysticEightInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 attribute vec4 inputTextureCoordinate4;
 attribute vec4 inputTextureCoordinate5;
 attribute vec4 inputTextureCoordinate6;
 attribute vec4 inputTextureCoordinate7;
 attribute vec4 inputTextureCoordinate8;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 varying vec2 textureCoordinate4;
 varying vec2 textureCoordinate5;
 varying vec2 textureCoordinate6;
 varying vec2 textureCoordinate7;
 varying vec2 textureCoordinate8;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     textureCoordinate3 = inputTextureCoordinate3.xy;
     textureCoordinate4 = inputTextureCoordinate4.xy;
     textureCoordinate5 = inputTextureCoordinate5.xy;
     textureCoordinate6 = inputTextureCoordinate6.xy;
     textureCoordinate7 = inputTextureCoordinate7.xy;
     textureCoordinate8 = inputTextureCoordinate8.xy;
 }
 );


@implementation MysticEightInputFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kMysticEightInputTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (void)disableFrameCheck8;
{
    eighthFrameCheckDisabled = YES;
}
@end
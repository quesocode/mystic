//
//  MysticEmptyFilter.m
//  Mystic
//
//  Created by Me on 3/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticEmptyFilter.h"

@implementation MysticEmptyFilter

NSString *const kMysticEmptyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = textureColor;
 }
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kMysticEmptyFragmentShaderString]))
    {
		return nil;
    }
    return self;
}



@end

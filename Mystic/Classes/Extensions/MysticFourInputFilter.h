//
//  MysticFourInputFilter.h
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//


#import "MysticThreeInputFilter.h"


extern NSString *const kMysticFourInputTextureVertexShaderString;

@interface MysticFourInputFilter : MysticThreeInputFilter
{
    GPUImageFramebuffer *fourthInputFramebuffer;
    
    GLint filterFourTextureCoordinateAttribute;
    GLint filterInputTextureUniform4;
    GPUImageRotationMode inputRotation4;
    GLuint filterSourceTexture4;
    CMTime fourFrameTime;
    
    BOOL hasSetThirdTexture, hasReceivedFourthFrame, fourthFrameWasVideo;
    BOOL fourthFrameCheckDisabled;
}



- (void)disableFrameCheck4;

@end

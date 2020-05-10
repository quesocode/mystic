//
//  MysticEightInputFilter.h
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSevenInputFilter.h"


extern NSString *const kMysticEightInputTextureVertexShaderString;

@interface MysticEightInputFilter : MysticSevenInputFilter
{
    GPUImageFramebuffer *eighthInputFramebuffer;
    
    GLint filterEightTextureCoordinateAttribute;
    GLint filterInputTextureUniform8;
    GPUImageRotationMode inputRotation8;
    GLuint filterSourceTexture8;
    CMTime eightFrameTime;
    
    BOOL hasSetSeventhTexture, hasReceivedEighthFrame, eighthFrameWasVideo;
    BOOL eighthFrameCheckDisabled;
}



- (void)disableFrameCheck8;

@end

//
//  MysticSevenInputFilter.h
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSixInputFilter.h"


extern NSString *const kMysticSevenInputTextureVertexShaderString;

@interface MysticSevenInputFilter : MysticSixInputFilter
{
    GPUImageFramebuffer *seventhInputFramebuffer;
    
    GLint filterSevenTextureCoordinateAttribute;
    GLint filterInputTextureUniform7;
    GPUImageRotationMode inputRotation7;
    GLuint filterSourceTexture7;
    CMTime sevenFrameTime;
    
    BOOL hasSetSixthTexture, hasReceivedSeventhFrame, seventhFrameWasVideo;
    BOOL seventhFrameCheckDisabled;
}



- (void)disableFrameCheck7;

@end

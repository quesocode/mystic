//
//  MysticThreeInputFilter.h
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTwoInputFilter.h"


extern NSString *const kMysticThreeInputTextureVertexShaderString;

@interface MysticThreeInputFilter : MysticTwoInputFilter
{
    GPUImageFramebuffer *thirdInputFramebuffer;
    
    GLint filterThirdTextureCoordinateAttribute;
    GLint filterInputTextureUniform3;
    GPUImageRotationMode inputRotation3;
    GLuint filterSourceTexture3;
    CMTime thirdFrameTime;
    
    BOOL hasSetSecondTexture, hasReceivedThirdFrame, thirdFrameWasVideo;
    BOOL thirdFrameCheckDisabled;
}

- (void)disableThirdFrameCheck;

- (void)disableFrameCheck3;


@end

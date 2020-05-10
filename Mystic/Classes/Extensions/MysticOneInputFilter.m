//
//  MysticOneInputFilter.m
//  Mystic
//
//  Created by travis weerts on 7/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticOneInputFilter.h"

@implementation MysticOneInputFilter

NSString *const kMysticOneInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kMysticOneInputTextureFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = textureColor;
 }
 );

#pragma mark -
#pragma mark Initialization and teardown

- (id) initWithDefaultShader;
{
    if (!(self = [self initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}



- (void) disableFrameCheck1;
{
    [self disableFirstFrameCheck];
}

- (void)disableFirstFrameCheck;
{
    
}

- (void) resetAllFrameChecks;
{
    
}

- (BOOL) updateFrame:(MysticBlock)completion;
{
    if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0) { if(completion) completion(); return NO; }
    __unsafe_unretained __block MysticImageFilter *weakSelf = self;
    runAsynchronouslyOnVideoProcessingQueue(^{
        if(weakSelf.firstTextureRequiresUpdate) [firstInputFramebuffer lock];
        [weakSelf newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        dispatch_semaphore_signal(imageUpdateSemaphore);
        if (completion != nil) completion();
    });
    
    return YES;
}



@end

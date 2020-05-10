//
//  MysticSevenInputFilter.m
//  Mystic
//
//  Created by travis weerts on 4/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSevenInputFilter.h"


NSString *const kMysticSevenInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 attribute vec4 inputTextureCoordinate4;
 attribute vec4 inputTextureCoordinate5;
 attribute vec4 inputTextureCoordinate6;
 attribute vec4 inputTextureCoordinate7;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 varying vec2 textureCoordinate4;
 varying vec2 textureCoordinate5;
 varying vec2 textureCoordinate6;
 varying vec2 textureCoordinate7;
 
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
 }
 );


@implementation MysticSevenInputFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kMysticSevenInputTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    inputRotation7 = kGPUImageNoRotation;
    
    hasSetSixthTexture = NO;
    
    hasReceivedSeventhFrame = NO;
    seventhFrameWasVideo = NO;
    seventhFrameCheckDisabled = NO;
    
    sixFrameTime = kCMTimeInvalid;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterSevenTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate7"];
        
        filterInputTextureUniform7 = [filterProgram uniformIndex:@"inputImageTexture7"];        glEnableVertexAttribArray(filterSevenTextureCoordinateAttribute);
    });
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate7"];
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        [thirdInputFramebuffer unlock];
        [fourthInputFramebuffer unlock];
        [fifthInputFramebuffer unlock];
        [sixthInputFramebuffer unlock];
        [seventhInputFramebuffer unlock];
        
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [thirdInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform3, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [fourthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform4, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [fifthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform5, 6);
    
    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, [sixthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform6, 7);
    
    glActiveTexture(GL_TEXTURE8);
    glBindTexture(GL_TEXTURE_2D, [seventhInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform7, 8);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    glVertexAttribPointer(filterThirdTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation3]);
    glVertexAttribPointer(filterFourTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation4]);
    glVertexAttribPointer(filterFiveTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation5]);
    glVertexAttribPointer(filterSixTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation6]);
    glVertexAttribPointer(filterSevenTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation7]);
    
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    [thirdInputFramebuffer unlock];
    [fourthInputFramebuffer unlock];
    [fifthInputFramebuffer unlock];
    [sixthInputFramebuffer unlock];
    [seventhInputFramebuffer unlock];
    
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
    if (hasSetSixthTexture)
    {
        return 6;
    }
    else if (hasSetFifthTexture)
    {
        return 5;
    }
    else if (hasSetFourthTexture)
    {
        return 4;
    }
    else if (hasSetThirdTexture)
    {
        return 3;
    }
    else if (hasSetSecondTexture)
    {
        return 2;
    }
    else if (hasSetFirstTexture)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        hasSetFirstTexture = YES;
        [firstInputFramebuffer lock];
    }
    else if (textureIndex == 1)
    {
        secondInputFramebuffer = newInputFramebuffer;
        [secondInputFramebuffer lock];
    }
    else if (textureIndex == 2)
    {
        thirdInputFramebuffer = newInputFramebuffer;
        [thirdInputFramebuffer lock];
    }
    else if (textureIndex == 3)
    {
        fourthInputFramebuffer = newInputFramebuffer;
        [fourthInputFramebuffer lock];
    }
    else if (textureIndex == 4)
    {
        fifthInputFramebuffer = newInputFramebuffer;
        [fifthInputFramebuffer lock];
    }
    else if (textureIndex == 5)
    {
        sixthInputFramebuffer = newInputFramebuffer;
        [sixthInputFramebuffer lock];
    }
    else
    {
        seventhInputFramebuffer = newInputFramebuffer;
        [seventhInputFramebuffer lock];
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
        
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFirstTexture = NO;
        }
    }
    else if (textureIndex == 1)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSecondTexture = NO;
        }
    }
    else if (textureIndex == 2)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetThirdTexture = NO;
        }
    }
    else if (textureIndex == 3)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFourthTexture = NO;
        }
    }
    else if (textureIndex == 4)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFifthTexture = NO;
        }
    }
    else if (textureIndex == 5)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSixthTexture = NO;
        }
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else if (textureIndex == 1)
    {
        inputRotation2 = newInputRotation;
    }
    else if (textureIndex == 2)
    {
        inputRotation3 = newInputRotation;
    }
    else if (textureIndex == 3)
    {
        inputRotation4 = newInputRotation;
    }
    else if (textureIndex == 4)
    {
        inputRotation5 = newInputRotation;
    }
    else if (textureIndex == 5)
    {
        inputRotation6 = newInputRotation;
    }
    else
    {
        inputRotation7 = newInputRotation;
    }
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    GPUImageRotationMode rotationToCheck;
    if (textureIndex == 0)
    {
        rotationToCheck = inputRotation;
    }
    else if (textureIndex == 1)
    {
        rotationToCheck = inputRotation2;
    }
    else if (textureIndex == 2)
    {
        rotationToCheck = inputRotation3;
    }
    else if (textureIndex == 3)
    {
        rotationToCheck = inputRotation4;
    }
    else if (textureIndex == 4)
    {
        rotationToCheck = inputRotation5;
    }
    else if (textureIndex == 5)
    {
        rotationToCheck = inputRotation6;
    }
    else
    {
        rotationToCheck = inputRotation7;
    }
    
    if (GPUImageRotationSwapsWidthAndHeight(rotationToCheck))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    
    
    // You can set up infinite update loops, so this helps to short circuit them
    if (hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame && hasReceivedFifthFrame && hasReceivedSixthFrame && hasReceivedSeventhFrame)
    {
        return;
    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;
    
    if (textureIndex == 0)
    {
        hasReceivedFirstFrame = YES;
        firstFrameTime = frameTime;
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if (CMTIME_IS_INDEFINITE(secondFrameTime))
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 1)
    {
        hasReceivedSecondFrame = YES;
        secondFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 2)
    {
        hasReceivedThirdFrame = YES;
        thirdFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 3)
    {
        hasReceivedFourthFrame = YES;
        fourFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if(textureIndex == 4)
    {
        hasReceivedFifthFrame = YES;
        fiveFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if(textureIndex == 5)
    {
        hasReceivedSixthFrame = YES;
        sixFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if(seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        hasReceivedSeventhFrame = YES;
        sevenFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            
            
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    
    
    
    if ((hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame && hasReceivedFifthFrame && hasReceivedSixthFrame && hasReceivedSeventhFrame) || updatedMovieFrameOppositeStillImage)
    {
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
        
        [self informTargetsAboutNewFrameAtTime:frameTime];
        
        hasReceivedFirstFrame = NO;
        hasReceivedSecondFrame = NO;
        hasReceivedThirdFrame = NO;
        hasReceivedFourthFrame = NO;
        hasReceivedFifthFrame = NO;
        hasReceivedSixthFrame = NO;
        hasReceivedSeventhFrame = NO;
    }
}



- (void)disableFrameCheck7;
{
    seventhFrameCheckDisabled = YES;
}
@end
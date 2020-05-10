//
//  MysticGPUImageSourcePicture.m
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticGPUImageSourcePicture.h"
#import "MysticConstants.h"

@implementation MysticGPUImageSourcePicture

@dynamic targetToIgnoreForUpdates;

- (void) dealloc;
{
   
    [self removeAllTargets];
    [self removeOutputFramebuffer];
}
- (void) processImage;
{
//    DLogDebug(@"source process image");
    [super processImage];
}
//
//- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;
//{
//    BOOL f =  [super processImageWithCompletionHandler:completion];
//    DLog(@"SOURCE <%p> %@: processImageWithCompletionHandler: %@", self, [self class], MBOOL(f));
//
//    return f;
//
//}
/*

- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;
{
    hasProcessedImage = YES;
    
    //    dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_FOREVER);
    
    if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return NO;
    }
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        if (MAX(pixelSizeOfImage.width, pixelSizeOfImage.height) > 1000.0)
        {
            [self conserveMemoryForNextFrame];
        }
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                
                [currentTarget setCurrentlyReceivingMonochromeInput:NO];
                [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
                //            [currentTarget setInputTexture:outputTexture atIndex:textureIndexOfTarget];
                [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
            }
            else
            {
                
            }
        }
        
        dispatch_semaphore_signal(imageUpdateSemaphore);
        
        if (completion != nil) {
            completion();
        }
    });
    
    return YES;
}
 
 */


- (BOOL) updateTargets;
{
    DLog(@"SOURCE MysticGPUImageSourcePicture: updateTargets");
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
       
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            
            [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
        }
        
       
    });
    
    return YES;
}



@end

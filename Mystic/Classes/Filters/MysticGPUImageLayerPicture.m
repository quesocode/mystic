//
//  MysticLayerImagePicture.m
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticGPUImageLayerPicture.h"
#import "MysticConstants.h"


@implementation MysticGPUImageLayerPicture

- (void) dealloc;
{
    [self removeAllTargets];
    [self removeOutputFramebuffer];
}
//- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;
//{
//    BOOL f =  [super processImageWithCompletionHandler:completion];
//    DLog(@"LAYER <%p> %@: processImageWithCompletionHandler: %@", self, [self class], MBOOL(f));
//    
//    return f;
//    
//}

- (void) processImage;
{
//    DLogDebug(@"layer process image");
    [super processImage];
}
- (BOOL) updateTargets;
{
    
    DLog(@"LAYER MysticGPUImageSourcePicture: updateTargets");

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

@implementation MysticGPUImageLayerTexture



@end

@implementation MysticGPUImageLayerTextureMap



@end

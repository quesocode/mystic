//
//  MysticGPUImageView.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticGPUImageView.h"

@implementation MysticGPUImageView


@synthesize shouldIgnoreUpdatesToThisTarget = _shouldIgnoreUpdatesToThisTarget;

//- (void) dealloc;
//{
//    DLog(@"GPUImageView dealloc: <%p>", self);
//    [super dealloc];
//}
- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
    {
		return nil;
    }
    
    [self commonSetup];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (!(self = [super initWithCoder:coder]))
    {
        return nil;
	}
    
    [self commonSetup];
    
	return self;
}

- (void)commonSetup;
{
    _shouldIgnoreUpdatesToThisTarget = NO;
    self.userInteractionEnabled = NO;
    self.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self setBackgroundColorRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
}

- (BOOL) shouldIgnoreUpdatesToThisTarget;
{
    return _shouldIgnoreUpdatesToThisTarget;
}

//- (void) setShouldIgnoreUpdatesToThisTarget:(BOOL)shouldIgnoreUpdatesToThisTarget;
//{
//    BOOL c = _shouldIgnoreUpdatesToThisTarget != shouldIgnoreUpdatesToThisTarget;
//    _shouldIgnoreUpdatesToThisTarget = shouldIgnoreUpdatesToThisTarget;
//    if(c && !_shouldIgnoreUpdatesToThisTarget)
//    {
//        [self newFrameReadyAtTime:kCMTimeIndefinite atIndex:[self nextAvailableTextureIndex]];
//
//    }
//}

//- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
//{
//    if(!_shouldIgnoreUpdatesToThisTarget)
//    {
//        DLog(@"MysticGPUImageView: New frame ready at index: %d", textureIndex);
//        [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
//    }
//    else
//    {
//        DLog(@"MysticGPUImageView: Ignoring updates: %d", textureIndex);
//
//    }
//}
- (void) refresh;
{
    [self newFrameReadyAtTime:kCMTimeIndefinite atIndex:[self nextAvailableTextureIndex]];
}



@end

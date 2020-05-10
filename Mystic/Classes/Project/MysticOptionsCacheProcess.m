//
//  MysticOptionsCacheProcess.m
//  Mystic
//
//  Created by Me on 8/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticOptionsCacheProcess.h"
#import "MysticRenderQueue.h"
#import "MysticOptionsCacheManager.h"
#import "MysticOptions.h"
#import "MysticEffectsManager.h"
#import "MysticRenderOperation.h"
#import "UserPotion.h"

@interface MysticOptionsCacheProcess ()
{
    BOOL _isFinished, _isExecuting, _isCancelled;
}

@end


@implementation MysticOptionsCacheProcess

- (void) dealloc;
{
    [_manager release];
    [_optsManager release];
    [_options release];
    [_image release];
    [_sourceImage release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _index = 1;
        _isExecuting = NO;
        _isCancelled = NO;
        _isFinished = NO;
        
        
    }
    return self;
}
- (BOOL) isConcurrent; { return YES; }

- (BOOL) isFinished;
{
    return _isFinished;
}
- (BOOL) isCancelled;
{
    return _isCancelled;
}
- (BOOL) isExecuting;
{
    return _isExecuting;
}

- (void) cancel;
{

//    [super cancel];

    [self willChangeValueForKey:@"isCancelled"];
    [self willChangeValueForKey:@"isExecuting"];
//    [self willChangeValueForKey:@"isFinished"];
    
    _isCancelled = YES;
    _isExecuting = NO;
    _isFinished = YES;
    
    [self.manager cancelledQueueOperation:self];

    
    [self didChangeValueForKey:@"isCancelled"];
    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
    
    
    
    self.threadPriority = 0.1f;

    
    self.image = nil;
    self.sourceImage = nil;
    self.options = nil;
    self.optsManager = nil;
    self.manager = nil;

}

- (void)finish;
{


    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    if(/* DISABLES CODE */ (YES) || self.image)
    {
        [self.manager finishedQueueOperation:self];
    }
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    self.threadPriority = 0.3f;

    
    
    self.image = nil;
    self.sourceImage = nil;
    self.options = nil;
    self.optsManager = nil;
    self.manager = nil;
    
    
    
}
- (UIImage *) sourceImageForOptions;
{
    return self.sourceImage ? self.sourceImage : self.options.sourceImage ? self.options.sourceImage : nil;
}

- (void) start;
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = YES;
    _isFinished = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    __unsafe_unretained __block  MysticOptionsCacheProcess *weakSelf = self;
    CGSize renderSize = [MysticEffectsManager sizeForSettings:self.options.settings];
    CGSize oRenderSize = renderSize;
    UIImage *rimg = self.sourceImageForOptions ? self.sourceImageForOptions : nil;
    
    if(CGSizeEqualToSize(CGSizeZero, renderSize))
    {
//        ALLog(@"Render Size Error: 0 x 0 is not acceptable rendersize", @[
//                                                                          @"rimg", ILogStr(rimg),
//                                                                          @"sizeForSettings", SLogStr(oRenderSize),
//                                                                          @"options size", self.options ? SLogStr(self.options.size) : @"---",
//                                                                          @"options", MObj(self.options),
//                                                                          
//                                                                          ]);
        
        renderSize = !CGSizeEqualToSize(CGSizeZero, self.options.size) ? self.options.size : rimg ? [MysticImage sizeInPixels:rimg] : renderSize;
    }
    
    id rimg2 = nil;
    
    if(!rimg)
    {
       
        rimg = self.options.sourceImage ? self.options.sourceImage : [[UserPotion potion] imageForRenderSize:renderSize];
        
        rimg2 = rimg ? @"==rimg" : ILogStr([UserPotion potion].sourceImage);
        
        rimg = rimg ? rimg : [UserPotion potion].sourceImage;

        
        
    }
    
    if(rimg && CGSizeEqualToSize(CGSizeZero, renderSize))
    {
        renderSize = [MysticImage sizeInPixels:rimg];
    }
    
//    ALLog(@"cacheProcess Render",          @[@"options", self.options,
//                                             @"sourceImage", ILogStr(self.sourceImage),
//                                             @"options source", ILogStr(self.options.sourceImage),
//                                             @"rimg1", ILogStr(rimg),
//                                             @"rimg2", MObj(rimg2),
//                                             @"render size for settings", SLogStr(oRenderSize),
//                                             @"render size", SLogStr(renderSize),
//                                             ]);
    
    self.options.size = renderSize;
    
    
    
    MysticOptions *newOptions = self.options;


    self.image = weakSelf.options.currentRenderedImage;
    
    
    
//    ALLog(@"Saving rendered Options cache image:", @[@"options", self.options.tag,
//                                                     @"img", ILogStr(self.image),
//                                                     ]);

    [weakSelf finish];

}
@end

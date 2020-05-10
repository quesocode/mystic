//
//  MysticLayerRenderProcess.m
//  Mystic
//
//  Created by Me on 9/26/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerRenderProcess.h"



@interface MysticLayerRenderProcess ()
{
    BOOL _isFinished, _isExecuting, _isCancelled;
}

@end


@implementation MysticLayerRenderProcess

- (void) dealloc;
{
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
    self.threadPriority = 0.1f;
    
    [self willChangeValueForKey:@"isCancelled"];
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isCancelled = YES;
    _isExecuting = NO;
    _isFinished = YES;
    
    
    
    [self didChangeValueForKey:@"isCancelled"];
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    
    
    self.manager = nil;
    
}

- (void)finish;
{
    
    self.threadPriority = 0.3f;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    

    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    
    self.manager = nil;
    
    
    
}

- (void) start;
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = YES;
    _isFinished = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    __unsafe_unretained __block  MysticLayerRenderProcess *weakSelf = self;
    
    
    [weakSelf finish];
    
}




@end

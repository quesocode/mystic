//
//  MysticRefreshOperation.m
//  Mystic
//
//  Created by Me on 8/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticRefreshOperation.h"
#import "MysticRenderQueue.h"
#import "MysticOptionsCacheManager.h"
#import "MysticOptions.h"
#import "MysticEffectsManager.h"
#import "MysticRenderOperation.h"
#import "UserPotion.h"

@interface MysticRefreshOperation ()
{
    BOOL _isFinished, _isExecuting;
}

@end


@implementation MysticRefreshOperation

- (void) dealloc;
{
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
        
    }
    return self;
}
- (BOOL) isConcurrent; { return YES; }


- (void) cancel;
{
    
    [super cancel];
    
    self.threadPriority = 0.1f;
    
}

- (void)finish;
{
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    
    self.threadPriority = 0.3f;
    
    if([self isCancelled]) return;
    
    
}
- (UIImage *) sourceImageForOptions;
{
    return self.sourceImage;
}

- (void) start;
{
    __unsafe_unretained __block  MysticRefreshOperation *weakSelf = self;
    
    
    
}
@end


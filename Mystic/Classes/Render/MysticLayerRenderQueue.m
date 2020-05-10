//
//  MysticLayerRenderQueue.m
//  Mystic
//
//  Created by Me on 9/26/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerRenderQueue.h"

@implementation MysticLayerRenderQueue


+ (MysticLayerRenderQueue *) sharedQueue;
{
    static dispatch_once_t once;
    static id instanceQue;
    dispatch_once(&once, ^{
        instanceQue = self.new;
    });
    return instanceQue;
}

- (void) dealloc;
{
    [super dealloc];
}
@end


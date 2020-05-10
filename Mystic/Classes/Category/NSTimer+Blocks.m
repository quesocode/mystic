//
//  NSTimer+Blocks.m
//
//  Created by Jiva DeVoe on 1/14/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import "NSTimer+Blocks.h"

@implementation NSTimer (Blocks)



+(id)wait:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:inTimeInterval
                                                      target:[NSBlockOperation blockOperationWithBlock:inBlock]
                                                    selector:@selector(main)
                                                    userInfo:nil
                                                     repeats:NO
                      ];
    return timer;
}

+(id)repeat:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:inTimeInterval
                                                      target:[NSBlockOperation blockOperationWithBlock:inBlock]
                                                    selector:@selector(main)
                                                    userInfo:nil
                                                     repeats:YES
                      ];
    return timer;
}

@end

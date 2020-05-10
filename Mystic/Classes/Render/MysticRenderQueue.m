//
//  MysticRenderQueue.m
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticRenderQueue.h"
#import "MysticConstants.h"


@interface MysticRenderQueue ()

@end

@implementation MysticRenderQueue


+ (MysticRenderQueue *) sharedQueue;
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

@interface MysticRenderProcessQueue ()

@end

@implementation MysticRenderProcessQueue

+ (MysticRenderProcessQueue *) sharedQueue;
{
    static dispatch_once_t once2;
    static MysticRenderProcessQueue *instanceQue2;
    dispatch_once(&once2, ^{
        instanceQue2 = self.new;
        if(usingIOS8())
        {
            instanceQue2.qualityOfService = NSOperationQualityOfServiceUserInitiated;
        }
    });
    return instanceQue2;
}

@end



@interface MysticRefreshProcessQueue ()

@end

@implementation MysticRefreshProcessQueue

+ (MysticRefreshProcessQueue *) sharedQueue;
{
    static dispatch_once_t once2;
    static MysticRefreshProcessQueue *instanceQue2;
    dispatch_once(&once2, ^{
        instanceQue2 = self.new;
        if(usingIOS8()) instanceQue2.qualityOfService = NSOperationQualityOfServiceUserInteractive;
    });
    return instanceQue2;
//    return [[self class] mainQueue];
}

@end

@interface MysticOptionsCacheManagerProcessQueue ()

@end

@implementation MysticOptionsCacheManagerProcessQueue

+ (MysticOptionsCacheManagerProcessQueue *) sharedQueue;
{
    static dispatch_once_t once2;
    static id instanceQue2;
    dispatch_once(&once2, ^{
        instanceQue2 = self.new;
    });
    return instanceQue2;
}

@end
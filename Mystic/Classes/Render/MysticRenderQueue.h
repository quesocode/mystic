//
//  MysticRenderQueue.h
//  Mystic
//
//  Created by travis weerts on 9/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MysticRenderQueue : NSOperationQueue


+ (MysticRenderQueue *) sharedQueue;

@end


@interface MysticRenderProcessQueue : NSOperationQueue
+ (MysticRenderProcessQueue *) sharedQueue;

@end

@interface MysticOptionsCacheManagerProcessQueue : NSOperationQueue
+ (MysticOptionsCacheManagerProcessQueue *) sharedQueue;

@end

@interface MysticRefreshProcessQueue : NSOperationQueue
+ (MysticRefreshProcessQueue *) sharedQueue;

@end
//
//  MysticLayerRenderQueue.h
//  Mystic
//
//  Created by Me on 9/26/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticLayerRenderProcess.h"

@interface MysticLayerRenderQueue : NSOperationQueue


+ (MysticLayerRenderQueue *) sharedQueue;



@end

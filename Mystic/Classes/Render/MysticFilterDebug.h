//
//  MysticFilter.h
//  Mystic
//
//  Created by Me on 11/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticFilterManager.h"

@interface MysticFilterDebug : NSObject

+ (NSString *) logTargets:(id)outputObj depth:(int)d;
+ (NSString *) logSubTargets:(GPUImageOutput <GPUImageInput>*)output depth:(int)d;

+ (NSString *) debugDescription:(MysticFilterManager *)manager;
+ (NSString *) layerDebugDescription:(MysticFilterLayer *)layer;


@end

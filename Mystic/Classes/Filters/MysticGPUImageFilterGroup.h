//
//  MysticGPUImageFilterGroup.h
//  Mystic
//
//  Created by Travis A. Weerts on 2/26/17.
//  Copyright © 2017 Blackpulp. All rights reserved.
//

#import "GPUImage.h"

@interface MysticGPUImageFilterGroup : GPUImageFilterGroup
@property (nonatomic, readonly) NSArray *allFilters;
- (void) removeAllFilters;
@end

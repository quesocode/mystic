//
//  MysticGPUImageSourcePicture.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "GPUImagePicture.h"

@interface MysticGPUImageSourcePicture : GPUImagePicture

@property(readwrite, nonatomic, unsafe_unretained) id<GPUImageInput> targetToIgnoreForUpdates;
- (BOOL) updateTargets;

@end

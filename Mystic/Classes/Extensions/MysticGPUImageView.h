//
//  MysticGPUImageView.h
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "GPUImageView.h"
#import "MysticConstants.h"

@interface MysticGPUImageView : GPUImageView


@property(readwrite, nonatomic) BOOL shouldIgnoreUpdatesToThisTarget;

- (void) refresh;


@end

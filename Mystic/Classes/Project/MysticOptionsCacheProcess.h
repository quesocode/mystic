//
//  MysticOptionsCacheProcess.h
//  Mystic
//
//  Created by Me on 8/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MysticOptions, MysticOptionsCacheManager, MysticOptionsManager;


@interface MysticOptionsCacheProcess : NSOperation
@property (nonatomic, assign) int index;
@property (nonatomic, retain) UIImage *image, *sourceImage;
@property (nonatomic, retain) MysticOptions *options;
@property (nonatomic, retain) MysticOptionsManager *optsManager;

@property (nonatomic, retain) MysticOptionsCacheManager *manager;
@end

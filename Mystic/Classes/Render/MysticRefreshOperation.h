//
//  MysticRefreshOperation.h
//  Mystic
//
//  Created by Me on 8/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MysticOptions;

@interface MysticRefreshOperation : NSOperation
@property (nonatomic, assign) int index;
@property (nonatomic, retain) UIImage *image, *sourceImage;
@property (nonatomic, retain) MysticOptions *options;

@end

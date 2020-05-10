//
//  MysticShareItem.h
//  Mystic
//
//  Created by Travis A. Weerts on 8/23/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MysticShareItem : NSObject <UIActivityItemSource>

@property (nonatomic, retain) UIImage *image, *thumbnail;
@property (nonatomic, retain) NSString *subject;
+ (id) itemWithImage:(UIImage *)img subject:(NSString *)subject;


@end

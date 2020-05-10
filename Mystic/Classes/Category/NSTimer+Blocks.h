//
//  NSTimer+Blocks.h
//
//  Created by Jiva DeVoe on 1/14/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Blocks)

+(id)wait:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock;
+(id)repeat:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock;
@end

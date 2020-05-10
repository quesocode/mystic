//
//  NSArray+Mystic.h
//  Mystic
//
//  Created by travis weerts on 1/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticTypedefs.h"

typedef NSString *(^MysticBlockArrayString)(id obj);

@interface NSArray (Mystic)
- (NSArray *)reversedArray;
- (NSArray *)shuffledArray;
- (NSArray *)shuffledArrayWithItemLimit:(NSUInteger)itemLimit;
- (id) objectAtRandomIndex;
- (NSDictionary *) objectAtRandomIndexExcept:(NSInteger)i;
- (NSString *) enumerateDescription:(MysticBlockArrayString)block;
- (BOOL) containsString:(NSString *)string;
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationFinished)complete;
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlock)animations completion:(MysticBlockAnimationFinished)complete;
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationFinished)complete;
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlock)animations completion:(MysticBlockAnimationFinished)complete;

- (NSMutableArray *) makeMutable;

@end

@interface NSMutableArray (Mystic)
- (void)reverse;
@end
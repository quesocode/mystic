//
//  NSArray+Mystic.m
//  Mystic
//
//  Created by travis weerts on 1/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#include <stdlib.h>
#import "NSArray+Mystic.h"
#import "MysticConstants.h"
#import "UIView+Mystic.h"
#import "NSDictionary+Merge.h"

@implementation NSArray (Mystic)

- (NSMutableArray *) makeMutable;
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self];
    for (int i = 0; i<newArray.count; i++) {
        id obj = [newArray objectAtIndex:i];
        if([obj isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *newObj = [(NSDictionary *)obj makeMutable];
            [newArray replaceObjectAtIndex:i withObject:newObj];
        }
        else if([obj isKindOfClass:[NSArray class]])
        {
            NSMutableArray *newObj = [(NSArray *)obj makeMutable];
            [newArray replaceObjectAtIndex:i withObject:newObj];
        }
    }
    return newArray;
}
- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationFinished)complete;
{
    [self fadeOut:duration delay:delay animations:nil completion:complete];

}
- (void) fadeOut:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlock)animations completion:(MysticBlockAnimationFinished)complete;
{
    [MysticUIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        for (UIView *view in self) {
            if(view.alpha != 0 && !view.hidden) view.alpha = 0;
        }
        if(animations) animations();
    } completion:complete];
}
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(MysticBlockAnimationFinished)complete;
{
    [self fadeIn:duration delay:delay animations:nil completion:complete];
}
- (void) fadeIn:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(MysticBlock)animations completion:(MysticBlockAnimationFinished)complete;
{
    [MysticUIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        for (UIView *view in self) {
            if(view.alpha != 1 && !view.hidden)  view.alpha = 1;
        }
        if(animations) animations();

    } completion:complete];
}
- (NSDictionary *) objectAtRandomIndexExcept:(NSInteger)i;
{
    int r = 0;
    int c = self.count;
    
    if(!(i == 0 && c == 1))
    {

//        r = c+1;
        r = i;
        while(r == i)
        {
            if (&arc4random_uniform != NULL)
            {
                r = arc4random_uniform (c);
            }
//            else
//            {
//                r = (arc4random() % c);
//            }
            r = MIN(self.count - 1, r);
            r = MAX(0, r);
            
            
       

        }
    }
    int r2 = MIN(self.count - 1, r);
    r2 = MAX(0, r2);
 
    
    return @{@"index":@(r2), @"value": self.count > r2 ?  [self objectAtIndex:r2] : [NSNull null]};
}
- (id) objectAtRandomIndex;
{
    int r = 0;
    int c = self.count;
    if (&arc4random_uniform != NULL)
        r = arc4random_uniform (c);
//    else
//        r = (arc4random() % c);
    
    return [self objectAtIndex:r];
}

- (NSString *) enumerateDescription:(MysticBlockArrayString)block;
{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    for (id obj in self) {
        NSString *s = block(obj);
        [str appendFormat:@"\n%@", s ? s : @"---"];
    }
    
    return str;
}

- (NSArray *)shuffledArray;
{
    NSMutableArray *shuffledArray = [[self mutableCopy] autorelease];
    NSUInteger arrayCount = [shuffledArray count];
    
    for (NSUInteger i = arrayCount - 1; i > 0; i--) {
        NSUInteger n = arc4random_uniform(i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [[shuffledArray copy] autorelease];
}

- (NSArray *)shuffledArrayWithItemLimit:(NSUInteger)itemLimit;
{
    if (!itemLimit) return [self shuffledArray];
    
    NSMutableArray *shuffledArray = [[self mutableCopy] autorelease];
    NSUInteger arrayCount = [shuffledArray count];
    
    NSUInteger loopCounter = 0;
    for (NSUInteger i = arrayCount - 1; i > 0 && loopCounter < itemLimit; i--) {
        NSUInteger n = arc4random_uniform(i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
        loopCounter++;
    }
    
    NSArray *arrayWithLimit;
    if (arrayCount > itemLimit) {
        NSRange arraySlice = NSMakeRange(arrayCount - loopCounter, loopCounter);
        arrayWithLimit = [shuffledArray subarrayWithRange:arraySlice];
    } else
        arrayWithLimit = [[shuffledArray copy] autorelease];
    
    return arrayWithLimit;
}

- (BOOL) containsString:(NSString *)string;
{
    for (NSInteger i = 0; i<self.count; i++) {
        NSString *s = [self objectAtIndex:i];
        if([s isKindOfClass:[NSString class]] && [s isEqualToString:string]) return YES;
    }
    return NO;
}

@end

@implementation NSMutableArray (Mystic)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

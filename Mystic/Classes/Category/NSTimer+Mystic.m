//
//  NSTimer+Mystic.m
//  Mystic
//
//  Created by travis weerts on 9/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NSTimer+Mystic.h"
#import "MysticConstants.h"

@implementation NSTimer (Mystic)

static NSDate *startTime = nil;
static NSDate *lastTime = nil;

+ (NSDate *) start;
{
    [lastTime release], lastTime=nil;
    [startTime release]; startTime = nil;
    NSDate *time = [NSDate date];
    startTime = [time retain];
    lastTime = [time retain];
    return startTime;
}
+ (NSTimeInterval) stamp;
{
    NSDate *stampTime = [NSDate date];
    
    NSTimeInterval executionTime = [stampTime timeIntervalSinceDate:lastTime];
    
    [lastTime release], lastTime=nil;
    lastTime = [stampTime retain];
    
    return executionTime;
}
+ (NSTimeInterval) stamp:(NSString *)format;
{
    NSTimeInterval ex = [NSTimer stamp];
    
    DLog(@"%@: %2.3f", format, ex);
    
    return ex;
}
+ (NSTimeInterval) sinceStart:(NSString *)format;
{
    NSDate *stampTime = [NSDate date];
    
    NSTimeInterval ex = [stampTime timeIntervalSinceDate:startTime];
    
    DLog(@"%@: %2.3f", format, ex);
    
    return ex;
}
+ (NSTimeInterval) sinceLast;
{
    NSDate *stampTime = [NSDate date];
    
    NSTimeInterval executionTime = [stampTime timeIntervalSinceDate:lastTime];
    
    [lastTime release], lastTime=nil;
    lastTime = [stampTime retain];
    
    return executionTime;
}
+ (NSTimeInterval) sinceLast:(NSString *)format;
{
    NSTimeInterval ex = [NSTimer sinceLast];
    
    DLog(@"%@: %2.3f", format, ex);
    
    return ex;
}
+ (NSTimeInterval) end;
{
    NSDate *stampTime = [NSDate date];
    NSTimeInterval executionTime = [stampTime timeIntervalSinceDate:startTime];
    [startTime release]; startTime = nil;
    [lastTime release], lastTime=nil;
    return executionTime;
}
+ (NSTimeInterval) end:(NSString *)format;
{
    NSTimeInterval ex = [NSTimer end];
    
    DLog(@"END %@: %2.3f", format, ex);
    
    return ex;
}
@end

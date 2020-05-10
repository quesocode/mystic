//
//  NSObject+Mystic.m
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NSObject+Mystic.h"

@implementation NSObject (Mystic)

- (void *)performSelector:(SEL)selector value:(void *)value {
    NSMethodSignature *methodSig = [self methodSignatureForSelector:selector];
    if(methodSig == nil)
    {
        return NULL;
    }
    
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    if(value != nil) [invocation setArgument:value atIndex:2];
    
    [invocation invoke];
    
    NSUInteger length = [[invocation methodSignature] methodReturnLength];
    
    // If method is non-void:
    if (length > 0) {
        void *buffer = (void *)malloc(length);
        [invocation getReturnValue:buffer];
        return buffer;
    }
    
    // If method is void:
    return NULL;
}
- (void *)performValueSelector:(SEL)selector;
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    
    [invocation invoke];
    
    NSUInteger length = [[invocation methodSignature] methodReturnLength];
    
    // If method is non-void:
    if (length > 0) {
        void *buffer = (void *)malloc(length);
        [invocation getReturnValue:buffer];
        return buffer;
    }
    
    // If method is void:
    return NULL;
}
@end

//
//  MysticLog.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/8/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticLog.h"
#import "NSString+Mystic.h"

@implementation MysticLog

+ (void) answer:(NSString *)name type:(NSString *)type tag:(NSString *)tagId info:(NSDictionary *) info;
{
#ifndef DEBUG
    [Answers logContentViewWithName:name contentType:type contentId:tagId customAttributes:info];
#else
#ifdef DEBUG_FABRIC
    [Answers logContentViewWithName:name contentType:type contentId:tagId customAttributes:info];
#endif
#endif
}
+ (void) answer:(NSString *)name info:(NSDictionary *) info;
{
#ifndef DEBUG
    [Answers logCustomEventWithName:name customAttributes:info];
#else
#ifdef DEBUG_FABRIC
    [Answers logCustomEventWithName:name customAttributes:info];
#endif
#endif
}
+ (void) error:(NSString *)title info:(NSDictionary *) info;
{
    [self answer:[title prefix:@"Error-"] info:info];

}


@end

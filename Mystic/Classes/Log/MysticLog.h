//
//  MysticLog.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/8/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>
#import "MysticUtility.h"

@interface MysticLog : NSObject

+ (void) answer:(NSString *)name info:(NSDictionary *) info;
+ (void) error:(NSString *)name info:(NSDictionary *) info;
+ (void) answer:(NSString *)name type:(NSString *)type tag:(NSString *)tagId info:(NSDictionary *) info;

@end

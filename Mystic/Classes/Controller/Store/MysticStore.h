//
//  MysticStore.h
//  Mystic
//
//  Created by Travis A. Weerts on 7/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MysticStore : NSObject

+ (BOOL) hasPurchased:(NSString *)productId;
+ (NSDictionary *) product:(NSString *)productId;

@end

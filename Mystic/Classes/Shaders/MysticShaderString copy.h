//
//  MysticShaderString.h
//  Mystic
//
//  Created by travis weerts on 7/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "MysticShaderConstants.h"

@class MysticOptions;

@interface MysticShaderString : NSObject

+ (NSDictionary *) shaderString;
+ (NSDictionary *) shaderString:(MysticOptions *)effects;
+ (NSString *) outputString:(NSString *)shaderStr;

@end

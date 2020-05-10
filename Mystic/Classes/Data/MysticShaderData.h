//
//  MysticShaderData.h
//  Mystic
//
//  Created by Me on 10/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDictionaryDataSource.h"
#import "MysticConstants.h"
#import "MysticShaderInfo.h"

@interface MysticShaderData : MysticDictionaryDataSource

+ (NSString *)function:(id)key;
+ (NSString *)constant:(id)key;
+ (NSString *)blend:(id)key;
+ (NSString *)uniform:(id)key;

+ (id) lookupShaderString:(id)keyPath;
+ (id) lookupFunction:(id)keyPath;
+ (id) lookupBlend:(id)keyPath;
+ (id) lookupConstant:(id)keyPath;
+ (id) lookupUniform:(id)keyPath;

+ (id) lookup:(id)keyPath;
+ (id) lookup:(id)keyPath option:(PackPotionOption *)option;

+ (NSString *) settingToKey:(id)aKey;
+ (NSString *) blendKey:(id)aKey;

@end



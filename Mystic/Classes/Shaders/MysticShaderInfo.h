//
//  MysticShaderInfo.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/20/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticConstants.h"
#import "MysticShaderData.h"


@interface MysticShaderInfo : NSObject
@property (nonatomic, assign) MysticObjectType type;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSMutableArray *constants, *uniforms, *functions;
@property (nonatomic, retain) NSString *blend, *function, *line, *prefix, *suffix, *header, *footer, *uniform, *blendFunction;

+ (id) info:(id)info forKey:(NSString *)keyPath;
+ (id) info:(id)info forKey:(NSString *)keyPath option:(PackPotionOption *)option;
+ (void) processTemplates:(BOOL)process;

@end
//
//  MysticShader.h
//  Mystic
//
//  Created by Me on 10/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticShaderConstants.h"
#import "MysticShaderStringOption.h"
#import "MysticShadersObject.h"

@interface MysticShader : MysticShaderStringOption


+ (instancetype) shader;
+ (instancetype) shader:(BOOL)processTemplates;
+ (instancetype) shaderWithOptions:(MysticOptions *)options;
+ (instancetype) shaderWithOptions:(MysticOptions *)options processTemplates:(BOOL)process;

+ (void) setShader:(MysticShader *)shader;

- (instancetype) initWithOptions:(MysticOptions *)options;
- (instancetype) initWithOptions:(MysticOptions *)options processTemplates:(BOOL)process;

+ (NSString *) outputString:(NSString *)shaderStr;
+ (BOOL) has:(id)settingKey forOption:(PackPotionOption *)option;
+ (BOOL) shaderFileIsNewer;

@end

//
//  MysticShaderStringSettings.h
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PackPotionOption;

@interface MysticShaderStringSettings : NSObject

@property (nonatomic, retain) NSMutableArray *headers;
@property (nonatomic, retain) NSMutableArray *prefixValues, *functions, *components, *uniforms;
@property (nonatomic, retain) NSMutableDictionary *prefixes;
@property (nonatomic, assign) BOOL controlsOutput;

+ (id) settingsShaderForOption:(PackPotionOption *)option controlOutput:(BOOL)shouldControl;
@end

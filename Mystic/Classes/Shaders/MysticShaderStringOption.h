//
//  MysticShaderStringOption.h
//  Mystic
//
//  Created by Me on 10/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticShaderConstants.h"
#import "MysticShaderData.h"


typedef enum
{
    MysticShaderPositionAuto = 0,
    MysticShaderPositionUniform,
    MysticShaderPositionConstant,
    MysticShaderPositionFunction,
    MysticShaderPositionHeader,
    MysticShaderPositionLine,
    MysticShaderPositionFooter,
    MysticShaderPositionPrefix,
    MysticShaderPositionSuffix,
    
} MysticShaderPosition;


@class PackPotionOption;

@interface MysticShaderStringOption : MysticShaderData

@property (nonatomic, readonly) NSString *prettyOutput;
@property (nonatomic, retain) NSMutableDictionary *headers, *functions, *uniforms, *prefixes, *footers, *suffixes, *mains, *vertexHeaders, *vertexFooters, *constants;
@property (nonatomic, assign) MysticShaderIndex index;
@property (nonatomic, retain) NSString *shader;
@property (nonatomic, retain) NSString *vertex;
@property (nonatomic, retain) NSString *mainTemplate;
@property (nonatomic, readonly) NSMutableArray *lines;
@property (nonatomic, readonly) NSArray *allKeys;
@property (nonatomic, retain) NSMutableArray *components, *lineKeys;
@property (nonatomic, assign) BOOL controlsOutput;

@property (nonatomic, retain) NSMutableArray *orderOfConstants;
@property (nonatomic, retain) NSMutableArray *orderOfMains;
@property (nonatomic, retain) NSMutableArray *orderOfPrefixes;
@property (nonatomic, retain) NSMutableArray *orderOfSuffixes;
@property (nonatomic, retain) NSMutableArray *orderOfFunctions;
@property (nonatomic, retain) NSMutableArray *orderOfHeaders;
@property (nonatomic, retain) NSMutableArray *orderOfFooters;
@property (nonatomic, retain) NSMutableArray *orderOfUniforms;
@property (nonatomic, retain) NSMutableArray *orderOfVertexHeaders;
@property (nonatomic, retain) NSMutableArray *orderOfVertexFooters;
@property (nonatomic, assign) BOOL processTemplates;


+ (id) shaderForOption:(PackPotionOption *)option controlOutput:(BOOL)shouldControl index:(MysticShaderIndex)index;
+ (id) shaderForOption:(PackPotionOption *)option index:(MysticShaderIndex)index;
+ (id) shaderForOption:(PackPotionOption *)option index:(MysticShaderIndex)index processTemplates:(BOOL)shouldProcess;

+ (NSString *) template:(NSString *)template index:(MysticShaderIndex)index process:(BOOL)shouldProcess;

- (BOOL) has:(id)settingKey forOption:(PackPotionOption *)option;

- (BOOL) add:(id)itemKey option:(PackPotionOption *)option key:(NSString *)path;
- (void) addShaderInfo:(MysticShaderInfo *)n itemKey:(id)itemKey option:(PackPotionOption *)option;

- (void) commonInit;

- (id) addBlend:(id)optionOrBlendType;
- (id) addBlend:(id)optionOrBlendType position:(MysticShaderPosition)position index:(MysticShaderIndex)index;

- (void) addLine:(NSString *)value;
- (void) addLine:(NSString *)value position:(MysticShaderPosition)position index:(MysticShaderIndex)index;
- (void) addLine:(NSString *)value key:(id)key position:(MysticShaderPosition)position index:(MysticShaderIndex)index;
- (void) addLine:(NSString *)value key:(id)key;
- (void) addHeader:(id)key value:(id)value;
- (void) addFooter:(id)key value:(id)value;
- (void) addPrefix:(id)key value:(id)value;
- (void) addFunction:(id)key value:(id)value;
- (void) addUniform:(id)key value:(id)value;
- (void) addSuffix:(id)key value:(id)value;
- (void) addMain:(id)key value:(id)value;
- (void) addConstant:(id)key value:(id)value;

- (void) addMains:(NSDictionary *)values;
- (void) addFunctions:(NSDictionary *)values;
- (void) addPrefixes:(NSDictionary *)values;
- (void) addFooters:(NSDictionary *)values;
- (void) addHeaders:(NSDictionary *)values;
- (void) addUniforms:(NSDictionary *)values;
- (void) addSuffixes:(NSDictionary *)values;
- (void) addConstants:(NSDictionary *)values;

- (void) addLines:(NSArray *)values;

- (void) insertLine:(id)value atIndex:(NSInteger)i;
- (void) insertMain:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertPrefix:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertSuffix:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertUniform:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertHeader:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertFooter:(id)key value:(id)value atIndex:(NSInteger)i;
- (void) insertFunction:(id)key value:(id)value atIndex:(NSInteger)i;
- (NSString *) compileMains;

- (void) addVertexHeader:(id)key value:(id)value;
- (void) addVertexFooter:(id)key value:(id)value;
- (void) addVertexFooters:(NSDictionary *)values;
- (void) addVertexHeaders:(NSDictionary *)values;
@end

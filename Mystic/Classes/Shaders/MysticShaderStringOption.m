//
//  MysticShaderStringOption.m
//  Mystic
//
//  Created by Me on 10/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticShaderStringOption.h"

#import "PackPotionOption.h"
#import "MysticShaderConstants.h"
#import "MysticFilterLayer.h"

@interface MysticShaderStringOption ()
{
    MysticShaderIndex _tempIndex;
}
@property (nonatomic, retain) PackPotionOption *option;
@property (nonatomic, assign) MysticShaderPosition linePosition;
@end

@implementation MysticShaderStringOption

+ (id) shaderForOption:(PackPotionOption *)option controlOutput:(BOOL)shouldControl index:(MysticShaderIndex)index;
{
    MysticShaderStringOption *shader = [[self class] shaderForOption:option index:index];
    shader.controlsOutput = shouldControl;
    return shader;
}
+ (id) shaderForOption:(PackPotionOption *)option index:(MysticShaderIndex)index;
{
    return [self shaderForOption:option index:index processTemplates:YES];
}
+ (id) shaderForOption:(PackPotionOption *)option index:(MysticShaderIndex)index processTemplates:(BOOL)should;
{
    MysticShaderStringOption *shader = [[[self class] alloc] init];
    shader.index = index;
    shader.processTemplates=should;
    [shader shadersForOption:option];
    return [shader autorelease];
}

+ (NSString *) template:(NSString *)template index:(MysticShaderIndex)index process:(BOOL)shouldProcess;
{
    
    template = isMEmpty(template) ? MysticShaderMainsTemplate : template;
    
    index = MysticShaderIndexClean(index);
    if(!shouldProcess) return template;
    
    NSDictionary *vars = @{
                           @"%%stackTexturePreviousCoordinate%%": index.previousIndex<=1 ? @"textureCoordinate" : [NSString stringWithFormat:@"textureCoordinate%d", (int)index.previousIndex],
                           @"%%textureCoordinate%%": index.stackIndex==1 ? @"textureCoordinate" : [NSString stringWithFormat:@"textureCoordinate%d", (int)index.index],
                           @"%%stackTextureCoordinate%%": index.stackIndex==1 ? @"textureCoordinate" : [NSString stringWithFormat:@"textureCoordinate%d", (int)index.stackIndex],
                           @"%%inputIndex%%": [NSString stringWithFormat:@"%d", (int)index.index],
                           @"%%inputStackIndex%%": index.stackIndex==1 ?  @"" : [NSString stringWithFormat:@"%d", (int)index.stackIndex],
                           @"$i": [NSString stringWithFormat:@"%d", (int)index.stackIndex],
                           @"$i1": [NSString stringWithFormat:@"%d", (int)index.stackIndex-1],
                           
                           @"%%index%%": [NSString stringWithFormat:@"%d", (int)index.count],
                           @"%%previousTextureColor%%": index.previousIndex <= 0 ? @"outputColor" : [NSString stringWithFormat:@"textureColor%d", (int)index.previousIndex],
                           @"%%textureColor%%": index.stackIndex == 1 ? @"outputColor" : [NSString stringWithFormat:@"textureColor%d", (int)index.index],
                           @"%%textureColorIndex%%": [NSString stringWithFormat:@"textureColor%d", (int)index.index],
                           @"%%inputTexture%%": index.stackIndex == 1 ? @"inputImageTexture" : [NSString stringWithFormat:@"inputImageTexture%d", (int)index.index],
                           };
    
    NSMutableString *str = [NSMutableString stringWithString:template];
    for (NSString *tpl in vars.allKeys) [str replaceOccurrencesOfString:tpl withString:vars[tpl] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    
    
    return [NSString stringWithString:str];
    
}


@synthesize functions=_functions, prefixes=_prefixes, components=_components, uniforms=_uniforms, controlsOutput=_controlsOutput, headers=_headers, footers=_footers, suffixes=_suffixes;

- (void) dealloc;
{
    [_option release];
    [_components removeAllObjects];
    [_components release];
    [_headers release];
    [_suffixes release];
    [_prefixes release];
    [_uniforms release];
    [_footers release];
    [_functions release];
    [_constants release];
    [_mains release];

    [_orderOfUniforms release];
    [_orderOfFooters release];
    [_orderOfFunctions release];
    [_orderOfHeaders release];
    [_orderOfPrefixes release];
    [_orderOfSuffixes release];
    [_orderOfVertexFooters release];
    [_orderOfVertexHeaders release];
    [_orderOfConstants release];
    [_orderOfMains release];
    [_lineKeys release];
    
    
    [_mainTemplate release];
    [_vertexFooters release];
    [_vertexHeaders release];

    [_shader release];
    [_vertex release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _controlsOutput = NO;
        _vertex = nil;
        _mainTemplate = nil;
        _shader = nil;
        _tempIndex = MysticShaderIndexUnknown;
        _linePosition = MysticShaderPositionAuto;
        _index = (MysticShaderIndex){NSNotFound, NSNotFound, 0};
    }
    return self;
}
- (void) commonInit;
{
    self.components = [NSMutableArray array];
    self.constants = [NSMutableDictionary dictionary];
    self.headers = [NSMutableDictionary dictionary];
    self.mains = [NSMutableDictionary dictionary];
    self.prefixes = [NSMutableDictionary dictionary];
    self.suffixes = [NSMutableDictionary dictionary];
    self.functions = [NSMutableDictionary dictionary];
    self.uniforms = [NSMutableDictionary dictionary];
    self.footers = [NSMutableDictionary dictionary];
    self.orderOfFunctions = [NSMutableArray array];
    self.orderOfPrefixes = [NSMutableArray array];
    self.orderOfSuffixes = [NSMutableArray array];
    self.orderOfHeaders = [NSMutableArray array];
    self.orderOfFooters = [NSMutableArray array];
    self.orderOfConstants = [NSMutableArray array];
    self.orderOfUniforms = [NSMutableArray array];
    self.orderOfMains = [NSMutableArray array];
    self.orderOfVertexFooters = [NSMutableArray array];
    self.orderOfVertexHeaders = [NSMutableArray array];
    self.lineKeys = [NSMutableArray array];
    self.vertexFooters = [NSMutableDictionary dictionary];
    self.vertexHeaders = [NSMutableDictionary dictionary];
    self.mainTemplate = nil;
}
- (void) shadersForOption:(PackPotionOption *)option;
{
    if(!option) return;
    [self commonInit];
    self.option = option;
    if(option.hasTextureCoordinate)
    {
        [self addMain:@(MysticShaderKeyMainIndexSub) value:@[@(self.index.stackIndex),@(self.index.index),@(self.index.count),@(self.index.previousIndex),@(self.index.offset)]];
        [self addVertexHeader:@(MysticShaderKeyVertexInputCoordinate + (self.index.index-1)) value:[NSString stringWithFormat:@"attribute vec4 inputTextureCoordinate%d;", (int)self.index.index]];
        [self addVertexHeader:@(MysticShaderKeyVertexTxtCoordinate + (self.index.index-1)) value:[NSString stringWithFormat:@"varying vec2 textureCoordinate%d;", (int)self.index.index]];
        [self addVertexFooter:@(MysticShaderKeyVertexTxtCoordinateValue + (self.index.index-1)) value:[NSString stringWithFormat:@"\ttextureCoordinate%d = inputTextureCoordinate%d.xy;", (int)self.index.index, (int)self.index.index]];
        if(option.numberOfInputTextures>1) for (int n=2; n<((int)option.numberOfInputTextures+1); n++) {
            int i = n;
            int off = !option.hasInput ? -1 : 0;
//            DLog(@"add main:  stackIndex:  %d   index: %d   count: %d   previous: %d   offset: %d", (int)self.index.stackIndex,  (int)self.index.index, (int)self.index.count , (int)self.index.previousIndex, (int)self.index.offset );

            
//            DLog(@"add main sub:  stackIndex:  %d   index: %d   count: %d   previous: %d   offset: %d", (int)self.index.stackIndex,  (int)self.index.index+(i-1)+off, (int)self.index.count +(i-1)+off, (int)self.index.previousIndex+(i-1)+off, (int)self.index.offset );
            [self addMain:@(MysticShaderKeyMainIndexTexture) value:@[@(self.index.stackIndex),@((int)self.index.index+(i-1)+off),@(self.index.count +(i-1)+off),@((int)self.index.previousIndex+(i-1)+off),@(self.index.offset)]];
        }
    }
    
#pragma mark - PreBlend Settings
    if(option.hasPreAdjustments) [self addPreAdjustmentShaders:option];
    if(option.hasCustomShader && option.blendingType == option.normalBlendingType)
    {
        NSDictionary *shdr = option.customShader;
        if(shdr)
        {
            MysticShaderInfo *shder = [MysticShaderInfo info:shdr forKey:option.tag];
            if(isM(shdr[@"main-template"])) self.mainTemplate = shdr[@"main-template"];
            if(isM(shdr[@"mains"])) [self addMains:shdr[@"mains"]];
            if(shder) [self addShaderInfo:shder itemKey:option.tag option:option];
        }
    }
    else if(![self addBlend:option] && option.hasTextureCoordinate && option.hasInput) [self addSuffix:@"normalout" value:@"outputColor = inputColor;"];

    if(option.hasTextureCoordinate && option.hasInput)
    {
        [self insertPrefix:@"input=textureColor" value:[NSString stringWithFormat:@" inputColor = textureColor%d; ", (int)self.index.index] atIndex:0];
//        [self insertPrefix:@"input=textureColor" value:option.shouldBlendWithPreviousTextureFirst ?
//         [NSString stringWithFormat:@" inputColor = textureColor%d; if(inputColor.a < 1.0) { inputColor = mix(previousOutputColor,inputColor,inputColor.a); }", (int)self.index.index] :
//         [NSString stringWithFormat:@" inputColor = textureColor%d; ", (int)self.index.index] atIndex:0];
    }


    
    else if(!option.hasInput)
    {
        [self addSuffix:@"normalout" value:@"outputColor = inputColor;"];
        if(self.index.count && option.hasTextureCoordinate) [self insertPrefix:@"input=output" value:@" inputColor = outputColor; " atIndex:0];
        
    }
    if(option.hasTextureCoordinate && option.hasInput && option.shouldBlendWithPreviousTextureFirst)
    {
        [self addSuffix:@"input=textureColorMix" value:[NSString stringWithFormat:@"if(inputColor.a < 1.0) { outputColor = mix(previousOutputColor,inputColor,inputColor.a); }"]];
    }
    
    if(self.index.count > 0 && option.hasInput) [self insertPrefix:@(MysticShaderKeyPrefixPreviousOutputColor) value:@" previousOutputColor = outputColor; " atIndex:0];
    if(option.hasInput)
    {
        NSString * keySuffix = [NSString stringWithFormat:@"%d", (int)self.index.stackIndex];
        [self addUniform:[@"backgroundColor" stringByAppendingString:keySuffix] value:[NSString stringWithFormat:@"uniform mediump vec4 backgroundColorUniform%d;", (int)self.index.stackIndex]];
        if(option.canReplaceColor) [self addUniform:[@"foreground" stringByAppendingString:keySuffix] value:[NSString stringWithFormat:@"uniform mediump vec4 foregroundColorUniform%d;", (int)self.index.stackIndex]];
        
        if([option hasAdjusted:MysticSettingIntensity] || [option isRefreshingAdjustment:MysticSettingIntensity])
        {
            [self addUniform:@(MysticShaderKeyIntensity + (self.index.index - 1)) value:[NSString stringWithFormat:@"uniform lowp float intensityUniform%d;", (int)self.index.stackIndex]];
            [self addFunction:@(MysticSettingIntensity) value:[[self class] function:@"intensity.function"]];
            [self addSuffix:@"intensity.suffix" value:[[self class] function:@"intensity.suffix"]];
        }
    }
    if(self.orderOfMains.count < 2)
    {
        [self.mains removeAllObjects];
        [self.orderOfMains removeAllObjects];
    }
    
    if(self.lines.count && self.controlsOutput)[self addSuffix:@(MysticShaderKeyControlOutput) value:MysticShaderControlOutput];
    
    int i = 1;
    for (id subTextureKey in option.textures.allKeys) {
        MysticShaderIndex textureIndex = MysticShaderIndexWithIndex(self.index, self.index.index+i);
        [self addLine:[NSString stringWithFormat:@"\n//   adding sub texture blend #%d/%d: %@", i, (int)textureIndex.index, MysticFilterTypeToString([subTextureKey integerValue])] position:MysticShaderPositionSuffix index:textureIndex];
        [self addBlend:subTextureKey position:MysticShaderPositionSuffix index:textureIndex];
        i++;
    }
}
- (void) addAdjustmentShaders:(PackPotionOption *)option;
{
    NSMutableString *str = [NSMutableString string];
    BOOL addError = NO;
    for (id asettingKey in option.orderedAvailableAdjustmentTypes) {
        if((!option.isTransforming && ![option hasAdjusted:[asettingKey integerValue]]) || [asettingKey integerValue] == MysticSettingIntensity /* || [option hasRenderedAdjustment:[asettingKey integerValue]] */) continue;
        NSString *fixedKey = [MysticShaderData settingToKey:asettingKey];
        BOOL added = [self add:asettingKey option:option key:[NSString stringWithFormat:@"functions.%@", fixedKey]];
        if(!added) addError = YES;
        [str appendFormat:@"\nSetting: %@   |   Key Path: %@  |  Added: %@", MysticString([asettingKey intValue]), MObj(fixedKey), MBOOL(added)];
    }
    if(addError) ALLog(@"Shader ERROR:  Unable to find shader info in config for a keypath. Try checking the constants MysticSetting to title", @[@"option", MysticString(option.type),@"settings", MObj(str), ]);
}

- (NSString *) addPreAdjustmentShaders:(PackPotionOption *)option;
{
    NSMutableString *str = [NSMutableString string];
    BOOL addError = NO;
    for (id asettingKey in option.orderedAvailablePreAdjustmentTypes) {

//        DLog(@"add pre shader: %@ = %@  |  use: %@", asettingKey, [MysticShaderData settingToKey:asettingKey], MBOOL(!((!option.isTransforming && ![option hasAdjusted:[asettingKey integerValue]]) || [asettingKey integerValue] == MysticSettingIntensity)));

        
        if((!option.isTransforming && ![option hasAdjusted:[asettingKey integerValue]]) || [asettingKey integerValue] == MysticSettingIntensity) continue;
        NSString *fixedKey = [MysticShaderData settingToKey:asettingKey];
        BOOL added = [self add:fixedKey option:option key:[NSString stringWithFormat:@"functions.%@", fixedKey]];
        if(!added) addError = YES;
        [str appendFormat:@"\nSetting: %@   |   Key Path: %@  |  Added: %@", MysticString([asettingKey intValue]), MObj(fixedKey), MBOOL(added)];
    }
    if(addError) ALLog(@"Shader ERROR:  Unable to find shader info in config for a keypath. Try checking the constants MysticSetting to title", @[@"option", MysticString(option.type),@"settings", MObj(str)]);
    return str;
}

- (NSString *) addPostAdjustmentShaders:(PackPotionOption *)option;
{
    NSMutableString *str = [NSMutableString string];
    BOOL addError = NO;
    for (id asettingKey in option.orderedAvailablePostAdjustmentTypes) {
        if((!option.isTransforming && ![option hasAdjusted:[asettingKey integerValue]]) || [asettingKey integerValue] == MysticSettingIntensity) continue;
        NSString *fixedKey = [MysticShaderData settingToKey:asettingKey];
        BOOL added = [self add:asettingKey option:option key:[NSString stringWithFormat:@"functions.%@", fixedKey] asLines:YES];
        if(!added) addError = YES;
        [str appendFormat:@"\nSetting: %@   |   Key Path: %@  |  Added: %@", MysticString([asettingKey intValue]), MObj(fixedKey), MBOOL(added)];
    }
    if(addError) ALLog(@"Shader ERROR:  Unable to find shader info in config for a keypath. Try checking the constants MysticSetting to title", @[@"option", MysticString(option.type),@"settings", MObj(str), ]);
    return str;
}
- (BOOL) add:(id)itemKey option:(PackPotionOption *)option key:(NSString *)path;
{
    return [self add:itemKey option:option key:path asLines:NO];
}
- (BOOL) add:(id)itemKey option:(PackPotionOption *)option key:(NSString *)path asLines:(BOOL)asLines;
{
    MysticShaderInfo *n = [[self class] lookup:path option:option];
    if(!n) return NO;
    [self addShaderInfo:n itemKey:itemKey option:option asLines:asLines];
   // if(itemKey && ![self.lineKeys containsObject:itemKey]) [self.lineKeys addObject:itemKey];
    return YES;
    
}
- (void) addShaderInfo:(MysticShaderInfo *)n itemKey:(id)itemKey option:(PackPotionOption *)option
{
    [self addShaderInfo:n itemKey:itemKey option:option asLines:NO];
}
- (void) addShaderInfo:(MysticShaderInfo *)n itemKey:(id)itemKey option:(PackPotionOption *)option asLines:(BOOL)asLines;
{
    if(n.uniforms && n.uniforms.count) for (id k in n.uniforms) [self addUniform:[k stringByAppendingFormat:@"-%d", (int)self.index.stackIndex] value:[[self class] uniform:k]];
    if(n.uniform) [self addUniform:[NSString stringWithFormat:@"%@-%d-prefixline", itemKey, (int)self.index.stackIndex] value:n.uniform];
    if(n.constants && n.constants.count) for (id k in n.constants) [self addConstant:k value:[[self class] constant:k]];
    if(n.functions && n.functions.count) for (id k in n.functions) [self addFunction:([k hasPrefix:@"blend"] ? [[k replace:@"blend" with:@""] lowercaseString] : k) value:[[self class] function:k]];
    if(n.header) [self addHeader:itemKey value:n.header];
    if(n.footer) [self addFooter:itemKey value:n.footer];
    if(n.prefix && asLines) [self addLine:n.prefix key:[NSString stringWithFormat:@"%@-%d-prefixline", itemKey, (int)self.index.stackIndex]];
    if(n.line) [self addLine:n.line key:[NSString stringWithFormat:@"%@-%d", itemKey, (int)self.index.stackIndex]];
    if(n.suffix && asLines) [self addLine:n.suffix key:[NSString stringWithFormat:@"%@-%d-suffixline", itemKey, (int)self.index.stackIndex]];
    if(n.blend && option) [self addFunction:MysticFilterTypeToString(option.blendingType) value:n.blend];
    if(n.function) [self addFunction:itemKey value:n.function];
    if(n.prefix && !asLines) [self addPrefix:[NSString stringWithFormat:@"%@-%d-prefix", itemKey, (int)self.index.stackIndex] value:n.prefix];
    if(n.suffix && !asLines) [self addSuffix:[NSString stringWithFormat:@"%@-%d-suffix", itemKey, (int)self.index.stackIndex] value:n.suffix];
    if(n.blendFunction)
    {
        [self addFunction:n.blendFunction value:[[self class] blend:n.blendFunction]];
    }
}


- (void) compileShader;
{
    NSMutableString *shader = [NSMutableString stringWithString:@""];
    
    if(self.lines.count || self.prefixes.count || self.suffixes.count)
    {
        for (id key in self.orderOfPrefixes) {
            if(isM(self.prefixes[key])) [shader appendString:[self.prefixes objectForKey:key]];
            [shader appendString:@"\n"];
        }
        for (NSString *line in self.lines) {
            if(isM(line)) [shader appendString:line];
            [shader appendString:@"\n"];
        }
        for (id key in self.orderOfSuffixes) {
            if(isM(self.suffixes[key])) [shader appendString:[self.suffixes objectForKey:key]];
            [shader appendString:@"\n"];
        }
    }
    self.shader = [[self class] template:shader index:self.index process:self.processTemplates];
}

- (NSString *) shader;
{
    if(!_shader) [self compileShader];
    return _shader;
}
- (NSArray *) allKeys;
{
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:self.lineKeys];
    if(self.headers.allKeys.count) [allKeys addObjectsFromArray:self.headers.allKeys];
    if(self.functions.allKeys.count) [allKeys addObjectsFromArray:self.functions.allKeys];
    if(self.prefixes.allKeys.count) [allKeys addObjectsFromArray:self.prefixes.allKeys];
    if(self.suffixes.allKeys.count) [allKeys addObjectsFromArray:self.suffixes.allKeys];
    if(self.footers.allKeys.count) [allKeys addObjectsFromArray:self.footers.allKeys];
    if(self.mains.allKeys.count) [allKeys addObjectsFromArray:self.mains.allKeys];
    if(self.uniforms.allKeys.count) [allKeys addObjectsFromArray:self.uniforms.allKeys];
    if(self.constants.allKeys.count) [allKeys addObjectsFromArray:self.constants.allKeys];
    
    NSArray *_allKeys = [allKeys copy];
    NSInteger index = [_allKeys count] - 1;
    for (id object in [_allKeys reverseObjectEnumerator]) {
        if ([allKeys indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound || ([object isKindOfClass:[NSString class]] && ([(NSString *)object hasPrefix:@"\n//"] || [(NSString *)object hasPrefix:@"//"]))
            || ([object isKindOfClass:[NSString class]] && ([(NSString *)object hasPrefix:@"inputColor"]))) {
            [allKeys removeObjectAtIndex:index];
        }
        index--;
    }
    [_allKeys release];
    return allKeys;
}
- (BOOL) has:(id)settingKey forOption:(PackPotionOption *)option;
{
    NSString *settingKeyStr = option ? nil : [NSString stringWithFormat:@"%@", settingKey];
    NSString *settingKeyStrIndex = !option ? nil : [NSString stringWithFormat:@"%@-%d", settingKey, (int)option.shaderIndexPath.stackIndex];
    for (id lineKey in self.allKeys) {
        if(([lineKey isKindOfClass:[NSString class]] && ((settingKeyStr && [lineKey isEqualToString:settingKeyStr]) || (settingKeyStr && ([lineKey isEqualToString:settingKeyStrIndex] || [lineKey hasPrefix:settingKeyStrIndex])))) || (!option && [lineKey isEqual:settingKey])) { return YES; }
    }
    return NO;
}
- (id) addBlend:(id)optionOrBlendType;
{
    return [self addBlend:optionOrBlendType position:_linePosition index:self.index];
}
- (id) addBlend:(id)optionOrBlendType position:(MysticShaderPosition)position index:(MysticShaderIndex)index;
{
    MysticShaderPosition _prevLinePosition = _linePosition;
    _tempIndex = index;
    _linePosition = position;
    PackPotionOption *option = [optionOrBlendType isKindOfClass:[PackPotionOption class]] ? optionOrBlendType : nil;
    MysticFilterType blendType = option ? option.blendingType : [optionOrBlendType integerValue];
    NSString *blend_key = [[[self class] blendKey:@(blendType)] lowercaseString];
    NSString *blendLineKey = [NSString stringWithFormat:@"%d-%d", (int)blendType, (int)self.index.stackIndex];
    NSDictionary *blend = nil;
    BOOL addedPostAdjustments = NO;
    blend = [[self class] lookupBlend:blend_key];
    if([blend isKindOfClass:[NSString class]])
    {
        [self addFunction:blend_key value:(NSString *)blend];
        if(option && option.hasPostAdjustments) { [self addPostAdjustmentShaders:option]; addedPostAdjustments=YES;}
        [self addLine:[NSString stringWithFormat:@"\noutputColor = mix(previousOutputColor, blend%@(outputColor, inputColor), inputColor.a);\n", [blend_key capitalizedString]] key:blendLineKey  position:position index:index];
    }
    else if([blend isKindOfClass:[NSDictionary class]])
    {
        if(blend && blend.count)
        {
            NSArray *bConst = blend[@"constants"];
            NSArray *bUni = blend[@"uniforms"];
            NSArray *bFunc = blend[@"functions"];
            NSArray *bPre = blend[@"prefix"];
            NSArray *bHdr = blend[@"headers"];
            NSString *value = blend[@"blend"];
            NSString *line = blend[@"line"];
            NSString *line_header = blend[@"line_header"];

            if(bConst && [bConst isKindOfClass:[NSString class]]) bConst = [(NSString *)bConst componentsSeparatedByString:@","];
            if(bConst && bConst.count) for(id bkey in bConst) [self addConstant:bkey value:[[self class] lookupConstant:bkey]];
            if(bHdr && [bHdr isKindOfClass:[NSString class]]) bHdr = [(NSString *)bHdr componentsSeparatedByString:@","];
            if(bHdr && bHdr.count) for(id bkey in bHdr) [self addHeader:bkey value:[[self class] lookupConstant:bkey]];
            if(bUni && [bUni isKindOfClass:[NSString class]]) bUni = [(NSString *)bUni componentsSeparatedByString:@","];
            if(bUni && bUni.count) for(id bkey in bUni) [self addUniform:[bkey stringByAppendingFormat:@"%d", (int)self.index.stackIndex] value:[[self class] uniform:bkey]];
            if(bPre && [bPre isKindOfClass:[NSString class]]) bPre = [(NSString *)bPre componentsSeparatedByString:@","];
            if(bPre && bPre.count) for(id bkey in bPre) [self addPrefix:bkey value:[[self class] lookupConstant:bkey]];
            if(bFunc && [bFunc isKindOfClass:[NSString class]]) bFunc = [(NSString *)bFunc componentsSeparatedByString:@","];
            if(bFunc && bFunc.count) for (id bkey in bFunc) [self addFunction:bkey value:[[self class] lookupFunction:bkey]];
            if(value)
            {
                [self addFunction:blend_key value:value];
                if(!line)
                {
                    if(option && option.hasPostAdjustments) [self addPostAdjustmentShaders:option]; addedPostAdjustments = YES;
                    line = [NSString stringWithFormat:@"\noutputColor = mix(previousOutputColor, blend%@(outputColor, inputColor), inputColor.a);\n", [blend_key capitalizedString]];
                }
            }
            if(line_header) [self addLine:line_header key:[blendLineKey suffix:@"-header"] position:MysticShaderPositionPrefix index:index];
            if(!addedPostAdjustments && option && option.hasPostAdjustments) [self addPostAdjustmentShaders:option];
            if(line) [self addLine:line key:blendLineKey position:position index:index];
        }
        else blend = nil;
    }
    
    _tempIndex = MysticShaderIndexUnknown;
    _linePosition = _prevLinePosition;
    return isM(blend) ? blend : nil;
}

- (void) addLine:(NSString *)value;
{
    [self addLine:value key:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] position:_linePosition index:MysticShaderIndexIsUnknown(_tempIndex) ? self.index : _tempIndex];
}
- (void) addLine:(NSString *)value key:(id)key;
{
    [self addLine:value key:key position:_linePosition index:MysticShaderIndexIsUnknown(_tempIndex) ? self.index : _tempIndex];
}
- (void) addLine:(NSString *)value position:(MysticShaderPosition)position index:(MysticShaderIndex)index;
{
    [self addLine:value key:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] position:position index:index];
}
- (void) addLine:(NSString *)value key:(id)key position:(MysticShaderPosition)position index:(MysticShaderIndex)index;
{
    if(!value) return;
    if([value rangeOfString:@"%%"].location != NSNotFound) value = [[self class] template:value index:MysticShaderIndexIsUnknown(index) ? MysticShaderIndexIsUnknown(_tempIndex) ? self.index : _tempIndex : index process:self.processTemplates];
    switch (position) {
        case MysticShaderPositionSuffix: [self addSuffix:value.md5 value:value]; return;
        case MysticShaderPositionPrefix: [self addPrefix:value.md5 value:value]; return;
        case MysticShaderPositionHeader: [self addHeader:value.md5 value:value]; return;
        case MysticShaderPositionFooter: [self addFooter:value.md5 value:value]; return;
        default: break;
    }
    if(key && ![self.lineKeys containsObject:key]) [self.lineKeys addObject:key];
    [self.components addObject:value];
}
- (void) addConstant:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfConstants addObject:k];
    if(!self.constants[k]) [self.constants setObject:value forKey:k];
}
- (void) addMain:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfMains addObject:k];
    if(!self.mains[k]) [self.mains setObject:value forKey:k];
}
- (void) addHeader:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    if(self.headers[k]) return;
    [self.orderOfHeaders addObject:k];
    if(!self.headers[k]) [self.headers setObject:value forKey:k];
}

- (void) addFooter:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfFooters addObject:k];
    if(!self.footers[k]) [self.footers setObject:value forKey:k];
}
- (void) addPrefix:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    if([self.orderOfPrefixes containsObject:key]) return;
    [self.orderOfPrefixes addObject:k];
    if(!self.prefixes[k]) [self.prefixes setObject:value forKey:k];
}
- (void) addSuffix:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfSuffixes addObject:k];
    if(!self.suffixes[k]) [self.suffixes setObject:value forKey:k];
}
- (void) addFunction:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    
    if(self.functions[k]) return;
    [self.orderOfFunctions addObject:k];
    [self.functions setObject:value forKey:k];
}
- (void) addUniform:(id)key value:(id)value;
{
    if(!value) return;

    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    if(self.uniforms[k] || [self.uniforms.allValues containsObject:value]) return;
    [self.orderOfUniforms addObject:k];
    value = [[self class] template:value index:self.index process:self.processTemplates];
    
    if(!self.uniforms[k]) [self.uniforms setObject:value forKey:k];
}

- (void) insertLine:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    value = [[self class] template:value index:self.index process:self.processTemplates];
    [self.components insertObject:value atIndex:i];
    
}

- (void) insertPrefix:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfPrefixes insertObject:k atIndex:i];
    if(!self.prefixes[k]) [self.prefixes setObject:value forKey:k];
    
}

- (void) insertUniform:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfUniforms insertObject:k atIndex:i];
    value = [[self class] template:value index:self.index process:self.processTemplates];
    if(!self.uniforms[k]) [self.uniforms setObject:value forKey:k];
    
}

- (void) insertSuffix:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfSuffixes insertObject:k atIndex:i];
    if(!self.suffixes[k]) [self.suffixes setObject:value forKey:k];
    
}

- (void) insertFunction:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfFunctions insertObject:k atIndex:i];
    if(!self.functions[k]) [self.functions setObject:value forKey:k];
    
}

- (void) insertFooter:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfFooters insertObject:k atIndex:i];
    if(!self.footers[k]) [self.footers setObject:value forKey:k];
    
}

- (void) insertHeader:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfHeaders insertObject:k atIndex:i];
    if(!self.headers[k]) [self.headers setObject:value forKey:k];
    
}

- (void) insertMain:(id)key value:(id)value atIndex:(NSInteger)i;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfMains insertObject:k atIndex:i];
    if(!self.mains[k]) [self.mains setObject:value forKey:k];
    
}

- (void) addMains:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addMain:key value:obj];
    }];
}
- (void) addFunctions:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addFunction:key value:obj];
    }];
}

- (void) addPrefixes:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addPrefix:key value:obj];
    }];
}

- (void) addSuffixes:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addSuffix:key value:obj];
    }];
}

- (void) addConstants:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addConstant:key value:obj];
    }];
}

- (void) addFooters:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addFooter:key value:obj];
    }];
}

- (void) addHeaders:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addHeader:key value:obj];
    }];
}

- (void) addUniforms:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addUniform:key value:obj];
    }];
}

- (void) addLines:(NSArray *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [wself addLine:obj];
    }];
}


- (void) addVertexHeader:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfVertexHeaders addObject:k];
    if(!self.vertexHeaders[k]) [self.vertexHeaders setObject:value forKey:k];
}
- (void) addVertexFooter:(id)key value:(id)value;
{
    if(!value) return;
    id k = !key ? value : ([key isKindOfClass:[NSNumber class]] ? @([key integerValue]) : key);
    [self.orderOfVertexFooters addObject:k];
    if(!self.vertexFooters[k]) [self.vertexFooters setObject:value forKey:k];
}

- (void) addVertexFooters:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addVertexFooter:key value:obj];
    }];
}
- (void) addVertexHeaders:(NSDictionary *)values;
{
    if(!values || !values.count) return;
    __block id wself = self;
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [wself addVertexHeader:key value:obj];
    }];
}
- (NSMutableArray *)lines; { return self.components; };




- (NSString *) compileMains;
{
    NSMutableString *subShader = [NSMutableString stringWithString:@""];
    MysticShaderIndex mainIndex = self.index;
    for (id key in self.orderOfMains) {
        
        if([key isKindOfClass:[NSNumber class]] && ([key integerValue] == MysticShaderKeyMainIndex || [key integerValue] == MysticShaderKeyMainIndexSub))
        {
            mainIndex = MysticShaderIndexFromArray(self.mains[key]);
            continue;
        }
        
        NSString *value = self.mains[key];
        
        [subShader appendString:[[self class] template:value index:mainIndex process:self.processTemplates]];
        [subShader appendString:@"\n"];
        
        
    }
    
    return subShader;
}


- (void) setProcessTemplates:(BOOL)processTemplates;
{
    _processTemplates = processTemplates;
    [MysticShaderInfo processTemplates:processTemplates];
}





@end

//
//  MysticShader.m
//  Mystic
//
//  Created by Me on 10/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticShader.h"
#import "NSString+Mystic.h"
#import "MysticImageFilter.h"

static MysticShader *MysticShaderInstance = nil;

@interface MysticShader ()
{
    
}


@property (nonatomic, assign) NSInteger numberOfInputs, numberOfShaders, numberOfOptions;

@property (nonatomic, retain) NSMutableArray *mainTemplates;

@end
@implementation MysticShader

+ (BOOL) shaderFileIsNewer;
{
#ifdef MYSTIC_LOAD_NEWEST_SHADER

    BOOL loadFromFile = NO;
    NSDate *lastDate = loadFromFile ? nil : [MysticUser temp:@"last-shader-date"];
    if(lastDate)
    {
        NSError *error=nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[MysticShadersObject cachedPathForFilename:@"shader.fsh"] error:&error];
        if(!error)
        {
            NSDate *lastModifiedLocal = [fileAttributes fileModificationDate];
            if(![lastDate isEqualToDate:lastModifiedLocal] && [lastDate laterDate:lastModifiedLocal] == lastModifiedLocal) loadFromFile = YES;
        }
    }
    return loadFromFile;
    
#else
    return NO;
#endif
}
+ (void) setShader:(MysticShader *)shader;
{
    if(MysticShaderInstance) MysticShaderInstance=nil;
    if(shader) MysticShaderInstance = shader;
    
}
+ (instancetype) shader;
{
    return [self shader:YES];
}
+ (instancetype) shader:(BOOL)processTemplates;
{
    if(!MysticShaderInstance) MysticShaderInstance = [[self class] shaderWithOptions:[MysticOptions current] processTemplates:processTemplates];
    return MysticShaderInstance;
}
+ (instancetype) shaderWithOptions:(MysticOptions *)options;
{
    return [self shaderWithOptions:options processTemplates:YES];
}
+ (instancetype) shaderWithOptions:(MysticOptions *)options processTemplates:(BOOL)process;
{
    id shader = [(MysticShader *)[[self class] alloc] initWithOptions:options processTemplates:process];
    return shader;
}
+ (BOOL) has:(id)settingKey forOption:(PackPotionOption *)option;
{
    return [[MysticShader shader] has:settingKey forOption:option];
}
- (instancetype) initWithOptions:(MysticOptions *)options;
{
    self = [super init];
    if(!self) return nil;
    self.processTemplates = YES;
    return [self compile:options];
}
- (instancetype) initWithOptions:(MysticOptions *)options processTemplates:(BOOL)process;
{
    self = [super init];
    if(!self) return nil;
    self.processTemplates = process;
    return [self compile:options];
}

- (void) commonInit;
{
    [super commonInit];
    self.mainTemplates = [NSMutableArray array];
}

- (id) compile:(MysticOptions *)optionsObj;
{
    [self commonInit];
    
#ifdef MYSTIC_LOAD_NEWEST_SHADER

    BOOL loadFromFile = [MysticUser is:Mk_SHADER_WITH_FILE];

    if(loadFromFile || [MysticShader shaderFileIsNewer])
    {

        NSError *error = nil;
        
        NSString *shaderStr = [NSString stringWithContentsOfFile:[MysticShadersObject cachedPathForFilename:@"shader.fsh"] encoding:NSUTF8StringEncoding error:&error];
        if(!error && shaderStr) { self.shader = shaderStr; }
        
        NSString *vertexStr = [NSString stringWithContentsOfFile:[MysticShadersObject cachedPathForFilename:@"vertex.vsh"] encoding:NSUTF8StringEncoding error:&error];
        if(!error && vertexStr) { self.vertex = vertexStr; }
        if(self.shader && self.vertex && self.shader.length && self.vertex.length) return self;
    }
    
#endif
    
    
    
#pragma mark - Init Compile
    
    NSMutableString *shader = [NSMutableString string];
    NSMutableString *vertex = [NSMutableString string];
    
    
#pragma mark - Set Vars
    
    NSArray *options = [optionsObj sortedRenderOptions];
    
    self.numberOfOptions = options ? options.count : 0;
    self.numberOfInputs = [MysticOptions numberOfShaders:options];
    self.numberOfShaders = [MysticOptions numberOfShaders:options];
    

    
//    DLogRender(@"Building Shader for Options:  \n\n%@", optionsObj);
    
#pragma mark - Compile
    [self addMain:@(MysticShaderKeyMainIndex) value:@[@(1),@(0),@(0),@(0),@(0)]];
    [self addVertexHeader:@(MysticShaderKeyVertexPosition) value:@"attribute vec4 position;"];
    [self addVertexHeader:@(MysticShaderKeyVertexInputCoordinate) value:@"attribute vec4 inputTextureCoordinate;"];
    [self addVertexHeader:@(MysticShaderKeyVertexTxtCoordinate) value:@"varying vec2 textureCoordinate;"];
    [self addVertexFooter:@(MysticShaderKeyVertexMain) value:@"\n\nvoid main() \n{"];
    [self addVertexFooter:@(MysticShaderKeyVertexGLPosition) value:@"\tgl_Position = position;"];
    [self addVertexFooter:@(MysticShaderKeyVertexTxtCoordinateValue) value:@"\ttextureCoordinate = inputTextureCoordinate.xy;"];
    if(self.numberOfOptions)
    {
        NSInteger index = 2;
        NSInteger stackIndex = 2;
        NSInteger x = 0;
        NSInteger prevEffectIndex = 0;
        [self add:@"threshold" option:nil key:@"functions.threshold"];
        [self addUniform:@"fullScale" value:[NSString stringWithFormat:@"uniform lowp float fullScale; // %2.2f", [MysticOptions current].filters.filter.fullScale]];

        [self.mainTemplates addObject:[NSNull null]];
        int lastCoordinateInsertion = 0;
        for (PackPotionOption *option in options)
        {
            if(!option.hasShader || option.ignoreActualRender) continue;
            
            MysticShaderStringOption *optionShader = [[self class] shaderForOption:option index:(MysticShaderIndex){stackIndex, index, x, MAX(option.hasInput ? index-1 : index-1, 0), option.hasInput ? 0 : -1} processTemplates:self.processTemplates];
            option.shaderIndexPath = optionShader.index;
            if(option.hasInput)
            {
                [self addUniform:@(MysticShaderKeyUniformMain + index) value:[NSString stringWithFormat:@"uniform sampler2D inputImageTexture%d;", (int)optionShader.index.index]];

                if(option.hasTextureCoordinate)
                {
                    [self insertUniform:@(MysticShaderKeyUniformMainCoord + index) value:[NSString stringWithFormat:@"varying highp vec2 textureCoordinate%d;", (int)optionShader.index.index] atIndex:lastCoordinateInsertion];
                    lastCoordinateInsertion++;
                    [self.mainTemplates addObject:optionShader.mainTemplate ? optionShader.mainTemplate : [NSNull null]];
                }
            }
            if(option.numberOfInputTextures > 1)
            {
                for (int i=1; i<option.numberOfInputTextures; i++) {
//                    DLog(@"adding input texture main template: %d", i);
                    int off = option.hasInput ? 0 : -1;
                    NSString *mtpl = MysticShaderMainsTextureTemplate;
                    if(!option.hasTextureCoordinate || !option.hasInput)
                    {
                        mtpl = MysticShaderMainsTextureTemplatePreviousCoord;
                    }
                    [self addUniform:@(MysticShaderKeyUniformMain + index+i+off) value:[NSString stringWithFormat:@"uniform sampler2D inputImageTexture%d;", (int)optionShader.index.index+i+off]];
                    [self.mainTemplates addObject:mtpl];
                }
            }
            
            
            [self addLine:[NSString stringWithFormat:@"\n//  --------------------------------------------------------\n//   Layer %d:   %@ ( %@ ) \n//   Blend:   %@/%@%@  %2.1f%% |  Fx: %d\n//   Input textures:   %d\n", (int)stackIndex, MyString(option.type), option.name, option.blending, MysticFilterTypeToString(option.blendingType), option.hasMaskImage ? @" Has Mask" : @"", option.intensity, option.layerEffect - MysticLayerEffectNone, (int)option.numberOfInputTextures]];
            
            [self addShader:optionShader];
            [self addLine:@"\n//  --------------------------------------------------------\n"];
            index += optionShader.index.offset;
            self.numberOfInputs += optionShader.index.offset;
            
            prevEffectIndex = index <= 1 ? 0 : index;
            stackIndex++;
            index+=1+(option.numberOfInputTextures-1);
            x++;
        }
    }

    [self addVertexFooter:@(MysticShaderKeyVertexMainClose) value:@"\n}"];
    [self insertUniform:@(MysticShaderKeyUniformMain) value:MysticShaderOneUniform atIndex:0];
    [self insertUniform:@"space" value:@"\n\n" atIndex:1];
    [self addHeader:@(MysticShaderKeyMain) value:MysticShaderMain];
    
    NSString *theMains = [self compileMains:options];
    if(theMains) [self addHeader:@(MysticShaderKeyMains) value:theMains];
    
    switch (self.numberOfInputs)
    {
        case 1: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderOne]; break; }
        case 2: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderTwo]; break; }
        case 3: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderThree]; break; }
        case 4: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderFour]; break; }
        case 5: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderFive]; break; }
        case 6: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderSix]; break; }
        case 7: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderSeven]; break; }
        case 8: { [self addHeader:@(MysticShaderKeyPrefixMain) value:MysticShaderEight]; break; }
        default: break;
    }
    
    NSString *inputStr = @"inputColor = outputColor;";
    [self addHeader:@"inputcolor=" value:inputStr];
    [self addFooter:@(MysticShaderKeyFragColor) value:[NSString stringWithFormat:@"\tgl_FragColor = %@; \n}", kMysticShaderOutputColor]];
    
    
#pragma mark - Return compile
    [shader appendString:[NSString stringWithFormat:@"// +=========================================================-\n//  Shader:    Options: %d  Inputs: %d  Textures: %d  Shaders: %d\n// =========================================================\r\r\r",
                   (int)self.numberOfOptions,
                   (int)self.numberOfInputs,
                   (int)optionsObj.numberOfInputTextures,
                   (int)self.numberOfShaders]];
    
    if(self.uniforms.count) [shader appendString:@"\n\n\n\n//   +=============== UNIFORMS ==================\n\n"];
    
    
    for (id key in self.orderOfUniforms) {
        if(isM(self.uniforms[key])) [shader appendString:self.uniforms[key]];
        [shader appendString:@"\n"];
    }
    
    
    if(self.constants.count) [shader appendString:@"\n\n\n\n//   +=============== CONSTANTS ==================\n\n"];
    
    for (id key in self.orderOfConstants) {
        if(isM(self.constants[key])) [shader appendString:self.constants[key]];
        [shader appendString:@"\n"];
    }
    
    if(self.functions.count) [shader appendString:@"\n\n\n\n//   +=============== FUNCTIONS ==================\n\n"];
    
    for (id key in self.orderOfFunctions) {
        if(isM(self.functions[key])) [shader appendString:self.functions[key]];
        [shader appendString:@"\n"];
    }
    
    
    
    
    if(self.headers.count) [shader appendString:@"\n\n\n\n//   +=============== HEADERS ==================\n\n"];

    
    for (id key in self.orderOfHeaders) {
        if(isM(self.headers[key])) [shader appendString:[self.headers[key] prefix:@"\t"]];
        [shader appendString:@"\n"];
    }
    
    if(self.prefixes.count) [shader appendString:@"\n\n\n\n//   +=============== PREFIX ==================\n\n"];
    

    for (id key in self.orderOfPrefixes) {
        if(isM(self.prefixes[key])) [shader appendString:[self.prefixes[key] prefix:@"\t"]];
        [shader appendString:@"\n"];
    }
    
    if(self.lines.count) [shader appendString:@"\n\n\n\n//   +=============== LINES ==================\n\n"];

    
    for (NSString *line in self.lines) {
        if(isM(line)) [shader appendString:line];
        [shader appendString:@"\n"];

    }
    
    if(self.suffixes.count) [shader appendString:@"\n\n\n\n//   +=============== SUFFIX ==================\n\n"];

    
    for (id key in self.orderOfSuffixes) {
        if(isM(self.suffixes[key])) [shader appendString:self.suffixes[key]];
        [shader appendString:@"\n"];

    }
    
    if(self.footers.count) [shader appendString:@"\n\n\n\n//   +=============== FOOTERS ==================\n\n"];

    
    for (id key in self.orderOfFooters) {
        if(isM(self.footers[key])) [shader appendString:[self.footers[key] prefix:@"\n"]];
        [shader appendString:@"\n"];
    }
    
    
    
    // build vertex
    
    for (id key in self.orderOfVertexHeaders) {
        if(isM(self.vertexHeaders[key])) [vertex appendString:self.vertexHeaders[key]];
        [vertex appendString:@"\n"];
    }
    
    for (id key in self.orderOfVertexFooters) {
        if(isM(self.vertexFooters[key])) [vertex appendString:self.vertexFooters[key]];
        [vertex appendString:@"\n"];
    }
    
    self.shader = shader;
    self.vertex = vertex;
    
//    DLogDebug(@"Shader:  \n\n%@", shader);
    return self;
}


- (NSString *) compileMains;
{
    return [self compileMains:[MysticOptions current].sortedRenderOptions];
}
- (NSString *) compileMains:(NSArray *)options;
{
    NSMutableString *subShader = [NSMutableString stringWithString:@""];
    MysticShaderIndex mainIndex = (MysticShaderIndex){1,0,0,0,0};
    for (id key in self.orderOfMains) {
        if([key isKindOfClass:[NSNumber class]] && ([key integerValue] == MysticShaderKeyMainIndex || [key integerValue] == MysticShaderKeyMainIndexSub || [key integerValue] == MysticShaderKeyMainIndexTexture))
        {
            mainIndex = MysticShaderIndexFromArray(self.mains[key]); continue;
        }
        [subShader appendString:[[self class] template:self.mains[key] index:mainIndex process:self.processTemplates]];
        [subShader appendString:@"\n"];
    }
    
    NSString *ltpl = nil;
    for (id mo in self.mainTemplates) {
        if(![mo isKindOfClass:[NSNull class]] && [mo isKindOfClass:[NSString class]]) { ltpl = mo; break; }
    }
    
    if(ltpl)
    {
        for (int _m=0; _m < [NSArray arrayWithArray:self.mainTemplates].count; _m++) {
            id mo = [self.mainTemplates objectAtIndex:_m];
            if(![mo isKindOfClass:[NSNull class]] && [mo isKindOfClass:[NSString class]])
            {
                ltpl = ltpl&&[mo isEqualToString:ltpl]?nil:mo;
            }
            else if(ltpl && ![mo isKindOfClass:[NSNull class]]) [self.mainTemplates replaceObjectAtIndex:_m withObject:ltpl];
        }
    }
    
    
    
    int x = 1;
    MysticShaderIndex indx = (MysticShaderIndex){x, x, x-1, MAX(x-1,0), 0};
    NSString *tpl = self.mainTemplates.count > x ? [self.mainTemplates objectAtIndex:x] : self.mainTemplate;
    [subShader appendString:[[self class] template:isMEmpty(tpl) ? nil : tpl index:indx process:self.processTemplates]];
    [subShader appendString:@"\n"];
    x++;
    
    
    for (PackPotionOption *option in options)
    {
        if(!option.hasShader || option.ignoreActualRender) continue;
        if(option.hasInput)
        {
            if(option.hasTextureCoordinate)
            {
                NSString *tpl = self.mainTemplates.count > x ? [self.mainTemplates objectAtIndex:x] : self.mainTemplate;
                [subShader appendString:[[self class] template:isMEmpty(tpl) ? nil : tpl index:option.shaderIndexPath process:self.processTemplates]];
                [subShader appendString:@"\n"];
            }
        }
        else
        {
            x -= 1;
        }
            
        for (int i=1; i<option.numberOfInputTextures; i++) {
            NSString *tpl = self.mainTemplates.count > x ? [self.mainTemplates objectAtIndex:x] : self.mainTemplate;
            int off = option.hasInput?0:-1;
            MysticShaderIndex nindex = MysticShaderIndexWithIndex(option.shaderIndexPath,option.shaderIndexPath.index+i+off);
            nindex.previousIndex -= 1;
            NSString *ntpl = [[self class] template:isMEmpty(tpl) ? nil : tpl index:nindex process:self.processTemplates];
            [subShader appendString:ntpl];
            [subShader appendString:@"\n"];
            x++;
        }
        x++;
    }
    
    return subShader;
    
}

- (void) addShader:(MysticShaderStringOption *)subShader;
{
    for (id k in subShader.orderOfConstants) {
        if([self.orderOfConstants containsObject:k]) continue;
        [self addConstant:k value:[subShader.constants objectForKey:k]];
    }
    for (id k in subShader.orderOfMains) {
        if([self.orderOfMains containsObject:k]) continue;
        [self addMain:k value:[subShader.mains objectForKey:k]];
    }
    for (id k in subShader.orderOfHeaders) {
        if([self.orderOfHeaders containsObject:k]) continue;
        [self addHeader:k value:[subShader.headers objectForKey:k]];
    }
    for (id k in subShader.orderOfUniforms) {
        if([self.orderOfUniforms containsObject:k]) continue;
        [self addUniform:k value:[subShader.uniforms objectForKey:k]];
    }
    for (id k in subShader.orderOfFooters) {
        if([self.orderOfFooters containsObject:k]) continue;
        [self addFooter:k value:[subShader.footers objectForKey:k]];
    }
    for (id k in subShader.orderOfFunctions) {
        if([self.orderOfFunctions containsObject:k]) continue;
        [self addFunction:k value:[subShader.functions objectForKey:k]];
    }
    [self addLine:subShader.shader];
    
    for (id k in subShader.orderOfVertexHeaders) {
        if([self.orderOfVertexHeaders containsObject:k]) continue;
        [self addVertexHeader:k value:[subShader.vertexHeaders objectForKey:k]];
    }
    for (id k in subShader.orderOfVertexFooters) {
        if([self.orderOfVertexFooters containsObject:k]) continue;
        [self addVertexFooter:k value:[subShader.vertexFooters objectForKey:k]];
    }
}



- (NSString *) prettyOutput;
{
    return [[self class] outputString:self.shader];
}

+ (NSString *) outputString:(NSString *)shaderStr;
{
    NSString *outStr =  shaderStr.stringByRemovingBlankLines;
    outStr = [outStr stringByReplacingOccurrencesOfString:@"//   +===" withString:@"\r\r//   ==="];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"===\n" withString:@"===\r\n"];
    outStr = [[self class] indentNewLines:outStr];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"===-" withString:@"==="];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"void main() {" withString:@"\nvoid main()\n{"];
    return outStr;
}


+ (NSString *) indentNewLines:(NSString *)str;
{
    NSMutableString *newStr = [NSMutableString stringWithString:@""];
    NSInteger tabs = 0;
    
    for (NSString *line in [str componentsSeparatedByString:@"\n"]) {
        if([line isEqualToString:@""] || [line isEqualToString:@"\t"]) continue;
        NSString *_line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        BOOL has1 = [line containsString:@"{"];
        BOOL has2 = [line containsString:@"}"];
        BOOL hasBoth = has1 && has2;
        if(has2 && !hasBoth) tabs--;
        if(tabs > 0)
        {
            NSString *pre = nil;
            if([line hasPrefix:@"\r"])
            {
                NSRange r = NSMakeRange(0, 1);
                for (int i=1; i<line.length; i++) {
                    if([[line substringWithRange:NSMakeRange(i,1)] isEqualToString:@"\r"]) continue;
                    r.location = i; break;
                }
                pre = [line substringWithRange:NSMakeRange(0, r.location)];
                _line = [_line substringFromIndex:r.location];
            }
            _line = [_line prefix:[NSString stringWithFormat:@"%@%@", pre?pre:@"", [@"\t" repeat:tabs]]];
        }
        BOOL ignoreExtraLineBreak = [_line hasSuffix:@";"] && ![_line hasPrefix:@"\n"];
        if(ignoreExtraLineBreak) _line = [_line stringByAppendingString:@"\n"];
        [newStr appendFormat:@"%@%@", _line, ignoreExtraLineBreak?@"":@"\n"];
        if(has1 && !hasBoth) tabs++;
        
        if(tabs == 0 && has2) [newStr appendString:@"\n"];
        
        
    }
    return newStr;
}


@end

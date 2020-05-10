//
//  MysticShadersObject.m
//  Mystic
//
//  Created by Travis on 10/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShadersObject.h"
#import "MysticShaderString.h"
#import "MysticShader.h"
#import "MysticOptions.h"

@implementation MysticShadersObject

static int MysticShaderSaveIndex = 0;

@synthesize
vertex=_vertexString,
shader=_shaderString;

- (void) dealloc;
{
    [_shaderString release];
    [_vertexString release];
    [super dealloc];
}
+ (MysticShadersObject *) shader:(id)object;
{
    MysticOptions *mOptions = (MysticOptions *)object;
    

    MysticShader *s = [MysticShader shaderWithOptions:mOptions];

    MysticShadersObject *shader = [[MysticShadersObject alloc] init];
    shader.shader = s.shader;
    shader.vertex = s.vertex && s.vertex.length ? s.vertex : nil;
#ifdef DEBUG
    if(mOptions.settings & MysticRenderOptionsOutputShader)
    {
        NSLog(@"%@", shader.shader);
        DLogDebug(@" ");
        DLogDebug(@" ");
        DLogSuccess(@"%@", [MysticShader outputString:shader.shader]);
        
        DLogHidden(@" ");
        DLogHidden(@" ");
        DLogHidden(@" ");
        DLogHidden(@" ");

        DLogHidden(@"---------------------------------");

        DLogHidden(@" ");
        DLogHidden(@" ");
        DLogHidden(@" ");
        DLogHidden(@" ");
        
        NSLog(@"%@", shader.vertex);
        DLogDebug(@" ");
        DLogDebug(@" ");
        DLogError(@"%@", [MysticShader outputString:shader.vertex]);
        
        
        
        [MysticOptions disable:MysticRenderOptionsOutputShader];
    }


    if(MYSTIC_SHADER_WRITE_TO_FILE == 1)
    {
        MysticShaderSaveIndex++;
        [self saveShaderToFile:@"shader.fsh" shader:s.prettyOutput];
        NSString *vertexStr = [MysticShaderString outputString:shader.vertex];
        if(vertexStr) [self saveShaderToFile:@"vertex.vsh" shader:vertexStr];
        NSError *error=nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[MysticShadersObject cachedPathForFilename:@"shader.fsh"] error:&error];
        if(!error)
        {
            NSDate *lastModifiedLocal = [fileAttributes fileModificationDate];
            [MysticUser setTemp:lastModifiedLocal key:@"last-shader-date"];
        }

        MysticShader *s2 = [MysticShader shaderWithOptions:mOptions processTemplates:NO];
        [self saveShaderToFile:@"shader__template.fsh" shader:s2.prettyOutput];
        NSString *vertexStr2 = [MysticShaderString outputString:s2.vertex];
        if(vertexStr2) [self saveShaderToFile:@"vertex__template.vsh" shader:vertexStr2];
        
        
//        [self saveShaderToFile:[NSString stringWithFormat:@"shader_%d.fsh", MysticShaderSaveIndex] shader:s.prettyOutput];
//        if(vertexStr) [self saveShaderToFile:[NSString stringWithFormat:@"vertext_%d.vsh", MysticShaderSaveIndex] shader:vertexStr];
//        
//        [self saveShaderToFile:[NSString stringWithFormat:@"shader__template_%d.fsh", MysticShaderSaveIndex] shader:s2.prettyOutput];
//        if(vertexStr2) [self saveShaderToFile:[NSString stringWithFormat:@"vertex__template_%d.vsh", MysticShaderSaveIndex]  shader:vertexStr2];
        
        
    }
#endif

    [MysticShader setShader:s];
    return [shader autorelease];
}
- (BOOL) isEqual:(id)object;
{
    BOOL isIt = [super isEqual:object];
    if(!isIt && [object isKindOfClass:[self class]])
    {
        MysticShadersObject *_obj = (MysticShadersObject *)object;
        isIt = [self usesSameShadersAs:_obj.shader vertex:_obj.vertex];
    }
    return isIt;
}
- (BOOL) usesSameShadersAs:(NSString *)shader vertex:(NSString *)vertex;
{
    if(!shader && !vertex && !self.shader && !self.vertex) return YES;
    if((!shader && self.shader) || (shader && !self.shader) || (!vertex && self.vertex) || (vertex && !self.vertex)) return NO;
    if(!shader || (shader && [shader isEqual:self.shader] ))
    {
        if(!vertex || (vertex && [vertex isEqual:self.vertex] ))
        {
            return YES;
        }
    }
    if(shader && ![shader isEqualToString:self.shader]) return NO;
    if(vertex && ![vertex isEqualToString:self.vertex]) return NO;
    return YES;
}
+ (NSString *) outputString:(NSString *)shaderStr;
{
    NSString *outStr = [shaderStr stringByReplacingOccurrencesOfString:@";" withString:@";\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"{" withString:@"\n{\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"}" withString:@"\n}\n"];
    outStr = [outStr stringByReplacingOccurrencesOfString:@"void main()" withString:@"\n\nvoid main()\n\n"];
    return outStr;
}

+ (NSString *) cachedShaderStr;
{
    NSError *error = nil;
    return [NSString stringWithContentsOfFile:[[self class] cachedPathForFilename:@"shader"] encoding:NSUTF8StringEncoding error:&error];
}

+ (NSString *) cachedVertexStr;
{
    NSError *error = nil;
    return [NSString stringWithContentsOfFile:[[self class] cachedPathForFilename:@"vertex"] encoding:NSUTF8StringEncoding error:&error];
}

+ (NSString *) cacheDirectoryPath;
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"shaders"];
    BOOL isDir;
    BOOL cachePathExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!cachePathExists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return cachePath;
}
+ (NSString *) cachedPath;
{
    return [[self class] cachedPathForFilename:nil];
}
+ (NSString *) cachedPathForFilename:(NSString *)filename;
{
    NSArray *f = [filename componentsSeparatedByString:@"."];
    filename = filename ? [f objectAtIndex:0] : nil;
    NSString *ext = filename && f.count > 1 ? [f objectAtIndex:1] : nil;
    

    NSString *cachedPath = [[self class] cacheDirectoryPath];
    cachedPath = [cachedPath stringByAppendingFormat:@"/%@%@.mystic%@", filename ? filename : @"",  filename ? @"" : @"mystic_shader", ext ? [@"." stringByAppendingString:ext] : @""];
    return cachedPath;
}

+ (NSString *) saveShaderToFile:(NSString *)filename shader:(NSString *)shader;
{
    NSString *path = [[self class] cachedPathForFilename:filename];
    NSError *myError = nil;
    [shader writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&myError];
    
    return path;
}
+ (void) deleteAllFiles:(NSString *)tag;
{
    [self deleteAllFiles:tag files:nil];
}
+ (void) deleteAllFiles:(NSString *)tag files:(NSMutableArray *)files;
{
    [MysticCache deleteAllFiles:[self cacheDirectoryPath] tag:tag files:files];
}

@end

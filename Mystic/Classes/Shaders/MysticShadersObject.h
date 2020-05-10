//
//  MysticShadersObject.h
//  Mystic
//
//  Created by Travis on 10/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MysticShadersObject : NSObject

@property (nonatomic, retain) NSString *shader;
@property (nonatomic, retain) NSString *vertex;

+ (MysticShadersObject *) shader:(id)object;
- (BOOL) usesSameShadersAs:(NSString *)shader vertex:(NSString *)vertex;
+ (NSString *) cachedPathForFilename:(NSString *)filename;
+ (NSString *) cachedPath;
+ (NSString *) cacheDirectoryPath;
+ (NSString *) cachedShaderStr;
+ (NSString *) cachedVertexStr;
+ (NSString *) saveShaderToFile:(NSString *)filename shader:(NSString *)shader;
+ (void) deleteAllFiles:(NSString *)tag;
+ (void) deleteAllFiles:(NSString *)tag files:(NSMutableArray *)files;

@end

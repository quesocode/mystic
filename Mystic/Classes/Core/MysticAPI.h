//
//  MysticAPI.h
//  Mystic
//
//  Created by travis weerts on 6/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@interface MysticAPI : NSObject
+ (void) setBuildNumber:(int)value;
+ (NSInteger) buildNumber;

+ (void) get:(NSString *)uri params:(NSDictionary *)params complete:(MysticBlockAPI)completed;
+ (void) upload:(NSString *)uri params:(NSDictionary *)params upload:(NSDictionary *)uploadInfo progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;

+ (void) upload:(NSString *)uri params:(NSDictionary *)params uploads:(NSArray *)uploads progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;
+ (void) dictionaryFromURL:(NSString *)urlStr finished:(MysticBlockObjBOOL)finished;
+ (void) post:(NSString *)uri params:(NSDictionary *)params progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;
+ (NSURL *) url:(NSString *)uri;

@end

//
//  NSString+Mystic.h
//  Mystic
//
//  Created by Travis on 10/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Mystic)
@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL isAllDigits;

@property (nonatomic, readonly) NSInteger numberOfLines;
@property (nonatomic, readonly)  NSString * _Nullable inlineString;
@property (nonatomic, readonly)  NSString * _Nullable inlineStringNoTabs;
@property (nonatomic, readonly)  NSString * _Nullable inlineNoColorString;
@property (nonatomic, readonly)  NSString * _Nullable stringByRemovingBlankLines;
@property (nonatomic, readonly)  NSString * _Nullable capitalized;
@property (nonatomic, readonly)  NSString * _Nullable lowercase;
@property (nonatomic, readonly)  NSString * _Nullable uppercase;
@property (nonatomic, readonly)  NSString * _Nullable localFilePath;
@property (nonatomic, readonly) NSString * _Nullable cleanString;
@property (readonly, nonatomic) int lengthVisible;

+ (NSString * _Nullable) md5:(NSString *_Nullable) input;
- (NSString *_Nullable)repeat:(NSUInteger)times;
- (NSString *_Nullable) md5;
- (BOOL) equals:(NSString *_Nullable)string;
- (NSString *_Nullable) debugStringLine:(int)length;
+ (NSString *_Nullable) fraction:(float)value;
- (NSString *_Nullable) capitalizedWordsString;
- (NSString *_Nullable) shorten:(int)max suffix:(NSString *_Nullable)sf;
- (NSString *_Nullable) firstLine;
- (void) copyToClipboard;
+ (instancetype _Nullable)format:(NSString *_Nullable)format, ...;
- (NSString *_Nullable) prefix:(NSString *_Nullable)pre suffix:(NSString *_Nullable)suff;
- (NSString *_Nullable) removeWhitespaces;
- (NSString *_Nullable) suffix:(NSString *_Nullable)suffix;
- (NSString *_Nullable) prefix:(NSString *_Nullable)prefix;
- (NSString *_Nullable) wrap:(NSString *_Nullable)wrapper;
- (NSString *_Nullable) trim:(NSString *_Nullable)str;
- (NSString *_Nullable) trimSuffix:(NSString *_Nullable)suffix;
- (NSString *_Nullable) trimPrefix:(NSString *_Nullable)prefix;
- (NSString *_Nullable) deleteSuffix:(NSString *_Nullable)suffix;
- (NSString *_Nullable) deletePrefix:(NSString *_Nullable)prefix;
- (NSString *_Nullable) replace:(NSString *_Nullable)string with:(NSString *_Nullable)replacement;
- (NSString *_Nullable) pad:(int)length use:(NSString *_Nullable)str;
- (NSString *_Nullable) pad:(int)length;

- (NSString *_Nullable) remove:(NSString *_Nullable)string;


- (instancetype _Nullable)append:(NSString *_Nullable)format, ...;
- (instancetype _Nullable)prepend:(NSString *_Nullable)format, ...;
- (instancetype _Nullable)with:(nullable id)value, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype _Nullable)format:(NSString * _Nullable)format;
- (float) compareWithString: (NSString * _Nullable) stringB;
- (float) compareWithWord: (NSString * _Nullable) stringB;
- (int) smallestOf: (int) a andOf: (int) b andOf: (int) c;
- (NSString * _Nullable) difference:(NSString * _Nullable)compare;

@end

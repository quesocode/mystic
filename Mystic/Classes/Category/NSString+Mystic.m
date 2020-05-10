//
//  NSString+Mystic.m
//  Mystic
//
//  Created by Travis on 10/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "NSString+Mystic.h"
#import "MysticConstants.h"
#import <stdarg.h>

@implementation NSString (Mystic)

- (BOOL) isAllDigits
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && self.length > 0;
}

- (NSString *)removeWhitespaces;
{
    return [[self componentsSeparatedByCharactersInSet:
             [NSCharacterSet whitespaceCharacterSet]]
            componentsJoinedByString:@""];
}

- (NSString *)repeat:(NSUInteger)times {
    return times <= 0 ? @"" : [@"" stringByPaddingToLength:(int)MIN(times* [self length],1000) withString:self startingAtIndex:0];
}

+ (NSString *) md5:(NSString *) input;
{
    return [input md5];
}
+ (NSString *_Nullable) fraction:(float)value;
{
    if(value == 0.1) return @"1/10";
    if(value == 0.25) return @"1/4";
    if(value == 0.5) return @"1/2";
    if(value > 0.3 && value < 0.35) return @"1/3";
    if(value > 0.6 && value < 0.68) return @"1/3";
    if(value > 1 && value < 2) return [NSString stringWithFormat:@"%1.1f", value];
    if(value == 0.75) return @"3/4";
    return value < 1 ? [NSString stringWithFormat:@"%d/10", [@(value*10) intValue]] : [NSString stringWithFormat:@"%d", [@(value) intValue]];

}
- (NSString *) prefix:(NSString *)pre suffix:(NSString *)suff;
{
    NSString *s = self;
    if(pre && pre.length) s=[s prefix:pre];
    if(suff && suff.length) s=[s suffix:suff];
    return s;
}
- (NSString *_Nullable) pad:(int)length use:(NSString *_Nullable)str;
{
    return [self stringByPaddingToLength:length withString:str startingAtIndex:0];

}
- (NSString *_Nullable) pad:(int)length;
{
    return [self stringByPaddingToLength:length withString:@" " startingAtIndex:0];
}
- (NSString *_Nullable) replace:(NSString *_Nullable)string with:(NSString *_Nullable)replacement;
{
    return !replacement ? string : [self stringByReplacingOccurrencesOfString:string withString:replacement];
}
- (NSString *_Nullable) remove:(NSString *_Nullable)string;
{
    return [self stringByReplacingOccurrencesOfString:string withString:@""];
}
- (NSString *) localFilePath;
{
    NSRange r = [self rangeOfString:@"/Library"];
    return r.location != NSNotFound ? [[self substringFromIndex:r.location] prefix:@"~"] : self;
}
- (NSString *) md5;
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
- (NSString *) capitalized; {    return [self capitalizedString]; }
- (NSString *) lowercase; {    return [self lowercaseString]; }
- (NSString *) uppercase; {    return [self uppercaseString]; }

- (NSString *) debugStringLine:(int)length;
{
    return [self stringByPaddingToLength:length withString:@"." startingAtIndex:0];
}

- (NSString *) shorten:(int)max suffix:(NSString *)sf;
{
    
    if(self.length <= max) return self;
    sf = sf ? sf : @"...";
    return [[self substringToIndex:max-sf.length] stringByAppendingString:sf];
}
- (NSInteger) numberOfLines;
{
    NSString *string = self;
    NSInteger numberOfLines, index, stringLength = [string length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
    if([string hasSuffix:@"\n"] || [string hasSuffix:@"\r"]) numberOfLines += 1;
    if([string hasPrefix:@"\n"] || [string hasPrefix:@"\r"]) numberOfLines += 1;
    return numberOfLines;
}
- (BOOL) isEmpty;
{
    return [self isEqualToString:@""];
}
- (NSString *) inlineString;
{
    NSString *s = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];

    return s;
}
- (NSString *) inlineStringNoTabs;
{
    return [self.inlineString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
}
- (NSString *) inlineNoColorString;
{
    NSString *s = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    s = [s stringByReplacingOccurrencesOfString:XCODE_COLORS_RESET_FG withString:@"{FG}"];
    s = [s stringByReplacingOccurrencesOfString:XCODE_COLORS_RESET_BG withString:@"{BG}"];
    s = [s stringByReplacingOccurrencesOfString:XCODE_COLORS_ESCAPE withString:@"{ESC}"];
    
    
    
    return s;
}
- (void) copyToClipboard;
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self];
}

- (NSString *) capitalizedWordsString;
{
    __unsafe_unretained __block NSMutableString *result = [[self mutableCopy] retain];
    __block int l = [result length];
    [result enumerateSubstringsInRange:NSMakeRange(0, l)
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [result replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                      withString:[[substring substringToIndex:1] uppercaseString]];
                                
//                                ALLog(@"capitalized words range:", @[@"string", MObj(result),
//                                                                     @"length", @(l),
//                                                                     @"sub", MObj(substring),
//                                                                     @"sub range", [NSString stringWithFormat:@"%d -> %d", substringRange.location, substringRange.length],
//                                                                     @"enc range", [NSString stringWithFormat:@"%d -> %d", enclosingRange.location, enclosingRange.length],
//                                                                     @"stop", MBOOL((enclosingRange.location + enclosingRange.length >= l)),
//                                                                     
//                                                                     ]);
                                if(enclosingRange.location + enclosingRange.length >= l)
                                {
                                    [result autorelease];
                                    *stop = YES;
                                }
                                
                                
                                
                            }];
    return [result autorelease];
}
- (BOOL) equals:(NSString *_Nullable)string;
{
    return !string ? NO : [self isEqualToString:string];
}
- (int) lengthVisible;
{
    if(self.length < 1) return 0;
    if(self.length <= 3) return (int)self.length;
    return (int)self.cleanString.length;
}
- (NSString *) cleanString;
{
    NSString *l2 = [self stringByReplacingOccurrencesOfString:(XCODE_COLORS_RESET_FG) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(LINE_COLOR) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(LOG_KEY_COLOR) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(LOG_VALUE_COLOR) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(XCODE_COLORS_RESET_BG) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(XCODE_COLORS_RESET) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(XCODE_COLORS_ESCAPE) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_B") withString:@" "];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_D") withString:@" "];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_SQ") withString:@"  "];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_ENDFG") withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_ENDBG") withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(@"$_END") withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:kBGb withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:kBGd withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:kBG withString:@""];

    
    NSMutableString *_l2 = [NSMutableString stringWithString:l2];
    NSRange r = [_l2 rangeOfString:@"$_"];
    
    while (r.location != NSNotFound) {
        NSRange r2 = [_l2 rangeOfString:@"_$" options:NSLiteralSearch range:NSMakeRange(r.location, _l2.length - r.location)];
        if(r2.location == NSNotFound) [_l2 replaceCharactersInRange:r withString:@""];
        else [_l2 replaceCharactersInRange:NSMakeRange(r.location, r2.location + r2.length - r.location) withString:@""];
        r = [_l2 rangeOfString:@"$_"];
    }
    l2 = [NSString stringWithString:_l2];
    l2 = [l2 stringByReplacingOccurrencesOfString:(XCODE_COLORS_RESET) withString:@""];
    l2 = [l2 stringByReplacingOccurrencesOfString:(XCODE_COLORS_RESET) withString:@""];
    return l2;
}
- (NSString *_Nullable) trim:(NSString *_Nullable)str;
{
    if(!str) return self;
    NSString *s = [self trimPrefix:str];
    s = [s trimSuffix:str];
    return s;
}
- (NSString *_Nullable) trimSuffix:(NSString *_Nullable)suffix;
{
    if(!suffix || ![self hasSuffix:suffix]) return self;
    int l = (int)suffix.length;
    NSString *s = [[self copy] autorelease];
    while ([s hasSuffix:suffix]) s = [s substringToIndex:s.length - l];
    return s;
}
- (NSString *_Nullable) trimPrefix:(NSString *_Nullable)prefix;
{
    if(!prefix || ![self hasPrefix:prefix]) return self;
    int l = (int)prefix.length;
    NSString *s = [[self copy] autorelease];
    while ([s hasPrefix:prefix]) s = [s substringFromIndex:l];
    return s;
}
- (NSString *_Nullable) deleteSuffix:(NSString *_Nullable)suffix;
{
    if(![self hasSuffix:suffix]) return self;
    return [self substringToIndex:self.length - suffix.length];
}
- (NSString *_Nullable) deletePrefix:(NSString *_Nullable)prefix;
{
    if(![self hasPrefix:prefix]) return self;
    return [self substringFromIndex:prefix.length];
}
- (NSString *) suffix:(NSString *)suffix;
{
    return !suffix ? [[self copy] autorelease] : [self stringByAppendingString:suffix];
}
- (NSString *) prefix:(NSString *)prefix;
{
    return !prefix ? [[self copy] autorelease] : [prefix stringByAppendingString:self];
}
- (NSString *) wrap:(NSString *)wrapper;
{
    return !wrapper ? self : [NSString stringWithFormat:@"%@%@%@", wrapper, self, wrapper];
}
- (NSString *) firstLine;
{
    return [[self componentsSeparatedByString:@"\n"] objectAtIndex:0];
}
+ (instancetype)format:(NSString *)format, ...;
{
    va_list args;
    va_start(args, format);
    NSString *s=[[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [s autorelease];
}
- (instancetype)prepend:(NSString *)format, ...;
{
    va_list args;
    va_start(args, format);
    NSString *s=[[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [[s autorelease] stringByAppendingString:self];
}
- (instancetype)append:(NSString *)format, ...;
{
    va_list args;
    va_start(args, format);
    NSString *s=[[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self stringByAppendingString:[s autorelease]];
}
- (instancetype _Nullable)format:(NSString *)format;
{
    return !format ? self : [NSString stringWithFormat:format, self];
}
- (instancetype _Nullable)with:(nullable id)value, ...;
{
    
    NSMutableArray *arguments = value ? [NSMutableArray arrayWithObject:value] : [NSMutableArray array];
    va_list args;
    va_start(args, value);
    
    id arg = nil;
    
    while(( arg = va_arg(args, id))){
        [arguments addObject:arg];
    }
    
    
    va_end(args);
    
    if ( arguments.count > 10 ) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Maximum of 10 arguments allowed" userInfo:@{@"collection": arguments}];
    }
    NSArray* a = [arguments arrayByAddingObjectsFromArray:@[@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X"]];
    return [NSString stringWithFormat:self, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10] ];
    
//    
//    
//    __unsafe_unretained id  * argList = (__unsafe_unretained id  *) calloc(1UL, sizeof(id) * arguments.count);
//    for (NSInteger i = 0; i < arguments.count; i++) {
//        argList[i] = arguments[i];
//    }
//
//    
//    NSString *s=[[NSString alloc] initWithFormat:self, *argList];
//    free(argList);
//    return [s autorelease];
}

- (NSString *) difference:(NSString *)compare;
{
    NSString *__self = [[self cleanString] inlineNoColorString];
    compare = [[compare cleanString] inlineNoColorString];
    NSString *d = nil;
    for (int i=0; i<__self.length; i++) {
        NSString *s = [__self substringWithRange:NSMakeRange(i, 1)];
        if(compare.length<i)
        {
            return [NSString stringWithFormat:@"Reached String.End:   '%@'", [__self substringFromIndex:i]];
        }
        NSString *c = [compare substringWithRange:NSMakeRange(i, 1)];
        if([s isEqualToString:c]) continue;
        return [NSString stringWithFormat:@"Diff: %d:  \n'%@'\n\n\n'%@'", i,[__self substringFromIndex:i-5],[compare substringFromIndex:i-5]];
    }
    if(compare.length > __self.length)
    {
        return [NSString stringWithFormat:@"Compare End:   '%@'", [compare substringFromIndex:compare.length - (compare.length-__self.length)]];
    }
    return nil;
}
//
//  NSString-Levenshtein.m
//
//  Created by Rick Bourner on Sat Aug 09 2003.
//  Rick@Bourner.com

// calculate the mean distance between all words in stringA and stringB
- (float) compareWithString: (NSString *) stringB
{
    float averageSmallestDistance = 0.0;
    float smallestDistance;
    float distance;
    
    NSMutableString * mStringA = [[NSMutableString alloc]  initWithString: self];
    NSMutableString * mStringB = [[NSMutableString alloc]  initWithString: stringB];
    
    
    // normalize
    [mStringA replaceOccurrencesOfString:@"\n"
                              withString: @" "
                                 options: NSLiteralSearch
                                   range: NSMakeRange(0, [mStringA  length])];
    
    [mStringB replaceOccurrencesOfString:@"\n"
                              withString: @" "
                                 options: NSLiteralSearch
                                   range: NSMakeRange(0, [mStringB  length])];
    
    NSArray * arrayA = [mStringA componentsSeparatedByString: @" "];
    NSArray * arrayB = [mStringB componentsSeparatedByString: @" "];
    
    NSEnumerator * emuA = [arrayA objectEnumerator];
    NSEnumerator * emuB;
    
    NSString * tokenA = NULL;
    NSString * tokenB = NULL;
    
    // O(n*m) but is there another way ?!?
    while ( tokenA = [emuA nextObject] ) {
        
        emuB = [arrayB objectEnumerator];
        smallestDistance = 99999999.0;
        
        while ( tokenB = [emuB nextObject] )
            if ( (distance = [tokenA compareWithWord: tokenB] ) <  smallestDistance )
                smallestDistance = distance;
        
        averageSmallestDistance += smallestDistance;
        
    }
    
    [mStringA release];
    [mStringB release];
    
    return averageSmallestDistance / [arrayA count];
}


// calculate the distance between two string treating them eash as a
// single word
- (float) compareWithWord: (NSString *) stringB
{
    // normalize strings
    NSString * stringA = [NSString stringWithString: self];
    [stringA stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [stringB stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    stringA = [stringA lowercaseString];
    stringB = [stringB lowercaseString];
    
    
    // Step 1
    int k, i, j, cost, * d, distance;
    
    int n = [stringA length];
    int m = [stringB length];
    
    if( n++ != 0 && m++ != 0 ) {
        
        d = malloc( sizeof(int) * m * n );
        
        // Step 2
        for( k = 0; k < n; k++)
            d[k] = k;
        
        for( k = 0; k < m; k++)
            d[ k * n ] = k;
        
        // Step 3 and 4
        for( i = 1; i < n; i++ )
            for( j = 1; j < m; j++ ) {
                
                // Step 5
                if( [stringA characterAtIndex: i-1] ==
                   [stringB characterAtIndex: j-1] )
                    cost = 0;
                else
                    cost = 1;
                
                // Step 6
                d[ j * n + i ] = [self smallestOf: d [ (j - 1) * n + i ] + 1
                                            andOf: d[ j * n + i - 1 ] +  1
                                            andOf: d[ (j - 1) * n + i -1 ] + cost ];
            }
        
        distance = d[ n * m - 1 ];
        
        free( d );
        
        return distance;
    }
    return 0.0;
}


// return the minimum of a, b and c
- (int) smallestOf: (int) a andOf: (int) b andOf: (int) c
{
    int min = a;
    if ( b < min )
        min = b;
    
    if( c < min )
        min = c;
    
    return min;
}
- (NSString* _Nullable)stringByRemovingBlankLines;
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n+" options:0 error:NULL];
    return  [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@"\n"];
    
//    
//    NSScanner *scan = [NSScanner scannerWithString:self];
//    NSMutableString *string = NSMutableString.new;
//    while (!scan.isAtEnd) {
//        [scan scanCharactersFromSet:NSCharacterSet.newlineCharacterSet intoString:NULL];
//        NSString *line = nil;
//        [scan scanUpToCharactersFromSet:NSCharacterSet.newlineCharacterSet intoString:&line];
//        if (line) [string appendFormat:@"%@\n",line];
//    }
//    if (string.length) [string deleteCharactersInRange:(NSRange){string.length-1,1}]; // drop last '\n'
//    return string;
}

@end

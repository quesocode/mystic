//
//  NSDictionary+Merge.m
//  Mystic
//
//  Created by travis weerts on 3/29/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NSDictionary+Merge.h"
#import "NSArray+Mystic.h"
#import "NSString+Mystic.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2 {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if (![dict1 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * newVal = [[dict1 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
                [result setObject: newVal forKey: key];
            } else {
                [result setObject: obj forKey: key];
            }
        }
    }];
    
    return (NSDictionary *) [[result mutableCopy] autorelease];
}
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}



// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


-(NSString*) urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}
- (NSMutableDictionary *) makeMutable;
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
    for (id key in self.allKeys) {
        id obj = self[key];
        if([obj isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *newObj = [(NSDictionary *)obj makeMutable];
            [newDict setObject:newObj forKey:key];
        }
        else if([obj isKindOfClass:[NSArray class]])
        {
            NSMutableArray *newObj = [(NSArray *)obj makeMutable];
            [newDict setObject:newObj forKey:key];
        }
    }
    return newDict;
}

- (NSDictionary *) makeKeysNumeric;
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        id obj = [self objectForKey:key];
        if([obj isKindOfClass:[NSDictionary class]])
        {
            obj = [(NSDictionary *)obj makeKeysNumeric];
        }
        else if([obj isKindOfClass:[NSArray class]])
        {
            NSMutableArray *nobj = [NSMutableArray array];
            for (id obj2 in ((NSArray *)obj)) {
                if([obj2 isKindOfClass:[NSDictionary class]])
                {
                    obj2 = [(NSDictionary *)obj2 makeKeysNumeric];
                }
                [nobj addObject:obj2];
            }
            obj = nobj;
        }
        
        if(key.isAllDigits)
        {
            [newDict setObject:obj forKey:@(key.intValue)];
        }
        else
        {
            [newDict setObject:obj forKey:key];
        }
    }
    
    
    return newDict;
}

@end


// edit requires at least 6 characters, I only needed 1

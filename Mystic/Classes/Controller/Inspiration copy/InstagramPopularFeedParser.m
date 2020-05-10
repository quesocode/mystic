//
//  InstagramPopularFeedParser.m
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import "InstagramPopularFeedParser.h"

@implementation InstagramPopularFeedParser
@synthesize delegate;

-(void)parseURL:(NSURL*)url
{
    NSData* data = [NSData dataWithContentsOfURL:url];
    //NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",jsonString);
    
    if (data) {
        NSError* error = nil;
        NSDictionary* jsondict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            [self.delegate didFailParsing:error];
        }
        else{
            NSArray* array = [jsondict valueForKey:@"data"];
            [self.delegate didFinishParsing:array];
        }
    }
    else
    {
        [self.delegate didFailParsing:nil];
    }
    
    
}

@end

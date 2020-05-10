//
//  InstagramPopularFeedParser.h
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstagramPopularFeedParserDelegate;
@interface InstagramPopularFeedParser : NSObject

@property (nonatomic, assign) __unsafe_unretained id delegate;

-(void)parseURL:(NSURL*)url;

@end

@protocol InstagramPopularFeedParserDelegate <NSObject>
-(void)didFinishParsing:(NSArray*)posts;
-(void)didFailParsing:(NSError*)error;
@end

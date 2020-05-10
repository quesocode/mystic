//
//  PopularFeedViewController.h
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramPopularFeedParser.h"

@interface PopularFeedViewController : UITableViewController <InstagramPopularFeedParserDelegate>
@property (nonatomic, strong) NSArray* posts;
@end

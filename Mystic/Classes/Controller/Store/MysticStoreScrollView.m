//
//  MysticStoreScrollView.m
//  Mystic
//
//  Created by Travis A. Weerts on 6/8/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticStoreScrollView.h"

@implementation MysticStoreScrollView
- (instancetype) init;
{
    self = [super init];
    if(!self) return nil;
    self.pagingEnabled = YES;
    return self;
}

@end



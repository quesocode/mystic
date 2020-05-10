//
//  MysticStore.m
//  Mystic
//
//  Created by Travis A. Weerts on 7/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticStore.h"
#import "MysticUser.h"
#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"

@implementation MysticStore

+ (BOOL) hasPurchased:(NSString *)productID;
{
    if(!productID) return YES;
    BOOL purchased2 = NO;
    RMStoreKeychainPersistence *persistence = [RMStore defaultStore].transactionPersistor;
    BOOL purchased1 = [persistence isPurchasedProductOfIdentifier:productID];
    if(!purchased1 && [MysticUser remembers:productID]) purchased2 = YES;
//    DLog(@"has purchased: %@ %@ %@", MBOOL(purchased1), MBOOL(purchased2), productID);
    return purchased1 || purchased2;
}
+ (NSDictionary *) product:(NSString *)productId;
{
    NSString *localPath = [[NSBundle mainBundle] pathForResource:@"store" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:localPath];
    NSDictionary *item = [data[@"items"] objectForKey:productId];
    if(item)
    {
        NSMutableDictionary *_item = [NSMutableDictionary dictionaryWithDictionary:item];
        [_item setObject:productId forKey:@"key"];
        item = _item;
    }
    return item;
    
}
@end



//
//  MysticObjectItem.h
//  Mystic
//
//  Created by Me on 8/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"


@interface MysticObjectItem : NSObject <NSMutableCopying>
{
//    NSDictionary *_info;
//    MysticCollectionItemType _type;

}


@property (nonatomic, retain) NSMutableDictionary *info;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) MysticCollectionItemType type;

+ (MysticCollectionItemType) typeOfBlockFromDictionary:(NSDictionary *)_info;
+ (id) itemWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;


- (id) objectForKey:(id)key;
- (id) valueForKey:(NSString *)key;
- (id) initWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;
- (void) prepare;
@end

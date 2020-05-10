//
//  MysticTag.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MysticGroup, MysticLayer;

@interface MysticTag : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * control;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * control_url;
@property (nonatomic, retain) NSNumber * available;
@property (nonatomic, retain) NSNumber * isPack;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) MysticGroup *group;
@property (nonatomic, retain) NSSet *layers;
@end

@interface MysticTag (CoreDataGeneratedAccessors)

- (void)addLayersObject:(MysticLayer *)value;
- (void)removeLayersObject:(MysticLayer *)value;
- (void)addLayers:(NSSet *)values;
- (void)removeLayers:(NSSet *)values;

@end

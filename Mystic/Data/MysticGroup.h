//
//  MysticGroup.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MysticLayer, MysticTag;

@interface MysticGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *layers;
@end

@interface MysticGroup (CoreDataGeneratedAccessors)

- (void)addTagsObject:(MysticTag *)value;
- (void)removeTagsObject:(MysticTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addLayersObject:(MysticLayer *)value;
- (void)removeLayersObject:(MysticLayer *)value;
- (void)addLayers:(NSSet *)values;
- (void)removeLayers:(NSSet *)values;

@end

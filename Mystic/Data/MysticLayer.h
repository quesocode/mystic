//
//  MysticLayer.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MysticGroup, MysticTag;

@interface MysticLayer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * blend;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * rating_votes;
@property (nonatomic, retain) NSNumber * rating_total;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * control;
@property (nonatomic, retain) NSString * control_file;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * preview;
@property (nonatomic, retain) NSString * thumb;
@property (nonatomic, retain) NSString * original;
@property (nonatomic, retain) NSString * sample;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * preset_intensity;
@property (nonatomic, retain) NSNumber * preset_sunshine;
@property (nonatomic, retain) NSNumber * preset_invert;
@property (nonatomic, retain) NSNumber * preset_blending;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * pinterest;
@property (nonatomic, retain) NSString * instagram;
@property (nonatomic, retain) NSString * email_subject;
@property (nonatomic, retain) NSString * email_to;
@property (nonatomic, retain) NSNumber * email_html;
@property (nonatomic, retain) NSString * email_cc;
@property (nonatomic, retain) NSString * email_bcc;
@property (nonatomic, retain) NSString * message_link;
@property (nonatomic, retain) NSString * folder;
@property (nonatomic, retain) NSString * newthumb;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * anchor;
@property (nonatomic, retain) NSNumber * colors;
@property (nonatomic, retain) NSString * hashtags;
@property (nonatomic, retain) NSNumber * stretch_mode;
@property (nonatomic, retain) NSString * alphaMask_url;
@property (nonatomic, retain) NSString * alphaMask_file;
@property (nonatomic, retain) NSNumber * fill_mode;
@property (nonatomic, retain) NSString * alphaMask;
@property (nonatomic, retain) NSNumber * uses;
@property (nonatomic, retain) NSString * backgroundColor;
@property (nonatomic, retain) NSString * controlImage;
@property (nonatomic, retain) NSString * controlImage_url;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * stretch_insets;
@property (nonatomic, retain) NSString * thumb_url;
@property (nonatomic, retain) MysticGroup *group;
@property (nonatomic, retain) NSOrderedSet *tags;
@end

@interface MysticLayer (CoreDataGeneratedAccessors)

- (void)insertObject:(MysticTag *)value inTagsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTagsAtIndex:(NSUInteger)idx;
- (void)insertTags:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTagsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTagsAtIndex:(NSUInteger)idx withObject:(MysticTag *)value;
- (void)replaceTagsAtIndexes:(NSIndexSet *)indexes withTags:(NSArray *)values;
- (void)addTagsObject:(MysticTag *)value;
- (void)removeTagsObject:(MysticTag *)value;
- (void)addTags:(NSOrderedSet *)values;
- (void)removeTags:(NSOrderedSet *)values;
@end

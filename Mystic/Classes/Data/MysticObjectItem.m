//
//  MysticObjectItem.m
//  Mystic
//
//  Created by Me on 8/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticObjectItem.h"

@implementation MysticObjectItem

@synthesize info = _info, type=_type;

+ (id) dictionaryWithDictionary:(MysticObjectItem *)item;
{
    return [NSMutableDictionary dictionaryWithDictionary:item.info];
}
+ (id) itemWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;
{
    Class blockClass = [self class];
    MysticCollectionItemType theType = [blockClass typeOfBlockFromDictionary:info];
    
    MysticObjectItem *entry = [[blockClass alloc] initWithDictionary:info indexPath:indexPath];
    [entry setType:theType];
    [entry prepare];
    return [entry autorelease];
}

+ (MysticCollectionItemType) typeOfBlockFromDictionary:(NSDictionary *)_info;
{
    MysticCollectionItemType _type = MysticCollectionItemTypeUnknown;
    if(!_info) return _type;
    if([_info objectForKey:kMysticBlockType])
    {
        NSString *typeStr = [_info objectForKey:kMysticBlockType];
        if([typeStr isEqualToString:kMysticBlockText])
        {
            _type = MysticCollectionItemTypeText;
        }
        else if([typeStr isEqualToString:kMysticBlockAttrText])
        {
            _type = MysticCollectionItemTypeAttributedText;
        }
        else if([typeStr isEqualToString:kMysticBlockVideoUrl])
        {
            _type = MysticCollectionItemTypeVideo;
        }
        else if([typeStr isEqualToString:kMysticBlockImageUrl])
        {
            _type = MysticCollectionItemTypeImage;
        }
        else if([typeStr isEqualToString:kMysticBlockHTML])
        {
            _type = MysticCollectionItemTypeHTML;
        }
        else if([typeStr isEqualToString:kMysticBlockBlocks])
        {
            _type = MysticCollectionItemTypeBlock;
        }
        else if([typeStr isEqualToString:kMysticBlockColor])
        {
            _type = MysticCollectionItemTypeColor;
        }
        else if([typeStr isEqualToString:kMysticBlockColors])
        {
            _type = MysticCollectionItemTypeGradient;
        }
        else if([typeStr isEqualToString:kMysticBlockLinkUrl])
        {
            _type = MysticCollectionItemTypeLink;
        }
    }
    else
    {
        if([_info objectForKey:kMysticBlockText])
        {
            _type = MysticCollectionItemTypeText;
        }
        else if([_info objectForKey:kMysticBlockAttrText])
        {
            _type = MysticCollectionItemTypeAttributedText;
        }
        else if([_info objectForKey:kMysticBlockVideoUrl])
        {
            _type = MysticCollectionItemTypeVideo;
        }
        else if([_info objectForKey:kMysticBlockImageUrl])
        {
            _type = MysticCollectionItemTypeImage;
        }
        else if([_info objectForKey:kMysticBlockColor])
        {
            _type = MysticCollectionItemTypeColor;
        }
        else if([_info objectForKey:kMysticBlockColors])
        {
            _type = MysticCollectionItemTypeGradient;
        }
        else if([_info objectForKey:kMysticBlockHTML])
        {
            _type = MysticCollectionItemTypeHTML;
        }
        else if([_info objectForKey:kMysticBlockBlocks])
        {
            _type = MysticCollectionItemTypeBlock;
        }
        else if([_info objectForKey:kMysticBlockLinkUrl])
        {
            _type = MysticCollectionItemTypeLink;
        }
    }
    return _type;
}


- (void) dealloc;
{
    [_indexPath release];
    [_info release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        self.info = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
}
- (id) initWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;
{
    self = [self init];
    if(self)
    {
        if(info) self.info = [NSMutableDictionary dictionaryWithDictionary:info];
        self.indexPath = indexPath;
    }
    return self;
}
- (void) prepare;
{
    
}

- (void) setType:(MysticCollectionItemType)type;
{
    _type = type;
}
- (MysticCollectionItemType) type;
{
    if(_type) return _type;
    _type = [[self class] typeOfBlockFromDictionary:self.info];
    
    return _type;
}


- (id) objectForKey:(id)key;
{
    return [self.info objectForKey:key];
}
- (id) valueForKey:(NSString *)key;
{
    return [self.info valueForKey:key];
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithZone:zone];
}
- (id)copyWithZone:(NSZone *)zone;
{
    return [[[self class] itemWithDictionary:[[self.info copy] autorelease] indexPath:[[self.indexPath copy] autorelease]] retain];
}
- (NSArray *) allKeys;
{
    return [self.info allKeys];
}
- (NSArray *) allValues;
{
    return [self.info allValues];
}
- (NSArray *)allKeysForObject:(id)anObject;
{
    return [self.info allKeysForObject:anObject];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray;
{
    [self.info removeObjectsForKeys:keyArray];
}

- (void) removeObjectForKey:(id)obj;
{
    [self.info removeObjectForKey:obj];
}

- (NSUInteger)count;
{
    return [self.info count];
}
- (NSEnumerator *)keyEnumerator;
{
    return [self.info keyEnumerator];
}

- (void)setObject:(id)anObject forKey:(id < NSCopying >)aKey;
{
    [self.info setObject:anObject forKey:aKey];
}
@end

//
//  MysticCollectionItem.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionItem.h"
#import "UIColor+Mystic.h"

@interface MysticCollectionItem ()
{
//    NSDictionary *_info;
//    MysticCollectionItemType _type;
    MysticTableLayout _layout;
    CGSize _size;
}

@end

@implementation MysticCollectionItem

@dynamic indexPath;

+ (id) collectionItemWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;
{
    return [[self class] itemWithDictionary:info indexPath:indexPath];
}




- (void) dealloc;
{
    [_gradient release];
    [_sectionTitle release];
    [super dealloc];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _size = CGSizeUnknown;
        _layout = (MysticTableLayout){-1,-1};
    }
    return self;
}

- (void) prepare;
{
    [super prepare];
}

//- (NSDictionary *) info;
//{
//    return self.info;
//}

- (NSString *) sectionTitle;
{
    if(_sectionTitle) return _sectionTitle;
    return [self.info objectForKey:@"sectionTitle"] ? [self.info objectForKey:@"sectionTitle"] : self.title;
}

- (NSString *) tag;
{
    if([self.info objectForKey:kMysticBlockTagId]) return [self.info objectForKey:kMysticBlockTagId];
    NSString *bTag = @"";
    switch (self.type)
    {
        case MysticCollectionItemTypeGradient:
            bTag = [self.colorStrings componentsJoinedByString:@"-"];
            return bTag;
            break;
        case MysticCollectionItemTypeColor:
            bTag = self.colorString;
            return bTag;

            break;
        default:
            bTag = self.title;
            break;
    }
    return [bTag md5];
}

- (NSString *) title;
{
    return [self.info objectForKey:kMysticBlockTitle];
}
- (NSString *) subtitle;
{
    return [self.info objectForKey:kMysticBlockSubTitle];
}

- (NSString *) filename;
{
    return [self.info objectForKey:kMysticBlockFilename];
}

- (NSString *) file;
{
    return [self.info objectForKey:kMysticBlockFilepath];
}

- (NSString *) text;
{
    return [self.info objectForKey:kMysticBlockText];
}

- (BOOL) enabled;
{
    return [self.info objectForKey:kMysticBlockEnabled] ? [[self.info objectForKey:kMysticBlockEnabled] boolValue] : YES;
}
- (NSString *) imageURLString;
{
    return [self.info objectForKey:kMysticBlockImageUrl];
}

- (NSString *) thumbnailURLString;
{
    return [self.info objectForKey:kMysticBlockThumbnailUrl] ? [self.info objectForKey:kMysticBlockThumbnailUrl] : self.imageURLString;
}

- (NSString *) highResolutionURLString;
{
    return [self.info objectForKey:kMysticBlockImageHighUrl];
}
- (NSString *) fullResolutionURLString;
{
    return [self.info objectForKey:kMysticBlockImageFullUrl];
}

- (NSString *) videoURLString;
{
    return [self.info objectForKey:kMysticBlockVideoUrl];
}

- (NSString *) linkURLString;
{
    return [self.info objectForKey:kMysticBlockLinkUrl];
}

- (NSString *) htmlString;
{
    return [self.info objectForKey:kMysticBlockHTML];
}

- (NSAttributedString *) attributedText;
{
    return [self.info objectForKey:kMysticBlockAttrText];
}



- (NSURL *) imageURL;
{
    return !self.imageURLString ? nil : [NSURL URLWithString:self.imageURLString];
}
- (NSURL *) thumbnailURL;
{
    id t = self.thumbnailURLString;
    return !t ? nil : [NSURL URLWithString:t];
}
- (NSURL *) fullResolutionURL;
{
    return !self.fullResolutionURLString ? nil : [NSURL URLWithString:self.fullResolutionURLString];
}
- (NSURL *) highResolutionURL;
{
    return !self.highResolutionURLString ? nil : [NSURL URLWithString:self.highResolutionURLString];
}
- (NSURL *) linkURL;
{
    return !self.linkURLString ? nil : [NSURL URLWithString:self.linkURLString];
}
- (NSURL *) videoURL;
{
    return !self.videoURLString ? nil : [NSURL URLWithString:self.videoURLString];
}

- (NSString *) colorString;
{
    return [self.info objectForKey:kMysticBlockColor];
}

- (NSString *) displayColorString;
{
    return [self.info objectForKey:kMysticBlockDisplayColor] ? [self.info objectForKey:kMysticBlockDisplayColor] : nil;
}

- (UIColor *) color;
{
    
    return self.colorString ? [UIColor string:self.colorString] : nil;
}
- (UIColor *) displayColor;
{
    
    return self.displayColorString ? [UIColor string:self.displayColorString] : self.color;
}
- (NSArray *) colorStrings;
{
    return [self.info objectForKey:kMysticBlockColors] ? [self.info objectForKey:kMysticBlockColors] : (self.colorString ? [NSArray arrayWithObject:self.colorString] : nil);
}
- (NSArray *) colors;
{
    NSMutableArray *cols = [NSMutableArray array];
    for (NSString *colStr in self.colorStrings) {
        UIColor *c = [UIColor string:colStr];
        if(c) [cols addObject:c];
    }
    return cols;
}

- (MysticGradient *) gradient;
{
    if(!_gradient)
    {
        _gradient = [[MysticGradient gradientWithColors:self.colorStrings] retain];
    }
    return _gradient;
}
- (NSArray *) gradientColors;
{
    if(!self.gradient)
    {
        self.gradient = [MysticGradient gradientWithColors:self.colorStrings];
    }
    return self.gradient.colors;
}

- (NSArray *) gradientLocations;
{
    if(!self.gradient)
    {
        self.gradient = [MysticGradient gradientWithColors:self.colorStrings];
    }
    return self.gradient.locations;
}


- (NSArray *) blocks;
{
    NSMutableArray *blocks = [NSMutableArray array];
    NSArray *blocksInfo = [self.info objectForKey:kMysticBlockBlocks];
    int _row = 0;
    int _section = 0;
    for (NSDictionary *aBlockInfo in blocksInfo) {
        [blocks addObject:[[self class] itemWithDictionary:aBlockInfo indexPath:[NSIndexPath indexPathForRow:_row inSection:_section]]];
        _row++;
    }
    return blocks;
}


- (MysticTableLayout) layout;
{
    if(_layout.rows != -1 && _layout.columns != -1) return _layout;
    MysticTableLayout layout = (MysticTableLayout){1,1};
    NSString *layoutStr = [self.info objectForKey:kMysticBlockLayout];
    NSArray *layoutArray = [layoutStr componentsSeparatedByString:@","];
    if(layoutArray.count >= 1)
    {
        layout.rows = [[layoutArray objectAtIndex:0] integerValue];
        layout.columns = layoutArray.count > 1 ? [[layoutArray objectAtIndex:1] integerValue] : layout.rows;
    }
    _layout = layout;
    return _layout;
}

- (CGSize) size;
{
    if(!CGSizeEqualToSize(CGSizeUnknown, _size)) return _size;
    CGSize size = CGSizeUnknown;
    NSString *layoutStr = [self.info objectForKey:kMysticBlockSize];
    NSArray *layoutArray = [layoutStr componentsSeparatedByString:@","];
    if(layoutArray.count >= 1)
    {
        size.width = [[layoutArray objectAtIndex:0] floatValue];
        size.height = layoutArray.count > 1 ? [[layoutArray objectAtIndex:1] floatValue] : size.width;
    }
    _size = CGSizeEqualToSize(CGSizeUnknown, size) ? CGSizeZero : size;
    return _size;
}
- (void) fullResolutionImage:(MysticBlockObject)finished;
{
    if(!finished) return;
    __unsafe_unretained __block MysticBlockObject _finished = Block_copy(finished);
    __unsafe_unretained __block MysticCollectionItem *weakSelf =self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *f = weakSelf.fullResolutionImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            _finished(f);
            Block_release(_finished);
        });
        
    });
}

- (UIImage *) fullResolutionImage;
{
    switch (self.type) {
        case MysticCollectionItemTypeGradient:
        {
            if(self.colorStrings)
            {
                CGSize maxSize = [MysticImage maximumImageSize];
                UIImage *img = [MysticImage backgroundImageWithColor:self.colorStrings size:maxSize scale:1];
                return img;
            }
            break;
        }
        case MysticCollectionItemTypeColor:
        {
            if(self.color)
            {
                CGSize maxSize = [MysticImage maximumImageSize];
                UIImage *img = [MysticImage backgroundImageWithColor:self.color size:maxSize scale:1];
                return img;
            }
            break;
        }
        default: break;
    }
    return nil;
}



@end

//
//  MysticCollectionItem.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//typedef enum {
//    MysticCollectionItemTypeUnknown = 0,
//    MysticCollectionItemTypeBlock,
//    MysticCollectionItemTypeText,
//    MysticCollectionItemTypeImage,
//    MysticCollectionItemTypeAttributedText,
//    MysticCollectionItemTypeLink,
//    MysticCollectionItemTypeButton,
//    MysticCollectionItemTypeHTML,
//    MysticCollectionItemTypeVideo,
//    MysticCollectionItemTypeColor,
//    MysticCollectionItemTypeGradient,
//    
//} MysticCollectionItemType;


#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "MysticObjectItem.h"
#import "MysticGradient.h"

@interface MysticCollectionItem : MysticObjectItem


@property (nonatomic, readonly) MysticTableLayout layout;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, readonly) NSString *filename, *file;
@property (nonatomic, readonly) NSString *imageURLString, *fullResolutionURLString, *highResolutionURLString, *thumbnailURLString;
@property (nonatomic, readonly) NSString *linkURLString;
@property (nonatomic, readonly) NSString *colorString;
@property (nonatomic, readonly) NSString *tag;

@property (nonatomic, readonly) NSString *displayColorString;

@property (nonatomic, readonly) NSString *htmlString;
@property (nonatomic, readonly) NSString *videoURLString;
@property (nonatomic, readonly) NSString *text, *title, *subtitle;
@property (nonatomic, readonly) NSAttributedString *attributedText;
@property (nonatomic, readonly) NSURL *imageURL, *thumbnailURL, *highResolutionURL, *fullResolutionURL;
@property (nonatomic, readonly) NSURL *linkURL;
@property (nonatomic, readonly) NSURL *videoURL;
@property (nonatomic, readonly) NSArray *blocks;
//@property (nonatomic, readonly) NSDictionary *info;
@property (nonatomic, readonly) UIColor *color, *displayColor;
@property (nonatomic, readonly) NSArray *colors;
@property (nonatomic, readonly) NSArray *colorStrings;
@property (nonatomic, readonly) UIImage *fullResolutionImage;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) NSString *sectionTitle;
@property (nonatomic, retain) MysticGradient *gradient;

+ (id) collectionItemWithDictionary:(NSDictionary *)info indexPath:(NSIndexPath *)indexPath;

- (void) fullResolutionImage:(MysticBlockObject)finished;
- (void) prepare;
@end




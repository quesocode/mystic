//
//  MysticInstagramPhoto.h
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MysticInstagramPhoto : NSObject;

@property (nonatomic, readonly) CGSize previewSize, size, thumbnailSize;
@property (nonatomic, retain) NSDictionary *info;
@property (nonatomic, readonly) UIImage *placeHolderImage;
@property (nonatomic, readonly) NSURL *url, *previewUrl, *thumbnailUrl, *authorProfileImageUrl, *authorWebUrl;
@property (nonatomic, readonly) NSString *authorUsername;
@property (nonatomic, readonly) NSDictionary *author;
+ (id) photoWithDictionary:(NSDictionary *)info;


@end

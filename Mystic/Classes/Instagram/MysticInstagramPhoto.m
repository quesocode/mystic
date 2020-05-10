//
//  MysticInstagramPhoto.m
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticInstagramPhoto.h"

@implementation MysticInstagramPhoto

+ (id) photoWithDictionary:(NSDictionary *)info;
{
    MysticInstagramPhoto *photo = [[MysticInstagramPhoto alloc] init];
    photo.info = info;
    return photo;
}

- (CGSize) previewSize;
{
    return CGSizeMake([[[[self.info objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"width"] floatValue], [[[[self.info objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"height"] floatValue]);
}

- (CGSize) size;
{
    return CGSizeMake([[[[self.info objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"width"] floatValue], [[[[self.info objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"height"] floatValue]);
}

- (CGSize) thumbnailSize;
{
    return CGSizeMake([[[[self.info objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"width"] floatValue], [[[[self.info objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"height"] floatValue]);
}

- (UIImage *) placeHolderImage;
{
    return [UIImage imageNamed:@"photo-back.jpg"];
}
- (NSDictionary *) author;
{
    return [self.info objectForKey:@"user"];
}
- (NSString *) authorUsername;
{
    return [[self.info objectForKey:@"user"] objectForKey:@"username"];
}
- (NSURL *) authorProfileImageUrl;
{
    return [NSURL URLWithString:[[self.info objectForKey:@"user"] objectForKey:@"profile_picture"]];
}
- (NSURL *) authorWebUrl;
{
    return [NSURL URLWithString:[@"http://instagram.com/" stringByAppendingString:[[self.info objectForKey:@"user"] objectForKey:@"username"]]];
}
- (NSURL *) url;
{
    return [NSURL URLWithString:[[[self.info objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]];
}
- (NSURL *) thumbnailUrl;
{
    return [NSURL URLWithString:[[[self.info objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"]];
}
- (NSURL *) previewUrl;
{
    return [NSURL URLWithString:[[[self.info objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]];
}

- (NSString *) description;
{
    return [self.info description];
}
@end

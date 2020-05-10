//
//  InstagramPostCell.m
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import "InstagramPostCell.h"

@implementation InstagramPostCell
@synthesize avatarImageView;
@synthesize postImageView;
@synthesize usernameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)placeAvatarWithImage:(UIImage*)image
{
    self.avatarImageView.image = image;
}

-(void)placePostWithImage:(UIImage*)image
{
    self.postImageView.image = image;
}

-(void)downloadAvatar:(NSURL*)url
{
    NSData* data = [NSData dataWithContentsOfURL:url];
    UIImage* image = [UIImage imageWithData:data];
    [self performSelectorOnMainThread:@selector(placeAvatarWithImage:) withObject:image waitUntilDone:YES];
}

-(void)downloadPost:(NSURL*)url
{
    NSData* data = [NSData dataWithContentsOfURL:url];
    UIImage* image = [UIImage imageWithData:data];
    [self performSelectorOnMainThread:@selector(placePostWithImage:) withObject:image waitUntilDone:YES];
}

@end

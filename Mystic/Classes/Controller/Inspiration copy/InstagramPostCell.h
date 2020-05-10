//
//  InstagramPostCell.h
//  instagrampopular
//
//  Created by Bebek, Taha on 10/21/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramPostCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView* postImageView;
@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;

-(void)downloadAvatar:(NSURL*)url;
-(void)downloadPost:(NSURL*)url;

@end

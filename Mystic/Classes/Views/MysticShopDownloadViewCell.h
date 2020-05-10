//
//  MysticShopDownloadViewCell.h
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticShopDownloadViewCell : UITableViewCell


@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, assign) float progress;

@property (nonatomic, retain) UILabel *topLabel;
@property (nonatomic, retain) UILabel *bottomLabel;
@property (nonatomic, assign) BOOL failed, finished;
@property (nonatomic, retain) UIImageView *thumbnailImageView;
@end

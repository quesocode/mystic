//
//  MysticShopDownloadViewCell.m
//  Mystic
//
//  Created by travis weerts on 3/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShopDownloadViewCell.h"
#import "UIColor+Mystic.h"

@implementation MysticShopDownloadViewCell

@synthesize progressView=_progressView, progress=_progress, topLabel=_topLabel, bottomLabel=_bottomLabel, thumbnailImageView=_thumbnailImageView, finished=_finished, failed=_failed;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = NO;
        
        UIColor *whiteTileImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-white-tile.png"]];
        UIView *backgroundView = nil;
        backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.backgroundColor = whiteTileImage;
        self.backgroundView =backgroundView;
        [backgroundView release];
        
        
        
        // Initialization code
        CGFloat height = 82.0f;
        CGFloat verticalPadding = 5.0f;
        CGFloat horizontalPadding = 15.0f;
        
        CGRect insetFrame = CGRectInset(self.contentView.bounds, 15, 10);
        CGRect progressFrame = insetFrame;
        
        
        
        
        progressFrame.size.width = insetFrame.size.width - 52.0f - horizontalPadding;
        progressFrame.size.height = 8.0f;
        progressFrame.origin.y = height/2 - 4.0f;
        progressFrame.origin.x = horizontalPadding + 52.0f + horizontalPadding;
        progressFrame.origin.y += 1;
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.frame = progressFrame;
        _progressView.progress = 0.0f;
        _progressView.trackTintColor = [UIColor mysticBlackColor];
        _progressView.progressTintColor = [UIColor mysticBlueColor];
        
        [self.contentView addSubview:_progressView];
        
        progressFrame = insetFrame;
        
        UIFont *topFont = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        progressFrame.size.height = topFont.lineHeight;
        progressFrame.origin.y = height/2 - _progressView.frame.size.height/2 - verticalPadding - topFont.lineHeight;
        progressFrame.origin.y += 1;
        progressFrame.origin.x = horizontalPadding + 52.0f + horizontalPadding;
        
        self.topLabel = [[[UILabel alloc] initWithFrame:progressFrame] autorelease];
        self.topLabel.backgroundColor = [UIColor clearColor];
        self.topLabel.textColor = [UIColor colorWithRed:(CGFloat)83/255 green:(CGFloat)82/255 blue:(CGFloat)80/255 alpha:1];
        self.topLabel.shadowColor = [UIColor whiteColor];
        self.topLabel.shadowOffset = CGSizeMake(0, 1);
        self.topLabel.font = topFont;
        self.topLabel.numberOfLines = 1;
        [self.contentView addSubview:self.topLabel];
        
        UIFont *bottomFont = [UIFont fontWithName:@"Helvetica" size:12];
        progressFrame.size.height = bottomFont.lineHeight;
        progressFrame.origin.y = height/2 + verticalPadding + _progressView.frame.size.height/2;
        progressFrame.origin.y += 1;
        
        self.bottomLabel = [[[UILabel alloc] initWithFrame:progressFrame] autorelease];
        self.bottomLabel.backgroundColor = [UIColor clearColor];
        self.bottomLabel.textColor = [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)185/255 blue:(CGFloat)180/255 alpha:1];
        self.bottomLabel.shadowColor = [UIColor whiteColor];
        self.bottomLabel.shadowOffset = CGSizeMake(0, 1);
        self.bottomLabel.font = bottomFont;
        self.bottomLabel.text = @"Downloading...";
        self.bottomLabel.numberOfLines = 1;
        [self.contentView addSubview:self.bottomLabel];
        
        
        
        progressFrame.origin.x = horizontalPadding;
        progressFrame.size.height = 58.0f;
        progressFrame.size.width = 56.0f;
        progressFrame.origin.y = self.topLabel.frame.origin.y - 3.0f;
        
        
        UIImageView *bgthumbView = [[UIImageView alloc] initWithFrame:progressFrame];
        bgthumbView.image = [UIImage imageNamed:@"shop-downloads-thumb-bg.jpg"];
        [self.contentView addSubview:bgthumbView];
        [bgthumbView release];
        progressFrame.origin.x = horizontalPadding + 2.0f;
        progressFrame.origin.y = self.topLabel.frame.origin.y - 1.0f;
        progressFrame.size.height = 52.0f;
        progressFrame.size.width = 52.0f;
        
        self.thumbnailImageView = [[[UIImageView alloc] initWithFrame:progressFrame] autorelease];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.thumbnailImageView];
        
    }
    return self;
}

- (void) setFailed:(BOOL)failed
{
    if(failed)
    {
        self.bottomLabel.textColor = [UIColor mysticRedColor];
        self.progressView.progressTintColor = [UIColor mysticRedColor];
        self.bottomLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    }
    _failed = failed;
}

- (void) setFinished:(BOOL)finished
{
    if(finished)
    {
        self.bottomLabel.textColor = [UIColor mysticGreenColor];
        self.bottomLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    }
    _finished = finished;
}

- (void) setProgress:(float)progress
{
    _progressView.progress = progress;
}

- (float) progress
{
    return _progressView.progress;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}

@end

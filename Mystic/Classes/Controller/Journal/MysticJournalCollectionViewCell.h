//
//  MysticJournalCollectionViewCell.h
//  Mystic
//
//  Created by Me on 3/29/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import <OHAttributedLabel/OHAttributedLabel.h>


@interface MysticJournalCollectionViewCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet OHAttributedLabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, readonly) BOOL hasBeenAdded;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) NSString * title;

@end

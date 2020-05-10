//
//  MysticJournalEntryCollectionViewCell.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticJournalCollectionViewCell.h"

@interface MysticJournalEntryCollectionViewCell : MysticJournalCollectionViewCell

@property (retain, nonatomic) IBOutlet OHAttributedLabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, readonly) BOOL hasBeenAdded;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) NSString * title;
@property (nonatomic, assign) NSString * text;


@end

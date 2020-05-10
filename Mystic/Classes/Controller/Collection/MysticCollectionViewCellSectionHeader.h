//
//  MysticCollectionViewCellSectionHeader.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticCollectionItem.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "MysticButton.h"


@interface MysticCollectionViewCellSectionHeader : UICollectionViewCell

@property (nonatomic, assign) MysticCollectionItem *collectionItem;
@property (nonatomic, retain) OHAttributedLabel *titleLabel;
@property (nonatomic, retain) MysticButton *button;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL showBorder, trackTouch;
@property (nonatomic, assign) CGFloat topBorderWidth;


- (void) commonStyle;
- (void) didTouch:(id)sender;

@end

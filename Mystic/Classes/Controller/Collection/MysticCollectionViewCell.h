//
//  MysticCollectionViewCell.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "MysticCollectionItem.h"
#import "UIImageView+WebCache.h"
#import "MysticConstants.h"
#import "MysticView.h"

@interface MysticCollectionViewCell : UICollectionViewCell

@property (retain, nonatomic) OHAttributedLabel *titleLabel;
@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) MysticView *bgView;

@property (nonatomic, assign) NSString * title, *text;
@property (nonatomic, assign) MysticCollectionItem *collectionItem;
@property (nonatomic, retain) UIView *overlayView;


- (void) commonStyle;
- (void) didSelect:(MysticBlockObjBOOL)selectBlock;
- (void) didDeselect:(MysticBlockObjBOOL)selectBlock;

@end

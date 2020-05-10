//
//  MysticPackPickerCell.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewCell.h"
#import "OHAttributedLabel.h"

@interface MysticPackPickerCell : MysticCollectionViewCell

@property (retain, nonatomic) OHAttributedLabel *titleLabel;
@property (readonly, nonatomic) UIImageView *normalImageView, *selectedImageView;
@property (nonatomic, assign) NSString * title;
@property (nonatomic, assign) BOOL shouldDraw;
@end

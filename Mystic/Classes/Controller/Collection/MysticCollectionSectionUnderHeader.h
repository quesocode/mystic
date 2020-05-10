//
//  MysticCollectionSectionUnderHeader.h
//  Mystic
//
//  Created by Me on 5/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "Mystic.h"

@interface MysticCollectionSectionUnderHeader : UICollectionViewCell

@property (nonatomic, retain) MysticBarButton *button;
@property (nonatomic, retain) UILabel *titleLabel;
- (void) setTitle:(NSString *)buttonTitle;
@end

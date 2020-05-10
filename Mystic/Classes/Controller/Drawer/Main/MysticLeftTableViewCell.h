//
//  MysticLeftTableViewCell.h
//  Mystic
//
//  Created by travis weerts on 8/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"

@interface MysticLeftTableViewCellBackgroundView : MysticBorderView

- (void) resetBackground;

@end

@interface MysticLeftTableViewCell : UITableViewCell
@property (nonatomic, assign) CGPoint layoutPadding;
@property (nonatomic, assign) UIEdgeInsets layoutImageInsets;
//@property (nonatomic, retain) MysticLeftTableViewCellBackgroundView *backgroundView;
@property (nonatomic, retain) UIView *backgroundView;

+ (Class) backgroundViewClass;
+ (CGSize) imageViewSize;

@end





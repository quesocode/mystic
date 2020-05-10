

//
//  MysticLayerTableViewCell.h
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLeftTableViewCell.h"
#import "Switch.h"
//@interface MysticLayerTableViewCellBackgroundView : MysticLeftTableViewCellBackgroundView
@interface MysticLayerTableViewCellBackgroundView : UIView
@property (nonatomic, assign) BOOL dashed, showBorder;
@property (nonatomic, assign) CGSize dashSize;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@end
@interface MysticLayerTableViewCell : MysticLeftTableViewCell

@property (nonatomic, retain) UIButton *imageViewBackground;

@property (nonatomic, retain) Switch *imageViewControl;
@property (nonatomic, assign) BOOL imageSwitchEnabled;

- (void) setImageViewBorderColor:(UIColor *)color;


@end

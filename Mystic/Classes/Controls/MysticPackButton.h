//
//  MysticPackButton.h
//  Mystic
//
//  Created by travis weerts on 9/3/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticButton.h"

@interface MysticPackButton : MysticButton
//@property (nonatomic, retain) UIView *backgroundView;
//@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) CGFloat imageViewAlphaOnSelect;
@property (nonatomic, assign) MysticObjectType objectType;
@property (nonatomic, assign) BOOL showBorder;
- (id)initWithFrame:(CGRect)frame type:(MysticObjectType)theType;

@end

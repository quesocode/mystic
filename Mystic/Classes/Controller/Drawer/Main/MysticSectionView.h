//
//  MysticSectionView.h
//  Mystic
//
//  Created by Travis on 10/15/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticSectionToolbar.h"



@interface MysticSectionView : UIView

@property (nonatomic, assign) NSString *text;
@property (nonatomic, retain) UILabel *label;

+ (CGFloat) height;

@end

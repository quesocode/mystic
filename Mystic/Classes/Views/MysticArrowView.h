//
//  MysticArrowView.h
//  Mystic
//
//  Created by Me on 10/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"

@interface MysticArrowView : MysticBorderView

@property (nonatomic, retain) UIColor *arrowColor, *arrowBorderColor;
@property (nonatomic, assign) MysticPosition arrowPosition, arrowAnchorPosition;

@end

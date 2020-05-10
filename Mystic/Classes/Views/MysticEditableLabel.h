//
//  MysticEditableLabel.h
//  Mystic
//
//  Created by travis weerts on 8/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"


@interface MysticEditableLabel : UILabel

@property (nonatomic) NSInteger numberOfBreaks;
@property (nonatomic, readonly) CGFloat fontSize;

- (CGSize) refresh;
- (CGRect) resize:(CGSize)newSize;

- (CGFloat) lineHeightInRect:(CGRect)frame;
- (CGSize) refresh:(CGRect)frame;

@end

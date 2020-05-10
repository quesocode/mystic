//
//  MysticGridView.h
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBorderView.h"

@interface MysticGridView : MysticBorderView

@property (nonatomic) NSInteger rows, columns;
//@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) BOOL useSquares;
//@property (nonatomic, retain) UIColor *borderColor, *centerBorderColor;
@property (nonatomic, retain) UIColor  *centerBorderColor;

@property (nonatomic) CGSize blockSize;

@end

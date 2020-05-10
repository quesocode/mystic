//
//  MysticPointColorBtn.h
//  Mystic
//
//  Created by Travis A. Weerts on 3/31/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticButton.h"

@interface MysticPointColorBtn : MysticButton

@property (nonatomic, assign) UIColor *color;
@property (nonatomic, retain) UIColor *color2;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) int focus;
+ (instancetype) color:(id)color point:(CGPoint)point size:(CGSize)size index:(int)index action:(MysticBlockSender)action;

@end

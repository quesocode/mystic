//
//  MysticAnimatedLabel.h
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticAnimatedLabel : UILabel

@property (nonatomic, assign) CGFloat duration;


- (void) setText:(NSString *)text animated:(BOOL)animated;


@end

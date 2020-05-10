//
//  UIImage (Mystic).h
//  Mystic
//
//  Created by Me on 9/24/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Mystic)

@property (nonatomic, readonly) UIImage *downsampleImage;

- (UIImage *)crop:(CGRect)rect;

@end

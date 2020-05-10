//
//  MysticImageView.h
//  Mystic
//
//  Created by Me on 3/25/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticImageView : UIImageView
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL animateImage;
- (void) setImage:(UIImage *)image duration:(NSTimeInterval)duration;

- (void) fadeToImage:(UIImage *)image duration:(NSTimeInterval)duration;
- (void) fadeToImage:(UIImage *)image;



@end

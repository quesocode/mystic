//
//  MysticResizableImageView.h
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticResizeableImageView : UIImageView

@property (nonatomic, copy) MysticBlockReturnsImage resizeImageBlock;

- (void) resize;
- (void) resize:(CGRect)bounds;
@end

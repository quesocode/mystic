//
//  MysticShapeView.h
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticResizeableLayer.h"
#import "MysticResizeableImageView.h"
#import "MysticLayers.h"

@class PackPotionOptionShape;

@interface MysticShapeView : MysticResizeableLayer

@property (nonatomic, retain) PackPotionOptionShape *option;
@property (nonatomic, readonly) MysticResizeableImageView *imageView;

@end

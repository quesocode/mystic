//
//  MysticDrawShapeView.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticDrawLayerView.h"
@class MysticLayerShapeView;

@interface MysticDrawShapeView : MysticDrawLayerView

@property (nonatomic, readonly) MysticLayerShapeView *shapeView;
- (UIImage *) contentImage:(CGSize)imageSize;

@end

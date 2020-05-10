//
//  MysticToolBlurView.h
//  Mystic
//
//  Created by Me on 2/9/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticView.h"

@interface MysticToolBlurView : MysticView
@property (nonatomic, assign) CGBlendMode blendMode;
@property (nonatomic, assign) BOOL dynamic;
@property (nonatomic, assign) float blurRadius;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, retain) UIImage *underlyingImage;
@property (nonatomic, retain) UIView *underlyingView;
@end

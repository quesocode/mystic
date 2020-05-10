//
//  MysticBackgroundView.h
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticBackgroundView : UIView

@property (nonatomic, assign) MysticBackgroundType backgroundType;
@property (nonatomic, assign) BOOL showBgImage;
@end
@interface MysticSameBackgroundView : UIView

@end

@interface MysticSameBackgroundViewLayer : CALayer

@end
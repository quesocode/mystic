//
//  PackPotionOptionLayer.h
//  Mystic
//
//  Created by Me on 11/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOption.h"
#import "MysticToggleButton.h"

@interface PackPotionOptionLayer : PackPotionOption


@property (nonatomic, retain) id view;
@property (nonatomic, assign) BOOL showControlEffectToggler, showControlEffectSettings;

@end

//
//  MysticSliderBlocks.h
//  Mystic
//
//  Created by Me on 3/23/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"



@interface MysticSliderBlocks : NSObject


+ (MysticSliderBlock) blockForSliderChange:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;
+ (MysticSliderBlock) blockForSliderFinish:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;
+ (MysticSliderBlock) blockForSliderStill:(MysticSlider *)slider option:(PackPotionOption *)option setting:(MysticObjectType)setting;

@end

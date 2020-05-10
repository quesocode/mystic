//
//  PackPotionOptionCamLayer.h
//  Mystic
//
//  Created by travis weerts on 3/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionImage.h"

@interface PackPotionOptionCamLayer : PackPotionOptionImage
+ (PackPotionOptionCamLayer *) optionWithName:(NSString *)name info:(NSDictionary *)info;
@property (nonatomic, assign) CGSize previewSize, sourceSize;
- (void) setMediaInfo:(NSArray *)info finished:(MysticBlock)finished;
@end

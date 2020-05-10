//
//  MysticBarButton.h
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticButton.h"

@interface MysticBarButton : MysticButton

@property (nonatomic) MysticToolType toolType, lastToolType;
@property (nonatomic) MysticObjectType objectType;

+ (MysticBarButton *) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType target:(id)target action:(SEL)action;

+ (MysticBarButton *) buttonWithIconType:(MysticIconType)iconType color:(id)colorOrColorType action:(MysticBlockSender)action;


@end

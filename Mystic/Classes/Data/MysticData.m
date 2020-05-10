//
//  MysticData.m
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticData.h"
#import "Mystic.h"

@implementation MysticData

+ (NSArray *) shapes;
{
    NSMutableArray *shapes = [NSMutableArray array];
    
    PackPotionOption *shape;
    
    shape = [PackPotionOption optionWithName:@"sextagon" image:@(MysticIconTypeSextagon) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"round star" image:@(MysticIconTypeStarRound) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"heart" image:@(MysticIconTypeHeart) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"chat" image:@(MysticIconTypeChat) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"star" image:@(MysticIconTypeStar) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    
    
    shape = [PackPotionOption optionWithName:@"rect" image:@(MysticIconTypeRectRound) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    
    shape = [PackPotionOption optionWithName:@"star fat" image:@(MysticIconTypeStarFat) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"sticker" image:@(MysticIconTypeSticker) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"circle" image:@(MysticIconTypeCircle) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"square" image:@(MysticIconTypeSquare) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    
    
    shape = [PackPotionOption optionWithName:@"pentagon" image:@(MysticIconTypePentagon) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    shape = [PackPotionOption optionWithName:@"logo" image:@(MysticIconTypeLogo) type:MysticObjectTypeShape info:nil];
    [shapes addObject:shape];
    
    
    
    return shapes;
}

@end

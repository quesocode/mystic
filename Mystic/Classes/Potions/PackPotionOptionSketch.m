//
//  PackPotionOptionSketch.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/10/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "PackPotionOptionSketch.h"
#import "MysticUser.h"

@implementation PackPotionOptionSketch
- (MysticObjectType) type; { return MysticObjectTypeSketch; }
- (NSString *) name; { return [MysticUser user].currentProjectName; }
@end

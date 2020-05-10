//
//  UserPotion.h
//  Mystic
//
//  Created by Travis on 10/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "UserPotionBase.h"

@interface UserPotion : UserPotionBase


+ (UserPotion *) potion;
+ (PackPotionOption *) makeOption:(MysticObjectType)newType;
+ (PackPotionOption *) makeOption:(MysticObjectType)newType userInfo:(NSDictionary *)info;
+ (BOOL) hasOption:(PackPotionOption *)option;
+ (void) removeOptionForType:(MysticObjectType)type cancel:(BOOL)cancel;


@end

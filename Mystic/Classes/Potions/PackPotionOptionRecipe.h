//
//  PackPotionOptionRecipe.h
//  Mystic
//
//  Created by travis weerts on 8/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "PackPotionOption.h"

@interface PackPotionOptionRecipe : PackPotionOption;

@property (nonatomic, retain) MysticProject *project;
@property (nonatomic, assign) MysticRecipesType recipeType;

+ (PackPotionOptionRecipe *) create;
+ (PackPotionOptionRecipe *) create:(NSString *)name;
- (void) share:(MysticBlockObjBOOL)finished;

@end

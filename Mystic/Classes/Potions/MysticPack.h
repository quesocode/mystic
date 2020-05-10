//
//  MysticPack.h
//  Mystic
//
//  Created by travis weerts on 12/22/12.
//  Copyright (c) 2012 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticPackButton.h"

@class PackPotion;
@class MysticPackIndex;
@interface MysticPack : MysticOption
{
    
}

@property (nonatomic, assign) MysticObjectType groupType, packType;
@property (nonatomic, assign) NSInteger packId;
@property (nonatomic, readonly) NSArray *packOptions, *packItems;
@property (nonatomic, readonly) PackPotionOption *sampleOption;
@property (nonatomic, retain) NSDictionary *potions;
@property (nonatomic, retain) NSMutableArray *optionKeys;
@property (nonatomic, assign) BOOL isSpecial;
@property (nonatomic, readonly) BOOL isAvailable, hasCustomControlImageURL;
@property (nonatomic, readonly) NSString *specialThumbUrl, *titleColorStr, *subTitleColorStr, *productID;
@property (nonatomic, retain) NSString *groupTitle, *title, *subtitle;
@property (nonatomic, readonly) MysticPackIndex *index;
@property (nonatomic, assign) PackPotion *defaultPotion;
@property (nonatomic, retain) NSDate *availableDate, *unavailableDate;
@property (nonatomic, assign) NSInteger numberOfPotions, maxNumberOfPotions, numberOfItems;
//@property (nonatomic, assign) NSString *queryString;
@property (nonatomic, retain) NSString *controlImageName;
@property (nonatomic) BOOL featuredPack, favoritesPack, recentPack;
+ (NSString *) featuredTitle;
+ (Class) optionsDataSourceClass;
+ (MysticObjectType) objectType;
+ (MysticPack *) packWithName:(NSString *)name info:(NSDictionary *)info;
+ (MysticPack *) packForOption:(PackPotionOption *)option;
+ (MysticPack *) packWithId:(NSInteger)packId;
+ (MysticPack *) featuredPackForType:(MysticObjectType)objType useTypeTitle:(BOOL)useTypeTitleForFeatured max:(NSInteger)max;
+ (id) packForIndex:(MysticPackIndex *)index;
+ (MysticPack *) packForType:(MysticObjectType)objType;
+ (MysticPack *) pack:(MysticObjectType)objType;

- (void) styleButton:(MysticPackButton *)button;
- (void) styleButtonText:(MysticPackButton *)button;
- (NSArray *) packItems:(MysticBlockFilteredKeyObjBOOL)filter;
- (NSInteger) numberOfItems:(MysticBlockFilteredKeyObjBOOL)filter;
- (void) packOptions:(MysticBlockData)finished;

@end


@interface MysticTextPack : MysticPack
@end

@interface MysticLightPack : MysticPack
@end

@interface MysticFramePack : MysticPack
@end

@interface MysticTexturePack : MysticPack
@end

@interface MysticShapePack : MysticPack
@end

@interface MysticLayerShapePack : MysticPack
@end

@interface MysticPackIndex : NSObject;

+ (id) packIndexForPack:(MysticPack *)pack;

@property (nonatomic, retain) id tag;
@property (nonatomic, assign) NSInteger packId, maxOptions;
@property (nonatomic, assign) MysticObjectType type;
@property (nonatomic, assign) BOOL featured;

@end



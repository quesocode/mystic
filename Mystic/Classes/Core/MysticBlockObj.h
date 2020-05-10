//
//  MysticBlockObj.h
//  Mystic
//
//  Created by Me on 3/25/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"

@interface MysticBlockObj : NSObject

@property (nonatomic, copy) MysticBlock block;
@property (nonatomic, copy) MysticBlockObject blockObject;
@property (nonatomic, copy) MysticBlockObjObj blockObjectObject;

@property (nonatomic, copy) MysticBlockBOOL blockBOOL;
@property (nonatomic, copy) MysticBlockButtonItem buttonBlock;


@property (nonatomic, retain) NSString *key;

+ (id) objectWithKey:(NSString *)theKey block:(MysticBlock)block;
+ (id) objectWithKey:(NSString *)theKey blockObject:(MysticBlockObject)ablock;
+ (id) objectWithKey:(NSString *)theKey blockBOOL:(MysticBlockBOOL)ablock;
+ (id) objectWithKey:(NSString *)theKey blockObjObj:(MysticBlockObjObj)ablock;

@end


@interface MysticImageBlockObj : MysticBlockObj;

- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(id)context;
+ (id) imageDone:(MysticBlockObjObj)aBlock;
+ (id) save:(UIImage *)image done:(MysticBlockObjObj)aBlock;

- (void) save:(UIImage *)image;

@end

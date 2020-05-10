
//
//  MysticOptions.h
//  Mystic
//
//  Created by travis weerts on 8/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticOptionsBase.h"
#import "MysticConstants.h"
#import "MysticOptionsProtocol.h"


@interface MysticOptions : MysticOptionsBase

@property (nonatomic, readonly) NSDictionary *projectDictionary;
@property (nonatomic, readonly) NSString *passDescriptionString;
@property (nonatomic, retain) NSString *projectName;
+ (MysticOptions *) current;
+ (MysticOptions *) currentOptions;
+ (MysticOptions *) reversedOptions;
+ (void) loadProject:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict;
+ (MysticOptions *) optionsFromProject:(NSDictionary *)projectDict addOptions:(BOOL)shouldAdd finished:(MysticBlockObjBOOL)finishedBlock;

- (void) savePotion:(NSString *)potionName;
- (void) saveProject;
- (void) storeImage:(UIImage *)theImage pass:(MysticOptions *)thePass;
- (void) optimizeForOffScreen;
- (void) optimizeForOnScreen;
- (void) passDescription;
+ (void) loadMultiOption:(NSDictionary *)projectDict finished:(MysticBlockObjBOOL)finishedBlock;

@end

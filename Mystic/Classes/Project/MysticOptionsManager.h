//
//  MysticOptions.h
//  Mystic
//
//  Created by travis weerts on 8/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticOptions.h"

@class MysticPreloaderImage, MysticFilterManager, MysticOptionsManager;

@protocol MysticOptionsManagerDelegate <NSObject>

@optional

@end


@interface MysticOptionsManager : MysticOptions


@property (nonatomic, readonly) NSArray *passes;
@property (nonatomic, readonly) NSInteger numberOfPasses, sortedOptionsCount;
@property (nonatomic, assign) NSInteger pass, nextPassIndex, numberOfOptionsPerPass;
@property (nonatomic, assign) BOOL hasAnotherPass, ignoreOptionsWithoutInput;
@property (nonatomic, assign) id delegate;
@property (nonatomic) BOOL hasMultiplePasses, isLastPass;

+ (id) managerWithOptions:(MysticOptions *)theOptions;
+ (id) managerWithOptions:(MysticOptions *)theOptions passes:(NSArray *)passes;

- (NSArray *) passesWithMax:(NSInteger)max;
- (NSInteger) numberOfPassesWithMax:(NSInteger)max;
- (MysticOptions *) nextPass;
- (void) resetManager;
- (MysticOptions *) currentPass;


@end

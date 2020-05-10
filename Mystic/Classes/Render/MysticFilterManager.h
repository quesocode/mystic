//
//  MysticFilterManager.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticFilterLayer.h"

@class MysticImageFilter, MysticGPUImageView;




@interface MysticFilterManager : NSObject

@property (nonatomic, retain) MysticGPUImageSourcePicture *sourcePicture;
//@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) MysticImageFilter *filter;
@property (nonatomic, retain) MysticShadersObject *shader;
@property (nonatomic, retain) NSMutableArray *allLayers;
@property (nonatomic, retain) NSMutableDictionary *layerKeys;
@property (nonatomic, retain) GPUImageOutput <GPUImageInput> * lastOutput;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL  sourceNeedsProcess;
@property (nonatomic, assign) MysticGPUImageView *imageView;
@property (nonatomic, readonly) id firstInput, lastLayerOutput;
+ (MysticFilterManager *) manager;
+ (NSString *) optionTag:(PackPotionOption *)_option;

- (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt tag:(NSString *)layerTag;
- (void) clearCurrentLayers;
- (void) clearLayersForOptions:(MysticOptions *)theOptions;
- (void) clean;
- (void) empty;
- (BOOL) processSourceImage;
- (BOOL) processSourceImageWithCompletion:(MysticBlock)finished;
- (BOOL) usesSameShadersAs:(MysticFilterManager *)otherManager;
- (void) addLayer:(MysticFilterLayer *)layer;
- (void) addLayers:(NSArray *)layersToAdd;

- (MysticFilterLayer *)layerForOption:(MysticOption *)option;
- (MysticFilterLayer *)layerForOption:(MysticOption *)option tag:(NSString *)layerTag;
- (NSArray *) layersForOption:(MysticOption *)option;
- (NSInteger) indexForOption:(MysticOption *)option;
- (MysticFilterLayer *) removeLayer:(MysticFilterLayer *)removeLayer;
- (void) removeAllLayers;
- (void) removeLayersExcept:(NSArray *)exceptions;
- (void) refresh:(PackPotionOption *)option;
- (void) refresh:(PackPotionOption *)option completion:(MysticBlock)finished;
- (MysticFilterLayer *) recycledLayerForOption:(PackPotionOption *)option;
- (BOOL) containsLayer:(MysticFilterLayer *)layer;
- (void)cleanUpNonDisplayFilters;
- (NSString *) logTargetsTree;

@end




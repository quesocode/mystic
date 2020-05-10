
//  MysticFilterLayer.h
//  Mystic
//
//  Created by Me on 11/13/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@class MysticImageFilter;

@interface MysticFilterLayer : NSObject

@property (nonatomic, retain) MysticGPUImageLayerPicture *sourcePicture;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, retain) MysticImage *image;
@property (nonatomic, retain) NSMutableArray *filterKeys;
@property (nonatomic, retain) NSArray *siblings;
@property (nonatomic, readonly) NSInteger level, position;
@property (nonatomic, readonly) NSString *filterKeysDescription;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) PackPotionOption *option;
@property (nonatomic, retain) NSMutableDictionary *filters;
@property (nonatomic, readonly) NSArray *orderedFilters;
@property (nonatomic, readonly) MysticObjectType type;
@property (nonatomic, retain) GPUImageOutput <GPUImageInput> * lastOutput;
@property (nonatomic, readonly) GPUImageOutput <GPUImageInput> * firstOutput;

@property (nonatomic, assign) BOOL refreshAll, requiresRefresh, isSourceLayer, setUseNextFrame, forceRequiresRefresh, hasGroupFilter;
@property (nonatomic, assign) BOOL added, hasSiblings;
@property (nonatomic, retain) NSMutableDictionary *textures;



+ (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt;
+ (MysticFilterLayer *) layerFromOption:(PackPotionOption *)opt tag:(NSString *)tag;
- (id) initWithOption:(PackPotionOption *)opt;
- (id) addFilter:(id)obj forKey:(id)key;
- (id) addFilter:(id)obj;
- (id) setFilter:(id)obj forKey:(id)key;
- (void) clean;
- (void) cleanAll;
- (void) empty;
- (id) filterForKey:(id)key;
- (void) removeFilterForKey:(id)key;
- (void) refresh:(PackPotionOption *)option;
- (void) addTexture:(MysticGPUImageLayerTexture *)texture forKey:(id)key;
- (void) addTextureFilter:(id)texture forKey:(id)key textureKey:(id)textureKey;

 - (void) prepareForUse;
- (void) replaceTexture:(id)textureKey image:(UIImage *)textureImage;


@end

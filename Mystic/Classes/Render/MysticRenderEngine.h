//
//  MysticRenderEngine.h
//  Mystic
//
//  Created by travis weerts on 8/20/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "GPUImage.h"
#import "MysticGPUImageFilterGroup.h"

@class MysticFilterLayer;

@interface MysticRenderEngine : NSObject

+ (GPUImageOutput<GPUImageInput> *) adjustTarget:(GPUImageOutput<GPUImageInput> *)filter effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer options:(MysticOptions *)options context:(NSDictionary *)context;
+ (GPUImageOutput<GPUImageInput> *) initFilter:(MysticObjectType)filterType target:(GPUImageOutput<GPUImageInput> *)filter effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer options:(MysticOptions *)options;
+ (id) filterForKey:(id)filterKey filterType:(MysticObjectType)filterType effect:(PackPotionOption *)effect layer:(MysticFilterLayer *)layer;


@end



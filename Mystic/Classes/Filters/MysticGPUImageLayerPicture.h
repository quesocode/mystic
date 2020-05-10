//
//  MysticLayerImagePicture.h
//  Mystic
//
//  Created by Travis on 10/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticGPUImageSourcePicture.h"

@interface MysticGPUImageLayerPicture : GPUImagePicture
- (BOOL) updateTargets;

@end

@interface MysticGPUImageLayerTexture : MysticGPUImageLayerPicture

@end

@interface MysticGPUImageLayerTextureMap : MysticGPUImageLayerTexture

@end

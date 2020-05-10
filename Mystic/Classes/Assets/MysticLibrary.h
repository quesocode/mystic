//
//  MysticLibrary.h
//  Mystic
//
//  Created by Me on 10/22/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <Photos/Photos.h>

#else
//#error Your SDK is too old for Photos Framework! Need at least 8.0.
#endif


@interface MysticLibrary : NSObject
+ (id) sharedLibrary;
+ (id) fetchAlbums:(MysticBlockObject)finished;
+ (id) fetchCameraRoll:(MysticBlockObject)finished;
+ (id) fetchCameraRollAssets:(MysticBlockObjObj)finished;
+ (void) fetchLastCameraRollPhoto:(MysticBlockObjObj)finished;
+ (ALAssetsLibrary *) sharedAssetsLibrary;
+ (void) save:(UIImage *)image album:(NSString *)albumName finished:(MysticBlockObject)finished;
+ (void) fetchLastCameraRollAsset:(MysticBlockObjObjObj)finished;

@end

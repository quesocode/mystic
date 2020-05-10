//
//  MysticAssetCollectionItem.h
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionItem.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MysticAssetCollectionItem : MysticCollectionItem

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, readonly) NSDictionary *assetInfo;
@property (nonatomic, readonly) UIImageOrientation imageOrientation;
@property (nonatomic, readonly) NSDictionary *mediaMetaData;
@property (nonatomic, readonly) BOOL imageHasAdjustments;
@property (nonatomic, readonly) UIImage *editedImage;
@end
